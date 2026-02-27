import 'package:fluent_ui/fluent_ui.dart';

// ════════════════════════ Card ════════════════════════

class Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const Card({
    super.key,
    required this.child,
    this.padding = _defaultPadding,
  });

  static const _defaultPadding = EdgeInsets.all(20);
  static final _radius = BorderRadius.circular(12);

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: _radius,
        border: Border.all(color: theme.inactiveBackgroundColor),
      ),
      child: child,
    );
  }
}

// ════════════════════════ SliderRow ════════════════════════

class SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final int divisions;
  final int step;
  final ValueChanged<double> onChanged;

  const SliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    required this.divisions,
    this.step = 1,
    required this.onChanged,
  });

  static const _labelWidth = 55.0;
  static const _badgeWidth = 36.0;
  static const _labelStyle =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  static final _badgeRadius = BorderRadius.circular(6);
  static const _badgePadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);

  int get _displayValue =>
      step > 1 ? (value.round() ~/ step * step) : value.round();

  double _snap(double v) => step > 1 ? (v ~/ step * step).toDouble() : v;

  @override
  Widget build(BuildContext context) {
    final accentColor = FluentTheme.of(context).accentColor;

    return Row(
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text(label, style: _labelStyle),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: max,
            divisions: divisions,
            onChanged: (v) => onChanged(_snap(v)),
          ),
        ),
        Container(
          width: _badgeWidth,
          padding: _badgePadding,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: _badgeRadius,
          ),
          child: Text(
            _displayValue.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════ TimeDisplay ════════════════════════

class TimeDisplay extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const TimeDisplay({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════ SettingTile ════════════════════════
// Uses isolated _HoverBuilder so only the background repaints on hover,
// not the entire tile content (icon, text, toggle).

class SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  static const _tilePadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  static const _dividerPadding = EdgeInsets.symmetric(horizontal: 12);
  static final _tileRadius = BorderRadius.circular(8);
  static const _titleStyle =
      TextStyle(fontSize: 13, fontWeight: FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HoverBuilder(
          builder: (isHovered) => AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: _tilePadding,
            decoration: BoxDecoration(
              color: isHovered
                  ? theme.accentColor.withValues(alpha: 0.05)
                  : Colors.transparent,
              borderRadius: _tileRadius,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: theme.accentColor.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: _titleStyle),
                      _SubtitleText(text: subtitle),
                    ],
                  ),
                ),
                ToggleSwitch(checked: value, onChanged: onChanged),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: _dividerPadding,
            child: ColoredBox(
              color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
              child: const SizedBox(height: 1, width: double.infinity),
            ),
          ),
      ],
    );
  }
}

// ════════════════════════ Subtitle Text ════════════════════════
// Extracted to avoid rebuilding when only hover state changes.

class _SubtitleText extends StatelessWidget {
  final String text;

  const _SubtitleText({required this.text});

  @override
  Widget build(BuildContext context) {
    final caption = FluentTheme.of(context).typography.caption;

    return Text(
      text,
      style: caption?.copyWith(
        fontSize: 11,
        color: caption.color?.withValues(alpha: 0.6),
      ),
    );
  }
}

// ════════════════════════ Hover Builder ════════════════════════
// Reusable hover isolation — only rebuilds the builder subtree.

class _HoverBuilder extends StatefulWidget {
  final Widget Function(bool isHovered) builder;

  const _HoverBuilder({required this.builder});

  @override
  State<_HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<_HoverBuilder> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _update(true),
      onExit: (_) => _update(false),
      child: widget.builder(_isHovered),
    );
  }

  void _update(bool value) {
    if (_isHovered != value) setState(() => _isHovered = value);
  }
}
