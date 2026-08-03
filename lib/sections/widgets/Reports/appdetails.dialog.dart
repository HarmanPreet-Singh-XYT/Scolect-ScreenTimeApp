import 'package:fluent_ui/fluent_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/data_controllers/applications_data_controller.dart';
import 'package:screentime/sections/controller/data_controllers/browser_data_controller.dart';
import '../../controller/data_controllers/reports_controller.dart';
import '../../controller/data_controllers/alerts_limits_data_controller.dart'
    as app_summary_data;
import 'tabs/overview_tab.dart';
import 'tabs/usage_chart_tab.dart';
import 'tabs/patterns_tab.dart';

export 'tabs/overview_tab.dart';
export 'tabs/usage_chart_tab.dart';
export 'tabs/patterns_tab.dart';

Map<String, double> generateTimeOfDayData(Map<int, Duration> hourlyBreakdown) {
  final buckets = {
    'Morning (6-12)': Duration.zero,
    'Afternoon (12-5)': Duration.zero,
    'Evening (5-9)': Duration.zero,
    'Night (9-6)': Duration.zero,
  };

  for (final entry in hourlyBreakdown.entries) {
    final hour = entry.key;
    final key = hour >= 6 && hour < 12
        ? 'Morning (6-12)'
        : hour >= 12 && hour < 17
            ? 'Afternoon (12-5)'
            : hour >= 17 && hour < 21
                ? 'Evening (5-9)'
                : 'Night (9-6)';
    buckets[key] = buckets[key]! + entry.value;
  }

  final total = buckets.values.fold(Duration.zero, (a, b) => a + b);
  if (total.inSeconds == 0) return {for (final k in buckets.keys) k: 25.0};

  return {
    for (final e in buckets.entries)
      e.key: (e.value.inSeconds / total.inSeconds) * 100
  };
}

Future<void> showAppDetailsDialog(
    BuildContext context, AppUsageSummary app) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = app_summary_data.ScreenTimeDataController();
  final appSummary = controller.getAppSummary(app.appName);
  if (appSummary == null) return;

  final appDataProvider = ApplicationsDataProvider();
  final appBasicDetails =
      await appDataProvider.fetchApplicationByName(app.appName);
  final appDetails = await appDataProvider.fetchApplicationDetails(
      app.appName, TimeRange.week);

  final weeklyData = appDetails.usageTrends.daily;
  final sortedDates = _sortedDateKeys(weeklyData);

  double xCoord = 0;
  final dateToX = <String, double>{};
  final spots = <FlSpot>[];
  double maxUsage = 0;

  for (final date in sortedDates) {
    final mins = (weeklyData[date] ?? Duration.zero).inMinutes.toDouble();
    maxUsage = max(maxUsage, mins);
    dateToX.putIfAbsent(date, () => xCoord++);
    spots.add(FlSpot(dateToX[date]!, mins));
  }

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (_) => AppDetailsDialog(
      app: app,
      l10n: l10n,
      appSummary: appSummary,
      appBasicDetails: appBasicDetails,
      appDetails: appDetails,
      dailyUsageSpots: spots,
      sortedDates: sortedDates,
      maxUsage: maxUsage,
      dateToXCoordinate: dateToX,
      timeOfDayUsage: generateTimeOfDayData(appDetails.hourlyBreakdown),
    ),
  );
}

List<String> _sortedDateKeys(Map<String, Duration> data) => data.keys.toList()
  ..sort((a, b) {
    try {
      return DateFormat('MM/dd')
          .parse(a)
          .compareTo(DateFormat('MM/dd').parse(b));
    } catch (_) {
      return 0;
    }
  });

/// Shows the same rich AppDetailsDialog for a website on the web extension,
/// building the required data objects from BrowserDataProvider.
///
/// [domain]      — the raw domain key used in chrome.storage (e.g. "youtube.com").
///                 Preferred for reliable lookup; falls back to [displayName].
/// [displayName] — human-readable name shown in the header (siteName or domain).
Future<void> showWebsiteDetailsDialog(
  BuildContext context, {
  required String displayName,
  String domain = '',          // raw storage key; preferred over displayName for lookup
  required String category,
  required Duration timeSpent,
  required bool isProductive,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final provider = BrowserDataProvider();

  // Fetch full site detail (limit, visits, tracking) and 7-day history in parallel
  final results = await Future.wait([
    provider.fetchAllWebsites(),
    provider.fetchHistory(days: 7),
  ]);

  final allSites = results[0] as List<WebsiteBasicDetail>;
  final history =
      results[1] as List<({String date, Duration totalTime, int siteCount})>;

  // Prefer raw domain for lookup; fall back to display name matching
  final lookupKey = domain.isNotEmpty ? domain : displayName;
  final site = allSites.cast<WebsiteBasicDetail?>().firstWhere(
            (s) => s!.domain == lookupKey || s.displayName == lookupKey,
            orElse: () => null,
          ) ??
      WebsiteBasicDetail(
        domain: lookupKey,
        category: category,
        timeSpent: timeSpent,
        isTracking: true,
        isHidden: false,
        isProductive: isProductive,
        dailyLimit: Duration.zero,
        limitStatus: false,
        visits: 0,
      );

  // Build weekly trend map from history (keyed MM/dd like the desktop does)
  final Map<String, Duration> weeklyDaily = {};
  for (final entry in history) {
    try {
      final parts = entry.date.split('-');
      final key = '${parts[1]}/${parts[2]}'; // YYYY-MM-DD → MM/DD
      // history gives total web time per day; we use the site's proportion of today
      // We can only show today's exact value — other days are totals, not per-site.
      // So we leave the daily trend empty except for today, which avoids misleading data.
      weeklyDaily[key] = Duration.zero;
    } catch (_) {}
  }
  // Fill today with the actual value
  final now = DateTime.now();
  final todayKey =
      '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
  weeklyDaily[todayKey] = site.timeSpent;

  final sortedDates = _sortedDateKeys(weeklyDaily);

  double xCoord = 0;
  final dateToX = <String, double>{};
  final spots = <FlSpot>[];
  double maxUsage = 0;
  for (final date in sortedDates) {
    final mins = (weeklyDaily[date] ?? Duration.zero).inMinutes.toDouble();
    maxUsage = max(maxUsage, mins);
    dateToX.putIfAbsent(date, () => xCoord++);
    spots.add(FlSpot(dateToX[date]!, mins));
  }

  // Build the data objects AppDetailsDialog expects
  final appSummary = app_summary_data.AppUsageSummary(
    appName: site.domain,
    siteName: site.siteName,
    category: site.category,
    dailyLimit: site.dailyLimit,
    currentUsage: site.timeSpent,
    limitStatus: site.limitStatus,
    isProductive: site.isProductive,
    isAboutToReachLimit: site.dailyLimit > Duration.zero &&
        site.timeSpent.inSeconds / site.dailyLimit.inSeconds >= 0.8,
    percentageOfLimitUsed: site.dailyLimit > Duration.zero
        ? (site.timeSpent.inSeconds / site.dailyLimit.inSeconds * 100)
            .clamp(0.0, 100.0)
        : 0.0,
    trend: app_summary_data.UsageTrend.noData,
  );

  final appBasicDetails = ApplicationBasicDetail(
    name: site.domain,
    siteName: site.siteName,
    category: site.category,
    screenTime: site.timeSpent,
    isTracking: site.isTracking,
    isHidden: site.isHidden,
    isProductive: site.isProductive,
    dailyLimit: site.dailyLimit,
    limitStatus: site.limitStatus,
  );

  final appDetails = ApplicationDetailedData(
    usageTrends: UsageTrendsData(
      daily: weeklyDaily,
      weekly: {},
      monthly: {},
    ),
    hourlyBreakdown: {},
    categoryUsage: {site.category: site.timeSpent},
    usageInsights: UsageInsights(
      mostActiveHours: [],
      longestSession: Duration.zero,
      averageDailyUsage: site.timeSpent,
    ),
    comparisons: UsageComparisons(
      currentPeriodUsage: site.timeSpent,
      previousPeriodUsage: Duration.zero,
      growthPercentage: 0,
      similarAppsComparison: [],
    ),
    sessionBreakdown: SessionBreakdown(
      averageSessionDuration: Duration.zero,
      longestSessionDuration: Duration.zero,
      shortestSessionDuration: Duration.zero,
      totalSessions: site.visits,
      averageLaunchesPerDay: site.visits.toDouble(),
      maxLaunchesPerDay: site.visits,
      lastUsedTimestamp: null,
    ),
  );

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (_) => AppDetailsDialog(
      app: AppUsageSummary(
        appName: site.displayName,
        category: site.category,
        totalTime: site.timeSpent,
        isProductive: site.isProductive,
        isVisible: true,
      ),
      l10n: l10n,
      appSummary: appSummary,
      appBasicDetails: appBasicDetails,
      appDetails: appDetails,
      dailyUsageSpots: spots,
      sortedDates: sortedDates,
      maxUsage: maxUsage,
      dateToXCoordinate: dateToX,
      timeOfDayUsage: generateTimeOfDayData({}),
    ),
  );
}

class AppDetailsDialog extends StatefulWidget {
  final AppUsageSummary app;
  final AppLocalizations l10n;
  final app_summary_data.AppUsageSummary appSummary;
  final ApplicationBasicDetail appBasicDetails;
  final ApplicationDetailedData appDetails;
  final List<FlSpot> dailyUsageSpots;
  final List<String> sortedDates;
  final double maxUsage;
  final Map<String, double> dateToXCoordinate;
  final Map<String, double> timeOfDayUsage;

  const AppDetailsDialog({
    super.key,
    required this.app,
    required this.l10n,
    required this.appSummary,
    required this.appBasicDetails,
    required this.appDetails,
    required this.dailyUsageSpots,
    required this.sortedDates,
    required this.maxUsage,
    required this.dateToXCoordinate,
    required this.timeOfDayUsage,
  });

  @override
  State<AppDetailsDialog> createState() => _AppDetailsDialogState();
}

class _AppDetailsDialogState extends State<AppDetailsDialog> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = widget.l10n;
    final tabs = [
      (l10n.overview, FluentIcons.view_dashboard),
      (l10n.usageOverPastWeek, FluentIcons.chart),
      (l10n.patterns, FluentIcons.insights),
    ];

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 700, maxHeight: 1000),
      title: _buildHeader(context, theme),
      content: SizedBox(
        width: 680,
        height: 460,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTabBar(tabs, theme),
            const SizedBox(height: 16),
            Expanded(child: _buildTabContent(context, l10n, theme)),
          ],
        ),
      ),
      actions: [
        Button(
            onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, FluentThemeData theme) {
    final app = widget.app;
    final l10n = widget.l10n;
    final color = app.isProductive ? Colors.green : Colors.red;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.light, color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: const Icon(FluentIcons.app_icon_default,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(app.appName,
                  style: theme.typography.subtitle
                      ?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _badge(app.category, theme.accentColor.withValues(alpha: 0.1),
                      theme.accentColor),
                  const SizedBox(width: 8),
                  _badge(
                    app.isProductive ? l10n.productive : l10n.nonProductive,
                    color.withValues(alpha: 0.1),
                    color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badge(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, color: fg, fontWeight: FontWeight.w500)),
      );

  Widget _buildTabBar(List<(String, IconData)> tabs, FluentThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: theme.cardColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final isSelected = _selectedTab == entry.key;
          final tab = entry.value;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? theme.accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tab.$2,
                        size: 14,
                        color: isSelected ? Colors.white : theme.inactiveColor),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        tab.$1,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color:
                              isSelected ? Colors.white : theme.inactiveColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    return switch (_selectedTab) {
      0 => OverviewTab(
          app: widget.app,
          l10n: l10n,
          appSummary: widget.appSummary,
          appBasicDetails: widget.appBasicDetails,
          appDetails: widget.appDetails,
          theme: theme,
        ),
      1 => UsageChartTab(
          l10n: l10n,
          appSummary: widget.appSummary,
          dailyUsageSpots: widget.dailyUsageSpots,
          sortedDates: widget.sortedDates,
          maxUsage: widget.maxUsage,
          theme: theme,
        ),
      2 => PatternsTab(
          l10n: l10n,
          appBasicDetails: widget.appBasicDetails,
          appDetails: widget.appDetails,
          timeOfDayUsage: widget.timeOfDayUsage,
          theme: theme,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
