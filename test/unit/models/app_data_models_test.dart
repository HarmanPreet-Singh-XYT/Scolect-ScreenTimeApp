// test/unit/models/app_data_models_test.dart
//
// Tests for AppUsageRecord, TimeRange, and FocusSessionRecord data models.
// Pure Dart – no platform or Hive dependency needed at test time.

import 'package:flutter_test/flutter_test.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';

void main() {
  final jan1 = DateTime(2026, 1, 1);
  final jan2 = DateTime(2026, 1, 2);

  // ──────────────────────────────────────────────────────────────────────────
  group('TimeRange', () {
    test('duration is difference between end and start', () {
      final range = TimeRange(
        startTime: DateTime(2026, 1, 1, 9, 0),
        endTime: DateTime(2026, 1, 1, 9, 30),
      );

      expect(range.duration, const Duration(minutes: 30));
    });

    test('zero-length range has zero duration', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final range = TimeRange(startTime: now, endTime: now);

      expect(range.duration, Duration.zero);
    });

    test('duration spans multiple hours correctly', () {
      final range = TimeRange(
        startTime: DateTime(2026, 1, 1, 8, 0),
        endTime: DateTime(2026, 1, 1, 10, 45),
      );

      expect(range.duration, const Duration(hours: 2, minutes: 45));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('AppUsageRecord', () {
    AppUsageRecord makeRecord({
      DateTime? date,
      Duration timeSpent = Duration.zero,
      int openCount = 0,
      List<TimeRange>? usagePeriods,
    }) {
      return AppUsageRecord(
        date: date ?? jan1,
        timeSpent: timeSpent,
        openCount: openCount,
        usagePeriods: usagePeriods ?? [],
      );
    }

    test('constructs with provided values', () {
      final record = makeRecord(
        date: jan1,
        timeSpent: const Duration(hours: 1),
        openCount: 5,
      );

      expect(record.date, jan1);
      expect(record.timeSpent, const Duration(hours: 1));
      expect(record.openCount, 5);
      expect(record.usagePeriods, isEmpty);
    });

    test('merge() sums timeSpent and openCount from both records', () {
      final a = makeRecord(
        timeSpent: const Duration(minutes: 30),
        openCount: 3,
        usagePeriods: [
          TimeRange(
            startTime: DateTime(2026, 1, 1, 9, 0),
            endTime: DateTime(2026, 1, 1, 9, 30),
          )
        ],
      );
      final b = makeRecord(
        timeSpent: const Duration(minutes: 20),
        openCount: 2,
        usagePeriods: [
          TimeRange(
            startTime: DateTime(2026, 1, 1, 10, 0),
            endTime: DateTime(2026, 1, 1, 10, 20),
          )
        ],
      );

      final merged = a.merge(b);

      expect(merged.timeSpent, const Duration(minutes: 50));
      expect(merged.openCount, 5);
      expect(merged.usagePeriods.length, 2);
      expect(merged.date, jan1); // date is taken from receiver
    });

    test('merge() with zero-time records produces correct totals', () {
      final a = makeRecord(timeSpent: const Duration(minutes: 10), openCount: 1);
      final b = makeRecord(timeSpent: Duration.zero, openCount: 0);

      final merged = a.merge(b);

      expect(merged.timeSpent, const Duration(minutes: 10));
      expect(merged.openCount, 1);
    });

    test('copyWith() overrides only specified fields', () {
      final original = makeRecord(
        date: jan1,
        timeSpent: const Duration(hours: 1),
        openCount: 3,
      );

      final copy = original.copyWith(openCount: 10);

      expect(copy.date, jan1);
      expect(copy.timeSpent, const Duration(hours: 1));
      expect(copy.openCount, 10);
    });

    test('copyWith() with no arguments returns equivalent record', () {
      final original = makeRecord(
        date: jan2,
        timeSpent: const Duration(minutes: 45),
        openCount: 7,
      );

      final copy = original.copyWith();

      expect(copy.date, original.date);
      expect(copy.timeSpent, original.timeSpent);
      expect(copy.openCount, original.openCount);
    });

    test('copyWith() can update all fields at once', () {
      final original = makeRecord();
      final copy = original.copyWith(
        date: jan2,
        timeSpent: const Duration(hours: 2),
        openCount: 99,
        usagePeriods: [],
      );

      expect(copy.date, jan2);
      expect(copy.timeSpent, const Duration(hours: 2));
      expect(copy.openCount, 99);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  group('FocusSessionRecord', () {
    FocusSessionRecord makeSession({
      DateTime? date,
      DateTime? startTime,
      Duration duration = const Duration(minutes: 25),
      List<String> appsBlocked = const [],
      bool completed = true,
      int breakCount = 0,
      Duration totalBreakTime = Duration.zero,
    }) {
      return FocusSessionRecord(
        date: date ?? jan1,
        startTime: startTime ?? DateTime(2026, 1, 1, 9, 0),
        duration: duration,
        appsBlocked: appsBlocked,
        completed: completed,
        breakCount: breakCount,
        totalBreakTime: totalBreakTime,
      );
    }

    test('constructs with all provided fields', () {
      final session = makeSession(
        duration: const Duration(minutes: 25),
        appsBlocked: ['Chrome', 'Slack'],
        completed: true,
        breakCount: 1,
        totalBreakTime: const Duration(minutes: 5),
      );

      expect(session.duration, const Duration(minutes: 25));
      expect(session.appsBlocked, ['Chrome', 'Slack']);
      expect(session.completed, isTrue);
      expect(session.breakCount, 1);
      expect(session.totalBreakTime, const Duration(minutes: 5));
    });

    test('incomplete session has completed = false', () {
      final session = makeSession(completed: false);
      expect(session.completed, isFalse);
    });

    test('session with no breaks has zero breakCount and zero totalBreakTime', () {
      final session = makeSession(breakCount: 0, totalBreakTime: Duration.zero);

      expect(session.breakCount, 0);
      expect(session.totalBreakTime, Duration.zero);
    });

    test('appsBlocked list is preserved in order', () {
      final session = makeSession(
        appsBlocked: ['YouTube', 'Twitter', 'Reddit'],
      );

      expect(session.appsBlocked, orderedEquals(['YouTube', 'Twitter', 'Reddit']));
    });

    test('empty appsBlocked is valid (no restrictions)', () {
      final session = makeSession(appsBlocked: []);
      expect(session.appsBlocked, isEmpty);
    });
  });
}
