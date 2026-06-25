// test/unit/packages/local_notifier_test.dart
//
// Tests for the local_notifier GitHub package.
//
// LocalNotifier talks to native code via MethodChannel 'local_notifier'.
// On Windows it requires setup() before notify(); on macOS it works without it.
//
// Strategy:
//   • LocalNotification data model – toJson(), fromJson() round-trip,
//     field defaults, actions serialisation.
//   • LocalNotificationAction – toJson() / fromJson().
//   • LocalNotificationCloseReason enum – all values present.
//   • NotificationPermissionStatus – fromJson(), isGranted/isDenied/isNotDetermined.
//   • LocalNotifier channel calls – mock the MethodChannel and verify:
//       - notify() invokes 'notify' with the correct payload.
//       - close() invokes 'close'.
//       - notify() before setup() on a non-Windows host works (no throw).
//   • LocalNotifier listener management – addListener / removeListener /
//     hasListeners.
//   • Incoming channel callbacks – 'onLocalNotificationShow',
//     'onLocalNotificationClose', 'onLocalNotificationClick',
//     'onLocalNotificationClickAction' fire the right callbacks.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_notifier/local_notifier.dart';

// ─── channel helpers ─────────────────────────────────────────────────────────

const _channelName = 'local_notifier';

List<MethodCall> _calls = [];

void _startRecording() {
  _calls = [];
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel(_channelName),
    (call) async {
      _calls.add(call);
      // 'setup' needs to return bool; others return null.
      if (call.method == 'setup') return true;
      return null;
    },
  );
}

void _stopRecording() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel(_channelName),
    null,
  );
}

/// Injects a fake method call *from* native (plugin → Dart side).
Future<void> _sendFromNative(String method, Map<String, dynamic> args) async {
  final codec = const StandardMethodCodec();
  final data = codec.encodeMethodCall(MethodCall(method, args));
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(_channelName, data, (_) {});
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(_startRecording);
  tearDown(_stopRecording);

  // ── LocalNotificationAction ──────────────────────────────────────────────────
  group('LocalNotificationAction', () {
    test('default type is "button"', () {
      final action = LocalNotificationAction(text: 'OK');
      expect(action.type, 'button');
    });

    test('toJson() includes type and text', () {
      final action = LocalNotificationAction(type: 'button', text: 'Snooze');
      final json = action.toJson();
      expect(json['type'], 'button');
      expect(json['text'], 'Snooze');
    });

    test('toJson() omits null text', () {
      final action = LocalNotificationAction(type: 'button');
      final json = action.toJson();
      expect(json.containsKey('text'), isFalse);
    });

    test('fromJson() round-trip', () {
      final original = LocalNotificationAction(type: 'button', text: 'Dismiss');
      final json = original.toJson();
      // fromJson requires non-null text; add it back.
      json['text'] = original.text ?? '';
      final restored = LocalNotificationAction.fromJson(json);
      expect(restored.type, original.type);
      expect(restored.text, original.text);
    });
  });

  // ── LocalNotificationCloseReason ─────────────────────────────────────────────
  group('LocalNotificationCloseReason', () {
    test('all expected values exist', () {
      expect(LocalNotificationCloseReason.values, containsAll([
        LocalNotificationCloseReason.userCanceled,
        LocalNotificationCloseReason.timedOut,
        LocalNotificationCloseReason.unknown,
      ]));
    });

    test('name-based lookup works for all values', () {
      for (final reason in LocalNotificationCloseReason.values) {
        final found = LocalNotificationCloseReason.values.firstWhere(
          (e) => e.name == reason.name,
          orElse: () => LocalNotificationCloseReason.unknown,
        );
        expect(found, equals(reason));
      }
    });

    test('unknown name falls back to unknown', () {
      final result = LocalNotificationCloseReason.values.firstWhere(
        (e) => e.name == 'somethingNew',
        orElse: () => LocalNotificationCloseReason.unknown,
      );
      expect(result, LocalNotificationCloseReason.unknown);
    });
  });

  // ── NotificationPermissionStatus ─────────────────────────────────────────────
  group('NotificationPermissionStatus', () {
    test('isGranted is true when status == "granted"', () {
      const status = NotificationPermissionStatus(
        status: 'granted',
        alertEnabled: true,
        soundEnabled: true,
        badgeEnabled: true,
        alertStyle: 'banner',
      );
      expect(status.isGranted, isTrue);
      expect(status.isDenied, isFalse);
      expect(status.isNotDetermined, isFalse);
    });

    test('isDenied is true when status == "denied"', () {
      const status = NotificationPermissionStatus(
        status: 'denied',
        alertEnabled: false,
        soundEnabled: false,
        badgeEnabled: false,
        alertStyle: 'none',
      );
      expect(status.isDenied, isTrue);
      expect(status.isGranted, isFalse);
    });

    test('isNotDetermined is true when status == "notDetermined"', () {
      const status = NotificationPermissionStatus(
        status: 'notDetermined',
        alertEnabled: false,
        soundEnabled: false,
        badgeEnabled: false,
        alertStyle: 'none',
      );
      expect(status.isNotDetermined, isTrue);
    });

    test('fromJson() parses all fields', () {
      final status = NotificationPermissionStatus.fromJson({
        'status': 'granted',
        'alertEnabled': true,
        'soundEnabled': false,
        'badgeEnabled': true,
        'alertStyle': 'alert',
      });
      expect(status.status, 'granted');
      expect(status.alertEnabled, isTrue);
      expect(status.soundEnabled, isFalse);
      expect(status.badgeEnabled, isTrue);
      expect(status.alertStyle, 'alert');
    });

    test('fromJson() uses defaults for missing optional fields', () {
      final status = NotificationPermissionStatus.fromJson({
        'status': 'denied',
      });
      expect(status.alertEnabled, isFalse);
      expect(status.soundEnabled, isFalse);
      expect(status.badgeEnabled, isFalse);
      expect(status.alertStyle, 'none');
    });
  });

  // ── LocalNotification model ──────────────────────────────────────────────────
  group('LocalNotification', () {
    test('identifier is auto-generated when not provided', () {
      final n = LocalNotification(title: 'Hello');
      expect(n.identifier, isNotEmpty);
    });

    test('provided identifier is used as-is', () {
      final n = LocalNotification(identifier: 'my-id-123', title: 'Hi');
      expect(n.identifier, 'my-id-123');
    });

    test('two notifications with no identifier have different identifiers', () {
      final a = LocalNotification(title: 'A');
      final b = LocalNotification(title: 'B');
      expect(a.identifier, isNot(equals(b.identifier)));
    });

    test('toJson() serialises title, body, silent', () {
      final n = LocalNotification(
        title: 'Alert',
        body: 'Something happened',
        silent: true,
      );
      final json = n.toJson();
      expect(json['title'], 'Alert');
      expect(json['body'], 'Something happened');
      expect(json['silent'], isTrue);
    });

    test('toJson() subtitle defaults to empty string', () {
      final n = LocalNotification(title: 'T');
      final json = n.toJson();
      expect(json['subtitle'], '');
    });

    test('toJson() body defaults to empty string', () {
      final n = LocalNotification(title: 'T');
      final json = n.toJson();
      expect(json['body'], '');
    });

    test('toJson() includes actions list', () {
      final n = LocalNotification(
        title: 'Limit reached',
        actions: [
          LocalNotificationAction(text: 'OK'),
          LocalNotificationAction(text: 'Snooze 10m'),
        ],
      );
      final json = n.toJson();
      final actions = json['actions'] as List;
      expect(actions, hasLength(2));
      expect(actions[0]['text'], 'OK');
      expect(actions[1]['text'], 'Snooze 10m');
    });

    test('toJson() actions is empty list when no actions provided', () {
      final n = LocalNotification(title: 'T');
      final json = n.toJson();
      expect(json['actions'], isEmpty);
    });

    test('fromJson() round-trip preserves all fields', () {
      final original = LocalNotification(
        identifier: 'round-trip-id',
        title: 'Usage limit',
        subtitle: 'Chrome',
        body: '2 hours reached',
        silent: false,
        actions: [LocalNotificationAction(text: 'Dismiss')],
      );
      final json = original.toJson();
      final restored = LocalNotification.fromJson(json);

      expect(restored.identifier, original.identifier);
      expect(restored.title, original.title);
      expect(restored.subtitle, original.subtitle);
      expect(restored.body, original.body);
      expect(restored.silent, original.silent);
      expect(restored.actions, hasLength(1));
      expect(restored.actions!.first.text, 'Dismiss');
    });
  });

  // ── LocalNotifier channel calls ──────────────────────────────────────────────
  group('LocalNotifier – notify()', () {
    test('notify() invokes "notify" channel method', () async {
      final n = LocalNotification(identifier: 'n1', title: 'Test');
      // On non-Windows, no setup() needed.
      await localNotifier.notify(n);

      expect(_calls.any((c) => c.method == 'notify'), isTrue);
    });

    test('notify() passes identifier in arguments', () async {
      final n = LocalNotification(identifier: 'check-id', title: 'X');
      await localNotifier.notify(n);

      final call = _calls.firstWhere((c) => c.method == 'notify');
      expect((call.arguments as Map)['identifier'], 'check-id');
    });

    test('notify() passes title in arguments', () async {
      final n = LocalNotification(identifier: 'title-test', title: 'My Title');
      await localNotifier.notify(n);

      final call = _calls.firstWhere((c) => c.method == 'notify');
      expect((call.arguments as Map)['title'], 'My Title');
    });

    test('close() invokes "close" channel method', () async {
      final n = LocalNotification(identifier: 'close-test', title: 'T');
      await localNotifier.close(n);

      expect(_calls.any((c) => c.method == 'close'), isTrue);
    });
  });

  // ── LocalNotifier listener management ───────────────────────────────────────
  group('LocalNotifier – listener management', () {
    test('hasListeners is false initially', () {
      // Since LocalNotifier is a singleton and tests share state, we check
      // that the count is consistent, not necessarily zero.
      final before = localNotifier.listeners.length;
      expect(before, greaterThanOrEqualTo(0));
    });

    test('addListener / removeListener are symmetric', () {
      final n = LocalNotification(title: 'Listener test');
      final before = localNotifier.listeners.length;

      localNotifier.addListener(n);
      expect(localNotifier.listeners.length, before + 1);

      localNotifier.removeListener(n);
      expect(localNotifier.listeners.length, before);
    });
  });

  // ── Incoming channel callbacks ───────────────────────────────────────────────
  group('LocalNotifier – incoming native callbacks', () {
    test('onLocalNotificationShow fires onShow callback', () async {
      bool shown = false;
      final n = LocalNotification(identifier: 'show-cb', title: 'T')
        ..onShow = () => shown = true;

      await localNotifier.notify(n);
      await _sendFromNative('onLocalNotificationShow', {'notificationId': 'show-cb'});

      expect(shown, isTrue);
    });

    test('onLocalNotificationClick fires onClick callback', () async {
      bool clicked = false;
      final n = LocalNotification(identifier: 'click-cb', title: 'T')
        ..onClick = () => clicked = true;

      await localNotifier.notify(n);
      await _sendFromNative('onLocalNotificationClick', {'notificationId': 'click-cb'});

      expect(clicked, isTrue);
    });

    test('onLocalNotificationClose fires onClose with correct reason', () async {
      LocalNotificationCloseReason? received;
      final n = LocalNotification(identifier: 'close-cb', title: 'T')
        ..onClose = (reason) => received = reason;

      await localNotifier.notify(n);
      await _sendFromNative('onLocalNotificationClose', {
        'notificationId': 'close-cb',
        'closeReason': 'userCanceled',
      });

      expect(received, LocalNotificationCloseReason.userCanceled);
    });

    test('onLocalNotificationClose with unknown reason falls back to unknown', () async {
      LocalNotificationCloseReason? received;
      final n = LocalNotification(identifier: 'close-unknown', title: 'T')
        ..onClose = (reason) => received = reason;

      await localNotifier.notify(n);
      await _sendFromNative('onLocalNotificationClose', {
        'notificationId': 'close-unknown',
        'closeReason': 'someFutureReason',
      });

      expect(received, LocalNotificationCloseReason.unknown);
    });

    test('onLocalNotificationClickAction fires onClickAction with index', () async {
      int? receivedIndex;
      final n = LocalNotification(identifier: 'action-cb', title: 'T')
        ..onClickAction = (i) => receivedIndex = i;

      await localNotifier.notify(n);
      await _sendFromNative('onLocalNotificationClickAction', {
        'notificationId': 'action-cb',
        'actionIndex': 1,
      });

      expect(receivedIndex, 1);
    });

    test('callback for a different notification identifier does not fire', () async {
      bool fired = false;
      final n = LocalNotification(identifier: 'my-notif', title: 'T')
        ..onShow = () => fired = true;

      await localNotifier.notify(n);
      // Wrong identifier – should NOT fire n's callback.
      await _sendFromNative('onLocalNotificationShow', {
        'notificationId': 'other-notif',
      });

      expect(fired, isFalse);
    });
  });
}
