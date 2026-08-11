import 'dart:async';
import 'dart:math' show max;
import 'package:fl_chart/fl_chart.dart';
import 'package:screentime/sections/controller/data_controllers/applications_data_controller.dart' show DurationFormatter;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/data_controllers/browser_data_controller.dart';
import 'package:screentime/utils/responsive.dart';
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
                    NumberBox<int>(
                      value: hours,
                      min: 0,
                      max: 23,
                      onChanged: (v) => setInner(() => hours = v ?? 0),
                      mode: SpinButtonPlacementMode.inline,
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
                    Text(l10n.minutesLabel,
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    NumberBox<int>(
                      value: minutes,
                      min: 0,
                      max: 59,
                      onChanged: (v) => setInner(() => minutes = v ?? 0),
                      mode: SpinButtonPlacementMode.inline,
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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
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

  List<WebsiteBasicDetail> get _filtered => _allSites
      .where((s) =>
          s.matchesSearch(_search) &&
          s.matchesCategory(_categoryFilter) &&
          s.matchesTracking(_trackingFilter) &&
          s.matchesProductivity(_productivityFilter))
      .toList();

  @override
  void dispose() {
    _debounce?.cancel();
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

    final isMobile = Responsive.isMobileWidth(MediaQuery.sizeOf(context).width);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 24,
        vertical: isMobile ? 14 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filters bar ────────────────────────────────────────────────
          BrowserCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: isMobile
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
                            onChanged: (v) => setState(() => _categoryFilter = v),
                          ),
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
                          _FilterCombo<String>(
                            value: _productivityFilter,
                            items: const ['all', 'productive', 'unproductive'],
                            label: (v) => switch (v) {
                              'productive' => l10n.productive,
                              'unproductive' => l10n.browserFilterUnproductive,
                              _ => l10n.browserFilterAllTypes,
                            },
                            onChanged: (v) => setState(() => _productivityFilter = v),
                          ),
                          BrowserIconButton(
                            tooltip: l10n.refresh,
                            icon: FluentIcons.refresh,
                            onPressed: _loadData,
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      BrowserSearchBox(
                        placeholder: l10n.browserSearchPlaceholder,
                        onChanged: _onSearch,
                      ),
                      const SizedBox(width: 12),
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
                        onChanged: (v) => setState(() => _productivityFilter = v),
                      ),
                      const Spacer(),
                      BrowserIconButton(
                        tooltip: l10n.refresh,
                        icon: FluentIcons.refresh,
                        onPressed: _loadData,
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 10),

          // ── Count ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              l10n.browserWebsiteCount(filtered.length),
              style: TextStyle(
                fontSize: 13,
                color: theme.typography.caption?.color?.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

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
                          _TableHeader(),
                          Expanded(
                            child: filtered.isEmpty
                                ? BrowserEmptyState(
                                    icon: FluentIcons.globe,
                                    title: l10n.browserNoWebsitesTitle,
                                    subtitle: l10n.browserNoWebsitesDesktopSubtitle,
                                  )
                                : ListView.builder(
                                    itemCount: filtered.length,
                                    itemBuilder: (context, i) => _WebsiteRow(
                                      site: filtered[i],
                                      showDivider: i < filtered.length - 1,
                                      onMetadataChanged: _loadData,
                                      onTap: () => _showSiteDetail(context, filtered[i]),
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
  }
}

// ─── Table header ─────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final color = theme.typography.caption?.color?.withValues(alpha: 0.5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.inactiveBackgroundColor.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(
            flex: 3,
            child: _HeaderCell(l10n.browserColumnDomain, color: color),
          ),
          Expanded(child: _HeaderCell(l10n.category, color: color)),
          SizedBox(
            width: 90,
            child: _HeaderCell(l10n.browserColumnTimeToday, color: color, align: TextAlign.right),
          ),
          SizedBox(
            width: 70,
            child: _HeaderCell(l10n.browserColumnVisits, color: color, align: TextAlign.center),
          ),
          SizedBox(
            width: 110,
            child: _HeaderCell('Daily Limit', color: color, align: TextAlign.center),
          ),
          SizedBox(
            width: 80,
            child: _HeaderCell(l10n.productive, color: color, align: TextAlign.center),
          ),
          SizedBox(
            width: 80,
            child: _HeaderCell(l10n.browserColumnTracking, color: color, align: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign align;

  const _HeaderCell(this.text, {this.color, this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      textAlign: align,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05,
        color: color,
      ),
    );
  }
}

// ─── Website row ──────────────────────────────────────────────────────────────

class _WebsiteRow extends StatefulWidget {
  final WebsiteBasicDetail site;
  final bool showDivider;
  final VoidCallback onMetadataChanged;
  final VoidCallback onTap;

  const _WebsiteRow({
    required this.site,
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

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final captionColor = theme.typography.caption?.color;
    final site = widget.site;
    final hasDifferentName = site.siteName.isNotEmpty && site.siteName != site.domain;

    // Limit progress
    final hasLimit = site.dailyLimit > Duration.zero;
    double limitProgress = 0;
    if (hasLimit && site.timeSpent > Duration.zero) {
      limitProgress =
          (site.timeSpent.inSeconds / site.dailyLimit.inSeconds).clamp(0.0, 1.0);
    }
    final overLimit = limitProgress >= 1.0;
    final limitColor = overLimit
        ? kBrowserRed
        : limitProgress > 0.75
            ? kBrowserAmber
            : kBrowserGreen;

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
                ? theme.inactiveBackgroundColor.withValues(alpha: 0.25)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Globe icon
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

                // Domain / display name (with inline editing)
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
                                  icon: const Icon(FluentIcons.check_mark, size: 12),
                                  onPressed: _saveEdit,
                                ),
                                IconButton(
                                  icon: const Icon(FluentIcons.cancel, size: 12),
                                  onPressed: () => setState(() => _editing = false),
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
                                        fontSize: 13, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (hasDifferentName)
                                    Text(
                                      site.domain,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: captionColor?.withValues(alpha: 0.5),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            if (site.limitStatus)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Tooltip(
                                  message: 'Daily limit reached – site is blocked',
                                  child: Icon(
                                    FluentIcons.lock,
                                    size: 13,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            if (_hovered)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Tooltip(
                                  message: AppLocalizations.of(context)!.browserEditSiteName,
                                  child: IconButton(
                                    icon: Icon(FluentIcons.edit,
                                        size: 13,
                                        color: captionColor?.withValues(alpha: 0.5)),
                                    onPressed: _startEdit,
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),

                // Category chip
                Expanded(
                  child: BrowserStatChip(
                    label: site.category,
                    color: theme.accentColor.withValues(alpha: 0.12),
                    textColor: theme.accentColor,
                  ),
                ),

                // Time
                SizedBox(
                  width: 90,
                  child: Text(
                    site.formattedTimeSpent,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.accentColor,
                    ),
                  ),
                ),

                // Visits
                SizedBox(
                  width: 70,
                  child: Text(
                    '${site.visits}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: captionColor?.withValues(alpha: 0.6),
                    ),
                  ),
                ),

                // ── Daily Limit column ──────────────────────────────────────
                SizedBox(
                  width: 110,
                  child: GestureDetector(
                    onTap: _showLimitPicker,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Tooltip(
                        message: hasLimit
                            ? 'Click to edit limit'
                            : 'Click to set a daily limit',
                        child: hasLimit
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Progress bar
                                  SizedBox(
                                    width: 90,
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
                                  const SizedBox(height: 3),
                                  Text(
                                    _formatLimit(site.dailyLimit),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: limitColor,
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: Text(
                                  'No limit',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: captionColor?.withValues(alpha: 0.35),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                // Productive toggle
                SizedBox(
                  width: 80,
                  child: Center(
                    child: _CompactToggle(
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
                ),

                // Tracking toggle
                SizedBox(
                  width: 80,
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
    final hasDifferentName = site.siteName.isNotEmpty && site.siteName != site.domain;

    final hasLimit = site.dailyLimit > Duration.zero;
    double limitProgress = 0;
    if (hasLimit && site.timeSpent > Duration.zero) {
      limitProgress =
          (site.timeSpent.inSeconds / site.dailyLimit.inSeconds).clamp(0.0, 1.0);
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
                                  icon: const Icon(FluentIcons.check_mark, size: 12),
                                  onPressed: _saveEdit,
                                ),
                                IconButton(
                                  icon: const Icon(FluentIcons.cancel, size: 12),
                                  onPressed: () => setState(() => _editing = false),
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
                                        fontSize: 14, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (hasDifferentName)
                                    Text(
                                      site.domain,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: captionColor?.withValues(alpha: 0.5),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            if (site.limitStatus)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Tooltip(
                                  message: 'Daily limit reached – site is blocked',
                                  child: Icon(
                                    FluentIcons.lock,
                                    size: 13,
                                    color: Colors.red,
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
                                      color: captionColor?.withValues(alpha: 0.5)),
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
                  color: theme.accentColor.withValues(alpha: 0.12),
                  textColor: theme.accentColor,
                ),
                _MetricPill(
                  icon: FluentIcons.timer,
                  label: site.formattedTimeSpent,
                  color: theme.accentColor,
                ),
                _MetricPill(
                  icon: FluentIcons.view,
                  label: '${site.visits} ${l10n.browserColumnVisits.toLowerCase()}',
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.inactiveBackgroundColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(FluentIcons.time_picker,
                          size: 13, color: captionColor?.withValues(alpha: 0.6)),
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

  const _MetricPill({required this.icon, required this.label, required this.color});

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final h = await _provider.fetchSiteHistory(widget.site.domain, days: 7);
    if (mounted) setState(() => _history = h);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final site = widget.site;
    final captionColor = theme.typography.caption?.color;
    final history = _history;

    // Limit progress
    final hasLimit = site.dailyLimit > Duration.zero;
    double limitProgress = 0;
    if (hasLimit && site.timeSpent > Duration.zero) {
      limitProgress = (site.timeSpent.inSeconds / site.dailyLimit.inSeconds).clamp(0.0, 1.0);
    }
    final overLimit = limitProgress >= 1.0;
    final limitColor = overLimit
        ? kBrowserRed
        : limitProgress > 0.75
            ? kBrowserAmber
            : kBrowserGreen;

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 560),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(FluentIcons.globe, size: 16, color: theme.accentColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  site.displayName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                if (site.siteName.isNotEmpty && site.siteName != site.domain)
                  Text(
                    site.domain,
                    style: TextStyle(
                      fontSize: 11,
                      color: captionColor?.withValues(alpha: 0.5),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ),
          BrowserStatChip(
            label: site.category,
            color: theme.accentColor.withValues(alpha: 0.12),
            textColor: theme.accentColor,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Today stats ──────────────────────────────────────────────
            Row(
              children: [
                _DetailStatCard(
                  icon: FluentIcons.timer,
                  label: 'Time today',
                  value: site.formattedTimeSpent,
                  color: kBrowserBlue,
                ),
                const SizedBox(width: 10),
                _DetailStatCard(
                  icon: FluentIcons.view,
                  label: 'Visits today',
                  value: '${site.visits}',
                  color: kBrowserPurple,
                ),
                const SizedBox(width: 10),
                _DetailStatCard(
                  icon: FluentIcons.time_picker,
                  label: 'Daily limit',
                  value: hasLimit
                      ? _formatLimit(site.dailyLimit)
                      : 'No limit',
                  color: hasLimit ? limitColor : (captionColor ?? kBrowserBlue).withValues(alpha: 0.4),
                ),
              ],
            ),
            if (hasLimit) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: theme.inactiveBackgroundColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: limitProgress,
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: limitColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(limitProgress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: limitColor,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),

            // ── 7-day chart ───────────────────────────────────────────────
            Text(
              '7-Day Activity',
              style: theme.typography.bodyStrong?.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 12),
            if (history == null)
              const SizedBox(
                height: 140,
                child: Center(child: ProgressRing()),
              )
            else
              _SiteHistoryChart(history: history),

            const SizedBox(height: 4),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
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

// ─── Detail stat card (inside dialog) ────────────────────────────────────────

class _DetailStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.typography.body?.color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: theme.typography.caption?.color?.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 7-day site history chart ─────────────────────────────────────────────────

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
    final captionColor = theme.typography.caption?.color;

    final maxSecs = widget.history
        .fold<int>(0, (m, e) => max(m, e.timeSpent.inSeconds));
    final maxVisits = widget.history
        .fold<int>(0, (m, e) => max(m, e.visits));

    // Normalize visits to same scale as time for dual bar
    // We'll show them as two bars side-by-side using BarChartGroupData

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 160,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxSecs > 0 ? maxSecs.toDouble() * 1.2 : 60,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => theme.micaBackgroundColor,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final entry = widget.history[groupIndex];
                    if (rodIndex == 0) {
                      return BarTooltipItem(
                        entry.timeSpent.toHourMinuteFormat(),
                        TextStyle(
                          color: kBrowserBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      );
                    } else {
                      return BarTooltipItem(
                        '${entry.visits} visits',
                        TextStyle(
                          color: kBrowserPurple,
                          fontWeight: FontWeight.w600,
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
                      // Show abbreviated day: "Mon", "Tue", etc.
                      final parts = dateStr.split('-');
                      if (parts.length == 3) {
                        final dt = DateTime(
                          int.parse(parts[0]),
                          int.parse(parts[1]),
                          int.parse(parts[2]),
                        );
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final label = days[dt.weekday - 1];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              color: captionColor?.withValues(alpha: 0.6),
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
                  color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(widget.history.length, (i) {
                final entry = widget.history[i];
                final isTouched = i == _touchedIndex;
                // Scale visits to time-axis: visits * (maxSecs / max(maxVisits,1))
                final visitScaled = maxVisits > 0 && maxSecs > 0
                    ? (entry.visits * maxSecs / maxVisits).toDouble()
                    : entry.visits.toDouble();
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: entry.timeSpent.inSeconds.toDouble(),
                      color: isTouched
                          ? kBrowserBlue
                          : kBrowserBlue.withValues(alpha: 0.7),
                      width: 8,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                    BarChartRodData(
                      toY: visitScaled,
                      color: isTouched
                          ? kBrowserPurple
                          : kBrowserPurple.withValues(alpha: 0.7),
                      width: 8,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ChartLegend(color: kBrowserBlue, label: 'Time'),
            const SizedBox(width: 16),
            _ChartLegend(color: kBrowserPurple, label: 'Visits'),
          ],
        ),
        // Raw data row for the touched day
        if (_touchedIndex >= 0 && _touchedIndex < widget.history.length) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.history[_touchedIndex].date,
                  style: TextStyle(
                    fontSize: 11,
                    color: captionColor?.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.history[_touchedIndex].timeSpent.toHourMinuteFormat(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kBrowserBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${widget.history[_touchedIndex].visits} visits',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kBrowserPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: FluentTheme.of(context).typography.caption?.color?.withValues(alpha: 0.7),
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
            color: value
                ? activeColor
                : theme.inactiveBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment:
                value ? Alignment.centerRight : Alignment.centerLeft,
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
