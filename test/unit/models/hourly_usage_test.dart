// test/unit/models/hourly_usage_test.dart
//
// Tests for the per-hour usage store on AppUsageRecord, including the
// Hive adapter round trip and backward compatibility with legacy records.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/models/export_models.dart';

TimeRange _range(int h1, int m1, int h2, int m2) => TimeRange(
      startTime: DateTime(2026, 1, 1, h1, m1),
      endTime: DateTime(2026, 1, 1, h2, m2),
    );

AppUsageRecord _record({
  List<TimeRange> periods = const [],
  Map<int, int> hourly = const {},
}) =>
    AppUsageRecord(
      date: DateTime(2026, 1, 1),
      timeSpent: const Duration(minutes: 1),
      openCount: 1,
      usagePeriods: periods,
      hourlySeconds: hourly,
    );

void main() {
  group('hourlyFromPeriods', () {
    test('period within one hour lands in that hour', () {
      expect(AppUsageRecord.hourlyFromPeriods([_range(9, 10, 9, 40)]),
          {9: 30 * 60});
    });

    test('period spanning hours is split at boundaries', () {
      expect(AppUsageRecord.hourlyFromPeriods([_range(9, 50, 11, 10)]),
          {9: 10 * 60, 10: 60 * 60, 11: 10 * 60});
    });

    test('period crossing midnight is split by hour of day', () {
      final p = TimeRange(
        startTime: DateTime(2026, 1, 1, 23, 30),
        endTime: DateTime(2026, 1, 2, 0, 30),
      );
      expect(AppUsageRecord.hourlyFromPeriods([p]), {23: 30 * 60, 0: 30 * 60});
    });

    test('zero-length and empty input produce nothing', () {
      expect(AppUsageRecord.hourlyFromPeriods([]), isEmpty);
      expect(AppUsageRecord.hourlyFromPeriods([_range(9, 0, 9, 0)]), isEmpty);
    });

    test('multiple periods in the same hour accumulate', () {
      expect(
          AppUsageRecord.hourlyFromPeriods(
              [_range(9, 0, 9, 10), _range(9, 30, 9, 40)]),
          {9: 20 * 60});
    });
  });

  group('mergeHourly / effectiveHourlySeconds', () {
    test('mergeHourly sums matching hours without mutating inputs', () {
      final a = {9: 100, 10: 50};
      final b = {10: 25, 11: 5};
      expect(AppUsageRecord.mergeHourly(a, b), {9: 100, 10: 75, 11: 5});
      expect(a, {9: 100, 10: 50});
    });

    test('legacy record falls back to retained periods', () {
      final legacy = _record(periods: [_range(9, 0, 9, 30)]);
      expect(legacy.hourlySeconds, isEmpty);
      expect(legacy.effectiveHourlySeconds, {9: 30 * 60});
    });

    test('stored hourly data wins over periods', () {
      final r = _record(periods: [_range(9, 0, 9, 30)], hourly: {9: 7200});
      expect(r.effectiveHourlySeconds, {9: 7200});
    });

    test('merge combines hourly data of both records', () {
      final a = _record(hourly: {9: 60});
      final b = _record(periods: [_range(9, 0, 9, 1), _range(10, 0, 10, 1)]);
      expect(a.merge(b).hourlySeconds, {9: 120, 10: 60});
    });

    test('copyWith keeps hourly data unless overridden', () {
      final r = _record(hourly: {9: 60});
      expect(r.copyWith(openCount: 5).hourlySeconds, {9: 60});
      expect(r.copyWith(hourlySeconds: {1: 1}).hourlySeconds, {1: 1});
    });
  });

  group('SessionArchive', () {
    test('addPeriods tracks count, total, longest and shortest', () {
      final a = SessionArchive.empty
          .addPeriods([_range(9, 0, 9, 10), _range(10, 0, 10, 2)]);
      expect(a.count, 2);
      expect(a.seconds, 12 * 60);
      expect(a.longestSeconds, 10 * 60);
      expect(a.shortestSeconds, 2 * 60);
    });

    test('zero-length periods are ignored', () {
      expect(SessionArchive.empty.addPeriods([_range(9, 0, 9, 0)]).isEmpty,
          isTrue);
    });

    test('merge combines extremes and ignores empty sides', () {
      const a = SessionArchive(
          count: 1, seconds: 100, longestSeconds: 100, shortestSeconds: 100);
      const b = SessionArchive(
          count: 2, seconds: 90, longestSeconds: 80, shortestSeconds: 10);
      final m = a.merge(b);
      expect(m.count, 3);
      expect(m.seconds, 190);
      expect(m.longestSeconds, 100);
      expect(m.shortestSeconds, 10);
      expect(a.merge(SessionArchive.empty), same(a));
      expect(SessionArchive.empty.merge(b), same(b));
    });

    test('record stats include archived and retained sessions', () {
      final r = AppUsageRecord(
        date: DateTime(2026, 1, 1),
        timeSpent: Duration.zero,
        openCount: 0,
        usagePeriods: [_range(9, 0, 9, 5)],
        archive: const SessionArchive(
            count: 3, seconds: 600, longestSeconds: 400, shortestSeconds: 30),
      );
      expect(r.sessionCount, 4);
      expect(r.totalSessionSeconds, 900);
      expect(r.longestSession, const Duration(seconds: 400));
      expect(r.shortestSession, const Duration(seconds: 30));
    });

    test('adapter round trip keeps the archive', () async {
      final dir = await Directory.systemTemp.createTemp('hive_archive_test');
      Hive.init(dir.path);
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(_delegate);
        Hive.registerAdapter(DurationAdapter());
        Hive.registerAdapter(TimeRangeAdapter());
      }
      _delegate.current = AppUsageRecordAdapter();
      final box = await Hive.openBox<AppUsageRecord>('archive');
      await box.put(
          'k',
          AppUsageRecord(
            date: DateTime(2026, 1, 1),
            timeSpent: Duration.zero,
            openCount: 0,
            usagePeriods: const [],
            archive: const SessionArchive(
                count: 3, seconds: 600, longestSeconds: 400, shortestSeconds: 30),
          ));
      await box.close();
      final r = (await Hive.openBox<AppUsageRecord>('archive')).get('k')!;
      await Hive.close();
      await dir.delete(recursive: true);

      expect(r.archive.count, 3);
      expect(r.archive.seconds, 600);
      expect(r.archive.longestSeconds, 400);
      expect(r.archive.shortestSeconds, 30);
    });
  });

  group('window titles', () {
    test('mergeTitles sums matching titles without mutating inputs', () {
      final a = {'Doc': 60, 'Mail': 30};
      final b = {'Doc': 40, 'Web': 5};
      expect(AppUsageRecord.mergeTitles(a, b), {'Doc': 100, 'Mail': 30, 'Web': 5});
      expect(a, {'Doc': 60, 'Mail': 30});
    });

    test('mergeTitles keeps the longest titles and folds the rest into other', () {
      final many = {for (var i = 0; i < 20; i++) 'title $i': (i + 1) * 10};
      final merged = AppUsageRecord.mergeTitles({}, many);

      final named = merged.keys.where((k) => k != AppUsageRecord.otherTitlesKey);
      expect(named.length, AppUsageRecord.maxTitles);
      // The five shortest (10..50 seconds) were folded away.
      expect(merged[AppUsageRecord.otherTitlesKey], 10 + 20 + 30 + 40 + 50);
      expect(merged.containsKey('title 0'), isFalse);
      expect(merged['title 19'], 200);
      // Nothing is lost overall.
      expect(merged.values.fold<int>(0, (s, v) => s + v),
          many.values.fold<int>(0, (s, v) => s + v));
    });

    test('growth stays bounded across many merges', () {
      var titles = <String, int>{};
      for (var i = 0; i < 500; i++) {
        titles = AppUsageRecord.mergeTitles(titles, {'window $i': 1 + i % 7});
      }
      expect(titles.length, lessThanOrEqualTo(AppUsageRecord.maxTitles + 1));
    });

    test('merge and copyWith carry titles', () {
      final a = _record().copyWith(titleSeconds: {'A': 1});
      final b = _record().copyWith(titleSeconds: {'A': 2, 'B': 3});
      expect(a.merge(b).titleSeconds, {'A': 3, 'B': 3});
      expect(a.copyWith(openCount: 9).titleSeconds, {'A': 1});
    });

    test('titles survive the Hive adapter and legacy records have none',
        () async {
      final dir = await Directory.systemTemp.createTemp('hive_titles_test');
      Hive.init(dir.path);
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(_delegate);
        Hive.registerAdapter(DurationAdapter());
        Hive.registerAdapter(TimeRangeAdapter());
      }
      _delegate.current = AppUsageRecordAdapter();
      var box = await Hive.openBox<AppUsageRecord>('titles');
      await box.put('with', _record().copyWith(titleSeconds: {'Doc': 90, '': 5}));
      _delegate.current = _LegacyUsageAdapter();
      await box.put('legacy', _record());
      await box.close();

      _delegate.current = AppUsageRecordAdapter();
      box = await Hive.openBox<AppUsageRecord>('titles');
      expect(box.get('with')!.titleSeconds, {'Doc': 90, '': 5});
      expect(box.get('legacy')!.titleSeconds, isEmpty);
      await Hive.close();
      await dir.delete(recursive: true);
    });

    test('titles survive the export JSON round trip and are optional', () {
      final withTitles = ExportableAppUsage(
        appName: 'a',
        dateKey: 'a:2026-01-01',
        date: '2026-01-01T00:00:00.000',
        timeSpentMicroseconds: 1,
        openCount: 1,
        usagePeriods: const [],
        titleSeconds: {'Doc': 60},
      );
      expect(ExportableAppUsage.fromJson(withTitles.toJson()).titleSeconds,
          {'Doc': 60});

      final without = ExportableAppUsage(
        appName: 'a',
        dateKey: 'a:2026-01-01',
        date: '2026-01-01T00:00:00.000',
        timeSpentMicroseconds: 1,
        openCount: 1,
        usagePeriods: const [],
      );
      expect(without.toJson().containsKey('titleSeconds'), isFalse);
      expect(ExportableAppUsage.fromJson(without.toJson()).titleSeconds, isNull);
    });
  });

  group('ExportableAppUsage', () {
    test('hourly data and archive survive a JSON round trip', () {
      final original = ExportableAppUsage(
        appName: 'a',
        dateKey: 'a:2026-01-01',
        date: '2026-01-01T00:00:00.000',
        timeSpentMicroseconds: 1,
        openCount: 1,
        usagePeriods: const [],
        hourlySeconds: {9: 60, 23: 5},
        sessionArchive: {'count': 2, 'seconds': 50},
      );
      final back = ExportableAppUsage.fromJson(original.toJson());
      expect(back.hourlySeconds, {9: 60, 23: 5});
      expect(back.sessionArchive, {'count': 2, 'seconds': 50});
    });

    test('exports without the new fields still import', () {
      final back = ExportableAppUsage.fromJson({
        'appName': 'a',
        'dateKey': 'a:2026-01-01',
        'date': '2026-01-01T00:00:00.000',
        'timeSpentMicroseconds': 1,
        'openCount': 1,
        'usagePeriods': <dynamic>[],
      });
      expect(back.hourlySeconds, isNull);
      expect(back.sessionArchive, isNull);
    });
  });

  group('AppUsageRecordAdapter', () {
    late Directory dir;

    // Hive's registry is global and resetAdapters() also drops the built-in
    // DateTime adapter, so register once and switch behaviour via the delegate.
    void registerAdapters(TypeAdapter<AppUsageRecord> usageAdapter) {
      _delegate.current = usageAdapter;
    }

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('hive_hourly_test');
      Hive.init(dir.path);
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(_delegate);
        Hive.registerAdapter(DurationAdapter());
        Hive.registerAdapter(TimeRangeAdapter());
      }
    });

    tearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    test('hourly data survives a write/read round trip', () async {
      registerAdapters(AppUsageRecordAdapter());
      final box = await Hive.openBox<AppUsageRecord>('usage');
      await box.put(
          'k',
          _record(
              periods: [_range(9, 0, 9, 5)], hourly: {9: 300, 10: 60}));
      await box.close();

      final r = (await Hive.openBox<AppUsageRecord>('usage')).get('k')!;
      expect(r.hourlySeconds, {9: 300, 10: 60});
      expect(r.usagePeriods, hasLength(1));
    });

    test('legacy 4-field record reads back and falls back to periods',
        () async {
      registerAdapters(_LegacyUsageAdapter());
      final box = await Hive.openBox<AppUsageRecord>('usage');
      await box.put('k', _record(periods: [_range(9, 0, 9, 5)]));
      await box.close();

      registerAdapters(AppUsageRecordAdapter());
      final r = (await Hive.openBox<AppUsageRecord>('usage')).get('k')!;
      expect(r.hourlySeconds, isEmpty);
      expect(r.effectiveHourlySeconds, {9: 300});
    });
  });
}

final _delegate = _SwitchableUsageAdapter();

// ignore: must_be_immutable
class _SwitchableUsageAdapter extends TypeAdapter<AppUsageRecord> {
  TypeAdapter<AppUsageRecord> current = AppUsageRecordAdapter();

  @override
  final int typeId = 1;

  @override
  AppUsageRecord read(BinaryReader reader) => current.read(reader);

  @override
  void write(BinaryWriter writer, AppUsageRecord obj) =>
      current.write(writer, obj);
}

/// Writes records the way the app did before hourlySeconds existed.
class _LegacyUsageAdapter extends TypeAdapter<AppUsageRecord> {
  @override
  final int typeId = 1;

  @override
  AppUsageRecord read(BinaryReader reader) =>
      throw UnimplementedError('write-only');

  @override
  void write(BinaryWriter writer, AppUsageRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.timeSpent)
      ..writeByte(2)
      ..write(obj.openCount)
      ..writeByte(3)
      ..write(obj.usagePeriods);
  }
}
