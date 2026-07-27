// ─── Extension Web Dashboard ──────────────────────────────────────────────────
//
// Full-page layout for the Flutter web dashboard when opened as an extension tab.
// Replicates the premium desktop sidebar structure and design system (collapsible
// left sidebar, top app bar, theme customization) but tailored for website tracking.

import 'dart:ui' show lerpDouble;
import 'package:fluent_ui/fluent_ui.dart';
import 'dart:async';
import 'package:screentime/web/web_location_helper.dart'
    if (dart.library.io) 'package:screentime/web/web_location_helper_stub.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:screentime/app_design.dart';
import 'package:screentime/adaptive_fluent/adaptive_theme_fluent_ui.dart';
import 'package:screentime/sections/UI sections/Settings/theme_provider.dart';
import 'package:screentime/sections/UI sections/Settings/theme_customization_model.dart';

import 'package:screentime/sections/overview.dart';
import 'package:screentime/sections/applications.dart';
import 'package:screentime/sections/reports.dart';
import 'package:screentime/sections/alerts_limits.dart';
import 'package:screentime/sections/focus_mode.dart';
import 'package:screentime/sections/settings.dart' as native_settings;
import 'UI sections/Browser/browser_extension_status.dart';
import 'UI sections/Browser/browser_websites.dart';
import 'UI sections/Browser/browser_shared.dart';
import 'package:screentime/onboarding/web_onboarding_screen.dart';

import '../web/extension_settings.dart'
    if (dart.library.io) '../web/extension_settings_stub.dart';
import '../web/chrome_storage_interop.dart'
    if (dart.library.io) '../web/chrome_storage_interop_stub.dart';

// ─── Web Dashboard Root ───────────────────────────────────────────────────────

class WebDashboard extends StatefulWidget {
  const WebDashboard({super.key});

  @override
  State<WebDashboard> createState() => _WebDashboardState();
}

class _WebDashboardState extends State<WebDashboard>
    with SingleTickerProviderStateMixin {
  // Sidebar state
  bool _isSidebarExpanded = true;
  late AnimationController _sidebarAnimController;
  late Animation<double> _sidebarAnimation;
  int _selectedIndex = 0;

  // Extension status state
  ExtensionMode _mode = ExtensionMode.standalone;
  String? _activeDomain;
  bool _isLoading = true;
  bool _showOnboarding = false;

  StreamSubscription? _hashSub;

  @override
  void initState() {
    super.initState();
    _sidebarAnimController = AnimationController(
      vsync: this,
      duration: AppDesign.animMedium,
    );
    _sidebarAnimation = CurvedAnimation(
      parent: _sidebarAnimController,
      curve: Curves.easeInOutCubic,
    );
    _sidebarAnimController.value = 1.0;

    if (kIsWeb) {
      _hashSub = subscribeHashChange(_checkHashNavigation);
    }

    _load();
  }

  @override
  void dispose() {
    _hashSub?.cancel();
    _sidebarAnimController.dispose();
    super.dispose();
  }

  void _checkHashNavigation() {
    if (!kIsWeb) return;
    if (isSettingsUrl()) {
      if (_selectedIndex != 5) {
        setState(() => _selectedIndex = 5);
      }
    }
  }

  Future<void> _load() async {
    final mode = await ExtensionSettings().getMode();
    final state = await _readAppState();
    int initialIndex = 0;
    if (kIsWeb) {
      if (isSettingsUrl()) {
        initialIndex = 5;
      }
    }
    bool showOnboarding = false;
    if (kIsWeb) {
      final stored = await chromeStorageGet(['onboarding_completed']);
      showOnboarding = stored['onboarding_completed'] != true;
    }

    if (!mounted) return;
    setState(() {
      _mode = mode;
      _activeDomain = state?['activeDomain'] as String?;
      _selectedIndex = initialIndex;
      _isLoading = false;
      _showOnboarding = showOnboarding;
    });
  }

  Future<Map<String, dynamic>?> _readAppState() async {
    if (!kIsWeb) return null;
    try {
      final result = await chromeStorageGet(['scolect_app_state']);
      return result['scolect_app_state'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
      if (_isSidebarExpanded) {
        _sidebarAnimController.forward();
      } else {
        _sidebarAnimController.reverse();
      }
    });
  }

  void _onModeChanged(ExtensionMode mode) {
    setState(() {
      _mode = mode;
      // If switching modes, update selection state if necessary
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeCustomizationProvider>();
    final customTheme = themeProvider.currentTheme;

    if (_isLoading) {
      return const ScaffoldPage(
        padding: EdgeInsets.zero,
        content: Center(child: ProgressRing()),
      );
    }

    if (_showOnboarding) {
      return WebOnboardingScreen(
        onComplete: () => setState(() => _showOnboarding = false),
      );
    }

    return Column(
      children: [
        // ── Top App Bar (Enhanced Title Bar styled) ─────────────────────────
        _WebTitleBar(
          mode: _mode,
          activeDomain: _activeDomain,
          onToggleSidebar: _toggleSidebar,
          isSidebarExpanded: _isSidebarExpanded,
        ),

        // ── Main Body (Sidebar + Content Area Row) ──────────────────────────
        Expanded(
          child: Row(
            children: [
              // Left Collapsible Sidebar
              AnimatedBuilder(
                animation: _sidebarAnimation,
                builder: (context, child) {
                  final expandProgress = _sidebarAnimation.value;
                  final width = lerpDouble(
                    AppDesign.sidebarCollapsedWidth,
                    AppDesign.sidebarExpandedWidth,
                    expandProgress,
                  )!;

                  return SizedBox(
                    width: width,
                    child: _WebSidebar(
                      width: width,
                      isExpanded: _isSidebarExpanded,
                      expandProgress: expandProgress,
                      selectedIndex: _selectedIndex,
                      onItemSelected: (idx) =>
                          setState(() => _selectedIndex = idx),
                      isDark: isDark,
                      customTheme: customTheme,
                    ),
                  );
                },
              ),

              // Main content panel
              Expanded(
                child: Container(
                  color: isDark
                      ? AppDesign.darkBackground
                      : AppDesign.lightBackground,
                  child: AnimatedSwitcher(
                    duration: AppDesign.animMedium,
                    child: _getPage(_selectedIndex),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getPage(int index) {
    // If tracker-only mode is active, force overview page to display the status screen
    if (_mode == ExtensionMode.trackerOnly && index == 0) {
      return BrowserExtensionStatus(
        key: const ValueKey('tracker_only_status'),
        onSwitchToStandalone: () => _onModeChanged(ExtensionMode.standalone),
      );
    }

    switch (index) {
      case 0:
        return const Overview(key: ValueKey('native_overview'));
      case 1:
        return const Applications(key: ValueKey('native_apps'));
      case 2:
        return const Reports(key: ValueKey('native_reports'));
      case 3:
        return const AlertsLimits(key: ValueKey('native_limits'));
      case 4:
        return const FocusMode(key: ValueKey('native_focus'));
      case 5:
        return native_settings.Settings(
          key: const ValueKey('native_settings'),
          setLocale: (_) {},
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Web Title Bar ───────────────────────────────────────────────────────────

class _WebTitleBar extends StatelessWidget {
  final ExtensionMode mode;
  final String? activeDomain;
  final VoidCallback onToggleSidebar;
  final bool isSidebarExpanded;

  const _WebTitleBar({
    required this.mode,
    required this.activeDomain,
    required this.onToggleSidebar,
    required this.isSidebarExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final captionColor = theme.typography.caption?.color;
    final themeProvider = context.watch<ThemeCustomizationProvider>();
    final customTheme = themeProvider.currentTheme;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? customTheme.darkSurface : customTheme.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? customTheme.darkBorder : customTheme.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Sidebar Toggle Button (matches desktop title bar toggle)
          IconButton(
            icon: Icon(
              isSidebarExpanded
                  ? FluentIcons.global_nav_button
                  : FluentIcons.global_nav_button,
              size: 16,
            ),
            onPressed: onToggleSidebar,
            style: ButtonStyle(
              backgroundColor: ButtonState.all(Colors.transparent),
            ),
          ),
          const SizedBox(width: 12),

          // Title
          Text(
            'Scolect Web Dashboard',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.typography.body?.color,
            ),
          ),

          const SizedBox(width: 16),

          // Active Tracking Indicator
          if (activeDomain != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: kBrowserGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: kBrowserGreen.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulseDot(),
                  const SizedBox(width: 6),
                  Text(
                    activeDomain!,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: kBrowserGreen.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

          const Spacer(),

          // Mode Chip
          _ModeChip(mode: mode),
          const SizedBox(width: 12),

          // Theme Toggle
          _ThemeToggleButton(),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kBrowserGreen.withValues(alpha: 0.4 + _anim.value * 0.6),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final ExtensionMode mode;
  const _ModeChip({required this.mode});

  Color get _color => switch (mode) {
        ExtensionMode.standalone => kBrowserBlue,
        ExtensionMode.trackerOnly => kBrowserGreen,
        ExtensionMode.hybrid => kBrowserPurple,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.2)),
      ),
      child: Text(
        mode.label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Tooltip(
      message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            try {
              FluentAdaptiveTheme.of(context).toggleThemeMode();
            } catch (_) {}
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppDesign.radiusSm),
            ),
            child: Icon(
              isDark ? FluentIcons.sunny : FluentIcons.clear_night,
              size: 14,
              color: theme.typography.body?.color?.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Web Sidebar ─────────────────────────────────────────────────────────────

class _WebSidebar extends StatelessWidget {
  final double width;
  final bool isExpanded;
  final double expandProgress;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isDark;
  final CustomThemeData customTheme;

  const _WebSidebar({
    required this.width,
    required this.isExpanded,
    required this.expandProgress,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.isDark,
    required this.customTheme,
  });

  List<_WebNavItem> _buildNavItems() {
    return const [
      _WebNavItem(icon: FluentIcons.home, label: 'Overview', index: 0),
      _WebNavItem(
          icon: FluentIcons.globe, label: 'Websites', index: 1),
      _WebNavItem(
          icon: FluentIcons.report_document, label: 'Reports', index: 2),
      _WebNavItem(icon: FluentIcons.timer, label: 'Limits', index: 3),
      _WebNavItem(icon: FluentIcons.focus, label: 'Focus Mode', index: 4),
      _WebNavItem.separator(),
      _WebNavItem(icon: FluentIcons.settings, label: 'Settings', index: 5),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _buildNavItems();
    final isCompact = expandProgress < 0.5;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isDark
            ? customTheme.darkSurfaceSecondary
            : customTheme.lightSurface,
        border: Border(
          right: BorderSide(
            color: isDark ? customTheme.darkBorder : customTheme.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header Logo
          _SidebarLogo(
            expandProgress: expandProgress,
            isDark: isDark,
            isCompact: isCompact,
          ),
          const SizedBox(height: 12),

          // Menu Items List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal:
                    isCompact ? AppDesign.spacingXs : AppDesign.spacingMd,
                vertical: AppDesign.spacingSm,
              ),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];

                if (item.isSeparator) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical:
                          isCompact ? AppDesign.spacingSm : AppDesign.spacingMd,
                      horizontal: isCompact ? AppDesign.spacingSm : 0,
                    ),
                    child: Divider(
                      style: DividerThemeData(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppDesign.darkBorder
                              : AppDesign.lightBorder,
                        ),
                      ),
                    ),
                  );
                }

                return _SidebarItemButton(
                  icon: item.icon!,
                  label: item.label!,
                  isSelected: selectedIndex == item.index,
                  expandProgress: expandProgress,
                  isDark: isDark,
                  isCompact: isCompact,
                  onTap: () => onItemSelected(item.index!),
                );
              },
            ),
          ),

          // "Get Desktop App" promo card at bottom of Web Sidebar (shown if NOT connected to Desktop App)
          if (!isCompact) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: customTheme.primaryAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: customTheme.primaryAccent.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          FluentIcons.desktop_flow,
                          size: 14,
                          color: customTheme.primaryAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Get Desktop App',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? customTheme.darkTextPrimary
                                : customTheme.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Unlock full system app tracking & automatic sync across devices.',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark
                            ? customTheme.darkTextSecondary
                            : customTheme.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          openDownloadUrl();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: customTheme.primaryAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Text(
                              'Download App',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Sidebar Footer version indicator
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Opacity(
              opacity: isCompact ? 0 : 0.4,
              child: Text(
                'v2.1.3 Stable',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sidebar Logo Header ──────────────────────────────────────────────────────

class _SidebarLogo extends StatelessWidget {
  final double expandProgress;
  final bool isDark;
  final bool isCompact;

  const _SidebarLogo({
    required this.expandProgress,
    required this.isDark,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final design = AppDesign.of(context);
    final margin = isCompact ? AppDesign.spacingXs : AppDesign.spacingMd;
    final padding = isCompact ? AppDesign.spacingSm : AppDesign.spacingLg;

    return Container(
      margin: EdgeInsets.all(margin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: design.subtleGradient(isDark),
        borderRadius: BorderRadius.circular(AppDesign.radiusLg),
        border: Border.all(
          color: design.primaryAccent.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDesign.spacingSm),
            decoration: BoxDecoration(
              gradient: design.primaryGradient,
              borderRadius: BorderRadius.circular(AppDesign.radiusMd),
            ),
            child: const Icon(
              FluentIcons.globe,
              size: 14,
              color: Colors.white,
            ),
          ),
          if (!isCompact) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Scolect',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Web Tracker',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.38)
                          : Colors.black.withValues(alpha: 0.38),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Sidebar Item Button ──────────────────────────────────────────────────────

class _SidebarItemButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final double expandProgress;
  final bool isDark;
  final bool isCompact;
  final VoidCallback onTap;

  const _SidebarItemButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.expandProgress,
    required this.isDark,
    required this.isCompact,
    required this.onTap,
  });

  @override
  State<_SidebarItemButton> createState() => _SidebarItemButtonState();
}

class _SidebarItemButtonState extends State<_SidebarItemButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final design = AppDesign.of(context);

    final highlightColor = design.primaryAccent;
    final textStyle = TextStyle(
      fontSize: 13,
      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
      color: widget.isSelected
          ? highlightColor
          : widget.isDark
              ? Colors.white.withValues(alpha: 0.7)
              : Colors.black.withValues(alpha: 0.7),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppDesign.animFast,
          height: 50,
          margin: const EdgeInsets.only(bottom: 6),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCompact ? 14 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? highlightColor.withValues(alpha: 0.12)
                : _isHovered
                    ? theme.inactiveBackgroundColor.withValues(alpha: 0.3)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDesign.radiusMd),
            border: Border.all(
              color: widget.isSelected
                  ? highlightColor.withValues(alpha: 0.2)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: widget.isCompact
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                widget.icon,
                size: 15,
                color: widget.isSelected ? highlightColor : textStyle.color,
              ),
              if (!widget.isCompact) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Nav Item Helper Model ────────────────────────────────────────────────────

class _WebNavItem {
  final IconData? icon;
  final String? label;
  final int? index;
  final bool isSeparator;

  const _WebNavItem({
    required this.icon,
    required this.label,
    required this.index,
  }) : isSeparator = false;

  const _WebNavItem.separator()
      : icon = null,
        label = null,
        index = null,
        isSeparator = true;
}
