import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/main.dart';
import 'package:screentime/sections/controller/data_controllers/browser_data_controller.dart';
import 'package:screentime/sections/settings.dart';
import 'dart:async';
import 'widgets/Browser/browser_shared.dart';
import 'widgets/Browser/browser_overview.dart';
import 'widgets/Browser/browser_websites.dart';
import 'widgets/Browser/browser_categories.dart';
import 'widgets/Browser/browser_limits.dart';
import 'widgets/Browser/browser_history.dart';

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
          onEnabled: () => settings.updateSetting('browserExtensionEnabled', true),
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
                            l10n.browserTitle,
                            style: theme.typography.subtitle?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            l10n.browserSubtitle,
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
                      if (serverEnabled)
                        _ServerBadge(),

                      if (_summary != null) ...[
                        const SizedBox(width: 16),
                        _QuickStat(
                          label: l10n.browserToday,
                          value: _summary!.totalTime.toHourMinuteFormat(),
                          color: theme.accentColor,
                        ),
                        const SizedBox(width: 20),
                        _QuickStat(
                          label: l10n.browserSites,
                          value: '${_summary!.siteCount}',
                          color: kBrowserPurple,
                        ),
                        const SizedBox(width: 16),
                      ],
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
                          onPressed: () => _switchTab(BrowserTab.settings),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ── Tab bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _buildTabBar(theme, l10n),
            ),
            const SizedBox(height: 4),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
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
    final tabs = BrowserTab.values.where((t) => t != BrowserTab.settings).toList();

    return BrowserCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs.map((tab) {
          final selected = _currentTab == tab;
          return _TabButton(
            label: _tabLabel(tab, l10n),
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
      BrowserTab.settings => const _DesktopServerSettings(key: ValueKey('desktop_server_settings')),
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
    _portController = TextEditingController(text: '${settings.browserServerPort}');
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
    displayInfoBar(context, builder: (ctx, close) => InfoBar(
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
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: SizedBox(
          width: 520,
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
              child: Icon(FluentIcons.globe, size: 40, color: theme.accentColor),
            ),
            const SizedBox(height: 24),

            // Title + subtitle
            Text(
              l10n.browserSetupTitle,
              style: theme.typography.subtitle?.copyWith(fontWeight: FontWeight.w700),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                              ? l10n.browserSetupServerRunning(settings.browserServerPort)
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.browserServerPort,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                            style: const TextStyle(fontSize: 11, color: Color(0xFFE53935)),
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
                        if (_portError != null) setState(() => _portError = null);
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kBrowserAmber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(FluentIcons.info, size: 16, color: kBrowserAmber),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Browser limits are enforced by the Chrome Extension',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Daily limits and website blocking only work inside Chrome. Install the extension and enable this server — the extension handles all enforcement and syncs data here.',
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
              child: Row(
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
                  const SizedBox(width: 16),
                  Button(
                    onPressed: () {
                      final platformStr = defaultTargetPlatform == TargetPlatform.macOS
                          ? 'mac'
                          : defaultTargetPlatform == TargetPlatform.windows
                              ? 'windows'
                              : 'linux';
                      launchUrl(
                        Uri.parse('https://www.scolect.com/download?source=desktop&platform=$platformStr'),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(theme.accentColor.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FluentIcons.open_in_new_window, size: 12, color: theme.accentColor),
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
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Steps card
            BrowserCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  _SetupStep(number: 4, text: l10n.browserSetupStep4, last: true),
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
  const _DesktopServerSettings({super.key});

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
    _portController = TextEditingController(text: '${settings.browserServerPort}');
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
    displayInfoBar(context, builder: (ctx, close) => InfoBar(
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
                    color: (settings.browserExtensionEnabled ? kBrowserGreen : (captionColor ?? theme.accentColor))
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
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        settings.browserExtensionEnabled
                            ? l10n.browserSetupServerRunning(settings.browserServerPort)
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
                  onChanged: (v) => settings.updateSetting('browserExtensionEnabled', v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Port configuration ─────────────────────────────────────────
          Text(
            l10n.browserServerPort,
            style: theme.typography.bodyStrong?.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
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
                          if (_portError != null) setState(() => _portError = null);
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
                    style: const TextStyle(fontSize: 11, color: Color(0xFFE53935)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Server running badge (desktop) ──────────────────────────────────────────

class _ServerBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kBrowserGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBrowserGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kBrowserGreen,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            l10n.browserSetupServerActive,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kBrowserGreen.withValues(alpha: 0.9),
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
