#include <bitsdojo_window_windows/bitsdojo_window_plugin.h>
auto bdw = bitsdojo_window_configure(BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP);
#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <cstdlib>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  // Restart handshake (see RestartApplication): wait for the previous
  // instance to be fully gone before doing anything that could collide with
  // it, and don't leak the flag to the Dart entrypoint.
  const std::string kWaitFlag = "--wait-for-pid=";
  for (auto it = command_line_arguments.begin();
       it != command_line_arguments.end();) {
    if (it->rfind(kWaitFlag, 0) == 0) {
      DWORD old_pid = static_cast<DWORD>(strtoul(it->c_str() + kWaitFlag.size(), nullptr, 10));
      if (old_pid != 0) {
        if (HANDLE old = ::OpenProcess(SYNCHRONIZE, FALSE, old_pid)) {
          ::WaitForSingleObject(old, 15000);
          ::CloseHandle(old);
        }
      }
      it = command_line_arguments.erase(it);
    } else {
      ++it;
    }
  }

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  int exit_code = EXIT_SUCCESS;
  {
    // Scoped so the window (and the engine inside it) is destroyed BEFORE
    // CoUninitialize; plugins may still be using COM during teardown.
    FlutterWindow window(project);
    Win32Window::Point origin(10, 10);
    Win32Window::Size size(1280, 720);
    if (!window.Create(L"screentime", origin, size)) {
      exit_code = EXIT_FAILURE;
    } else {
      window.SetQuitOnClose(true);

      ::MSG msg;
      BOOL got;
      // GetMessage returns -1 on error; `while (GetMessage(...))` would spin.
      while ((got = ::GetMessage(&msg, nullptr, 0, 0)) != 0) {
        if (got == -1) break;
        ::TranslateMessage(&msg);
        ::DispatchMessage(&msg);
      }
    }
  }

  ::CoUninitialize();
  return exit_code;
}
