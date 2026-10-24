// test/unit/storage/app_data_store_test.dart
//
// Integration tests for AppDataStore against real Hive boxes in a temp dir:
// the appId-key migration, duplicate-app cleanup, bloated-box salvage, the
// session archive and day-boundary handling.
//
// Desktop init only records the Hive directory (needed for backups) on macOS
// and Windows, so these are skipped elsewhere.

// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/utils/browser_extension_server.dart';
import 'package:screentime/sections/controller/data_controllers/insights_data.dart';
import 'package:screentime/utils/category_limits.dart';
import 'package:screentime/utils/category_rules.dart';
import 'package:screentime/utils/daily_digest.dart';
import 'package:screentime/utils/device_snapshot.dart';
import 'package:screentime/utils/device_sync.dart';
import 'package:screentime/utils/extension_auth.dart';
import 'package:screentime/utils/privacy_filters.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _usageBox = 'harman_screentime_app_usage_box';
const _metadataBox = 'harman_screentime_app_metadata_box';

class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProvider(this.root);
  final String root;

  @override
  Future<String?> getApplicationDocumentsPath() async => '$root/docs';

  @override
  Future<String?> getApplicationSupportPath() async => '$root/support';
}

final _desktop = Platform.isMacOS || Platform.isWindows;

DateTime _daysAgo(int n) {
  final now = DateTime.now().subtract(Duration(days: n));
  return DateTime(now.year, now.month, now.day);
}

String _key(String appId, DateTime d) =>
    '$appId:${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

AppUsageRecord _usage(DateTime date, int minutes, int opens) => AppUsageRecord(
      date: date,
      timeSpent: Duration(minutes: minutes),
      openCount: opens,
      usagePeriods: [
        TimeRange(
          startTime: date.add(const Duration(hours: 9)),
          endTime: date.add(Duration(hours: 9, minutes: minutes)),
        ),
      ],
    );

AppMetadata _meta({String displayName = ''}) => AppMetadata(
      category: 'Productivity',
      isProductive: true,
      displayName: displayName,
    );

void main() {
  late Directory root;

  /// <docs>/Scolect is where desktop init opens the boxes.
  String hiveDir() => '${root.path}/docs/Scolect';

  void registerAdapters() {
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(AppUsageRecordAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TimeRangeAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(FocusSessionRecordAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(AppMetadataAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(DurationAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(BrowserSourceAdapter());
  }

  /// Writes data into the boxes the way an older app version left it, then
  /// closes Hive so AppDataStore.init() starts from disk.
  Future<void> seed({
    Map<String, AppUsageRecord> usage = const {},
    Map<String, AppMetadata> metadata = const {},
  }) async {
    await Directory(hiveDir()).create(recursive: true);
    Hive.init(hiveDir());
    registerAdapters();
    final u = await Hive.openBox<AppUsageRecord>(_usageBox);
    final m = await Hive.openBox<AppMetadata>(_metadataBox);
    await u.putAll(usage);
    await m.putAll(metadata);
    await u.flush();
    await m.flush();
    await Hive.close();
  }

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    root = await Directory.systemTemp.createTemp('app_data_store_test');
    PathProviderPlatform.instance = _FakePathProvider(root.path);
    SharedPreferences.setMockInitialValues({});
    await SettingsManager().init();
  });

  tearDown(() async {
    await AppDataStore().resetForTesting();
    await root.delete(recursive: true);
  });

  group('session archive', () {
    test('periods pushed out by the retention cap are archived, not lost',
        () async {
      // Initialises the store with no seeded data.
      await seed();
      expect(await AppDataStore().init(), isTrue);

      final day = _daysAgo(0);
      // 15 separate 2-minute sessions, 10 minutes apart (no merging).
      for (var i = 0; i < 15; i++) {
        final start = day.add(Duration(hours: 8, minutes: i * 10));
        await AppDataStore().recordAppUsage(
          'app.a',
          day,
          const Duration(minutes: 2),
          1,
          [TimeRange(startTime: start, endTime: start.add(const Duration(minutes: 2)))],
        );
      }

      final r = AppDataStore().getAppUsage('app.a', day)!;
      expect(r.usagePeriods, hasLength(10));
      expect(r.archive.count, 5);
      expect(r.sessionCount, 15);
      expect(r.totalSessionSeconds, 15 * 120);
      expect(r.longestSession, const Duration(minutes: 2));
      expect(r.shortestSession, const Duration(minutes: 2));
      // Hourly totals stay exact regardless of the cap.
      expect(r.hourlySeconds.values.fold<int>(0, (a, b) => a + b), 15 * 120);
    }, skip: !_desktop);
  });

  group('day boundaries', () {
    test('logical date follows tracking.resetHour', () async {
      final sm = SettingsManager();
      final lateNight = DateTime(2026, 3, 10, 2, 59);
      final morning = DateTime(2026, 3, 10, 3, 0);

      expect(sm.getLogicalDate(lateNight), DateTime(2026, 3, 10));

      sm.updateSetting('tracking.resetHour', 3);
      expect(sm.getLogicalDate(lateNight), DateTime(2026, 3, 9));
      expect(sm.getLogicalDate(morning), DateTime(2026, 3, 10));
    });

    test('logical date rolls back across a month boundary', () async {
      SettingsManager().updateSetting('tracking.resetHour', 4);
      expect(SettingsManager().getLogicalDate(DateTime(2026, 3, 1, 1, 0)),
          DateTime(2026, 2, 28));
    });

    test('usage for different days stays in separate records', () async {
      await seed();
      expect(await AppDataStore().init(), isTrue);

      final today = _daysAgo(0);
      final yesterday = _daysAgo(1);
      await AppDataStore().recordAppUsage('app.a', yesterday,
          const Duration(minutes: 5), 1, []);
      await AppDataStore().recordAppUsage('app.a', today,
          const Duration(minutes: 7), 1, []);

      expect(AppDataStore().getAppUsage('app.a', yesterday)!.timeSpent,
          const Duration(minutes: 5));
      expect(AppDataStore().getAppUsage('app.a', today)!.timeSpent,
          const Duration(minutes: 7));
    }, skip: !_desktop);
  });

  group('appId-key migration', () {
    test('annotates legacy metadata with its key as display name', () async {
      await seed(metadata: {
        'Safari': _meta(),
        'Notes': _meta(displayName: 'My Notes'),
      }, usage: {
        _key('Safari', _daysAgo(1)): _usage(_daysAgo(1), 10, 1),
      });

      expect(await AppDataStore().init(), isTrue);

      expect(AppDataStore().getAppMetadata('Safari')!.displayName, 'Safari');
      expect(AppDataStore().getAppMetadata('Notes')!.displayName, 'My Notes');
      expect(SettingsManager().getSetting('migrations.appIdKeyMigrationDone'),
          isTrue);
    }, skip: !_desktop);

    test('writes a backup of the boxes before touching them', () async {
      await seed(
        metadata: {'Safari': _meta()},
        usage: {_key('Safari', _daysAgo(1)): _usage(_daysAgo(1), 10, 1)},
      );

      await AppDataStore().init();

      final backups = Directory(hiveDir())
          .listSync()
          .whereType<Directory>()
          .where((d) => d.path.contains('backup_pre_appid_migration_'));
      expect(backups, isNotEmpty);
      expect(
          File('${backups.first.path}/$_usageBox.hive').existsSync(), isTrue);
    }, skip: !_desktop);

    test('fresh install is marked done without a backup', () async {
      await seed();
      await AppDataStore().init();

      expect(SettingsManager().getSetting('migrations.appIdKeyMigrationDone'),
          isTrue);
      final backups = Directory(hiveDir())
          .listSync()
          .whereType<Directory>()
          .where((d) => d.path.contains('backup_pre_appid_migration_'));
      expect(backups, isEmpty);
    }, skip: !_desktop);
  });

  group('duplicate-app cleanup', () {
    test('merges entries sharing a display name into the richest one',
        () async {
      final d1 = _daysAgo(1);
      final d2 = _daysAgo(2);
      await seed(metadata: {
        'com.apple.Safari': _meta(displayName: 'Safari'),
        '/Applications/Safari.app': _meta(displayName: 'safari'),
      }, usage: {
        // Survivor: 60 + 30 minutes total.
        _key('com.apple.Safari', d1): _usage(d1, 60, 2),
        _key('com.apple.Safari', d2): _usage(d2, 30, 1),
        // Duplicate: overlaps d1, plus a day the survivor never had.
        _key('/Applications/Safari.app', d1): _usage(d1, 10, 1),
        _key('/Applications/Safari.app', _daysAgo(3)): _usage(_daysAgo(3), 5, 1),
      });

      expect(await AppDataStore().init(), isTrue);

      final store = AppDataStore();
      expect(store.getAppMetadata('/Applications/Safari.app'), isNull);
      expect(store.getAppMetadata('com.apple.Safari'), isNotNull);

      final merged = store.getAppUsage('com.apple.Safari', d1)!;
      expect(merged.timeSpent, const Duration(minutes: 70));
      expect(merged.openCount, 3);
      expect(merged.usagePeriods, hasLength(2));
      expect(merged.hourlySeconds.values.fold<int>(0, (a, b) => a + b),
          70 * 60);

      expect(store.getAppUsage('com.apple.Safari', _daysAgo(3))!.timeSpent,
          const Duration(minutes: 5));
      expect(store.getAppUsage('/Applications/Safari.app', d1), isNull);
      expect(SettingsManager()
          .getSetting('migrations.duplicateAppCleanupDone'), isTrue);
    }, skip: !_desktop);

    test('leaves distinct apps alone', () async {
      final d = _daysAgo(1);
      await seed(metadata: {
        'com.apple.Safari': _meta(displayName: 'Safari'),
        'com.apple.Notes': _meta(displayName: 'Notes'),
      }, usage: {
        _key('com.apple.Safari', d): _usage(d, 20, 1),
        _key('com.apple.Notes', d): _usage(d, 15, 1),
      });

      await AppDataStore().init();

      expect(AppDataStore().getAppUsage('com.apple.Safari', d)!.timeSpent,
          const Duration(minutes: 20));
      expect(AppDataStore().getAppUsage('com.apple.Notes', d)!.timeSpent,
          const Duration(minutes: 15));
    }, skip: !_desktop);

    test('does not run again once the flag is set', () async {
      final d = _daysAgo(1);
      await seed(metadata: {
        'a': _meta(displayName: 'Same'),
        'b': _meta(displayName: 'Same'),
      }, usage: {
        _key('a', d): _usage(d, 20, 1),
        _key('b', d): _usage(d, 10, 1),
      });
      SettingsManager().updateSetting('migrations.appIdKeyMigrationDone', true);
      SettingsManager().updateSetting('migrations.duplicateAppCleanupDone', true);

      await AppDataStore().init();

      expect(AppDataStore().getAppMetadata('a'), isNotNull);
      expect(AppDataStore().getAppMetadata('b'), isNotNull);
    }, skip: !_desktop);
  });

  group('bloated box salvage', () {
    test('rewrites a box above the compaction threshold and keeps its data',
        () async {
      final d = _daysAgo(1);
      await Directory(hiveDir()).create(recursive: true);
      Hive.init(hiveDir());
      registerAdapters();
      final box = await Hive.openBox<AppUsageRecord>(_usageBox,
          compactionStrategy: (_, __) => false);
      // Append-only bloat: overwrite one key until the file is well over 5 MB.
      final fat = AppUsageRecord(
        date: d,
        timeSpent: const Duration(minutes: 1),
        openCount: 1,
        usagePeriods: List.generate(
          10,
          (i) => TimeRange(
            startTime: d.add(Duration(minutes: i * 10)),
            endTime: d.add(Duration(minutes: i * 10 + 1)),
          ),
        ),
      );
      for (var i = 0; i < 20000; i++) {
        await box.put(_key('app.a', d), fat);
      }
      await box.flush();
      await Hive.close();

      final file = File('${hiveDir()}/$_usageBox.hive');
      final before = await file.length();
      expect(before, greaterThan(5 * 1024 * 1024));

      expect(await AppDataStore().init(), isTrue);

      expect(await file.length(), lessThan(before));
      expect(AppDataStore().getAppUsage('app.a', d)!.usagePeriods, hasLength(10));
      expect(File('${hiveDir()}/$_usageBox.hive.salvage.bak').existsSync(),
          isFalse);
    }, skip: !_desktop, timeout: const Timeout(Duration(minutes: 2)));
  });

  group('privacy filters end to end', () {
    const port = 46174;

    Future<int> postUsage(List<Map<String, dynamic>> domains) async {
      final client = HttpClient();
      try {
        final req = await client.postUrl(Uri.parse('http://127.0.0.1:$port/usage'));
        req.headers.contentType = ContentType.json;
        final now = DateTime.now();
        req.write(jsonEncode({
          'date':
              '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
          'domains': domains,
        }));
        final res = await req.close();
        await res.drain<void>();
        return res.statusCode;
      } finally {
        client.close(force: true);
      }
    }

    tearDown(() async {
      await BrowserExtensionServer.dispose();
      SettingsManager().updateSetting(PrivacyFilters.settingKey, <dynamic>[]);
      PrivacyFilters.instance.refresh();
    });

    test('excluded domains are never stored; redacted ones are merged',
        () async {
      HttpOverrides.global = null;
      await seed();
      expect(await AppDataStore().init(), isTrue);
      SettingsManager().updateSetting(ExtensionAuth.settingKey, false);
      SettingsManager().updateSetting(PrivacyFilters.settingKey, [
        const PrivacyFilterRule(id: '1', pattern: r'secret\.io$').toJson(),
        const PrivacyFilterRule(
          id: '2',
          pattern: r'\.bank\.com$',
          action: FilterAction.redact,
          replacement: 'Banking',
        ).toJson(),
      ]);
      PrivacyFilters.instance.refresh();
      expect(await BrowserExtensionServer.startServer(port: port), isTrue);

      final status = await postUsage([
        {'domain': 'app.secret.io', 'seconds': 300, 'visits': 3},
        {'domain': 'login.bank.com', 'seconds': 120, 'visits': 2},
        {'domain': 'pay.bank.com', 'seconds': 60, 'visits': 1},
        {'domain': 'example.com', 'seconds': 30, 'visits': 1},
      ]);
      expect(status, 200);

      final today = SettingsManager().getLogicalDate(DateTime.now());
      final store = AppDataStore();
      expect(store.getAppUsage('web:app.secret.io', today), isNull);
      expect(store.getAppMetadata('web:app.secret.io'), isNull);
      expect(store.getAppUsage('web:login.bank.com', today), isNull);
      expect(store.getAppUsage('web:pay.bank.com', today), isNull);

      final banking = store.getAppUsage('web:Banking', today)!;
      expect(banking.timeSpent, const Duration(seconds: 180));
      expect(banking.openCount, 3);
      expect(store.getAppUsage('web:example.com', today)!.timeSpent,
          const Duration(seconds: 30));
    }, skip: !_desktop);
  });

  group('window titles in the store', () {
    test('titles accumulate across calls and stay bounded', () async {
      await seed();
      expect(await AppDataStore().init(), isTrue);
      final day = _daysAgo(0);

      for (var i = 0; i < 40; i++) {
        await AppDataStore().recordAppUsage('app.a', day, const Duration(minutes: 1), 0, [],
            titleSeconds: {'window ${i % 25}': 60});
      }

      final r = AppDataStore().getAppUsage('app.a', day)!;
      expect(r.titleSeconds.length, lessThanOrEqualTo(AppUsageRecord.maxTitles + 1));
      expect(r.titleSeconds.values.fold<int>(0, (s, v) => s + v), 40 * 60);
    }, skip: !_desktop);

    test('calls without titles leave existing titles alone', () async {
      await seed();
      await AppDataStore().init();
      final day = _daysAgo(0);
      await AppDataStore().recordAppUsage('app.a', day, const Duration(minutes: 1), 0, [],
          titleSeconds: {'Doc': 60});
      await AppDataStore().recordAppUsage('app.a', day, const Duration(minutes: 1), 0, []);

      final r = AppDataStore().getAppUsage('app.a', day)!;
      expect(r.titleSeconds, {'Doc': 60});
      expect(r.timeSpent, const Duration(minutes: 2));
    }, skip: !_desktop);

    test('clearWindowTitles removes cached and on-disk titles, keeps totals',
        () async {
      final old = _daysAgo(200); // outside the 60-day cache: disk only
      await seed(usage: {
        _key('app.a', old): _usage(old, 30, 1).copyWith(titleSeconds: {'Old doc': 1800}),
      });
      expect(await AppDataStore().init(), isTrue);
      final today = _daysAgo(0);
      await AppDataStore().recordAppUsage('app.a', today, const Duration(minutes: 5), 1, [],
          titleSeconds: {'New doc': 300});

      final cleared = await AppDataStore().clearWindowTitles();
      expect(cleared, greaterThanOrEqualTo(1));

      expect(AppDataStore().getAppUsage('app.a', today)!.titleSeconds, isEmpty);
      expect(AppDataStore().getAppUsage('app.a', today)!.timeSpent,
          const Duration(minutes: 5));

      // Reload from disk: nothing comes back.
      await AppDataStore().forceCommitToHive();
      await AppDataStore().resetForTesting();
      expect(await AppDataStore().init(), isTrue);
      expect(AppDataStore().getAppUsage('app.a', today)!.titleSeconds, isEmpty);
      final disk = await Hive.openBox<AppUsageRecord>(_usageBox);
      expect(disk.get(_key('app.a', old))!.titleSeconds, isEmpty);
      expect(disk.get(_key('app.a', old))!.timeSpent, const Duration(minutes: 30));
      await disk.close();
    }, skip: !_desktop);
  });

  group('category rules against real data', () {
    AppMetadata metaIn(String category, {String displayName = ''}) => AppMetadata(
          category: category,
          isProductive: CategoryRules.isProductiveCategory(category),
          displayName: displayName,
        );

    test('apply-to-existing recategorizes matching native apps only',
        () async {
      final d = _daysAgo(1);
      await seed(metadata: {
        'com.figma.Desktop': metaIn('Uncategorized', displayName: 'Figma'),
        'com.acme.Notes': metaIn('Productivity', displayName: 'Notes'),
        'com.apple.Safari': metaIn('Uncategorized', displayName: 'Safari'),
      }, usage: {
        _key('com.figma.Desktop', d): _usage(d, 30, 1),
      });
      expect(await AppDataStore().init(), isTrue);

      final rules = CategoryRules(source: () => const [
            CategoryRule(id: '1', pattern: 'figma', category: 'Creative'),
            CategoryRule(id: '2', pattern: 'notes', category: 'Study'),
          ]);
      final changed = await rules.applyToExistingApps(AppDataStore());

      expect(changed, 2);
      final store = AppDataStore();
      expect(store.getAppMetadata('com.figma.Desktop')!.category, 'Creative');
      expect(store.getAppMetadata('com.figma.Desktop')!.isProductive, isTrue);
      expect(store.getAppMetadata('com.acme.Notes')!.category, 'Study');
      expect(store.getAppMetadata('com.apple.Safari')!.category, 'Uncategorized');

      // Running it again changes nothing.
      expect(await rules.applyToExistingApps(store), 0);
    }, skip: !_desktop);

    test('summary reports the uncategorized share and top apps', () async {
      final d = _daysAgo(1);
      await seed(metadata: {
        'a': metaIn('Uncategorized', displayName: 'A'),
        'b': metaIn('Development', displayName: 'B'),
      }, usage: {
        _key('a', d): _usage(d, 90, 1),
        _key('b', d): _usage(d, 30, 1),
      });
      await AppDataStore().init();

      final s = CategoryRules.summarize(AppDataStore());
      expect(s.total, const Duration(minutes: 120));
      expect(s.uncategorized, const Duration(minutes: 90));
      expect(s.share, closeTo(0.75, 0.001));
      expect(s.topApps.single.key, 'a');
      expect(CategoryRules.shouldShowHint(s), isTrue);
    }, skip: !_desktop);
  });

  group('insights', () {
    AppMetadata meta(String name, String category, {bool isPrivate = false}) =>
        AppMetadata(
          category: category,
          isProductive: true,
          displayName: name,
          isPrivate: isPrivate,
        );

    AppUsageRecord rec(DateTime date, int minutes,
            {Map<int, int>? hourly, Map<String, int>? titles}) =>
        AppUsageRecord(
          date: date,
          timeSpent: Duration(minutes: minutes),
          openCount: 1,
          usagePeriods: const [],
          hourlySeconds: hourly ?? {9: minutes * 60},
          titleSeconds: titles ?? const {},
        );

    Future<InsightsData> open({
      required Map<String, AppMetadata> metadata,
      required Map<String, AppUsageRecord> usage,
      InsightsFilter? include,
    }) async {
      await seed(metadata: metadata, usage: usage);
      expect(await AppDataStore().init(), isTrue);
      return InsightsData(AppDataStore(),
          include: include ?? (id, m) => !id.startsWith('web:') && !(m?.isPrivate ?? false));
    }

    test('dailyTotals covers every day and sums native apps', () async {
      final t = _daysAgo(0), y = _daysAgo(1);
      final data = await open(metadata: {
        'a': meta('A', 'Development'),
        'b': meta('B', 'Productivity'),
      }, usage: {
        _key('a', t): rec(t, 30),
        _key('b', t): rec(t, 15),
        _key('a', y): rec(y, 60),
      });

      final totals = data.dailyTotals(7);
      expect(totals.length, 7);
      expect(totals[t], const Duration(minutes: 45));
      expect(totals[y], const Duration(minutes: 60));
      expect(totals[_daysAgo(3)], Duration.zero);
      expect(totals.keys.first.isBefore(totals.keys.last), isTrue);
    }, skip: !_desktop);

    test('compareWeeks splits current and previous week and ranks movers',
        () async {
      final data = await open(metadata: {
        'code': meta('Code', 'Development'),
        'chat': meta('Chat', 'Social Media'),
      }, usage: {
        _key('code', _daysAgo(1)): rec(_daysAgo(1), 120),
        _key('code', _daysAgo(9)): rec(_daysAgo(9), 60),
        _key('chat', _daysAgo(2)): rec(_daysAgo(2), 10),
        _key('chat', _daysAgo(10)): rec(_daysAgo(10), 70),
        _key('chat', _daysAgo(20)): rec(_daysAgo(20), 500), // outside both
      });

      final w = data.compareWeeks();
      expect(w.current, const Duration(minutes: 130));
      expect(w.previous, const Duration(minutes: 130));
      expect(w.delta, Duration.zero);

      final dev = w.categories.firstWhere((c) => c.category == 'Development');
      expect(dev.current, const Duration(minutes: 120));
      expect(dev.previous, const Duration(minutes: 60));
      expect(w.categories.first.category, 'Development'); // largest current

      expect(w.movers.map((m) => m.name), unorderedEquals(['Code', 'Chat']));
      expect(w.movers.map((m) => m.delta.inMinutes), unorderedEquals([60, -60]));
    }, skip: !_desktop);

    test('movers ignore changes under a minute and respect the limit', () async {
      final data = await open(metadata: {
        for (var i = 0; i < 8; i++) 'app$i': meta('App $i', 'Development'),
      }, usage: {
        for (var i = 0; i < 8; i++)
          _key('app$i', _daysAgo(1)): rec(_daysAgo(1), (i + 1) * 10),
      });
      expect(data.compareWeeks(moversLimit: 3).movers.length, 3);
      expect(data.compareWeeks().movers.first.name, 'App 7');
    }, skip: !_desktop);

    test('dayTimeline stacks hours, ranks apps and folds the rest into other',
        () async {
      final d = _daysAgo(1);
      final data = await open(metadata: {
        for (final id in ['a', 'b', 'c']) id: meta(id.toUpperCase(), 'Development'),
      }, usage: {
        _key('a', d): rec(d, 90, hourly: {9: 3600, 10: 1800}),
        _key('b', d): rec(d, 40, hourly: {9: 1200, 11: 1200}),
        _key('c', d): rec(d, 5, hourly: {9: 300}),
      });

      final t = data.dayTimeline(d, topApps: 2);
      expect(t.topApps.map((a) => a.appId), ['a', 'b']);
      expect(t.hours[9]['a'], 3600);
      expect(t.hours[9]['b'], 1200);
      expect(t.hours[9][DayTimeline.otherKey], 300);
      expect(t.hourTotal(10), 1800);
      expect(t.hourTotal(0), 0);
      expect(t.totalSeconds, 3600 + 1800 + 1200 + 1200 + 300);
      expect(t.isEmpty, isFalse);
      expect(data.dayTimeline(_daysAgo(5)).isEmpty, isTrue);
    }, skip: !_desktop);

    test('private apps are excluded by the filter everywhere', () async {
      final d = _daysAgo(1);
      final data = await open(metadata: {
        'pub': meta('Public', 'Development'),
        'priv': meta('Secret', 'Development', isPrivate: true),
      }, usage: {
        _key('pub', d): rec(d, 30, titles: {'Public doc': 1800}),
        _key('priv', d): rec(d, 60, titles: {'Secret doc': 3600}),
      });

      expect(data.dailyTotals(3)[d], const Duration(minutes: 30));
      expect(data.compareWeeks().current, const Duration(minutes: 30));
      expect(data.dayTimeline(d).topApps.map((a) => a.appId), ['pub']);
      expect(data.searchTitles('doc').map((h) => h.title), ['Public doc']);
    }, skip: !_desktop);

    test('searchTitles matches case-insensitively, aggregates and ranks',
        () async {
      final t = _daysAgo(0), y = _daysAgo(2);
      final data = await open(metadata: {
        'code': meta('Code', 'Development'),
        'word': meta('Word', 'Productivity'),
      }, usage: {
        _key('code', t): rec(t, 40, titles: {'Scolect - main.dart': 1200, 'Other': 600, '': 60}),
        _key('code', y): rec(y, 30, titles: {'Scolect - main.dart': 900}),
        _key('word', y): rec(y, 20, titles: {'SCOLECT report.docx': 1200}),
      });

      final hits = data.searchTitles('scolect');
      expect(hits.map((h) => h.title),
          ['Scolect - main.dart', 'SCOLECT report.docx']);
      expect(hits.first.seconds, 2100);
      expect(hits.first.appName, 'Code');
      expect(hits.first.lastSeen, t);
      expect(data.searchTitles('   '), isEmpty);
      expect(data.searchTitles('nomatch'), isEmpty);
      expect(data.hasAnyTitles(), isTrue);
    }, skip: !_desktop);

    test('search is limited to the requested window and ignores the other bucket',
        () async {
      final old = _daysAgo(45);
      final data = await open(metadata: {
        'a': meta('A', 'Development'),
      }, usage: {
        _key('a', old): rec(old, 10, titles: {'ancient doc': 600}),
        _key('a', _daysAgo(1)): rec(_daysAgo(1), 10, titles: {'': 600}),
      });
      expect(data.searchTitles('doc'), isEmpty);
      expect(data.searchTitles('doc', days: 60).length, 1);
      expect(data.searchTitles(''), isEmpty);
    }, skip: !_desktop);

    test('history finds streaks, records, peak hour and the focus split',
        () async {
      // Active today, yesterday and 2 days ago; a gap; then 5 and 6 days ago.
      final data = await open(metadata: {
        'a': meta('A', 'Development'),
      }, usage: {
        for (final n in [0, 1, 2, 5, 6])
          _key('a', _daysAgo(n)): rec(_daysAgo(n), 60 + n, hourly: {14: (60 + n) * 60}),
      });

      final h = data.history(30);
      expect(h.currentStreak, 3);
      expect(h.longestStreak, 3);
      expect(h.busiestDay!.key, _daysAgo(6));
      expect(h.lightestDay!.key, _daysAgo(0));
      expect(h.peakHour, 14);
      expect(h.hasHourly, isTrue);
      // `meta` marks apps productive, so all of it lands in the productive side.
      expect(h.productive.current, greaterThan(0));
      expect(h.other.current, 0);
      expect(h.opens.current, 5);
      expect(h.trends.single.name, 'A');
    }, skip: !_desktop);

    test('a streak under a daily goal breaks on a day over it', () async {
      final data = await open(metadata: {
        'a': meta('A', 'Development'),
      }, usage: {
        _key('a', _daysAgo(0)): rec(_daysAgo(0), 60),
        _key('a', _daysAgo(1)): rec(_daysAgo(1), 300), // over the goal
        _key('a', _daysAgo(2)): rec(_daysAgo(2), 60),
      });

      final h = data.history(14, goal: const Duration(hours: 2));
      expect(h.currentStreak, 1);
      expect(h.longestStreak, 1);
      expect(data.history(14).currentStreak, 3);
    }, skip: !_desktop);
  });

  group('category limits and digest against real data', () {
    AppMetadata m(String name, String category, {bool isPrivate = false}) => AppMetadata(
          category: category,
          isProductive: true,
          displayName: name,
          isPrivate: isPrivate,
        );

    test('usageByCategory sums today per category and skips websites', () async {
      final d = _daysAgo(0);
      await seed(metadata: {
        'a': m('A', 'Gaming'),
        'b': m('B', 'gaming'),
        'c': m('C', 'Productivity'),
      }, usage: {
        _key('a', d): _usage(d, 30, 1),
        _key('b', d): _usage(d, 20, 1),
        _key('c', d): _usage(d, 10, 1),
        _key('a', _daysAgo(1)): _usage(_daysAgo(1), 99, 1),
      });
      await AppDataStore().init();

      final usage = CategoryLimits.usageByCategory(AppDataStore(), d);
      expect(usage['gaming'], const Duration(minutes: 50));
      expect(usage['productivity'], const Duration(minutes: 10));

      final limits = CategoryLimits(source: () => const [
            CategoryLimit(id: '1', category: 'Gaming', minutes: 55),
          ]);
      expect(limits.evaluate(usage).single.state, LimitState.approaching);
    }, skip: !_desktop);

    test('digest sums today, compares with yesterday, ranks apps, hides private',
        () async {
      final t = _daysAgo(0), y = _daysAgo(1);
      await seed(metadata: {
        'code': m('Code', 'Development'),
        'chat': m('Chat', 'Social Media'),
        'secret': m('Secret', 'Development', isPrivate: true),
      }, usage: {
        _key('code', t): _usage(t, 120, 1),
        _key('chat', t): _usage(t, 30, 1),
        _key('secret', t): _usage(t, 500, 1),
        _key('code', y): _usage(y, 60, 1),
      });
      await AppDataStore().init();

      final digest = DailyDigest.build(AppDataStore(), t);
      expect(digest.total, const Duration(minutes: 150));
      expect(digest.previousTotal, const Duration(minutes: 60));
      expect(digest.topApps.map((a) => a.name), ['Code', 'Chat']);
      expect(digest.body, contains('+1h 30m vs yesterday'));
      expect(digest.body, isNot(contains('Secret')));
      expect(digest.isEmpty, isFalse);
      expect(DailyDigest.build(AppDataStore(), _daysAgo(30)).isEmpty, isTrue);
    }, skip: !_desktop);
  });

  group('device sync', () {
    AppMetadata m(String name, String category, {bool isPrivate = false}) => AppMetadata(
          category: category,
          isProductive: true,
          displayName: name,
          isPrivate: isPrivate,
        );

    final peerId = 'b' * 32;

    DeviceSnapshot peerSnapshot(DateTime day, {int codeSeconds = 7200}) => DeviceSnapshot(
          deviceId: peerId,
          deviceName: 'Desktop',
          updatedAt: DateTime.now(),
          days: {
            DeviceSnapshot.dayKey(day): [
              SnapshotApp('code', 'Development', codeSeconds, {9: 3600, 10: codeSeconds - 3600}),
              SnapshotApp('Photoshop', 'Creative', 1800, const {11: 1800}),
            ]
          },
        );

    Directory shared = Directory.systemTemp;
    DeviceSync sync = DeviceSync(interval: const Duration(days: 1));

    Future<void> setUpSync() async {
      shared = await Directory.systemTemp.createTemp('shared_folder');
      SettingsManager().updateSetting('deviceSync.folder', shared.path);
      SettingsManager().updateSetting('deviceSync.enabled', true);
      sync = DeviceSync(interval: const Duration(days: 1));
    }

    tearDown(() async {
      await sync.resetForTesting();
      if (shared.path != Directory.systemTemp.path && await shared.exists()) {
        await shared.delete(recursive: true);
      }
      shared = Directory.systemTemp;
    });

    Directory syncDir() => Directory('${shared.path}/${DeviceSync.folderName}');

    test('snapshot build keeps native non-private apps and merges same names',
        () async {
      final d = _daysAgo(0);
      await seed(metadata: {
        'com.a.Code': m('Code', 'Development'),
        '/usr/bin/code': m('Code', 'Development'),
        'secret': m('Secret', 'Development', isPrivate: true),
      }, usage: {
        _key('com.a.Code', d): _usage(d, 30, 1),
        _key('/usr/bin/code', d): _usage(d, 20, 1),
        _key('secret', d): _usage(d, 99, 1),
      });
      await AppDataStore().init();

      final snap = DeviceSnapshot.build(AppDataStore(),
          deviceId: 'c' * 32, deviceName: 'Mac', now: DateTime.now());
      final apps = snap.appsOn(d);
      expect(apps.map((a) => a.name), ['Code']);
      expect(apps.single.seconds, 50 * 60);
      expect(apps.single.hourly[9], 50 * 60);
      // And the file we write is one another device will accept.
      expect(DeviceSnapshot.parse(snap.toJson()), isNotNull);
    }, skip: !_desktop);

    test('writes its own file, reads peers, ignores everything untrusted',
        () async {
      final d = _daysAgo(0);
      await seed(metadata: {'a': m('A', 'Development')}, usage: {_key('a', d): _usage(d, 30, 1)});
      await AppDataStore().init();
      await setUpSync();
      await syncDir().create(recursive: true);

      // A real peer, plus junk a shared folder tends to collect.
      await File('${syncDir().path}/$peerId.json').writeAsString(peerSnapshot(d).toJson());
      await File('${syncDir().path}/${'d' * 32}.json').writeAsString('not json');
      await File('${syncDir().path}/${'e' * 32} (conflicted copy).json')
          .writeAsString(peerSnapshot(d).toJson());
      // File name says one id, contents another: not trusted.
      await File('${syncDir().path}/${'f' * 32}.json').writeAsString(peerSnapshot(d).toJson());
      await File('${syncDir().path}/notes.txt').writeAsString('hello');

      expect(await sync.syncOnce(), isTrue);

      expect(sync.peers.map((p) => p.deviceId), [peerId]);
      expect(sync.lastError, isNull);
      expect(sync.lastSyncedAt, isNotNull);

      final own = File('${syncDir().path}/${sync.deviceId}.json');
      expect(await own.exists(), isTrue);
      expect(DeviceSnapshot.parse(await own.readAsString())!.totalOn(d),
          const Duration(minutes: 30));
      expect(syncDir().listSync().where((e) => e.path.endsWith('.tmp')), isEmpty);
    }, skip: !_desktop);

    test('does not rewrite an unchanged file, and never reads its own back',
        () async {
      final d = _daysAgo(0);
      await seed(metadata: {'a': m('A', 'Development')}, usage: {_key('a', d): _usage(d, 30, 1)});
      await AppDataStore().init();
      await setUpSync();

      await sync.syncOnce();
      final own = File('${syncDir().path}/${sync.deviceId}.json');
      final first = await own.lastModified();
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await sync.syncOnce();
      expect(await own.lastModified(), first);
      expect(sync.peers, isEmpty);

      await AppDataStore().recordAppUsage('a', d, const Duration(minutes: 5), 0, []);
      await sync.syncOnce();
      expect(await own.lastModified(), isNot(first));
    }, skip: !_desktop);

    test('fails cleanly with no folder, and when disabled does nothing', () async {
      await seed();
      await AppDataStore().init();
      sync = DeviceSync(interval: const Duration(days: 1));
      SettingsManager().updateSetting('deviceSync.folder', '');
      expect(await sync.syncOnce(), isFalse);

      shared = await Directory.systemTemp.createTemp('shared_folder');
      SettingsManager().updateSetting('deviceSync.folder', shared.path);
      SettingsManager().updateSetting('deviceSync.enabled', false);
      await sync.start();
      expect(sync.isActive, isFalse);
      expect(syncDir().existsSync(), isFalse);
    }, skip: !_desktop);

    test('device id is created once and is valid', () async {
      await seed();
      await AppDataStore().init();
      sync = DeviceSync();
      shared = await Directory.systemTemp.createTemp('shared_folder');
      final id = sync.deviceId;
      expect(DeviceSnapshot.idPattern.hasMatch(id), isTrue);
      expect(sync.deviceId, id);
      expect(DeviceSync().deviceId, id);
    }, skip: !_desktop);

    test('removeOwnFile deletes only this device\'s file', () async {
      final d = _daysAgo(0);
      await seed(metadata: {'a': m('A', 'Development')}, usage: {_key('a', d): _usage(d, 30, 1)});
      await AppDataStore().init();
      await setUpSync();
      await File('${syncDir().path}/$peerId.json').create(recursive: true);
      await File('${syncDir().path}/$peerId.json').writeAsString(peerSnapshot(d).toJson());
      await sync.syncOnce();

      await sync.removeOwnFile();
      expect(File('${syncDir().path}/${sync.deviceId}.json').existsSync(), isFalse);
      expect(File('${syncDir().path}/$peerId.json').existsSync(), isTrue);
    }, skip: !_desktop);

    test('Insights adds other devices only when asked, matching apps by name',
        () async {
      final t = _daysAgo(0), y = _daysAgo(1);
      await seed(metadata: {
        'com.a.Code': m('Code', 'Development'),
      }, usage: {
        _key('com.a.Code', t): _usage(t, 60, 1),
        _key('com.a.Code', y): _usage(y, 30, 1),
      });
      await AppDataStore().init();

      final data = InsightsData(
        AppDataStore(),
        include: (id, meta) => true,
        peers: () => [peerSnapshot(t, codeSeconds: 7200)],
      );
      expect(data.hasPeers, isTrue);

      // Off by default: this device only.
      expect(data.dailyTotals(2)[t], const Duration(minutes: 60));

      data.allDevices = true;
      // 60 min here + 120 min "code" + 30 min Photoshop on the other device.
      expect(data.dailyTotals(2)[t], const Duration(minutes: 210));
      expect(data.dailyTotals(2)[y], const Duration(minutes: 30));

      // "Code" here and "code" there are one app.
      final week = data.compareWeeks();
      final code = week.movers.firstWhere((a) => a.name.toLowerCase() == 'code');
      expect(code.current, const Duration(minutes: 60 + 30 + 120));
      expect(week.categories.map((c) => c.category),
          containsAll(['Development', 'Creative']));

      final timeline = data.dayTimeline(t);
      expect(timeline.topApps.map((a) => a.name.toLowerCase()).toSet(),
          {'code', 'photoshop'});
      expect(timeline.hourTotal(9), 3600 + 3600); // local 09:00 hour + peer 09:00
      expect(timeline.hourTotal(10), 3600);

      data.allDevices = false;
      expect(data.dailyTotals(2)[t], const Duration(minutes: 60));
    }, skip: !_desktop);

    test('time with no time of day is reported as unplaced, not dropped',
        () async {
      final d = _daysAgo(0);
      await seed(metadata: {
        'a': m('A', 'Development'),
        'old': m('Old', 'Development'),
      }, usage: {
        _key('a', d): _usage(d, 30, 1),
        // A legacy-style record: time counted, but no periods and no hourly data.
        _key('old', d): AppUsageRecord(
            date: d, timeSpent: const Duration(minutes: 20), openCount: 1, usagePeriods: const []),
      });
      await AppDataStore().init();
      final peer = DeviceSnapshot(
        deviceId: peerId,
        deviceName: 'Desktop',
        updatedAt: DateTime.now(),
        days: {
          DeviceSnapshot.dayKey(d): [
            const SnapshotApp('Legacy', 'Other', 600, {}),
            const SnapshotApp('Half', 'Other', 1800, {8: 900}),
          ]
        },
      );
      final data = InsightsData(AppDataStore(),
          include: (id, meta) => true, peers: () => [peer]);

      var t = data.dayTimeline(d);
      expect(t.unplacedSeconds, 20 * 60);
      expect(t.totalSeconds, 30 * 60);

      data.allDevices = true;
      t = data.dayTimeline(d);
      // 20 min local + 10 min and 15 min (1800 - 900) from the other device.
      expect(t.unplacedSeconds, (20 + 10 + 15) * 60);
      // Everything is accounted for: placed + unplaced equals the day total.
      expect(t.totalSeconds + t.unplacedSeconds, data.dailyTotals(1)[d]!.inSeconds);
    }, skip: !_desktop);

    test('peer days outside the requested range are ignored', () async {
      await seed();
      await AppDataStore().init();
      final data = InsightsData(
        AppDataStore(),
        include: (id, meta) => true,
        peers: () => [peerSnapshot(_daysAgo(40))],
      )..allDevices = true;
      expect(data.dailyTotals(7).values.fold<Duration>(Duration.zero, (a, b) => a + b),
          Duration.zero);
      expect(data.dailyTotals(60)[_daysAgo(40)], const Duration(minutes: 150));
    }, skip: !_desktop);
  });
}
