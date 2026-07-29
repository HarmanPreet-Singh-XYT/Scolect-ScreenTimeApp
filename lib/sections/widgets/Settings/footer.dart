import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kAnimDuration = Duration(milliseconds: 150);
final _kBorderRadius6 = BorderRadius.circular(6);

// ============== FOOTER SECTION ==============

class FooterSection extends StatelessWidget {
  final VoidCallback onContact;
  final VoidCallback onReport;
  final VoidCallback onFeedback;
  final VoidCallback onGithub;

  const FooterSection({
    super.key,
    required this.onContact,
    required this.onReport,
    required this.onFeedback,
    required this.onGithub,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    final icons = [
      FluentIcons.chat,
      FluentIcons.bug,
      FluentIcons.feedback,
      FluentIcons.open_source,
    ];
    final labels = [
      l10n.contactButton,
      l10n.reportBugButton,
      l10n.submitFeedbackButton,
      l10n.githubButton,
    ];
    final callbacks = [onContact, onReport, onFeedback, onGithub];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < icons.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            _FooterButton(
              icon: icons[i],
              label: labels[i],
              onPressed: callbacks[i],
              isPrimary: i == icons.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer Button
// ─────────────────────────────────────────────────────────────────────────────

class _FooterButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _FooterButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<_FooterButton> createState() => _FooterButtonState();
}

class _FooterButtonState extends State<_FooterButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final accent = theme.accentColor;
    final inactiveBg = theme.inactiveBackgroundColor;
    final isPrimary = widget.isPrimary;

    final Color bgColor;
    final Color borderColor;
    final Color? contentColor;

    if (isPrimary) {
      bgColor = accent.withValues(alpha: _isHovered ? 0.15 : 0.08);
      borderColor = accent.withValues(alpha: _isHovered ? 0.5 : 0.2);
      contentColor = accent;
    } else {
      bgColor = inactiveBg.withValues(alpha: _isHovered ? 0.6 : 0.3);
      borderColor = _isHovered ? inactiveBg : Colors.transparent;
      contentColor = _isHovered ? null : Colors.grey[100];
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: _kAnimDuration,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: _kBorderRadius6,
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: contentColor),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: contentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
