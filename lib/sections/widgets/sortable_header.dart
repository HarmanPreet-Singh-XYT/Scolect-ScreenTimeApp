import 'package:fluent_ui/fluent_ui.dart';

/// Ascending/descending sort state for a single active column.
enum SortDirection { ascending, descending }

/// A clickable table-header cell that shows a sort arrow when active.
///
/// Reused by the sortable tables in Applications, Alerts & Limits, Reports,
/// and Focus Mode so header click-to-sort behaves and looks the same
/// everywhere.
class SortableHeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final TextAlign align;
  final TextStyle? style;
  final bool isActive;
  final SortDirection direction;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const SortableHeaderCell({
    super.key,
    required this.label,
    this.flex = 1,
    this.align = TextAlign.start,
    this.style,
    this.isActive = false,
    this.direction = SortDirection.ascending,
    this.onTap,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final activeColor = theme.accentColor;
    final effectiveStyle = isActive
        ? style?.copyWith(color: activeColor, fontWeight: FontWeight.w700)
        : style;

    final mainAxisAlignment = switch (align) {
      TextAlign.center => MainAxisAlignment.center,
      TextAlign.right || TextAlign.end => MainAxisAlignment.end,
      _ => MainAxisAlignment.start,
    };

    final content = Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              textAlign: align,
              style: effectiveStyle,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 4),
            Icon(
              direction == SortDirection.ascending
                  ? FluentIcons.sort_up
                  : FluentIcons.sort_down,
              size: 10,
              color: activeColor,
            ),
          ],
        ],
      ),
    );

    return Expanded(
      flex: flex,
      child: onTap == null
          ? content
          : MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: content,
              ),
            ),
    );
  }
}
