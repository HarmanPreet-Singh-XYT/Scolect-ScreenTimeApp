import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/data_controllers/browser_data_controller.dart';
import 'browser_shared.dart';
import '../../../web/extension_settings.dart'
    if (dart.library.io) '../../../web/extension_settings_stub.dart';

class BrowserWebsites extends StatefulWidget {
  final ValueChanged<BrowserTab> onTabChange;

  const BrowserWebsites({super.key, required this.onTabChange});

  @override
  State<BrowserWebsites> createState() => _BrowserWebsitesState();
}

class _BrowserWebsitesState extends State<BrowserWebsites> {
  final _provider = BrowserDataProvider();
  final _extSettings = ExtensionSettings();

  List<WebsiteBasicDetail> _allSites = [];
  List<String> _categories = ['All'];
  bool _isLoading = true;
  String _search = '';
  String _categoryFilter = 'All';
  String _trackingFilter = 'all';
  String _productivityFilter = 'all';
  Timer? _debounce;
  bool _clearConfirm = false;

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

  Future<void> _clearData() async {
    await _extSettings.clearAllData();
    if (!mounted) return;
    setState(() => _clearConfirm = false);
    final l10n = AppLocalizations.of(context)!;
    displayInfoBar(context, builder: (ctx, close) {
      return InfoBar(
        title: Text(l10n.browserDataCleared),
        action: Button(onPressed: close, child: Text(l10n.ok)),
      );
    });
    _loadData();
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _search = v);
    });
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filters bar ────────────────────────────────────────────────
          BrowserCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
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

          // ── Count + clear data ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Text(
                  l10n.browserWebsiteCount(filtered.length),
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.typography.caption?.color?.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (kIsWeb) ...[
                  const Spacer(),
                  if (_clearConfirm)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.browserAreYouSure,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.typography.caption?.color?.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(kBrowserRed),
                          ),
                          onPressed: _clearData,
                          child: Text(l10n.browserYesDelete),
                        ),
                        const SizedBox(width: 6),
                        Button(
                          onPressed: () => setState(() => _clearConfirm = false),
                          child: Text(l10n.cancelButton),
                        ),
                      ],
                    )
                  else
                    Button(
                      onPressed: () => setState(() => _clearConfirm = true),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          kBrowserRed.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        l10n.browserClearDataButton,
                        style: TextStyle(color: kBrowserRed, fontSize: 12),
                      ),
                    ),
                ],
              ],
            ),
          ),

          // ── Table ──────────────────────────────────────────────────────
          Expanded(
            child: BrowserCard(
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
                              subtitle: kIsWeb
                                  ? l10n.browserNoWebsitesWebSubtitle
                                  : l10n.browserNoWebsitesDesktopSubtitle,
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, i) => _WebsiteRow(
                                site: filtered[i],
                                showDivider: i < filtered.length - 1,
                                onMetadataChanged: _loadData,
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

  const _WebsiteRow({
    required this.site,
    required this.showDivider,
    required this.onMetadataChanged,
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

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final captionColor = theme.typography.caption?.color;
    final site = widget.site;
    final hasDifferentName = site.siteName.isNotEmpty && site.siteName != site.domain;

    return Column(
      children: [
        MouseRegion(
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
