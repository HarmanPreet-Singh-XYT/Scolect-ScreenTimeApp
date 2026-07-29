import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mt;

// ─────────────────────────────────────────────────────────────────────────────
// Shared Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kAnimDuration = Duration(milliseconds: 150);
const _kExpandDuration = Duration(milliseconds: 250);
final _kBorderRadius6 = BorderRadius.circular(6);
final _kBorderRadius8 = BorderRadius.circular(8);

const _kHeaderPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);
const _kContentPadding = EdgeInsets.all(16);
const _kCardShadow = BoxShadow(
  color: Color(0x08000000), // black @ 0.03 alpha
  blurRadius: 8,
  offset: Offset(0, 2),
);

// ─────────────────────────────────────────────────────────────────────────────
// Shared Hover Mixin
// ─────────────────────────────────────────────────────────────────────────────

mixin _HoverStateMixin<T extends StatefulWidget> on State<T> {
  bool isHovered = false;

  Widget buildHoverRegion({required Widget child}) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card Decoration Helper
// ─────────────────────────────────────────────────────────────────────────────

BoxDecoration _cardDecoration(FluentThemeData theme) {
  return BoxDecoration(
    color: theme.micaBackgroundColor,
    borderRadius: _kBorderRadius8,
    border: Border.all(
      color: theme.inactiveBackgroundColor.withValues(alpha: 0.6),
    ),
    boxShadow: const [_kCardShadow],
  );
}

Widget _cardHeaderIcon({
  required IconData icon,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: _kBorderRadius6,
    ),
    child: Icon(icon, size: 16, color: color),
  );
}

// ============== STICKY HEADER DELEGATE ==============

class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  StickyHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant StickyHeaderDelegate oldDelegate) =>
      child != oldDelegate.child || height != oldDelegate.height;
}

// ============== QUICK ACTION BUTTON ==============

class QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<QuickActionButton> createState() => QuickActionButtonState();
}

class QuickActionButtonState extends State<QuickActionButton>
    with _HoverStateMixin {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: buildHoverRegion(
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: _kAnimDuration,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHovered
                  ? FluentTheme.of(context).inactiveBackgroundColor
                  : Colors.transparent,
              borderRadius: _kBorderRadius6,
            ),
            child: Icon(widget.icon, size: 18),
          ),
        ),
      ),
    );
  }
}

// ============== SETTINGS CARD ==============

class SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final List<Widget> children;
  final Widget? trailing;
  final bool isExpanded;
  final VoidCallback? onExpandToggle;

  const SettingsCard({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    required this.children,
    this.trailing,
    this.isExpanded = true,
    this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final effectiveColor = iconColor ?? theme.accentColor;
    final isExpandable = onExpandToggle != null;

    return Container(
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onExpandToggle,
            child: MouseRegion(
              cursor: isExpandable
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: Container(
                padding: _kHeaderPadding,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          theme.inactiveBackgroundColor.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    _cardHeaderIcon(icon: icon, color: effectiveColor),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (trailing != null) trailing!,
                    if (isExpandable) ...[
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isExpanded ? 0 : -0.25,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(FluentIcons.chevron_down, size: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: _kContentPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
        ],
      ),
    );
  }
}

// ============== SETTING ROW ==============

class SettingRow extends StatefulWidget {
  final String title;
  final String description;
  final Widget control;
  final IconData? icon;
  final bool isSubSetting;
  final bool showDivider;

  const SettingRow({
    super.key,
    required this.title,
    required this.description,
    required this.control,
    this.icon,
    this.isSubSetting = false,
    this.showDivider = true,
  });

  @override
  State<SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<SettingRow> with _HoverStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isSub = widget.isSubSetting;

    return Column(
      children: [
        buildHoverRegion(
          child: AnimatedContainer(
            duration: _kAnimDuration,
            padding: EdgeInsets.symmetric(
              horizontal: isSub ? 12 : 8,
              vertical: 10,
            ),
            margin: EdgeInsets.only(left: isSub ? 20 : 0),
            decoration: BoxDecoration(
              color: isHovered
                  ? theme.inactiveBackgroundColor.withValues(alpha: 0.3)
                  : null,
              borderRadius: _kBorderRadius6,
              border: isSub
                  ? Border(
                      left: BorderSide(
                        color: theme.accentColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 16, color: theme.accentColor),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSub ? Colors.grey[100] : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[100],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                widget.control,
              ],
            ),
          ),
        ),
        if (widget.showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              height: 1,
              color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
            ),
          ),
      ],
    );
  }
}

// ============== STATUS BADGE ==============

class StatusBadge extends StatelessWidget {
  final bool isActive;
  final String activeText;
  final String inactiveText;

  const StatusBadge({
    super.key,
    required this.isActive,
    required this.activeText,
    required this.inactiveText,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.green : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? activeText : inactiveText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ============== TIMEOUT BUTTON ==============

class TimeoutButton extends StatefulWidget {
  final String value;
  final VoidCallback onPressed;

  const TimeoutButton({
    super.key,
    required this.value,
    required this.onPressed,
  });

  @override
  State<TimeoutButton> createState() => TimeoutButtonState();
}

class TimeoutButtonState extends State<TimeoutButton> with _HoverStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final accent = theme.accentColor;

    return buildHoverRegion(
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: _kAnimDuration,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isHovered
                ? accent.withValues(alpha: 0.1)
                : theme.inactiveBackgroundColor.withValues(alpha: 0.3),
            borderRadius: _kBorderRadius6,
            border: Border.all(
              color: isHovered
                  ? accent.withValues(alpha: 0.5)
                  : theme.inactiveBackgroundColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isHovered ? accent : null,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                FluentIcons.edit,
                size: 12,
                color: isHovered ? accent : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== WARNING BANNER ==============

class WarningBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;

  const WarningBanner({
    super.key,
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: _kBorderRadius6,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style:
                  TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== ANIMATED TOGGLE CARD ==============

class AnimatedToggleCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final List<Widget> children;
  final Widget? trailing;
  final bool initiallyExpanded;

  const AnimatedToggleCard({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    required this.children,
    this.trailing,
    this.initiallyExpanded = true,
  });

  @override
  State<AnimatedToggleCard> createState() => _AnimatedToggleCardState();
}

class _AnimatedToggleCardState extends State<AnimatedToggleCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded = widget.initiallyExpanded;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _kExpandDuration,
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );

    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _expandAnimation = curve;
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final effectiveColor = widget.iconColor ?? theme.accentColor;

    return Container(
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mt.Material(
            color: Colors.transparent,
            child: mt.InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(8),
                bottom: Radius.circular(_isExpanded ? 0 : 8),
              ),
              child: Container(
                padding: _kHeaderPadding,
                decoration: _isExpanded
                    ? BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.inactiveBackgroundColor
                                .withValues(alpha: 0.4),
                          ),
                        ),
                      )
                    : null,
                child: Row(
                  children: [
                    _cardHeaderIcon(icon: widget.icon, color: effectiveColor),
                    const SizedBox(width: 12),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (widget.trailing != null) widget.trailing!,
                    const SizedBox(width: 8),
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: const Icon(FluentIcons.chevron_down, size: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: _kContentPadding,
              child: Column(children: widget.children),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== COMPACT SETTING TILE ==============

class CompactSettingTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget control;
  final IconData? leadingIcon;
  final Color? iconColor;

  const CompactSettingTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.control,
    this.leadingIcon,
    this.iconColor,
  });

  @override
  State<CompactSettingTile> createState() => _CompactSettingTileState();
}

class _CompactSettingTileState extends State<CompactSettingTile>
    with _HoverStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return buildHoverRegion(
      child: AnimatedContainer(
        duration: _kAnimDuration,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isHovered
              ? theme.inactiveBackgroundColor.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: _kBorderRadius6,
        ),
        child: Row(
          children: [
            if (widget.leadingIcon != null) ...[
              Icon(
                widget.leadingIcon,
                size: 16,
                color: widget.iconColor ?? theme.accentColor,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: TextStyle(fontSize: 11, color: Colors.grey[100]),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            widget.control,
          ],
        ),
      ),
    );
  }
}

// ============== INFO TOOLTIP ==============

class InfoTooltip extends StatelessWidget {
  final String message;

  const InfoTooltip({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: MouseRegion(
        cursor: SystemMouseCursors.help,
        child: Icon(FluentIcons.info, size: 14, color: Colors.grey[100]),
      ),
    );
  }
}

// ============== SEGMENTED SELECTOR ==============

class SegmentedSelector<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  const SegmentedSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
        borderRadius: _kBorderRadius6,
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            _SegmentOption<T>(
              option: option,
              isSelected: option == selected,
              label: labelBuilder(option),
              onTap: () => onChanged(option),
            ),
        ],
      ),
    );
  }
}

class _SegmentOption<T> extends StatelessWidget {
  final T option;
  final bool isSelected;
  final String label;
  final VoidCallback onTap;

  const _SegmentOption({
    required this.option,
    required this.isSelected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: _kAnimDuration,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.micaBackgroundColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? theme.accentColor : Colors.grey[100],
          ),
        ),
      ),
    );
  }
}

// ============== PROGRESS BUTTON ==============

class ProgressButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Future<void> Function() onPressed;

  const ProgressButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<ProgressButton> createState() => _ProgressButtonState();
}

class _ProgressButtonState extends State<ProgressButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: _isLoading ? null : _handlePress,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoading)
            const SizedBox(
              width: 12,
              height: 12,
              child: ProgressRing(strokeWidth: 2),
            )
          else
            Icon(widget.icon, size: 12),
          const SizedBox(width: 8),
          Text(widget.label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
