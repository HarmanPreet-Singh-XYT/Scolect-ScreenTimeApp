// lib/foreground_window_plugin.dart
// Main plugin file that resolves based on platform capability

export 'foreground_window_info.dart';
export 'foreground_window_plugin_stub.dart'
    if (dart.library.io) 'foreground_window_plugin_desktop.dart'
    if (dart.library.html) 'foreground_window_plugin_web.dart';
