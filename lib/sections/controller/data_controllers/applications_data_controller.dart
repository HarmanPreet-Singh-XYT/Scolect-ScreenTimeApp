import 'package:intl/intl.dart';
import 'dart:math';
import '../app_data_controller.dart';

// Extension for formatting Duration objects
extension DurationFormatter on Duration {
  String toHourMinuteFormat() {
    final int hours = inHours;
    final int minutes = inMinutes % 60;

    if (hours > 0) {
      return minutes > 0 ? "${hours}h ${minutes}m" : "${hours}h";
    } else if (minutes > 0) {
      return "${minutes}m";
    }
    return "${inSeconds % 60}s";
  }
}

enum TimeRange { day, week, month }

class DateRange {
  final DateTime startDate;
  final DateTime endDate;
  final int dayCount;

  DateRange({required this.startDate, required this.endDate})
      : dayCount = endDate.difference(startDate).inDays + 1;
}

class ApplicationBasicDetail {
  final String name;
  final String category;
  final Duration screenTime;
  final String formattedScreenTime;
  final bool isTracking;
  final bool isHidden;
  final bool isProductive;
  final Duration dailyLimit;
  final bool limitStatus;

  ApplicationBasicDetail({
    required this.name,
    required this.category,
    required this.screenTime,
    required this.isTracking,
    required this.isHidden,
    required this.isProductive,
    required this.dailyLimit,
    required this.limitStatus,
  }) : formattedScreenTime = screenTime.toHourMinuteFormat();
}

class UsageTrendsData {
  final Map<String, Duration> daily;
  final Map<String, Duration> weekly;
  final Map<String, Duration> monthly;
  final Map<String, String> formattedDaily;
  final Map<String, String> formattedWeekly;
  final Map<String, String> formattedMonthly;

  UsageTrendsData({
    required this.daily,
    required this.weekly,
    required this.monthly,
  })  : formattedDaily =
            daily.map((k, v) => MapEntry(k, v.toHourMinuteFormat())),
        formattedWeekly =
            weekly.map((k, v) => MapEntry(k, v.toHourMinuteFormat())),
        formattedMonthly =
            monthly.map((k, v) => MapEntry(k, v.toHourMinuteFormat()));
}

class UsageInsights {
  final List<int> mostActiveHours;
  final Duration longestSession;
  final String formattedLongestSession;
  final Duration averageDailyUsage;
  final String formattedAverageDailyUsage;

  UsageInsights({
    required this.mostActiveHours,
    required this.longestSession,
    required this.averageDailyUsage,
  })  : formattedLongestSession = longestSession.toHourMinuteFormat(),
        formattedAverageDailyUsage = averageDailyUsage.toHourMinuteFormat();
}

class CategoryAppComparison {
  final String appName;
  final Duration usage;
  final String formattedUsage;
  final double comparisonPercentage;

  CategoryAppComparison({
    required this.appName,
    required this.usage,
    required this.comparisonPercentage,
  }) : formattedUsage = usage.toHourMinuteFormat();
}

class UsageComparisons {
  final Duration currentPeriodUsage;
  final String formattedCurrentPeriodUsage;
  final Duration previousPeriodUsage;
  final String formattedPreviousPeriodUsage;
  final double growthPercentage;
  final List<CategoryAppComparison> similarAppsComparison;

  UsageComparisons({
    required this.currentPeriodUsage,
    required this.previousPeriodUsage,
    required this.growthPercentage,
    required this.similarAppsComparison,
  })  : formattedCurrentPeriodUsage = currentPeriodUsage.toHourMinuteFormat(),
        formattedPreviousPeriodUsage = previousPeriodUsage.toHourMinuteFormat();
}

class SessionBreakdown {
  final Duration averageSessionDuration;
  final String formattedAverageSessionDuration;
  final Duration longestSessionDuration;
  final String formattedLongestSessionDuration;
  final Duration shortestSessionDuration;
  final String formattedShortestSessionDuration;
  final int totalSessions;
  final double averageLaunchesPerDay;
  final int maxLaunchesPerDay;
  final DateTime? lastUsedTimestamp;

  SessionBreakdown({
    required this.averageSessionDuration,
    required this.longestSessionDuration,
    required this.shortestSessionDuration,
    required this.totalSessions,
    required this.averageLaunchesPerDay,
    required this.maxLaunchesPerDay,
    required this.lastUsedTimestamp,
  })  : formattedAverageSessionDuration =
            averageSessionDuration.toHourMinuteFormat(),
        formattedLongestSessionDuration =
            longestSessionDuration.toHourMinuteFormat(),
        formattedShortestSessionDuration =
            shortestSessionDuration.toHourMinuteFormat();
}

class ApplicationDetailedData {
  final UsageTrendsData usageTrends;
  final Map<int, Duration> hourlyBreakdown;
  final Map<int, String> formattedHourlyBreakdown;
  final Map<String, Duration> categoryUsage;
  final Map<String, String> formattedCategoryUsage;
  final UsageInsights usageInsights;
  final UsageComparisons comparisons;
  final SessionBreakdown sessionBreakdown;

  ApplicationDetailedData({
    required this.usageTrends,
    required this.hourlyBreakdown,
    required this.categoryUsage,
    required this.usageInsights,
    required this.comparisons,
    required this.sessionBreakdown,
  })  : formattedHourlyBreakdown =
            hourlyBreakdown.map((k, v) => MapEntry(k, v.toHourMinuteFormat())),
        formattedCategoryUsage =
            categoryUsage.map((k, v) => MapEntry(k, v.toHourMinuteFormat()));
}

// Helper class to return combined insights and session data
class _InsightsAndSession {
  final UsageInsights insights;
  final SessionBreakdown session;

  _InsightsAndSession({required this.insights, required this.session});
}

class ApplicationsDataProvider {
  static final ApplicationsDataProvider _instance =
      ApplicationsDataProvider._internal();
  factory ApplicationsDataProvider() => _instance;
  ApplicationsDataProvider._internal();

  final AppDataStore _dataStore = AppDataStore();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      _initialized = await _dataStore.init();
    }
  }

  // ============================================================
  // HELPER: Iterate dates in range (eliminates repeated while-loops)
  // ============================================================

  Iterable<DateTime> _datesInRange(DateRange range) sync* {
    DateTime current = range.startDate;
    while (!current.isAfter(range.endDate)) {
      yield current;
      current = current.add(const Duration(days: 1));
    }
  }

  /// Sum total usage for an app across a date range.
  Duration _sumUsageInRange(String appName, DateRange range) {
    Duration total = Duration.zero;
    for (final date in _datesInRange(range)) {
      total +=
          _dataStore.getAppUsage(appName, date)?.timeSpent ?? Duration.zero;
    }
    return total;
  }

  DateTime _minDate(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

  // ============================================================
  // PUBLIC API
  // ============================================================

  Future<List<ApplicationBasicDetail>> fetchAllApplications() async {
    await _ensureInitialized();

    final DateTime today = DateTime.now();
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);
    final appNames = _dataStore.allAppNames;
    final applications = <ApplicationBasicDetail>[];

    for (final appName in appNames) {
      final metadata = _dataStore.getAppMetadata(appName);
      if (metadata == null) continue;

      final usageRecord = _dataStore.getAppUsage(appName, startOfDay);

      applications.add(ApplicationBasicDetail(
        name: appName,
        category: metadata.category,
        screenTime: usageRecord?.timeSpent ?? Duration.zero,
        isTracking: metadata.isTracking,
        isHidden: !metadata.isVisible,
        isProductive: metadata.isProductive,
        dailyLimit: metadata.dailyLimit,
        limitStatus: metadata.limitStatus,
      ));
    }

    applications.sort((a, b) => b.screenTime.compareTo(a.screenTime));
    return applications;
  }

  Future<ApplicationBasicDetail> fetchApplicationByName(String appName) async {
    await _ensureInitialized();

    final metadata = _dataStore.getAppMetadata(appName);
    if (metadata == null) {
      throw Exception('App metadata not found for: $appName');
    }

    final usageRecord = _dataStore.getAppUsage(appName, DateTime.now());

    return ApplicationBasicDetail(
      name: appName,
      category: metadata.category,
      screenTime: usageRecord?.timeSpent ?? Duration.zero,
      isTracking: metadata.isTracking,
      isHidden: !metadata.isVisible,
      isProductive: metadata.isProductive,
      dailyLimit: metadata.dailyLimit,
      limitStatus: metadata.limitStatus,
    );
  }

  /// OPTIMIZED: Single date-range iteration shared across all analytics.
  Future<ApplicationDetailedData> fetchApplicationDetails(
      String appName, TimeRange timeRange) async {
    await _ensureInitialized();

    final metadata = _dataStore.getAppMetadata(appName);
    if (metadata == null) {
      throw Exception('App metadata not found for: $appName');
    }

    final dateRange = _getDateRange(timeRange);

    // ── Single pass: collect all records once ──
    final records = <DateTime, AppUsageRecord?>{};
    for (final date in _datesInRange(dateRange)) {
      records[date] = _dataStore.getAppUsage(appName, date);
    }

    // ── Build all analytics from the shared records map ──
    final usageTrends = _buildUsageTrends(records, dateRange);
    final hourlyBreakdown = _buildHourlyBreakdown(records);
    final insightsAndSession =
        _buildInsightsAndSession(records, hourlyBreakdown, dateRange);
    final categoryUsage =
        _buildCategoryUsage(appName, metadata.category, dateRange);
    final comparisons =
        _buildComparisons(appName, metadata.category, dateRange, records);

    return ApplicationDetailedData(
      usageTrends: usageTrends,
      hourlyBreakdown: hourlyBreakdown,
      categoryUsage: categoryUsage,
      usageInsights: insightsAndSession.insights,
      comparisons: comparisons,
      sessionBreakdown: insightsAndSession.session,
    );
  }

  // ============================================================
  // DATE RANGE
  // ============================================================

  DateRange _getDateRange(TimeRange timeRange) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (timeRange) {
      case TimeRange.day:
        return DateRange(startDate: today, endDate: today);
      case TimeRange.week:
        return DateRange(
          startDate: today.subtract(const Duration(days: 6)),
          endDate: today,
        );
      case TimeRange.month:
        return DateRange(
          startDate: today.subtract(const Duration(days: 29)),
          endDate: today,
        );
    }
  }

  // ============================================================
  // USAGE TRENDS - Uses pre-fetched records
  // ============================================================

  UsageTrendsData _buildUsageTrends(
      Map<DateTime, AppUsageRecord?> records, DateRange dateRange) {
    final dailyUsage = <String, Duration>{};
    final weeklyUsage = <String, Duration>{};
    final monthlyUsage = <String, Duration>{};

    final dateFormat = DateFormat('MM/dd');
    final monthFormat = DateFormat('MMM');

    // Single iteration builds daily + monthly simultaneously
    for (final entry in records.entries) {
      final date = entry.key;
      final usage = entry.value?.timeSpent ?? Duration.zero;

      dailyUsage[dateFormat.format(date)] = usage;

      if (dateRange.dayCount >= 28) {
        final monthKey = monthFormat.format(date);
        monthlyUsage.update(monthKey, (v) => v + usage, ifAbsent: () => usage);
      }
    }

    // Weekly aggregation
    if (dateRange.dayCount >= 7) {
      final totalWeeks = (dateRange.dayCount - 1) ~/ 7 + 1;
      for (int w = 0; w < totalWeeks; w++) {
        Duration weekTotal = Duration.zero;
        final weekStart = dateRange.startDate.add(Duration(days: w * 7));
        final weekEnd =
            _minDate(weekStart.add(const Duration(days: 6)), dateRange.endDate);

        DateTime d = weekStart;
        while (!d.isAfter(weekEnd)) {
          weekTotal += records[d]?.timeSpent ?? Duration.zero;
          d = d.add(const Duration(days: 1));
        }

        if (weekTotal > Duration.zero) {
          weeklyUsage['Week ${w + 1}'] = weekTotal;
        }
      }
    }

    return UsageTrendsData(
      daily: dailyUsage,
      weekly: weeklyUsage,
      monthly: monthlyUsage,
    );
  }

  // ============================================================
  // HOURLY BREAKDOWN - Uses pre-fetched records
  // ============================================================

  Map<int, Duration> _buildHourlyBreakdown(
      Map<DateTime, AppUsageRecord?> records) {
    final hourlyUsage = <int, Duration>{};
    for (int h = 0; h < 24; h++) {
      hourlyUsage[h] = Duration.zero;
    }

    for (final record in records.values) {
      if (record == null || record.usagePeriods.isEmpty) continue;

      for (final period in record.usagePeriods) {
        final startHour = period.startTime.hour;
        final endHour = period.endTime.hour;

        if (startHour == endHour) {
          hourlyUsage[startHour] = hourlyUsage[startHour]! + period.duration;
        } else {
          for (int hour = startHour; hour <= endHour; hour++) {
            final hourStart = DateTime(
              period.startTime.year,
              period.startTime.month,
              period.startTime.day,
              hour,
            );
            final hourEnd = hourStart.add(const Duration(hours: 1));

            final effectiveStart =
                hour == startHour ? period.startTime : hourStart;
            final effectiveEnd = hour == endHour ? period.endTime : hourEnd;

            hourlyUsage[hour] =
                hourlyUsage[hour]! + effectiveEnd.difference(effectiveStart);
          }
        }
      }
    }

    return hourlyUsage;
  }

  // ============================================================
  // INSIGHTS + SESSION BREAKDOWN - Combined single pass
  // ============================================================

  _InsightsAndSession _buildInsightsAndSession(
    Map<DateTime, AppUsageRecord?> records,
    Map<int, Duration> hourlyBreakdown,
    DateRange dateRange,
  ) {
    // ── Active hours from pre-computed hourly breakdown ──
    final sortedHours = hourlyBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final activeHours = <int>[];
    for (int i = 0; i < min(3, sortedHours.length); i++) {
      if (sortedHours[i].value > Duration.zero) {
        activeHours.add(sortedHours[i].key);
      }
    }

    // ── Single pass for sessions, usage totals, launches ──
    Duration totalUsage = Duration.zero;
    int daysWithUsage = 0;
    Duration longestSession = Duration.zero;
    Duration shortestSession = const Duration(days: 365);
    final sessionDurations = <Duration>[];
    int totalLaunches = 0;
    int maxLaunchesPerDay = 0;
    int daysWithLaunches = 0;
    DateTime? lastUsedTimestamp;

    for (final record in records.values) {
      if (record == null) continue;

      if (record.timeSpent > Duration.zero) {
        totalUsage += record.timeSpent;
        daysWithUsage++;
      }

      if (record.openCount > 0) {
        totalLaunches += record.openCount;
        daysWithLaunches++;
        if (record.openCount > maxLaunchesPerDay) {
          maxLaunchesPerDay = record.openCount;
        }
      }

      for (final period in record.usagePeriods) {
        sessionDurations.add(period.duration);

        if (period.duration > longestSession) {
          longestSession = period.duration;
        }
        if (period.duration < shortestSession) {
          shortestSession = period.duration;
        }
        if (lastUsedTimestamp == null ||
            period.endTime.isAfter(lastUsedTimestamp)) {
          lastUsedTimestamp = period.endTime;
        }
      }
    }

    if (sessionDurations.isEmpty) {
      shortestSession = Duration.zero;
    }

    final averageDailyUsage = daysWithUsage > 0
        ? Duration(seconds: totalUsage.inSeconds ~/ daysWithUsage)
        : Duration.zero;

    Duration averageSessionDuration = Duration.zero;
    if (sessionDurations.isNotEmpty) {
      final totalSessionSeconds =
          sessionDurations.fold<int>(0, (sum, d) => sum + d.inSeconds);
      averageSessionDuration =
          Duration(seconds: totalSessionSeconds ~/ sessionDurations.length);
    }

    final insights = UsageInsights(
      mostActiveHours: activeHours,
      longestSession: longestSession,
      averageDailyUsage: averageDailyUsage,
    );

    final session = SessionBreakdown(
      averageSessionDuration: averageSessionDuration,
      longestSessionDuration: longestSession,
      shortestSessionDuration: shortestSession,
      totalSessions: sessionDurations.length,
      averageLaunchesPerDay:
          daysWithLaunches > 0 ? totalLaunches / daysWithLaunches : 0,
      maxLaunchesPerDay: maxLaunchesPerDay,
      lastUsedTimestamp: lastUsedTimestamp,
    );

    return _InsightsAndSession(insights: insights, session: session);
  }

  // ============================================================
  // CATEGORY USAGE
  // ============================================================

  Map<String, Duration> _buildCategoryUsage(
      String appName, String appCategory, DateRange dateRange) {
    final categoryUsage = <String, Duration>{};

    for (final name in _dataStore.allAppNames) {
      final metadata = _dataStore.getAppMetadata(name);
      if (metadata == null || metadata.category != appCategory) continue;

      final totalUsage = _sumUsageInRange(name, dateRange);
      if (totalUsage > Duration.zero) {
        categoryUsage[name] = totalUsage;
      }
    }

    return categoryUsage;
  }

  // ============================================================
  // COMPARISONS - Reuses pre-fetched current period data
  // ============================================================

  UsageComparisons _buildComparisons(
    String appName,
    String category,
    DateRange dateRange,
    Map<DateTime, AppUsageRecord?> records,
  ) {
    // Current period from pre-fetched records
    Duration currentPeriodUsage = Duration.zero;
    for (final record in records.values) {
      currentPeriodUsage += record?.timeSpent ?? Duration.zero;
    }

    // Previous period
    final previousRange = DateRange(
      startDate:
          dateRange.startDate.subtract(Duration(days: dateRange.dayCount)),
      endDate: dateRange.startDate.subtract(const Duration(days: 1)),
    );
    final previousPeriodUsage = _sumUsageInRange(appName, previousRange);

    final growthPercentage = previousPeriodUsage.inSeconds > 0
        ? ((currentPeriodUsage.inSeconds - previousPeriodUsage.inSeconds) /
                previousPeriodUsage.inSeconds) *
            100
        : 0.0;

    // Similar apps comparison
    final similarApps = <CategoryAppComparison>[];
    final currentSeconds = currentPeriodUsage.inSeconds;

    for (final name in _dataStore.allAppNames) {
      if (name == appName) continue;

      final metadata = _dataStore.getAppMetadata(name);
      if (metadata == null || metadata.category != category) continue;

      final appTotalUsage = _sumUsageInRange(name, dateRange);
      if (appTotalUsage <= Duration.zero) continue;

      similarApps.add(CategoryAppComparison(
        appName: name,
        usage: appTotalUsage,
        comparisonPercentage: currentSeconds > 0
            ? (appTotalUsage.inSeconds / currentSeconds) * 100
            : 0,
      ));
    }

    similarApps.sort((a, b) => b.usage.compareTo(a.usage));

    return UsageComparisons(
      currentPeriodUsage: currentPeriodUsage,
      previousPeriodUsage: previousPeriodUsage,
      growthPercentage: growthPercentage,
      similarAppsComparison: similarApps,
    );
  }
}
