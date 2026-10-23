import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/sections/widgets/Settings/reusables.dart';

// ============== WINDOW TITLES ==============
//
// Desktop-only opt-in for recording sampled window titles per app.

class WindowTitlesSection extends StatefulWidget {
  const WindowTitlesSection({super.key});

  @override
  State<WindowTitlesSection> createState() => _WindowTitlesSectionState();
}

class _WindowTitlesSectionState extends State<WindowTitlesSection> {
  static const String settingKey = 'trackWindowTitles';
  bool _enabled = SettingsManager().getSetting(settingKey) == true;
  bool _clearing = false;

  void _setEnabled(bool value) {
    SettingsManager().updateSetting(settingKey, value);
    setState(() => _enabled = value);
  }

  Future<void> _clear() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _clearing = true);
    final cleared = await AppDataStore().clearWindowTitles();
    if (!mounted) return;
    setState(() => _clearing = false);
    await displayInfoBar(context, builder: (context, close) {
      return InfoBar(
        title: Text(l10n.wtCleared(cleared)),
        severity: InfoBarSeverity.success,
        onClose: close,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SettingsCard(
      title: l10n.wtSectionTitle,
      icon: FluentIcons.app_icon_default,
      children: [
        SettingRow(
          title: l10n.wtToggleTitle,
          description: l10n.wtToggleDescription,
          control: ToggleSwitch(checked: _enabled, onChanged: _setEnabled),
        ),
        SettingRow(
          title: l10n.wtClearTitle,
          description: l10n.wtClearDescription,
          showDivider: false,
          control: Button(
            onPressed: _clearing ? null : _clear,
            child: _clearing
                ? const SizedBox(width: 16, height: 16, child: ProgressRing(strokeWidth: 2))
                : Text(l10n.wtClearAction),
          ),
        ),
      ],
    );
  }
}
