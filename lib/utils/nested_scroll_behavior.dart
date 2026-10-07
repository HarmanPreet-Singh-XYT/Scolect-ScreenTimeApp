import 'package:fluent_ui/fluent_ui.dart';

/// Scroll behavior that lets nested scrollables hand leftover scroll to the
/// enclosing one.
///
/// Trackpad (precision touchpad) gestures are resolved through the gesture
/// arena, so the innermost scrollable under the pointer wins the whole gesture.
/// With clamping physics (Windows) an inner list that has hit its edge then
/// swallows the gesture and the page behind it appears stuck. Mouse wheels are
/// unaffected because they use the pointer-signal resolver.
///
/// Applied once at the app level, this covers every nested list/grid instead of
/// patching each screen.
class NestedScrollBehavior extends FluentScrollBehavior {
  const NestedScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    final axis = axisDirectionToAxis(details.direction);
    return NotificationListener<OverscrollNotification>(
      onNotification: (n) {
        // depth > 0: bubbled up from a deeper scrollable, already handled there.
        if (n.depth != 0 || n.metrics.axis != axis) return false;
        final outer = Scrollable.maybeOf(context, axis: axis)?.position;
        if (outer == null || !outer.hasPixels) return false;
        final target = (outer.pixels + n.overscroll)
            .clamp(outer.minScrollExtent, outer.maxScrollExtent);
        if (target != outer.pixels) outer.jumpTo(target);
        return false;
      },
      child: super.buildOverscrollIndicator(context, child, details),
    );
  }
}
