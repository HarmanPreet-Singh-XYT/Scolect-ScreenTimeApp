import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/data_controllers/browser_data_controller.dart';
import 'browser_shared.dart';
import 'browser_websites.dart' show showBrowserLimitPicker, formatBrowserLimit;

class BrowserLimits extends StatefulWidget {
  final ValueChanged<BrowserTab> onTabChange;

  const BrowserLimits({super.key, required this.onTabChange});

  @override
  State<BrowserLimits> createState() => _BrowserLimitsState();
}

class _BrowserLimitsState extends State<BrowserLimits> {
  final _provider = BrowserDataProvider();

  List<WebsiteBasicDetail> _sites = [];
  bool _isLoading = true;
  String _search = '';

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
    try {
      final sites = await _provider.fetchAllWebsites(includeHistorical: true);
      if (!mounted) return;
      setState(() {
        _sites = sites;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setLimit(String domain, Duration limit) async {
    await BrowserDataProvider().updateWebsiteMetadata(
      domain,
      dailyLimit: limit,
    );
    await _loadData();
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

    final withLimits =
        _sites.where((s) => s.dailyLimit > Duration.zero).toList();
    final withoutLimits = _sites
        .where((s) =>
            s.dailyLimit == Duration.zero &&
            (_search.isEmpty || s.matchesSearch(_search)))
        .toList();

    // High usage sites without limits (suggested for limits)
    final suggestions = _sites
        .where((s) =>
            s.dailyLimit == Duration.zero &&
            s.timeSpent >= const Duration(minutes: 20))
        .take(3)
        .toList();

    final exceededCount = withLimits
        .where((s) => s.timeSpent >= s.dailyLimit && s.dailyLimit > Duration.zero)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Summary Metrics Strip ────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 440;
              final card1 = BrowserCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    BrowserGradientIconBox(
                      icon: FluentIcons.time_picker,
                      color: kBrowserAmber,
                      size: 18,
                      boxSize: 38,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Active Limits',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: captionColor?.withValues(alpha: 0.65),
                            ),
                          ),
                          Text(
                            '${withLimits.length} Websites',
                            style: theme.typography.bodyStrong?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              final card2 = BrowserCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    BrowserGradientIconBox(
                      icon: exceededCount > 0
                          ? FluentIcons.warning
                          : FluentIcons.check_mark,
                      color: exceededCount > 0 ? kBrowserRed : kBrowserGreen,
                      size: 18,
                      boxSize: 38,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Limits Status',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: captionColor?.withValues(alpha: 0.65),
                            ),
                          ),
                          Text(
                            exceededCount > 0
                                ? '$exceededCount Exceeded'
                                : 'All Respected',
                            style: theme.typography.bodyStrong?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: exceededCount > 0 ? kBrowserRed : kBrowserGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              if (isNarrow) {
                return Column(
                  children: [
                    card1,
                    const SizedBox(height: 10),
                    card2,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: card1),
                  const SizedBox(width: 12),
                  Expanded(child: card2),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // ── Smart Recommendations (if any) ───────────────────────────
          if (suggestions.isNotEmpty) ...[
            BrowserCard(
              backgroundColor: isDark
                  ? kBrowserAmber.withValues(alpha: 0.08)
                  : kBrowserAmber.withValues(alpha: 0.05),
              borderColor: kBrowserAmber.withValues(alpha: 0.25),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(FluentIcons.lightbulb, size: 15, color: kBrowserAmber),
                      const SizedBox(width: 8),
                      Text(
                        l10n.browserRecommendedLimits,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.browserRecommendedLimitsDesc,
                          style: TextStyle(
                            fontSize: 12,
                            color: captionColor?.withValues(alpha: 0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: suggestions.map((site) {
                      final recLimit = const Duration(minutes: 45);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : theme.inactiveBackgroundColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BrowserDomainAvatar(
                              domain: site.domain,
                              siteName: site.siteName,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  site.displayName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Used ${site.formattedTimeSpent}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: captionColor?.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Button(
                              onPressed: () => _setLimit(site.domain, recLimit),
                              style: ButtonStyle(
                                padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                ),
                              ),
                              child: const Text('Set 45m',
                                  style: TextStyle(fontSize: 11)),
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
          ],

          // ── Active limits ──────────────────────────────────────────────
          BrowserSectionHeader(
            icon: FluentIcons.time_picker,
            title: l10n.browserActiveLimits,
            subtitle: l10n.browserActiveLimitsSubtitle(withLimits.length),
            color: kBrowserAmber,
          ),
          const SizedBox(height: 12),

          if (withLimits.isEmpty)
            BrowserCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: BrowserEmptyState(
                icon: FluentIcons.time_picker,
                title: l10n.browserNoLimitsTitle,
                subtitle: l10n.browserNoLimitsSubtitle,
              ),
            )
          else
            Column(
              children: withLimits.map((site) {
                final double progress = site.dailyLimit > Duration.zero
                    ? (site.timeSpent.inSeconds / site.dailyLimit.inSeconds).clamp(0.0, 1.0)
                    : 0.0;
                final isExceeded = site.timeSpent >= site.dailyLimit;
                final isWarning = progress >= 0.8 && !isExceeded;
                final statusColor = isExceeded
                    ? kBrowserRed
                    : (isWarning ? kBrowserAmber : kBrowserGreen);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BrowserCard(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: LayoutBuilder(
                      builder: (context, cardConstraints) {
                        final isCardNarrow = cardConstraints.maxWidth < 480;

                        if (isCardNarrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  BrowserDomainAvatar(
                                    domain: site.domain,
                                    siteName: site.siteName,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          site.displayName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          site.category,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: captionColor?.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        formatBrowserLimit(site.dailyLimit),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: statusColor,
                                        ),
                                      ),
                                      Text(
                                        l10n.browserTimeUsed(site.formattedTimeSpent),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: captionColor?.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: BrowserProgressBar(
                                      fraction: progress,
                                      color: statusColor,
                                      height: 6,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${(progress * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Button(
                                    onPressed: () => showBrowserLimitPicker(
                                      context,
                                      site,
                                      _loadData,
                                    ),
                                    child: const Text('Edit', style: TextStyle(fontSize: 11)),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    icon: const Icon(FluentIcons.delete, size: 12, color: kBrowserRed),
                                    onPressed: () => _setLimit(site.domain, Duration.zero),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            BrowserDomainAvatar(
                              domain: site.domain,
                              siteName: site.siteName,
                              size: 36,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          site.displayName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      BrowserStatChip(
                                        label: site.category,
                                        color: CategoryMeta.fromName(site.category).color,
                                        icon: CategoryMeta.fromName(site.category).icon,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: BrowserProgressBar(
                                          fraction: progress,
                                          color: statusColor,
                                          height: 6,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${(progress * 100).round()}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatBrowserLimit(site.dailyLimit),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.browserTimeUsed(site.formattedTimeSpent),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: captionColor?.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Action buttons
                            Button(
                              onPressed: () => showBrowserLimitPicker(
                                context,
                                site,
                                _loadData,
                              ),
                              child: const Text('Edit', style: TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            Tooltip(
                              message: 'Remove Limit',
                              child: IconButton(
                                icon: const Icon(FluentIcons.delete, size: 13, color: kBrowserRed),
                                onPressed: () => _setLimit(site.domain, Duration.zero),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 24),

          // ── All Websites (Add Limits) ─────────────────────────────────
          BrowserSectionHeader(
            icon: FluentIcons.globe,
            title: l10n.browserAllWebsites,
            subtitle: 'Quickly configure daily usage limits for any site',
            color: theme.accentColor,
            trailing: BrowserSearchBox(
              placeholder: 'Search websites…',
              onChanged: (v) => setState(() => _search = v),
              width: 220,
            ),
          ),
          const SizedBox(height: 12),

          if (withoutLimits.isEmpty && withLimits.isNotEmpty && _search.isEmpty)
            BrowserCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: BrowserEmptyState(
                icon: FluentIcons.check_mark,
                title: l10n.browserAllSitesHaveLimits,
                subtitle: 'All tracked websites currently have active limits configured.',
              ),
            )
          else if (_sites.isEmpty)
            BrowserCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: BrowserEmptyState(
                icon: FluentIcons.globe,
                title: l10n.browserNoWebsitesTrackedTitle,
                subtitle: kIsWeb
                    ? l10n.browserNoWebsitesTrackedWebSubtitle
                    : l10n.browserNoWebsitesTrackedDesktopSubtitle,
              ),
            )
          else
            BrowserCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: withoutLimits.asMap().entries.map((e) {
                    final i = e.key;
                    final site = e.value;
                    final showDiv = i < withoutLimits.length - 1;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                          child: LayoutBuilder(
                            builder: (context, uncappedConstraints) {
                              final isUncappedNarrow = uncappedConstraints.maxWidth < 480;

                              final avatarAndText = Row(
                                children: [
                                  BrowserDomainAvatar(
                                    domain: site.domain,
                                    siteName: site.siteName,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          site.displayName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${site.formattedTimeSpent} ${l10n.browserToday.toLowerCase()} · ${site.category}',
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

                              final quickLimitRow = Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _QuickLimitChip(
                                    label: '30m',
                                    onTap: () => _setLimit(site.domain, const Duration(minutes: 30)),
                                  ),
                                  const SizedBox(width: 6),
                                  _QuickLimitChip(
                                    label: '1h',
                                    onTap: () => _setLimit(site.domain, const Duration(hours: 1)),
                                  ),
                                  const SizedBox(width: 6),
                                  _QuickLimitChip(
                                    label: '2h',
                                    onTap: () => _setLimit(site.domain, const Duration(hours: 2)),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton(
                                    onPressed: () => showBrowserLimitPicker(
                                      context,
                                      site,
                                      _loadData,
                                    ),
                                    child: Text(l10n.browserCustom, style: const TextStyle(fontSize: 11)),
                                  ),
                                ],
                              );

                              if (isUncappedNarrow) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    avatarAndText,
                                    const SizedBox(height: 8),
                                    quickLimitRow,
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(child: avatarAndText),
                                  const SizedBox(width: 12),
                                  quickLimitRow,
                                ],
                              );
                            },
                          ),
                        ),
                        if (showDiv)
                          Divider(
                            style: DividerThemeData(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : theme.inactiveBackgroundColor.withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickLimitChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickLimitChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : theme.inactiveBackgroundColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : theme.inactiveBackgroundColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.typography.body?.color?.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
