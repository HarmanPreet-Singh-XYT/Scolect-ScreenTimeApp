import 'package:flutter/foundation.dart';
import '../app_data_controller.dart';
import '../settings_data_controller.dart';
import '../../../web/web_browser_data_provider.dart' if (dart.library.io) '../../../web/web_browser_data_provider_stub.dart';
import '../../../utils/private_mode_access.dart';

class AppUsageSummary {
  /// Storage key — use for lookups/limit/category updates, never for display.
  final String appId;
  /// Human-readable label — use for anything shown to the user.
  final String appName;
  final String siteName;
  final String category;
  final Duration dailyLimit;
  final Duration currentUsage;
  final bool limitStatus;
  final bool isProductive;
  final bool isAboutToReachLimit;
  final double percentageOfLimitUsed;
  final UsageTrend trend;
  final bool isPrivate;

  const AppUsageSummary({
    required this.appId,
    required this.appName,
    this.siteName = '',
    required this.category,
    required this.dailyLimit,
    required this.currentUsage,
    required this.limitStatus,
    required this.isProductive,
    required this.isAboutToReachLimit,
    required this.percentageOfLimitUsed,
    required this.trend,
    this.isPrivate = false,
  });

  factory AppUsageSummary.fromJson(Map<String, dynamic> json) {
    return AppUsageSummary(
      appId: json['appId'] as String? ?? json['appName'] as String,
      appName: json['appName'] as String,
      siteName: json['siteName'] as String? ?? '',
      category: json['category'] as String,
      dailyLimit: Duration(seconds: json['dailyLimit'] as int),
      currentUsage: Duration(seconds: json['currentUsage'] as int),
      limitStatus: json['limitStatus'] as bool,
      isProductive: json['isProductive'] as bool,
      isAboutToReachLimit: json['isAboutToReachLimit'] as bool,
      percentageOfLimitUsed: (json['percentageOfLimitUsed'] as num).toDouble(),
      trend: _trendFromString[json['trend']] ?? UsageTrend.noData,
      isPrivate: json['isPrivate'] as bool? ?? false,
    );
  }

  static const _trendFromString = {
    'UsageTrend.increasing': UsageTrend.increasing,
    'UsageTrend.decreasing': UsageTrend.decreasing,
    'UsageTrend.stable': UsageTrend.stable,
    'UsageTrend.noData': UsageTrend.noData,
  };

  Map<String, dynamic> toJson() => {
        'appId': appId,
        'appName': appName,
        'siteName': siteName,
        'category': category,
        'dailyLimit': dailyLimit.inSeconds,
        'currentUsage': currentUsage.inSeconds,
        'limitStatus': limitStatus,
        'isProductive': isProductive,
        'isAboutToReachLimit': isAboutToReachLimit,
        'percentageOfLimitUsed': percentageOfLimitUsed,
        'trend': trend.toString(),
        'isPrivate': isPrivate,
      };
}

enum UsageTrend { increasing, decreasing, stable, noData }

class ScreenTimeDataController extends ChangeNotifier {
  static final ScreenTimeDataController _instance =
      ScreenTimeDataController._internal();
  factory ScreenTimeDataController() => _instance;
  ScreenTimeDataController._internal() {
    _loadOverallLimitFromStorage();
  }

  final AppDataStore _dataStore = AppDataStore();

  static const _overallEnabledKey = 'limitsAlerts.overallLimit.enabled';
  static const _overallHoursKey = 'limitsAlerts.overallLimit.hours';
  static const _overallMinutesKey = 'limitsAlerts.overallLimit.minutes';

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

  Duration getOverallUsage() =>
      _dataStore.getTotalScreenTime(SettingsManager().getLogicalDate(DateTime.now()));

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

  void _loadOverallLimitFromStorage() {
    final settings = SettingsManager();
    final enabled = settings.getSetting(_overallEnabledKey) as bool? ?? false;
    final hours = (settings.getSetting(_overallHoursKey) as num?)?.toInt() ?? 0;
    final minutes =
        (settings.getSetting(_overallMinutesKey) as num?)?.toInt() ?? 0;
    _overallLimitEnabled = enabled;
    _overallLimit = Duration(hours: hours, minutes: minutes);
  }

  void _saveOverallLimitToStorage() {
    final settings = SettingsManager();
    settings.updateSetting(_overallEnabledKey, _overallLimitEnabled);
    settings.updateSetting(_overallHoursKey, _overallLimit.inHours);
    settings.updateSetting(_overallMinutesKey, _overallLimit.inMinutes % 60);
  }

  // ============================================================
  // APP SUMMARIES - OPTIMIZED WITH CACHING
  // ============================================================

  void _invalidateSummaryCache() {
    _cachedSummaries = null;
    _cachedSummariesTimestamp = null;
  }

  Future<List<AppUsageSummary>> getAllAppsSummary() async {
    final now = DateTime.now();
    if (_cachedSummaries != null &&
        _cachedSummariesTimestamp != null &&
        now.difference(_cachedSummariesTimestamp!).inMilliseconds <
            _cacheValidityMs) {
      return _cachedSummaries!;
    }

    _cachedSummaries = await _buildAppSummaries(now);
    _cachedSummariesTimestamp = now;
    return _cachedSummaries!;
  }

  AppUsageSummary? getAppSummary(String appId) {
    final metadata = _dataStore.getAppMetadata(appId);
    if (metadata == null) return null;

    final todayUsage = _dataStore.getAppUsage(
        appId, SettingsManager().getLogicalDate(DateTime.now()));
    return _createAppSummary(
      appId: appId,
      metadata: metadata,
      currentUsage: todayUsage?.timeSpent ?? Duration.zero,
    );
  }

  Future<List<AppUsageSummary>> getAppsWithLimits() async {
    final summaries = await getAllAppsSummary();
    final apps = summaries.where((app) => app.limitStatus).toList();
    apps.sort(
        (a, b) => b.percentageOfLimitUsed.compareTo(a.percentageOfLimitUsed));
    return apps;
  }

  Future<List<AppUsageSummary>> getAppsNearLimit({double threshold = 0.8}) async =>
      (await getAppsWithLimits())
          .where((app) => app.percentageOfLimitUsed >= threshold)
          .toList();

  Future<List<AppUsageSummary>> getAppsExceededLimit() async => (await getAppsWithLimits())
      .where((app) => app.percentageOfLimitUsed >= 1.0)
      .toList();

  // ============================================================
  // APP LIMIT MANAGEMENT
  // ============================================================

  Future<bool> updateAppLimit(
      String appId, Duration limit, bool enableLimit) async {
    final result = await _dataStore.updateAppMetadata(
      appId,
      dailyLimit: limit,
      limitStatus: enableLimit,
    );
    if (result) _invalidateSummaryCache();
    return result;
  }

  Future<bool> updateAppCategory(
      String appId, String category, bool isProductive) async {
    final result = await _dataStore.updateAppMetadata(
      appId,
      category: category,
      isProductive: isProductive,
    );
    if (result) _invalidateSummaryCache();
    return result;
  }

  // ============================================================
  // ANALYTICS - OPTIMIZED: Single pass for category aggregation
  // ============================================================

  Future<Map<String, Duration>> getUsageByCategory() async {
    final result = <String, Duration>{};
    final summaries = await getAllAppsSummary();
    for (final app in summaries) {
      result.update(
        app.category,
        (existing) => existing + app.currentUsage,
        ifAbsent: () => app.currentUsage,
      );
    }
    return result;
  }

  Future<List<AppUsageSummary>> getMostUsedApps({int limit = 5}) async {
    final apps = await getAllAppsSummary();
    apps.sort((a, b) => b.currentUsage.compareTo(a.currentUsage));
    return apps.take(limit).toList();
  }

  Future<Map<String, dynamic>> getAllData() async {
    final appSummaries = await getAllAppsSummary();
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

  Future<List<AppUsageSummary>> _buildAppSummaries(DateTime today) async {
    List<AppUsageSummary> result;

    if (kIsWeb) {
      final webSites = await WebBrowserDataProvider().fetchAllWebsites();
      result = <AppUsageSummary>[];
      for (final site in webSites) {
        final hasActiveLimit = site.dailyLimit > Duration.zero;
        double percentOfLimit = 0.0;
        bool isApproaching = false;
        if (hasActiveLimit) {
          percentOfLimit = site.timeSpent.inSeconds / site.dailyLimit.inSeconds;
          final remaining = site.dailyLimit - site.timeSpent;
          isApproaching = remaining > Duration.zero && remaining <= const Duration(minutes: 5);
        }
        result.add(AppUsageSummary(
          appId: site.domain,
          appName: site.domain,
          siteName: site.siteName,
          category: site.category,
          dailyLimit: site.dailyLimit,
          currentUsage: site.timeSpent,
          limitStatus: site.dailyLimit > Duration.zero,
          isProductive: site.isProductive,
          isAboutToReachLimit: isApproaching,
          percentageOfLimitUsed: percentOfLimit,
          trend: UsageTrend.stable,
          isPrivate: site.isPrivate,
        ));
      }
    } else {
      final appNames = _dataStore.allAppNames;
      result = <AppUsageSummary>[];

      for (final appId in appNames) {
        if (appId.startsWith('web:')) continue;
        final metadata = _dataStore.getAppMetadata(appId);
        if (metadata == null || !metadata.isVisible) continue;

        final todayUsage = _dataStore.getAppUsage(appId, today);

        result.add(_createAppSummary(
          appId: appId,
          metadata: metadata,
          currentUsage: todayUsage?.timeSpent ?? Duration.zero,
        ));
      }
    }

    final showPrivate = shouldShowPrivateOnly();
    result.removeWhere((s) => s.isPrivate != showPrivate);

    return result;
  }

  AppUsageSummary _createAppSummary({
    required String appId,
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
      appId: appId,
      appName: _dataStore.displayNameFor(appId),
      siteName: metadata.siteName,
      category: metadata.category,
      dailyLimit: metadata.dailyLimit,
      currentUsage: currentUsage,
      limitStatus: metadata.limitStatus,
      isProductive: metadata.isProductive,
      isAboutToReachLimit: isApproachingLimit,
      percentageOfLimitUsed: percentOfLimit,
      trend: _calculateUsageTrend(appId),
      isPrivate: metadata.isPrivate,
    );
  }

  UsageTrend _calculateUsageTrend(String appId) {
    final today = SettingsManager().getLogicalDate(DateTime.now());
    final weekAgo = today.subtract(const Duration(days: 7));

    final weekUsage = _dataStore.getAppUsageRange(
      appId,
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
