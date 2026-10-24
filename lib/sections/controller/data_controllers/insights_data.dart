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

/// One app's time in each of the last four weeks, oldest first.
class AppTrend {
  final String name;
  final List<int> weeklySeconds;
  const AppTrend(this.name, this.weeklySeconds);
  int get total => weeklySeconds.fold(0, (s, v) => s + v);
}

class DeviceShare {
  final String name;
  final bool isThisDevice;
  final int seconds;
  const DeviceShare(this.name, this.seconds, {this.isThisDevice = false});
}

class LongestBlock {
  final int seconds;
  final String appName;
  final DateTime day;
  const LongestBlock(this.seconds, this.appName, this.day);
}

class DayBookends {
  final String firstApp;
  final DateTime firstAt;
  final String lastApp;
  final DateTime lastAt;
  const DayBookends(this.firstApp, this.firstAt, this.lastApp, this.lastAt);
}

/// Totals for the current 7 days and the 7 before them.
class WeekPair {
  final int current;
  final int previous;
  const WeekPair(this.current, this.previous);
  int get delta => current - previous;
}

/// Everything derived from one pass over the last ~26 weeks.
class HistoryInsights {
  final Map<DateTime, Duration> daily;

  /// `weekdayHour[weekday][hour]` = total seconds (weekday 0 = Monday).
  final List<List<int>> weekdayHour;

  /// How many of each weekday fall in the range, to turn totals into averages.
  final List<int> weekdayCount;

  final Duration? goal;
  final int currentStreak;
  final int longestStreak;
  final MapEntry<DateTime, Duration>? busiestDay;
  final MapEntry<DateTime, Duration>? lightestDay;

  /// Start of the busiest rolling 7-day window and its total.
  final MapEntry<DateTime, Duration>? busiestWeek;

  /// Productive vs everything else, this device only.
  final WeekPair productive;
  final WeekPair other;
  final WeekPair lateNight;
  final WeekPair opens; // app opens
  final WeekPair activeSeconds; // time those opens spanned
  final List<AppTrend> trends;

  const HistoryInsights({
    required this.daily,
    required this.weekdayHour,
    required this.weekdayCount,
    this.goal,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.busiestDay,
    this.lightestDay,
    this.busiestWeek,
    this.productive = const WeekPair(0, 0),
    this.other = const WeekPair(0, 0),
    this.lateNight = const WeekPair(0, 0),
    this.opens = const WeekPair(0, 0),
    this.activeSeconds = const WeekPair(0, 0),
    this.trends = const [],
  });

  factory HistoryInsights.fromDaily(Map<DateTime, Duration> daily) => HistoryInsights(
        daily: daily,
        weekdayHour: List.generate(7, (_) => List.filled(24, 0)),
        weekdayCount: List.filled(7, 0),
      );

  bool get hasFocusData =>
      productive.current + productive.previous + other.current + other.previous > 0;

  bool get hasHabitsData =>
      opens.current + opens.previous > 0 || lateNight.current + lateNight.previous > 0;

  bool get hasHourly => weekdayHour.any((d) => d.any((s) => s > 0));

  /// Average seconds for [weekday] (0 = Monday) across observed days.
  double weekdayAverage(int weekday) {
    final n = weekdayCount[weekday];
    if (n == 0) return 0;
    return weekdayHour[weekday].fold(0, (s, v) => s + v) / n;
  }

  /// Seconds per average [hour] of the week, to find the busiest hour.
  int hourTotal(int hour) =>
      List.generate(7, (d) => weekdayHour[d][hour]).fold(0, (s, v) => s + v);

  /// The hour with the most time across all days, or null with no hourly data.
  int? get peakHour {
    var best = -1, bestSecs = 0;
    for (var h = 0; h < 24; h++) {
      final t = hourTotal(h);
      if (t > bestSecs) {
        bestSecs = t;
        best = h;
      }
    }
    return best < 0 ? null : best;
  }

  /// Weekday (0 = Monday) with the highest daily average, or null.
  int? get busiestWeekday {
    var best = -1;
    var bestAvg = 0.0;
    for (var d = 0; d < 7; d++) {
      final a = weekdayAverage(d);
      if (a > bestAvg) {
        bestAvg = a;
        best = d;
      }
    }
    return best < 0 ? null : best;
  }
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
      final meta = store.getAppMetadata(entry.key);
      final category = meta?.category ?? 'Uncategorized';
      final key = allDevices ? name.toLowerCase() : entry.key;
      for (final r in entry.value) {
        yield _Row(key, name, category, _day(r.date), r.timeSpent.inSeconds,
            r.effectiveHourlySeconds,
            productive: meta?.isProductive, opens: r.openCount);
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

  static bool _isLateNight(int hour) => hour >= 23 || hour < 5;

  /// One pass over the last [days] days producing every long-range insight.
  /// [goal] (daily time) turns the streak into "days under goal"; without it a
  /// streak is simply consecutive days with any activity.
  HistoryInsights history(int days, {Duration? goal}) {
    final end = today;
    final start = end.subtract(Duration(days: days - 1));
    final totals = <DateTime, int>{
      for (var i = 0; i < days; i++) start.add(Duration(days: i)): 0,
    };
    final grid = List.generate(7, (_) => List.filled(24, 0));
    final weekdayCount = List.filled(7, 0);
    for (final d in totals.keys) {
      weekdayCount[d.weekday - 1]++;
    }

    final weekTotals = List.filled((days / 7).ceil(), 0);
    final perApp = <String, List<int>>{};
    final names = <String, String>{};
    final prod = [0, 0], other = [0, 0], late = [0, 0], opens = [0, 0], span = [0, 0];

    for (final r in _rows(start, end)) {
      if (!totals.containsKey(r.day)) continue;
      totals[r.day] = totals[r.day]! + r.seconds;
      final age = (end.difference(r.day).inHours / 24).round();
      final bucket = age ~/ 7;
      if (bucket < weekTotals.length) weekTotals[bucket] += r.seconds;

      final wd = r.day.weekday - 1;
      r.hourly.forEach((h, secs) {
        if (h < 0 || h > 23) return;
        grid[wd][h] += secs;
        if (bucket < 2 && _isLateNight(h)) late[bucket] += secs;
      });

      if (bucket < 4) {
        names.putIfAbsent(r.key, () => r.name);
        (perApp[r.key] ??= List.filled(4, 0))[3 - bucket] += r.seconds;
      }
      if (bucket < 2) {
        if (r.productive == true) {
          prod[bucket] += r.seconds;
        } else if (r.productive == false) {
          other[bucket] += r.seconds;
        }
        opens[bucket] += r.opens;
        if (r.opens > 0) span[bucket] += r.seconds;
      }
    }

    final daily = {for (final e in totals.entries) e.key: Duration(seconds: e.value)};
    final ordered = daily.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    bool qualifies(Duration v) =>
        v > Duration.zero && (goal == null || v <= goal);
    var longest = 0, run = 0;
    for (final e in ordered) {
      run = qualifies(e.value) ? run + 1 : 0;
      if (run > longest) longest = run;
    }
    var current = 0;
    var i = ordered.length - 1;
    // Today may still be in progress with nothing logged yet; don't break on it.
    if (i >= 0 && ordered[i].value == Duration.zero) i--;
    while (i >= 0 && qualifies(ordered[i].value)) {
      current++;
      i--;
    }

    MapEntry<DateTime, Duration>? busiest, lightest;
    for (final e in ordered) {
      if (e.value <= Duration.zero) continue;
      if (busiest == null || e.value > busiest.value) busiest = e;
      if (lightest == null || e.value < lightest.value) lightest = e;
    }

    MapEntry<DateTime, Duration>? busiestWeek;
    for (var b = 0; b < weekTotals.length; b++) {
      if (weekTotals[b] <= 0) continue;
      if (busiestWeek == null || weekTotals[b] > busiestWeek.value.inSeconds) {
        busiestWeek = MapEntry(
          end.subtract(Duration(days: b * 7 + 6)),
          Duration(seconds: weekTotals[b]),
        );
      }
    }

    final trends = [
      for (final e in perApp.entries) AppTrend(names[e.key]!, e.value)
    ]..sort((a, b) => b.total.compareTo(a.total));

    WeekPair pair(List<int> v) => WeekPair(v[0], v[1]);
    return HistoryInsights(
      daily: daily,
      weekdayHour: grid,
      weekdayCount: weekdayCount,
      goal: goal,
      currentStreak: current,
      longestStreak: longest,
      busiestDay: busiest,
      lightestDay: lightest,
      busiestWeek: busiestWeek,
      productive: pair(prod),
      other: pair(other),
      lateNight: pair(late),
      opens: pair(opens),
      activeSeconds: pair(span),
      trends: trends.take(5).toList(),
    );
  }

  /// The longest single stretch in one app over the last [days] days. Uses the
  /// retained sessions plus the archive's longest, so it survives the cap.
  LongestBlock? longestBlock({int days = 7}) {
    final end = today;
    final start = end.subtract(Duration(days: days - 1));
    LongestBlock? best;
    for (final entry in _records(start, end)) {
      for (final r in entry.value) {
        var longest = r.archive.longestSeconds;
        for (final p in r.usagePeriods) {
          if (p.duration.inSeconds > longest) longest = p.duration.inSeconds;
        }
        if (longest > 0 && (best == null || longest > best.seconds)) {
          best = LongestBlock(longest, _name(entry.key), _day(r.date));
        }
      }
    }
    return best;
  }

  /// First and last app used on [day], from recorded sessions.
  DayBookends? dayBookends(DateTime day) {
    final d = _day(day);
    String? firstApp, lastApp;
    DateTime? firstAt, lastAt;
    for (final entry in _records(d, d)) {
      for (final r in entry.value) {
        if (_day(r.date) != d) continue;
        for (final p in r.usagePeriods) {
          if (firstAt == null || p.startTime.isBefore(firstAt)) {
            firstAt = p.startTime;
            firstApp = _name(entry.key);
          }
          if (lastAt == null || p.endTime.isAfter(lastAt)) {
            lastAt = p.endTime;
            lastApp = _name(entry.key);
          }
        }
      }
    }
    if (firstAt == null || lastAt == null) return null;
    return DayBookends(firstApp!, firstAt, lastApp!, lastAt);
  }

  /// Most-used window titles over the last [days] days, merged across apps.
  List<TitleHit> topTitles({int days = 7, int limit = 5}) {
    final end = today;
    final start = end.subtract(Duration(days: days - 1));
    final hits = <String, ({String app, int seconds, DateTime last})>{};
    for (final entry in _records(start, end)) {
      for (final r in entry.value) {
        r.titleSeconds.forEach((title, secs) {
          if (title == AppUsageRecord.otherTitlesKey) return;
          final key = '${entry.key}\u0000$title';
          final prev = hits[key];
          hits[key] = (
            app: _name(entry.key),
            seconds: (prev?.seconds ?? 0) + secs,
            last: prev == null || r.date.isAfter(prev.last) ? r.date : prev.last,
          );
        });
      }
    }
    final out = [
      for (final e in hits.entries)
        TitleHit('', e.value.app, e.key.split('\u0000').last, e.value.seconds,
            e.value.last)
    ]..sort((a, b) => b.seconds.compareTo(a.seconds));
    return out.take(limit).toList();
  }

  /// Time per device over the last [days] days: this one plus each peer.
  List<DeviceShare> deviceSplit({int days = 7, String thisDeviceName = ''}) {
    final end = today;
    final start = end.subtract(Duration(days: days - 1));
    var local = 0;
    for (final entry in _records(start, end)) {
      for (final r in entry.value) {
        local += r.timeSpent.inSeconds;
      }
    }
    final out = <DeviceShare>[DeviceShare(thisDeviceName, local, isThisDevice: true)];
    for (final peer in _peers()) {
      var secs = 0;
      for (final day in peer.days.entries) {
        final d = DeviceSnapshot.parseDay(day.key);
        if (d == null || d.isBefore(start) || d.isAfter(end)) continue;
        for (final a in day.value) {
          secs += a.seconds;
        }
      }
      out.add(DeviceShare(peer.deviceName, secs));
    }
    return out..sort((a, b) => b.seconds.compareTo(a.seconds));
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

  /// Null when unknown (rows from other devices carry no productivity flag).
  final bool? productive;
  final int opens;
  const _Row(this.key, this.name, this.category, this.day, this.seconds, this.hourly,
      {this.productive, this.opens = 0});
}
