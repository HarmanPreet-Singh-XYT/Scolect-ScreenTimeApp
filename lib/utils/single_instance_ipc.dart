import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart';
import 'macos_window.dart';

class SingleInstanceIPC {
  static const int _port = 45999;
  static ServerSocket? _server;
  static const String _ack = 'SCOLECT_OK';

  /// Asks an already-running instance to show itself. Returns true only if
  /// the listener on the port answered with our ack — a silent or foreign
  /// listener returns false so the caller keeps starting up.
  static Future<bool> notifyExistingInstance() async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        InternetAddress.loopbackIPv4,
        _port,
        timeout: const Duration(milliseconds: 500),
      );
      socket.write('SHOW');
      await socket.flush();
      // The server keeps the connection open, so read just the first chunk.
      final reply =
          await socket.first.timeout(const Duration(seconds: 1));
      return String.fromCharCodes(reply).contains(_ack);
    } catch (e) {
      return false;
    } finally {
      try {
        socket?.destroy();
      } catch (_) {}
    }
  }

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
          // Ack so a secondary instance can tell we're really Scolect and
          // not some unrelated program that happens to own this port.
          try {
            client.write(_ack);
            client.flush().catchError((_) {});
          } catch (_) {}
          _handleCommand(msg);
        }, onError: (_) {});
      }, onError: (_) {});
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
