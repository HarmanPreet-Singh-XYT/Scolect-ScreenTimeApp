import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/main.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/application_controller.dart';
import 'controller/settings_data_controller.dart';
import './controller/data_controllers/applications_data_controller.dart';
import './controller/categories_controller.dart';
import 'dart:async';
import 'package:screentime/l10n/app_localizations.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _kAnimationDuration = Duration(milliseconds: 400);
const _kDebounceDuration = Duration(milliseconds: 300);
const _kHoverDuration = Duration(milliseconds: 150);
const _kToggleDuration = Duration(milliseconds: 200);

const _kGreenColor = Color(0xFF10B981);
const _kBlueColor = Color(0xFF3B82F6);
const _kPurpleColor = Color(0xFF8B5CF6);
const _kAmberColor = Color(0xFFF59E0B);

// ─── Data Model ───────────────────────────────────────────────────────────────

class AppViewModel {
  final String name;
  final String category;
  final String screenTime;
  bool isTracking;
  bool isHidden;
  final bool isProductive;
  final Duration dailyLimit;
  final bool limitStatus;

  AppViewModel({
    required this.name,
    required this.category,
    required this.screenTime,
    required this.isTracking,
    required this.isHidden,
    required this.isProductive,
    required this.dailyLimit,
    required this.limitStatus,
  });

  factory AppViewModel.fromDetail(ApplicationBasicDetail detail) {
    return AppViewModel(
      name: detail.name,
      category: detail.category,
      screenTime: detail.formattedScreenTime,
      isTracking: detail.isTracking,
      isHidden: detail.isHidden,
      isProductive: detail.isProductive,
      dailyLimit: detail.dailyLimit,
      limitStatus: detail.limitStatus,
    );
  }

  bool get hasData => screenTime != "0s" && name.isNotEmpty;

  bool matchesSearch(String query) =>
      query.isEmpty || name.toLowerCase().contains(query.toLowerCase());

  bool matchesCategory(String category) =>
      category == "All" || category.contains(this.category);

  bool matchesTracking(String filter) => switch (filter) {
        "tracked" => isTracking,
        "untracked" => !isTracking,
        _ => true,
      };

  bool matchesVisibility(String filter) => switch (filter) {
        "visible" => !isHidden,
        "hidden" => isHidden,
        _ => true,
      };
}

// ─── Main Widget ──────────────────────────────────────────────────────────────

class Applications extends StatefulWidget {
  const Applications({super.key});

  @override
  State<Applications> createState() => _ApplicationsState();
}

class _ApplicationsState extends State<Applications>
    with SingleTickerProviderStateMixin {
  final _settingsManager = SettingsManager();
  final _appDataStore = AppDataStore();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  String _trackingFilter = "all";
  String _visibilityFilter = "all";
  String _selectedCategory = "All";
  String _searchValue = '';
  List<AppViewModel> _apps = [];
  bool _isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _loadFilterPreferences();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigationState.registerRefreshCallback(_loadData);
    });
    _loadData();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: _kAnimationDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
  }

  void _loadFilterPreferences() {
    _trackingFilter =
        _settingsManager.getSetting("applications.trackingFilter") ?? "all";
    _visibilityFilter =
        _settingsManager.getSetting("applications.visibilityFilter") ?? "all";
    _selectedCategory =
        _settingsManager.getSetting("applications.selectedCategory") ?? "All";
  }

  Future<void> _loadData() async {
    try {
      final allApps = await ApplicationsDataProvider().fetchAllApplications();
      if (!mounted) return;

      setState(() {
        _apps = allApps.map(AppViewModel.fromDetail).toList();
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      debugPrint('Error loading applications data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    _animationController.reset();
    setState(() => _isLoading = true);
    await _loadData();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_kDebounceDuration, () {
      if (_searchValue != value && mounted) {
        setState(() => _searchValue = value);
      }
    });
  }

  void _updateFilter(String key, String value, void Function(String) setter) {
    setState(() {
      setter(value);
      _settingsManager.updateSetting("applications.$key", value);
    });
  }

  Future<void> _toggleAppSetting(String type, bool value, String name) async {
    final index = _apps.indexWhere((app) => app.name == name);
    if (index == -1) return;

    final tracker = BackgroundAppTracker();
    final currentApp = tracker.getTrackingInfo()['currentApp'];

    switch (type) {
      case 'isTracking':
        _apps[index].isTracking = value;
        await _appDataStore.updateAppMetadata(name, isTracking: value);
        if (!value && currentApp == name) {
          debugPrint('🛑 Tracking disabled for currently active app: $name');
        }
      case 'isHidden':
        _apps[index].isHidden = value;
        await _appDataStore.updateAppMetadata(name, isVisible: !value);
        if (value && currentApp == name) {
          debugPrint('🛑 Visibility disabled for currently active app: $name');
        }
    }
    setState(() {});
  }

  List<AppViewModel> get _filteredApps => _apps
      .where((app) =>
          app.hasData &&
          app.matchesTracking(_trackingFilter) &&
          app.matchesVisibility(_visibilityFilter) &&
          app.matchesCategory(_selectedCategory) &&
          app.matchesSearch(_searchValue))
      .toList();

  @override
  void dispose() {
    _debounce?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    if (_isLoading) {
      return ScaffoldPage(
        padding: EdgeInsets.zero,
        content: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ProgressRing(),
              const SizedBox(height: 16),
              Text(l10n.applicationsTitle, style: theme.typography.body),
            ],
          ),
        ),
      );
    }

    final filteredApps = _filteredApps;

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                changeSearchValue: _onSearchChanged,
                onRefresh: _refreshData,
              ),
              const SizedBox(height: 20),
              _FilterBar(
                trackingFilter: _trackingFilter,
                visibilityFilter: _visibilityFilter,
                selectedCategory: _selectedCategory,
                onTrackingFilterChanged: (v) => _updateFilter(
                    "trackingFilter", v, (s) => _trackingFilter = s),
                onVisibilityFilterChanged: (v) => _updateFilter(
                    "visibilityFilter", v, (s) => _visibilityFilter = s),
                onCategoryChanged: (v) => _updateFilter(
                    "selectedCategory", v, (s) => _selectedCategory = s),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  l10n.applicationCount(filteredApps.length),
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        theme.typography.caption?.color?.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: _DataTable(
                  apps: filteredApps,
                  toggleAppSetting: _toggleAppSetting,
                  refreshData: _refreshData,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final ValueChanged<String> changeSearchValue;
  final VoidCallback onRefresh;

  const _Header({
    required this.changeSearchValue,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final captionColor = theme.typography.caption?.color;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _GradientIconBox(
              icon: FluentIcons.app_icon_default,
              color: theme.accentColor,
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.applicationsTitle,
                  style: theme.typography.subtitle?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.applicationsSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: captionColor?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            _SearchBox(
              placeholder: l10n.searchApplication,
              onChanged: changeSearchValue,
            ),
            const SizedBox(width: 12),
            _BorderedIconButton(
              tooltip: l10n.refresh,
              icon: FluentIcons.refresh,
              onPressed: onRefresh,
            ),
          ],
        ),
      ],
    );
  }
}

class _GradientIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _GradientIconBox({
    required this.icon,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: size, color: color),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final String placeholder;
  final ValueChanged<String> onChanged;

  const _SearchBox({required this.placeholder, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      width: 260,
      height: 36,
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.inactiveBackgroundColor, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            FluentIcons.search,
            size: 14,
            color: theme.typography.caption?.color?.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextBox(
              placeholder: placeholder,
              onChanged: onChanged,
              decoration: WidgetStateProperty.all(
                const BoxDecoration(border: Border()),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _BorderedIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _BorderedIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.micaBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.inactiveBackgroundColor, width: 1),
          ),
          child: Icon(icon, size: 14, color: theme.typography.body?.color),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

// ─── Filter Bar ───────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final String trackingFilter;
  final String visibilityFilter;
  final String selectedCategory;
  final ValueChanged<String> onTrackingFilterChanged;
  final ValueChanged<String> onVisibilityFilterChanged;
  final ValueChanged<String> onCategoryChanged;

  const _FilterBar({
    required this.trackingFilter,
    required this.visibilityFilter,
    required this.selectedCategory,
    required this.onTrackingFilterChanged,
    required this.onVisibilityFilterChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _CardContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _FilterDropdown(
                icon: FluentIcons.checkbox_composite,
                label: _trackingLabel(l10n),
                activeColor: _kGreenColor,
                items: [
                  _DropdownItem(FluentIcons.view_all, l10n.allTracking, "all"),
                  _DropdownItem(
                      FluentIcons.check_mark, l10n.tracking, "tracked"),
                  _DropdownItem(
                      FluentIcons.cancel, l10n.notTracking, "untracked"),
                ],
                selectedValue: trackingFilter,
                onChanged: onTrackingFilterChanged,
              ),
              const SizedBox(width: 16),
              _FilterDropdown(
                icon: FluentIcons.view,
                label: _visibilityLabel(l10n),
                activeColor: _kPurpleColor,
                items: [
                  _DropdownItem(
                      FluentIcons.view_all, l10n.allVisibility, "all"),
                  _DropdownItem(FluentIcons.red_eye, l10n.visible, "visible"),
                  _DropdownItem(FluentIcons.hide3, l10n.hidden, "hidden"),
                ],
                selectedValue: visibilityFilter,
                onChanged: onVisibilityFilterChanged,
              ),
            ],
          ),
          _CategoryDropdown(
            selectedCategory: selectedCategory,
            onChanged: onCategoryChanged,
          ),
        ],
      ),
    );
  }

  String _trackingLabel(AppLocalizations l10n) => switch (trackingFilter) {
        "tracked" => l10n.tracking,
        "untracked" => l10n.notTracking,
        _ => l10n.allTracking,
      };

  String _visibilityLabel(AppLocalizations l10n) => switch (visibilityFilter) {
        "visible" => l10n.visible,
        "hidden" => l10n.hidden,
        _ => l10n.allVisibility,
      };
}

class _DropdownItem {
  final IconData icon;
  final String label;
  final String value;

  const _DropdownItem(this.icon, this.label, this.value);
}

class _FilterDropdown extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color activeColor;
  final List<_DropdownItem> items;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: activeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: DropDownButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: activeColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: activeColor,
              ),
            ),
          ],
        ),
        items: items.map((item) {
          final isSelected = item.value == selectedValue;
          return MenuFlyoutItem(
            leading: Icon(
              item.icon,
              size: 14,
              color: isSelected
                  ? activeColor
                  : theme.typography.body?.color?.withValues(alpha: 0.6),
            ),
            text: Text(
              item.label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? activeColor : null,
              ),
            ),
            onPressed: () => onChanged(item.value),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onChanged;

  const _CategoryDropdown({
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropDownButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FluentIcons.filter, size: 12, color: theme.accentColor),
            const SizedBox(width: 8),
            Text(
              selectedCategory == 'All' ? l10n.allCategories : selectedCategory,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        items: [
          MenuFlyoutItem(
            leading: const Icon(FluentIcons.globe, size: 14),
            text: Text(l10n.allCategories),
            onPressed: () => onChanged('All'),
          ),
          const MenuFlyoutSeparator(),
          ...AppCategories.categories.map((category) => MenuFlyoutItem(
                text: Text(category.name),
                onPressed: () => onChanged(category.name),
              )),
        ],
      ),
    );
  }
}

// ─── Data Table ───────────────────────────────────────────────────────────────

class _DataTable extends StatelessWidget {
  final List<AppViewModel> apps;
  final void Function(String type, bool value, String name) toggleAppSetting;
  final Future<void> Function() refreshData;

  const _DataTable({
    required this.apps,
    required this.toggleAppSetting,
    required this.refreshData,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    if (apps.isEmpty) {
      return _EmptyState(theme: theme, l10n: l10n);
    }

    return _CardContainer(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            _TableHeaderRow(l10n: l10n, theme: theme),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final app = apps[index];
                  return _ApplicationRow(
                    app: app,
                    toggleAppSetting: toggleAppSetting,
                    refreshData: refreshData,
                    isLast: index == apps.length - 1,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final FluentThemeData theme;
  final AppLocalizations l10n;

  const _EmptyState({required this.theme, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FluentIcons.app_icon_default,
            size: 48,
            color: theme.inactiveBackgroundColor,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noApplicationsFound,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.typography.body?.color?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tryAdjustingFilters,
            style: TextStyle(
              fontSize: 13,
              color: theme.typography.caption?.color?.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  final AppLocalizations l10n;
  final FluentThemeData theme;

  const _TableHeaderRow({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _TableHeader(label: l10n.tableName, flex: 3),
          _TableHeader(label: l10n.tableCategory, flex: 2),
          _TableHeader(label: l10n.tableScreenTime, flex: 2, centered: true),
          _TableHeader(label: l10n.tableTracking, flex: 1, centered: true),
          _TableHeader(label: l10n.tableHidden, flex: 1, centered: true),
          _TableHeader(label: l10n.tableEdit, flex: 1, centered: true),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String label;
  final int flex;
  final bool centered;

  const _TableHeader({
    required this.label,
    required this.flex,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Expanded(
      flex: flex,
      child: Container(
        alignment: centered ? Alignment.center : Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.typography.body?.color?.withValues(alpha: 0.7),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─── Application Row ──────────────────────────────────────────────────────────

class _ApplicationRow extends StatefulWidget {
  final AppViewModel app;
  final void Function(String type, bool value, String name) toggleAppSetting;
  final Future<void> Function() refreshData;
  final bool isLast;

  const _ApplicationRow({
    required this.app,
    required this.toggleAppSetting,
    required this.refreshData,
    required this.isLast,
  });

  @override
  State<_ApplicationRow> createState() => _ApplicationRowState();
}

class _ApplicationRowState extends State<_ApplicationRow> {
  bool _isHovered = false;

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _EditAppDialog(
        app: widget.app,
        refreshData: widget.refreshData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final app = widget.app;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: _kHoverDuration,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _isHovered
              ? theme.inactiveBackgroundColor.withValues(alpha: 0.3)
              : Colors.transparent,
          border: widget.isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
        ),
        child: Row(
          children: [
            // Name
            Expanded(
              flex: 3,
              child: Text(
                app.name,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Category
            Expanded(
              flex: 2,
              child: _Chip(
                label: app.category,
                color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
                textColor: theme.typography.body?.color?.withValues(alpha: 0.8),
              ),
            ),
            // Screen Time
            Expanded(
              flex: 2,
              child: Center(
                child: _Chip(
                  label: app.screenTime,
                  color: theme.accentColor.withValues(alpha: 0.1),
                  textColor: theme.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Tracking Toggle
            Expanded(
              flex: 1,
              child: Center(
                child: _CompactToggle(
                  value: app.isTracking,
                  onChanged: (v) =>
                      widget.toggleAppSetting('isTracking', v, app.name),
                  activeColor: _kGreenColor,
                ),
              ),
            ),
            // Hidden Toggle
            Expanded(
              flex: 1,
              child: Center(
                child: _CompactToggle(
                  value: app.isHidden,
                  onChanged: (v) =>
                      widget.toggleAppSetting('isHidden', v, app.name),
                  activeColor: _kPurpleColor,
                ),
              ),
            ),
            // Edit Button
            Expanded(
              flex: 1,
              child: Center(
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? theme.accentColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      FluentIcons.edit,
                      size: 14,
                      color: _isHovered
                          ? theme.accentColor
                          : theme.typography.body?.color
                              ?.withValues(alpha: 0.5),
                    ),
                  ),
                  onPressed: () => _showEditDialog(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final FontWeight fontWeight;

  const _Chip({
    required this.label,
    required this.color,
    this.textColor,
    this.fontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: fontWeight,
          color: textColor,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ─── Edit Dialog ──────────────────────────────────────────────────────────────

class _EditAppDialog extends StatefulWidget {
  final AppViewModel app;
  final Future<void> Function() refreshData;

  const _EditAppDialog({required this.app, required this.refreshData});

  @override
  State<_EditAppDialog> createState() => _EditAppDialogState();
}

class _EditAppDialogState extends State<_EditAppDialog> {
  late String _selectedCategory;
  late bool _isProductive;
  late bool _isTracking;
  late bool _isVisible;
  late bool _limitStatus;
  late int _limitHours;
  late int _limitMinutes;
  late bool _isCustomCategory;
  late TextEditingController _customCategoryController;

  @override
  void initState() {
    super.initState();
    final app = widget.app;
    _selectedCategory = app.category;
    _isProductive = app.isProductive;
    _isTracking = app.isTracking;
    _isVisible = !app.isHidden;
    _limitStatus = app.limitStatus;
    _limitHours = app.dailyLimit.inHours;
    _limitMinutes = app.dailyLimit.inMinutes.remainder(60);
    _isCustomCategory =
        !AppCategories.categories.any((c) => c.name == _selectedCategory);
    _customCategoryController = TextEditingController(
      text: _isCustomCategory ? _selectedCategory : '',
    );
  }

  @override
  void dispose() {
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    final finalCategory = _isCustomCategory
        ? (_customCategoryController.text.isNotEmpty
            ? _customCategoryController.text
            : l10n.uncategorized)
        : _selectedCategory;

    await AppDataStore().updateAppMetadata(
      widget.app.name,
      category: finalCategory,
      isProductive: _isProductive,
      isTracking: _isTracking,
      isVisible: _isVisible,
      dailyLimit: Duration(hours: _limitHours, minutes: _limitMinutes),
      limitStatus: _limitStatus,
    );

    await widget.refreshData();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 480),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(FluentIcons.edit, size: 20, color: theme.accentColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.editAppTitle(widget.app.name),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l10n.configureAppSettings,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color:
                        theme.typography.caption?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Section
            _DialogSection(
              icon: FluentIcons.tag,
              title: l10n.categorySection,
              iconColor: _kBlueColor,
              child: _buildCategorySection(l10n),
            ),
            const SizedBox(height: 16),
            // Behavior Section
            _DialogSection(
              icon: FluentIcons.settings,
              title: l10n.behaviorSection,
              iconColor: _kGreenColor,
              child: Column(
                children: [
                  _DialogToggle(
                    icon: FluentIcons.chart,
                    label: l10n.isProductive,
                    value: _isProductive,
                    onChanged: (v) => setState(() => _isProductive = v),
                    activeColor: _kGreenColor,
                  ),
                  const SizedBox(height: 8),
                  _DialogToggle(
                    icon: FluentIcons.timer,
                    label: l10n.trackUsage,
                    value: _isTracking,
                    onChanged: (v) => setState(() => _isTracking = v),
                    activeColor: _kBlueColor,
                  ),
                  const SizedBox(height: 8),
                  _DialogToggle(
                    icon: FluentIcons.view,
                    label: l10n.visibleInReports,
                    value: _isVisible,
                    onChanged: (v) => setState(() => _isVisible = v),
                    activeColor: _kPurpleColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Time Limits Section
            _DialogSection(
              icon: FluentIcons.clock,
              title: l10n.timeLimitsSection,
              iconColor: _kAmberColor,
              child: Column(
                children: [
                  _DialogToggle(
                    icon: FluentIcons.stopwatch,
                    label: l10n.enableDailyLimit,
                    value: _limitStatus,
                    onChanged: (v) => setState(() => _limitStatus = v),
                    activeColor: _kAmberColor,
                  ),
                  AnimatedSize(
                    duration: _kToggleDuration,
                    child: _limitStatus
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _kAmberColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _TimeInputField(
                                      label: l10n.hours,
                                      value: _limitHours,
                                      max: 24,
                                      onChanged: (v) => setState(
                                          () => _limitHours = v?.toInt() ?? 0),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _TimeInputField(
                                      label: l10n.minutes,
                                      value: _limitMinutes,
                                      max: 59,
                                      onChanged: (v) => setState(() =>
                                          _limitMinutes = v?.toInt() ?? 0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Button(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(l10n.cancel),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FluentIcons.save, size: 14),
                const SizedBox(width: 8),
                Text(l10n.saveChanges),
              ],
            ),
          ),
          onPressed: () => _save(l10n),
        ),
      ],
    );
  }

  Widget _buildCategorySection(AppLocalizations l10n) {
    return Column(
      children: [
        ComboBox<String>(
          value: _isCustomCategory ? l10n.customCategory : _selectedCategory,
          isExpanded: true,
          items: [
            ...AppCategories.categories.map((category) => ComboBoxItem<String>(
                  value: category.name,
                  child: Text(category.name),
                )),
            ComboBoxItem<String>(
              value: l10n.customCategory,
              child: Text(l10n.customCategory),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _isCustomCategory = value == l10n.customCategory;
                if (!_isCustomCategory) _selectedCategory = value;
              });
            }
          },
        ),
        AnimatedSize(
          duration: _kToggleDuration,
          child: _isCustomCategory
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextBox(
                    controller: _customCategoryController,
                    placeholder: l10n.customCategoryPlaceholder,
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─── Shared Components ────────────────────────────────────────────────────────

class _CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _CardContainer({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CompactToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const _CompactToggle({
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: _kToggleDuration,
        width: 36,
        height: 20,
        decoration: BoxDecoration(
          color: value
              ? activeColor
              : FluentTheme.of(context).inactiveBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: AnimatedAlign(
          duration: _kToggleDuration,
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Widget child;

  const _DialogSection({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.typography.body?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DialogToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const _DialogToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: value
            ? activeColor.withValues(alpha: 0.08)
            : theme.inactiveBackgroundColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: value
                    ? activeColor
                    : theme.typography.body?.color?.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                  color: value ? activeColor : theme.typography.body?.color,
                ),
              ),
            ],
          ),
          _CompactToggle(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }
}

class _TimeInputField extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Function(num?) onChanged;

  const _TimeInputField({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _kAmberColor,
          ),
        ),
        const SizedBox(height: 6),
        NumberBox(
          value: value,
          min: 0,
          max: max,
          mode: SpinButtonPlacementMode.inline,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
