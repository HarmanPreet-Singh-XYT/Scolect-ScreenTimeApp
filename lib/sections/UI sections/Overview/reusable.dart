import 'package:fluent_ui/fluent_ui.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final double iconSize;
  final double fontSize;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.iconSize = 32,
    this.fontSize = 13,
  });

  static const _iconTextGap = SizedBox(height: 12);

  @override
  Widget build(BuildContext context) {
    final inactiveColor = FluentTheme.of(context).inactiveColor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // shrink-wrap instead of expanding
        children: [
          Icon(
            icon,
            size: iconSize,
            color: inactiveColor.withValues(alpha: 0.5),
          ),
          _iconTextGap,
          Text(
            message,
            style: TextStyle(
              color: inactiveColor,
              fontSize: fontSize,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
