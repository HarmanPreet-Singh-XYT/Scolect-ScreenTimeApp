import '../app_data_controller.dart';
import '../settings_data_controller.dart';
import '../categories_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screentime/web/chrome_storage_interop.dart' if (dart.library.io) 'package:screentime/web/chrome_storage_interop_stub.dart';

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
    if (kIsWeb) return _fetchWebOverview();
    await _ensureInitialized();

    final DateTime today = SettingsManager().getLogicalDate(DateTime.now());
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
      if (appName.startsWith('web:')) continue;
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
          isProductive: metadata.isProductive,
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

  Future<OverviewData> _fetchWebOverview() async {
    final d = DateTime.now();
    final dateKey = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final storageKey = 'scolect_day_$dateKey';

    final result = await chromeStorageGet([storageKey]);
    final dayData = result[storageKey] as Map<dynamic, dynamic>? ?? {};
    final domains = (dayData['domains'] as List<dynamic>?) ?? [];

    final metaRes = await chromeStorageGet(['scolect_app_metadata', 'scolect_settings']);
    final siteMeta = (metaRes['scolect_app_metadata'] as Map<dynamic, dynamic>?) ?? {};
    final settingsMap = (metaRes['scolect_settings'] as Map<dynamic, dynamic>?) ?? {};
    final customMeta = (settingsMap['metadata'] as Map<dynamic, dynamic>?) ?? {};

    Duration totalTime = Duration.zero;
    List<ApplicationDetail> applications = [];
    int maxSeconds = 0;
    String mostUsed = "None";
    Map<String, Duration> categoryTotals = {};

    for (var d in domains) {
      final domain = d['domain'] as String? ?? 'unknown';
      final seconds = d['seconds'] as num? ?? 0;
      final duration = Duration(seconds: seconds.toInt());

      final meta = (customMeta[domain] as Map<dynamic, dynamic>?) ?? {};
      final rawSiteMeta = (siteMeta[domain] as Map<dynamic, dynamic>?) ?? {};

      final siteName = (meta['siteName'] as String?)?.isNotEmpty == true
          ? meta['siteName'] as String
          : (rawSiteMeta['siteName'] as String? ?? '');
      final displayName = siteName.isNotEmpty ? siteName : domain;
      final category = (meta['category'] as String?)?.isNotEmpty == true
          ? meta['category'] as String
          : (rawSiteMeta['category'] as String?)?.isNotEmpty == true
              ? rawSiteMeta['category'] as String
              : AppCategories.categorizeApp(displayName);

      if (seconds > maxSeconds) {
        maxSeconds = seconds.toInt();
        mostUsed = displayName;
      }

      totalTime += duration;
      categoryTotals[category] = (categoryTotals[category] ?? Duration.zero) + duration;

      applications.add(ApplicationDetail(
        name: displayName,
        category: category,
        screenTime: duration,
        percentageOfTotalTime: 0,
        isVisible: true,
        isProductive: true,
      ));
    }

    final totalSecs = totalTime.inSeconds;
    if (totalSecs > 0) {
      for (int i = 0; i < applications.length; i++) {
        final app = applications[i];
        final pct = (app.screenTime.inSeconds / totalSecs) * 100;
        applications[i] = ApplicationDetail(
          name: app.name,
          category: app.category,
          screenTime: app.screenTime,
          percentageOfTotalTime: pct,
          isVisible: true,
          isProductive: true,
        );
      }
    }

    final categoryBreakdown = totalSecs > 0
        ? categoryTotals.entries.map((entry) {
            return CategoryDetail(
              name: entry.key,
              totalScreenTime: entry.value,
              percentageOfTotalTime: (entry.value.inSeconds / totalSecs) * 100,
            );
          }).toList()
        : <CategoryDetail>[];

    applications.sort((a, b) => b.screenTime.compareTo(a.screenTime));
    categoryBreakdown.sort((a, b) => b.totalScreenTime.compareTo(a.totalScreenTime));

    return OverviewData(
      totalScreenTime: totalTime,
      averageScreenTime: totalTime,
      screenTimePercentage: 0,
      productiveTime: totalTime,
      productivityScore: 100,
      mostUsedApp: mostUsed,
      focusSessions: 0,
      totalFocusTime: Duration.zero,
      topApplications: applications,
      categoryBreakdown: categoryBreakdown,
      applicationLimits: [],
    );
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
  final bool isProductive;

  ApplicationDetail({
    required this.name,
    required this.category,
    required this.screenTime,
    required this.percentageOfTotalTime,
    required this.isVisible,
    required this.isProductive,
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
