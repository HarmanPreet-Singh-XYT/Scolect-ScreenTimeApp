// lib/foreground_window_plugin_web.dart

import 'foreground_window_info.dart';

class ForegroundWindowPlugin {
  static Future<WindowInfo> getForegroundWindowInfo({int? targetHwnd}) async {
    return WindowInfo.unknown();
  }

  static Future<void> hideOtherApp(int pid) async {}

  static Future<void> terminateOtherApp(int pid) async {}
}
