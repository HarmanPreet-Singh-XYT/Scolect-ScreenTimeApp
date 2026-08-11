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
import 'package:screentime/sections/widgets/Settings/theme_provider.dart';
import 'package:screentime/sections/widgets/Settings/theme_customization_model.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart' show ThemeOptions, SettingsManager;
import 'package:screentime/utils/responsive.dart';

import 'package:screentime/sections/overview.dart';
import 'package:screentime/sections/applications.dart';
import 'package:screentime/sections/reports.dart';
import 'package:screentime/sections/alerts_limits.dart';
import 'package:screentime/sections/focus_mode.dart';
import 'package:screentime/sections/settings.dart' as native_settings;
import 'package:screentime/sections/help.dart';
import 'widgets/Browser/browser_extension_status.dart';
import 'widgets/Browser/browser_websites.dart';
import 'widgets/Browser/browser_shared.dart';
import 'package:screentime/onboarding/web_onboarding_screen.dart';

import '../web/extension_settings.dart'
    if (dart.library.io) '../web/extension_settings_stub.dart';
import '../web/chrome_storage_interop.dart'
    if (dart.library.io) '../web/chrome_storage_interop_stub.dart';
import 'package:screentime/l10n/app_localizations.dart';

// ─── Web Dashboard Root ───────────────────────────────────────────────────────

class WebDashboard extends StatefulWidget {
  final Function(Locale) setLocale;

  const WebDashboard({super.key, required this.setLocale});

  @override
  State<WebDashboard> createState() => _WebDashboardState();
}

class _WebDashboardState extends State<WebDashboard>
    with SingleTickerProviderStateMixin {
  // Sidebar state
  bool _isSidebarExpanded = true;
  bool _appliedInitialSidebarState = false;
  late AnimationController _sidebarAnimController;
  late Animation<double> _sidebarAnimation;
  int _selectedIndex = 0;

  // Extension status state
  ExtensionMode _mode = ExtensionMode.standalone;
  bool _isLoading = true;
  bool _showOnboarding = false;
  bool _everConnected = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kIsWeb) _syncOverlayStrings(context);
  }

  // Called from the body LayoutBuilder (the same width source that decides
  // mobile vs desktop layout) so the initial sidebar state can never
  // disagree with which layout is actually showing. Mutates state directly
  // (no setState) so the correction lands in this same build pass instead
  // of flashing the drawer open for one frame first.
  void _applyInitialSidebarStateFor(bool isMobile) {
    if (_appliedInitialSidebarState) return;
    _appliedInitialSidebarState = true;
    if (isMobile) {
      _isSidebarExpanded = false;
      _sidebarAnimController.value = 0.0;
    }
  }

  void _syncOverlayStrings(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (l == null) return;
    chromeStorageSet({
      'scolect_overlay_strings': {
        'badge': l.blockOverlayBadge,
        'title': l.blockOverlayTitle,
        'timeSpent': l.blockOverlayTimeSpent,
        'dailyLimit': l.blockOverlayDailyLimit,
        'visitsToday': l.blockOverlayVisitsToday,
        'resetsIn': l.blockOverlayResetsIn,
        'goBack': l.blockOverlayGoBack,
        'openDashboard': l.blockOverlayOpenDashboard,
        'unblockToday': l.blockOverlayUnblockToday,
        'unblockButton': l.blockOverlayUnblockButton,
        'footer': l.blockOverlayFooter,
        'unblockConfirmLabel': l.blockOverlayUnblockConfirmLabel('{siteName}'),
      },
    });
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
    bool everConnected = false;
    if (kIsWeb) {
      final stored = await chromeStorageGet(['onboarding_completed', 'scolect_ever_connected']);
      showOnboarding = stored['onboarding_completed'] != true;
      everConnected = stored['scolect_ever_connected'] == true;
    }

    if (!mounted) return;
    setState(() {
      _mode = mode;
      _selectedIndex = initialIndex;
      _isLoading = false;
      _showOnboarding = showOnboarding;
      _everConnected = everConnected;
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = Responsive.isMobileWidth(constraints.maxWidth);
        _applyInitialSidebarStateFor(isMobile);

        return Column(
          children: [
            // ── Top App Bar (Enhanced Title Bar styled) ─────────────────────
            _WebTitleBar(
              mode: _mode,
              onToggleSidebar: _toggleSidebar,
              isSidebarExpanded: _isSidebarExpanded,
              isMobile: isMobile,
            ),

            // ── Main Body (Sidebar + Content Area) ───────────────────────────
            Expanded(
              child: isMobile
                  ? _buildMobileBody(isDark, customTheme)
                  : _buildDesktopBody(isDark, customTheme),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopBody(bool isDark, CustomThemeData customTheme) {
    return Row(
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
                onItemSelected: (idx) => setState(() => _selectedIndex = idx),
                isDark: isDark,
                customTheme: customTheme,
                everConnected: _everConnected,
              ),
            );
          },
        ),

        // Main content panel
        Expanded(
          child: Container(
            color: isDark ? AppDesign.darkBackground : AppDesign.lightBackground,
            child: AnimatedSwitcher(
              duration: AppDesign.animMedium,
              child: _getPage(_selectedIndex),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBody(bool isDark, CustomThemeData customTheme) {
    return Stack(
      children: [
        // Main content panel fills the full width on mobile
        Positioned.fill(
          child: Container(
            color: isDark ? AppDesign.darkBackground : AppDesign.lightBackground,
            child: AnimatedSwitcher(
              duration: AppDesign.animMedium,
              child: _getPage(_selectedIndex),
            ),
          ),
        ),

        // Backdrop + drawer. IgnorePointer keeps them out of the hit-test
        // tree entirely once closed, so content below stays tappable and
        // scrollable — an invisible (opacity 0) widget still blocks hits.
        IgnorePointer(
          ignoring: !_isSidebarExpanded,
          child: GestureDetector(
            onTap: _toggleSidebar,
            child: AnimatedBuilder(
              animation: _sidebarAnimation,
              builder: (context, child) => Opacity(
                opacity: _sidebarAnimation.value,
                child: child,
              ),
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
          ),
        ),
        IgnorePointer(
          ignoring: !_isSidebarExpanded,
          child: AnimatedBuilder(
            animation: _sidebarAnimation,
            builder: (context, child) {
              const drawerWidth = AppDesign.sidebarExpandedWidth;
              final offsetX = lerpDouble(
                -drawerWidth,
                0,
                _sidebarAnimation.value,
              )!;

              return Transform.translate(
                offset: Offset(offsetX, 0),
                child: child,
              );
            },
            child: SizedBox(
              width: AppDesign.sidebarExpandedWidth,
              height: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(4, 0),
                    ),
                  ],
                ),
                child: _WebSidebar(
                  width: AppDesign.sidebarExpandedWidth,
                  isExpanded: true,
                  expandProgress: 1.0,
                  selectedIndex: _selectedIndex,
                  onItemSelected: (idx) {
                    setState(() => _selectedIndex = idx);
                    _toggleSidebar();
                  },
                  isDark: isDark,
                  customTheme: customTheme,
                  everConnected: _everConnected,
                ),
              ),
            ),
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
          setLocale: widget.setLocale,
        );
      case 6:
        return const Help(key: ValueKey('native_help'));
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Web Title Bar ───────────────────────────────────────────────────────────

class _WebTitleBar extends StatelessWidget {
  final ExtensionMode mode;
  final VoidCallback onToggleSidebar;
  final bool isSidebarExpanded;
  final bool isMobile;

  const _WebTitleBar({
    required this.mode,
    required this.onToggleSidebar,
    required this.isSidebarExpanded,
    required this.isMobile,
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

          // Title (shortened on mobile so the mode chip / theme toggle fit)
          Expanded(
            child: Text(
              isMobile ? 'Scolect' : 'Scolect Web Dashboard',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.typography.body?.color,
              ),
            ),
          ),

          const SizedBox(width: 8),

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
    final themeProvider = context.watch<ThemeCustomizationProvider>();

    return Tooltip(
      message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            final next = isDark ? ThemeOptions.light : ThemeOptions.dark;
            themeProvider.setThemeMode(next);
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
  final bool everConnected;

  const _WebSidebar({
    required this.width,
    required this.isExpanded,
    required this.expandProgress,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.isDark,
    required this.customTheme,
    required this.everConnected,
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
      _WebNavItem(icon: FluentIcons.chat_bot, label: 'Help', index: 6),
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

          // "Get Desktop App" promo card (hidden once user has connected desktop app at least once)
          if (!isCompact && !everConnected) ...[
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
                      'Unlock full system-level tracking & automatic sync with your browser data.',
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
                'v${SettingsManager().versionInfo["version"]} Stable',
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
              boxShadow: [
                BoxShadow(
                  color: design.primaryAccent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(
              'assets/icons/tray_icon_mac.png',
              width: 20,
              height: 20,
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
                    'Open Source',
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
