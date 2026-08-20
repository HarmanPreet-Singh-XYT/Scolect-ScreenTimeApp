// lib/foreground_window_plugin_desktop.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'foreground_window_info.dart';
import 'foreground_window_plugin_windows.dart' as windows;

class ForegroundWindowPlugin {
  static const MethodChannel _channel = MethodChannel('foreground_window_plugin');

  static Future<WindowInfo> getForegroundWindowInfo() async {
    if (Platform.isWindows) {
      final winInfo = await windows.ForegroundWindowPlugin.getForegroundWindowInfo();
      return WindowInfo(
        windowTitle: winInfo.windowTitle,
        processName: winInfo.processName,
        executableName: winInfo.executableName,
        programName: winInfo.programName,
        processId: winInfo.processId,
        parentProcessId: winInfo.parentProcessId,
        parentProcessName: winInfo.parentProcessName,
        appId: winInfo.appId,
      );
    } else if (Platform.isMacOS) {
      try {
        final result = await _channel.invokeMethod('getForegroundWindow');
        final data = Map<String, dynamic>.from(result);
        
        return WindowInfo(
          windowTitle: data['windowTitle'] as String? ?? 'Unknown',
          processName: data['processName'] as String? ?? 'Unknown',
          executableName: data['executableName'] as String? ?? 'Unknown',
          programName: data['programName'] as String? ?? 'Unknown',
          processId: data['processId'] as int? ?? 0,
          parentProcessId: data['parentProcessId'] as int? ?? 0,
          parentProcessName: data['parentProcessName'] as String? ?? 'Unknown',
          appId: data['appId'] as String? ?? 'unknown',
        );
      } catch (e) {
        throw Exception('Failed to get foreground window: $e');
      }
    } else {
      throw UnsupportedError('Platform ${Platform.operatingSystem} is not supported');
    }
  }

  static Future<void> hideOtherApp(int pid) async {
    if (Platform.isWindows) {
      await windows.ForegroundWindowPlugin.hideOtherApp(pid);
    }
  }

  static Future<void> terminateOtherApp(int pid) async {
    if (Platform.isWindows) {
      await windows.ForegroundWindowPlugin.terminateOtherApp(pid);
    }
  }
}
