// test/unit/models/window_info_test.dart
//
// Tests for the WindowInfo and AppLaunchInfo data classes.
// These are pure Dart classes with no platform dependencies, so they
// run on any host regardless of OS.

import 'package:flutter_test/flutter_test.dart';
import 'package:screentime/foreground_window_plugin_windows.dart';

void main() {
  group('WindowInfo', () {
    test('constructs with all required fields', () {
      const info = WindowInfo(
        windowTitle: 'Visual Studio Code',
        processName: r'C:\Users\user\AppData\Local\Programs\Microsoft VS Code\Code.exe',
        executableName: 'Code',
        programName: 'Visual Studio Code',
        processId: 1234,
        parentProcessId: 5678,
        parentProcessName: 'explorer.exe',
      );

      expect(info.windowTitle, 'Visual Studio Code');
      expect(info.processName,
          r'C:\Users\user\AppData\Local\Programs\Microsoft VS Code\Code.exe');
      expect(info.executableName, 'Code');
      expect(info.programName, 'Visual Studio Code');
      expect(info.processId, 1234);
      expect(info.parentProcessId, 5678);
      expect(info.parentProcessName, 'explorer.exe');
    });

    test('WindowInfo.unknown() returns safe fallback values', () {
      final info = WindowInfo.unknown();

      expect(info.windowTitle, isEmpty);
      expect(info.processName, 'Unknown');
      expect(info.executableName, 'Unknown');
      expect(info.programName, 'Unknown');
      expect(info.processId, 0);
      expect(info.parentProcessId, 0);
      expect(info.parentProcessName, 'Unknown');
    });

    test('toString() includes all key fields', () {
      const info = WindowInfo(
        windowTitle: 'Notepad',
        processName: r'C:\Windows\notepad.exe',
        executableName: 'Notepad',
        programName: 'Notepad',
        processId: 100,
        parentProcessId: 200,
        parentProcessName: 'explorer.exe',
      );

      final str = info.toString();
      expect(str, contains('Notepad'));
      expect(str, contains('100'));
      expect(str, contains('200'));
      expect(str, contains('explorer.exe'));
    });

    test('two WindowInfo objects with same data are value-equal via toString', () {
      const a = WindowInfo(
        windowTitle: 'App',
        processName: 'app.exe',
        executableName: 'App',
        programName: 'App',
        processId: 42,
        parentProcessId: 1,
        parentProcessName: 'System',
      );
      const b = WindowInfo(
        windowTitle: 'App',
        processName: 'app.exe',
        executableName: 'App',
        programName: 'App',
        processId: 42,
        parentProcessId: 1,
        parentProcessName: 'System',
      );

      expect(a.toString(), equals(b.toString()));
    });
  });

  group('AppLaunchInfo', () {
    test('constructs with all required fields', () {
      const info = AppLaunchInfo(
        processId: 999,
        parentProcessId: 1,
        parentProcessName: 'winlogon.exe',
        wasStartedWithSystem: true,
        isSystemLaunched: true,
        isRegisteredAutoStart: false,
        commandLineArgs: ['--auto-launched'],
        launchType: 'startup',
      );

      expect(info.processId, 999);
      expect(info.parentProcessId, 1);
      expect(info.parentProcessName, 'winlogon.exe');
      expect(info.wasStartedWithSystem, isTrue);
      expect(info.isSystemLaunched, isTrue);
      expect(info.isRegisteredAutoStart, isFalse);
      expect(info.commandLineArgs, ['--auto-launched']);
      expect(info.launchType, 'startup');
    });

    test('commandLineArgs can be empty', () {
      const info = AppLaunchInfo(
        processId: 1,
        parentProcessId: 0,
        parentProcessName: 'System',
        wasStartedWithSystem: false,
        isSystemLaunched: false,
        isRegisteredAutoStart: false,
        commandLineArgs: [],
        launchType: 'manual',
      );

      expect(info.commandLineArgs, isEmpty);
    });

    test('toString() includes key fields', () {
      const info = AppLaunchInfo(
        processId: 42,
        parentProcessId: 1,
        parentProcessName: 'explorer.exe',
        wasStartedWithSystem: false,
        isSystemLaunched: false,
        isRegisteredAutoStart: true,
        commandLineArgs: [],
        launchType: 'autostart',
      );

      final str = info.toString();
      expect(str, contains('42'));
      expect(str, contains('explorer.exe'));
      expect(str, contains('autostart'));
    });
  });
}
