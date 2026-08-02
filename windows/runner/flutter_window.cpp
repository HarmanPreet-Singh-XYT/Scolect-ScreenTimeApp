#include "flutter_window.h"

#include <windows.h>
#include <powrprof.h>
#include <optional>
#include <string>
#include "flutter/generated_plugin_registrant.h"

#pragma comment(lib, "powrprof.lib")

// Custom window message used to marshal overlay callbacks from the Rust Win32
// thread back to the Flutter engine messenger thread (the main Win32 thread).
// LPARAM carries a heap-allocated char* (must be freed after use).
#define WM_OVERLAY_ACTION (WM_USER + 1)

// ─── Function pointer types for block_overlay.dll ────────────────────────────
typedef void (*PFN_block_overlay_show)(DWORD pid, const char* app_name,
                                       int used_seconds, int limit_seconds,
                                       bool hard_block,
                                       BlockOverlayCallback callback);
typedef void (*PFN_block_overlay_dismiss)();
typedef void (*PFN_block_overlay_start_grace)(int seconds);

// ─── Globals shared between the Flutter window and the Rust callback ──────────
namespace {

// The main window HWND — set in OnCreate, used by the Rust callback to post
// WM_OVERLAY_ACTION back to the main thread.
HWND g_main_hwnd = nullptr;

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
  if (!g_main_hwnd || !action) return;
  // Duplicate the string onto the heap; MessageHandler frees it.
  char* copy = _strdup(action);
  PostMessage(g_main_hwnd, WM_OVERLAY_ACTION, 0,
              reinterpret_cast<LPARAM>(copy));
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
  block_overlay_dll_ = LoadLibraryA("block_overlay.dll");
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
          if (auto* v = std::get_if<int32_t>(call.arguments())) seconds = *v;
          else if (auto* v = std::get_if<int64_t>(call.arguments())) seconds = static_cast<int>(*v);
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
  params.Callback = [](PVOID context, ULONG type, PVOID /*setting*/) -> ULONG {
    FlutterWindow* self = static_cast<FlutterWindow*>(context);
    HWND hwnd = self->GetHandle();
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
  // Unregister WTS while HWND is still valid
  UnregisterWTSNotification(GetHandle());

  // Dismiss any live overlay before tearing down the channel.
  if (g_dismiss_fn) g_dismiss_fn();
  g_overlay_channel = nullptr;
  g_main_hwnd = nullptr;

  overlay_channel_.reset();
  restart_channel_.reset();
  flutter_controller_.reset();

  if (block_overlay_dll_) {
    FreeLibrary(block_overlay_dll_);
    block_overlay_dll_ = nullptr;
    g_show_fn    = nullptr;
    g_dismiss_fn = nullptr;
    g_grace_fn   = nullptr;
  }

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

  switch (message) {
    case WM_FONTCHANGE:
      if (flutter_controller_) {
        flutter_controller_->engine()->ReloadSystemFonts();
      }
      break;

    case WM_OVERLAY_ACTION: {
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
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

// =========================
// App Restart Logic
// =========================

void RestartApplication() {
  wchar_t exePath[MAX_PATH] = {};
  if (GetModuleFileNameW(nullptr, exePath, MAX_PATH) == 0) {
    ExitProcess(0);
  }

  STARTUPINFOW si{};
  si.cb = sizeof(si);
  PROCESS_INFORMATION pi{};

  if (CreateProcessW(
          exePath,
          nullptr,
          nullptr,
          nullptr,
          FALSE,
          0,
          nullptr,
          nullptr,
          &si,
          &pi)) {
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
  }

  ExitProcess(0);
}