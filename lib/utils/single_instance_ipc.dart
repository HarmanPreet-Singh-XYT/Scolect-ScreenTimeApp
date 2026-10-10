import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart';
import 'macos_window.dart';

class SingleInstanceIPC {
  static const int _port = 45999;
  static ServerSocket? _server;

  /// Call ONLY in the primary instance
  static Future<void> startServer() async {
    try {
      _server = await ServerSocket.bind(
        InternetAddress.loopbackIPv4,
        _port,
        shared: false,
      );

      debugPrint('✅ IPC Server started on port $_port');

      _server!.listen((client) {
        client.listen((data) {
          final msg = String.fromCharCodes(data).trim();
          debugPrint('📨 IPC received: $msg');
          _handleCommand(msg);
        });
      });
    } catch (e) {
      debugPrint('⚠️ IPC Server bind failed: $e');
    }
  }

  /// Handle incoming IPC commands
  static void _handleCommand(String command) {
    switch (command) {
      case 'SHOW':
        _showWindow();
        break;
      case 'HIDE':
        _hideWindow();
        break;
      case 'EXIT':
        _exitApp();
        break;
      default:
        debugPrint('⚠️ Unknown IPC command: $command');
    }
  }

  static void _showWindow() {
    if (Platform.isMacOS) {
      MacOSWindow.show();
    } else {
      appWindow.show();
      appWindow.restore();
    }
  }

  static void _hideWindow() {
    if (Platform.isMacOS) {
      MacOSWindow.hide();
    } else {
      appWindow.hide();
    }
  }

  static void _exitApp() {
    if (Platform.isMacOS) {
      MacOSWindow.exit();
    } else {
      windowManager.destroy();
    }
  }

  /// Call ONLY in secondary instance
  static Future<void> requestShow() async {
    await _sendCommand('SHOW');
  }

  static Future<void> requestHide() async {
    await _sendCommand('HIDE');
  }

  static Future<void> requestExit() async {
    await _sendCommand('EXIT');
  }

  static Future<void> _sendCommand(String command) async {
    try {
      final socket = await Socket.connect(
        InternetAddress.loopbackIPv4,
        _port,
        timeout: const Duration(milliseconds: 500),
      );

      socket.write(command);
      await socket.flush();
      await socket.close();
      debugPrint('✅ IPC $command request sent');
    } catch (e) {
      debugPrint('⚠️ IPC $command request failed: $e');
    }
  }

  /// Cleanup server when app exits
  static Future<void> dispose() async {
    await _server?.close();
    _server = null;
    debugPrint('🛑 IPC Server closed');
  }
}
