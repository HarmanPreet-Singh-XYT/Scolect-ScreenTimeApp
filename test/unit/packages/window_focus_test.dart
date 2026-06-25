// test/unit/packages/window_focus_test.dart
//
// Tests for the window_focus GitHub package (expert.kotelnikoff/window_focus).
//
// Strategy:
//   WindowFocus talks to native code via MethodChannel
//   'expert.kotelnikoff/window_focus'. We register fake handlers to simulate
//   what the native Rust/Swift side sends back, then verify:
//     • AppWindowDto data model behaviour (equality, hashCode, toString)
//     • PermissionStatus logic (allGranted, toString)
//     • WindowFocusError model (type, message, timestamp)
//     • WindowFocus Dart-side parsing: _handleFocusChange, _handleUserActiveChange,
//       _handleUserActive, _handleUserInactivity – all exercised by injecting
//       fake MethodCalls through the binary messenger.
//     • Stream events land on onFocusChanged / onUserActiveChanged / onError.
//     • dispose() closes all streams without throwing.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_focus/window_focus.dart';

// ─── channel helpers ─────────────────────────────────────────────────────────

const _channelName = 'expert.kotelnikoff/window_focus';

/// Injects a fake MethodCall *from* native *into* Dart (server → client).
Future<void> _sendFromNative(String method, [dynamic arguments]) async {
  final codec = const StandardMethodCodec();
  final data = codec.encodeMethodCall(MethodCall(method, arguments));
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(_channelName, data, (_) {});
}

/// Registers a fake channel handler that replies to *Dart → native* calls.
void _setNativeReply(Future<dynamic> Function(MethodCall) handler) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel(_channelName),
    handler,
  );
}

void _clearNativeReply() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel(_channelName),
    null,
  );
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Silence the channel during plugin construction (setIdleThreshold etc.)
  setUp(() {
    _setNativeReply((_) async => null);
  });

  tearDown(() {
    _clearNativeReply();
  });

  // ── AppWindowDto ────────────────────────────────────────────────────────────
  group('AppWindowDto', () {
    test('stores appName and windowTitle', () {
      final dto = AppWindowDto(appName: 'chrome.exe', windowTitle: 'Google - Chrome');
      expect(dto.appName, 'chrome.exe');
      expect(dto.windowTitle, 'Google - Chrome');
    });

    test('toString contains both fields', () {
      final dto = AppWindowDto(appName: 'code.exe', windowTitle: 'main.dart - VSCode');
      expect(dto.toString(), contains('main.dart - VSCode'));
      expect(dto.toString(), contains('code.exe'));
    });

    test('equality: same fields → equal', () {
      final a = AppWindowDto(appName: 'notepad.exe', windowTitle: 'Untitled');
      final b = AppWindowDto(appName: 'notepad.exe', windowTitle: 'Untitled');
      expect(a, equals(b));
    });

    test('equality: different appName → not equal', () {
      final a = AppWindowDto(appName: 'notepad.exe', windowTitle: 'File');
      final b = AppWindowDto(appName: 'wordpad.exe', windowTitle: 'File');
      expect(a, isNot(equals(b)));
    });

    test('equality: different windowTitle → not equal', () {
      final a = AppWindowDto(appName: 'app.exe', windowTitle: 'Title A');
      final b = AppWindowDto(appName: 'app.exe', windowTitle: 'Title B');
      expect(a, isNot(equals(b)));
    });

    test('hashCode is consistent for equal objects', () {
      final a = AppWindowDto(appName: 'slack.exe', windowTitle: '#general');
      final b = AppWindowDto(appName: 'slack.exe', windowTitle: '#general');
      expect(a.hashCode, equals(b.hashCode));
    });

    test('hashCode differs for different objects', () {
      final a = AppWindowDto(appName: 'a.exe', windowTitle: 'A');
      final b = AppWindowDto(appName: 'b.exe', windowTitle: 'B');
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });

    test('empty strings are valid', () {
      final dto = AppWindowDto(appName: '', windowTitle: '');
      expect(dto.appName, isEmpty);
      expect(dto.windowTitle, isEmpty);
    });
  });

  // ── PermissionStatus ────────────────────────────────────────────────────────
  group('PermissionStatus', () {
    test('allGranted is true only when both permissions are true', () {
      expect(
        PermissionStatus(screenRecording: true, inputMonitoring: true).allGranted,
        isTrue,
      );
      expect(
        PermissionStatus(screenRecording: true, inputMonitoring: false).allGranted,
        isFalse,
      );
      expect(
        PermissionStatus(screenRecording: false, inputMonitoring: true).allGranted,
        isFalse,
      );
      expect(
        PermissionStatus(screenRecording: false, inputMonitoring: false).allGranted,
        isFalse,
      );
    });

    test('toString includes both field values', () {
      final status = PermissionStatus(screenRecording: true, inputMonitoring: false);
      final str = status.toString();
      expect(str, contains('screenRecording: true'));
      expect(str, contains('inputMonitoring: false'));
    });
  });

  // ── WindowFocusError ────────────────────────────────────────────────────────
  group('WindowFocusError', () {
    test('stores type and message', () {
      final error = WindowFocusError(
        type: WindowFocusErrorType.initialization,
        message: 'Plugin failed to start',
      );
      expect(error.type, WindowFocusErrorType.initialization);
      expect(error.message, 'Plugin failed to start');
    });

    test('timestamp is set at construction time', () {
      final before = DateTime.now();
      final error = WindowFocusError(
        type: WindowFocusErrorType.unknown,
        message: 'oops',
      );
      final after = DateTime.now();
      expect(error.timestamp.isAfter(before) || error.timestamp == before, isTrue);
      expect(error.timestamp.isBefore(after) || error.timestamp == after, isTrue);
    });

    test('toString includes type and message', () {
      final error = WindowFocusError(
        type: WindowFocusErrorType.focusChange,
        message: 'bad args',
      );
      final str = error.toString();
      expect(str, contains('focusChange'));
      expect(str, contains('bad args'));
    });

    test('originalError is null by default', () {
      final error = WindowFocusError(
        type: WindowFocusErrorType.unknown,
        message: 'x',
      );
      expect(error.originalError, isNull);
    });

    test('originalError and stackTrace are stored when provided', () {
      final original = Exception('root cause');
      final st = StackTrace.current;
      final error = WindowFocusError(
        type: WindowFocusErrorType.methodCall,
        message: 'wrapped',
        originalError: original,
        stackTrace: st,
      );
      expect(error.originalError, same(original));
      expect(error.stackTrace, same(st));
    });
  });

  // ── WindowFocusErrorType coverage ──────────────────────────────────────────
  group('WindowFocusErrorType enum', () {
    test('all expected values exist', () {
      final values = WindowFocusErrorType.values;
      expect(values, contains(WindowFocusErrorType.initialization));
      expect(values, contains(WindowFocusErrorType.methodCall));
      expect(values, contains(WindowFocusErrorType.focusChange));
      expect(values, contains(WindowFocusErrorType.activityChange));
      expect(values, contains(WindowFocusErrorType.screenshot));
      expect(values, contains(WindowFocusErrorType.permission));
      expect(values, contains(WindowFocusErrorType.settings));
      expect(values, contains(WindowFocusErrorType.configuration));
      expect(values, contains(WindowFocusErrorType.unknown));
    });
  });

  // ── WindowFocus stream events (Dart-side logic) ─────────────────────────────
  group('WindowFocus event handling', () {
    late WindowFocus plugin;

    setUp(() async {
      plugin = WindowFocus();
      // Give the async _initializePlugin a tick to complete.
      await Future.microtask(() {});
    });

    tearDown(() {
      plugin.dispose();
    });

    test('onFocusChange native call emits AppWindowDto on onFocusChanged stream', () async {
      final future = plugin.onFocusChanged.first;

      await _sendFromNative('onFocusChange', {
        'appName': 'explorer.exe',
        'windowTitle': 'This PC',
      });

      final dto = await future;
      expect(dto.appName, 'explorer.exe');
      expect(dto.windowTitle, 'This PC');
    });

    test('onFocusChange with empty strings emits empty-field AppWindowDto', () async {
      final future = plugin.onFocusChanged.first;

      await _sendFromNative('onFocusChange', {
        'appName': '',
        'windowTitle': '',
      });

      final dto = await future;
      expect(dto.appName, isEmpty);
      expect(dto.windowTitle, isEmpty);
    });

    test('onFocusChange with missing keys falls back to empty strings', () async {
      final future = plugin.onFocusChanged.first;

      // Omit both keys – the Dart handler defaults to '' via ?? ''.
      await _sendFromNative('onFocusChange', <String, dynamic>{});

      final dto = await future;
      expect(dto.appName, isEmpty);
      expect(dto.windowTitle, isEmpty);
    });

    test('onUserActiveChange true emits true on onUserActiveChanged', () async {
      final future = plugin.onUserActiveChanged.first;

      await _sendFromNative('onUserActiveChange', true);

      expect(await future, isTrue);
      expect(plugin.isUserActive, isTrue);
    });

    test('onUserActiveChange false emits false on onUserActiveChanged', () async {
      final future = plugin.onUserActiveChanged.first;

      await _sendFromNative('onUserActiveChange', false);

      expect(await future, isFalse);
      expect(plugin.isUserActive, isFalse);
    });

    test('onUserActive event marks user as active', () async {
      // First force inactive state.
      await _sendFromNative('onUserActiveChange', false);
      await Future.microtask(() {});

      final future = plugin.onUserActiveChanged.first;
      await _sendFromNative('onUserActive', null);

      expect(await future, isTrue);
      expect(plugin.isUserActive, isTrue);
    });

    test('onUserInactivity event marks user as inactive', () async {
      final future = plugin.onUserActiveChanged.first;
      await _sendFromNative('onUserInactivity', null);

      expect(await future, isFalse);
      expect(plugin.isUserActive, isFalse);
    });

    test('multiple consecutive focus changes emit in order', () async {
      final events = <AppWindowDto>[];
      final sub = plugin.onFocusChanged.listen(events.add);

      await _sendFromNative('onFocusChange', {'appName': 'a.exe', 'windowTitle': 'A'});
      await _sendFromNative('onFocusChange', {'appName': 'b.exe', 'windowTitle': 'B'});
      await _sendFromNative('onFocusChange', {'appName': 'c.exe', 'windowTitle': 'C'});
      await Future.microtask(() {});

      await sub.cancel();
      expect(events.map((e) => e.appName).toList(), ['a.exe', 'b.exe', 'c.exe']);
    });
  });

  // ── WindowFocus dispose ─────────────────────────────────────────────────────
  group('WindowFocus dispose', () {
    test('dispose() closes streams without throwing', () {
      final plugin = WindowFocus();
      expect(() => plugin.dispose(), returnsNormally);
    });

    test('calling dispose() twice does not throw', () {
      final plugin = WindowFocus();
      plugin.dispose();
      expect(() => plugin.dispose(), returnsNormally);
    });
  });

  // ── WindowFocus initial state ───────────────────────────────────────────────
  group('WindowFocus initial state', () {
    test('isUserActive defaults to true', () {
      final plugin = WindowFocus();
      expect(plugin.isUserActive, isTrue);
      plugin.dispose();
    });
  });
}
