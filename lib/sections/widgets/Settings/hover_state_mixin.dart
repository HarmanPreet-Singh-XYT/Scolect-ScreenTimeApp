import 'package:flutter/material.dart';

/// Shared mixin that eliminates the repeated [_isHovered] + [MouseRegion]
/// boilerplate. Import this wherever hover behaviour is needed.
mixin HoverStateMixin<T extends StatefulWidget> on State<T> {
  bool isHovered = false;

  Widget buildHoverable({required Widget child}) => MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: child,
      );
}
