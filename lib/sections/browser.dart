import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/main.dart' show navigationState;
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/browser_source_filter.dart';
import 'package:screentime/sections/controller/data_controllers/browser_data_controller.dart';
import 'package:screentime/sections/settings.dart';
import 'package:screentime/utils/browser_extension_server_stub.dart'
    if (dart.library.io) 'package:screentime/utils/browser_extension_server.dart';
import 'dart:async';
import 'widgets/Browser/browser_shared.dart';
import 'widgets/Browser/browser_overview.dart';
import 'widgets/Browser/browser_websites.dart';
import 'widgets/Browser/browser_categories.dart';
import 'widgets/Browser/browser_limits.dart';
import 'widgets/Browser/browser_history.dart';
import 'widgets/Browser/browser_source_filter_dropdown.dart'
    show iconForBrowser;

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
  int _refreshKey = 0;
  ({Duration totalTime, int siteCount, int visitCount})? _summary;
  int _siteCount = 0;
  int _categoryCount = 0;
  int _activeLimitsCount = 0;
  int _productivePercentage = 0;
  Timer? _syncStatusTimer;

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

    // Repaint the "last synced" badge periodically so its relative time
    // ("Xs ago") and stale/warning state stay current without user action.
    _syncStatusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });

    // Swapping the header's browser-source filter should immediately re-fetch
    // every website number on this page under the new selection.
    BrowserSourceFilterProvider().addListener(_refreshData);
    _provider.addListener(_loadSummary);
  }

  Future<void> _loadSummary() async {
    final summary = await _provider.fetchTodaySummary();
    final sites = await _provider.fetchAllWebsites();
    final cats = await _provider.fetchAllCategories();
    if (!mounted) return;

    final activeLimits = sites.where((s) => s.dailyLimit > Duration.zero).length;
    final totalWebSecs = summary.totalTime.inSeconds;
    final productiveSecs = sites
        .where((s) => s.isProductive)
        .fold<int>(0, (sum, s) => sum + s.timeSpent.inSeconds);
    final prodPct = totalWebSecs > 0 ? (productiveSecs / totalWebSecs * 100).round() : 0;

    setState(() {
      _summary = summary;
      _siteCount = sites.length;
      _categoryCount = cats.where((c) => c != 'All').length;
      _activeLimitsCount = activeLimits;
      _productivePercentage = prodPct;
      _isLoading = false;
    });
    _animationController.forward();
  }

  Future<void> _refreshData() async {
    _animationController.reset();
    setState(() {
      _isLoading = true;
      _refreshKey++;
    });
    await _loadSummary();
  }

  void _switchTab(BrowserTab tab) {
    setState(() => _currentTab = tab);
  }

  @override
  void dispose() {
    _syncStatusTimer?.cancel();
    BrowserSourceFilterProvider().removeListener(_refreshData);
    _provider.removeListener(_loadSummary);
    _animationController.dispose();
    super.dispose();
  }

  String _tabLabel(BrowserTab tab, AppLocalizations l10n) => switch (tab) {
        BrowserTab.overview => l10n.browserTabOverview,
        BrowserTab.websites => l10n.browserTabWebsites,
        BrowserTab.categories => l10n.browserTabCategories,
        BrowserTab.limits => l10n.browserTabLimits,
        BrowserTab.history => l10n.browserTabHistory,
        BrowserTab.settings => l10n.settings,
      };

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final captionColor = theme.typography.caption?.color;

    final settings = context.watch<SettingsProvider>();
    final serverEnabled = settings.browserExtensionEnabled;

    if (_isLoading) {
      return ScaffoldPage(
        padding: EdgeInsets.zero,
        content: const Center(child: ProgressRing()),
      );
    }

    if (!serverEnabled) {
      return ScaffoldPage(
        padding: EdgeInsets.zero,
        content: _DesktopSetupScreen(
          onEnabled: () =>
              settings.updateSetting('browserExtensionEnabled', true),
        ),
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
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 620;

                  final titleSection = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BrowserGradientIconBox(
                        icon: FluentIcons.globe,
                        color: theme.accentColor,
                        size: 22,
                        boxSize: 42,
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.browserTitle,
                            style: theme.typography.subtitle?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            l10n.browserSubtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: captionColor?.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(child: titleSection),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                BrowserIconButton(
                                  tooltip: l10n.refresh,
                                  icon: FluentIcons.refresh,
                                  onPressed: _refreshData,
                                ),
                                if (serverEnabled) ...[
                                  const SizedBox(width: 8),
                                  BrowserIconButton(
                                    tooltip: l10n.browserExtensionSettings,
                                    icon: FluentIcons.settings,
                                    color: _currentTab == BrowserTab.settings ? theme.accentColor : null,
                                    onPressed: () => _switchTab(BrowserTab.settings),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (serverEnabled)
                              _ServerBadge(
                                lastSyncAt: BrowserExtensionServer.lastUsageSyncAt,
                              ),
                            if (_summary != null && _summary!.totalTime > Duration.zero) ...[
                              _HeaderStatBadge(
                                icon: FluentIcons.timer,
                                label: _summary!.totalTime.toHourMinuteFormat(),
                                sublabel: l10n.browserToday,
                                color: theme.accentColor,
                              ),
                              _HeaderStatBadge(
                                icon: FluentIcons.check_mark,
                                label: '$_productivePercentage%',
                                sublabel: l10n.productive,
                                color: _productivePercentage >= 60
                                    ? kBrowserGreen
                                    : kBrowserAmber,
                              ),
                              if (_activeLimitsCount > 0)
                                _HeaderStatBadge(
                                  icon: FluentIcons.time_picker,
                                  label: '$_activeLimitsCount',
                                  sublabel: l10n.browserTabLimits,
                                  color: kBrowserPurple,
                                ),
                            ],
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      titleSection,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (serverEnabled)
                            _ServerBadge(
                              lastSyncAt: BrowserExtensionServer.lastUsageSyncAt,
                            ),
                          if (_summary != null && _summary!.totalTime > Duration.zero) ...[
                            const SizedBox(width: 12),
                            _HeaderStatBadge(
                              icon: FluentIcons.timer,
                              label: _summary!.totalTime.toHourMinuteFormat(),
                              sublabel: l10n.browserToday,
                              color: theme.accentColor,
                            ),
                            const SizedBox(width: 8),
                            _HeaderStatBadge(
                              icon: FluentIcons.check_mark,
                              label: '$_productivePercentage%',
                              sublabel: l10n.productive,
                              color: _productivePercentage >= 60
                                  ? kBrowserGreen
                                  : kBrowserAmber,
                            ),
                            if (_activeLimitsCount > 0) ...[
                              const SizedBox(width: 8),
                              _HeaderStatBadge(
                                icon: FluentIcons.time_picker,
                                label: '$_activeLimitsCount',
                                sublabel: l10n.browserTabLimits,
                                color: kBrowserPurple,
                              ),
                            ],
                          ],
                          const SizedBox(width: 12),
                          BrowserIconButton(
                            tooltip: l10n.refresh,
                            icon: FluentIcons.refresh,
                            onPressed: _refreshData,
                          ),
                          if (serverEnabled) ...[
                            const SizedBox(width: 8),
                            BrowserIconButton(
                              tooltip: l10n.browserExtensionSettings,
                              icon: FluentIcons.settings,
                              color: _currentTab == BrowserTab.settings ? theme.accentColor : null,
                              onPressed: () => _switchTab(BrowserTab.settings),
                            ),
                          ],
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Segmented Tab bar ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: _buildTabBar(theme, l10n),
            ),
            const SizedBox(height: 4),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                ),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(FluentThemeData theme, AppLocalizations l10n) {
    return BrowserSegmentedTabBar(
      currentTab: _currentTab,
      onTabChanged: _switchTab,
      tabLabels: {
        for (final tab in BrowserTab.values)
          tab: _tabLabel(tab, l10n),
      },
      tabCounts: {
        BrowserTab.websites: _siteCount,
        BrowserTab.categories: _categoryCount,
        BrowserTab.limits: _activeLimitsCount,
      },
    );
  }

  Widget _buildContent() {
    return switch (_currentTab) {
      BrowserTab.overview => BrowserOverview(
          key: ValueKey('browser_overview_$_refreshKey'),
          onTabChange: _switchTab,
        ),
      BrowserTab.websites => BrowserWebsites(
          key: ValueKey('browser_websites_$_refreshKey'),
          onTabChange: _switchTab,
        ),
      BrowserTab.categories => BrowserCategories(
          key: ValueKey('browser_categories_$_refreshKey'),
          onTabChange: _switchTab,
        ),
      BrowserTab.limits => BrowserLimits(
          key: ValueKey('browser_limits_$_refreshKey'),
          onTabChange: _switchTab,
        ),
      BrowserTab.history => BrowserHistory(
          key: ValueKey('browser_history_$_refreshKey'),
        ),
      BrowserTab.settings => _DesktopServerSettings(
          key: const ValueKey('desktop_server_settings'),
          onDataCleared: _refreshData,
        ),
    };
  }
}

// ─── Desktop setup screen ─────────────────────────────────────────────────────

class _DesktopSetupScreen extends StatefulWidget {
  final VoidCallback onEnabled;
  const _DesktopSetupScreen({required this.onEnabled});

  @override
  State<_DesktopSetupScreen> createState() => _DesktopSetupScreenState();
}

class _DesktopSetupScreenState extends State<_DesktopSetupScreen> {
  late TextEditingController _portController;
  String? _portError;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _portController =
        TextEditingController(text: '${settings.browserServerPort}');
  }

  @override
  void dispose() {
    _portController.dispose();
    super.dispose();
  }

  void _savePort(SettingsProvider settings, AppLocalizations l10n) {
    final value = int.tryParse(_portController.text.trim());
    if (value == null || value < 1024 || value > 65535) {
      setState(() => _portError = l10n.browserServerPortInvalid);
      return;
    }
    setState(() => _portError = null);
    settings.updateSetting('browserServerPort', value);
    displayInfoBar(context,
        builder: (ctx, close) => InfoBar(
              title: Text(l10n.browserServerPortSaved),
              action: Button(onPressed: close, child: Text(l10n.ok)),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final captionColor = theme.typography.caption?.color;
    final settings = context.watch<SettingsProvider>();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.accentColor.withValues(alpha: 0.15),
                      theme.accentColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child:
                    Icon(FluentIcons.globe, size: 40, color: theme.accentColor),
              ),
              const SizedBox(height: 24),

              // Title + subtitle
              Text(
                l10n.browserSetupTitle,
                style: theme.typography.subtitle
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.browserSetupSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: captionColor?.withValues(alpha: 0.6),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Enable toggle card
              BrowserCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (settings.browserExtensionEnabled
                                ? kBrowserGreen
                                : captionColor ?? theme.accentColor)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        FluentIcons.plug_connected,
                        size: 16,
                        color: settings.browserExtensionEnabled
                            ? kBrowserGreen
                            : captionColor?.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.browserSetupEnableServer,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            settings.browserExtensionEnabled
                                ? l10n.browserSetupServerRunning(
                                    settings.browserServerPort)
                                : l10n.browserSetupServerOff,
                            style: TextStyle(
                              fontSize: 12,
                              color: settings.browserExtensionEnabled
                                  ? kBrowserGreen
                                  : captionColor?.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ToggleSwitch(
                      checked: settings.browserExtensionEnabled,
                      onChanged: (v) =>
                          settings.updateSetting('browserExtensionEnabled', v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Port configuration card
              BrowserCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.browserServerPort,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.browserServerPortDesc,
                            style: TextStyle(
                              fontSize: 12,
                              color: captionColor?.withValues(alpha: 0.5),
                            ),
                          ),
                          if (_portError != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _portError!,
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFFE53935)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 90,
                      child: TextBox(
                        controller: _portController,
                        keyboardType: TextInputType.number,
                        placeholder: '46000',
                        style: const TextStyle(fontSize: 13),
                        onChanged: (_) {
                          if (_portError != null)
                            setState(() => _portError = null);
                        },
                        onSubmitted: (_) => _savePort(settings, l10n),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Button(
                      onPressed: () => _savePort(settings, l10n),
                      child: Text(l10n.saveButton),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Browser limits info card ───────────────────────────────────
              BrowserCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kBrowserAmber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(FluentIcons.info,
                          size: 16, color: kBrowserAmber),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.browserLimitsExtensionInfo,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.browserLimitsExtensionInfoDesc,
                            style: TextStyle(
                              fontSize: 12,
                              color: captionColor?.withValues(alpha: 0.65),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Chrome Extension Promo Card
              BrowserCard(
                padding: const EdgeInsets.all(20),
                child: LayoutBuilder(
                  builder: (context, cardConstraints) {
                    final isCardNarrow = cardConstraints.maxWidth < 440;

                    final iconAndText = Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            FluentIcons.globe,
                            size: 22,
                            color: theme.accentColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Get the Scolect Chrome Extension',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Set daily limits, block sites when limits are reached, and sync website usage to this app — all enforced directly in Chrome.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: captionColor?.withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    final actionButton = Button(
                      onPressed: () {
                        final platformStr = defaultTargetPlatform ==
                                TargetPlatform.macOS
                            ? 'mac'
                            : defaultTargetPlatform == TargetPlatform.windows
                                ? 'windows'
                                : 'linux';
                        launchUrl(
                          Uri.parse(
                              'https://www.scolect.com/download?source=desktop&platform=$platformStr'),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            theme.accentColor.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FluentIcons.open_in_new_window,
                              size: 12, color: theme.accentColor),
                          const SizedBox(width: 6),
                          Text(
                            'Extension Info',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.accentColor,
                            ),
                          ),
                        ],
                      ),
                    );

                    if (isCardNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          iconAndText,
                          const SizedBox(height: 12),
                          actionButton,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: iconAndText),
                        const SizedBox(width: 16),
                        actionButton,
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Steps card
              BrowserCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.browserSetupHowTo,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: captionColor?.withValues(alpha: 0.5),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SetupStep(number: 1, text: l10n.browserSetupStep1),
                    _SetupStep(number: 2, text: l10n.browserSetupStep2),
                    _SetupStep(number: 3, text: l10n.browserSetupStep3),
                    _SetupStep(
                        number: 4, text: l10n.browserSetupStep4, last: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupStep extends StatelessWidget {
  final int number;
  final String text;
  final bool last;

  const _SetupStep({
    required this.number,
    required this.text,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final captionColor = theme.typography.caption?.color;

    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 10),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: captionColor?.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Desktop server settings tab ─────────────────────────────────────────────

class _DesktopServerSettings extends StatefulWidget {
  final VoidCallback? onDataCleared;
  const _DesktopServerSettings({super.key, this.onDataCleared});

  @override
  State<_DesktopServerSettings> createState() => _DesktopServerSettingsState();
}

class _DesktopServerSettingsState extends State<_DesktopServerSettings> {
  late TextEditingController _portController;
  String? _portError;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _portController =
        TextEditingController(text: '${settings.browserServerPort}');
  }

  @override
  void dispose() {
    _portController.dispose();
    super.dispose();
  }

  void _validateAndSavePort(SettingsProvider settings, AppLocalizations l10n) {
    final value = int.tryParse(_portController.text.trim());
    if (value == null || value < 1024 || value > 65535) {
      setState(() => _portError = l10n.browserServerPortInvalid);
      return;
    }
    setState(() => _portError = null);
    settings.updateSetting('browserServerPort', value);
    displayInfoBar(context,
        builder: (ctx, close) => InfoBar(
              title: Text(l10n.browserServerPortSaved),
              action: Button(onPressed: close, child: Text(l10n.ok)),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final captionColor = theme.typography.caption?.color;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Enable / disable toggle ────────────────────────────────────
          BrowserCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (settings.browserExtensionEnabled
                            ? kBrowserGreen
                            : (captionColor ?? theme.accentColor))
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FluentIcons.plug_connected,
                    size: 16,
                    color: settings.browserExtensionEnabled
                        ? kBrowserGreen
                        : captionColor?.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.browserSetupEnableServer,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        settings.browserExtensionEnabled
                            ? l10n.browserSetupServerRunning(
                                settings.browserServerPort)
                            : l10n.browserSetupServerOff,
                        style: TextStyle(
                          fontSize: 12,
                          color: settings.browserExtensionEnabled
                              ? kBrowserGreen
                              : captionColor?.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                ToggleSwitch(
                  checked: settings.browserExtensionEnabled,
                  onChanged: (v) =>
                      settings.updateSetting('browserExtensionEnabled', v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Port configuration ─────────────────────────────────────────
          Text(
            l10n.browserServerPort,
            style: theme.typography.bodyStrong
                ?.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          BrowserCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.browserServerPortDesc,
                  style: TextStyle(
                    fontSize: 12,
                    color: captionColor?.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: TextBox(
                        controller: _portController,
                        keyboardType: TextInputType.number,
                        placeholder: '46000',
                        style: const TextStyle(fontSize: 13),
                        onChanged: (_) {
                          if (_portError != null)
                            setState(() => _portError = null);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: settings.browserExtensionEnabled
                          ? () => _validateAndSavePort(settings, l10n)
                          : null,
                      child: Text(l10n.saveButton),
                    ),
                  ],
                ),
                if (_portError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _portError!,
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFFE53935)),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Connected browsers ──────────────────────────────────────────
          Text(
            l10n.browserConnectedBrowsers,
            style: theme.typography.bodyStrong
                ?.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.browserConnectedBrowsersDesc,
            style: TextStyle(
                fontSize: 12, color: captionColor?.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 8),
          const _ConnectedBrowsersList(),

          const SizedBox(height: 20),

          // ── Delete browser data ────────────────────────────────────────
          Text(
            l10n.browserDesktopClearDataTitle,
            style: theme.typography.bodyStrong
                ?.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          BrowserCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.browserDesktopClearDataDescription,
                    style: TextStyle(
                      fontSize: 12,
                      color: captionColor?.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Button(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      const Color(0xFFE53935).withValues(alpha: 0.1),
                    ),
                    foregroundColor:
                        const WidgetStatePropertyAll(Color(0xFFE53935)),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: Color(0xFFE53935)),
                      ),
                    ),
                  ),
                  onPressed: () => _confirmClearWebData(context, l10n),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.delete,
                          size: 12, color: Color(0xFFE53935)),
                      const SizedBox(width: 6),
                      Text(l10n.browserDesktopClearDataButtonLabel),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearWebData(
      BuildContext context, AppLocalizations l10n) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Row(
          children: [
            const Icon(FluentIcons.warning, color: Color(0xFFE53935), size: 20),
            const SizedBox(width: 10),
            Text(l10n.browserDesktopClearDataDialogTitle),
          ],
        ),
        content: Text(l10n.browserDesktopClearDataDialogContent),
        actions: [
          Button(
            child: Text(l10n.cancelButton),
            onPressed: () => Navigator.pop(ctx),
          ),
          FilledButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0xFFE53935)),
            ),
            child: Text(l10n.browserDesktopClearDataButtonLabel),
            onPressed: () async {
              Navigator.pop(ctx);
              await AppDataStore().clearWebData();
              widget.onDataCleared?.call();
              navigationState.refreshCurrentScreen();
              if (context.mounted) {
                displayInfoBar(
                  context,
                  builder: (infoCtx, close) => InfoBar(
                    title: Text(l10n.browserDesktopClearDataTitle),
                    action: Button(onPressed: close, child: Text(l10n.ok)),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─── Connected browsers (desktop) ────────────────────────────────────────────

class _ConnectedBrowsersList extends StatefulWidget {
  const _ConnectedBrowsersList();

  @override
  State<_ConnectedBrowsersList> createState() => _ConnectedBrowsersListState();
}

class _ConnectedBrowsersListState extends State<_ConnectedBrowsersList> {
  final _dataStore = AppDataStore();

  @override
  void initState() {
    super.initState();
    _dataStore.addListener(_onChanged);
  }

  @override
  void dispose() {
    _dataStore.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _ping(BrowserSource source) {
    BrowserExtensionServer.pingBrowser(source.id);
    final l10n = AppLocalizations.of(context)!;
    displayInfoBar(
      context,
      builder: (ctx, close) => InfoBar(
        title: Text(l10n.browserSourcePingSent(source.localizedLabel(l10n))),
        severity: InfoBarSeverity.info,
        action: IconButton(
          icon: const Icon(FluentIcons.clear, size: 12),
          onPressed: close,
        ),
      ),
    );
  }

  Future<void> _rename(BrowserSource source) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _RenameBrowserDialog(source: source),
    );
    if (result != null) {
      await _dataStore.renameBrowserSource(source.id, result);
    }
  }

  Future<void> _remove(BrowserSource source) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Text(l10n.browserSourceRemoveTitle),
        content:
            Text(l10n.browserSourceRemoveConfirm(source.localizedLabel(l10n))),
        actions: [
          Button(
            child: Text(l10n.cancelButton),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          FilledButton(
            child: Text(l10n.browserSourceRemoveAction),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      BrowserSourceFilterProvider().clearIfSelected(source.id);
      await _dataStore.removeBrowserSource(source.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sources = _dataStore.browserSources;

    if (sources.isEmpty) {
      final theme = FluentTheme.of(context);
      return BrowserCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: Text(
            l10n.browserConnectedBrowsersEmpty,
            style: TextStyle(
              fontSize: 12,
              color: theme.typography.caption?.color?.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return BrowserCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        children: [
          for (int i = 0; i < sources.length; i++) ...[
            if (i > 0) const Divider(size: double.infinity),
            _BrowserSourceRow(
              source: sources[i],
              onPing: () => _ping(sources[i]),
              onRename: () => _rename(sources[i]),
              onRemove: () => _remove(sources[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _BrowserSourceRow extends StatelessWidget {
  final BrowserSource source;
  final VoidCallback onPing;
  final VoidCallback onRename;
  final VoidCallback onRemove;

  const _BrowserSourceRow({
    required this.source,
    required this.onPing,
    required this.onRename,
    required this.onRemove,
  });

  String _lastSeenLabel(AppLocalizations l10n) {
    final elapsed = DateTime.now().difference(source.lastSeen);
    if (elapsed.inMinutes < 1) return l10n.browserSyncedJustNow;
    if (elapsed.inHours < 1)
      return l10n.browserSyncedMinutesAgo(elapsed.inMinutes);
    if (elapsed.inDays < 1) return l10n.browserSyncedHoursAgo(elapsed.inHours);
    return l10n.browserSourceLastSeenDaysAgo(elapsed.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kBrowserBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconForBrowser(source.detectedBrowser),
                size: 16, color: kBrowserBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.localizedLabel(l10n),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${l10n.browserSourceLastSeen}: ${_lastSeenLabel(l10n)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.typography.caption?.color
                        ?.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: l10n.browserSourcePingTooltip,
            child: IconButton(
              icon:
                  Icon(FluentIcons.ringer, size: 14, color: theme.accentColor),
              onPressed: onPing,
            ),
          ),
          IconButton(
            icon: const Icon(FluentIcons.edit, size: 14),
            onPressed: onRename,
          ),
          IconButton(
            icon: Icon(FluentIcons.delete, size: 14, color: kBrowserRed),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _RenameBrowserDialog extends StatefulWidget {
  final BrowserSource source;
  const _RenameBrowserDialog({required this.source});

  @override
  State<_RenameBrowserDialog> createState() => _RenameBrowserDialogState();
}

class _RenameBrowserDialogState extends State<_RenameBrowserDialog> {
  // Prefill only an actual user-assigned name — leaving this empty for a
  // source still on its default "Browser N" label means saving without
  // typing anything keeps that default live (and localized) instead of
  // freezing today's display language into displayName as literal text.
  late final TextEditingController _controller =
      TextEditingController(text: widget.source.displayName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 400),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(FluentIcons.edit, size: 18, color: theme.accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.browserRenameDialogTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextBox(
            controller: _controller,
            placeholder: widget.source.localizedLabel(l10n),
            autofocus: true,
            style: const TextStyle(fontSize: 13),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.cancelButton),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: Text(l10n.saveButton),
          onPressed: _submit,
        ),
      ],
    );
  }
}

// ─── Header Stat Badge ────────────────────────────────────────────────────────

class _HeaderStatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;

  const _HeaderStatBadge({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.12)
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.1,
                ),
              ),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: theme.typography.caption?.color?.withValues(alpha: 0.65),
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Server running badge (desktop) ──────────────────────────────────────────

class _ServerBadge extends StatefulWidget {
  final DateTime? lastSyncAt;

  const _ServerBadge({this.lastSyncAt});

  @override
  State<_ServerBadge> createState() => _ServerBadgeState();
}

class _ServerBadgeState extends State<_ServerBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  static const _staleAfter = Duration(minutes: 3);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final synced = widget.lastSyncAt;
    final isStale = synced == null || now.difference(synced) > _staleAfter;

    final String label;
    if (synced == null) {
      label = l10n.browserNeverSynced;
    } else {
      final elapsed = now.difference(synced);
      if (elapsed.inMinutes < 1) {
        label = l10n.browserSyncedJustNow;
      } else if (elapsed.inHours < 1) {
        label = l10n.browserSyncedMinutesAgo(elapsed.inMinutes);
      } else {
        label = l10n.browserSyncedHoursAgo(elapsed.inHours);
      }
    }

    final color = isStale ? kBrowserAmber : kBrowserGreen;

    return Tooltip(
      message: isStale ? l10n.browserSyncStalled : label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, _) => Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: isStale ? 0.8 : _pulseAnimation.value),
                  boxShadow: !isStale
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4 * _pulseAnimation.value),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
