import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/widgets/sortable_header.dart';
import 'package:screentime/utils/responsive.dart';
import '../../controller/data_controllers/reports_controller.dart';
import '../../controller/services/private_mode_service.dart';
import '../../../web/web_private_mode_service.dart'
    if (dart.library.io) '../../../web/web_private_mode_service_stub.dart';
import './appdetails.dialog.dart';

class ApplicationUsage extends StatefulWidget {
  final List<AppUsageSummary> appUsageDetails;

  const ApplicationUsage({
    super.key,
    required this.appUsageDetails,
  });

  @override
  State<ApplicationUsage> createState() => _ApplicationUsageState();
}

class _ApplicationUsageState extends State<ApplicationUsage> {
  List<AppUsageSummary> _filteredAppUsageDetails = [];
  String _searchQuery = '';
  String _sortBy = 'Usage';
  bool _sortAscending = false;
  String _productivityFilter = 'All';
  int? _hoveredIndex;
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  // Cached computed values to avoid recalculation in build
  late List<AppUsageSummary> _visibleApps;
  int _totalApps = 0;
  int _productiveApps = 0;

  bool get _privateModeUnlocked => kIsWeb
      ? WebPrivateModeService().isUnlocked
      : PrivateModeController().isUnlocked;

  void _onPrivateModeChanged() {
    if (mounted) setState(_applyFilterAndSort);
  }

  @override
  void initState() {
    super.initState();
    _applyFilterAndSort();
    if (kIsWeb) {
      WebPrivateModeService().addListener(_onPrivateModeChanged);
    } else {
      PrivateModeController().addListener(_onPrivateModeChanged);
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    if (kIsWeb) {
      WebPrivateModeService().removeListener(_onPrivateModeChanged);
    } else {
      PrivateModeController().removeListener(_onPrivateModeChanged);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(ApplicationUsage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appUsageDetails != widget.appUsageDetails) {
      _applyFilterAndSort();
    }
  }

  /// Single method that filters, sorts, and caches derived data.
  void _applyFilterAndSort() {
    final query = _searchQuery.toLowerCase();

    final privateModeUnlocked = _privateModeUnlocked;
    _filteredAppUsageDetails = widget.appUsageDetails.where((app) {
      final matchesQuery =
          query.isEmpty || app.appName.toLowerCase().contains(query);
      final matchesProductivity = switch (_productivityFilter) {
        'Productive' => app.isProductive,
        'NonProductive' => !app.isProductive,
        _ => true,
      };
      final matchesPrivate = !app.isPrivate || privateModeUnlocked;
      return matchesQuery && matchesProductivity && matchesPrivate;
    }).toList();

    _sortInPlace();

    // Cache derived values
    _visibleApps = _filteredAppUsageDetails
        .where((app) => app.appName.trim().isNotEmpty)
        .toList();
    _totalApps = _filteredAppUsageDetails.length;
    _productiveApps =
        _filteredAppUsageDetails.where((a) => a.isProductive).length;
  }

  void _sortInPlace() {
    final int Function(AppUsageSummary, AppUsageSummary) comparator;
    switch (_sortBy) {
      case 'Name':
        comparator = (a, b) => a.appName.compareTo(b.appName);
        break;
      case 'Category':
        comparator = (a, b) => a.category.compareTo(b.category);
        break;
      case 'Usage':
      default:
        comparator = (a, b) => a.totalTime.compareTo(b.totalTime);
        break;
    }

    _filteredAppUsageDetails.sort(
      _sortAscending ? comparator : (a, b) => comparator(b, a),
    );
  }

  void _updateFilterAndSort() {
    setState(() {
      _applyFilterAndSort();
    });
  }

  void _onHeaderSort(String column) {
    setState(() {
      if (_sortBy == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = column;
        _sortAscending = true;
      }
      _applyFilterAndSort();
    });
  }

  void _cycleProductivityFilter() {
    setState(() {
      _productivityFilter = switch (_productivityFilter) {
        'All' => 'Productive',
        'Productive' => 'NonProductive',
        _ => 'All',
      };
      _applyFilterAndSort();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = Responsive.isMobileWidth(constraints.maxWidth);

        return Container(
          height: 500,
          decoration: BoxDecoration(
            color: theme.micaBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.resources.dividerStrokeColorDefault,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                l10n: l10n,
                theme: theme,
                totalApps: _totalApps,
                productiveApps: _productiveApps,
                isMobile: isMobile,
              ),
              _buildToolbar(l10n, theme, isMobile),
              if (!isMobile)
                _ColumnHeaders(
                  l10n: l10n,
                  theme: theme,
                  sortBy: _sortBy,
                  sortAscending: _sortAscending,
                  onSort: _onHeaderSort,
                  productivityFilter: _productivityFilter,
                  onProductivityFilterCycle: _cycleProductivityFilter,
                ),
              Expanded(
                child: _visibleApps.isEmpty
                    ? _EmptyState(
                        l10n: l10n,
                        theme: theme,
                        hasSearch: _searchQuery.isNotEmpty,
                        onClear: _clearSearch,
                      )
                    : _buildAppList(_visibleApps, theme, isMobile),
              ),
              _FooterStats(l10n: l10n, theme: theme, apps: _visibleApps),
            ],
          ),
        );
      },
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _applyFilterAndSort();
    });
  }

  Widget _buildSearchBox(AppLocalizations l10n, FluentThemeData theme,
      {required double width}) {
    return SizedBox(
      width: width,
      height: 32,
      child: TextBox(
        controller: _searchController,
        focusNode: _searchFocusNode,
        placeholder: l10n.searchApplications,
        style: const TextStyle(fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        onChanged: (value) {
          _searchQuery = value;
          _updateFilterAndSort();
        },
        prefix: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child:
              Icon(FluentIcons.search, size: 14, color: theme.inactiveColor),
        ),
        suffix: _searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(FluentIcons.clear,
                    size: 12, color: theme.inactiveColor),
                onPressed: _clearSearch,
              )
            : null,
      ),
    );
  }

  Widget _buildSortToggle(AppLocalizations l10n) {
    return Tooltip(
      message: _sortAscending ? l10n.sortAscending : l10n.sortDescending,
      child: ToggleButton(
        checked: _sortAscending,
        onChanged: (value) {
          _sortAscending = value;
          _updateFilterAndSort();
        },
        child: Icon(
          _sortAscending ? FluentIcons.sort_up : FluentIcons.sort_down,
          size: 14,
        ),
      ),
    );
  }

  Widget _buildToolbar(
      AppLocalizations l10n, FluentThemeData theme, bool isMobile) {
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchBox(l10n, theme, width: double.infinity),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildSortPills(l10n, theme)),
                const SizedBox(width: 8),
                _buildSortToggle(l10n),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _buildSearchBox(l10n, theme, width: 200),
          const SizedBox(width: 12),
          Expanded(child: _buildSortPills(l10n, theme)),
          const SizedBox(width: 8),
          _buildSortToggle(l10n),
        ],
      ),
    );
  }

  Widget _buildSortPills(AppLocalizations l10n, FluentThemeData theme) {
    const sortOptions = [
      ('Usage', FluentIcons.timer),
      ('Name', FluentIcons.text_field),
      ('Category', FluentIcons.tag),
    ];

    // Map keys to localized labels
    String label(String key) {
      switch (key) {
        case 'Usage':
          return l10n.sortByUsage;
        case 'Name':
          return l10n.sortByName;
        case 'Category':
          return l10n.sortByCategory;
        default:
          return key;
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (key, icon) in sortOptions)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: ToggleButton(
                checked: _sortBy == key,
                onChanged: (value) {
                  if (value) {
                    _sortBy = key;
                    _updateFilterAndSort();
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 12),
                    const SizedBox(width: 4),
                    Text(label(key), style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppList(
      List<AppUsageSummary> apps, FluentThemeData theme, bool isMobile) {
    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _AppUsageCard(
              app: app,
              theme: theme,
              onTap: () => _showAppDetails(context, app),
            ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: apps.length,
      itemExtent: 52, // Fixed height for better scroll performance
      itemBuilder: (context, index) {
        final app = apps[index];
        final isHovered = _hoveredIndex == index;

        return _AppListItem(
          app: app,
          isHovered: isHovered,
          theme: theme,
          onEnter: () {
            if (_hoveredIndex != index) setState(() => _hoveredIndex = index);
          },
          onExit: () {
            if (_hoveredIndex == index) setState(() => _hoveredIndex = null);
          },
          onTap: () => _showAppDetails(context, app),
        );
      },
    );
  }

  void _showAppDetails(BuildContext context, AppUsageSummary app) {
    if (!context.mounted) return;
    if (kIsWeb) {
      // On web the app list comes from chrome storage, not the desktop Hive
      // store. Use showWebsiteDetailsDialog which reads limits & history from
      // chrome.storage.local correctly.
      showWebsiteDetailsDialog(
        context,
        domain: app.appName,  // always the raw domain in web reports
        displayName: app.siteName.isNotEmpty ? app.siteName : app.appName,
        category: app.category,
        timeSpent: app.totalTime,
        isProductive: app.isProductive,
      );
    } else {
      showAppDetailsDialog(context, app);
    }
  }
}

// ==================== EXTRACTED STATELESS WIDGETS ====================

class _Header extends StatelessWidget {
  final AppLocalizations l10n;
  final FluentThemeData theme;
  final int totalApps;
  final int productiveApps;
  final bool isMobile;

  const _Header({
    required this.l10n,
    required this.theme,
    required this.totalApps,
    required this.productiveApps,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final titleRow = Row(
      children: [
        Icon(FluentIcons.app_icon_default_list,
            size: 20, color: theme.accentColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            l10n.detailedApplicationUsage,
            style: theme.typography.subtitle
                ?.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final stats = [
      _MiniStat(
        value: '$totalApps',
        label: l10n.apps,
        icon: FluentIcons.grid_view_medium,
        color: theme.accentColor,
        theme: theme,
      ),
      _MiniStat(
        value: '$productiveApps',
        label: l10n.productive,
        icon: FluentIcons.check_mark,
        color: Colors.green,
        theme: theme,
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.resources.dividerStrokeColorDefault,
          ),
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleRow,
                const SizedBox(height: 10),
                Wrap(spacing: 16, runSpacing: 8, children: stats),
              ],
            )
          : Row(
              children: [
                Expanded(child: titleRow),
                const SizedBox(width: 12),
                stats[0],
                const SizedBox(width: 16),
                stats[1],
              ],
            ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final FluentThemeData theme;

  const _MiniStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 12, color: color),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style: theme.typography.caption
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label,
                style: theme.typography.caption
                    ?.copyWith(fontSize: 10, color: theme.inactiveColor)),
          ],
        ),
      ],
    );
  }
}

class _ColumnHeaders extends StatelessWidget {
  final AppLocalizations l10n;
  final FluentThemeData theme;
  final String sortBy;
  final bool sortAscending;
  final ValueChanged<String> onSort;
  final String productivityFilter;
  final VoidCallback onProductivityFilterCycle;

  const _ColumnHeaders({
    required this.l10n,
    required this.theme,
    required this.sortBy,
    required this.sortAscending,
    required this.onSort,
    required this.productivityFilter,
    required this.onProductivityFilterCycle,
  });

  String _productivityLabel() => switch (productivityFilter) {
        'Productive' => l10n.productive,
        'NonProductive' => l10n.nonProductive,
        _ => l10n.productivityHeader,
      };

  @override
  Widget build(BuildContext context) {
    final style = theme.typography.caption?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.inactiveColor,
      fontSize: 11,
      letterSpacing: 0.5,
    );
    final direction =
        sortAscending ? SortDirection.ascending : SortDirection.descending;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: theme.resources.dividerStrokeColorDefault),
        ),
      ),
      child: Row(
        children: [
          SortableHeaderCell(
            label: l10n.nameHeader,
            flex: 3,
            style: style,
            isActive: sortBy == 'Name',
            direction: direction,
            onTap: () => onSort('Name'),
          ),
          SortableHeaderCell(
            label: l10n.categoryHeader,
            flex: 2,
            style: style,
            isActive: sortBy == 'Category',
            direction: direction,
            onTap: () => onSort('Category'),
          ),
          SortableHeaderCell(
            label: l10n.totalTimeHeader,
            flex: 2,
            style: style,
            isActive: sortBy == 'Usage',
            direction: direction,
            onTap: () => onSort('Usage'),
          ),
          Expanded(
            flex: 2,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onProductivityFilterCycle,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        _productivityLabel(),
                        overflow: TextOverflow.ellipsis,
                        style: productivityFilter != 'All'
                            ? style?.copyWith(
                                color: theme.accentColor,
                                fontWeight: FontWeight.w700,
                              )
                            : style,
                      ),
                    ),
                    if (productivityFilter != 'All') ...[
                      const SizedBox(width: 4),
                      Icon(FluentIcons.filter,
                          size: 10, color: theme.accentColor),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 50),
        ],
      ),
    );
  }
}

class _AppListItem extends StatelessWidget {
  final AppUsageSummary app;
  final bool isHovered;
  final FluentThemeData theme;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final VoidCallback onTap;

  const _AppListItem({
    required this.app,
    required this.isHovered,
    required this.theme,
    required this.onEnter,
    required this.onExit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MouseRegion(
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isHovered
                ? theme.accentColor.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isHovered
                  ? theme.accentColor.withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              // App name with icon
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    _AppIcon(isProductive: app.isProductive),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            app.siteName.isNotEmpty
                                ? app.siteName
                                : app.appName,
                            style: theme.typography.body
                                ?.copyWith(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (app.siteName.isNotEmpty &&
                              app.siteName != app.appName)
                            Text(
                              app.appName,
                              style: theme.typography.caption?.copyWith(
                                fontSize: 10,
                                color: theme.inactiveColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Category
              Expanded(
                flex: 2,
                child: _CategoryChip(category: app.category, theme: theme),
              ),
              // Total Time
              Expanded(
                flex: 2,
                child: _TimeDisplay(duration: app.totalTime, theme: theme),
              ),
              // Productivity
              Expanded(
                flex: 2,
                child: _ProductivityBadge(
                    isProductive: app.isProductive, l10n: l10n),
              ),
              // Info icon
              SizedBox(
                width: 50,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: isHovered ? 1.0 : 0.5,
                    child: Icon(FluentIcons.info,
                        size: 14, color: theme.accentColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppUsageCard extends StatelessWidget {
  final AppUsageSummary app;
  final FluentThemeData theme;
  final VoidCallback onTap;

  const _AppUsageCard({
    required this.app,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.resources.dividerStrokeColorDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AppIcon(isProductive: app.isProductive),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        app.siteName.isNotEmpty ? app.siteName : app.appName,
                        style: theme.typography.body
                            ?.copyWith(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (app.siteName.isNotEmpty &&
                          app.siteName != app.appName)
                        Text(
                          app.appName,
                          style: theme.typography.caption?.copyWith(
                            fontSize: 10,
                            color: theme.inactiveColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _TimeDisplay(duration: app.totalTime, theme: theme),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _CategoryChip(category: app.category, theme: theme),
                _ProductivityBadge(isProductive: app.isProductive, l10n: l10n),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppIcon extends StatelessWidget {
  final bool isProductive;
  const _AppIcon({required this.isProductive});

  @override
  Widget build(BuildContext context) {
    final color = isProductive ? Colors.green : Colors.red;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(FluentIcons.app_icon_default, size: 14, color: color),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  final FluentThemeData theme;
  const _CategoryChip({required this.category, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: theme.resources.dividerStrokeColorDefault),
        ),
        child: Text(
          category,
          style: theme.typography.caption?.copyWith(fontSize: 11),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final Duration duration;
  final FluentThemeData theme;
  const _TimeDisplay({required this.duration, required this.theme});

  @override
  Widget build(BuildContext context) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final captionStyle =
        theme.typography.caption?.copyWith(color: theme.inactiveColor);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hours > 0) ...[
          Text('$hours',
              style: theme.typography.body?.copyWith(
                fontWeight: FontWeight.bold,
                color: hours > 2 ? Colors.orange : null,
              )),
          Text('h ', style: captionStyle),
        ],
        Text('$minutes',
            style:
                theme.typography.body?.copyWith(fontWeight: FontWeight.bold)),
        Text('m', style: captionStyle),
      ],
    );
  }
}

class _ProductivityBadge extends StatelessWidget {
  final bool isProductive;
  final AppLocalizations l10n;
  const _ProductivityBadge({required this.isProductive, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final color = isProductive ? Colors.green : Colors.red;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isProductive ? FluentIcons.check_mark : FluentIcons.cancel,
              size: 10,
              color: color,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                isProductive ? l10n.productive : l10n.nonProductive,
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final FluentThemeData theme;
  final bool hasSearch;
  final VoidCallback onClear;

  const _EmptyState({
    required this.l10n,
    required this.theme,
    required this.hasSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FluentIcons.search,
              size: 40, color: theme.inactiveColor.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(l10n.noApplicationsMatch,
              style:
                  theme.typography.body?.copyWith(color: theme.inactiveColor)),
          if (hasSearch) ...[
            const SizedBox(height: 8),
            Button(onPressed: onClear, child: Text(l10n.clearSearch)),
          ],
        ],
      ),
    );
  }
}

class _FooterStats extends StatelessWidget {
  final AppLocalizations l10n;
  final FluentThemeData theme;
  final List<AppUsageSummary> apps;

  const _FooterStats({
    required this.l10n,
    required this.theme,
    required this.apps,
  });

  @override
  Widget build(BuildContext context) {
    final totalTime =
        apps.fold<Duration>(Duration.zero, (sum, app) => sum + app.totalTime);
    final hours = totalTime.inHours;
    final minutes = totalTime.inMinutes.remainder(60);
    final formatted = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(color: theme.resources.dividerStrokeColorDefault),
        ),
      ),
      child: Row(
        children: [
          const Spacer(),
          Text('${l10n.totalTime}: ',
              style: theme.typography.caption
                  ?.copyWith(color: theme.inactiveColor)),
          Text(formatted,
              style: theme.typography.caption
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
