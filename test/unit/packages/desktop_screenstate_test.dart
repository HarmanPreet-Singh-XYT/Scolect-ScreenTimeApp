// test/unit/packages/desktop_screenstate_test.dart
//
// Tests for the desktop_screenstate GitHub package (Rust branch).
//
// DesktopScreenState on Windows uses FFI into a Rust DLL, and on macOS uses
// MethodChannel 'screenstate'. Both are unavailable in unit-test environments.
//
// Strategy:
//   • ScreenState enum – verify all values exist and name-based lookup works
//     (used by _onWindowsEvent and _handleMethodCall to parse event strings).
//   • macOS MethodChannel path – inject fake 'onScreenStateChange' calls
//     through the binary messenger and verify state.value updates correctly.
//   • Singleton – instance getter always returns the same object.
//   • ValueListenable – verify isActive stream reports state changes.

import 'package:desktop_screenstate/desktop_screenstate.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _channelName = 'screenstate';

/// Sends a fake method call *from* native *into* Dart (simulating macOS plugin).
Future<void> _sendScreenStateEvent(String stateName) async {
  final codec = const StandardMethodCodec();
  final data = codec.encodeMethodCall(
    MethodCall('onScreenStateChange', stateName),
  );
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(_channelName, data, (_) {});
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── ScreenState enum ─────────────────────────────────────────────────────────
  group('ScreenState enum', () {
    test('all expected values exist', () {
      expect(ScreenState.values, containsAll([
        ScreenState.sleep,
        ScreenState.awaked,
        ScreenState.locked,
        ScreenState.unlocked,
        ScreenState.screenOff,
        ScreenState.screenOn,
      ]));
    });

    test('name-based lookup finds the right value', () {
      for (final state in ScreenState.values) {
        final found = ScreenState.values.firstWhere(
          (e) => e.name == state.name,
          orElse: () => ScreenState.awaked,
        );
        expect(found, equals(state));
      }
    });

    test('unknown name falls back to awaked (orElse contract)', () {
      final result = ScreenState.values.firstWhere(
        (e) => e.name == 'nonExistentEvent',
        orElse: () => ScreenState.awaked,
      );
      expect(result, ScreenState.awaked);
    });

    test('event names match Dart identifiers used in native code', () {
      // The Rust DLL and Swift plugin emit these exact strings.
      const expectedNames = {
        'sleep', 'awaked', 'locked', 'unlocked', 'screenOff', 'screenOn',
      };
      final actualNames = ScreenState.values.map((e) => e.name).toSet();
      expect(actualNames, equals(expectedNames));
    });
  });

  // ── macOS MethodChannel path ─────────────────────────────────────────────────
  group('DesktopScreenState – MethodChannel event parsing (macOS path)', () {
    test('onScreenStateChange "locked" updates state to locked', () async {
      // Access the singleton; on macOS test host it sets up the channel handler.
      final screenState = DesktopScreenState.instance;

      await _sendScreenStateEvent('locked');
      await Future.microtask(() {});

      expect(screenState.state, ScreenState.locked);
    });

    test('onScreenStateChange "unlocked" updates state to unlocked', () async {
      final screenState = DesktopScreenState.instance;

      await _sendScreenStateEvent('unlocked');
      await Future.microtask(() {});

      expect(screenState.state, ScreenState.unlocked);
    });

    test('onScreenStateChange "sleep" updates state to sleep', () async {
      final screenState = DesktopScreenState.instance;

      await _sendScreenStateEvent('sleep');
      await Future.microtask(() {});

      expect(screenState.state, ScreenState.sleep);
    });

    test('onScreenStateChange "awaked" updates state to awaked', () async {
      final screenState = DesktopScreenState.instance;

      await _sendScreenStateEvent('awaked');
      await Future.microtask(() {});

      expect(screenState.state, ScreenState.awaked);
    });

    test('onScreenStateChange "screenOff" updates state to screenOff', () async {
      final screenState = DesktopScreenState.instance;

      await _sendScreenStateEvent('screenOff');
      await Future.microtask(() {});

      expect(screenState.state, ScreenState.screenOff);
    });

    test('onScreenStateChange "screenOn" updates state to screenOn', () async {
      final screenState = DesktopScreenState.instance;

      await _sendScreenStateEvent('screenOn');
      await Future.microtask(() {});

      expect(screenState.state, ScreenState.screenOn);
    });

    test('unknown event name falls back to awaked without throwing', () async {
      final screenState = DesktopScreenState.instance;

      // Put it into a known state first.
      await _sendScreenStateEvent('locked');
      await Future.microtask(() {});

      // Then fire an unknown event – should not throw and falls back to awaked.
      await _sendScreenStateEvent('someFutureEvent');
      await Future.microtask(() {});

      expect(screenState.state, ScreenState.awaked);
    });
  });

  // ── Singleton ────────────────────────────────────────────────────────────────
  group('DesktopScreenState singleton', () {
    test('instance getter always returns the same object', () {
      final a = DesktopScreenState.instance;
      final b = DesktopScreenState.instance;
      expect(identical(a, b), isTrue);
    });
  });

  // ── ValueListenable ──────────────────────────────────────────────────────────
  group('DesktopScreenState ValueListenable', () {
    test('isActive notifier reports current state after event', () async {
      final screenState = DesktopScreenState.instance;

      await _sendScreenStateEvent('locked');
      await Future.microtask(() {});

      expect(screenState.isActive.value, ScreenState.locked);
    });

    test('state getter and isActive.value are in sync', () async {
      final screenState = DesktopScreenState.instance;

      await _sendScreenStateEvent('unlocked');
      await Future.microtask(() {});

      expect(screenState.state, equals(screenState.isActive.value));
    });

    test('ValueListenable listener fires on state change', () async {
      final screenState = DesktopScreenState.instance;
      ScreenState? captured;

      void listener() {
        captured = screenState.isActive.value;
      }

      screenState.isActive.addListener(listener);

      await _sendScreenStateEvent('sleep');
      await Future.microtask(() {});

      screenState.isActive.removeListener(listener);
      expect(captured, ScreenState.sleep);
    });
  });
}
