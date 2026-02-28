import 'dart:io' show Platform;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:provider/provider.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/settings.dart';
import 'package:screentime/sections/UI%20sections/Settings/reusables.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kHighlightDuration = Duration(milliseconds: 5000);
const _kHighlightDelay = Duration(milliseconds: 500);
const _kPulseDelay = Duration(milliseconds: 2000);
final _kBorderRadius6 = BorderRadius.circular(6);
final _kBorderRadius8 = BorderRadius.circular(8);
const _kReminderOptions = [1, 5, 15, 30, 60];

// ============== NOTIFICATION SECTION ==============

class NotificationSection extends StatefulWidget {
  final bool isHighlighted;

  const NotificationSection({
    super.key,
    this.isHighlighted = false,
  });

  @override
  State<NotificationSection> createState() => _NotificationSectionState();
}

class _NotificationSectionState extends State<NotificationSection>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  NotificationPermissionStatus? _permissionStatus;
  bool _isCheckingPermission = false;
  bool _isRequestingPermission = false;
  bool _isHighlighted = false;

  late final AnimationController _highlightController;
  late final Animation<double> _highlightAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _highlightController = AnimationController(
      vsync: this,
      duration: _kHighlightDuration,
    )..addStatusListener(_onHighlightStatus);

    _highlightAnimation = CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeInOut,
    );

    if (Platform.isMacOS) _checkPermissionStatus();
    if (widget.isHighlighted) _startHighlight();
  }

  @override
  void didUpdateWidget(NotificationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && !oldWidget.isHighlighted) {
      _startHighlight();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _highlightController
      ..removeStatusListener(_onHighlightStatus)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && Platform.isMacOS) {
      _checkPermissionStatus();
    }
  }

  // ── Highlight ─────────────────────────────────────────────────────────────

  void _onHighlightStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      Future.delayed(_kHighlightDelay, () {
        if (mounted) setState(() => _isHighlighted = false);
      });
    }
  }

  void _startHighlight() {
    setState(() => _isHighlighted = true);
    _highlightController.forward(from: 0);
    Future.delayed(_kPulseDelay, () {
      if (mounted && _isHighlighted) {
        _highlightController.forward(from: 0);
      }
    });
  }

  // ── Permissions ───────────────────────────────────────────────────────────

  Future<void> _checkPermissionStatus() async {
    setState(() => _isCheckingPermission = true);
    try {
      final status = await localNotifier.checkPermission();
      if (mounted) {
        setState(() {
          _permissionStatus = status;
          _isCheckingPermission = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      if (mounted) setState(() => _isCheckingPermission = false);
    }
  }

  Future<void> _requestPermission(SettingsProvider settings) async {
    setState(() => _isRequestingPermission = true);
    try {
      final granted = await localNotifier.requestPermission();
      if (!mounted) return;

      if (granted) {
        await _enableAllNotifications(settings);
        await _checkPermissionStatus();
      } else {
        await _showPermissionDeniedDialog();
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      if (mounted) _showErrorInfoBar(e.toString());
    } finally {
      if (mounted) setState(() => _isRequestingPermission = false);
    }
  }

  Future<void> _enableAllNotifications(SettingsProvider settings) async {
    const keys = [
      'notificationsEnabled',
      'notificationsFocusMode',
      'notificationsScreenTime',
      'notificationsAppScreenTime',
    ];
    for (final key in keys) {
      await settings.updateSetting(key, true);
    }
  }

  Future<void> _openSystemSettings() async {
    try {
      final opened = await localNotifier.openNotificationSettings();
      if (!opened && mounted) {
        _showErrorInfoBar('Failed to open System Settings');
      }
    } catch (e) {
      debugPrint('Error opening system settings: $e');
      if (mounted) _showErrorInfoBar(e.toString());
    }
  }

  Future<void> _handleNotificationToggle(
      bool value, SettingsProvider settings) async {
    if (!Platform.isMacOS) {
      settings.updateSetting('notificationsEnabled', value);
      return;
    }

    await _checkPermissionStatus();

    if (!value) {
      settings.updateSetting('notificationsEnabled', false);
      return;
    }

    if (_permissionStatus?.isGranted ?? false) {
      settings.updateSetting('notificationsEnabled', true);
    } else if (_permissionStatus?.isDenied ?? false) {
      await _showPermissionDeniedDialog();
    } else {
      await _requestPermission(settings);
    }
  }

  // ── Dialogs & InfoBars ────────────────────────────────────────────────────

  void _showErrorInfoBar(String error) {
    displayInfoBar(context, builder: (ctx, close) {
      final l10n = AppLocalizations.of(ctx)!;
      return InfoBar(
        title: Text(l10n.permission_error),
        content: Text(error),
        severity: InfoBarSeverity.error,
        onClose: close,
      );
    });
  }

  Future<void> _showPermissionDeniedDialog() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Text(l10n.notification_permission_denied),
        content: Text(l10n.notification_permission_denied_message),
        actions: [
          Button(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _openSystemSettings();
            },
            child: Text(l10n.open_settings),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.accentColor;

    final permissionGranted = _permissionStatus?.isGranted ?? false;
    final canEnable = !Platform.isMacOS || permissionGranted;
    final notificationsEnabled = settings.notificationsEnabled && canEnable;

    return AnimatedBuilder(
      animation: _highlightAnimation,
      builder: (context, child) {
        final highlightColor = accent.withValues(
          alpha: _isHighlighted
              ? (isDark ? 0.15 : 0.08) *
                  (0.3 + 0.7 * (1 - _highlightAnimation.value).abs())
              : 0.0,
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: highlightColor,
            borderRadius: _kBorderRadius8,
            border: _isHighlighted
                ? Border.all(color: accent.withValues(alpha: 0.4), width: 2)
                : null,
            boxShadow: _isHighlighted
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: SettingsCard(
        title: l10n.notificationsSection,
        icon: FluentIcons.ringer,
        iconColor: Colors.purple,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Platform.isMacOS) ...[
              _buildPermissionBadge(l10n),
              const SizedBox(width: 8),
            ],
            StatusBadge(
              isActive: notificationsEnabled,
              activeText: l10n.on,
              inactiveText: l10n.off,
            ),
          ],
        ),
        children: [
          _buildPermissionWarning(theme, l10n),
          SettingRow(
            title: l10n.notificationsTitle,
            description: Platform.isMacOS && !permissionGranted
                ? l10n.enable_notification_permission_hint
                : l10n.notificationsAllDescription,
            control: ToggleSwitch(
              checked: notificationsEnabled,
              onChanged: (v) => _handleNotificationToggle(v, settings),
            ),
          ),
          if (notificationsEnabled) ...[
            _NotificationToggleRow(
              title: l10n.focusModeNotificationsTitle,
              description: l10n.focusModeNotificationsDescription,
              settingKey: 'notificationsFocusMode',
              checked: settings.notificationsFocusMode,
            ),
            _NotificationToggleRow(
              title: l10n.screenTimeNotificationsTitle,
              description: l10n.screenTimeNotificationsDescription,
              settingKey: 'notificationsScreenTime',
              checked: settings.notificationsScreenTime,
            ),
            _NotificationToggleRow(
              title: l10n.appScreenTimeNotificationsTitle,
              description: l10n.appScreenTimeNotificationsDescription,
              settingKey: 'notificationsAppScreenTime',
              checked: settings.notificationsAppScreenTime,
            ),
            SettingRow(
              title: l10n.frequentAlertsTitle,
              description: l10n.frequentAlertsDescription,
              isSubSetting: true,
              showDivider: false,
              control: ComboBox<String>(
                value: settings.reminderFrequency.toString(),
                items: [
                  for (final val in _kReminderOptions)
                    ComboBoxItem<String>(
                      value: val.toString(),
                      child: Text(l10n.minutes_format(val)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    settings.updateSetting(
                        'reminderFrequency', int.parse(value));
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Permission Widgets ────────────────────────────────────────────────────

  Widget _buildPermissionBadge(AppLocalizations l10n) {
    if (!Platform.isMacOS) return const SizedBox.shrink();

    if (_isCheckingPermission) {
      return const SizedBox(
        width: 12,
        height: 12,
        child: ProgressRing(strokeWidth: 2),
      );
    }

    if (_permissionStatus == null) return const SizedBox.shrink();

    final (color, text) = _permissionStatus!.isGranted
        ? (Colors.green, l10n.permission_allowed)
        : _permissionStatus!.isDenied
            ? (Colors.orange, l10n.permission_denied)
            : (Colors.grey as Color, l10n.permission_not_set);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionWarning(FluentThemeData theme, AppLocalizations l10n) {
    if (!Platform.isMacOS ||
        _isCheckingPermission ||
        _permissionStatus == null) {
      return const SizedBox.shrink();
    }

    if (_permissionStatus!.isDenied) {
      return _PermissionBanner(
        color: Colors.orange,
        icon: FluentIcons.warning,
        title: l10n.notification_permission_denied,
        subtitle: l10n.notification_permission_denied_hint,
        action: FilledButton(
          onPressed: _openSystemSettings,
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
          child: Text(l10n.open_settings, style: const TextStyle(fontSize: 11)),
        ),
      );
    }

    if (_permissionStatus!.isNotDetermined) {
      return _PermissionBanner(
        color: theme.accentColor,
        icon: FluentIcons.info,
        title: l10n.notification_permission_required,
        subtitle: l10n.notification_permission_required_message,
        action: FilledButton(
          onPressed: _isRequestingPermission
              ? null
              : () => _requestPermission(context.read<SettingsProvider>()),
          child: _isRequestingPermission
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: ProgressRing(strokeWidth: 2),
                )
              : Text(l10n.allow_notifications,
                  style: const TextStyle(fontSize: 11)),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Permission Banner (extracted from duplicated pattern)
// ─────────────────────────────────────────────────────────────────────────────

class _PermissionBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget action;

  const _PermissionBanner({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: _kBorderRadius6,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey[100]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          action,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification Toggle Row (extracted from repeated pattern)
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationToggleRow extends StatelessWidget {
  final String title;
  final String description;
  final String settingKey;
  final bool checked;

  const _NotificationToggleRow({
    required this.title,
    required this.description,
    required this.settingKey,
    required this.checked,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsProvider>();

    return SettingRow(
      title: title,
      description: description,
      isSubSetting: true,
      control: ToggleSwitch(
        checked: checked,
        onChanged: (value) => settings.updateSetting(settingKey, value),
      ),
    );
  }
}
