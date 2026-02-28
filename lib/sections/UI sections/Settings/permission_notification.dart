import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/utils/app_restart.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

final _kBorderRadius6 = BorderRadius.circular(6);

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Info Banner
// ─────────────────────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String? subtitle;
  final double iconSize;
  final EdgeInsets margin;
  final Widget? trailing;

  const _InfoBanner({
    required this.color,
    required this.icon,
    this.title = '',
    this.subtitle,
    this.iconSize = 16,
    this.margin = const EdgeInsets.only(bottom: 12),
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: _kBorderRadius6,
      ),
      child: Row(
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: subtitle != null
                ? Column(
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
                        subtitle!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[100],
                        ),
                      ),
                    ],
                  )
                : Text(
                    title,
                    style: const TextStyle(fontSize: 11),
                  ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Input Monitoring Permission Banner
// ─────────────────────────────────────────────────────────────────────────────

class InputMonitoringPermissionBanner extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const InputMonitoringPermissionBanner({
    super.key,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _InfoBanner(
      color: Colors.orange,
      icon: FluentIcons.warning,
      title: l10n.inputMonitoringPermissionTitle,
      subtitle: l10n.inputMonitoringPermissionDescription,
      trailing: FilledButton(
        onPressed: onOpenSettings,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
        child: Text(l10n.openSettings, style: const TextStyle(fontSize: 11)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Restart Required Dialog
// ─────────────────────────────────────────────────────────────────────────────

class RestartRequiredDialog extends StatelessWidget {
  const RestartRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ContentDialog(
      title: Text(l10n.restartRequiredTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.restartRequiredDescription),
          const SizedBox(height: 12),
          _InfoBanner(
            color: Colors.blue,
            icon: FluentIcons.info,
            iconSize: 14,
            title: l10n.restartNote,
            margin: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        Button(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.restartLater),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.restartNow),
        ),
      ],
    );
  }

  static Future<void> show(BuildContext context) async {
    final shouldRestart = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const RestartRequiredDialog(),
    );

    if (shouldRestart != true || !context.mounted) return;

    try {
      await AppRestart.restart();
    } catch (e) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;

      await showDialog<void>(
        context: context,
        builder: (ctx) => ContentDialog(
          title: Text(l10n.restartFailedTitle),
          content: Text(l10n.restartFailedMessage),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
    }
  }
}
