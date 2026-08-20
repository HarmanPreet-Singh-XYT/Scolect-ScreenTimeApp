import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/sections/controller/data_controllers/alerts_limits_data_controller.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/widgets/sortable_header.dart';
import './reusable.dart' as rub;
import './approw.dart';

class ApplicationLimitsCard extends StatefulWidget {
  final List<AppUsageSummary> appSummaries;
  final ScreenTimeDataController controller;
  final VoidCallback onDataChanged;

  const ApplicationLimitsCard({
    super.key,
    required this.appSummaries,
    required this.controller,
    required this.onDataChanged,
  });

  // ──────────────────────────── constants ────────────────────────────

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF6B7280),
  );

  static const _sectionLabelStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );

  @override
  State<ApplicationLimitsCard> createState() => _ApplicationLimitsCardState();
}

class _ApplicationLimitsCardState extends State<ApplicationLimitsCard> {
  String _sortColumn = 'name';
  SortDirection _sortDirection = SortDirection.ascending;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortDirection = _sortDirection == SortDirection.ascending
            ? SortDirection.descending
            : SortDirection.ascending;
      } else {
        _sortColumn = column;
        _sortDirection = SortDirection.ascending;
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  List<AppUsageSummary> get _sortedApps {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = widget.appSummaries.where((app) {
      if (app.appName.trim().isEmpty) return false;
      if (query.isEmpty) return true;
      return app.appName.toLowerCase().contains(query) ||
          app.siteName.toLowerCase().contains(query) ||
          app.category.toLowerCase().contains(query);
    }).toList();

    final int Function(AppUsageSummary, AppUsageSummary) comparator;
    switch (_sortColumn) {
      case 'category':
        comparator = (a, b) => a.category.compareTo(b.category);
      case 'dailyLimit':
        comparator = (a, b) => a.dailyLimit.compareTo(b.dailyLimit);
      case 'currentUsage':
        comparator = (a, b) => a.currentUsage.compareTo(b.currentUsage);
      case 'name':
      default:
        comparator = (a, b) => (a.siteName.isNotEmpty ? a.siteName : a.appName)
            .toLowerCase()
            .compareTo((b.siteName.isNotEmpty ? b.siteName : b.appName)
                .toLowerCase());
    }

    filtered.sort(_sortDirection == SortDirection.ascending
        ? comparator
        : (a, b) => comparator(b, a));
    return filtered;
  }

  // ──────────────────────────── build ────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sortedApps = _sortedApps;

    return LayoutBuilder(
      builder: (context, constraints) {
        // This card's table row is flex-based (no hardcoded column
        // widths), so it can render comfortably narrower than the global
        // 700px mobile threshold — using that threshold here made the
        // table fall back to mobile cards even inside a wide desktop
        // window, since this card is one column of a multi-column page
        // layout rather than the full page width.
        final isMobile = constraints.maxWidth < 520;

        return rub.Card(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(
                count: sortedApps.length,
                onAdd: () => _showLimitDialog(context),
                searchController: _searchController,
                onSearchChanged: _onSearchChanged,
                onClearSearch: _clearSearch,
                isMobile: isMobile,
              ),
              if (!isMobile)
                _TableHeader(
                  headerStyle: ApplicationLimitsCard._headerStyle,
                  sortColumn: _sortColumn,
                  sortDirection: _sortDirection,
                  onSort: _toggleSort,
                ),
              if (sortedApps.isEmpty)
                _EmptyState(
                  hasSearch: _searchQuery.trim().isNotEmpty,
                  onClear: _clearSearch,
                )
              else if (isMobile)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: Column(
                    children: sortedApps
                        .map((app) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: AppLimitCard(
                                app: app,
                                onEdit: () =>
                                    _showLimitDialog(context, app: app),
                              ),
                            ))
                        .toList(),
                  ),
                )
              else
                ...sortedApps.asMap().entries.map((entry) => AppRow(
                      app: entry.value,
                      onEdit: () =>
                          _showLimitDialog(context, app: entry.value),
                      isLast: entry.key == sortedApps.length - 1,
                    )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ──────────────────────── unified dialog ───────────────────────────

  void _showLimitDialog(BuildContext context, {AppUsageSummary? app}) {
    final isEdit = app != null;
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    String? selectedApp = app?.appId;
    double hours = app?.dailyLimit.inHours.toDouble() ?? 1.0;
    double minutes = (app?.dailyLimit.inMinutes ?? 0) % 60.0;
    bool limitEnabled = app?.limitStatus ?? true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final totalMinutes = (hours * 60 + minutes).round();
          final formattedTime = formatDuration(hours.round(), minutes.round());
          final canSubmit = isEdit || (selectedApp != null && totalMinutes > 0);

          return ContentDialog(
            title: _DialogTitle(
              icon: isEdit ? FluentIcons.edit : FluentIcons.add,
              label: isEdit
                  ? l10n.editLimitTitle(app.appName)
                  : (kIsWeb ? "Add Website Limit" : l10n.addApplicationLimit),
            ),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App selector — only for add mode
                  if (!isEdit) ...[
                    Text(l10n.selectApplication,
                        style: ApplicationLimitsCard._sectionLabelStyle),
                    const SizedBox(height: 8),
                    ComboBox<String>(
                      placeholder: Text(
                        kIsWeb ? "Select Website" : l10n.selectApplicationPlaceholder,
                        style: TextStyle(
                          color: theme.resources.textFillColorSecondary,
                        ),
                      ),
                      isExpanded: true,
                      items: widget.appSummaries
                          .where((a) => a.appName.trim().isNotEmpty)
                          .map((a) => ComboBoxItem<String>(
                                value: a.appId,
                                child: Text(a.appName,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      value: selectedApp,
                      onChanged: (v) => setState(() => selectedApp = v),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],

                  // Toggle
                  _ToggleRow(
                    label: l10n.enableLimit,
                    value: limitEnabled,
                    onChanged: (v) => setState(() => limitEnabled = v),
                  ),

                  const SizedBox(height: 24),

                  if (isEdit) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                  ],

                  // Time sliders
                  _TimePicker(
                    enabled: limitEnabled,
                    formattedTime: formattedTime,
                    hours: hours,
                    minutes: minutes,
                    hoursLabel: l10n.hours,
                    minutesLabel: l10n.minutes,
                    dailyLimitLabel: l10n.dailyLimit,
                    onHoursChanged: (v) => setState(() => hours = v),
                    onMinutesChanged: (v) => setState(() => minutes = v),
                  ),
                ],
              ),
            ),
            actions: [
              Button(
                child: Text(l10n.cancel),
                onPressed: () => Navigator.pop(context),
              ),
              FilledButton(
                onPressed: canSubmit
                    ? () {
                        final duration = Duration(
                          hours: hours.round(),
                          minutes: minutes.round() ~/ 5 * 5,
                        );
                        widget.controller.updateAppLimit(
                          selectedApp!,
                          duration,
                          limitEnabled,
                        );
                        widget.onDataChanged();
                        Navigator.pop(context);
                      }
                    : null,
                child: Text(isEdit ? l10n.save : l10n.add),
              ),
            ],
          );
        },
      ),
    );
  }

  // ──────────────────────── static helpers ───────────────────────────

  static String formatDuration(int hours, int minutes) {
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    if (minutes > 0) return '${minutes}m';
    return '0m';
  }
}

// ════════════════════════ Extracted Widgets ══════════════════════════

class _Header extends StatelessWidget {
  final int count;
  final VoidCallback onAdd;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final bool isMobile;

  const _Header({
    required this.count,
    required this.onAdd,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    final titleRow = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(FluentIcons.app_icon_default,
              size: 18, color: theme.accentColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                kIsWeb ? "Website Limits" : l10n.applicationLimits,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                kIsWeb ? "$count Websites" : l10n.applicationsTracked(count),
                style: TextStyle(
                  fontSize: 12,
                  color:
                      theme.typography.caption?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        if (!isMobile)
          FilledButton(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            onPressed: onAdd,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FluentIcons.add, size: 12),
                const SizedBox(width: 6),
                Text(l10n.addLimit),
              ],
            ),
          ),
      ],
    );

    final searchBox = SizedBox(
      height: 32,
      child: TextBox(
        controller: searchController,
        placeholder: l10n.searchApplications,
        style: const TextStyle(fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        onChanged: onSearchChanged,
        prefix: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child:
              Icon(FluentIcons.search, size: 14, color: theme.inactiveColor),
        ),
        suffix: searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(FluentIcons.clear,
                    size: 12, color: theme.inactiveColor),
                onPressed: onClearSearch,
              )
            : null,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleRow,
          const SizedBox(height: 12),
          searchBox,
          if (isMobile) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                onPressed: onAdd,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.add, size: 12),
                    const SizedBox(width: 6),
                    Text(l10n.addLimit),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final TextStyle headerStyle;
  final String sortColumn;
  final SortDirection sortDirection;
  final ValueChanged<String> onSort;

  const _TableHeader({
    required this.headerStyle,
    required this.sortColumn,
    required this.sortDirection,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final borderColor = theme.inactiveBackgroundColor.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.03),
        border: Border(
          top: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          SortableHeaderCell(
            label: l10n.applicationHeader,
            flex: 3,
            style: headerStyle,
            isActive: sortColumn == 'name',
            direction: sortDirection,
            onTap: () => onSort('name'),
          ),
          SortableHeaderCell(
            label: l10n.categoryHeader,
            flex: 3,
            padding: const EdgeInsets.only(left: 8),
            style: headerStyle,
            isActive: sortColumn == 'category',
            direction: sortDirection,
            onTap: () => onSort('category'),
          ),
          SortableHeaderCell(
            label: l10n.dailyLimitHeader,
            flex: 2,
            padding: const EdgeInsets.only(left: 8),
            style: headerStyle,
            isActive: sortColumn == 'dailyLimit',
            direction: sortDirection,
            onTap: () => onSort('dailyLimit'),
          ),
          SortableHeaderCell(
            label: l10n.currentUsageHeader,
            flex: 2,
            padding: const EdgeInsets.only(left: 8),
            style: headerStyle,
            isActive: sortColumn == 'currentUsage',
            direction: sortDirection,
            onTap: () => onSort('currentUsage'),
          ),
          SizedBox(
            width: 50,
            child: Text(l10n.edit,
                style: headerStyle, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback? onClear;

  const _EmptyState({this.hasSearch = false, this.onClear});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                hasSearch ? FluentIcons.search : FluentIcons.app_icon_default,
                size: 48,
                color: theme.inactiveColor),
            const SizedBox(height: 16),
            Text(
              hasSearch ? l10n.noApplicationsMatch : l10n.noApplicationsToDisplay,
              style: TextStyle(color: theme.inactiveColor),
            ),
            if (hasSearch && onClear != null) ...[
              const SizedBox(height: 8),
              Button(onPressed: onClear, child: Text(l10n.clearSearch)),
            ],
          ],
        ),
      ),
    );
  }
}

class _DialogTitle extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DialogTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.accentColor, size: 20),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.resources.dividerStrokeColorDefault),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ToggleSwitch(checked: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final bool enabled;
  final String formattedTime;
  final double hours;
  final double minutes;
  final String hoursLabel;
  final String minutesLabel;
  final String dailyLimitLabel;
  final ValueChanged<double> onHoursChanged;
  final ValueChanged<double> onMinutesChanged;

  const _TimePicker({
    required this.enabled,
    required this.formattedTime,
    required this.hours,
    required this.minutes,
    required this.hoursLabel,
    required this.minutesLabel,
    required this.dailyLimitLabel,
    required this.onHoursChanged,
    required this.onMinutesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !enabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dailyLimitLabel,
                style: ApplicationLimitsCard._sectionLabelStyle),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.accentColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            rub.SliderRow(
              label: hoursLabel,
              value: hours,
              max: 12,
              divisions: 12,
              onChanged: onHoursChanged,
            ),
            const SizedBox(height: 12),
            rub.SliderRow(
              label: minutesLabel,
              value: minutes,
              max: 55,
              divisions: 11,
              step: 5,
              onChanged: onMinutesChanged,
            ),
          ],
        ),
      ),
    );
  }
}
