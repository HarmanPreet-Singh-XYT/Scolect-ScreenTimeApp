import 'package:flutter/foundation.dart';
import '../../app_data_controller.dart';
import 'insight_models.dart';
import 'habit_profile_models.dart';
import 'personalization_store.dart';

import 'package:screentime/l10n/app_localizations.dart';

// ─── PersonalizationEngine ────────────────────────────────────────────────────
// Pure-Dart singleton. Runs deterministic rule-based analysis on data already
// cached by AppDataStore — no external calls, no new Hive boxes.

class PersonalizationEngine {
  static final PersonalizationEngine _instance =
      PersonalizationEngine._internal();
  factory PersonalizationEngine() => _instance;
  PersonalizationEngine._internal();

  final AppDataStore _store = AppDataStore();
  final PersonalizationStore _persist = PersonalizationStore();

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Generates a human-readable summary of today.
  /// Pass values already loaded by DailyOverviewData to avoid a second query.
  DailyNarrative buildDailyNarrative({
    required AppLocalizations l10n,
    required Duration totalScreenTime,
    required String topAppName,
    required int topAppOpenCount,
    required Duration topAppTimeSpent,
    required int focusSessions,
    required Duration totalFocusTime,
    required double productivityScore, // 0–100
  }) {
    // ── Headline ──
    final h = totalScreenTime.inHours;
    final m = totalScreenTime.inMinutes.remainder(60);
    final timeStr = h > 0 ? '${h}h ${m}m' : '${m}m';
    final headline = l10n.narrativeTodaySpent(timeStr);

    // ── Detail: longest focused stretch ──
    String? detail;
    final stretch = _longestFocusStretch(DateTime.now());
    if (stretch != null) {
      final start = _fmtHour(stretch.startTime);
      final end = _fmtHour(stretch.endTime);
      detail = l10n.narrativeMostFocused(start, end);
    } else if (focusSessions > 0) {
      final fs = totalFocusTime.inMinutes;
      detail = l10n.narrativeFocusSessions(focusSessions, focusSessions, fs);
    }

    // ── App note: frequent short vs. infrequent long ──
    String? appNote;
    if (topAppName != 'None' && topAppOpenCount > 0) {
      final avgMinutes = topAppOpenCount > 0
          ? topAppTimeSpent.inMinutes ~/ topAppOpenCount
          : 0;
      if (topAppOpenCount >= 8 && avgMinutes < 5) {
        appNote = l10n.narrativeCheckedAppShort(topAppName, topAppOpenCount);
      } else if (topAppOpenCount <= 3 && topAppTimeSpent.inMinutes >= 30) {
        appNote = l10n.narrativeCheckedAppLong(topAppName, topAppOpenCount, topAppOpenCount);
      }
    }

    // ── Tone ──
    late final String tone;
    if (productivityScore >= 70) {
      tone = l10n.narrativeToneSolid;
    } else if (productivityScore >= 50) {
      tone = l10n.narrativeToneDecent;
    } else if (totalScreenTime.inMinutes < 30) {
      tone = l10n.narrativeToneLight;
    } else {
      tone = l10n.narrativeToneImprove;
    }

    return DailyNarrative(
      headline: headline,
      detail: detail,
      appNote: appNote,
      tone: tone,
    );
  }

  /// Pattern-detection over the last [lookbackDays] days.
  /// Returns only insights that have NOT been dismissed.
  Future<List<Insight>> getActiveInsights({int lookbackDays = 60}) async {
    try {
      if (!_store.isInitialized) return [];

      final today = DateTime.now();
      final start = today.subtract(Duration(days: lookbackDays));

      final allUsage = _store.getAllAppUsageForRange(start, today);
      final focusSessions = _store.getFocusSessionsRange(start, today);

      final raw = await compute(_runDetectors, _DetectorInput(
        allUsage: allUsage,
        focusSessions: focusSessions,
        metadataByApp: _buildMetadataSnapshot(),
        today: today,
      ));

      return raw
          .where((i) => !_persist.isInsightDismissed(i.id))
          .toList();
    } catch (e) {
      debugPrint('PersonalizationEngine.getActiveInsights error: $e');
      return [];
    }
  }

  /// Returns the cached HabitProfile, recomputing if >24h old.
  Future<HabitProfile?> getHabitProfile({int lookbackDays = 90}) async {
    try {
      if (!_store.isInitialized) return null;

      if (!_persist.needsRecompute && _persist.cachedProfile != null) {
        return _persist.cachedProfile!;
      }

      final today = DateTime.now();
      final start = today.subtract(Duration(days: lookbackDays));
      final focusSessions = _store.getFocusSessionsRange(start, today);

      // Collect per-day productivity scores and screen times
      final Map<int, List<double>> scoresByWeekday = {};
      final List<Duration> dailyTimes = [];
      int daysWithData = 0;

      for (int i = 0; i < lookbackDays; i++) {
        final date = today.subtract(Duration(days: i));
        final total = _store.getTotalScreenTime(date);
        if (total.inMinutes < 5) continue;

        daysWithData++;
        dailyTimes.add(total);

        final score = _store.getProductivityScore(date);
        scoresByWeekday.putIfAbsent(date.weekday, () => []).add(score);
      }

      if (daysWithData < 3) return null;

      // Persist first tracking date
      final firstDate = today.subtract(Duration(days: lookbackDays - 1));
      await _persist.setFirstDateIfAbsent(firstDate);

      // Chronotype: bucket focus sessions by hour
      final Map<int, int> sessionsByBucket = {0: 0, 1: 0, 2: 0};
      for (final s in focusSessions) {
        final h = s.startTime.hour;
        if (h >= 5 && h < 12) {
          sessionsByBucket[0] = sessionsByBucket[0]! + 1;
        } else if (h >= 12 && h < 17) {
          sessionsByBucket[1] = sessionsByBucket[1]! + 1;
        } else {
          sessionsByBucket[2] = sessionsByBucket[2]! + 1;
        }
      }
      final maxBucket = sessionsByBucket.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      final Chronotype chronotype = focusSessions.isEmpty
          ? Chronotype.unknown
          : [
              Chronotype.morningPerson,
              Chronotype.afternoonPeak,
              Chronotype.nightOwl
            ][maxBucket];

      // Work style: average focus session length
      final completedSessions =
          focusSessions.where((s) => s.completed).toList();
      Duration avgFocusLen = Duration.zero;
      if (completedSessions.isNotEmpty) {
        final total = completedSessions.fold(
            Duration.zero, (sum, s) => sum + s.focusTime);
        avgFocusLen = Duration(
            seconds: total.inSeconds ~/ completedSessions.length);
      }

      late final WorkStyle workStyle;
      if (completedSessions.isEmpty) {
        workStyle = WorkStyle.balanced;
      } else if (avgFocusLen.inMinutes >= 40) {
        workStyle = WorkStyle.deepFocus;
      } else if (avgFocusLen.inMinutes < 20) {
        workStyle = WorkStyle.taskSwitcher;
      } else {
        workStyle = WorkStyle.balanced;
      }

      // Most common distraction app (non-productive, highest open count)
      String? distractionApp;
      int maxOpenCount = 0;
      for (final appName in _store.allAppNames) {
        final meta = _store.getAppMetadata(appName);
        if (meta == null || meta.isProductive) continue;
        int totalOpens = 0;
        for (int i = 0; i < lookbackDays; i++) {
          final date = today.subtract(Duration(days: i));
          final record = _store.getAppUsage(appName, date);
          if (record != null) totalOpens += record.openCount;
        }
        if (totalOpens > maxOpenCount) {
          maxOpenCount = totalOpens;
          distractionApp = appName;
        }
      }
      if (maxOpenCount < 5) distractionApp = null;

      // Best / worst day by avg productivity score
      int bestDay = 1, worstDay = 7;
      double bestScore = -1, worstScore = 101;
      for (final entry in scoresByWeekday.entries) {
        if (entry.value.isEmpty) continue;
        final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
        if (avg > bestScore) {
          bestScore = avg;
          bestDay = entry.key;
        }
        if (avg < worstScore) {
          worstScore = avg;
          worstDay = entry.key;
        }
      }

      // Peak focus window: 2-hour bin with highest completion rate
      final Map<int, int> binTotal = {};
      final Map<int, int> binCompleted = {};
      for (final s in focusSessions) {
        final bin = (s.startTime.hour ~/ 2) * 2;
        binTotal[bin] = (binTotal[bin] ?? 0) + 1;
        if (s.completed) binCompleted[bin] = (binCompleted[bin] ?? 0) + 1;
      }
      int peakStart = 9, peakEnd = 11;
      double bestRate = -1;
      for (final bin in binTotal.keys) {
        final rate = (binCompleted[bin] ?? 0) / binTotal[bin]!;
        if (rate > bestRate) {
          bestRate = rate;
          peakStart = bin;
          peakEnd = bin + 2;
        }
      }

      // Average daily screen time
      final avgDaily = dailyTimes.isNotEmpty
          ? Duration(
              seconds: dailyTimes.fold(Duration.zero, (a, b) => a + b).inSeconds ~/
                  dailyTimes.length)
          : Duration.zero;

      // Average productivity score
      double totalScore = 0;
      int scoreDays = 0;
      for (final list in scoresByWeekday.values) {
        for (final s in list) {
          totalScore += s;
          scoreDays++;
        }
      }
      final avgScore = scoreDays > 0 ? totalScore / scoreDays : 0.0;

      final profile = HabitProfile(
        chronotype: chronotype,
        workStyle: workStyle,
        mostCommonDistractionApp: distractionApp,
        avgFocusSessionLength: avgFocusLen,
        bestDayOfWeek: bestDay,
        worstDayOfWeek: worstDay,
        avgDailyScreenTime: avgDaily,
        avgProductivityScore: avgScore,
        daysAnalyzed: daysWithData,
        computedAt: DateTime.now(),
        peakFocusStartHour: peakStart,
        peakFocusEndHour: peakEnd,
      );

      await _persist.saveProfile(profile);
      return profile;
    } catch (e) {
      debugPrint('PersonalizationEngine.getHabitProfile error: $e');
      return null;
    }
  }

  /// Builds the weekly story narrative.
  Future<WeeklyStory?> buildWeeklyStory({required AppLocalizations l10n}) async {
    try {
      if (!_store.isInitialized) return null;

      final today = DateTime.now();
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final thisWeekTotal =
          _store.getTotalScreenTimeRange(weekStart, today);

      if (thisWeekTotal.inMinutes < 5) return null;

      // Ordinal week since first tracking date
      final firstDate = _persist.firstTrackingDate ?? weekStart;
      final weekNumber =
          today.difference(firstDate).inDays ~/ 7 + 1;

      // Week 1 total for comparison
      final week1Start = firstDate;
      final week1End = firstDate.add(const Duration(days: 6));
      final week1Total = _store.getTotalScreenTimeRange(week1Start, week1End);

      final h = thisWeekTotal.inHours;
      final m = thisWeekTotal.inMinutes.remainder(60);
      final timeStr = h > 0 ? '${h}h ${m}m' : '${m}m';
      final headline = l10n.weeklyStoryHeadline(weekNumber, timeStr);

      String? progressNote;
      if (weekNumber > 1 && week1Total.inMinutes > 0) {
        final diffMins = week1Total.inMinutes - thisWeekTotal.inMinutes;
        if (diffMins > 30) {
          final dh = diffMins ~/ 60;
          final dm = diffMins.remainder(60);
          final diff = dh > 0 ? '${dh}h ${dm}m' : '${dm}m';
          progressNote = l10n.weeklyStoryReclaimed(diff);
        } else if (diffMins < -30) {
          final dh = diffMins.abs() ~/ 60;
          final dm = diffMins.abs().remainder(60);
          final diff = dh > 0 ? '${dh}h ${dm}m' : '${dm}m';
          progressNote = l10n.weeklyStoryUp(diff);
        }
      }

      // Find the biggest non-productive category this week
      final catBreakdown =
          _store.getCategoryBreakdownRange(weekStart, today);
      String? improvementArea;
      Duration maxDistraction = Duration.zero;
      String? worstCat;
      for (final entry in catBreakdown.entries) {
        final meta = _categoryIsProductive(entry.key);
        if (!meta && entry.value > maxDistraction) {
          maxDistraction = entry.value;
          worstCat = entry.key;
        }
      }
      if (worstCat != null && maxDistraction.inMinutes >= 30) {
        final dh = maxDistraction.inHours;
        final dm = maxDistraction.inMinutes.remainder(60);
        final timeLabel = dh > 0 ? '${dh}h' : '${dm}m';
        improvementArea = l10n.weeklyStoryImprovementArea(timeLabel, worstCat);
      }

      return WeeklyStory(
        weekNumber: weekNumber,
        headline: headline,
        progressNote: progressNote,
        improvementArea: improvementArea,
      );
    } catch (e) {
      debugPrint('PersonalizationEngine.buildWeeklyStory error: $e');
      return null;
    }
  }

  /// Dismiss an insight (persisted immediately).
  Future<void> dismissInsight(String id) => _persist.dismissInsight(id);

  // ── Private helpers ─────────────────────────────────────────────────────────

  TimeRange? _longestFocusStretch(DateTime date) {
    final dateKey = _fmtDateKey(date);
    // Gather all usage periods from all apps for today
    final allPeriods = <TimeRange>[];
    for (final appName in _store.allAppNames) {
      final record = _store.getAppUsage(appName, date);
      if (record != null) allPeriods.addAll(record.usagePeriods);
    }
    if (allPeriods.isEmpty) return null;

    allPeriods.sort((a, b) => a.startTime.compareTo(b.startTime));

    // Merge periods that are within 5 minutes of each other
    final merged = <TimeRange>[];
    var current = allPeriods.first;
    for (int i = 1; i < allPeriods.length; i++) {
      final next = allPeriods[i];
      if (next.startTime.difference(current.endTime).inMinutes <= 5) {
        current = TimeRange(
            startTime: current.startTime,
            endTime: next.endTime.isAfter(current.endTime)
                ? next.endTime
                : current.endTime);
      } else {
        merged.add(current);
        current = next;
      }
    }
    merged.add(current);

    if (merged.isEmpty) return null;
    return merged.reduce((a, b) => a.duration >= b.duration ? a : b);
  }

  Map<String, bool> _buildMetadataSnapshot() {
    final result = <String, bool>{};
    for (final appName in _store.allAppNames) {
      final meta = _store.getAppMetadata(appName);
      if (meta != null) result[appName] = meta.isProductive;
    }
    return result;
  }

  bool _categoryIsProductive(String category) {
    const productiveCategories = {
      'Productivity',
      'Development',
      'Education',
      'Work',
      'Design',
      'Finance',
    };
    return productiveCategories.contains(category);
  }

  static String _fmtDateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _fmtHour(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute;
    final suffix = h < 12 ? 'AM' : 'PM';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return m == 0 ? '$hour $suffix' : '$hour:${m.toString().padLeft(2, '0')} $suffix';
  }
}

// ─── Detector input (passed to isolate via compute) ───────────────────────────

class _DetectorInput {
  final Map<String, List<AppUsageRecord>> allUsage;
  final List<FocusSessionRecord> focusSessions;
  final Map<String, bool> metadataByApp; // appName → isProductive
  final DateTime today;

  _DetectorInput({
    required this.allUsage,
    required this.focusSessions,
    required this.metadataByApp,
    required this.today,
  });
}

// ─── Detector pipeline (runs in isolate) ─────────────────────────────────────

List<Insight> _runDetectors(_DetectorInput input) {
  final results = <Insight>[];

  final d1 = _detectWeekdayPattern(input);
  if (d1 != null) results.add(d1);

  final d2 = _detectStartupSequence(input);
  if (d2 != null) results.add(d2);

  final d3 = _detectFocusTimeOfDay(input);
  if (d3 != null) results.add(d3);

  final d4 = _detectPostHeavyUsage(input);
  if (d4 != null) results.add(d4);

  return results;
}

// Insight: one weekday has >=30% more screen time than average
Insight? _detectWeekdayPattern(_DetectorInput input) {
  try {
    final Map<int, List<Duration>> byWeekday = {};

    for (final records in input.allUsage.values) {
      for (final r in records) {
        byWeekday.putIfAbsent(r.date.weekday, () => []).add(r.timeSpent);
      }
    }
    if (byWeekday.isEmpty) return null;

    // Average per weekday
    final Map<int, Duration> avgByDay = {};
    for (final entry in byWeekday.entries) {
      final total =
          entry.value.fold(Duration.zero, (a, b) => a + b);
      avgByDay[entry.key] =
          Duration(seconds: total.inSeconds ~/ entry.value.length);
    }

    final overallAvg = Duration(
        seconds: avgByDay.values
                .fold(Duration.zero, (a, b) => a + b)
                .inSeconds ~/
            avgByDay.length);

    for (final entry in avgByDay.entries) {
      if (overallAvg.inSeconds < 60) continue;
      final ratio = entry.value.inSeconds / overallAvg.inSeconds;
      if (ratio >= 1.30) {
        final dayName = _weekdayName(entry.key);
        final extra = ((ratio - 1) * 100).round();
        return Insight(
          id: 'weekday_overwork_${entry.key}',
          title: '$dayName is your longest day',
          body:
              'On average, you spend $extra% more time at your screen on $dayName than any other day.',
          type: InsightType.weekdayPattern,
          severity: InsightSeverity.neutral,
          generatedAt: input.today,
        );
      }
    }
    return null;
  } catch (_) {
    return null;
  }
}

// Insight: two apps are opened back-to-back on 70%+ of days
Insight? _detectStartupSequence(_DetectorInput input) {
  try {
    // Group all usage periods per date
    final Map<String, List<MapEntry<String, DateTime>>> byDate = {};

    for (final appEntry in input.allUsage.entries) {
      for (final record in appEntry.value) {
        final dateKey = _fmtKey(record.date);
        for (final period in record.usagePeriods) {
          byDate
              .putIfAbsent(dateKey, () => [])
              .add(MapEntry(appEntry.key, period.startTime));
        }
      }
    }

    // For each day, find the first and second apps
    final Map<String, int> pairCounts = {};
    int totalDays = 0;

    for (final entry in byDate.entries) {
      final periods = entry.value;
      periods.sort((a, b) => a.value.compareTo(b.value));
      if (periods.length < 2) continue;

      totalDays++;
      final first = periods.first.key;
      // Find second distinct app within 2 minutes
      for (int i = 1; i < periods.length; i++) {
        if (periods[i].key != first) {
          final gap = periods[i].value.difference(periods.first.value);
          if (gap.inMinutes <= 2) {
            final pair = '${first}___${periods[i].key}';
            pairCounts[pair] = (pairCounts[pair] ?? 0) + 1;
          }
          break;
        }
      }
    }

    if (totalDays < 5) return null;

    for (final entry in pairCounts.entries) {
      final rate = entry.value / totalDays;
      if (rate >= 0.70) {
        final parts = entry.key.split('___');
        final app1 = _shortName(parts[0]);
        final app2 = _shortName(parts[1]);
        return Insight(
          id: 'startup_sequence_${parts[0]}_${parts[1]}',
          title: 'Your daily startup ritual',
          body:
              'On ${(rate * 100).round()}% of your days, you open $app1 and then $app2 within 2 minutes — every single time.',
          type: InsightType.appSequence,
          severity: InsightSeverity.neutral,
          generatedAt: input.today,
        );
      }
    }
    return null;
  } catch (_) {
    return null;
  }
}

// Insight: focus sessions succeed much more in AM vs PM
Insight? _detectFocusTimeOfDay(_DetectorInput input) {
  try {
    if (input.focusSessions.length < 5) return null;

    int amTotal = 0, amCompleted = 0;
    int pmTotal = 0, pmCompleted = 0;

    for (final s in input.focusSessions) {
      if (s.startTime.hour < 12) {
        amTotal++;
        if (s.completed) amCompleted++;
      } else {
        pmTotal++;
        if (s.completed) pmCompleted++;
      }
    }

    if (amTotal < 3 || pmTotal < 3) return null;

    final amRate = amCompleted / amTotal;
    final pmRate = pmCompleted / pmTotal;

    if (amRate >= pmRate * 1.5) {
      return Insight(
        id: 'focus_am_peak',
        title: 'You focus best in the morning',
        body:
            'Your morning focus sessions complete ${(amRate * 100).round()}% of the time vs ${(pmRate * 100).round()}% in the afternoon. Schedule deep work before noon.',
        type: InsightType.timeOfDayFocus,
        severity: InsightSeverity.positive,
        generatedAt: input.today,
      );
    } else if (pmRate >= amRate * 1.5) {
      return Insight(
        id: 'focus_pm_peak',
        title: 'You focus best in the afternoon',
        body:
            'Your afternoon focus sessions complete ${(pmRate * 100).round()}% of the time vs ${(amRate * 100).round()}% in the morning. Save deep work for after lunch.',
        type: InsightType.timeOfDayFocus,
        severity: InsightSeverity.positive,
        generatedAt: input.today,
      );
    }
    return null;
  } catch (_) {
    return null;
  }
}

// Insight: after heavy use of a distracting app, it's rarely opened again
Insight? _detectPostHeavyUsage(_DetectorInput input) {
  try {
    // Find non-productive apps with heavy use days
    for (final appEntry in input.allUsage.entries) {
      final appName = appEntry.key;
      if (input.metadataByApp[appName] == true) continue; // skip productive

      final records = appEntry.value;
      if (records.length < 5) continue;

      // Days with >=20 min usage
      final heavyDays =
          records.where((r) => r.timeSpent.inMinutes >= 20).toList();
      if (heavyDays.length < 3) continue;

      // On heavy days, how many had only one usage period (not revisited)?
      int singleVisitHeavy = 0;
      for (final r in heavyDays) {
        if (r.openCount <= 2) singleVisitHeavy++;
      }

      final noReturnRate = singleVisitHeavy / heavyDays.length;
      if (noReturnRate >= 0.80) {
        final short = _shortName(appName);
        return Insight(
          id: 'post_heavy_$appName',
          title: 'Once you\'re in $short, you go deep',
          body:
              'On ${(noReturnRate * 100).round()}% of days you open $short, you spend 20+ min in one sitting and rarely go back. You tend to binge or skip it.',
          type: InsightType.postHeavyUsage,
          severity: InsightSeverity.neutral,
          generatedAt: input.today,
        );
      }
    }
    return null;
  } catch (_) {
    return null;
  }
}

// ─── Small utilities (top-level for isolate access) ───────────────────────────

String _weekdayName(int day) {
  const names = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  return day >= 1 && day <= 7 ? names[day] : 'that day';
}

String _fmtKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _shortName(String appName) {
  // Strip common suffixes like ".exe", long window titles
  final cleaned = appName
      .replaceAll(RegExp(r'\.exe$', caseSensitive: false), '')
      .split(' — ')
      .first
      .split(' - ')
      .first
      .trim();
  return cleaned.length > 24 ? '${cleaned.substring(0, 22)}…' : cleaned;
}
