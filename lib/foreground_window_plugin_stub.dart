// lib/foreground_window_plugin_stub.dart

import 'foreground_window_info.dart';

class ForegroundWindowPlugin {
  static Future<WindowInfo> getForegroundWindowInfo() async {
    throw UnsupportedError('ForegroundWindowPlugin is not supported on this platform.');
  }

  static Future<void> hideOtherApp(int pid) async {}

  static Future<void> terminateOtherApp(int pid) async {}
}
