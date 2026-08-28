import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/data_controllers/browser_data_controller.dart';
import 'browser_shared.dart';

class BrowserCategories extends StatefulWidget {
  final ValueChanged<BrowserTab> onTabChange;

  const BrowserCategories({super.key, required this.onTabChange});

  @override
  State<BrowserCategories> createState() => _BrowserCategoriesState();
}

class _BrowserCategoriesState extends State<BrowserCategories> {
  final _provider = BrowserDataProvider();

  List<WebsiteCategorySummary> _categories = [];
  Map<String, List<WebsiteBasicDetail>> _byCat = {};
  bool _isLoading = true;
  String? _expanded;

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
    final cats = await _provider.fetchCategoryBreakdown();
    final sites = await _provider.fetchAllWebsites();
    if (!mounted) return;

    final Map<String, List<WebsiteBasicDetail>> grouped = {};
    for (final s in sites) {
      grouped.putIfAbsent(s.category, () => []).add(s);
    }

    setState(() {
      _categories = cats;
      _byCat = grouped;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final captionColor = theme.typography.caption?.color;

    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    if (_categories.isEmpty) {
      return BrowserEmptyState(
        icon: FluentIcons.tag,
        title: l10n.browserNoCategoriesTitle,
        subtitle: l10n.browserNoCategoriesSubtitle,
      );
    }

    final totalSecs =
        _categories.fold<int>(0, (sum, c) => sum + c.totalTime.inSeconds);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Time Distribution Hero Card ───────────────────────────────
          BrowserCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, heroConstraints) {
                    final isNarrowHero = heroConstraints.maxWidth < 480;
                    if (isNarrowHero) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BrowserSectionHeader(
                            icon: FluentIcons.pie_single,
                            title: l10n.browserTimeDistribution,
                            subtitle: 'Browsing breakdown across ${_categories.length} categories',
                            color: theme.accentColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${Duration(seconds: totalSecs).toHourMinuteFormat()} total',
                            style: theme.typography.bodyStrong?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.accentColor,
                            ),
                          ),
                        ],
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BrowserSectionHeader(
                          icon: FluentIcons.pie_single,
                          title: l10n.browserTimeDistribution,
                          subtitle: 'Browsing breakdown across ${_categories.length} categories',
                          color: theme.accentColor,
                        ),
                        Text(
                          '${Duration(seconds: totalSecs).toHourMinuteFormat()} total',
                          style: theme.typography.bodyStrong?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.accentColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Segmented progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 16,
                    child: Row(
                      children: _categories.map((c) {
                        final meta = CategoryMeta.fromName(c.category);
                        final pct = totalSecs > 0
                            ? c.totalTime.inSeconds / totalSecs
                            : 0.0;
                        final flex = (pct * 1000).round();
                        if (flex <= 0) return const SizedBox.shrink();
                        return Flexible(
                          flex: flex,
                          child: Tooltip(
                            message: '${c.category}: ${c.formattedTime} (${c.percentage.toStringAsFixed(0)}%)',
                            child: Container(
                              color: meta.color,
                              margin: const EdgeInsets.symmetric(horizontal: 0.5),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Category Legend Chips
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: _categories.map((c) {
                    final meta = CategoryMeta.fromName(c.category);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: meta.color.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(meta.icon, size: 12, color: meta.color),
                          const SizedBox(width: 5),
                          Text(
                            '${c.category} · ${c.percentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: meta.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Category Cards Grid ───────────────────────────────────────
          Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BrowserSectionHeader(
                    icon: FluentIcons.tag,
                    title: 'Category Details',
                    subtitle: 'Inspect individual websites and usage per category',
                    color: kBrowserPurple,
                  ),
                  const SizedBox(height: 12),
                  ..._categories.map((cat) {
                    final meta = CategoryMeta.fromName(cat.category);
                    final sites = _byCat[cat.category] ?? [];
                    final isExpanded = _expanded == cat.category;
                    final topSitesInCat = sites.take(3).toList();
                    final catSecs = cat.totalTime.inSeconds;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BrowserCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            // Header Row (Clickable to expand)
                            GestureDetector(
                              onTap: () => setState(() =>
                                  _expanded = isExpanded ? null : cat.category),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 14),
                                  color: isExpanded
                                      ? (isDark
                                          ? Colors.white.withValues(alpha: 0.03)
                                          : theme.inactiveBackgroundColor.withValues(alpha: 0.25))
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      // Category Icon Box
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: meta.color.withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(9),
                                          border: Border.all(
                                            color: meta.color.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(meta.icon, size: 18, color: meta.color),
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Category Name & Site count
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              cat.category,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${l10n.browserSiteCount(cat.siteCount)} visited today',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: captionColor?.withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Time Spent & Share Badge
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            cat.formattedTime,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: meta.color,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${cat.percentage.toStringAsFixed(0)}% of total',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: captionColor?.withValues(alpha: 0.55),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 14),

                                      // Expand Arrow
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white.withValues(alpha: 0.06)
                                              : theme.inactiveBackgroundColor.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          isExpanded
                                              ? FluentIcons.chevron_up
                                              : FluentIcons.chevron_down,
                                          size: 11,
                                          color: captionColor?.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Mini preview (when collapsed)
                            if (!isExpanded && topSitesInCat.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                                child: LayoutBuilder(
                                  builder: (context, previewConstraints) {
                                    final width = previewConstraints.maxWidth;
                                    final countToShow = width >= 540 ? 3 : (width >= 360 ? 2 : 1);
                                    final displayedSites = topSitesInCat.take(countToShow).toList();

                                    return Row(
                                      children: displayedSites.map((s) {
                                        return Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(right: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.white.withValues(alpha: 0.03)
                                                  : theme.inactiveBackgroundColor.withValues(alpha: 0.25),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              children: [
                                                BrowserDomainAvatar(
                                                  domain: s.domain,
                                                  siteName: s.siteName,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    s.displayName,
                                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  s.formattedTimeSpent,
                                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: meta.color),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ),
                            ],

                            // Expanded Detailed Sites List
                            AnimatedSize(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              child: isExpanded && sites.isNotEmpty
                                  ? Column(
                                      children: [
                                        Divider(
                                          style: DividerThemeData(
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.white.withValues(alpha: 0.06)
                                                  : theme.inactiveBackgroundColor.withValues(alpha: 0.4),
                                            ),
                                          ),
                                        ),
                                        ...sites.map((s) {
                                          final sitePct = catSecs > 0
                                              ? (s.timeSpent.inSeconds / catSecs).clamp(0.0, 1.0)
                                              : 0.0;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                            child: LayoutBuilder(
                                              builder: (context, siteRowConstraints) {
                                                final isSiteRowNarrow = siteRowConstraints.maxWidth < 400;

                                                if (isSiteRowNarrow) {
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          BrowserDomainAvatar(
                                                            domain: s.domain,
                                                            siteName: s.siteName,
                                                            size: 26,
                                                          ),
                                                          const SizedBox(width: 10),
                                                          Expanded(
                                                            child: Text(
                                                              s.displayName,
                                                              style: const TextStyle(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            s.formattedTimeSpent,
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w700,
                                                              color: meta.color,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: BrowserProgressBar(
                                                              fraction: sitePct,
                                                              color: meta.color,
                                                              height: 3,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 10),
                                                          ProductivityChip(isProductive: s.isProductive),
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                }

                                                return Row(
                                                  children: [
                                                    BrowserDomainAvatar(
                                                      domain: s.domain,
                                                      siteName: s.siteName,
                                                      size: 26,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            s.displayName,
                                                            style: const TextStyle(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          const SizedBox(height: 3),
                                                          BrowserProgressBar(
                                                            fraction: sitePct,
                                                            color: meta.color,
                                                            height: 3,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    ProductivityChip(isProductive: s.isProductive),
                                                    const SizedBox(width: 16),
                                                    Text(
                                                      s.formattedTimeSpent,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w700,
                                                        color: meta.color,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          );
                                        }),
                                        const SizedBox(height: 6),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
        ],
      ),
    );
  }
}
