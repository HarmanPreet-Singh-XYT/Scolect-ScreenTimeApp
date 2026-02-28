import '../app_data_controller.dart';

class DailyOverviewData {
  static final DailyOverviewData _instance = DailyOverviewData._internal();
  factory DailyOverviewData() => _instance;
  DailyOverviewData._internal();

  final AppDataStore _dataStore = AppDataStore();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      _initialized = await _dataStore.init();
    }
  }

  /// Fetch today's overview data - OPTIMIZED: Single pass through all apps
  Future<OverviewData> fetchTodayOverview() async {
    await _ensureInitialized();

    final DateTime today = DateTime.now();
    final DateTime weekAgo = today.subtract(const Duration(days: 7));

    // Pre-fetch shared values once
    final Duration todayScreenTime = _dataStore.getTotalScreenTime(today);
    final Duration averageWeekScreenTime =
        _dataStore.getAverageScreenTime(weekAgo, today);
    final Duration todayProductiveTime = _dataStore.getProductiveTime(today);
    final double todayProductivityScore =
        _dataStore.getProductivityScore(today);
    final String mostUsedApp = _dataStore.getMostUsedApp(today);
    final int focusSessionsCount = _dataStore.getFocusSessionsCount(today);
    final Duration totalFocusTime = _dataStore.getTotalFocusTime(today);

    // ── OPTIMIZED: Single pass builds all three lists simultaneously ──
    final result = _buildAllAppData(today, todayScreenTime);

    return OverviewData(
      totalScreenTime: todayScreenTime,
      averageScreenTime: averageWeekScreenTime,
      screenTimePercentage:
          _calculatePercentage(todayScreenTime, averageWeekScreenTime),
      productiveTime: todayProductiveTime,
      productivityScore: todayProductivityScore,
      mostUsedApp: mostUsedApp,
      focusSessions: focusSessionsCount,
      totalFocusTime: totalFocusTime,
      topApplications: result.topApplications,
      categoryBreakdown: result.categoryBreakdown,
      applicationLimits: result.applicationLimits,
    );
  }

  /// Single pass through all apps to build top applications,
  /// category breakdown, and application limits simultaneously.
  _AppDataResult _buildAllAppData(DateTime date, Duration totalScreenTime) {
    final applications = <ApplicationDetail>[];
    final limitDetails = <ApplicationLimitDetail>[];
    final categoryTotals = <String, Duration>{};

    final int totalSeconds = totalScreenTime.inSeconds;
    final bool hasTotalTime = totalSeconds > 0;

    // ── One loop through all apps ──
    for (final appName in _dataStore.allAppNames) {
      final metadata = _dataStore.getAppMetadata(appName);
      if (metadata == null) continue;

      final usageRecord = _dataStore.getAppUsage(appName, date);
      final timeSpent = usageRecord?.timeSpent ?? Duration.zero;

      // Build top applications entry
      if (usageRecord != null) {
        applications.add(ApplicationDetail(
          name: appName,
          category: metadata.category,
          screenTime: timeSpent,
          percentageOfTotalTime:
              hasTotalTime ? (timeSpent.inSeconds / totalSeconds) * 100 : 0.0,
          isVisible: metadata.isVisible,
        ));
      }

      // Accumulate category totals
      if (timeSpent > Duration.zero) {
        categoryTotals.update(
          metadata.category,
          (existing) => existing + timeSpent,
          ifAbsent: () => timeSpent,
        );
      }

      // Build application limits entry
      if (metadata.limitStatus) {
        double percentageOfLimit = 0.0;
        if (metadata.dailyLimit > Duration.zero) {
          percentageOfLimit =
              (timeSpent.inSeconds / metadata.dailyLimit.inSeconds) * 100;
        }

        limitDetails.add(ApplicationLimitDetail(
          name: appName,
          category: metadata.category,
          dailyLimit: metadata.dailyLimit,
          actualUsage: timeSpent,
          percentageOfLimit: percentageOfLimit,
          percentageOfTotalTime:
              hasTotalTime ? (timeSpent.inSeconds / totalSeconds) * 100 : 0.0,
        ));
      }
    }

    // Sort results
    applications.sort((a, b) => b.screenTime.compareTo(a.screenTime));
    limitDetails
        .sort((a, b) => b.percentageOfLimit.compareTo(a.percentageOfLimit));

    // Build category breakdown from accumulated totals
    final categoryBreakdown = hasTotalTime
        ? categoryTotals.entries.map((entry) {
            return CategoryDetail(
              name: entry.key,
              totalScreenTime: entry.value,
              percentageOfTotalTime:
                  (entry.value.inSeconds / totalSeconds) * 100,
            );
          }).toList()
        : <CategoryDetail>[];

    if (categoryBreakdown.isNotEmpty) {
      categoryBreakdown
          .sort((a, b) => b.totalScreenTime.compareTo(a.totalScreenTime));
    }

    return _AppDataResult(
      topApplications: applications,
      categoryBreakdown: categoryBreakdown,
      applicationLimits: limitDetails,
    );
  }

  double _calculatePercentage(Duration current, Duration average) {
    if (average.inSeconds < 300) return 100.0;
    return ((current.inSeconds / average.inSeconds) * 100).clamp(0.0, 200.0);
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    }
    return '${duration.inSeconds.remainder(60)}s';
  }
}

/// Internal result class to return all three lists from single pass
class _AppDataResult {
  final List<ApplicationDetail> topApplications;
  final List<CategoryDetail> categoryBreakdown;
  final List<ApplicationLimitDetail> applicationLimits;

  _AppDataResult({
    required this.topApplications,
    required this.categoryBreakdown,
    required this.applicationLimits,
  });
}

class OverviewData {
  final Duration totalScreenTime;
  final Duration averageScreenTime;
  final double screenTimePercentage;
  final Duration productiveTime;
  final double productivityScore;
  final String mostUsedApp;
  final int focusSessions;
  final Duration totalFocusTime;
  final List<ApplicationDetail> topApplications;
  final List<CategoryDetail> categoryBreakdown;
  final List<ApplicationLimitDetail> applicationLimits;

  final String formattedTotalScreenTime;
  final String formattedAverageScreenTime;
  final String formattedProductiveTime;
  final String formattedTotalFocusTime;

  OverviewData({
    required this.totalScreenTime,
    required this.averageScreenTime,
    required this.screenTimePercentage,
    required this.productiveTime,
    required this.productivityScore,
    required this.mostUsedApp,
    required this.focusSessions,
    required this.totalFocusTime,
    required this.topApplications,
    required this.categoryBreakdown,
    required this.applicationLimits,
  })  : formattedTotalScreenTime =
            DailyOverviewData.formatDuration(totalScreenTime),
        formattedAverageScreenTime =
            DailyOverviewData.formatDuration(averageScreenTime),
        formattedProductiveTime =
            DailyOverviewData.formatDuration(productiveTime),
        formattedTotalFocusTime =
            DailyOverviewData.formatDuration(totalFocusTime);
}

class ApplicationDetail {
  final String name;
  final String category;
  final Duration screenTime;
  final double percentageOfTotalTime;
  final String formattedScreenTime;
  final bool isVisible;

  ApplicationDetail({
    required this.name,
    required this.category,
    required this.screenTime,
    required this.percentageOfTotalTime,
    required this.isVisible,
  }) : formattedScreenTime = DailyOverviewData.formatDuration(screenTime);
}

class CategoryDetail {
  final String name;
  final Duration totalScreenTime;
  final double percentageOfTotalTime;
  final String formattedTotalScreenTime;

  CategoryDetail({
    required this.name,
    required this.totalScreenTime,
    required this.percentageOfTotalTime,
  }) : formattedTotalScreenTime =
            DailyOverviewData.formatDuration(totalScreenTime);
}

class ApplicationLimitDetail {
  final String name;
  final String category;
  final Duration dailyLimit;
  final Duration actualUsage;
  final double percentageOfLimit;
  final double percentageOfTotalTime;
  final String formattedDailyLimit;
  final String formattedActualUsage;

  ApplicationLimitDetail({
    required this.name,
    required this.category,
    required this.dailyLimit,
    required this.actualUsage,
    required this.percentageOfLimit,
    required this.percentageOfTotalTime,
  })  : formattedDailyLimit = DailyOverviewData.formatDuration(dailyLimit),
        formattedActualUsage = DailyOverviewData.formatDuration(actualUsage);
}
