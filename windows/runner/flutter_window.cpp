#include "flutter_window.h"

#include <windows.h>
#include <shellapi.h>
#include <powrprof.h>
#include <atomic>
#include <optional>
#include <string>
#include <thread>
#include "flutter/generated_plugin_registrant.h"

#pragma comment(lib, "powrprof.lib")
#pragma comment(lib, "shell32.lib")

// Custom window message used to marshal overlay callbacks from the Rust Win32
// thread back to the Flutter engine messenger thread (the main Win32 thread).
// LPARAM carries a heap-allocated char* (must be freed after use).
//
// This MUST be a globally-registered message (RegisterWindowMessageA), not a
// raw WM_USER+N value: the Flutter Windows embedder's own platform-thread
// task runner posts messages to this window using IDs in the WM_USER range
// for its internal wakeups. HandleTopLevelWindowProc() runs before our own
// switch in MessageHandler and swallows anything it recognizes as its own —
// a raw WM_USER+1 collided with that and silently ate every overlay action
// (the Rust click handler and native callback both fired correctly, but the
// posted message never reached our switch, so Dart never heard about it).
static const UINT WM_OVERLAY_ACTION = RegisterWindowMessageA("ScolectBlockOverlayAction");

// ─── Function pointer types for block_overlay.dll ────────────────────────────
typedef void (*PFN_block_overlay_show)(DWORD pid, const char* app_name,
                                       int used_seconds, int limit_seconds,
                                       bool hard_block,
                                       BlockOverlayCallback callback);
typedef void (*PFN_block_overlay_dismiss)();
typedef void (*PFN_block_overlay_start_grace)(int seconds);

// ─── Globals shared between the Flutter window and the Rust callback ──────────
namespace {

// The main window HWND — set in OnCreate, used by the Rust callback and the
// power-notification callback (both on foreign threads) to post messages back
// to the main thread. Atomic because OnDestroy clears it concurrently.
std::atomic<HWND> g_main_hwnd{nullptr};

// Overlay channel pointer — set in OnCreate, used in MessageHandler.
// Raw pointer is safe because FlutterWindow outlives the message loop.
flutter::MethodChannel<>* g_overlay_channel = nullptr;

// ─── DLL function pointers (null until DLL is loaded) ─────────────────────

PFN_block_overlay_show       g_show_fn    = nullptr;
PFN_block_overlay_dismiss    g_dismiss_fn = nullptr;
PFN_block_overlay_start_grace g_grace_fn  = nullptr;

// ─── Rust → Flutter callback (called from Rust Win32 thread) ─────────────────
// Posts WM_OVERLAY_ACTION to the main window so that the method channel
// InvokeMethod call happens on the correct thread.
void CALLBACK OverlayCallback(const char* action) {
  HWND hwnd = g_main_hwnd.load();
  if (!hwnd || !action) return;
  // Duplicate the string onto the heap; MessageHandler frees it.
  char* copy = _strdup(action);
  if (!copy) return;
  if (!PostMessage(hwnd, WM_OVERLAY_ACTION, 0,
                   reinterpret_cast<LPARAM>(copy))) {
    free(copy);  // window gone / queue full: nobody will ever receive it
  }
}

// ─── WTS helpers ──────────────────────────────────────────────────────────────

typedef BOOL(WINAPI* WTSRegisterFn)(HWND, DWORD);
typedef BOOL(WINAPI* WTSUnregisterFn)(HWND);

void RegisterWTSNotification(HWND hwnd) {
  HMODULE lib = LoadLibraryA("wtsapi32.dll");
  if (!lib) return;
  auto fn = (WTSRegisterFn)GetProcAddress(lib, "WTSRegisterSessionNotification");
  if (fn) fn(hwnd, 0); // 0 = NOTIFY_FOR_THIS_SESSION
  FreeLibrary(lib);
}

void UnregisterWTSNotification(HWND hwnd) {
  HMODULE lib = LoadLibraryA("wtsapi32.dll");
  if (!lib) return;
  auto fn = (WTSUnregisterFn)GetProcAddress(lib, "WTSUnregisterSessionNotification");
  if (fn) fn(hwnd);
  FreeLibrary(lib);
}

} // namespace

// =========================
// FlutterWindow
// =========================

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {
  // Tear down while this object is still fully alive. If the message loop
  // exits without WM_DESTROY having run (e.g. PostQuitMessage from
  // SystemNavigator.pop / exit), the HWND is still valid here, and letting the
  // flutter_controller_ member destruct implicitly would leave it non-null but
  // half-destroyed while Windows keeps delivering messages to MessageHandler.
  Destroy();

  if (power_notification_handle_) {
    UnregisterPowerSettingNotification(power_notification_handle_);
    power_notification_handle_ = nullptr;
  }
  if (suspend_resume_handle_) {
    PowerUnregisterSuspendResumeNotification(suspend_resume_handle_);
    suspend_resume_handle_ = nullptr;
  }
}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left,
      frame.bottom - frame.top,
      project_);

  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }

  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([this]() {
    // Show(); // optional
  });
  flutter_controller_->ForceRedraw();

  // Store main HWND for cross-thread callback marshalling.
  g_main_hwnd = GetHandle();

  // -------------------------
  // Restart Method Channel
  // -------------------------
  restart_channel_ = std::make_unique<flutter::MethodChannel<>>(
      flutter_controller_->engine()->messenger(),
      "app_restart",
      &flutter::StandardMethodCodec::GetInstance());

  restart_channel_->SetMethodCallHandler(
      [](const flutter::MethodCall<>& call,
         std::unique_ptr<flutter::MethodResult<>> result) {
        if (call.method_name() == "restartApp") {
          RestartApplication();
          result->Success();
        } else {
          result->NotImplemented();
        }
      });

  // -------------------------
  // Block Overlay DLL + Method Channel
  // -------------------------
  // Load the Rust DLL dynamically so the app still starts if the DLL is absent
  // (e.g. during a non-Windows build or before the Rust crate has been built).
  // Load by full path from the exe's directory: a bare name goes through the
  // normal search order (current directory, PATH), which can pick up a stale
  // or planted DLL.
  {
    std::wstring dll_path(32768, L'\0');
    DWORD len = GetModuleFileNameW(nullptr, dll_path.data(),
                                   static_cast<DWORD>(dll_path.size()));
    if (len > 0 && len < dll_path.size()) {
      dll_path.resize(len);
      size_t slash = dll_path.find_last_of(L"\\/");
      if (slash != std::wstring::npos) {
        dll_path.resize(slash + 1);
        dll_path += L"block_overlay.dll";
        block_overlay_dll_ = LoadLibraryExW(
            dll_path.c_str(), nullptr,
            LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR | LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
      }
    }
  }
  if (block_overlay_dll_) {
    g_show_fn = reinterpret_cast<PFN_block_overlay_show>(
        GetProcAddress(block_overlay_dll_, "block_overlay_show"));
    g_dismiss_fn = reinterpret_cast<PFN_block_overlay_dismiss>(
        GetProcAddress(block_overlay_dll_, "block_overlay_dismiss"));
    g_grace_fn = reinterpret_cast<PFN_block_overlay_start_grace>(
        GetProcAddress(block_overlay_dll_, "block_overlay_start_grace"));
  }

  overlay_channel_ = std::make_unique<flutter::MethodChannel<>>(
      flutter_controller_->engine()->messenger(),
      "timemark/block_overlay",
      &flutter::StandardMethodCodec::GetInstance());

  // Store raw ptr so the WM_OVERLAY_ACTION handler can use it without capturing
  // the unique_ptr (which would extend lifetime past OnDestroy).
  g_overlay_channel = overlay_channel_.get();

  overlay_channel_->SetMethodCallHandler(
      [](const flutter::MethodCall<>& call,
         std::unique_ptr<flutter::MethodResult<>> result) {
        const std::string& method = call.method_name();

        if (method == "show") {
          if (!g_show_fn) { result->Error("UNAVAILABLE", "block_overlay.dll not loaded"); return; }

          const auto* args =
              std::get_if<flutter::EncodableMap>(call.arguments());
          if (!args) { result->Error("BAD_ARGS", "Expected map"); return; }

          auto get_int = [&](const std::string& key, int def = 0) -> int {
            auto it = args->find(flutter::EncodableValue(key));
            if (it == args->end()) return def;
            if (auto* v = std::get_if<int32_t>(&it->second)) return *v;
            if (auto* v = std::get_if<int64_t>(&it->second)) return static_cast<int>(*v);
            return def;
          };
          auto get_str = [&](const std::string& key) -> std::string {
            auto it = args->find(flutter::EncodableValue(key));
            if (it == args->end()) return "";
            if (auto* v = std::get_if<std::string>(&it->second)) return *v;
            return "";
          };
          auto get_bool = [&](const std::string& key) -> bool {
            auto it = args->find(flutter::EncodableValue(key));
            if (it == args->end()) return false;
            if (auto* v = std::get_if<bool>(&it->second)) return *v;
            return false;
          };

          DWORD pid            = static_cast<DWORD>(get_int("pid"));
          std::string app_name = get_str("appName");
          int used_sec         = get_int("usedSeconds");
          int limit_sec        = get_int("limitSeconds");
          bool hard            = get_bool("hardBlock");

          g_show_fn(pid, app_name.c_str(), used_sec, limit_sec, hard,
                    OverlayCallback);
          result->Success();

        } else if (method == "dismiss") {
          if (g_dismiss_fn) g_dismiss_fn();
          result->Success();

        } else if (method == "startGrace") {
          if (!g_grace_fn) { result->Error("UNAVAILABLE", "block_overlay.dll not loaded"); return; }
          int seconds = 300;
          if (auto* v32 = std::get_if<int32_t>(call.arguments())) seconds = *v32;
          else if (auto* v64 = std::get_if<int64_t>(call.arguments())) seconds = static_cast<int>(*v64);
          g_grace_fn(seconds);
          result->Success();

        } else {
          result->NotImplemented();
        }
      });

  // -------------------------
  // Screen state: display on/off
  // Requires GUID_CONSOLE_DISPLAY_STATE registration so Windows
  // delivers PBT_POWERSETTINGCHANGE to this window.
  // -------------------------
  power_notification_handle_ = RegisterPowerSettingNotification(
      GetHandle(), &GUID_CONSOLE_DISPLAY_STATE, DEVICE_NOTIFY_WINDOW_HANDLE);

  // -------------------------
  // Screen state: lock/unlock
  // Loaded dynamically to avoid wtsapi32.h linker issues.
  // -------------------------
  RegisterWTSNotification(GetHandle());

  // -------------------------
  // Screen state: true system sleep/resume
  // Uses a callback on a system thread so it fires BEFORE the CPU halts —
  // unlike WM_POWERBROADCAST which may not be processed in time.
  // PostMessage routes it back through HandleTopLevelWindowProc so the
  // plugin's existing WM_POWERBROADCAST handler picks it up normally.
  // -------------------------
  DEVICE_NOTIFY_SUBSCRIBE_PARAMETERS params = {};
  params.Context = this;
  params.Callback = [](PVOID /*context*/, ULONG type, PVOID /*setting*/) -> ULONG {
    // Runs on a system thread: use the atomic handle, never touch `this`.
    HWND hwnd = g_main_hwnd.load();
    if (!hwnd) return ERROR_SUCCESS;
    switch (type) {
      case PBT_APMSUSPEND:
        PostMessage(hwnd, WM_POWERBROADCAST, PBT_APMSUSPEND, 0);
        break;
      case PBT_APMRESUMEAUTOMATIC:
        PostMessage(hwnd, WM_POWERBROADCAST, PBT_APMRESUMEAUTOMATIC, 0);
        break;
    }
    return ERROR_SUCCESS;
  };

  PowerRegisterSuspendResumeNotification(
      DEVICE_NOTIFY_CALLBACK,
      &params,
      &suspend_resume_handle_);

  return true;
}

void FlutterWindow::OnDestroy() {
  // The suspend/resume callback holds `this` and runs on a system thread, so
  // stop it before anything it touches goes away.
  if (power_notification_handle_) {
    UnregisterPowerSettingNotification(power_notification_handle_);
    power_notification_handle_ = nullptr;
  }
  if (suspend_resume_handle_) {
    PowerUnregisterSuspendResumeNotification(suspend_resume_handle_);
    suspend_resume_handle_ = nullptr;
  }

  // Unregister WTS while HWND is still valid. On the WM_DESTROY path the base
  // class has already nulled its handle (the window itself is still alive), so
  // fall back to the handle we published for the other threads.
  HWND wts_hwnd = GetHandle();
  if (!wts_hwnd) wts_hwnd = g_main_hwnd.load();
  if (wts_hwnd) UnregisterWTSNotification(wts_hwnd);

  // Dismiss any live overlay before tearing down the channel.
  if (g_dismiss_fn) g_dismiss_fn();
  g_overlay_channel = nullptr;
  g_main_hwnd = nullptr;

  overlay_channel_.reset();
  restart_channel_.reset();
  // Move the controller out BEFORE destroying it, so flutter_controller_ is
  // already null if destruction pumps messages back into MessageHandler
  // (the engine's view teardown does). Otherwise HandleTopLevelWindowProc is
  // called on a controller whose view is gone -> ACCESS_VIOLATION in
  // FlutterWindowsView::GetEngine.
  {
    std::unique_ptr<flutter::FlutterViewController> controller =
        std::move(flutter_controller_);
    controller.reset();
  }

  // Deliberately NOT calling FreeLibrary(block_overlay_dll_): the DLL owns a
  // live Win32 message-loop thread (and its wndproc), and unmapping the module
  // under it crashes the process on exit. The OS reclaims it at process exit.
  g_show_fn    = nullptr;
  g_dismiss_fn = nullptr;
  g_grace_fn   = nullptr;

  Win32Window::OnDestroy();
}

LRESULT FlutterWindow::MessageHandler(HWND hwnd,
                                      UINT const message,
                                      WPARAM const wparam,
                                      LPARAM const lparam) noexcept {
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(
            hwnd, message, wparam, lparam);
    if (result) {
      return *result;
    }
  }

  // WM_OVERLAY_ACTION is a RegisterWindowMessageA() value, not a compile-time
  // constant, so it can't be a switch `case` label — handle it separately.
  if (message == WM_OVERLAY_ACTION) {
    // Fired from OverlayCallback (Rust Win32 thread) via PostMessage.
    // LPARAM is a heap-allocated char* (strdup'd in OverlayCallback).
    char* action = reinterpret_cast<char*>(lparam);
    if (action && g_overlay_channel) {
      std::string action_str(action);
      g_overlay_channel->InvokeMethod(
          "onAction",
          std::make_unique<flutter::EncodableValue>(action_str));
    }
    free(action);
    return 0;
  }

  switch (message) {
    case WM_QUERYENDSESSION:
      return TRUE;
    case WM_ENDSESSION:
      // Shutdown/restart/logoff (incl. MSIX update restarts). WM_CLOSE is
      // intercepted by preventClose to hide to tray, so without this the app
      // never exits and the OS reports a hang.
      if (wparam) PostQuitMessage(0);
      return 0;
    case WM_FONTCHANGE:
      if (flutter_controller_) {
        flutter_controller_->engine()->ReloadSystemFonts();
      }
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

// =========================
// App Restart Logic
// =========================

void RestartApplication() {
  std::wstring exe_path(32768, L'\0');
  DWORD n = GetModuleFileNameW(nullptr, exe_path.data(),
                               static_cast<DWORD>(exe_path.size()));
  if (n == 0 || n >= exe_path.size()) {
    return;  // Can't locate ourselves: keep running rather than vanish.
  }
  exe_path.resize(n);

  // The new instance waits for this process to exit (see main.cpp) before it
  // does its single-instance check, so it can't mistake us for a live
  // instance and bail out, leaving the user with no app at all.
  std::wstring params =
      L"--wait-for-pid=" + std::to_wstring(GetCurrentProcessId());
  int argc = 0;
  if (LPWSTR* argv = CommandLineToArgvW(GetCommandLineW(), &argc)) {
    for (int i = 1; i < argc; i++) {
      if (wcsncmp(argv[i], L"--wait-for-pid=", 15) == 0) continue;
      params += L" \"";
      params += argv[i];
      params += L"\"";
    }
    LocalFree(argv);
  }

  bool launched = false;

  // ShellExecuteW correctly handles packaged MSIX applications (AppX
  // activation / shell execution alias) as well as unpackaged binaries.
  HINSTANCE hInst = ShellExecuteW(nullptr, L"open", exe_path.c_str(),
                                  params.c_str(), nullptr, SW_SHOWNORMAL);
  launched = reinterpret_cast<INT_PTR>(hInst) > 32;

  if (!launched) {
    std::wstring cmd = L"\"" + exe_path + L"\" " + params;
    STARTUPINFOW si{};
    si.cb = sizeof(si);
    PROCESS_INFORMATION pi{};
    if (CreateProcessW(exe_path.c_str(), cmd.data(), nullptr, nullptr, FALSE,
                       0, nullptr, nullptr, &si, &pi)) {
      CloseHandle(pi.hProcess);
      CloseHandle(pi.hThread);
      launched = true;
    }
  }

  if (!launched) {
    return;  // Restart failed; stay alive instead of quitting for nothing.
  }

  // Quit through the normal path so the window/engine tear down and Dart gets
  // to flush storage; ExitProcess here would cut all of that off (and can hang
  // under the loader lock with the overlay/GDI+/Dart threads still running).
  PostQuitMessage(0);

  // Safety net: if shutdown wedges, the waiting new instance must not hang
  // forever — hard-kill ourselves after a grace period.
  std::thread([]() {
    Sleep(8000);
    TerminateProcess(GetCurrentProcess(), 0);
  }).detach();
}
