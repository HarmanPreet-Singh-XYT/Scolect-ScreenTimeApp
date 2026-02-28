import 'package:flutter/foundation.dart';
import '../app_data_controller.dart';

class AppUsageSummary {
  final String appName;
  final String category;
  final Duration dailyLimit;
  final Duration currentUsage;
  final bool limitStatus;
  final bool isProductive;
  final bool isAboutToReachLimit;
  final double percentageOfLimitUsed;
  final UsageTrend trend;

  const AppUsageSummary({
    required this.appName,
    required this.category,
    required this.dailyLimit,
    required this.currentUsage,
    required this.limitStatus,
    required this.isProductive,
    required this.isAboutToReachLimit,
    required this.percentageOfLimitUsed,
    required this.trend,
  });

  factory AppUsageSummary.fromJson(Map<String, dynamic> json) {
    return AppUsageSummary(
      appName: json['appName'] as String,
      category: json['category'] as String,
      dailyLimit: Duration(seconds: json['dailyLimit'] as int),
      currentUsage: Duration(seconds: json['currentUsage'] as int),
      limitStatus: json['limitStatus'] as bool,
      isProductive: json['isProductive'] as bool,
      isAboutToReachLimit: json['isAboutToReachLimit'] as bool,
      percentageOfLimitUsed: (json['percentageOfLimitUsed'] as num).toDouble(),
      trend: _trendFromString[json['trend']] ?? UsageTrend.noData,
    );
  }

  static const _trendFromString = {
    'UsageTrend.increasing': UsageTrend.increasing,
    'UsageTrend.decreasing': UsageTrend.decreasing,
    'UsageTrend.stable': UsageTrend.stable,
    'UsageTrend.noData': UsageTrend.noData,
  };

  Map<String, dynamic> toJson() => {
        'appName': appName,
        'category': category,
        'dailyLimit': dailyLimit.inSeconds,
        'currentUsage': currentUsage.inSeconds,
        'limitStatus': limitStatus,
        'isProductive': isProductive,
        'isAboutToReachLimit': isAboutToReachLimit,
        'percentageOfLimitUsed': percentageOfLimitUsed,
        'trend': trend.toString(),
      };
}

enum UsageTrend { increasing, decreasing, stable, noData }

class ScreenTimeDataController extends ChangeNotifier {
  static final ScreenTimeDataController _instance =
      ScreenTimeDataController._internal();
  factory ScreenTimeDataController() => _instance;
  ScreenTimeDataController._internal();

  final AppDataStore _dataStore = AppDataStore();

  Duration _overallLimit = Duration.zero;
  bool _overallLimitEnabled = false;

  // Cache for app summaries to avoid redundant rebuilds within the same frame
  List<AppUsageSummary>? _cachedSummaries;
  DateTime? _cachedSummariesTimestamp;
  static const _cacheValidityMs = 1000; // 1 second cache

  Future<bool> initialize() => _dataStore.init();

  // ============================================================
  // OVERALL LIMIT MANAGEMENT
  // ============================================================

  void updateOverallLimit(Duration limit, bool enabled) {
    if (_overallLimit == limit && _overallLimitEnabled == enabled) return;
    _overallLimit = limit;
    _overallLimitEnabled = enabled;
    _invalidateSummaryCache();
    _saveOverallLimitToStorage();
    notifyListeners();
  }

  Duration get overallLimit => _overallLimit;
  bool get overallLimitEnabled => _overallLimitEnabled;

  Duration getOverallUsage() => _dataStore.getTotalScreenTime(DateTime.now());

  bool get isOverallLimitReached {
    if (!_overallLimitEnabled || _overallLimit == Duration.zero) return false;
    return getOverallUsage() >= _overallLimit;
  }

  double getOverallLimitPercentage() {
    if (!_overallLimitEnabled || _overallLimit.inSeconds == 0) return 0.0;
    return (getOverallUsage().inSeconds / _overallLimit.inSeconds)
        .clamp(0.0, 1.0);
  }

  bool isApproachingOverallLimit(
      {Duration threshold = const Duration(minutes: 15)}) {
    if (!_overallLimitEnabled || _overallLimit == Duration.zero) return false;
    final remaining = _overallLimit - getOverallUsage();
    return remaining > Duration.zero && remaining <= threshold;
  }

  void _saveOverallLimitToStorage() {
    debugPrint(
        'Saving overall limit: enabled=$_overallLimitEnabled, limit=$_overallLimit');
  }

  // ============================================================
  // APP SUMMARIES - OPTIMIZED WITH CACHING
  // ============================================================

  void _invalidateSummaryCache() {
    _cachedSummaries = null;
    _cachedSummariesTimestamp = null;
  }

  List<AppUsageSummary> getAllAppsSummary() {
    final now = DateTime.now();
    if (_cachedSummaries != null &&
        _cachedSummariesTimestamp != null &&
        now.difference(_cachedSummariesTimestamp!).inMilliseconds <
            _cacheValidityMs) {
      return _cachedSummaries!;
    }

    _cachedSummaries = _buildAppSummaries(now);
    _cachedSummariesTimestamp = now;
    return _cachedSummaries!;
  }

  AppUsageSummary? getAppSummary(String appName) {
    final metadata = _dataStore.getAppMetadata(appName);
    if (metadata == null) return null;

    final todayUsage = _dataStore.getAppUsage(appName, DateTime.now());
    return _createAppSummary(
      appName: appName,
      metadata: metadata,
      currentUsage: todayUsage?.timeSpent ?? Duration.zero,
    );
  }

  List<AppUsageSummary> getAppsWithLimits() {
    final apps = getAllAppsSummary().where((app) => app.limitStatus).toList();
    apps.sort(
        (a, b) => b.percentageOfLimitUsed.compareTo(a.percentageOfLimitUsed));
    return apps;
  }

  List<AppUsageSummary> getAppsNearLimit({double threshold = 0.8}) =>
      getAppsWithLimits()
          .where((app) => app.percentageOfLimitUsed >= threshold)
          .toList();

  List<AppUsageSummary> getAppsExceededLimit() => getAppsWithLimits()
      .where((app) => app.percentageOfLimitUsed >= 1.0)
      .toList();

  // ============================================================
  // APP LIMIT MANAGEMENT
  // ============================================================

  Future<bool> updateAppLimit(
      String appName, Duration limit, bool enableLimit) async {
    final result = await _dataStore.updateAppMetadata(
      appName,
      dailyLimit: limit,
      limitStatus: enableLimit,
    );
    if (result) _invalidateSummaryCache();
    return result;
  }

  Future<bool> updateAppCategory(
      String appName, String category, bool isProductive) async {
    final result = await _dataStore.updateAppMetadata(
      appName,
      category: category,
      isProductive: isProductive,
    );
    if (result) _invalidateSummaryCache();
    return result;
  }

  // ============================================================
  // ANALYTICS - OPTIMIZED: Single pass for category aggregation
  // ============================================================

  Map<String, Duration> getUsageByCategory() {
    final result = <String, Duration>{};
    for (final app in getAllAppsSummary()) {
      result.update(
        app.category,
        (existing) => existing + app.currentUsage,
        ifAbsent: () => app.currentUsage,
      );
    }
    return result;
  }

  List<AppUsageSummary> getMostUsedApps({int limit = 5}) {
    final apps = getAllAppsSummary();
    apps.sort((a, b) => b.currentUsage.compareTo(a.currentUsage));
    return apps.take(limit).toList();
  }

  Map<String, dynamic> getAllData() {
    final appSummaries = getAllAppsSummary();
    final overallUsage = getOverallUsage();

    // Compute category usage and most-used in a single pass
    final usageByCategory = <String, Duration>{};
    final sortedByUsage = List<AppUsageSummary>.from(appSummaries);

    for (final app in appSummaries) {
      usageByCategory.update(
        app.category,
        (existing) => existing + app.currentUsage,
        ifAbsent: () => app.currentUsage,
      );
    }

    sortedByUsage.sort((a, b) => b.currentUsage.compareTo(a.currentUsage));
    final mostUsedApps = sortedByUsage.take(5);

    return {
      'appSummaries': appSummaries.map((s) => s.toJson()).toList(),
      'usageByCategory':
          usageByCategory.map((key, value) => MapEntry(key, value.inSeconds)),
      'mostUsedApps': mostUsedApps.map((app) => app.toJson()).toList(),
      'overallUsageSeconds': overallUsage.inSeconds,
      'overallLimitSeconds': _overallLimit.inSeconds,
      'overallLimitEnabled': _overallLimitEnabled,
      'overallLimitPercentage': getOverallLimitPercentage(),
    };
  }

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

  List<AppUsageSummary> _buildAppSummaries(DateTime today) {
    final appNames = _dataStore.allAppNames;
    final result = <AppUsageSummary>[];

    for (final appName in appNames) {
      final metadata = _dataStore.getAppMetadata(appName);
      if (metadata == null || !metadata.isVisible) continue;

      final todayUsage = _dataStore.getAppUsage(appName, today);

      result.add(_createAppSummary(
        appName: appName,
        metadata: metadata,
        currentUsage: todayUsage?.timeSpent ?? Duration.zero,
      ));
    }

    return result;
  }

  AppUsageSummary _createAppSummary({
    required String appName,
    required AppMetadata metadata,
    required Duration currentUsage,
  }) {
    final hasActiveLimit =
        metadata.limitStatus && metadata.dailyLimit > Duration.zero;

    double percentOfLimit = 0.0;
    bool isApproachingLimit = false;

    if (hasActiveLimit) {
      percentOfLimit = currentUsage.inSeconds / metadata.dailyLimit.inSeconds;
      final remaining = metadata.dailyLimit - currentUsage;
      isApproachingLimit =
          remaining > Duration.zero && remaining <= const Duration(minutes: 5);
    }

    return AppUsageSummary(
      appName: appName,
      category: metadata.category,
      dailyLimit: metadata.dailyLimit,
      currentUsage: currentUsage,
      limitStatus: metadata.limitStatus,
      isProductive: metadata.isProductive,
      isAboutToReachLimit: isApproachingLimit,
      percentageOfLimitUsed: percentOfLimit,
      trend: _calculateUsageTrend(appName),
    );
  }

  UsageTrend _calculateUsageTrend(String appName) {
    final today = DateTime.now();
    final weekAgo = today.subtract(const Duration(days: 7));

    final weekUsage = _dataStore.getAppUsageRange(
      appName,
      weekAgo,
      today.subtract(const Duration(days: 1)),
    );

    if (weekUsage.length < 3) return UsageTrend.noData;

    // Calculate average change using first and last directly (O(1) vs O(n))
    // For trend detection, the net change divided by periods is equivalent
    final firstSeconds = weekUsage.first.timeSpent.inSeconds;
    final lastSeconds = weekUsage.last.timeSpent.inSeconds;
    final avgChangeSeconds =
        (lastSeconds - firstSeconds) / (weekUsage.length - 1);

    if (avgChangeSeconds > 300) return UsageTrend.increasing;
    if (avgChangeSeconds < -300) return UsageTrend.decreasing;
    return UsageTrend.stable;
  }
}
