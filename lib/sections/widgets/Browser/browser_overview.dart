import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
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
  List<WebsiteBasicDetail> _allSites = [];

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
      _allSites = sites;
      _topSites = sites.take(6).toList();
      _categories = cats.take(5).toList();
      _isLoading = false;
    });
  }

  Future<void> _launchUrl(String domain) async {
    final uri = Uri.parse(domain.startsWith('http') ? domain : 'https://$domain');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final captionColor = theme.typography.caption?.color;

    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    final summary = _summary!;
    final totalSecs = summary.totalTime.inSeconds;
    final maxSecs = _topSites.isNotEmpty ? _topSites.first.timeSpent.inSeconds : 1;

    // Productivity metrics
    final productiveSecs = _allSites
        .where((s) => s.isProductive)
        .fold<int>(0, (sum, s) => sum + s.timeSpent.inSeconds);
    final productivePct = totalSecs > 0 ? (productiveSecs / totalSecs * 100).round() : 0;

    // Limits metrics
    final sitesWithLimits = _allSites.where((s) => s.dailyLimit > Duration.zero).toList();
    final exceededLimits = sitesWithLimits.where((s) => s.timeSpent >= s.dailyLimit).length;

    // Top productive site
    final topProductiveSite = _allSites.where((s) => s.isProductive && s.timeSpent > Duration.zero).firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Insight Cards (4-metric grid) ───────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final int crossAxisCount;
              final double childAspectRatio;

              if (width >= 640) {
                crossAxisCount = 4;
                childAspectRatio = width >= 900 ? 1.75 : 1.45;
              } else if (width >= 380) {
                crossAxisCount = 2;
                childAspectRatio = 2.0;
              } else {
                crossAxisCount = 1;
                childAspectRatio = 3.0;
              }
              const cardSpacing = 14.0;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: cardSpacing,
                mainAxisSpacing: cardSpacing,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: childAspectRatio,
                children: [
                  // 1. Total Web Time
                  BrowserCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.browserTodayWebTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: captionColor?.withValues(alpha: 0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            BrowserGradientIconBox(
                              icon: FluentIcons.timer,
                              color: kBrowserBlue,
                              size: 16,
                              boxSize: 32,
                            ),
                          ],
                        ),
                        Text(
                          summary.totalTime.toHourMinuteFormat(),
                          style: theme.typography.subtitle?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '${summary.visitCount} visits across ${summary.siteCount} sites',
                          style: TextStyle(
                            fontSize: 11,
                            color: captionColor?.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // 2. Productivity Score
                  BrowserCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.browserProductivePercent(productivePct),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: captionColor?.withValues(alpha: 0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '$productivePct%',
                                style: theme.typography.subtitle?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                  letterSpacing: -0.5,
                                  color: productivePct >= 60
                                      ? kBrowserGreen
                                      : (productivePct >= 40 ? kBrowserAmber : kBrowserRed),
                                ),
                              ),
                              Text(
                                '${Duration(seconds: productiveSecs).toHourMinuteFormat()} ${l10n.focusTime.toLowerCase()}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: captionColor?.withValues(alpha: 0.6),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        BrowserCircularRing(
                          percentage: productivePct.toDouble(),
                          color: productivePct >= 60
                              ? kBrowserGreen
                              : (productivePct >= 40 ? kBrowserAmber : kBrowserRed),
                          size: 48,
                          strokeWidth: 4.5,
                          centerChild: Icon(
                            productivePct >= 60 ? FluentIcons.check_mark : FluentIcons.timer,
                            size: 14,
                            color: productivePct >= 60 ? kBrowserGreen : kBrowserAmber,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Top Focus Site
                  BrowserCard(
                    padding: const EdgeInsets.all(16),
                    onTap: topProductiveSite != null
                        ? () => widget.onTabChange(BrowserTab.websites)
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.browserTopFocus,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: captionColor?.withValues(alpha: 0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            BrowserGradientIconBox(
                              icon: FluentIcons.favorite_star,
                              color: kBrowserPurple,
                              size: 16,
                              boxSize: 32,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (topProductiveSite != null) ...[
                              BrowserDomainAvatar(
                                domain: topProductiveSite.domain,
                                siteName: topProductiveSite.siteName,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                topProductiveSite?.displayName ?? l10n.browserNoDataYet,
                                style: theme.typography.bodyStrong?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          topProductiveSite != null
                              ? '${topProductiveSite.formattedTimeSpent} ${l10n.browserToday.toLowerCase()}'
                              : l10n.browserNoProductiveSites,
                          style: TextStyle(
                            fontSize: 11,
                            color: captionColor?.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // 4. Daily Limits Health
                  BrowserCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => widget.onTabChange(BrowserTab.limits),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.browserLimitsHealth,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: captionColor?.withValues(alpha: 0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            BrowserGradientIconBox(
                              icon: FluentIcons.time_picker,
                              color: exceededLimits > 0 ? kBrowserRed : kBrowserAmber,
                              size: 16,
                              boxSize: 32,
                            ),
                          ],
                        ),
                        Text(
                          sitesWithLimits.isEmpty
                              ? l10n.browserNoLimitsTitle
                              : (exceededLimits > 0
                                  ? l10n.browserLimitsExceeded(exceededLimits)
                                  : l10n.browserLimitsActiveCount(sitesWithLimits.length)),
                          style: theme.typography.subtitle?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: -0.3,
                            color: exceededLimits > 0
                                ? kBrowserRed
                                : (sitesWithLimits.isEmpty ? captionColor : kBrowserAmber),
                          ),
                        ),
                        Text(
                          sitesWithLimits.isEmpty
                              ? l10n.browserNoLimitsSubtitle
                              : (exceededLimits > 0
                                  ? l10n.browserActiveLimitsHealthWarning(exceededLimits)
                                  : l10n.browserActiveLimitsHealthSafe),
                          style: TextStyle(
                            fontSize: 11,
                            color: captionColor?.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // ── Top Sites & Category Share Split ─────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 960;

              final topSitesSection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BrowserSectionHeader(
                    icon: FluentIcons.globe,
                    title: l10n.browserTopSitesToday,
                    subtitle: 'Most active domains visited today',
                    color: theme.accentColor,
                    trailing: GestureDetector(
                      onTap: () => widget.onTabChange(BrowserTab.websites),
                      child: Text(
                        l10n.browserViewAll,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_topSites.isEmpty)
                    BrowserCard(
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                            final pct = maxSecs > 0
                                ? site.timeSpent.inSeconds / maxSecs
                                : 0.0;
                            final sharePct = totalSecs > 0
                                ? (site.timeSpent.inSeconds / totalSecs * 100).toStringAsFixed(0)
                                : '0';

                            return _TopSiteTile(
                              site: site,
                              barFraction: pct,
                              sharePercentage: sharePct,
                              showDivider: i < _topSites.length - 1,
                              accentColor: theme.accentColor,
                              onLaunch: () => _launchUrl(site.domain),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              );

              final categorySection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BrowserSectionHeader(
                    icon: FluentIcons.tag,
                    title: l10n.browserByCategory,
                    subtitle: 'Time distribution by website category',
                    color: kBrowserPurple,
                    trailing: GestureDetector(
                      onTap: () => widget.onTabChange(BrowserTab.categories),
                      child: Text(
                        l10n.browserViewAll,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_categories.isEmpty)
                    BrowserCard(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: BrowserEmptyState(
                        icon: FluentIcons.tag,
                        title: l10n.browserNoCategoriesTitle,
                        subtitle: l10n.browserNoCategoriesSubtitle,
                      ),
                    )
                  else
                    BrowserCard(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category segmented visual meter
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 10,
                              child: Row(
                                children: _categories.map((c) {
                                  final meta = CategoryMeta.fromName(c.category);
                                  final flex = (c.percentage * 10).round();
                                  if (flex == 0) return const SizedBox.shrink();
                                  return Flexible(
                                    flex: flex,
                                    child: Container(color: meta.color),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Category list items
                          ..._categories.asMap().entries.map((entry) {
                            final cat = entry.value;
                            final meta = CategoryMeta.fromName(cat.category);
                            final showDiv = entry.key < _categories.length - 1;
                            return _CategoryTile(
                              summary: cat,
                              meta: meta,
                              totalSecs: totalSecs,
                              showDivider: showDiv,
                            );
                          }),
                        ],
                      ),
                    ),
                ],
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: topSitesSection),
                    const SizedBox(width: 18),
                    Expanded(flex: 2, child: categorySection),
                  ],
                );
              }

              return Column(
                children: [
                  topSitesSection,
                  const SizedBox(height: 24),
                  categorySection,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Top Site Tile Widget ─────────────────────────────────────────────────────

class _TopSiteTile extends StatefulWidget {
  final WebsiteBasicDetail site;
  final double barFraction;
  final String sharePercentage;
  final bool showDivider;
  final Color accentColor;
  final VoidCallback onLaunch;

  const _TopSiteTile({
    required this.site,
    required this.barFraction,
    required this.sharePercentage,
    required this.showDivider,
    required this.accentColor,
    required this.onLaunch,
  });

  @override
  State<_TopSiteTile> createState() => _TopSiteTileState();
}

class _TopSiteTileState extends State<_TopSiteTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final captionColor = theme.typography.caption?.color;
    final catMeta = CategoryMeta.fromName(widget.site.category);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        color: _hovered
            ? theme.inactiveBackgroundColor.withValues(alpha: 0.35)
            : Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 450;

                  return Row(
                    children: [
                      // Domain Avatar
                      BrowserDomainAvatar(
                        domain: widget.site.domain,
                        siteName: widget.site.siteName,
                        size: 32,
                      ),
                      const SizedBox(width: 12),

                      // Domain Name & Category Pill & Progress Bar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.site.displayName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!isCompact) ...[
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Container(
                                      constraints: const BoxConstraints(maxWidth: 130),
                                      child: BrowserStatChip(
                                        label: widget.site.category,
                                        color: catMeta.color,
                                        icon: catMeta.icon,
                                      ),
                                    ),
                                  ),
                                  if (widget.site.isProductive) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: kBrowserGreen.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Productive',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: kBrowserGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            BrowserProgressBar(
                              fraction: widget.barFraction,
                              color: widget.site.isProductive ? kBrowserGreen : widget.accentColor,
                              height: 4,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Time spent & visits
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.site.formattedTimeSpent,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: widget.accentColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isCompact
                                ? '${widget.sharePercentage}% web'
                                : '${widget.sharePercentage}% of web · ${l10n.browserVisitCount(widget.site.visits)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: captionColor?.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 8),

                      // Launch icon button
                      Tooltip(
                        message: 'Open in Browser',
                        child: IconButton(
                          icon: Icon(
                            FluentIcons.open_in_new_window,
                            size: 13,
                            color: _hovered ? theme.accentColor : captionColor?.withValues(alpha: 0.4),
                          ),
                          onPressed: widget.onLaunch,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (widget.showDivider)
              Divider(
                style: DividerThemeData(
                  decoration: BoxDecoration(
                    color: theme.inactiveBackgroundColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Category Tile Widget ─────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final WebsiteCategorySummary summary;
  final CategoryMeta meta;
  final int totalSecs;
  final bool showDivider;

  const _CategoryTile({
    required this.summary,
    required this.meta,
    required this.totalSecs,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final pct = totalSecs > 0
        ? (summary.totalTime.inSeconds / totalSecs).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: meta.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(meta.icon, size: 14, color: meta.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          summary.category,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${summary.percentage.toStringAsFixed(0)}%  ·  ${summary.formattedTime}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.typography.body?.color?.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    BrowserProgressBar(
                      fraction: pct,
                      color: meta.color,
                      height: 5,
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
                color: theme.inactiveBackgroundColor.withValues(alpha: 0.35),
              ),
            ),
          ),
      ],
    );
  }
}
