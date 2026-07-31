import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/data_controllers/browser_data_controller.dart';
import 'browser_shared.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final sites = await _provider.fetchAllWebsites();
    if (!mounted) return;
    setState(() {
      _sites = sites;
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

    final withLimits = _sites.where((s) => s.dailyLimit > Duration.zero).toList();
    final withoutLimits = _sites.where((s) => s.dailyLimit == Duration.zero).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Active limits ──────────────────────────────────────────────
          _SectionHeader(
            icon: FluentIcons.time_picker,
            title: l10n.browserActiveLimits,
            subtitle: l10n.browserActiveLimitsSubtitle(withLimits.length),
            color: kBrowserAmber,
          ),
          const SizedBox(height: 10),

          if (withLimits.isEmpty)
            BrowserCard(
              height: 120,
              child: BrowserEmptyState(
                icon: FluentIcons.time_picker,
                title: l10n.browserNoLimitsTitle,
                subtitle: l10n.browserNoLimitsSubtitle,
              ),
            )
          else
            BrowserCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Column(
                  children: withLimits.asMap().entries.map((e) {
                    return _LimitRow(
                      site: e.value,
                      showDivider: e.key < withLimits.length - 1,
                      onChanged: _loadData,
                    );
                  }).toList(),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // ── Add limits ────────────────────────────────────────────────
          _SectionHeader(
            icon: FluentIcons.globe,
            title: l10n.browserAllWebsites,
            subtitle: l10n.browserAllWebsitesSubtitle,
            color: theme.accentColor,
          ),
          const SizedBox(height: 10),

          if (withoutLimits.isEmpty && withLimits.isNotEmpty)
            BrowserCard(
              height: 80,
              child: BrowserEmptyState(
                icon: FluentIcons.check_mark,
                title: l10n.browserAllSitesHaveLimits,
                subtitle: '',
              ),
            )
          else if (_sites.isEmpty)
            BrowserCard(
              height: 120,
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
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Column(
                  children: withoutLimits.asMap().entries.map((e) {
                    return _LimitRow(
                      site: e.value,
                      showDivider: e.key < withoutLimits.length - 1,
                      onChanged: _loadData,
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

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.typography.bodyStrong
                    ?.copyWith(fontWeight: FontWeight.w600)),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: theme.typography.caption?.color?.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Limit row ────────────────────────────────────────────────────────────────

class _LimitRow extends StatefulWidget {
  final WebsiteBasicDetail site;
  final bool showDivider;
  final VoidCallback onChanged;

  const _LimitRow({
    required this.site,
    required this.showDivider,
    required this.onChanged,
  });

  @override
  State<_LimitRow> createState() => _LimitRowState();
}

class _LimitRowState extends State<_LimitRow> {
  bool _hovered = false;

  void _showLimitPicker() {
    final l10n = AppLocalizations.of(context)!;
    final site = widget.site;
    int hours = site.dailyLimit.inHours;
    int minutes = site.dailyLimit.inMinutes % 60;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => ContentDialog(
          title: Text(l10n.browserDailyLimitDialog(site.domain)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.browserDailyLimitDialogDesc),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(l10n.browserHours, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 120,
                        child: NumberBox<int>(
                          value: hours,
                          min: 0,
                          max: 23,
                          onChanged: (v) => setInner(() => hours = v ?? 0),
                          mode: SpinButtonPlacementMode.inline,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(':',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  Column(
                    children: [
                      Text(l10n.minutesLabel, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 120,
                        child: NumberBox<int>(
                          value: minutes,
                          min: 0,
                          max: 59,
                          onChanged: (v) => setInner(() => minutes = v ?? 0),
                          mode: SpinButtonPlacementMode.inline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Button(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancelButton),
            ),
            if (site.dailyLimit > Duration.zero)
              Button(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await BrowserDataProvider().updateWebsiteMetadata(
                    site.domain,
                    dailyLimit: Duration.zero,
                  );
                  widget.onChanged();
                },
                child: Text(l10n.browserRemoveLimit),
              ),
            FilledButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final limit =
                    Duration(hours: hours, minutes: minutes);
                await BrowserDataProvider().updateWebsiteMetadata(
                  site.domain,
                  dailyLimit: limit,
                );
                widget.onChanged();
              },
              child: Text(l10n.saveButton),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final site = widget.site;
    final hasLimit = site.dailyLimit > Duration.zero;

    // Progress: how much of the limit has been consumed today
    double progress = 0;
    if (hasLimit && site.timeSpent > Duration.zero) {
      progress =
          (site.timeSpent.inSeconds / site.dailyLimit.inSeconds).clamp(0.0, 1.0);
    }
    final overLimit = progress >= 1.0;
    final limitColor = overLimit
        ? kBrowserRed
        : progress > 0.75
            ? kBrowserAmber
            : kBrowserGreen;

    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: _showLimitPicker,
            child: AnimatedContainer(
              duration: kBrowserHoverDuration,
              color: _hovered
                  ? theme.inactiveBackgroundColor.withValues(alpha: 0.25)
                  : Colors.transparent,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(FluentIcons.globe,
                        size: 14,
                        color: theme.accentColor.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(site.displayName,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        if (hasLimit) ...[
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
                                widthFactor: progress,
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: limitColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (hasLimit)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatLimit(site.dailyLimit),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: limitColor,
                          ),
                        ),
                        Text(
                          l10n.browserTimeUsed(site.formattedTimeSpent),
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.typography.caption?.color
                                ?.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      l10n.browserSetLimit,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.accentColor.withValues(alpha: 0.7),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(FluentIcons.chevron_right,
                      size: 12,
                      color: theme.typography.caption?.color
                          ?.withValues(alpha: 0.4)),
                ],
              ),
            ),
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
    );
  }

  String _formatLimit(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }
}
