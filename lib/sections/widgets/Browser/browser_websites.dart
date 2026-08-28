import 'dart:async';
import 'dart:math' show max;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/data_controllers/browser_data_controller.dart';
import 'package:screentime/sections/controller/services/private_mode_service.dart';
import 'package:screentime/web/web_private_mode_service.dart'
    if (dart.library.io) 'package:screentime/web/web_private_mode_service_stub.dart';
import 'package:screentime/app_design.dart';
import 'browser_shared.dart';

// ─── Shared limit picker (used by both table row and mobile card) ────────────

String formatBrowserLimit(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h > 0 && m > 0) return '${h}h ${m}m';
  if (h > 0) return '${h}h';
  return '${m}m';
}

/// Opens the daily limit picker dialog — same UX as BrowserLimits tab.
/// Shared by [_WebsiteRow] (desktop table) and [_WebsiteCard] (mobile list).
void showBrowserLimitPicker(
  BuildContext context,
  WebsiteBasicDetail site,
  VoidCallback onMetadataChanged,
) {
  final l10n = AppLocalizations.of(context)!;
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
                    Text(l10n.browserHours,
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 100,
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
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                Column(
                  children: [
                    Text(l10n.minutesLabel,
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 100,
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
                onMetadataChanged();
              },
              child: Text(l10n.browserRemoveLimit),
            ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final limit = Duration(hours: hours, minutes: minutes);
              await BrowserDataProvider().updateWebsiteMetadata(
                site.domain,
                dailyLimit: limit,
              );
              onMetadataChanged();
            },
            child: Text(l10n.saveButton),
          ),
        ],
      ),
    ),
  );
}

class BrowserWebsites extends StatefulWidget {
  final ValueChanged<BrowserTab> onTabChange;

  const BrowserWebsites({super.key, required this.onTabChange});

  @override
  State<BrowserWebsites> createState() => _BrowserWebsitesState();
}

class _BrowserWebsitesState extends State<BrowserWebsites> {
  final _provider = BrowserDataProvider();

  List<WebsiteBasicDetail> _allSites = [];
  List<String> _categories = ['All'];
  bool _isLoading = true;
  String _search = '';
  String _categoryFilter = 'All';
  String _trackingFilter = 'all';
  String _productivityFilter = 'all';
  String _sortColumn = 'timeSpent';
  bool _sortAscending = false;
  Timer? _debounce;

  void _onPrivateModeChanged() {
    if (mounted) _loadData();
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WebPrivateModeService().addListener(_onPrivateModeChanged);
    } else {
      PrivateModeController().addListener(_onPrivateModeChanged);
    }
    _provider.addListener(_loadData);
    _loadData();
  }

  Future<void> _loadData() async {
    final sites = await _provider.fetchAllWebsites();
    final cats = await _provider.fetchAllCategories();
    if (!mounted) return;
    setState(() {
      _allSites = sites;
      _categories = cats;
      _isLoading = false;
    });
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _search = v);
    });
  }

  void _showSiteDetail(BuildContext context, WebsiteBasicDetail site) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _WebsiteDetailDialog(site: site),
    );
  }

  void _onSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = false;
      }
    });
  }

  List<WebsiteBasicDetail> get _filtered {
    final list = _allSites
        .where((s) =>
            s.matchesSearch(_search) &&
            s.matchesCategory(_categoryFilter) &&
            s.matchesTracking(_trackingFilter) &&
            s.matchesProductivity(_productivityFilter))
        .toList();

    list.sort((a, b) {
      int cmp;
      switch (_sortColumn) {
        case 'domain':
          cmp = a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
          break;
        case 'category':
          cmp = a.category.toLowerCase().compareTo(b.category.toLowerCase());
          break;
        case 'timeSpent':
          cmp = a.timeSpent.compareTo(b.timeSpent);
          break;
        case 'visits':
          cmp = a.visits.compareTo(b.visits);
          break;
        case 'limit':
          cmp = a.dailyLimit.compareTo(b.dailyLimit);
          break;
        case 'productivity':
          cmp = (a.isProductive ? 1 : 0).compareTo(b.isProductive ? 1 : 0);
          break;
        case 'tracking':
          cmp = (a.isTracking ? 1 : 0).compareTo(b.isTracking ? 1 : 0);
          break;
        default:
          cmp = a.timeSpent.compareTo(b.timeSpent);
      }
      return _sortAscending ? cmp : -cmp;
    });
    return list;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (kIsWeb) {
      WebPrivateModeService().removeListener(_onPrivateModeChanged);
    } else {
      PrivateModeController().removeListener(_onPrivateModeChanged);
    }
    _provider.removeListener(_loadData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final filtered = _filtered;

    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    // Summary metrics
    final totalWebSecs = _allSites.fold<int>(0, (sum, s) => sum + s.timeSpent.inSeconds);
    final productiveSecs = _allSites
        .where((s) => s.isProductive)
        .fold<int>(0, (sum, s) => sum + s.timeSpent.inSeconds);
    final activeLimits = _allSites.where((s) => s.dailyLimit > Duration.zero).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 720;
        final isNarrowFilters = width < 780;

        final summaryCards = [
          _MiniSummaryCard(
            icon: FluentIcons.globe,
            label: 'Total Sites',
            value: '${_allSites.length}',
            color: theme.accentColor,
          ),
          _MiniSummaryCard(
            icon: FluentIcons.timer,
            label: 'Total Web Time',
            value: Duration(seconds: totalWebSecs).toHourMinuteFormat(),
            color: kBrowserBlue,
          ),
          _MiniSummaryCard(
            icon: FluentIcons.check_mark,
            label: 'Productive Time',
            value: Duration(seconds: productiveSecs).toHourMinuteFormat(),
            color: kBrowserGreen,
          ),
          _MiniSummaryCard(
            icon: FluentIcons.time_picker,
            label: 'Active Limits',
            value: '$activeLimits Active',
            color: kBrowserAmber,
          ),
        ];

        Widget summaryStrip;
        if (width >= 620) {
          summaryStrip = Row(
            children: [
              for (int i = 0; i < summaryCards.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: summaryCards[i]),
              ],
            ],
          );
        } else if (width >= 380) {
          summaryStrip = Column(
            children: [
              Row(
                children: [
                  Expanded(child: summaryCards[0]),
                  const SizedBox(width: 12),
                  Expanded(child: summaryCards[1]),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: summaryCards[2]),
                  const SizedBox(width: 12),
                  Expanded(child: summaryCards[3]),
                ],
              ),
            ],
          );
        } else {
          summaryStrip = Column(
            children: [
              for (int i = 0; i < summaryCards.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                summaryCards[i],
              ],
            ],
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 24,
            vertical: isMobile ? 14 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              summaryStrip,
              const SizedBox(height: 14),

              // ── Filters bar ────────────────────────────────────────────────
              BrowserCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: isNarrowFilters
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          BrowserSearchBox(
                            placeholder: l10n.browserSearchPlaceholder,
                            onChanged: _onSearch,
                            width: double.infinity,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _FilterCombo<String>(
                                value: _categoryFilter,
                                items: _categories,
                                label: (v) => v,
                                onChanged: (v) =>
                                    setState(() => _categoryFilter = v),
                              ),
                              _FilterCombo<String>(
                                value: _trackingFilter,
                                items: const ['all', 'tracked', 'untracked'],
                                label: (v) => switch (v) {
                                  'tracked' => l10n.browserFilterTracked,
                                  'untracked' => l10n.browserFilterUntracked,
                                  _ => l10n.browserFilterAllTracking,
                                },
                                onChanged: (v) =>
                                    setState(() => _trackingFilter = v),
                              ),
                              _FilterCombo<String>(
                                value: _productivityFilter,
                                items: const ['all', 'productive', 'unproductive'],
                                label: (v) => switch (v) {
                                  'productive' => l10n.productive,
                                  'unproductive' => l10n.browserFilterUnproductive,
                                  _ => l10n.browserFilterAllTypes,
                                },
                                onChanged: (v) =>
                                    setState(() => _productivityFilter = v),
                              ),
                              BrowserIconButton(
                                tooltip: l10n.refresh,
                                icon: FluentIcons.refresh,
                                onPressed: _loadData,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  l10n.browserWebsiteCount(filtered.length),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.typography.caption?.color?.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: BrowserSearchBox(
                              placeholder: l10n.browserSearchPlaceholder,
                              onChanged: _onSearch,
                              width: double.infinity,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _FilterCombo<String>(
                            value: _categoryFilter,
                            items: _categories,
                            label: (v) => v,
                            onChanged: (v) => setState(() => _categoryFilter = v),
                          ),
                          const SizedBox(width: 8),
                          _FilterCombo<String>(
                            value: _trackingFilter,
                            items: const ['all', 'tracked', 'untracked'],
                            label: (v) => switch (v) {
                              'tracked' => l10n.browserFilterTracked,
                              'untracked' => l10n.browserFilterUntracked,
                              _ => l10n.browserFilterAllTracking,
                            },
                            onChanged: (v) => setState(() => _trackingFilter = v),
                          ),
                          const SizedBox(width: 8),
                          _FilterCombo<String>(
                            value: _productivityFilter,
                            items: const ['all', 'productive', 'unproductive'],
                            label: (v) => switch (v) {
                              'productive' => l10n.productive,
                              'unproductive' => l10n.browserFilterUnproductive,
                              _ => l10n.browserFilterAllTypes,
                            },
                            onChanged: (v) =>
                                setState(() => _productivityFilter = v),
                          ),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              l10n.browserWebsiteCount(filtered.length),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.typography.caption?.color?.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          BrowserIconButton(
                            tooltip: l10n.refresh,
                            icon: FluentIcons.refresh,
                            onPressed: _loadData,
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 12),

              // ── Table / card list ────────────────────────────────────────────
              Expanded(
                child: isMobile
                    ? (filtered.isEmpty
                        ? BrowserCard(
                            child: BrowserEmptyState(
                              icon: FluentIcons.globe,
                              title: l10n.browserNoWebsitesTitle,
                              subtitle: l10n.browserNoWebsitesDesktopSubtitle,
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _WebsiteCard(
                                site: filtered[i],
                                onMetadataChanged: _loadData,
                                onTap: () => _showSiteDetail(context, filtered[i]),
                              ),
                            ),
                          ))
                    : BrowserCard(
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                          child: Column(
                            children: [
                              _TableHeader(
                                sortColumn: _sortColumn,
                                sortAscending: _sortAscending,
                                onSort: _onSort,
                              ),
                              Expanded(
                                child: filtered.isEmpty
                                    ? BrowserEmptyState(
                                        icon: FluentIcons.globe,
                                        title: l10n.browserNoWebsitesTitle,
                                        subtitle:
                                            l10n.browserNoWebsitesDesktopSubtitle,
                                      )
                                    : ListView.builder(
                                        itemCount: filtered.length,
                                        itemBuilder: (context, i) => _WebsiteRow(
                                          site: filtered[i],
                                          totalWebSecs: totalWebSecs,
                                          showDivider: i < filtered.length - 1,
                                          onMetadataChanged: _loadData,
                                          onTap: () =>
                                              _showSiteDetail(context, filtered[i]),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Mini Summary Card ────────────────────────────────────────────────────────

class _MiniSummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniSummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final captionColor = theme.typography.caption?.color;

    return BrowserCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: captionColor?.withValues(alpha: 0.65),
                  ),
                ),
                Text(
                  value,
                  style: theme.typography.bodyStrong?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Table header with Interactive Sorting ────────────────────────────────────

class _TableHeader extends StatelessWidget {
  final String sortColumn;
  final bool sortAscending;
  final ValueChanged<String> onSort;

  const _TableHeader({
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final color = theme.typography.caption?.color?.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : theme.inactiveBackgroundColor.withValues(alpha: 0.35),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : theme.inactiveBackgroundColor.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 42),
          Expanded(
            flex: 3,
            child: _SortableHeaderCell(
              label: l10n.browserColumnDomain,
              column: 'domain',
              activeColumn: sortColumn,
              ascending: sortAscending,
              onTap: () => onSort('domain'),
              color: color,
            ),
          ),
          Expanded(
            flex: 2,
            child: _SortableHeaderCell(
              label: l10n.category,
              column: 'category',
              activeColumn: sortColumn,
              ascending: sortAscending,
              onTap: () => onSort('category'),
              color: color,
            ),
          ),
          SizedBox(
            width: 95,
            child: _SortableHeaderCell(
              label: l10n.browserColumnTimeToday,
              column: 'timeSpent',
              activeColumn: sortColumn,
              ascending: sortAscending,
              onTap: () => onSort('timeSpent'),
              align: TextAlign.right,
              color: color,
            ),
          ),
          SizedBox(
            width: 60,
            child: _SortableHeaderCell(
              label: l10n.browserColumnVisits,
              column: 'visits',
              activeColumn: sortColumn,
              ascending: sortAscending,
              onTap: () => onSort('visits'),
              align: TextAlign.center,
              color: color,
            ),
          ),
          SizedBox(
            width: 95,
            child: _SortableHeaderCell(
              label: l10n.browserColumnDailyLimit,
              column: 'limit',
              activeColumn: sortColumn,
              ascending: sortAscending,
              onTap: () => onSort('limit'),
              align: TextAlign.center,
              color: color,
            ),
          ),
          SizedBox(
            width: 100,
            child: _SortableHeaderCell(
              label: l10n.productive,
              column: 'productivity',
              activeColumn: sortColumn,
              ascending: sortAscending,
              onTap: () => onSort('productivity'),
              align: TextAlign.center,
              color: color,
            ),
          ),
          SizedBox(
            width: 75,
            child: _SortableHeaderCell(
              label: l10n.browserColumnTracking,
              column: 'tracking',
              activeColumn: sortColumn,
              ascending: sortAscending,
              onTap: () => onSort('tracking'),
              align: TextAlign.center,
              color: color,
            ),
          ),
          const SizedBox(width: 36), // Action button column spacer
        ],
      ),
    );
  }
}

class _SortableHeaderCell extends StatelessWidget {
  final String label;
  final String column;
  final String activeColumn;
  final bool ascending;
  final VoidCallback onTap;
  final TextAlign align;
  final Color? color;

  const _SortableHeaderCell({
    required this.label,
    required this.column,
    required this.activeColumn,
    required this.ascending,
    required this.onTap,
    this.align = TextAlign.left,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isSelected = column == activeColumn;
    final activeColor = isSelected ? theme.accentColor : color;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: align == TextAlign.right
              ? MainAxisAlignment.end
              : (align == TextAlign.center
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start),
          children: [
            Flexible(
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: 0.2,
                  color: activeColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              isSelected
                  ? (ascending ? FluentIcons.chevron_up : FluentIcons.chevron_down)
                  : FluentIcons.sort,
              size: 10,
              color: isSelected
                  ? theme.accentColor
                  : color?.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Website row ──────────────────────────────────────────────────────────────

class _WebsiteRow extends StatefulWidget {
  final WebsiteBasicDetail site;
  final int totalWebSecs;
  final bool showDivider;
  final VoidCallback onMetadataChanged;
  final VoidCallback onTap;

  const _WebsiteRow({
    required this.site,
    required this.totalWebSecs,
    required this.showDivider,
    required this.onMetadataChanged,
    required this.onTap,
  });

  @override
  State<_WebsiteRow> createState() => _WebsiteRowState();
}

class _WebsiteRowState extends State<_WebsiteRow> {
  bool _hovered = false;
  bool _editing = false;
  late TextEditingController _nameController;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.site.displayName);
  }

  @override
  void didUpdateWidget(_WebsiteRow old) {
    super.didUpdateWidget(old);
    if (old.site.displayName != widget.site.displayName && !_editing) {
      _nameController.text = widget.site.displayName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveEdit() async {
    final newName = _nameController.text.trim();
    setState(() => _editing = false);
    if (newName == widget.site.displayName) return;
    await BrowserDataProvider().updateWebsiteMetadata(
      widget.site.domain,
      siteName: newName.isEmpty ? '' : newName,
    );
    widget.onMetadataChanged();
  }

  void _startEdit() {
    setState(() {
      _editing = true;
      _nameController.text = widget.site.displayName;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _nameController.selection = TextSelection(
          baseOffset: 0, extentOffset: _nameController.text.length);
    });
  }

  void _showLimitPicker() {
    showBrowserLimitPicker(context, widget.site, widget.onMetadataChanged);
  }

  Future<void> _launchSite() async {
    final uri = Uri.parse(
        widget.site.domain.startsWith('http') ? widget.site.domain : 'https://${widget.site.domain}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final captionColor = theme.typography.caption?.color;
    final site = widget.site;
    final hasDifferentName =
        site.siteName.isNotEmpty && site.siteName != site.domain;
    final catMeta = CategoryMeta.fromName(site.category);

    // Limit progress
    final hasLimit = site.dailyLimit > Duration.zero;
    double limitProgress = 0;
    if (hasLimit && site.timeSpent > Duration.zero) {
      limitProgress = (site.timeSpent.inSeconds / site.dailyLimit.inSeconds)
          .clamp(0.0, 1.0);
    }
    final overLimit = limitProgress >= 1.0;
    final limitColor = overLimit
        ? kBrowserRed
        : limitProgress > 0.75
            ? kBrowserAmber
            : kBrowserGreen;

    final sharePct = widget.totalWebSecs > 0
        ? (site.timeSpent.inSeconds / widget.totalWebSecs * 100).round()
        : 0;

    return Column(
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: AnimatedContainer(
              duration: kBrowserHoverDuration,
              color: _hovered
                  ? (isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : theme.inactiveBackgroundColor.withValues(alpha: 0.28))
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Domain Avatar
                  BrowserDomainAvatar(
                    domain: site.domain,
                    siteName: site.siteName,
                    size: 30,
                  ),
                  const SizedBox(width: 12),

                  // Domain / display name
                  Expanded(
                    flex: 3,
                    child: _editing
                        ? SizedBox(
                            height: 28,
                            child: TextBox(
                              controller: _nameController,
                              focusNode: _focusNode,
                              style: const TextStyle(fontSize: 13),
                              onSubmitted: (_) => _saveEdit(),
                              suffix: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(FluentIcons.check_mark,
                                        size: 12),
                                    onPressed: _saveEdit,
                                  ),
                                  IconButton(
                                    icon: const Icon(FluentIcons.cancel,
                                        size: 12),
                                    onPressed: () =>
                                        setState(() => _editing = false),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      site.displayName,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (hasDifferentName)
                                      Text(
                                        site.domain,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: captionColor?.withValues(
                                              alpha: 0.5),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              if (site.limitStatus)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Tooltip(
                                    message: 'Limit enforced',
                                    child: Icon(
                                      FluentIcons.lock,
                                      size: 12,
                                      color: kBrowserAmber,
                                    ),
                                  ),
                                ),
                              if (_hovered)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Tooltip(
                                    message: l10n.browserEditSiteName,
                                    child: IconButton(
                                      icon: Icon(FluentIcons.edit,
                                          size: 12,
                                          color: captionColor?.withValues(
                                              alpha: 0.6)),
                                      onPressed: _startEdit,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),

                  // Category chip
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 135),
                        child: BrowserStatChip(
                          label: site.category,
                          color: catMeta.color,
                          icon: catMeta.icon,
                        ),
                      ),
                    ),
                  ),

                  // Time Spent Today
                  SizedBox(
                    width: 95,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          site.formattedTimeSpent,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: site.timeSpent > Duration.zero
                                ? theme.accentColor
                                : captionColor?.withValues(alpha: 0.4),
                          ),
                        ),
                        if (sharePct > 0)
                          Text(
                            '$sharePct% of web',
                            style: TextStyle(
                              fontSize: 10,
                              color: captionColor?.withValues(alpha: 0.55),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Visits
                  SizedBox(
                    width: 60,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : theme.inactiveBackgroundColor.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${site.visits}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: captionColor?.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Daily Limit column ──────────────────────────────────────
                  SizedBox(
                    width: 95,
                    child: GestureDetector(
                      onTap: _showLimitPicker,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Tooltip(
                          message: hasLimit
                              ? 'Click to edit daily limit'
                              : 'Click to set a daily limit',
                          child: hasLimit
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      child: BrowserProgressBar(
                                        fraction: limitProgress,
                                        color: limitColor,
                                        height: 4,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      formatBrowserLimit(site.dailyLimit),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: limitColor,
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.1)
                                            : theme.inactiveBackgroundColor.withValues(alpha: 0.6),
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      l10n.browserSetLimit,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                        color: captionColor?.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  // Productivity toggle chip
                  SizedBox(
                    width: 100,
                    child: Center(
                      child: ProductivityChip(
                        isProductive: site.isProductive,
                        onTap: () async {
                          await BrowserDataProvider().updateWebsiteMetadata(
                            site.domain,
                            isProductive: !site.isProductive,
                          );
                          widget.onMetadataChanged();
                        },
                      ),
                    ),
                  ),

                  // Tracking toggle
                  SizedBox(
                    width: 75,
                    child: Center(
                      child: _CompactToggle(
                        value: site.isTracking,
                        activeColor: theme.accentColor,
                        onChanged: (v) async {
                          await BrowserDataProvider().updateWebsiteMetadata(
                            site.domain,
                            isTracking: v,
                          );
                          widget.onMetadataChanged();
                        },
                      ),
                    ),
                  ),

                  // Quick Action (Launch)
                  SizedBox(
                    width: 36,
                    child: Tooltip(
                      message: l10n.browserOpenInBrowser,
                      child: IconButton(
                        icon: Icon(
                          FluentIcons.open_in_new_window,
                          size: 13,
                          color: _hovered
                              ? theme.accentColor
                              : captionColor?.withValues(alpha: 0.35),
                        ),
                        onPressed: _launchSite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.showDivider)
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
  }
}

// ─── Website card (mobile list view) ──────────────────────────────────────────

class _WebsiteCard extends StatefulWidget {
  final WebsiteBasicDetail site;
  final VoidCallback onMetadataChanged;
  final VoidCallback onTap;

  const _WebsiteCard({
    required this.site,
    required this.onMetadataChanged,
    required this.onTap,
  });

  @override
  State<_WebsiteCard> createState() => _WebsiteCardState();
}

class _WebsiteCardState extends State<_WebsiteCard> {
  bool _editing = false;
  late TextEditingController _nameController;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.site.displayName);
  }

  @override
  void didUpdateWidget(_WebsiteCard old) {
    super.didUpdateWidget(old);
    if (old.site.displayName != widget.site.displayName && !_editing) {
      _nameController.text = widget.site.displayName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveEdit() async {
    final newName = _nameController.text.trim();
    setState(() => _editing = false);
    if (newName == widget.site.displayName) return;
    await BrowserDataProvider().updateWebsiteMetadata(
      widget.site.domain,
      siteName: newName.isEmpty ? '' : newName,
    );
    widget.onMetadataChanged();
  }

  void _startEdit() {
    setState(() {
      _editing = true;
      _nameController.text = widget.site.displayName;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _nameController.selection = TextSelection(
          baseOffset: 0, extentOffset: _nameController.text.length);
    });
  }

  void _showLimitPicker() {
    showBrowserLimitPicker(context, widget.site, widget.onMetadataChanged);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final captionColor = theme.typography.caption?.color;
    final site = widget.site;
    final hasDifferentName =
        site.siteName.isNotEmpty && site.siteName != site.domain;

    final hasLimit = site.dailyLimit > Duration.zero;
    double limitProgress = 0;
    if (hasLimit && site.timeSpent > Duration.zero) {
      limitProgress = (site.timeSpent.inSeconds / site.dailyLimit.inSeconds)
          .clamp(0.0, 1.0);
    }
    final overLimit = limitProgress >= 1.0;
    final limitColor = overLimit
        ? kBrowserRed
        : limitProgress > 0.75
            ? kBrowserAmber
            : kBrowserGreen;

    return BrowserCard(
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BrowserDomainAvatar(
                  domain: site.domain,
                  siteName: site.siteName,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _editing
                      ? SizedBox(
                          height: 30,
                          child: TextBox(
                            controller: _nameController,
                            focusNode: _focusNode,
                            style: const TextStyle(fontSize: 13),
                            onSubmitted: (_) => _saveEdit(),
                            suffix: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(FluentIcons.check_mark,
                                      size: 12),
                                  onPressed: _saveEdit,
                                ),
                                IconButton(
                                  icon:
                                      const Icon(FluentIcons.cancel, size: 12),
                                  onPressed: () =>
                                      setState(() => _editing = false),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    site.displayName,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (hasDifferentName)
                                    Text(
                                      site.domain,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: captionColor?.withValues(
                                            alpha: 0.5),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            if (site.limitStatus)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Tooltip(
                                  message: 'Limit enforced',
                                  child: Icon(
                                    FluentIcons.lock,
                                    size: 13,
                                    color: kBrowserAmber,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Tooltip(
                                message: l10n.browserEditSiteName,
                                child: IconButton(
                                  icon: Icon(FluentIcons.edit,
                                      size: 13,
                                      color:
                                          captionColor?.withValues(alpha: 0.5)),
                                  onPressed: _startEdit,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                BrowserStatChip(
                  label: site.category,
                  color: CategoryMeta.fromName(site.category).color,
                  icon: CategoryMeta.fromName(site.category).icon,
                ),
                _MetricPill(
                  icon: FluentIcons.timer,
                  label: site.formattedTimeSpent,
                  color: theme.accentColor,
                ),
                _MetricPill(
                  icon: FluentIcons.view,
                  label:
                      '${site.visits} ${l10n.browserColumnVisits.toLowerCase()}',
                  color: captionColor?.withValues(alpha: 0.7) ?? kBrowserPurple,
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _showLimitPicker,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        theme.inactiveBackgroundColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(FluentIcons.time_picker,
                          size: 13,
                          color: captionColor?.withValues(alpha: 0.6)),
                      const SizedBox(width: 6),
                      Text(
                        'Daily Limit',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: captionColor?.withValues(alpha: 0.6),
                        ),
                      ),
                      const Spacer(),
                      if (hasLimit) ...[
                        SizedBox(
                          width: 60,
                          child: Stack(
                            children: [
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: theme.inactiveBackgroundColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: limitProgress,
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
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatBrowserLimit(site.dailyLimit),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: limitColor,
                          ),
                        ),
                      ] else
                        Text(
                          'No limit',
                          style: TextStyle(
                            fontSize: 12,
                            color: captionColor?.withValues(alpha: 0.35),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ToggleRow(
                    label: l10n.productive,
                    value: site.isProductive,
                    activeColor: kBrowserGreen,
                    onChanged: (v) async {
                      await BrowserDataProvider().updateWebsiteMetadata(
                        site.domain,
                        isProductive: v,
                      );
                      widget.onMetadataChanged();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ToggleRow(
                    label: l10n.browserColumnTracking,
                    value: site.isTracking,
                    activeColor: theme.accentColor,
                    onChanged: (v) async {
                      await BrowserDataProvider().updateWebsiteMetadata(
                        site.domain,
                        isTracking: v,
                      );
                      widget.onMetadataChanged();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetricPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.typography.caption?.color?.withValues(alpha: 0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        _CompactToggle(
          value: value,
          activeColor: activeColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ─── Website detail dialog ────────────────────────────────────────────────────

class _WebsiteDetailDialog extends StatefulWidget {
  final WebsiteBasicDetail site;
  const _WebsiteDetailDialog({required this.site});

  @override
  State<_WebsiteDetailDialog> createState() => _WebsiteDetailDialogState();
}

class _WebsiteDetailDialogState extends State<_WebsiteDetailDialog> {
  final _provider = BrowserDataProvider();
  List<({String date, Duration timeSpent, int visits})>? _history;
  late WebsiteBasicDetail _site;
  late bool _isPrivate;
  late bool _isProductive;
  late bool _isTracking;

  @override
  void initState() {
    super.initState();
    _site = widget.site;
    _isPrivate = widget.site.isPrivate;
    _isProductive = widget.site.isProductive;
    _isTracking = widget.site.isTracking;
    _load();
  }

  Future<void> _load() async {
    final h = await _provider.fetchSiteHistory(_site.domain, days: 7);
    if (mounted) setState(() => _history = h);
  }

  Future<void> _setPrivate(bool value) async {
    setState(() => _isPrivate = value);
    await _provider.updateWebsiteMetadata(_site.domain, isPrivate: value);
  }

  Future<void> _setProductive(bool value) async {
    setState(() => _isProductive = value);
    await _provider.updateWebsiteMetadata(_site.domain, isProductive: value);
  }

  Future<void> _setTracking(bool value) async {
    setState(() => _isTracking = value);
    await _provider.updateWebsiteMetadata(_site.domain, isTracking: value);
  }

  Future<void> _launchSite() async {
    final uri = Uri.parse(
      _site.domain.startsWith('http') ? _site.domain : 'https://${_site.domain}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openLimitPicker() {
    showBrowserLimitPicker(context, _site, () async {
      final updated = await _provider.fetchAllWebsites();
      final fresh = updated.firstWhere(
        (s) => s.domain == _site.domain,
        orElse: () => _site,
      );
      if (mounted) setState(() => _site = fresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final site = _site;
    final captionColor = theme.typography.caption?.color;
    final history = _history;
    final catMeta = CategoryMeta.fromName(site.category);

    // Limit progress calculation
    final hasLimit = site.dailyLimit > Duration.zero;
    double limitProgress = 0;
    if (hasLimit && site.timeSpent > Duration.zero) {
      limitProgress = (site.timeSpent.inSeconds / site.dailyLimit.inSeconds).clamp(0.0, 1.0);
    }
    final overLimit = limitProgress >= 1.0;
    final limitColor = overLimit
        ? kBrowserRed
        : (limitProgress > 0.75 ? kBrowserAmber : kBrowserGreen);

    // 7-day totals
    Duration total7dTime = Duration.zero;
    int total7dVisits = 0;
    if (history != null) {
      for (final e in history) {
        total7dTime += e.timeSpent;
        total7dVisits += e.visits;
      }
    }

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 580),
      title: Row(
        children: [
          BrowserDomainAvatar(
            domain: site.domain,
            siteName: site.displayName,
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  site.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  site.domain,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: captionColor?.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          BrowserStatChip(
            label: site.category,
            color: catMeta.color,
            icon: catMeta.icon,
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Open in Browser',
            child: IconButton(
              icon: Icon(
                FluentIcons.open_in_new_window,
                size: 14,
                color: theme.accentColor,
              ),
              onPressed: _launchSite,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 3 Hero Metric Cards ─────────────────────────────────────
            LayoutBuilder(
              builder: (context, metricConstraints) {
                final isNarrow = metricConstraints.maxWidth < 460;

                final timeTodayCard = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: kBrowserBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                    border: Border.all(color: kBrowserBlue.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(FluentIcons.timer, size: 13, color: kBrowserBlue),
                          const SizedBox(width: 6),
                          Text(
                            l10n.browserDetailTimeToday,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: captionColor?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        site.formattedTimeSpent,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: site.timeSpent > Duration.zero
                              ? kBrowserBlue
                              : theme.typography.body?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.browserTotalTimeToday,
                        style: TextStyle(
                          fontSize: 10,
                          color: captionColor?.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                );

                final visitsTodayCard = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: kBrowserPurple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                    border: Border.all(color: kBrowserPurple.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(FluentIcons.view, size: 13, color: kBrowserPurple),
                          const SizedBox(width: 6),
                          Text(
                            l10n.browserDetailVisitsToday,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: captionColor?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${site.visits}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: site.visits > 0
                              ? kBrowserPurple
                              : theme.typography.body?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.browserPageSessions,
                        style: TextStyle(
                          fontSize: 10,
                          color: captionColor?.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                );

                final dailyLimitCard = GestureDetector(
                  onTap: _openLimitPicker,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: (hasLimit ? limitColor : theme.accentColor)
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                        border: Border.all(
                          color: (hasLimit ? limitColor : theme.accentColor)
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                FluentIcons.time_picker,
                                size: 13,
                                color: hasLimit ? limitColor : theme.accentColor,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  l10n.browserDetailDailyLimit,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: captionColor?.withValues(alpha: 0.7),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                FluentIcons.edit,
                                size: 10,
                                color: captionColor?.withValues(alpha: 0.4),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            hasLimit ? formatBrowserLimit(site.dailyLimit) : l10n.noLimit,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: hasLimit ? limitColor : theme.typography.body?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (hasLimit)
                            BrowserProgressBar(
                              fraction: limitProgress,
                              color: limitColor,
                              height: 4,
                            )
                          else
                            Text(
                              l10n.browserClickToSetLimitPrompt,
                              style: TextStyle(
                                fontSize: 10,
                                color: captionColor?.withValues(alpha: 0.5),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      timeTodayCard,
                      const SizedBox(height: 8),
                      visitsTodayCard,
                      const SizedBox(height: 8),
                      dailyLimitCard,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: timeTodayCard),
                    const SizedBox(width: 10),
                    Expanded(child: visitsTodayCard),
                    const SizedBox(width: 10),
                    Expanded(child: dailyLimitCard),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),

            // ── Quick Settings / Preferences Panel ──────────────────────
            LayoutBuilder(
              builder: (context, prefConstraints) {
                final isNarrow = prefConstraints.maxWidth < 460;

                if (isNarrow) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : theme.inactiveBackgroundColor.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : theme.inactiveBackgroundColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${l10n.browserClassification}:',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: captionColor?.withValues(alpha: 0.7),
                              ),
                            ),
                            ProductivityChip(
                              isProductive: _isProductive,
                              onTap: () => _setProductive(!_isProductive),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FluentIcons.lock,
                                  size: 12,
                                  color: _isPrivate
                                      ? kBrowserRed
                                      : captionColor?.withValues(alpha: 0.5),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.markAsPrivate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _isPrivate ? FontWeight.w600 : FontWeight.w500,
                                    color: _isPrivate ? kBrowserRed : theme.typography.body?.color,
                                  ),
                                ),
                              ],
                            ),
                            _CompactToggle(
                              value: _isPrivate,
                              activeColor: kBrowserRed,
                              onChanged: _setPrivate,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.browserColumnTracking,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: theme.typography.body?.color,
                              ),
                            ),
                            _CompactToggle(
                              value: _isTracking,
                              activeColor: theme.accentColor,
                              onChanged: _setTracking,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : theme.inactiveBackgroundColor.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : theme.inactiveBackgroundColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Productivity status
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              '${l10n.browserClassification}:',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: captionColor?.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ProductivityChip(
                              isProductive: _isProductive,
                              onTap: () => _setProductive(!_isProductive),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : theme.inactiveBackgroundColor.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 14),

                      // Private Toggle
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FluentIcons.lock,
                            size: 12,
                            color: _isPrivate
                                ? kBrowserRed
                                : captionColor?.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.markAsPrivate,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _isPrivate ? FontWeight.w600 : FontWeight.w500,
                              color: _isPrivate ? kBrowserRed : theme.typography.body?.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CompactToggle(
                            value: _isPrivate,
                            activeColor: kBrowserRed,
                            onChanged: _setPrivate,
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 1,
                        height: 24,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : theme.inactiveBackgroundColor.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 14),

                      // Tracking Toggle
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.browserColumnTracking,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.typography.body?.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CompactToggle(
                            value: _isTracking,
                            activeColor: theme.accentColor,
                            onChanged: _setTracking,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 18),

            // ── 7-Day Activity & Visits Trend ───────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      FluentIcons.bar_chart_vertical,
                      size: 14,
                      color: theme.accentColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.browserSevenDayActivity,
                      style: theme.typography.bodyStrong?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (history != null && total7dTime > Duration.zero)
                  Text(
                    l10n.browserSevenDayTotalSummary(
                      total7dTime.toHourMinuteFormat(),
                      total7dVisits,
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.accentColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            if (history == null)
              const SizedBox(
                height: 150,
                child: Center(child: ProgressRing()),
              )
            else
              _SiteHistoryChart(history: history),

            const SizedBox(height: 4),
          ],
        ),
      ),
      actions: [
        Button(
          onPressed: _openLimitPicker,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.time_picker, size: 12, color: theme.accentColor),
              const SizedBox(width: 6),
              Text(hasLimit ? l10n.browserEditDailyLimit : l10n.browserSetDailyLimit),
            ],
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.close),
        ),
      ],
    );
  }
}

// ─── 7-day site history chart (Refined Dual-Rod Gradient Bar Chart) ───────────

class _SiteHistoryChart extends StatefulWidget {
  final List<({String date, Duration timeSpent, int visits})> history;
  const _SiteHistoryChart({required this.history});

  @override
  State<_SiteHistoryChart> createState() => _SiteHistoryChartState();
}

class _SiteHistoryChartState extends State<_SiteHistoryChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final captionColor = theme.typography.caption?.color;

    final maxSecs = widget.history.fold<int>(0, (m, e) => max(m, e.timeSpent.inSeconds));
    final maxVisits = widget.history.fold<int>(0, (m, e) => max(m, e.visits));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.02)
            : theme.inactiveBackgroundColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDesign.radiusMd),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : theme.inactiveBackgroundColor.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxSecs > 0 ? maxSecs.toDouble() * 1.2 : 60,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => isDark ? const Color(0xFF1E2028) : Colors.white,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final entry = widget.history[groupIndex];
                      if (rodIndex == 0) {
                        return BarTooltipItem(
                          '⏱ ${entry.timeSpent.toHourMinuteFormat()}',
                          const TextStyle(
                            color: kBrowserBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        );
                      } else {
                        return BarTooltipItem(
                          '👀 ${entry.visits} visits',
                          const TextStyle(
                            color: kBrowserPurple,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        );
                      }
                    },
                  ),
                  touchCallback: (event, response) {
                    setState(() {
                      _touchedIndex = response?.spot?.touchedBarGroupIndex ?? -1;
                    });
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= widget.history.length) {
                          return const SizedBox.shrink();
                        }
                        final dateStr = widget.history[i].date;
                        final parts = dateStr.split('-');
                        if (parts.length == 3) {
                          final dt = DateTime(
                            int.parse(parts[0]),
                            int.parse(parts[1]),
                            int.parse(parts[2]),
                          );
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final label = days[dt.weekday - 1];
                          final isSelected = i == _touchedIndex;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? theme.accentColor
                                    : captionColor?.withValues(alpha: 0.65),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 22,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : theme.inactiveBackgroundColor.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(widget.history.length, (i) {
                  final entry = widget.history[i];
                  final isTouched = i == _touchedIndex;
                  final visitScaled = maxVisits > 0 && maxSecs > 0
                      ? (entry.visits * maxSecs / maxVisits).toDouble()
                      : entry.visits.toDouble();

                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: entry.timeSpent.inSeconds.toDouble(),
                        color: isTouched ? kBrowserBlue : kBrowserBlue.withValues(alpha: 0.75),
                        width: 9,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: visitScaled,
                        color: isTouched ? kBrowserPurple : kBrowserPurple.withValues(alpha: 0.75),
                        width: 9,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Legend and selected day pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ChartLegend(color: kBrowserBlue, label: l10n.browserChartLegendTime),
                  const SizedBox(width: 14),
                  _ChartLegend(color: kBrowserPurple, label: l10n.browserChartLegendVisits),
                ],
              ),
              if (_touchedIndex >= 0 && _touchedIndex < widget.history.length)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${widget.history[_touchedIndex].date}: ${widget.history[_touchedIndex].timeSpent.toHourMinuteFormat()} (${widget.history[_touchedIndex].visits} visits)',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: theme.accentColor,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: FluentTheme.of(context)
                .typography
                .caption
                ?.color
                ?.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

// ─── Filter combo ─────────────────────────────────────────────────────────────

class _FilterCombo<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  const _FilterCombo({
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ComboBox<T>(
      value: value,
      items: items
          .map((i) => ComboBoxItem<T>(value: i, child: Text(label(i))))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

// ─── Compact toggle ───────────────────────────────────────────────────────────

class _CompactToggle extends StatelessWidget {
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _CompactToggle({
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 20,
          decoration: BoxDecoration(
            color: value ? activeColor : theme.inactiveBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
