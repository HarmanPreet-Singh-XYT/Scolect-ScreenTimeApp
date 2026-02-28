import 'dart:io' show Platform;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/main.dart';

import '../../controller/notification_controller.dart';
import '../../controller/settings_data_controller.dart';

// ─── Shared constants & helpers ───────────────────────────────────

const _kWarningColor = Color(0xFFFF9800);
const _kAnimDuration = Duration(milliseconds: 300);
const _kAnimCurve = Curves.easeOutCubic;

const _kSettingsKey = 'focusModeSettings.notificationBannerDismissed';
const _kNotifEnabledKey = 'notifications.enabled';
const _kFocusModeKey = 'notifications.focusMode';

const _kNavParams = {
  'highlightSection': 'notifications',
  'reason': 'enable_notifications',
};

/// Describes why notifications are unavailable.
enum _NotifIssue { system, appDisabled, focusModeDisabled }

// ─── Mixin: shared banner logic ───────────────────────────────────

mixin _NotificationBannerMixin<T extends StatefulWidget> on State<T> {
  final NotificationController notifController = NotificationController();
  final SettingsManager settingsManager = SettingsManager();

  bool isDismissed = false;
  bool isCheckingPermission = false;

  void loadDismissedState() {
    isDismissed = settingsManager.getSetting(_kSettingsKey) ?? false;
  }

  Future<void> checkPermission() async {
    if (!Platform.isMacOS) return;

    setState(() => isCheckingPermission = true);

    await notifController.refreshPermissionStatus();

    final allEnabled = notifController.canSendNotifications &&
        (settingsManager.getSetting(_kNotifEnabledKey) ?? true) &&
        (settingsManager.getSetting(_kFocusModeKey) ?? true);

    if (!mounted) return;
    setState(() {
      isCheckingPermission = false;
      if (allEnabled) isDismissed = true;
    });
  }

  void dismissBanner({bool permanent = false}) {
    if (permanent) {
      settingsManager.updateSetting(_kSettingsKey, true);
    }
    setState(() => isDismissed = true);
  }

  Future<void> navigateToSettings() async {
    context.read<NavigationState>().changeIndex(5, params: _kNavParams);
    if (mounted) await checkPermission();
  }

  /// Returns the current issue, or `null` if notifications are fully enabled.
  _NotifIssue? get currentIssue {
    if (!notifController.canSendNotifications) return _NotifIssue.system;
    if (!(settingsManager.getSetting(_kNotifEnabledKey) ?? true)) {
      return _NotifIssue.appDisabled;
    }
    if (!(settingsManager.getSetting(_kFocusModeKey) ?? true)) {
      return _NotifIssue.focusModeDisabled;
    }
    return null;
  }

  /// `true` when the banner should be hidden.
  bool get shouldHide =>
      !Platform.isMacOS ||
      isDismissed ||
      isCheckingPermission ||
      currentIssue == null;
}

// ─── Full-size banner ─────────────────────────────────────────────

class NotificationPermissionBanner extends StatefulWidget {
  const NotificationPermissionBanner({super.key});

  @override
  State<NotificationPermissionBanner> createState() =>
      _NotificationPermissionBannerState();
}

class _NotificationPermissionBannerState
    extends State<NotificationPermissionBanner> with _NotificationBannerMixin {
  @override
  void initState() {
    super.initState();
    loadDismissedState();
    checkPermission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    if (shouldHide) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final issue = currentIssue!;

    final (String message, String actionText, bool isSystem) = switch (issue) {
      _NotifIssue.system => (
          l10n.systemNotificationsDisabled,
          l10n.openSystemSettings,
          true,
        ),
      _NotifIssue.appDisabled => (
          l10n.appNotificationsDisabled,
          l10n.goToSettings,
          false,
        ),
      _NotifIssue.focusModeDisabled => (
          l10n.focusModeNotificationsDisabled,
          l10n.goToSettings,
          false,
        ),
    };

    return _FullBannerBody(
      message: message,
      actionText: actionText,
      isSystemSettings: isSystem,
      title: l10n.notificationsDisabled,
      dontShowAgainLabel: l10n.dontShowAgain,
      onAction: navigateToSettings,
      onDismiss: () => dismissBanner(),
      onDismissPermanent: () => dismissBanner(permanent: true),
    );
  }
}

/// Stateless inner body — extracted so [build] stays lean.
class _FullBannerBody extends StatelessWidget {
  const _FullBannerBody({
    required this.message,
    required this.actionText,
    required this.isSystemSettings,
    required this.title,
    required this.dontShowAgainLabel,
    required this.onAction,
    required this.onDismiss,
    required this.onDismissPermanent,
  });

  final String message;
  final String actionText;
  final bool isSystemSettings;
  final String title;
  final String dontShowAgainLabel;
  final VoidCallback onAction;
  final VoidCallback onDismiss;
  final VoidCallback onDismissPermanent;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return AnimatedContainer(
      duration: _kAnimDuration,
      curve: _kAnimCurve,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _kWarningColor.withValues(alpha: 0.1),
            _kWarningColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _kWarningColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Warning icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _kWarningColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(FluentIcons.warning,
                color: _kWarningColor, size: 20),
          ),
          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.typography.bodyStrong?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _kWarningColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: theme.typography.caption?.copyWith(
                    color:
                        theme.typography.caption?.color?.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _WarningFilledButton(
                icon: isSystemSettings
                    ? FluentIcons.system
                    : FluentIcons.settings,
                label: actionText,
                onPressed: onAction,
              ),
              const SizedBox(width: 8),
              Button(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                onPressed: onDismissPermanent,
                child: Text(dontShowAgainLabel),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(FluentIcons.chrome_close, size: 12),
                onPressed: onDismiss,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Compact banner ───────────────────────────────────────────────

class CompactNotificationBanner extends StatefulWidget {
  const CompactNotificationBanner({super.key});

  @override
  State<CompactNotificationBanner> createState() =>
      _CompactNotificationBannerState();
}

class _CompactNotificationBannerState extends State<CompactNotificationBanner>
    with _NotificationBannerMixin {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    loadDismissedState();
    checkPermission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkPermission();
  }

  Future<void> _showSystemSettingsInfo() async {
    await showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: const Row(
          children: [
            Icon(FluentIcons.system, size: 20),
            SizedBox(width: 12),
            Text('System Settings Required'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications are disabled at the system level. To enable:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Text('1. Open System Settings (System Preferences)'),
            SizedBox(height: 8),
            Text('2. Go to Notifications'),
            SizedBox(height: 8),
            Text('3. Find and select TimeMark'),
            SizedBox(height: 8),
            Text('4. Enable "Allow notifications"'),
            SizedBox(height: 16),
            Text(
              'Then return to this app and notifications will work.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          FilledButton(
            child: const Text('Got it'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (shouldHide) return const SizedBox.shrink();

    final issue = currentIssue!;
    final theme = FluentTheme.of(context);

    final (String shortMsg, String longMsg, String actionText, bool isSystem) =
        switch (issue) {
      _NotifIssue.system => (
          'Notifications disabled',
          'Enable notifications in System Settings to receive focus session alerts.',
          'Open System Settings',
          true,
        ),
      _NotifIssue.appDisabled => (
          'Notifications disabled',
          'Enable notifications in app settings to receive focus session alerts.',
          'Go to Settings',
          false,
        ),
      _NotifIssue.focusModeDisabled => (
          'Focus notifications disabled',
          'Enable focus mode notifications in settings to receive session alerts.',
          'Go to Settings',
          false,
        ),
    };

    return AnimatedContainer(
      duration: _kAnimDuration,
      curve: _kAnimCurve,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _kWarningColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _kWarningColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(FluentIcons.warning,
                      color: _kWarningColor, size: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      shortMsg,
                      style: theme.typography.body?.copyWith(
                        color: _kWarningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isExpanded
                          ? FluentIcons.chevron_up
                          : FluentIcons.chevron_down,
                      size: 12,
                    ),
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  ),
                  IconButton(
                    icon: const Icon(FluentIcons.chrome_close, size: 10),
                    onPressed: () => dismissBanner(),
                  ),
                ],
              ),
            ),
          ),

          // Expandable detail
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(longMsg, style: theme.typography.caption),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: isSystem
                              ? _showSystemSettingsInfo
                              : navigateToSettings,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isSystem
                                    ? FluentIcons.system
                                    : FluentIcons.settings,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(actionText),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Button(
                        onPressed: () => dismissBanner(permanent: true),
                        child: const Text("Don't show again"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────

class _WarningFilledButton extends StatelessWidget {
  const _WarningFilledButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: ButtonStyle(
        backgroundColor:
            WidgetStateProperty.all(_kWarningColor.withValues(alpha: 0.15)),
        foregroundColor: WidgetStateProperty.all(_kWarningColor),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
