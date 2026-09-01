import '../app_data_controller.dart';
import '../settings_data_controller.dart';
import '../categories_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screentime/web/chrome_storage_interop.dart'
    if (dart.library.io) 'package:screentime/web/chrome_storage_interop_stub.dart';
import 'package:screentime/utils/private_mode_access.dart';

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
    // When the titlebar toggle has switched the view to private-only,
    // delegate to the fully-rescoped private variant so aggregate stats
    // (totalScreenTime, categoryBreakdown, applicationLimits) reflect the
    // private subset too, not just the topApplications list.
    if (shouldShowPrivateOnly()) return fetchTodayPrivateOverview();
    if (kIsWeb) return _fetchWebOverview();
    await _ensureInitialized();

    final DateTime today = SettingsManager().getLogicalDate(DateTime.now());
    final DateTime weekAgo = today.subtract(const Duration(days: 7));

    // Pre-fetch shared values once
    final Duration rawTodayScreenTime = _dataStore.getTotalScreenTime(today);
    final Duration averageWeekScreenTime =
        _dataStore.getAverageScreenTime(weekAgo, today);
    final Duration todayProductiveTime = _dataStore.getProductiveTime(today);
    final double todayProductivityScore =
        _dataStore.getProductivityScore(today);
    final String mostUsedAppId = _dataStore.getMostUsedApp(today);
    final String mostUsedApp = mostUsedAppId == "None"
        ? mostUsedAppId
        : _dataStore.displayNameFor(mostUsedAppId);
    final int focusSessionsCount = _dataStore.getFocusSessionsCount(today);
    final Duration totalFocusTime = _dataStore.getTotalFocusTime(today);

    // ── OPTIMIZED: Single pass builds all three lists simultaneously ──
    final result = _buildAllAppData(today, rawTodayScreenTime);

    // Filter the visible top-applications and limits lists to the current
    // view — private items are never shown by name/identity outside the
    // private-only view, independent of the totals setting.
    final showPrivate = shouldShowPrivateOnly();
    final topApplications = result.topApplications
        .where((a) => a.isPrivate == showPrivate)
        .toList();
    final applicationLimits = result.applicationLimits
        .where((l) => l.isPrivate == showPrivate)
        .toList();

    // Aggregate totals respect the "Include Private Items in Totals" setting:
    // subtract private apps' time out of the raw (always-inclusive) store
    // total when the setting is off, and rebuild the category breakdown
    // (which _buildAllAppData computed unconditionally over every app) from
    // the same public-only app list so private categories/percentages don't
    // leak through when excluded.
    final includePrivate = shouldIncludePrivateInTotals();
    final Duration privateTime = result.topApplications
        .where((a) => a.isPrivate)
        .fold(Duration.zero, (sum, a) => sum + a.screenTime);
    final Duration todayScreenTime =
        includePrivate ? rawTodayScreenTime : rawTodayScreenTime - privateTime;

    final categoryBreakdown = includePrivate
        ? result.categoryBreakdown
        : () {
            final categoryTotals = <String, Duration>{};
            for (final a in topApplications) {
              categoryTotals.update(
                a.category,
                (existing) => existing + a.screenTime,
                ifAbsent: () => a.screenTime,
              );
            }
            final totalSeconds = todayScreenTime.inSeconds;
            final breakdown = totalSeconds > 0
                ? categoryTotals.entries
                    .map((entry) => CategoryDetail(
                          name: entry.key,
                          totalScreenTime: entry.value,
                          percentageOfTotalTime:
                              (entry.value.inSeconds / totalSeconds) * 100,
                        ))
                    .toList()
                : <CategoryDetail>[];
            breakdown.sort((a, b) => b.totalScreenTime.compareTo(a.totalScreenTime));
            return breakdown;
          }();

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
      topApplications: topApplications,
      categoryBreakdown: categoryBreakdown,
      applicationLimits: applicationLimits,
    );
  }

  /// Fetch today's overview data scoped ONLY to private-tagged apps/sites.
  /// Called directly by [fetchTodayOverview] when the titlebar toggle has
  /// switched the view to private-only. Unlike the public path, every stat
  /// here (totalScreenTime, topApplications, categoryBreakdown,
  /// applicationLimits, mostUsedApp) is computed from the private-only
  /// subset, not the full day's data with private items merely hidden from
  /// one list. Caller is expected to only invoke this while unlocked; it
  /// does not itself gate on [isPrivateModeUnlocked].
  Future<OverviewData> fetchTodayPrivateOverview() async {
    if (kIsWeb) return _fetchWebPrivateOverview();
    await _ensureInitialized();

    final DateTime today = SettingsManager().getLogicalDate(DateTime.now());
    final result = _buildAllAppData(today, _dataStore.getTotalScreenTime(today));

    final privateApps = result.topApplications
        .where((a) => a.isPrivate)
        .toList()
      ..sort((a, b) => b.screenTime.compareTo(a.screenTime));

    final Duration privateTotal = privateApps.fold(
        Duration.zero, (sum, a) => sum + a.screenTime);
    final int privateTotalSeconds = privateTotal.inSeconds;

    // Recompute percentage-of-total against the private-only total, and
    // rebuild category breakdown / limits scoped to private apps only.
    final rescaledApps = privateApps
        .map((a) => ApplicationDetail(
              appId: a.appId,
              name: a.name,
              domain: a.domain,
              category: a.category,
              screenTime: a.screenTime,
              percentageOfTotalTime: privateTotalSeconds > 0
                  ? (a.screenTime.inSeconds / privateTotalSeconds) * 100
                  : 0.0,
              isVisible: a.isVisible,
              isProductive: a.isProductive,
              isPrivate: a.isPrivate,
            ))
        .toList();

    final Map<String, Duration> categoryTotals = {};
    for (final a in privateApps) {
      categoryTotals.update(
        a.category,
        (existing) => existing + a.screenTime,
        ifAbsent: () => a.screenTime,
      );
    }
    final categoryBreakdown = privateTotalSeconds > 0
        ? categoryTotals.entries
            .map((entry) => CategoryDetail(
                  name: entry.key,
                  totalScreenTime: entry.value,
                  percentageOfTotalTime:
                      (entry.value.inSeconds / privateTotalSeconds) * 100,
                ))
            .toList()
        : <CategoryDetail>[];
    if (categoryBreakdown.isNotEmpty) {
      categoryBreakdown
          .sort((a, b) => b.totalScreenTime.compareTo(a.totalScreenTime));
    }

    final privateNames = privateApps.map((a) => a.name).toSet();
    final applicationLimits = result.applicationLimits
        .where((l) => privateNames.contains(l.name))
        .toList();

    final String mostUsedApp =
        rescaledApps.isNotEmpty ? rescaledApps.first.name : 'None';

    return OverviewData(
      totalScreenTime: privateTotal,
      averageScreenTime: privateTotal,
      screenTimePercentage: 0,
      productiveTime: privateTotal,
      productivityScore: 0,
      mostUsedApp: mostUsedApp,
      focusSessions: 0,
      totalFocusTime: Duration.zero,
      topApplications: rescaledApps,
      categoryBreakdown: categoryBreakdown,
      applicationLimits: applicationLimits,
    );
  }

  /// Web counterpart of [fetchTodayPrivateOverview] — re-derives from
  /// chrome.storage the same way [_fetchWebOverview] does, but scopes every
  /// stat to `isPrivate: true` domains only.
  Future<OverviewData> _fetchWebPrivateOverview() async {
    final full = await _fetchWebOverview();
    final privateApps = full.topApplications.where((a) => a.isPrivate).toList()
      ..sort((a, b) => b.screenTime.compareTo(a.screenTime));

    final Duration privateTotal = privateApps.fold(
        Duration.zero, (sum, a) => sum + a.screenTime);
    final int privateTotalSeconds = privateTotal.inSeconds;

    final rescaledApps = privateApps
        .map((a) => ApplicationDetail(
              appId: a.appId,
              name: a.name,
              domain: a.domain,
              category: a.category,
              screenTime: a.screenTime,
              percentageOfTotalTime: privateTotalSeconds > 0
                  ? (a.screenTime.inSeconds / privateTotalSeconds) * 100
                  : 0.0,
              isVisible: a.isVisible,
              isProductive: a.isProductive,
              isPrivate: a.isPrivate,
            ))
        .toList();

    final Map<String, Duration> categoryTotals = {};
    for (final a in privateApps) {
      categoryTotals.update(
        a.category,
        (existing) => existing + a.screenTime,
        ifAbsent: () => a.screenTime,
      );
    }
    final categoryBreakdown = privateTotalSeconds > 0
        ? categoryTotals.entries
            .map((entry) => CategoryDetail(
                  name: entry.key,
                  totalScreenTime: entry.value,
                  percentageOfTotalTime:
                      (entry.value.inSeconds / privateTotalSeconds) * 100,
                ))
            .toList()
        : <CategoryDetail>[];
    if (categoryBreakdown.isNotEmpty) {
      categoryBreakdown
          .sort((a, b) => b.totalScreenTime.compareTo(a.totalScreenTime));
    }

    final privateDomains = privateApps.map((a) => a.domain).toSet();
    final applicationLimits = full.applicationLimits
        .where((l) => privateDomains.contains(l.name) ||
            privateApps.any((a) => a.name == l.name))
        .toList();

    final String mostUsedApp =
        rescaledApps.isNotEmpty ? rescaledApps.first.name : 'None';

    return OverviewData(
      totalScreenTime: privateTotal,
      averageScreenTime: privateTotal,
      screenTimePercentage: 0,
      productiveTime: privateTotal,
      productivityScore: 0,
      mostUsedApp: mostUsedApp,
      focusSessions: 0,
      totalFocusTime: Duration.zero,
      topApplications: rescaledApps,
      categoryBreakdown: categoryBreakdown,
      applicationLimits: applicationLimits,
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
          appId: appName,
          name: _dataStore.displayNameFor(appName),
          category: metadata.category,
          screenTime: timeSpent,
          percentageOfTotalTime:
              hasTotalTime ? (timeSpent.inSeconds / totalSeconds) * 100 : 0.0,
          isVisible: metadata.isVisible,
          isProductive: metadata.isProductive,
          isPrivate: metadata.isPrivate,
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
          name: _dataStore.displayNameFor(appName),
          category: metadata.category,
          dailyLimit: metadata.dailyLimit,
          actualUsage: timeSpent,
          percentageOfLimit: percentageOfLimit,
          percentageOfTotalTime:
              hasTotalTime ? (timeSpent.inSeconds / totalSeconds) * 100 : 0.0,
          isPrivate: metadata.isPrivate,
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
    final d = SettingsManager().getLogicalDate(DateTime.now());
    final dateKey =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final storageKey = 'scolect_day_$dateKey';

    final result = await chromeStorageGet([storageKey]);
    final dayData = result[storageKey] as Map<dynamic, dynamic>? ?? {};
    final domains = (dayData['domains'] as List<dynamic>?) ?? [];

    final metaRes =
        await chromeStorageGet(['scolect_app_metadata', 'scolect_settings']);
    final siteMeta =
        (metaRes['scolect_app_metadata'] as Map<dynamic, dynamic>?) ?? {};
    final settingsMap =
        (metaRes['scolect_settings'] as Map<dynamic, dynamic>?) ?? {};
    final customMeta =
        (settingsMap['metadata'] as Map<dynamic, dynamic>?) ?? {};

    final includePrivate = shouldIncludePrivateInTotals();
    final showPrivate = shouldShowPrivateOnly();
    Duration totalTime = Duration.zero;
    List<ApplicationDetail> applications = [];
    // Tracks domains with a configured limit: displayName → (usage, limitSecs, category, isPrivate)
    final Map<String,
            ({Duration usage, int limitSeconds, String category, bool isPrivate})>
        limitMap = {};
    // Raw domain keys already processed in the first loop (prevents duplicates)
    final Set<String> seenDomains = {};
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
      final isPrivate = meta['isPrivate'] as bool? ?? false;

      // Mark domain as seen (dedup guard for the second loop)
      seenDomains.add(domain);

      // Collect domains that have a daily limit configured
      final limitSecs = (meta['dailyLimitSeconds'] as num?)?.toInt() ?? 0;
      if (limitSecs > 0) {
        limitMap[displayName] = (
          usage: duration,
          limitSeconds: limitSecs,
          category: category,
          isPrivate: isPrivate,
        );
      }

      if (isPrivate) {
        // Exclude private time from public-view aggregates when the totals
        // setting is off. Doesn't apply in the private-only view — there,
        // private items are the entire content, not something to exclude.
        if (!includePrivate && !showPrivate) {
          applications.add(ApplicationDetail(
            name: displayName,
            domain: domain,
            category: category,
            screenTime: duration,
            percentageOfTotalTime: 0,
            isVisible: true,
            isProductive: true,
            isPrivate: isPrivate,
          ));
          continue;
        }
      }

      if (seconds > maxSeconds) {
        maxSeconds = seconds.toInt();
        mostUsed = displayName;
      }

      totalTime += duration;
      categoryTotals[category] =
          (categoryTotals[category] ?? Duration.zero) + duration;

      applications.add(ApplicationDetail(
        name: displayName,
        domain: domain,
        category: category,
        screenTime: duration,
        percentageOfTotalTime: 0,
        isVisible: true,
        isProductive: true,
        isPrivate: isPrivate,
      ));
    }

    // Include domains with a limit configured but zero usage today.
    // Guard by raw domain key to avoid duplicates when siteName resolution differs.
    for (final entry in customMeta.entries) {
      final domain = entry.key as String;
      if (seenDomains.contains(domain)) continue; // already in limitMap from first loop
      final meta = entry.value as Map<dynamic, dynamic>? ?? {};
      final limitSecs = (meta['dailyLimitSeconds'] as num?)?.toInt() ?? 0;
      if (limitSecs > 0) {
        final siteName = (meta['siteName'] as String?) ?? '';
        final displayName = siteName.isNotEmpty ? siteName : domain;
        final category = (meta['category'] as String?)?.isNotEmpty == true
            ? meta['category'] as String
            : AppCategories.categorizeApp(displayName);
        limitMap[displayName] = (
          usage: Duration.zero,
          limitSeconds: limitSecs,
          category: category,
          isPrivate: meta['isPrivate'] as bool? ?? false,
        );
      }
    }

    final totalSecs = totalTime.inSeconds;
    if (totalSecs > 0) {
      for (int i = 0; i < applications.length; i++) {
        final app = applications[i];
        final pct = (app.screenTime.inSeconds / totalSecs) * 100;
        applications[i] = ApplicationDetail(
          name: app.name,
          domain: app.domain,
          category: app.category,
          screenTime: app.screenTime,
          percentageOfTotalTime: pct,
          isVisible: true,
          isProductive: true,
          isPrivate: app.isPrivate,
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

    // Build ApplicationLimitDetail list from collected limit data
    final applicationLimits = limitMap.entries.map((e) {
      final limitDur = Duration(seconds: e.value.limitSeconds);
      final usageSecs = e.value.usage.inSeconds;
      final pctOfLimit = e.value.limitSeconds > 0
          ? (usageSecs / e.value.limitSeconds) * 100
          : 0.0;
      final pctOfTotal =
          totalSecs > 0 ? (usageSecs / totalSecs) * 100 : 0.0;
      return ApplicationLimitDetail(
        name: e.key,
        category: e.value.category,
        dailyLimit: limitDur,
        actualUsage: e.value.usage,
        percentageOfLimit: pctOfLimit,
        percentageOfTotalTime: pctOfTotal,
        isPrivate: e.value.isPrivate,
      );
    }).toList()
      ..sort((a, b) => b.percentageOfLimit.compareTo(a.percentageOfLimit));

    applications.sort((a, b) => b.screenTime.compareTo(a.screenTime));
    categoryBreakdown
        .sort((a, b) => b.totalScreenTime.compareTo(a.totalScreenTime));

    // Filter the visible top-applications and limits lists to the current
    // view; totalTime/categoryBreakdown already respect includePrivateInTotals
    // from the accumulation loop above.
    final topApplications =
        applications.where((a) => a.isPrivate == showPrivate).toList();
    final visibleApplicationLimits =
        applicationLimits.where((l) => l.isPrivate == showPrivate).toList();

    return OverviewData(
      totalScreenTime: totalTime,
      averageScreenTime: totalTime,
      screenTimePercentage: 0,
      productiveTime: totalTime,
      productivityScore: 100,
      mostUsedApp: mostUsed,
      focusSessions: 0,
      totalFocusTime: Duration.zero,
      topApplications: topApplications,
      categoryBreakdown: categoryBreakdown,
      applicationLimits: visibleApplicationLimits,
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
  /// Storage key — use for lookups, never for display. Empty on the web
  /// path, which uses [domain] as its identity instead.
  final String appId;
  final String name;     // display name (siteName or domain)
  final String domain;  // raw domain key (web only; empty string on desktop)
  final String category;
  final Duration screenTime;
  final double percentageOfTotalTime;
  final String formattedScreenTime;
  final bool isVisible;
  final bool isProductive;
  final bool isPrivate;

  ApplicationDetail({
    this.appId = '',
    required this.name,
    this.domain = '',
    required this.category,
    required this.screenTime,
    required this.percentageOfTotalTime,
    required this.isVisible,
    required this.isProductive,
    this.isPrivate = false,
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
  final bool isPrivate;
  final String formattedDailyLimit;
  final String formattedActualUsage;

  ApplicationLimitDetail({
    required this.name,
    required this.category,
    required this.dailyLimit,
    required this.actualUsage,
    required this.percentageOfLimit,
    required this.percentageOfTotalTime,
    this.isPrivate = false,
  })  : formattedDailyLimit = DailyOverviewData.formatDuration(dailyLimit),
        formattedActualUsage = DailyOverviewData.formatDuration(actualUsage);
}
