import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/settings.dart';
import 'package:screentime/sections/UI%20sections/Settings/reusables.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kAnimDuration = Duration(milliseconds: 150);
final _kBorderRadius6 = BorderRadius.circular(6);

// ============== DATA SECTION ==============

class DataSection extends StatelessWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.read<SettingsProvider>();

    return SettingsCard(
      title: l10n.dataSection,
      icon: FluentIcons.database,
      iconColor: Colors.red,
      children: [
        SettingRow(
          title: l10n.clearDataTitle,
          description: l10n.clearDataDescription,
          control: _DangerButton(
            label: l10n.clearDataButtonLabel,
            icon: FluentIcons.delete,
            onPressed: () => _showConfirmDialog(
              context: context,
              iconColor: Colors.red,
              title: l10n.clearDataDialogTitle,
              content: l10n.clearDataDialogContent,
              cancelLabel: l10n.cancelButton,
              confirmLabel: l10n.clearDataButtonLabel,
              onConfirm: settings.clearData,
            ),
          ),
        ),
        SettingRow(
          title: l10n.resetSettingsTitle2,
          description: l10n.resetSettingsDescription,
          showDivider: false,
          control: _DangerButton(
            label: l10n.resetButtonLabel,
            icon: FluentIcons.refresh,
            isWarning: true,
            onPressed: () => _showConfirmDialog(
              context: context,
              iconColor: Colors.orange,
              title: l10n.resetSettingsDialogTitle,
              content: l10n.resetSettingsDialogContent,
              cancelLabel: l10n.cancelButton,
              confirmLabel: l10n.resetButtonLabel,
              onConfirm: settings.resetSettings,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showConfirmDialog({
    required BuildContext context,
    required Color iconColor,
    required String title,
    required String content,
    required String cancelLabel,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Row(
          children: [
            Icon(FluentIcons.warning, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          Button(
            child: Text(cancelLabel),
            onPressed: () => Navigator.pop(ctx),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(iconColor),
            ),
            child: Text(confirmLabel),
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Danger Button
// ─────────────────────────────────────────────────────────────────────────────

class _DangerButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isWarning;
  final VoidCallback onPressed;

  const _DangerButton({
    required this.label,
    required this.icon,
    this.isWarning = false,
    required this.onPressed,
  });

  @override
  State<_DangerButton> createState() => _DangerButtonState();
}

class _DangerButtonState extends State<_DangerButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isWarning ? Colors.orange : Colors.red;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: _kAnimDuration,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                _isHovered ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: _kBorderRadius6,
            border: Border.all(
              color: _isHovered ? color : color.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 12, color: color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
