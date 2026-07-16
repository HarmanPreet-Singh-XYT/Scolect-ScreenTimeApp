import 'package:fluent_ui/fluent_ui.dart';
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
    _loadData();
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

    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    if (_categories.isEmpty) {
      return const BrowserEmptyState(
        icon: FluentIcons.tag,
        title: 'No categories yet',
        subtitle: 'Categories appear once websites are tracked',
      );
    }

    final totalSecs = _categories.fold<int>(
      0, (sum, c) => sum + c.totalTime.inSeconds);

    // Color palette cycling
    const palette = [
      kBrowserBlue,
      kBrowserPurple,
      kBrowserGreen,
      kBrowserAmber,
      kBrowserRed,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Distribution bar ──────────────────────────────────────────
          BrowserCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time Distribution',
                  style: theme.typography.bodyStrong
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 16,
                    child: Row(
                      children: _categories.asMap().entries.map((e) {
                        final pct = totalSecs > 0
                            ? e.value.totalTime.inSeconds / totalSecs
                            : 0.0;
                        return Flexible(
                          flex: (pct * 1000).round(),
                          child: Container(
                            color: palette[e.key % palette.length],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: _categories.asMap().entries.map((e) {
                    final color = palette[e.key % palette.length];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${e.value.category} (${e.value.percentage.toStringAsFixed(0)}%)',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.typography.caption?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Per-category expandable cards ─────────────────────────────
          ..._categories.asMap().entries.map((e) {
            final cat = e.value;
            final color = palette[e.key % palette.length];
            final sites = _byCat[cat.category] ?? [];
            final isExpanded = _expanded == cat.category;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: BrowserCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // Header row
                    GestureDetector(
                      onTap: () => setState(() =>
                          _expanded = isExpanded ? null : cat.category),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  cat.category,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                '${cat.siteCount} site${cat.siteCount != 1 ? 's' : ''}  ·  ${cat.formattedTime}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.typography.caption?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(width: 12),
                              BrowserStatChip(
                                label:
                                    '${cat.percentage.toStringAsFixed(0)}%',
                                color: color.withValues(alpha: 0.15),
                                textColor: color,
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isExpanded
                                    ? FluentIcons.chevron_up
                                    : FluentIcons.chevron_down,
                                size: 12,
                                color: theme.typography.caption?.color
                                    ?.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Expandable site list
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      child: isExpanded && sites.isNotEmpty
                          ? Column(
                              children: [
                                Divider(
                                  style: DividerThemeData(
                                    decoration: BoxDecoration(
                                      color: theme.inactiveBackgroundColor
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                                ...sites.map((s) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: color.withValues(alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Icon(FluentIcons.globe,
                                                size: 12,
                                                color: color.withValues(alpha: 0.6)),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(s.domain,
                                                style: const TextStyle(
                                                    fontSize: 13)),
                                          ),
                                          Text(
                                            s.formattedTimeSpent,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
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
    );
  }
}
