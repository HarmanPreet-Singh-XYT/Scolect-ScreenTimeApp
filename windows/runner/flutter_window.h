#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <memory>
#include <windows.h>
#include <powrprof.h>
#include "win32_window.h"
#include "block_overlay_ffi.h"

// Restarts the current application.
void RestartApplication();

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window,
                         UINT const message,
                         WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;

  // Method channel for app restart
  std::unique_ptr<flutter::MethodChannel<>> restart_channel_;

  // Method channel for block overlay (timemark/block_overlay)
  std::unique_ptr<flutter::MethodChannel<>> overlay_channel_;

  // Handle to the block_overlay Rust DLL (loaded dynamically at runtime)
  HMODULE block_overlay_dll_ = nullptr;

  // Handle for GUID_CONSOLE_DISPLAY_STATE (screen on/off)
  HPOWERNOTIFY power_notification_handle_ = nullptr;

  // Handle for true system sleep/resume callback (fires on system thread)
  HPOWERNOTIFY suspend_resume_handle_ = nullptr;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_