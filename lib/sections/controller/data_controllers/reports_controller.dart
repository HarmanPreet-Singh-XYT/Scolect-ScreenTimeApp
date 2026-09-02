import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/sections/controller/categories_controller.dart';
import 'package:screentime/web/chrome_storage_interop.dart' if (dart.library.io) 'package:screentime/web/chrome_storage_interop_stub.dart';
import 'package:flutter/foundation.dart';
import 'focus_mode_data_controller.dart';
import 'package:screentime/utils/private_mode_access.dart';
import 'package:screentime/utils/date_formats.dart';

// ============================================================
// DATA MODELS
// ============================================================

class AnalyticsSummary {
  final Duration totalScreenTime;
  final double screenTimeComparisonPercent;
  final Duration productiveTime;
  final double productiveTimeComparisonPercent;
  final String mostUsedApp;
  final Duration mostUsedAppTime;
  final int focusSessionsCount;
  final double focusSessionsComparisonPercent;
  final List<DailyScreenTime> dailyScreenTimeData;
  final Map<String, double> categoryBreakdown;
  final List<AppUsageSummary> appUsageDetails;
  final Duration privateAppsTime;

  const AnalyticsSummary({
    required this.totalScreenTime,
    required this.screenTimeComparisonPercent,
    required this.productiveTime,
    required this.productiveTimeComparisonPercent,
    required this.mostUsedApp,
    required this.mostUsedAppTime,
    required this.focusSessionsCount,
    required this.focusSessionsComparisonPercent,
    required this.dailyScreenTimeData,
    required this.categoryBreakdown,
    required this.appUsageDetails,
    this.privateAppsTime = Duration.zero,
  });

  /// Total screen time with private apps' time excluded, for when the
  /// "include private items in totals" setting is off.
  Duration get visibleScreenTime => totalScreenTime - privateAppsTime;

  /// Only the private-tagged app/site entries, for the isolated Private
  /// Mode section's reports view.
  List<AppUsageSummary> get privateAppUsageDetails =>
      appUsageDetails.where((a) => a.isPrivate).toList();
}

class DailyScreenTime {
  final DateTime date;
  final Duration screenTime;

  const DailyScreenTime({required this.date, required this.screenTime});
}

class AppUsageSummary {
  /// Storage key — use for lookups, never for display.
  final String appId;
  final String appName;
  final String siteName;
  final String category;
  final Duration totalTime;
  final bool isProductive;
  final bool isVisible;
  final bool isPrivate;

  const AppUsageSummary({
    required this.appId,
    required this.appName,
    this.siteName = '',
    required this.category,
    required this.totalTime,
    required this.isProductive,
    required this.isVisible,
    this.isPrivate = false,
  });
}

// ============================================================
// INTERNAL: Date range + comparison period bundle
// ============================================================

class _AnalyticsDateRange {
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? comparisonStartDate;
  final DateTime? comparisonEndDate;

  const _AnalyticsDateRange({
    required this.startDate,
    required this.endDate,
    this.comparisonStartDate,
    this.comparisonEndDate,
  });

  bool get hasComparison =>
      comparisonStartDate != null && comparisonEndDate != null;
}

// ============================================================
// ANALYTICS CONTROLLER
// ============================================================

class UsageAnalyticsController extends ChangeNotifier {
  final AppDataStore _dataStore = AppDataStore();

  bool _isLoading = false;
  bool _initialized = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> initialize() async {
    if (_initialized) return true;
    _setLoading(true);
    final bool success = await _dataStore.init();
    _initialized = success;
    _setLoading(false);
    if (!success) _error = _dataStore.lastError;
    return success;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) await initialize();
  }

  // ============================================================
  // PUBLIC API - Simplified with shared _executeAnalytics
  // ============================================================

  Future<AnalyticsSummary> getSpecificDateRangeAnalytics(
    DateTime startDate,
    DateTime endDate, {
    bool compareWithPrevious = true,
  }) async {
    final normalizedStart = _normalizeDate(startDate);
    final normalizedEnd = _normalizeDate(endDate);

    if (normalizedEnd.isBefore(normalizedStart)) {
      throw ArgumentError('End date must be after start date');
    }

    _AnalyticsDateRange range;
    if (compareWithPrevious) {
      final dayCount = normalizedEnd.difference(normalizedStart).inDays + 1;
      final prevEnd = normalizedStart.subtract(const Duration(days: 1));
      final prevStart = prevEnd.subtract(Duration(days: dayCount - 1));
      range = _AnalyticsDateRange(
        startDate: normalizedStart,
        endDate: normalizedEnd,
        comparisonStartDate: prevStart,
        comparisonEndDate: prevEnd,
      );
    } else {
      range = _AnalyticsDateRange(
          startDate: normalizedStart, endDate: normalizedEnd);
    }

    return _executeAnalytics(range, 'specific date range');
  }

  Future<AnalyticsSummary> getSpecificDayAnalytics(
    DateTime date, {
    bool compareWithToday = true,
  }) async {
    final normalizedDate = _normalizeDate(date);
    final today = _today();

    _AnalyticsDateRange range;
    if (compareWithToday && normalizedDate != today) {
      range = _AnalyticsDateRange(
        startDate: normalizedDate,
        endDate: normalizedDate,
        comparisonStartDate: today,
        comparisonEndDate: today,
      );
    } else {
      range = _AnalyticsDateRange(
          startDate: normalizedDate, endDate: normalizedDate);
    }

    return _executeAnalytics(range, 'specific day');
  }

  Future<AnalyticsSummary> getLastSevenDaysAnalytics() async {
    final today = _today();
    final startDate = today.subtract(const Duration(days: 6));
    final prevStart = startDate.subtract(const Duration(days: 7));
    final prevEnd = startDate.subtract(const Duration(days: 1));

    return _executeAnalytics(
      _AnalyticsDateRange(
        startDate: startDate,
        endDate: today,
        comparisonStartDate: prevStart,
        comparisonEndDate: prevEnd,
      ),
      'last seven days',
    );
  }

  Future<AnalyticsSummary> getLastMonthAnalytics() async {
    final today = _today();
    final startDate = DateTime(today.year, today.month - 1, today.day);
    final prevStart =
        DateTime(startDate.year, startDate.month - 1, startDate.day);
    final prevEnd = startDate.subtract(const Duration(days: 1));

    return _executeAnalytics(
      _AnalyticsDateRange(
        startDate: startDate,
        endDate: today,
        comparisonStartDate: prevStart,
        comparisonEndDate: prevEnd,
      ),
      'last month',
    );
  }

  Future<AnalyticsSummary> getLastThreeMonthsAnalytics() async {
    final today = _today();
    final startDate = DateTime(today.year, today.month - 3, today.day);
    final prevStart =
        DateTime(startDate.year, startDate.month - 3, startDate.day);
    final prevEnd = startDate.subtract(const Duration(days: 1));

    return _executeAnalytics(
      _AnalyticsDateRange(
        startDate: startDate,
        endDate: today,
        comparisonStartDate: prevStart,
        comparisonEndDate: prevEnd,
      ),
      'last three months',
    );
  }

  Future<AnalyticsSummary> getLifetimeAnalytics() async {
    await _ensureInitialized();

    final today = _today();
    DateTime earliestDate = today.subtract(const Duration(days: 365));

    // Find earliest recorded data
    for (final appName in _dataStore.allAppNames) {
      for (int i = 365; i >= 0; i--) {
        final checkDate = today.subtract(Duration(days: i));
        if (_dataStore.getAppUsage(appName, checkDate) != null) {
          if (checkDate.isBefore(earliestDate)) {
            earliestDate = checkDate;
          }
          break;
        }
      }
    }

    return _executeAnalytics(
      _AnalyticsDateRange(startDate: earliestDate, endDate: today),
      'lifetime',
    );
  }

  // ============================================================
  // CORE: Single entry point for all analytics computation
  // ============================================================

  Future<AnalyticsSummary> _executeAnalytics(
    _AnalyticsDateRange range,
    String label,
  ) async {
    await _ensureInitialized();
    _setLoading(true);

    try {
      final result = kIsWeb
          ? await _computeWebAnalytics(range)
          : _computeAnalytics(range);
      _setLoading(false);
      return result;
    } catch (e) {
      _setError('Error fetching $label analytics: $e');
      _setLoading(false);
      return _emptyAnalyticsSummary;
    }
  }

  /// OPTIMIZED: Single-pass computation for all analytics data
  AnalyticsSummary _computeAnalytics(_AnalyticsDateRange range) {
    final showPrivate = shouldShowPrivateOnly();
    final includePrivate = shouldIncludePrivateInTotals();

    // ── Collect per-day data in a single date iteration ──
    final dailyScreenTimeData = <DailyScreenTime>[];
    int focusSessionsCount = 0;

    // Per-app accumulators (built during date iteration). Whole-day totals
    // (totalScreenTime, productiveTime) can't be used directly when the
    // titlebar toggle is active — they're not app-scoped — so those are
    // re-derived from appTotalUsage below instead.
    final appTotalUsage = <String, Duration>{};
    final categoryTotalUsage = <String, Duration>{};
    final dailyPrivateUsage = <DateTime, Duration>{};

    final appNames = _dataStore.allAppNames;

    DateTime currentDate = range.startDate;
    while (!currentDate.isAfter(range.endDate)) {
      // Focus sessions (not app-scoped; left as whole-day regardless of toggle)
      focusSessionsCount += _dataStore.getFocusSessionsCount(currentDate);

      // Per-app usage for this day
      for (final appName in appNames) {
        if (appName.startsWith('web:')) continue;
        final record = _dataStore.getAppUsage(appName, currentDate);
        if (record != null && record.timeSpent > Duration.zero) {
          final metadata = _dataStore.getAppMetadata(appName);
          final isPrivate = metadata?.isPrivate ?? false;
          if (isPrivate) {
            dailyPrivateUsage.update(
              currentDate,
              (existing) => existing + record.timeSpent,
              ifAbsent: () => record.timeSpent,
            );
          }
          // Public view: keep matching (public) records, plus private ones
          // when "Include Private Items in Totals" is on. Private-only view
          // (showPrivate): keep only private records, unaffected by the
          // totals setting.
          final keep = showPrivate
              ? isPrivate
              : (!isPrivate || includePrivate);
          if (!keep) continue;

          appTotalUsage.update(
            appName,
            (existing) => existing + record.timeSpent,
            ifAbsent: () => record.timeSpent,
          );

          if (metadata != null) {
            categoryTotalUsage.update(
              metadata.category,
              (existing) => existing + record.timeSpent,
              ifAbsent: () => record.timeSpent,
            );
          }
        }
      }

      // Daily screen time chart series: whole-day total when showing public
      // data — minus private time when the totals setting excludes it — or
      // the private-only subset accumulated above when the toggle is on.
      Duration dayScreenTime;
      if (showPrivate) {
        dayScreenTime = dailyPrivateUsage[currentDate] ?? Duration.zero;
      } else {
        dayScreenTime = _dataStore.getTotalScreenTime(currentDate);
        if (!includePrivate) {
          dayScreenTime -= dailyPrivateUsage[currentDate] ?? Duration.zero;
        }
      }
      dailyScreenTimeData
          .add(DailyScreenTime(date: currentDate, screenTime: dayScreenTime));

      currentDate = currentDate.add(const Duration(days: 1));
    }

    final totalScreenTime = appTotalUsage.values
        .fold(Duration.zero, (sum, d) => sum + d);
    final productiveTime = showPrivate
        ? totalScreenTime
        : _sumProductiveTime(range.startDate, range.endDate);

    // ── Most used app from accumulated totals ──
    String mostUsedApp = 'None';
    Duration mostUsedAppTime = Duration.zero;

    appTotalUsage.forEach((app, duration) {
      if (duration > mostUsedAppTime) {
        mostUsedApp = _dataStore.displayNameFor(app);
        mostUsedAppTime = duration;
      }
    });

    // ── Category breakdown as percentages ──
    final totalCategorySeconds =
        categoryTotalUsage.values.fold<int>(0, (sum, d) => sum + d.inSeconds);
    final categoryBreakdown = <String, double>{};
    if (totalCategorySeconds > 0) {
      categoryTotalUsage.forEach((category, duration) {
        categoryBreakdown[category] =
            (duration.inSeconds / totalCategorySeconds) * 100;
      });
    }

    // ── App usage details sorted by time ──
    final appUsageDetails = <AppUsageSummary>[];
    appTotalUsage.forEach((appId, totalTime) {
      final metadata = _dataStore.getAppMetadata(appId);
      appUsageDetails.add(AppUsageSummary(
        appId: appId,
        appName: _dataStore.displayNameFor(appId),
        siteName: metadata?.siteName ?? '',
        category: metadata?.category ?? 'Uncategorized',
        totalTime: totalTime,
        isProductive: metadata?.isProductive ?? false,
        isVisible: metadata?.isVisible ?? false,
        isPrivate: metadata?.isPrivate ?? false,
      ));
    });
    appUsageDetails.sort((a, b) => b.totalTime.compareTo(a.totalTime));
    final privateAppsTime =
        dailyPrivateUsage.values.fold(Duration.zero, (sum, d) => sum + d);

    // ── Comparison period (if any) ──
    double screenTimeComparisonPercent = 0;
    double productiveTimeComparisonPercent = 0;
    double focusSessionsComparisonPercent = 0;

    if (range.hasComparison && !showPrivate) {
      final compData = _computeComparisonData(
        range.comparisonStartDate!,
        range.comparisonEndDate!,
      );
      screenTimeComparisonPercent = _percentageChange(
          totalScreenTime.inMinutes, compData.totalScreenTime.inMinutes);
      productiveTimeComparisonPercent = _percentageChange(
          productiveTime.inMinutes, compData.productiveTime.inMinutes);
      focusSessionsComparisonPercent =
          _percentageChange(focusSessionsCount, compData.focusSessionsCount);
    }

    return AnalyticsSummary(
      totalScreenTime: totalScreenTime,
      screenTimeComparisonPercent: screenTimeComparisonPercent,
      productiveTime: productiveTime,
      productiveTimeComparisonPercent: productiveTimeComparisonPercent,
      mostUsedApp: mostUsedApp,
      mostUsedAppTime: mostUsedAppTime,
      focusSessionsCount: focusSessionsCount,
      focusSessionsComparisonPercent: focusSessionsComparisonPercent,
      dailyScreenTimeData: dailyScreenTimeData,
      categoryBreakdown: categoryBreakdown,
      appUsageDetails: appUsageDetails,
      privateAppsTime: privateAppsTime,
    );
  }

  /// Sum of per-day productive time across the range — kept as a whole-day
  /// aggregate for the public view (matches existing behavior). Not used
  /// when [shouldShowPrivateOnly] is true; the private view derives
  /// productiveTime from the private-only appTotalUsage sum instead, since
  /// "productive" is a per-app property and the whole-day store total can't
  /// be split into private/public without per-app data.
  Duration _sumProductiveTime(DateTime start, DateTime end) {
    Duration total = Duration.zero;
    DateTime d = start;
    while (!d.isAfter(end)) {
      total += _dataStore.getProductiveTime(d);
      d = d.add(const Duration(days: 1));
    }
    return total;
  }

  /// Lightweight comparison data — only computes what's needed for % change
  _ComparisonData _computeComparisonData(DateTime startDate, DateTime endDate) {
    Duration totalScreenTime = Duration.zero;
    Duration productiveTime = Duration.zero;
    int focusSessionsCount = 0;

    DateTime currentDate = startDate;
    while (!currentDate.isAfter(endDate)) {
      totalScreenTime += _dataStore.getTotalScreenTime(currentDate);
      productiveTime += _dataStore.getProductiveTime(currentDate);
      focusSessionsCount += _dataStore.getFocusSessionsCount(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return _ComparisonData(
      totalScreenTime: totalScreenTime,
      productiveTime: productiveTime,
      focusSessionsCount: focusSessionsCount,
    );
  }

  Future<AnalyticsSummary> _computeWebAnalytics(_AnalyticsDateRange range) async {
    final showPrivate = shouldShowPrivateOnly();
    final includePrivate = shouldIncludePrivateInTotals();
    final metaRes = await chromeStorageGet(['scolect_app_metadata', 'scolect_settings']);
    final siteMeta = (metaRes['scolect_app_metadata'] as Map<dynamic, dynamic>?) ?? {};
    final settingsMap = (metaRes['scolect_settings'] as Map<dynamic, dynamic>?) ?? {};
    final customMeta = (settingsMap['metadata'] as Map<dynamic, dynamic>?) ?? {};

    bool isPrivateDomain(String domain) {
      final meta = (customMeta[domain] as Map<dynamic, dynamic>?) ?? {};
      return meta['isPrivate'] as bool? ?? false;
    }

    final dailyScreenTimeData = <DailyScreenTime>[];
    Duration totalScreenTime = Duration.zero;
    Duration privateAppsTime = Duration.zero;
    final domainTotals = <String, int>{};
    final categoryTotals = <String, int>{};

    DateTime currentDate = range.startDate;
    while (!currentDate.isAfter(range.endDate)) {
      final dateKey = '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
      final storageKey = 'scolect_day_$dateKey';
      final dayRes = await chromeStorageGet([storageKey]);
      final dayData = dayRes[storageKey] as Map<dynamic, dynamic>? ?? {};
      final domains = (dayData['domains'] as List<dynamic>?) ?? [];

      int dayScopedSeconds = 0;
      for (var d in domains) {
        final domain = d['domain'] as String? ?? 'unknown';
        final secs = (d['seconds'] as num? ?? 0).toInt();

        final isPrivate = isPrivateDomain(domain);
        if (isPrivate) privateAppsTime += Duration(seconds: secs);

        // Public view: count matching (public) domains, plus private ones
        // when "Include Private Items in Totals" is on. Private-only view
        // (showPrivate): count only private domains, unaffected by the
        // totals setting.
        final keep = showPrivate ? isPrivate : (!isPrivate || includePrivate);
        if (!keep) continue;

        dayScopedSeconds += secs;
        domainTotals[domain] = (domainTotals[domain] ?? 0) + secs;

        final meta = (customMeta[domain] as Map<dynamic, dynamic>?) ?? {};
        final rawSiteMeta = (siteMeta[domain] as Map<dynamic, dynamic>?) ?? {};
        final siteName = (meta['siteName'] as String?)?.isNotEmpty == true
            ? meta['siteName'] as String
            : (rawSiteMeta['siteName'] as String? ?? '');
        final displayName = siteName.isNotEmpty ? siteName : domain;
        final rawCat = (meta['category'] as String?)?.isNotEmpty == true
            ? meta['category'] as String
            : (rawSiteMeta['category'] as String? ?? '');
        final category = (rawCat.isNotEmpty && rawCat != 'Uncategorized')
            ? rawCat
            : AppCategories.categorizeApp(displayName);

        categoryTotals[category] = (categoryTotals[category] ?? 0) + secs;
      }

      totalScreenTime += Duration(seconds: dayScopedSeconds);
      dailyScreenTimeData.add(DailyScreenTime(
          date: currentDate, screenTime: Duration(seconds: dayScopedSeconds)));
      currentDate = currentDate.add(const Duration(days: 1));
    }

    String mostUsedApp = 'None';
    int maxSecs = 0;
    domainTotals.forEach((domain, secs) {
      if (secs > maxSecs) {
        maxSecs = secs;
        final meta = (customMeta[domain] as Map<dynamic, dynamic>?) ?? {};
        final rawSiteMeta = (siteMeta[domain] as Map<dynamic, dynamic>?) ?? {};
        final siteName = (meta['siteName'] as String?)?.isNotEmpty == true
            ? meta['siteName'] as String
            : (rawSiteMeta['siteName'] as String? ?? '');
        mostUsedApp = siteName.isNotEmpty ? siteName : domain;
      }
    });

    final totalSecs = totalScreenTime.inSeconds;
    final categoryBreakdown = <String, double>{};
    if (totalSecs > 0) {
      categoryTotals.forEach((category, secs) {
        categoryBreakdown[category] = (secs / totalSecs) * 100;
      });
    }

    final appUsageDetails = <AppUsageSummary>[];
    domainTotals.forEach((domain, secs) {
      final meta = (customMeta[domain] as Map<dynamic, dynamic>?) ?? {};
      final rawSiteMeta = (siteMeta[domain] as Map<dynamic, dynamic>?) ?? {};
      final siteName = (meta['siteName'] as String?)?.isNotEmpty == true
          ? meta['siteName'] as String
          : (rawSiteMeta['siteName'] as String? ?? '');
      final displayName = siteName.isNotEmpty ? siteName : domain;
      final rawCat = (meta['category'] as String?)?.isNotEmpty == true
          ? meta['category'] as String
          : (rawSiteMeta['category'] as String? ?? '');
      final category = (rawCat.isNotEmpty && rawCat != 'Uncategorized')
          ? rawCat
          : AppCategories.categorizeApp(displayName);

      appUsageDetails.add(AppUsageSummary(
        appId: domain,
        appName: domain,
        siteName: siteName,
        category: category,
        totalTime: Duration(seconds: secs),
        isProductive: meta['isProductive'] as bool? ?? false,
        isVisible: true,
        isPrivate: isPrivateDomain(domain),
      ));
    });

    appUsageDetails.sort((a, b) => b.totalTime.compareTo(a.totalTime));

    return AnalyticsSummary(
      totalScreenTime: totalScreenTime,
      screenTimeComparisonPercent: 0,
      productiveTime: totalScreenTime,
      productiveTimeComparisonPercent: 0,
      mostUsedApp: mostUsedApp,
      mostUsedAppTime: Duration(seconds: maxSecs),
      focusSessionsCount: 0,
      focusSessionsComparisonPercent: 0,
      dailyScreenTimeData: dailyScreenTimeData,
      categoryBreakdown: categoryBreakdown,
      appUsageDetails: appUsageDetails,
      privateAppsTime: privateAppsTime,
    );
  }

  // ============================================================
  // UTILITY
  // ============================================================

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _today() {
    return SettingsManager().getLogicalDate(DateTime.now());
  }

  double _percentageChange(num current, num previous) {
    if (previous == 0) return 0;
    return ((current - previous) / previous) * 100;
  }

  // Keep public for external callers
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  double calculatePercentageChange(num current, num previous) =>
      _percentageChange(current, previous);

  static const _emptyAnalyticsSummary = AnalyticsSummary(
    totalScreenTime: Duration.zero,
    screenTimeComparisonPercent: 0,
    productiveTime: Duration.zero,
    productiveTimeComparisonPercent: 0,
    mostUsedApp: 'None',
    mostUsedAppTime: Duration.zero,
    focusSessionsCount: 0,
    focusSessionsComparisonPercent: 0,
    dailyScreenTimeData: [],
    categoryBreakdown: {},
    appUsageDetails: [],
  );

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    debugPrint('UsageAnalyticsController Error: $_error');
    notifyListeners();
  }
}

/// Minimal struct for comparison period data
class _ComparisonData {
  final Duration totalScreenTime;
  final Duration productiveTime;
  final int focusSessionsCount;

  const _ComparisonData({
    required this.totalScreenTime,
    required this.productiveTime,
    required this.focusSessionsCount,
  });
}

// ============================================================
// FOCUS MODE ANALYTICS - OPTIMIZED
// ============================================================

class FocusModeAnalytics {
  final FocusAnalyticsService _analyticsService = FocusAnalyticsService();

  Map<String, dynamic> getLastSevenDaysData({DateTime? endDate}) {
    final now = endDate ?? SettingsManager().getLogicalDate(DateTime.now());
    return _getPeriodData(
      startDate: now.subtract(const Duration(days: 6)),
      endDate: now,
    );
  }

  Map<String, dynamic> getLastMonthData({DateTime? endDate}) {
    final now = endDate ?? SettingsManager().getLogicalDate(DateTime.now());
    return _getPeriodData(
      startDate: now.subtract(const Duration(days: 29)),
      endDate: now,
    );
  }

  Map<String, dynamic> getLastThreeMonthsData({DateTime? endDate}) {
    final now = endDate ?? SettingsManager().getLogicalDate(DateTime.now());
    return _getPeriodData(
      startDate: now.subtract(const Duration(days: 89)),
      endDate: now,
    );
  }

  Map<String, dynamic> getLifetimeData() {
    final now = SettingsManager().getLogicalDate(DateTime.now());
    return _getPeriodData(
      startDate: now.subtract(const Duration(days: 365)),
      endDate: now,
    );
  }

  Map<String, dynamic> _getPeriodData({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final sessionsByDay = _analyticsService.getSessionCountByDay(
      startDate: startDate,
      endDate: endDate,
    );

    final timeDistribution = _analyticsService.getTimeDistribution(
      startDate: startDate,
      endDate: endDate,
    );

    final sessions = _analyticsService.getSessionHistory(
      startDate: startDate,
      endDate: endDate,
    );

    // ── Single pass through sessionsByDay for totals + most productive ──
    int totalSessions = 0;
    String mostProductiveDay = 'None';
    int maxSessions = 0;

    sessionsByDay.forEach((day, count) {
      totalSessions += count;
      if (count > maxSessions) {
        maxSessions = count;
        mostProductiveDay = day;
      }
    });

    if (mostProductiveDay != 'None') {
      try {
        mostProductiveDay = AppDateFormat.weekdayFull(
            AppDateFormat.parseIsoDate(mostProductiveDay));
      } catch (e) {
        debugPrint('Error formatting most productive day: $e');
      }
    }

    // ── Single pass through sessions for total focus time ──
    int totalFocusMinutes = 0;
    for (final session in sessions) {
      final duration = session['duration'];
      if (duration is int) {
        totalFocusMinutes += duration;
      }
    }
    final totalFocusTime = Duration(minutes: totalFocusMinutes);

    final daysInPeriod = endDate.difference(startDate).inDays + 1;

    return {
      'periodStart': startDate,
      'periodEnd': endDate,
      'totalSessions': totalSessions,
      'avgDailySessions': totalSessions / daysInPeriod,
      'mostProductiveDay': mostProductiveDay,
      'sessionsByDay': sessionsByDay,
      'timeDistribution': timeDistribution,
      'sessions': sessions,
      'totalFocusTime': totalFocusTime,
      'avgSessionLength': totalSessions > 0
          ? Duration(minutes: totalFocusMinutes ~/ totalSessions)
          : Duration.zero,
      'currentStreak': _calculateCurrentStreak(sessionsByDay, endDate),
      'daysInPeriod': daysInPeriod,
    };
  }

  int _calculateCurrentStreak(
      Map<String, int> sessionsByDay, DateTime endDate) {
    int streak = 0;
    DateTime currentDate = endDate;

    while (true) {
      final dateStr = AppDateFormat.isoDate(currentDate);
      final count = sessionsByDay[dateStr];

      if (count != null && count > 0) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}
