import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/main.dart';
import 'package:screentime/sections/controller/data_controllers/alerts_limits_data_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'UI sections/AlertsLimits/applicationlimit.dart';
import 'UI sections/AlertsLimits/notificationCard.dart';
import 'UI sections/AlertsLimits/overalllimit.dart';
import 'UI sections/AlertsLimits/quickStats.dart';

// ──────────────── Settings Keys ────────────────

abstract final class _Keys {
  static const popup = 'limitsAlerts.popup';
  static const frequent = 'limitsAlerts.frequent';
  static const sound = 'limitsAlerts.sound';
  static const system = 'limitsAlerts.system';
  static const overallEnabled = 'limitsAlerts.overallLimit.enabled';
  static const overallHours = 'limitsAlerts.overallLimit.hours';
  static const overallMinutes = 'limitsAlerts.overallLimit.minutes';
}

// ──────────────── Main Page ────────────────

class AlertsLimits extends StatefulWidget {
  final ScreenTimeDataController? controller;
  final SettingsManager? settingsManager;

  const AlertsLimits({
    super.key,
    this.controller,
    this.settingsManager,
  });

  @override
  State<AlertsLimits> createState() => _AlertsLimitsState();
}

class _AlertsLimitsState extends State<AlertsLimits> {
  late final ScreenTimeDataController _controller;
  late final SettingsManager _settings;

  // Notification state
  bool _popupAlerts = false;
  bool _frequentAlerts = false;
  bool _soundAlerts = false;
  bool _systemAlerts = false;

  // Overall limit state
  bool _overallLimitEnabled = false;
  double _overallLimitHours = 2.0;
  double _overallLimitMinutes = 0.0;

  // Data state
  List<AppUsageSummary> _appSummaries = [];
  Duration _totalScreenTime = Duration.zero;
  bool _isLoading = true;
  String? _errorMessage;

  // ──────────────── lifecycle ────────────────

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScreenTimeDataController();
    _settings = widget.settingsManager ?? SettingsManager();
    _loadSettings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigationState.registerRefreshCallback(_loadData);
    });

    _loadData();
  }

  void _loadSettings() {
    _popupAlerts = _settings.getSetting(_Keys.popup);
    _frequentAlerts = _settings.getSetting(_Keys.frequent);
    _soundAlerts = _settings.getSetting(_Keys.sound);
    _systemAlerts = _settings.getSetting(_Keys.system);
    _overallLimitEnabled = _settings.getSetting(_Keys.overallEnabled) ?? false;
    _overallLimitHours =
        _settings.getSetting(_Keys.overallHours)?.toDouble() ?? 2.0;
    _overallLimitMinutes =
        _settings.getSetting(_Keys.overallMinutes)?.toDouble() ?? 0.0;
  }

  // ──────────────── data loading ────────────────

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _controller.initialize();
      final allData = await _controller.getAllData();

      if (!mounted) return;

      final summaries = (allData['appSummaries'] as List<dynamic>)
          .map((json) => AppUsageSummary.fromJson(json as Map<String, dynamic>))
          .toList();

      setState(() {
        _appSummaries = summaries;
        _totalScreenTime = Duration(
          minutes:
              summaries.fold(0, (sum, app) => sum + app.currentUsage.inMinutes),
        );
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            AppLocalizations.of(context)!.failedToLoadData(e.toString());
        _isLoading = false;
      });
    }
  }

  // ──────────────── notification settings ────────────────

  void _onNotificationChanged(AlertType type, bool value) {
    setState(() {
      switch (type) {
        case AlertType.popup:
          _popupAlerts = value;
        case AlertType.frequent:
          _frequentAlerts = value;
        case AlertType.sound:
          _soundAlerts = value;
        case AlertType.system:
          _systemAlerts = value;
      }
    });

    final settingsKey = switch (type) {
      AlertType.popup => _Keys.popup,
      AlertType.frequent => _Keys.frequent,
      AlertType.sound => _Keys.sound,
      AlertType.system => _Keys.system,
    };
    _settings.updateSetting(settingsKey, value);
  }

  // ──────────────── overall limit ────────────────

  void _onOverallEnabledChanged(bool value) {
    setState(() => _overallLimitEnabled = value);

    _settings.updateSetting(_Keys.overallEnabled, value);

    if (value) {
      _syncOverallLimit();
    } else {
      _controller.updateOverallLimit(Duration.zero, false);
    }
  }

  void _onOverallHoursChanged(double value) {
    setState(() => _overallLimitHours = value);
    _syncOverallLimit();
  }

  void _onOverallMinutesChanged(double value) {
    setState(() => _overallLimitMinutes = value);
    _syncOverallLimit();
  }

  void _syncOverallLimit() {
    final roundedMinutes = _overallLimitMinutes.round() ~/ 5 * 5;
    final duration = Duration(
      hours: _overallLimitHours.round(),
      minutes: roundedMinutes,
    );

    _settings.updateSetting(_Keys.overallHours, _overallLimitHours.round());
    _settings.updateSetting(_Keys.overallMinutes, roundedMinutes);
    _controller.updateOverallLimit(duration, _overallLimitEnabled);
  }

  // ──────────────── reset ────────────────

  void _resetAllLimits() {
    try {
      for (final app in _controller.getAllAppsSummary()) {
        _controller.updateAppLimit(app.appName, Duration.zero, false);
      }

      setState(() {
        _overallLimitEnabled = false;
        _overallLimitHours = 2.0;
        _overallLimitMinutes = 0.0;
      });

      _settings.updateSetting(_Keys.overallEnabled, false);
      _settings.updateSetting(_Keys.overallHours, 2);
      _settings.updateSetting(_Keys.overallMinutes, 0);
      _controller.updateOverallLimit(Duration.zero, false);
      _loadData();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              AppLocalizations.of(context)!.failedToLoadData(e.toString());
        });
      }
    }
  }

  // ──────────────── build ────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ScaffoldPage(
        padding: EdgeInsets.zero,
        content: Center(child: ProgressRing()),
      );
    }

    if (_errorMessage != null) {
      return ScaffoldPage(
        padding: EdgeInsets.zero,
        content: Center(
          child: _ErrorCard(
            message: _errorMessage!,
            onRetry: _loadData,
          ),
        ),
      );
    }

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1000;
          final isMedium = constraints.maxWidth >= 700;

          // Build cards once, reuse across layouts
          final notificationCard = NotificationSettingsCard(
            settings: NotificationSettings(
              frequentAlerts: _frequentAlerts,
              systemAlerts: _systemAlerts,
              soundAlerts: _soundAlerts,
              popupAlerts: _popupAlerts,
            ),
            onChanged: _onNotificationChanged,
          );

          final overallCard = OverallLimitCard(
            enabled: _overallLimitEnabled,
            hours: _overallLimitHours,
            minutes: _overallLimitMinutes,
            totalScreenTime: _totalScreenTime,
            onEnabledChanged: _onOverallEnabledChanged,
            onHoursChanged: _onOverallHoursChanged,
            onMinutesChanged: _onOverallMinutesChanged,
          );

          final appLimitsCard = ApplicationLimitsCard(
            appSummaries: _appSummaries,
            controller: _controller,
            onDataChanged: _loadData,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    onReset: _resetAllLimits,
                    onRefresh: _loadData,
                  ),
                  const SizedBox(height: 24),
                  QuickStatsRow(
                    totalScreenTime: _totalScreenTime,
                    appsWithLimits:
                        _appSummaries.where((a) => a.limitStatus).length,
                    appsNearLimit: _appSummaries
                        .where((a) => a.isAboutToReachLimit)
                        .length,
                    isMedium: isMedium,
                  ),
                  const SizedBox(height: 24),
                  _ContentLayout(
                    isWide: isWide,
                    isMedium: isMedium,
                    notificationCard: notificationCard,
                    overallCard: overallCard,
                    appLimitsCard: appLimitsCard,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════ Content Layout ═══════════════════
// Single widget handles all 3 responsive breakpoints.
// Cards are passed in — never duplicated.

class _ContentLayout extends StatelessWidget {
  final bool isWide;
  final bool isMedium;
  final Widget notificationCard;
  final Widget overallCard;
  final Widget appLimitsCard;

  const _ContentLayout({
    required this.isWide,
    required this.isMedium,
    required this.notificationCard,
    required this.overallCard,
    required this.appLimitsCard,
  });

  static const _gap16 = SizedBox(height: 16);
  static const _gap20w = SizedBox(width: 20);
  static const _gap16w = SizedBox(width: 16);

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: appLimitsCard),
          _gap20w,
          SizedBox(
            width: 320,
            child: Column(
              children: [
                notificationCard,
                _gap16,
                overallCard,
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        if (isMedium)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: notificationCard),
              _gap16w,
              Expanded(child: overallCard),
            ],
          )
        else ...[
          notificationCard,
          _gap16,
          overallCard,
        ],
        _gap16,
        appLimitsCard,
      ],
    );
  }
}

// ═══════════════════ Error Card ═══════════════════

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  static final _radius = BorderRadius.circular(12);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: _radius,
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FluentIcons.error_badge, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onRetry,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FluentIcons.refresh, size: 14),
                const SizedBox(width: 8),
                Text(l10n.retry),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════ Header ═══════════════════

class _Header extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onRefresh;

  const _Header({required this.onReset, required this.onRefresh});

  static final _iconRadius = BorderRadius.circular(8);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.alertsLimitsTitle,
                style: theme.typography.title
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.alertsLimitsSubtitle,
                style: theme.typography.caption?.copyWith(
                  color:
                      theme.typography.caption?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Tooltip(
          message: l10n.refresh,
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.1),
                borderRadius: _iconRadius,
              ),
              child:
                  Icon(FluentIcons.refresh, size: 16, color: theme.accentColor),
            ),
            onPressed: onRefresh,
          ),
        ),
        const SizedBox(width: 8),
        Button(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          onPressed: () => _showResetDialog(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FluentIcons.reset, size: 14),
              const SizedBox(width: 8),
              Text(l10n.resetAll),
            ],
          ),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (context) => ContentDialog(
        title: Row(
          children: [
            Icon(FluentIcons.warning, color: Colors.orange, size: 24),
            const SizedBox(width: 12),
            Text(l10n.resetSettingsTitle),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(l10n.resetSettingsContent),
        ),
        actions: [
          Button(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
              onReset();
            },
            child: Text(l10n.resetAll),
          ),
        ],
      ),
    );
  }
}
