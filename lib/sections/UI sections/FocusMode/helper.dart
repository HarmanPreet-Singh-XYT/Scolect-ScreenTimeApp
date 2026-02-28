import 'package:fluent_ui/fluent_ui.dart';

/// Mixin that encapsulates the common hover/press state logic.
mixin _HoverStateMixin<T extends StatefulWidget> on State<T> {
  bool _isHovered = false;

  MouseRegion buildHoverRegion({required Widget child}) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: child,
    );
  }
}

// ─── Control Button ───────────────────────────────────────────────

class ControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const ControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  State<ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<ControlButton> with _HoverStateMixin {
  bool _isPressed = false;

  void _setPressed(bool value) => setState(() => _isPressed = value);

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final accent = theme.accentColor;

    return Tooltip(
      message: widget.tooltip,
      child: buildHoverRegion(
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            transform: Matrix4.identity()..scale(_isPressed ? 0.92 : 1.0),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: _isHovered
                  ? accent.withValues(alpha: 0.1)
                  : theme.micaBackgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: _isHovered
                    ? accent.withValues(alpha: 0.3)
                    : theme.inactiveBackgroundColor,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: _isHovered ? accent : null,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Play / Pause Button ──────────────────────────────────────────

class PlayPauseButton extends StatefulWidget {
  final bool isRunning;
  final Color color;
  final VoidCallback onPressed;

  const PlayPauseButton({
    super.key,
    required this.isRunning,
    required this.color,
    required this.onPressed,
  });

  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
    with _HoverStateMixin {
  static const _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final color = widget.color;

    return buildHoverRegion(
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: _duration,
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: _isHovered ? 0.5 : 0.3),
                blurRadius: _isHovered ? 24 : 16,
                offset: const Offset(0, 6),
                spreadRadius: _isHovered ? 2 : 0,
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: _duration,
            child: Icon(
              widget.isRunning ? FluentIcons.pause : FluentIcons.play_solid,
              key: ValueKey(widget.isRunning),
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Session Chip ─────────────────────────────────────────────────

class SessionChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback? onTap;

  const SessionChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.color,
    this.onTap,
  });

  @override
  State<SessionChip> createState() => _SessionChipState();
}

class _SessionChipState extends State<SessionChip> with _HoverStateMixin {
  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;
    final color = widget.color;

    final Color bgColor;
    final Color borderColor;
    final Color textColor;

    if (active) {
      bgColor = color.withValues(alpha: 0.15);
      borderColor = color;
      textColor = color;
    } else if (_isHovered) {
      bgColor = color.withValues(alpha: 0.05);
      borderColor = color.withValues(alpha: 0.5);
      textColor = color.withValues(alpha: 0.8);
    } else {
      bgColor = Colors.transparent;
      borderColor = FluentTheme.of(context).inactiveBackgroundColor;
      textColor = FluentTheme.of(context)
              .typography
              .body
              ?.color
              ?.withValues(alpha: 0.6) ??
          Colors.grey;
    }

    return buildHoverRegion(
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: textColor,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
