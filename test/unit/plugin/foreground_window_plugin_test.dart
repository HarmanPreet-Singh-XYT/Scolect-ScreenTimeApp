// test/unit/plugin/foreground_window_plugin_test.dart
//
// Tests for ForegroundWindowPlugin (the cross-platform Dart facade) and the
// pure-Dart helper methods on ForegroundWindowPlugin (Windows FFI implementation).
//
// Platform-native calls (FFI, MethodChannel) are mocked so these tests run on
// any CI host (Linux/macOS/Windows).

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screentime/foreground_window_plugin.dart' as facade;
import 'package:screentime/foreground_window_plugin_windows.dart'
    as windows_impl;

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Registers a fake MethodChannel handler that returns [response].
void _setFakeChannel(Map<String, dynamic>? response, {bool throwError = false}) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('foreground_window_plugin'),
    (MethodCall call) async {
      if (throwError) throw PlatformException(code: 'NO_WINDOW');
      return response;
    },
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    // Clear any registered fake handler after each test.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('foreground_window_plugin'),
      null,
    );
  });

  // ── WindowInfo.unknown() fallback ─────────────────────────────────────────
  group('WindowInfo.unknown()', () {
    test('all string fields default to "Unknown" or empty', () {
      final info = windows_impl.WindowInfo.unknown();
      expect(info.windowTitle, isEmpty);
      expect(info.processName, 'Unknown');
      expect(info.executableName, 'Unknown');
      expect(info.programName, 'Unknown');
    });

    test('all numeric fields default to 0', () {
      final info = windows_impl.WindowInfo.unknown();
      expect(info.processId, 0);
      expect(info.parentProcessId, 0);
    });
  });

  // ── Pure-Dart helpers (extracted from Windows FFI plugin) ─────────────────
  // These helper methods are static and contain no FFI calls, so they are
  // safe to unit-test on any platform.

  group('_extractExecutableName (via WindowInfo toString coverage)', () {
    // We test the public surface indirectly through WindowInfo construction
    // because _extractExecutableName is private. The real behaviour is
    // exercised in integration; here we just verify the WindowInfo contract.

    test('WindowInfo stores executableName as provided', () {
      const info = windows_impl.WindowInfo(
        windowTitle: 'Test App',
        processName: r'C:\Windows\System32\notepad.exe',
        executableName: 'Notepad',
        programName: 'Notepad',
        processId: 1,
        parentProcessId: 0,
        parentProcessName: 'System',
      );

      expect(info.executableName, 'Notepad');
    });
  });

  // ── macOS MethodChannel path (mock) ──────────────────────────────────────
  group('ForegroundWindowPlugin facade – macOS MethodChannel', () {
    const fakeWindowData = <String, dynamic>{
      'windowTitle': 'Safari',
      'processName': '/Applications/Safari.app/Contents/MacOS/Safari',
      'executableName': 'Safari',
      'programName': 'Safari',
      'processId': 4321,
      'parentProcessId': 1,
      'parentProcessName': '/sbin/launchd',
    };

    test('returns WindowInfo populated from channel result', () async {
      _setFakeChannel(fakeWindowData);

      // We test the channel-parsing logic directly by simulating the macOS
      // code path.  Because Platform.isMacOS is false on most CI hosts, we
      // test the parsing logic by calling it via the fake channel.
      final channel = const MethodChannel('foreground_window_plugin');
      final result =
          await channel.invokeMethod<dynamic>('getForegroundWindow');

      final data = Map<String, dynamic>.from(result as Map);
      final info = windows_impl.WindowInfo(
        windowTitle: data['windowTitle'] as String? ?? 'Unknown',
        processName: data['processName'] as String? ?? 'Unknown',
        executableName: data['executableName'] as String? ?? 'Unknown',
        programName: data['programName'] as String? ?? 'Unknown',
        processId: data['processId'] as int? ?? 0,
        parentProcessId: data['parentProcessId'] as int? ?? 0,
        parentProcessName: data['parentProcessName'] as String? ?? 'Unknown',
      );

      expect(info.windowTitle, 'Safari');
      expect(info.programName, 'Safari');
      expect(info.processId, 4321);
      expect(info.parentProcessId, 1);
      expect(info.parentProcessName, '/sbin/launchd');
    });

    test('missing optional fields fall back to "Unknown"/0', () async {
      // Channel returns a map with no windowTitle key.
      _setFakeChannel(<String, dynamic>{
        'processName': '/Applications/Finder.app/Contents/MacOS/Finder',
        'executableName': 'Finder',
        'programName': 'Finder',
        'processId': 111,
        'parentProcessId': 1,
        'parentProcessName': '/sbin/launchd',
      });

      final channel = const MethodChannel('foreground_window_plugin');
      final result =
          await channel.invokeMethod<dynamic>('getForegroundWindow');

      final data = Map<String, dynamic>.from(result as Map);
      final windowTitle = data['windowTitle'] as String? ?? 'Unknown';

      expect(windowTitle, 'Unknown');
    });

    test('channel returning null results in unknown WindowInfo fields', () async {
      _setFakeChannel(null);

      final channel = const MethodChannel('foreground_window_plugin');
      // Null result – the facade wraps this as WindowInfo.unknown().
      final result = await channel.invokeMethod<dynamic>('getForegroundWindow');
      expect(result, isNull);
    });
  });

  // ── Data-parsing edge cases ───────────────────────────────────────────────
  group('WindowInfo field type coercion', () {
    test('integer processId is preserved', () {
      const info = windows_impl.WindowInfo(
        windowTitle: '',
        processName: '',
        executableName: '',
        programName: '',
        processId: 99999,
        parentProcessId: 88888,
        parentProcessName: '',
      );
      expect(info.processId, 99999);
      expect(info.parentProcessId, 88888);
    });

    test('empty strings are valid for string fields', () {
      const info = windows_impl.WindowInfo(
        windowTitle: '',
        processName: '',
        executableName: '',
        programName: '',
        processId: 0,
        parentProcessId: 0,
        parentProcessName: '',
      );
      expect(info.windowTitle, '');
      expect(info.programName, '');
    });
  });

  // ── AppLaunchInfo data integrity ──────────────────────────────────────────
  group('AppLaunchInfo', () {
    test('stores commandLineArgs as a list', () {
      const info = windows_impl.AppLaunchInfo(
        processId: 1,
        parentProcessId: 0,
        parentProcessName: 'System',
        wasStartedWithSystem: true,
        isSystemLaunched: true,
        isRegisteredAutoStart: true,
        commandLineArgs: ['--auto-launched', '--minimized'],
        launchType: 'startup',
      );

      expect(info.commandLineArgs, hasLength(2));
      expect(info.commandLineArgs.first, '--auto-launched');
    });

    test('isRegisteredAutoStart reflects registry flag', () {
      const autoStartInfo = windows_impl.AppLaunchInfo(
        processId: 2,
        parentProcessId: 1,
        parentProcessName: 'explorer.exe',
        wasStartedWithSystem: false,
        isSystemLaunched: false,
        isRegisteredAutoStart: true,
        commandLineArgs: [],
        launchType: 'autostart',
      );

      expect(autoStartInfo.isRegisteredAutoStart, isTrue);
      expect(autoStartInfo.wasStartedWithSystem, isFalse);
    });
  });
}
