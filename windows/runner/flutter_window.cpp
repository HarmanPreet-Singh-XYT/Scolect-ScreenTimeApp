#include "flutter_window.h"

#include <windows.h>
#include <powrprof.h>
#include <optional>
#include "flutter/generated_plugin_registrant.h"

#pragma comment(lib, "powrprof.lib")

// Load WTS functions dynamically to avoid wtsapi32.h linker issues
namespace {

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

  restart_channel_.reset();
  flutter_controller_.reset();
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