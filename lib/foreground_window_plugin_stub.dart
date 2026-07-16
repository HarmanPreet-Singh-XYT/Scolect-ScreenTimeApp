// lib/foreground_window_plugin_stub.dart

import 'foreground_window_info.dart';

class ForegroundWindowPlugin {
  static Future<WindowInfo> getForegroundWindowInfo() async {
    throw UnsupportedError('ForegroundWindowPlugin is not supported on this platform.');
  }
}
