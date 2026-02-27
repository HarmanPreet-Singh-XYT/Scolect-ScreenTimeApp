import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import './reusable.dart' as rub;

// ──────────────── Type-safe alert key ────────────────

enum AlertType { popup, frequent, sound, system }

// ──────────────── Immutable settings model ────────────────

class NotificationSettings {
  final bool frequentAlerts;
  final bool systemAlerts;
  final bool soundAlerts;
  final bool popupAlerts;

  const NotificationSettings({
    this.frequentAlerts = false,
    this.systemAlerts = false,
    this.soundAlerts = false,
    this.popupAlerts = false,
  });

  bool operator [](AlertType type) => switch (type) {
        AlertType.popup => popupAlerts,
        AlertType.frequent => frequentAlerts,
        AlertType.sound => soundAlerts,
        AlertType.system => systemAlerts,
      };
}

// ──────────────── Tile descriptor ────────────────

class _TileConfig {
  final AlertType type;
  final IconData icon;
  final String Function(AppLocalizations) titleOf;
  final String Function(AppLocalizations) subtitleOf;

  const _TileConfig({
    required this.type,
    required this.icon,
    required this.titleOf,
    required this.subtitleOf,
  });
}

// Static config list — defined once, reused every build
final List<_TileConfig> _tileConfigs = [
  _TileConfig(
    type: AlertType.popup,
    icon: FluentIcons.comment,
    titleOf: (l) => l.popupAlerts,
    subtitleOf: (l) => l.showPopupNotifications,
  ),
  _TileConfig(
    type: AlertType.frequent,
    icon: FluentIcons.timer,
    titleOf: (l) => l.frequentAlerts,
    subtitleOf: (l) => l.moreFrequentReminders,
  ),
  _TileConfig(
    type: AlertType.sound,
    icon: FluentIcons.volume3,
    titleOf: (l) => l.soundAlerts,
    subtitleOf: (l) => l.playSoundWithAlerts,
  ),
  _TileConfig(
    type: AlertType.system,
    icon: FluentIcons.system,
    titleOf: (l) => l.systemAlerts,
    subtitleOf: (l) => l.systemTrayNotifications,
  ),
];

// ──────────────── Widget ────────────────

class NotificationSettingsCard extends StatelessWidget {
  final NotificationSettings settings;
  final void Function(AlertType type, bool value) onChanged;

  const NotificationSettingsCard({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return rub.Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Header(),
          const SizedBox(height: 20),
          for (var i = 0; i < _tileConfigs.length; i++)
            rub.SettingTile(
              icon: _tileConfigs[i].icon,
              title: _tileConfigs[i].titleOf(l10n),
              subtitle: _tileConfigs[i].subtitleOf(l10n),
              value: settings[_tileConfigs[i].type],
              onChanged: (v) => onChanged(_tileConfigs[i].type, v),
              showDivider: i < _tileConfigs.length - 1,
            ),
        ],
      ),
    );
  }
}

// ──────────────── Header ────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(FluentIcons.ringer, size: 18, color: theme.accentColor),
        ),
        const SizedBox(width: 12),
        Text(
          l10n.notificationsSettings,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
