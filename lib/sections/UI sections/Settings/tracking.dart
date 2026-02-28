import 'dart:io' show Platform;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/application_controller.dart';
import 'package:screentime/sections/settings.dart';
import 'package:screentime/sections/UI%20sections/Settings/reusables.dart';
import 'package:screentime/sections/UI sections/Settings/permission_notification.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kExpandDuration = Duration(milliseconds: 200);
final _kBorderRadius6 = BorderRadius.circular(6);

// ============== TRACKING SECTION ==============

class TrackingSection extends StatefulWidget {
  const TrackingSection({super.key});

  @override
  State<TrackingSection> createState() => _TrackingSectionState();
}

class _TrackingSectionState extends State<TrackingSection>
    with WidgetsBindingObserver {
  bool _showAdvanced = false;
  bool _hasInputMonitoringPermission = true;
  bool _isCheckingPermission = true;

  static final _isMacOS = Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_isMacOS) {
      _checkInputMonitoringPermission();
    } else {
      _isCheckingPermission = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isMacOS) {
      _checkInputMonitoringPermission();
    }
  }

  // ── Permission Handling ───────────────────────────────────────────────────

  Future<void> _checkInputMonitoringPermission() async {
    setState(() => _isCheckingPermission = true);
    try {
      final hasPermission =
          await BackgroundAppTracker().checkInputMonitoringPermission();
      if (mounted) {
        setState(() {
          _hasInputMonitoringPermission = hasPermission;
          _isCheckingPermission = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking input monitoring permission: $e');
      if (mounted) setState(() => _isCheckingPermission = false);
    }
  }

  Future<void> _handleOpenInputMonitoringSettings() async {
    try {
      await BackgroundAppTracker().openInputMonitoringSettings();
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      await showDialog<void>(
        context: context,
        builder: (ctx) => ContentDialog(
          title: Text(l10n.permissionGrantedTitle),
          content: Text(l10n.permissionGrantedDescription),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                RestartRequiredDialog.show(ctx);
              },
              child: Text(l10n.continueButton),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error opening input monitoring settings: $e');
      if (mounted) _showErrorInfoBar(e.toString());
    }
  }

  void _showErrorInfoBar(String error) {
    displayInfoBar(context, builder: (ctx, close) {
      final l10n = AppLocalizations.of(ctx)!;
      return InfoBar(
        title: Text(l10n.error),
        content: Text(error),
        severity: InfoBarSeverity.error,
        onClose: close,
      );
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final theme = FluentTheme.of(context);

    final showPermissionBanner = _isMacOS &&
        !_isCheckingPermission &&
        !_hasInputMonitoringPermission &&
        settings.monitorKeyboard;

    return SettingsCard(
      title: l10n.activityTrackingSection,
      icon: FluentIcons.view,
      iconColor: Colors.teal,
      trailing: StatusBadge(
        isActive: settings.idleDetectionEnabled,
        activeText: l10n.active,
        inactiveText: l10n.disabled,
      ),
      children: [
        if (showPermissionBanner)
          InputMonitoringPermissionBanner(
            onOpenSettings: _handleOpenInputMonitoringSettings,
          ),
        SettingRow(
          title: l10n.idleDetectionTitle,
          description: l10n.idleDetectionDescription,
          control: ToggleSwitch(
            checked: settings.idleDetectionEnabled,
            onChanged: (v) => settings.updateSetting('idleDetectionEnabled', v),
          ),
        ),
        if (settings.idleDetectionEnabled)
          SettingRow(
            title: l10n.idleTimeoutTitle,
            description: l10n
                .idleTimeoutDescription(settings.getFormattedIdleTimeout(l10n)),
            control: TimeoutButton(
              value: settings.getFormattedIdleTimeout(l10n),
              onPressed: () => _showIdleTimeoutDialog(context, settings, l10n),
            ),
          ),
        _AdvancedToggle(
          isExpanded: _showAdvanced,
          onToggle: () => setState(() => _showAdvanced = !_showAdvanced),
          label: l10n.advanced_options,
          theme: theme,
        ),
        AnimatedCrossFade(
          firstChild: _AdvancedOptions(settings: settings, l10n: l10n),
          secondChild: const SizedBox.shrink(),
          crossFadeState: _showAdvanced
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: _kExpandDuration,
        ),
      ],
    );
  }

  Future<void> _showIdleTimeoutDialog(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
  ) async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => IdleTimeoutDialog(
        currentValue: settings.idleTimeout,
        presets: settings.idleTimeoutPresets,
        l10n: l10n,
      ),
    );
    if (result != null) {
      settings.updateSetting('idleTimeout', result);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Advanced Toggle Button
// ─────────────────────────────────────────────────────────────────────────────

class _AdvancedToggle extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final String label;
  final FluentThemeData theme;

  const _AdvancedToggle({
    required this.isExpanded,
    required this.onToggle,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onToggle,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.inactiveBackgroundColor.withValues(alpha: 0.2),
              borderRadius: _kBorderRadius6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FluentIcons.developer_tools, size: 14),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: _kExpandDuration,
                  child: const Icon(FluentIcons.chevron_down, size: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Advanced Options Panel
// ─────────────────────────────────────────────────────────────────────────────

class _AdvancedOptions extends StatelessWidget {
  final SettingsProvider settings;
  final AppLocalizations l10n;

  const _AdvancedOptions({
    required this.settings,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WarningBanner(
          message: l10n.advancedWarning,
          icon: FluentIcons.warning,
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _AdvancedToggleRow(
          title: l10n.monitorAudioTitle,
          description: l10n.monitorAudioDescription,
          settingKey: 'monitorAudio',
          checked: settings.monitorAudio,
        ),
        if (settings.monitorAudio)
          SettingRow(
            title: l10n.audioSensitivityTitle,
            description: l10n.audioSensitivityDescription(
                settings.audioThreshold.toStringAsFixed(4)),
            isSubSetting: true,
            control: SizedBox(
              width: 150,
              child: Slider(
                value: settings.audioThreshold,
                min: 0.0001,
                max: 0.1,
                divisions: 100,
                onChanged: (v) => settings.updateSetting('audioThreshold', v),
              ),
            ),
          ),
        _AdvancedToggleRow(
          title: l10n.monitorControllersTitle,
          description: l10n.monitorControllersDescription,
          settingKey: 'monitorControllers',
          checked: settings.monitorControllers,
        ),
        _AdvancedToggleRow(
          title: l10n.monitorHIDTitle,
          description: l10n.monitorHIDDescription,
          settingKey: 'monitorHIDDevices',
          checked: settings.monitorHIDDevices,
        ),
        _AdvancedToggleRow(
          title: l10n.monitorKeyboardTitle,
          description: l10n.monitorKeyboardDescription,
          settingKey: 'monitorKeyboard',
          checked: settings.monitorKeyboard,
          showDivider: false,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Advanced Toggle Row
// ─────────────────────────────────────────────────────────────────────────────

class _AdvancedToggleRow extends StatelessWidget {
  final String title;
  final String description;
  final String settingKey;
  final bool checked;
  final bool showDivider;

  const _AdvancedToggleRow({
    required this.title,
    required this.description,
    required this.settingKey,
    required this.checked,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsProvider>();

    return SettingRow(
      title: title,
      description: description,
      isSubSetting: true,
      showDivider: showDivider,
      control: ToggleSwitch(
        checked: checked,
        onChanged: (v) => settings.updateSetting(settingKey, v),
      ),
    );
  }
}
