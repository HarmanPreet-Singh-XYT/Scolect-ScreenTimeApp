// lib/foreground_window_plugin_web.dart

import 'foreground_window_info.dart';

class ForegroundWindowPlugin {
  static Future<WindowInfo> getForegroundWindowInfo() async {
    return WindowInfo.unknown();
  }
}
