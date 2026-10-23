// test/unit/utils/manual_log_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:screentime/utils/manual_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DateTime clock;
  late ManualLog log;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    clock = DateTime(2026, 3, 18, 10, 0, 0);
    log = ManualLog(now: () => clock);
  });

  group('stopwatch', () {
    test('start then stop records the elapsed time', () async {
      expect(await log.start('  Writing   report '), isTrue);
      expect(log.running!.label, 'Writing report');

      clock = clock.add(const Duration(minutes: 25, seconds: 10));
      expect(log.runningElapsed, const Duration(minutes: 25, seconds: 10));

      final entry = await log.stop();
      expect(entry!.label, 'Writing report');
      expect(entry.seconds, 25 * 60 + 10);
      expect(entry.start, DateTime(2026, 3, 18, 10));
      expect(log.running, isNull);
      expect(log.entries.single.id, entry.id);
    });

    test('cannot start twice or with an empty label', () async {
      expect(await log.start('   '), isFalse);
      expect(await log.start('A'), isTrue);
      expect(await log.start('B'), isFalse);
      expect(log.running!.label, 'A');
    });

    test('a stop within the first second still records one second', () async {
      await log.start('Quick');
      expect((await log.stop())!.seconds, 1);
    });

    test('a stopwatch left running is capped at 24 hours', () async {
      await log.start('Forgot');
      clock = clock.add(const Duration(days: 3));
      expect((await log.stop())!.seconds, 24 * 3600);
    });

    test('stop with nothing running does nothing', () async {
      expect(await log.stop(), isNull);
      expect(log.entries, isEmpty);
    });

    test('discard throws the time away', () async {
      await log.start('Oops');
      await log.discardRunning();
      expect(log.running, isNull);
      expect(log.entries, isEmpty);
    });

    test('a running stopwatch survives a reload', () async {
      await log.start('Long task');
      clock = clock.add(const Duration(hours: 2));

      final reloaded = ManualLog(now: () => clock);
      await reloaded.load();
      expect(reloaded.running!.label, 'Long task');
      expect(reloaded.runningElapsed, const Duration(hours: 2));
    });
  });

  group('entries', () {
    test('add validates label and duration and caps long entries', () async {
      expect(await log.add(label: '', start: clock, duration: const Duration(hours: 1)), isNull);
      expect(await log.add(label: 'x', start: clock, duration: Duration.zero), isNull);
      final long = await log.add(label: 'x', start: clock, duration: const Duration(days: 2));
      expect(long!.seconds, 24 * 3600);
    });

    test('labels are trimmed, collapsed and clipped', () {
      expect(ManualLog.cleanLabel('  a   b\tc '), 'a b c');
      expect(ManualLog.cleanLabel('x' * 100).length, ManualLog.maxLabelLength);
    });

    test('entries are newest first and survive a reload', () async {
      await log.add(label: 'Old', start: DateTime(2026, 3, 1, 9), duration: const Duration(minutes: 30));
      await log.add(label: 'New', start: DateTime(2026, 3, 17, 9), duration: const Duration(minutes: 45));
      expect(log.entries.map((e) => e.label), ['New', 'Old']);

      final reloaded = ManualLog(now: () => clock);
      await reloaded.load();
      expect(reloaded.entries.map((e) => e.label), ['New', 'Old']);
      expect(reloaded.entries.first.seconds, 45 * 60);
    });

    test('delete removes just that entry', () async {
      final a = await log.add(label: 'A', start: clock, duration: const Duration(minutes: 5));
      await log.add(label: 'B', start: clock, duration: const Duration(minutes: 5));
      await log.delete(a!.id);
      expect(log.entries.map((e) => e.label), ['B']);
      await log.delete('missing'); // no throw
    });

    test('forDay and totalsByLabel group by start day', () async {
      await log.add(label: 'Meet', start: DateTime(2026, 3, 18, 9), duration: const Duration(hours: 1));
      await log.add(label: 'Meet', start: DateTime(2026, 3, 17, 15), duration: const Duration(minutes: 30));
      await log.add(label: 'Read', start: DateTime(2026, 3, 18, 20), duration: const Duration(minutes: 20));
      await log.add(label: 'Meet', start: DateTime(2026, 3, 1, 9), duration: const Duration(hours: 5));

      expect(log.forDay(DateTime(2026, 3, 18)).map((e) => e.label), ['Read', 'Meet']);
      final week = log.totalsByLabel(DateTime(2026, 3, 12), DateTime(2026, 3, 18));
      expect(week, {'Meet': 5400, 'Read': 1200});
    });

    test('history is capped', () async {
      for (var i = 0; i < ManualLog.maxEntries + 5; i++) {
        await log.add(
            label: 'e', start: DateTime(2026, 1, 1).add(Duration(minutes: i)),
            duration: const Duration(minutes: 1));
      }
      expect(log.entries.length, ManualLog.maxEntries);
      // The oldest were dropped.
      expect(log.entries.last.start, DateTime(2026, 1, 1).add(const Duration(minutes: 5)));
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('corrupt stored data is ignored', () async {
      SharedPreferences.setMockInitialValues({'manual_log_v1': 'not json'});
      final l = ManualLog(now: () => clock);
      await l.load();
      expect(l.entries, isEmpty);

      SharedPreferences.setMockInitialValues({
        'manual_log_v1': '{"entries":[{"id":1},{"id":"a","label":"ok","start":0,"seconds":5}]}'
      });
      await l.load();
      expect(l.entries.single.label, 'ok');
    });
  });
}
