import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/utils/device_snapshot.dart';
import 'package:screentime/utils/private_mode_access.dart';

/// Decides whether an app counts towards insights. Mirrors the Reports rule:
/// in the private-only view show only private apps, otherwise hide private
/// apps unless the user chose to include them in totals.
typedef InsightsFilter = bool Function(String appId, AppMetadata? meta);

bool defaultInsightsFilter(String appId, AppMetadata? meta) {
  if (appId.startsWith('web:')) return false; // websites have their own views
  final isPrivate = meta?.isPrivate ?? false;
  if (shouldShowPrivateOnly()) return isPrivate;
  return !isPrivate || shouldIncludePrivateInTotals();
}

class CategoryDelta {
  final String category;
  final Duration current;
  final Duration previous;
  const CategoryDelta(this.category, this.current, this.previous);
  Duration get delta => current - previous;
}

class AppDelta {
  final String appId;
  final String name;
  final Duration current;
  final Duration previous;
  const AppDelta(this.appId, this.name, this.current, this.previous);
  Duration get delta => current - previous;
}

class WeekComparison {
  final Duration current;
  final Duration previous;
  final List<CategoryDelta> categories; // largest current first
  final List<AppDelta> movers; // largest absolute change first

  const WeekComparison(this.current, this.previous, this.categories, this.movers);

  Duration get delta => current - previous;
  bool get hasData => current > Duration.zero || previous > Duration.zero;
}

class TimelineSegment {
  final String appId;
  final String name;
  final int seconds;
  const TimelineSegment(this.appId, this.name, this.seconds);
}

/// One day split into 24 hours; each hour lists the apps used in it.
class DayTimeline {
  final DateTime day;

  /// Apps shown individually, in legend order (most used first).
  final List<TimelineSegment> topApps;

  /// `hours[h]` maps an appId in [topApps] to seconds; [otherKey] collects
  /// everything else.
  final List<Map<String, int>> hours;

  /// Time counted in the day's total that has no time of day recorded (for
  /// example days recorded before hourly data existed). It can't be drawn on
  /// the hour axis, so it is reported separately instead of silently dropped.
  final int unplacedSeconds;

  static const String otherKey = '\u0000other';

  const DayTimeline(this.day, this.topApps, this.hours, {this.unplacedSeconds = 0});

  int hourTotal(int h) => hours[h].values.fold(0, (s, v) => s + v);
  int get totalSeconds => List.generate(24, hourTotal).fold(0, (s, v) => s + v);
  bool get isEmpty => totalSeconds == 0;
}

class TitleHit {
  final String appId;
  final String appName;
  final String title;
  final int seconds;
  final DateTime lastSeen;
  const TitleHit(this.appId, this.appName, this.title, this.seconds, this.lastSeen);
}

/// Read-only analytics over [AppDataStore]. Pure with respect to the store, so
/// it can be tested against seeded data.
class InsightsData {
  InsightsData(
    this.store, {
    InsightsFilter? include,
    DateTime Function()? now,
    List<DeviceSnapshot> Function()? peers,
  })  : _include = include ?? defaultInsightsFilter,
        _now = now ?? DateTime.now,
        _peers = peers ?? (() => const []);

  final AppDataStore store;
  final InsightsFilter _include;
  final DateTime Function() _now;
  final List<DeviceSnapshot> Function() _peers;

  /// When true, usage from synced devices is added to this device's. Apps are
  /// then matched across devices by display name (case-insensitive) instead of
  /// by app id, since ids differ between operating systems.
  bool allDevices = false;

  bool get hasPeers => _peers().isNotEmpty;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime get today => _day(_now());

  Iterable<MapEntry<String, List<AppUsageRecord>>> _records(
      DateTime start, DateTime end) {
    return store.getAllAppUsageForRange(start, end).entries.where(
        (e) => _include(e.key, store.getAppMetadata(e.key)));
  }

  String _name(String appId) => store.displayNameFor(appId);

  /// Usage rows for the range: this device's, plus other devices' when
  /// [allDevices] is on. Local-only rows are keyed by app id.
  Iterable<_Row> _rows(DateTime start, DateTime end) sync* {
    for (final entry in _records(start, end)) {
      final name = _name(entry.key);
      final category =
          store.getAppMetadata(entry.key)?.category ?? 'Uncategorized';
      final key = allDevices ? name.toLowerCase() : entry.key;
      for (final r in entry.value) {
        yield _Row(key, name, category, _day(r.date), r.timeSpent.inSeconds,
            r.effectiveHourlySeconds);
      }
    }
    if (!allDevices) return;
    for (final peer in _peers()) {
      for (final day in peer.days.entries) {
        final d = DeviceSnapshot.parseDay(day.key);
        if (d == null || d.isBefore(start) || d.isAfter(end)) continue;
        for (final a in day.value) {
          yield _Row(a.name.toLowerCase(), a.name, a.category, d, a.seconds,
              a.hourly);
        }
      }
    }
  }

  /// Total tracked time per day over the last [days] days, oldest first.
  /// Days with no data are present with [Duration.zero].
  Map<DateTime, Duration> dailyTotals(int days) {
    final end = today;
    final start = end.subtract(Duration(days: days - 1));
    final totals = <DateTime, Duration>{
      for (var i = 0; i < days; i++) start.add(Duration(days: i)): Duration.zero,
    };
    for (final r in _rows(start, end)) {
      if (totals.containsKey(r.day)) {
        totals[r.day] = totals[r.day]! + Duration(seconds: r.seconds);
      }
    }
    return totals;
  }

  /// The last 7 days against the 7 days before them.
  WeekComparison compareWeeks({int moversLimit = 5}) {
    final end = today;
    final curStart = end.subtract(const Duration(days: 6));
    final prevStart = end.subtract(const Duration(days: 13));
    final prevEnd = end.subtract(const Duration(days: 7));

    var cur = Duration.zero;
    var prev = Duration.zero;
    final perApp = <String, List<Duration>>{};
    final names = <String, String>{};
    final perCategory = <String, List<Duration>>{};

    for (final r in _rows(prevStart, end)) {
      final isCurrent = !r.day.isBefore(curStart);
      final isPrevious = !r.day.isBefore(prevStart) && !r.day.isAfter(prevEnd);
      if (!isCurrent && !isPrevious) continue;
      final i = isCurrent ? 0 : 1;
      final spent = Duration(seconds: r.seconds);
      if (isCurrent) {
        cur += spent;
      } else {
        prev += spent;
      }
      names.putIfAbsent(r.key, () => r.name);
      (perApp[r.key] ??= [Duration.zero, Duration.zero])[i] += spent;
      (perCategory[r.category] ??= [Duration.zero, Duration.zero])[i] += spent;
    }

    final categories = [
      for (final e in perCategory.entries) CategoryDelta(e.key, e.value[0], e.value[1])
    ]..sort((a, b) => b.current.compareTo(a.current));

    const minChange = Duration(minutes: 1);
    final movers = [
      for (final e in perApp.entries)
        AppDelta(e.key, names[e.key]!, e.value[0], e.value[1])
    ].where((a) => a.delta.abs() >= minChange).toList()
      ..sort((a, b) => b.delta.abs().compareTo(a.delta.abs()));

    return WeekComparison(cur, prev, categories, movers.take(moversLimit).toList());
  }

  /// Hour-by-hour usage for [day], with the busiest [topApps] broken out.
  DayTimeline dayTimeline(DateTime day, {int topApps = 6}) {
    final d = _day(day);
    final perApp = <String, Map<int, int>>{};
    final names = <String, String>{};
    var unplaced = 0;
    for (final r in _rows(d, d)) {
      if (r.day != d) continue;
      names.putIfAbsent(r.key, () => r.name);
      final hourly = perApp.putIfAbsent(r.key, () => {});
      var placed = 0;
      r.hourly.forEach((h, s) {
        hourly[h] = (hourly[h] ?? 0) + s;
        placed += s;
      });
      if (r.seconds > placed) unplaced += r.seconds - placed;
    }

    int total(Map<int, int> m) => m.values.fold(0, (s, v) => s + v);
    final ranked = perApp.entries.where((e) => total(e.value) > 0).toList()
      ..sort((a, b) => total(b.value).compareTo(total(a.value)));
    final top = ranked.take(topApps).toList();
    final topIds = top.map((e) => e.key).toSet();

    final hours = List.generate(24, (_) => <String, int>{});
    for (final e in ranked) {
      final key = topIds.contains(e.key) ? e.key : DayTimeline.otherKey;
      e.value.forEach((h, s) {
        if (h < 0 || h > 23) return;
        hours[h][key] = (hours[h][key] ?? 0) + s;
      });
    }

    return DayTimeline(
      d,
      [for (final e in top) TimelineSegment(e.key, names[e.key]!, total(e.value))],
      hours,
      unplacedSeconds: unplaced,
    );
  }

  /// Window titles from the last [days] days containing [query]
  /// (case-insensitive), most time first. Empty query returns nothing.
  List<TitleHit> searchTitles(String query, {int days = 30, int limit = 50}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final end = today;
    final start = end.subtract(Duration(days: days - 1));
    final hits = <String, ({int seconds, DateTime last})>{};
    final names = <String, String>{};

    for (final entry in _records(start, end)) {
      for (final r in entry.value) {
        r.titleSeconds.forEach((title, seconds) {
          if (title == AppUsageRecord.otherTitlesKey) return;
          if (!title.toLowerCase().contains(q)) return;
          final key = '${entry.key}\u0000$title';
          names[key] = entry.key;
          final prev = hits[key];
          hits[key] = (
            seconds: (prev?.seconds ?? 0) + seconds,
            last: prev == null || r.date.isAfter(prev.last) ? r.date : prev.last,
          );
        });
      }
    }

    final result = [
      for (final e in hits.entries)
        TitleHit(names[e.key]!, _name(names[e.key]!), e.key.split('\u0000').last,
            e.value.seconds, e.value.last)
    ]..sort((a, b) => b.seconds.compareTo(a.seconds));
    return result.take(limit).toList();
  }

  /// Whether any title has been recorded in the last [days] days.
  bool hasAnyTitles({int days = 30}) {
    final end = today;
    final start = end.subtract(Duration(days: days - 1));
    for (final entry in _records(start, end)) {
      if (entry.value.any((r) => r.titleSeconds.isNotEmpty)) return true;
    }
    return false;
  }
}

class _Row {
  final String key;
  final String name;
  final String category;
  final DateTime day;
  final int seconds;
  final Map<int, int> hourly;
  const _Row(this.key, this.name, this.category, this.day, this.seconds, this.hourly);
}
