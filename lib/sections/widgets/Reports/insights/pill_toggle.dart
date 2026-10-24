import 'package:fluent_ui/fluent_ui.dart';

/// One option of a [PillToggle].
class PillOption {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const PillOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
}

/// Compact segmented control drawn from the Fluent theme, so it follows the
/// user's light/dark mode and accent color.
class PillToggle extends StatelessWidget {
  final List<PillOption> options;
  const PillToggle({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = theme.typography.caption?.color?.withValues(alpha: 0.7);

    Widget pill(PillOption o) => MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: o.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: o.selected
                    ? (isDark ? theme.micaBackgroundColor : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: o.selected
                    ? Border.all(color: theme.resources.cardStrokeColorDefault)
                    : null,
                boxShadow: o.selected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(o.icon, size: 13, color: o.selected ? theme.accentColor.normal : muted),
                  const SizedBox(width: 6),
                  Text(
                    o.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: o.selected ? FontWeight.w600 : FontWeight.w500,
                      color: o.selected ? theme.typography.body?.color : muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.resources.subtleFillColorSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            pill(options[i]),
          ],
        ],
      ),
    );
  }
}
