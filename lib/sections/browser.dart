import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screentime/app_design.dart';
import 'package:screentime/main.dart';
import 'package:screentime/sections/controller/data_controllers/browser_data_controller.dart';
import 'dart:async';
import 'UI sections/Browser/browser_shared.dart';
import 'UI sections/Browser/browser_overview.dart';
import 'UI sections/Browser/browser_websites.dart';
import 'UI sections/Browser/browser_categories.dart';
import 'UI sections/Browser/browser_limits.dart';
import 'UI sections/Browser/browser_extension_status.dart';
import 'UI sections/Browser/browser_extension_settings.dart';

// Conditionally import extension settings (web only)
import '../web/extension_settings.dart'
    if (dart.library.io) '../web/extension_settings_stub.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _kDebounceDuration = Duration(milliseconds: 300);

// ─── Main section widget ──────────────────────────────────────────────────────

class Browser extends StatefulWidget {
  const Browser({super.key});

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> with SingleTickerProviderStateMixin {
  final _provider = BrowserDataProvider();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  BrowserTab _currentTab = BrowserTab.overview;
  bool _isLoading = true;
  ({Duration totalTime, int siteCount, int visitCount})? _summary;
  Timer? _debounce;

  // Web-only: extension mode state
  ExtensionMode _extensionMode = ExtensionMode.standalone;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: kBrowserAnimDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigationState.registerRefreshCallback(_refreshData);
    });

    _loadSummary();
    if (kIsWeb) _loadExtensionMode();
  }

  Future<void> _loadSummary() async {
    final summary = await _provider.fetchTodaySummary();
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _isLoading = false;
    });
    _animationController.forward();
  }

  Future<void> _loadExtensionMode() async {
    final mode = await ExtensionSettings().getMode();
    if (!mounted) return;
    setState(() => _extensionMode = mode);
  }

  Future<void> _refreshData() async {
    _animationController.reset();
    setState(() => _isLoading = true);
    await _loadSummary();
  }

  void _switchTab(BrowserTab tab) {
    setState(() => _currentTab = tab);
  }

  void _onModeChanged(ExtensionMode mode) {
    setState(() {
      _extensionMode = mode;
      // If switching away from tracker-only, go to overview
      if (mode != ExtensionMode.trackerOnly &&
          _currentTab == BrowserTab.settings) {
        _currentTab = BrowserTab.overview;
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final captionColor = theme.typography.caption?.color;

    if (_isLoading) {
      return ScaffoldPage(
        padding: EdgeInsets.zero,
        content: const Center(child: ProgressRing()),
      );
    }

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      BrowserGradientIconBox(
                        icon: FluentIcons.globe,
                        color: theme.accentColor,
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Browser',
                            style: theme.typography.subtitle?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            kIsWeb
                                ? 'Website tracking · ${_extensionMode.label}'
                                : 'Track and manage your website usage',
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
                      // Hybrid sync badge
                      if (kIsWeb && _extensionMode == ExtensionMode.hybrid)
                        _SyncBadge(),

                      if (_summary != null) ...[
                        if (kIsWeb && _extensionMode == ExtensionMode.hybrid)
                          const SizedBox(width: 16),
                        _QuickStat(
                          label: 'Today',
                          value: _summary!.totalTime.toHourMinuteFormat(),
                          color: theme.accentColor,
                        ),
                        const SizedBox(width: 20),
                        _QuickStat(
                          label: 'Sites',
                          value: '${_summary!.siteCount}',
                          color: kBrowserPurple,
                        ),
                        const SizedBox(width: 16),
                      ],
                      BrowserIconButton(
                        tooltip: 'Refresh',
                        icon: FluentIcons.refresh,
                        onPressed: _refreshData,
                      ),
                      // Settings icon (web only)
                      if (kIsWeb) ...[
                        const SizedBox(width: 8),
                        BrowserIconButton(
                          tooltip: 'Extension Settings',
                          icon: FluentIcons.settings,
                          onPressed: () => _switchTab(BrowserTab.settings),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ── Tab bar (hidden in tracker-only mode) ─────────────────────
            if (!kIsWeb || _extensionMode != ExtensionMode.trackerOnly) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: _buildTabBar(theme),
              ),
              const SizedBox(height: 4),
            ],

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(FluentThemeData theme) {
    // On web: show overview / websites / categories / limits / (settings via icon)
    // Filter out settings from tab bar — it's accessed via the gear icon
    final tabs = kIsWeb
        ? BrowserTab.values.where((t) => t != BrowserTab.settings).toList()
        : BrowserTab.values.where((t) => t != BrowserTab.settings).toList();

    return BrowserCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs.map((tab) {
          final selected = _currentTab == tab;
          return _TabButton(
            label: tab.label,
            icon: tab.icon,
            selected: selected,
            onTap: () => _switchTab(tab),
            accent: theme.accentColor,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    // Tracker-only mode: show status screen instead of full dashboard
    if (kIsWeb && _extensionMode == ExtensionMode.trackerOnly) {
      return BrowserExtensionStatus(
        key: const ValueKey('tracker_only_status'),
        onSwitchToStandalone: () => _onModeChanged(ExtensionMode.standalone),
      );
    }

    // Settings tab (web only)
    if (_currentTab == BrowserTab.settings) {
      return BrowserExtensionSettings(
        key: const ValueKey('ext_settings'),
        onModeChanged: _onModeChanged,
      );
    }

    return switch (_currentTab) {
      BrowserTab.overview => BrowserOverview(
          key: const ValueKey('browser_overview'),
          onTabChange: _switchTab,
        ),
      BrowserTab.websites => BrowserWebsites(
          key: const ValueKey('browser_websites'),
          onTabChange: _switchTab,
        ),
      BrowserTab.categories => BrowserCategories(
          key: const ValueKey('browser_categories'),
          onTabChange: _switchTab,
        ),
      BrowserTab.limits => BrowserLimits(
          key: const ValueKey('browser_limits'),
          onTabChange: _switchTab,
        ),
      BrowserTab.settings => const SizedBox.shrink(),
    };
  }
}

// ─── Hybrid sync badge ────────────────────────────────────────────────────────

class _SyncBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kBrowserPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBrowserPurple.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kBrowserPurple,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Syncing',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kBrowserPurple.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick stat chip in header ────────────────────────────────────────────────

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.typography.caption?.color?.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

// ─── Tab button ───────────────────────────────────────────────────────────────

class _TabButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.accent,
  });

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: kBrowserHoverDuration,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.selected
                ? widget.accent.withValues(alpha: 0.15)
                : _hovered
                    ? theme.inactiveBackgroundColor.withValues(alpha: 0.5)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: widget.selected
                    ? widget.accent
                    : theme.typography.caption?.color?.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      widget.selected ? FontWeight.w600 : FontWeight.w400,
                  color: widget.selected
                      ? widget.accent
                      : theme.typography.caption?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on Duration {
  String toHourMinuteFormat() {
    if (inSeconds < 60) return '${inSeconds}s';
    final h = inHours;
    final m = inMinutes % 60;
    if (h > 0) return m > 0 ? '${h}h ${m}m' : '${h}h';
    return '${m}m';
  }
}
