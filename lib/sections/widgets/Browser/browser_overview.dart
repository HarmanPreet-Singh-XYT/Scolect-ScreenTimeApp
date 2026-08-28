import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/data_controllers/browser_data_controller.dart';
import 'browser_shared.dart';

class BrowserOverview extends StatefulWidget {
  final ValueChanged<BrowserTab> onTabChange;

  const BrowserOverview({super.key, required this.onTabChange});

  @override
  State<BrowserOverview> createState() => _BrowserOverviewState();
}

class _BrowserOverviewState extends State<BrowserOverview> {
  final _provider = BrowserDataProvider();

  bool _isLoading = true;
  ({Duration totalTime, int siteCount, int visitCount})? _summary;
  List<WebsiteBasicDetail> _topSites = [];
  List<WebsiteCategorySummary> _categories = [];

  @override
  void initState() {
    super.initState();
    _provider.addListener(_loadData);
    _loadData();
  }

  @override
  void dispose() {
    _provider.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    final summary = await _provider.fetchTodaySummary();
    final sites = await _provider.fetchAllWebsites();
    final cats = await _provider.fetchCategoryBreakdown();
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _topSites = sites.take(5).toList();
      _categories = cats.take(4).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    final summary = _summary!;
    final totalSecs = summary.totalTime.inSeconds;
    final maxSecs =
        _topSites.isNotEmpty ? _topSites.first.timeSpent.inSeconds : 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary stats ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: BrowserSummaryCard(
                  icon: FluentIcons.timer,
                  label: l10n.browserTodayWebTime,
                  value: summary.totalTime.toHourMinuteFormat(),
                  color: kBrowserBlue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: BrowserSummaryCard(
                  icon: FluentIcons.globe,
                  label: l10n.browserSitesVisited,
                  value: '${summary.siteCount}',
                  color: kBrowserPurple,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: BrowserSummaryCard(
                  icon: FluentIcons.link,
                  label: l10n.browserPageVisits,
                  value: '${summary.visitCount}',
                  color: kBrowserGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Top sites ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionLabel(l10n.browserTopSitesToday),
              GestureDetector(
                onTap: () => widget.onTabChange(BrowserTab.websites),
                child: Text(
                  l10n.browserViewAll,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_topSites.isEmpty)
            BrowserCard(
              height: 160,
              child: BrowserEmptyState(
                icon: FluentIcons.globe,
                title: l10n.browserNoWebActivityTitle,
                subtitle: kIsWeb
                    ? l10n.browserNoActivityWebSubtitle
                    : l10n.browserNoActivityDesktopSubtitle,
              ),
            )
          else
            BrowserCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: _topSites.asMap().entries.map((entry) {
                    final i = entry.key;
                    final site = entry.value;
                    final pct =
                        maxSecs > 0 ? site.timeSpent.inSeconds / maxSecs : 0.0;
                    return _SiteRow(
                      site: site,
                      barFraction: pct,
                      showDivider: i < _topSites.length - 1,
                      accentColor: theme.accentColor,
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 20),

          // ── Category breakdown ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionLabel(l10n.browserByCategory),
              GestureDetector(
                onTap: () => widget.onTabChange(BrowserTab.categories),
                child: Text(
                  l10n.browserViewAll,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_categories.isEmpty)
            BrowserCard(
              height: 120,
              child: BrowserEmptyState(
                icon: FluentIcons.tag,
                title: l10n.browserNoCategoriesTitle,
                subtitle: l10n.browserNoCategoriesSubtitle,
              ),
            )
          else
            BrowserCard(
              child: Column(
                children: _categories.asMap().entries.map((entry) {
                  final cat = entry.value;
                  final showDiv = entry.key < _categories.length - 1;
                  return _CategoryRow(
                    summary: cat,
                    totalSecs: totalSecs,
                    showDivider: showDiv,
                    accentColor: theme.accentColor,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Site row ────────────────────────────────────────────────────────────────

class _SiteRow extends StatelessWidget {
  final WebsiteBasicDetail site;
  final double barFraction;
  final bool showDivider;
  final Color accentColor;

  const _SiteRow({
    required this.site,
    required this.barFraction,
    required this.showDivider,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final captionColor = theme.typography.caption?.color;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Favicon
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(FluentIcons.globe,
                    size: 14, color: accentColor.withValues(alpha: 0.6)),
              ),
              const SizedBox(width: 12),
              // Domain + bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      site.displayName,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Stack(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.inactiveBackgroundColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: barFraction.clamp(0.0, 1.0),
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accentColor,
                                  accentColor.withValues(alpha: 0.6)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Time + visits
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    site.formattedTimeSpent,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  Text(
                    l10n.browserVisitCount(site.visits),
                    style: TextStyle(
                      fontSize: 11,
                      color: captionColor?.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            style: DividerThemeData(
              decoration: BoxDecoration(
                color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Category row ─────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  final WebsiteCategorySummary summary;
  final int totalSecs;
  final bool showDivider;
  final Color accentColor;

  const _CategoryRow({
    required this.summary,
    required this.totalSecs,
    required this.showDivider,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final captionColor = theme.typography.caption?.color;
    final pct = totalSecs > 0
        ? (summary.totalTime.inSeconds / totalSecs).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(summary.category,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500)),
                        Text(
                          '${summary.percentage.toStringAsFixed(0)}%  ·  ${summary.formattedTime}',
                          style: TextStyle(
                              fontSize: 12,
                              color: captionColor?.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: theme.inactiveBackgroundColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: pct,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            style: DividerThemeData(
              decoration: BoxDecoration(
                color: theme.inactiveBackgroundColor.withValues(alpha: 0.4),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Text(
      text,
      style: theme.typography.bodyStrong?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

extension on Duration {
  String toHourMinuteFormat() {
    if (inSeconds < 60) return '${inSeconds}s';
    final h = inHours;
    final m = inMinutes % 60;
    if (h > 0) return m > 0 ? '${h}h ${m}m' : '${h}h';
    return '${m}m';
  }
}
