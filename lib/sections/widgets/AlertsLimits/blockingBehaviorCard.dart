import 'package:flutter/foundation.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/sections/controller/services/app_blocking_service.dart';
import './reusable.dart' as rub;

/// Desktop-only card (hidden on web) that lets the user choose how Scolect
/// responds when a limited app gains focus after its limit is reached.
class BlockingBehaviorCard extends StatelessWidget {
  final BlockingBehavior value;
  final ValueChanged<BlockingBehavior> onChanged;

  const BlockingBehaviorCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();

    final theme = FluentTheme.of(context);

    return rub.Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(theme: theme),
          const SizedBox(height: 16),
          _BehaviorTile(
            title: 'Notification only',
            subtitle: 'Alert you when a limit is reached, no other action.',
            icon: FluentIcons.ringer,
            selected: value == BlockingBehavior.none,
            onTap: () => onChanged(BlockingBehavior.none),
            theme: theme,
          ),
          const SizedBox(height: 8),
          _BehaviorTile(
            title: 'Soft block',
            subtitle:
                'Bring Scolect to the front with options to minimize, quit, snooze, or unblock the app.',
            icon: FluentIcons.blocked2,
            selected: value == BlockingBehavior.soft,
            onTap: () => onChanged(BlockingBehavior.soft),
            theme: theme,
          ),
          const SizedBox(height: 8),
          _BehaviorTile(
            title: 'Hard block',
            subtitle:
                'Same as soft block, and also immediately hides the app from your screen.',
            icon: FluentIcons.blocked,
            selected: value == BlockingBehavior.hard,
            onTap: () => onChanged(BlockingBehavior.hard),
            theme: theme,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Note: Blocking is a nudge, not a lock. You can still reopen the app from the Dock or taskbar.',
              style: theme.typography.caption?.copyWith(
                fontSize: 11,
                color: theme.typography.caption?.color?.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final FluentThemeData theme;
  const _Header({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(FluentIcons.blocked2, size: 18, color: theme.accentColor),
        ),
        const SizedBox(width: 12),
        const Text(
          'Blocking Behavior',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _BehaviorTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final FluentThemeData theme;

  const _BehaviorTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_BehaviorTile> createState() => _BehaviorTileState();
}

class _BehaviorTileState extends State<_BehaviorTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? widget.theme.accentColor.withValues(alpha: 0.1)
        : _hovered
            ? widget.theme.accentColor.withValues(alpha: 0.05)
            : Colors.transparent;

    final borderColor = widget.selected
        ? widget.theme.accentColor.withValues(alpha: 0.5)
        : widget.theme.inactiveBackgroundColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: widget.selected
                    ? widget.theme.accentColor
                    : widget.theme.accentColor.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: widget.selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.theme.typography.caption?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.selected)
                Icon(FluentIcons.check_mark,
                    size: 14, color: widget.theme.accentColor),
            ],
          ),
        ),
      ),
    );
  }
}
