// Shared constants, widgets, and utilities used across all Browser sub-pages.
import 'dart:math' as math;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/app_design.dart';
export 'package:screentime/sections/controller/data_controllers/applications_data_controller.dart'
    show DurationFormatter;

// ─── Colors & Themes ──────────────────────────────────────────────────────────

const kBrowserGreen  = Color(0xFF10B981);
const kBrowserBlue   = Color(0xFF3B82F6);
const kBrowserPurple = Color(0xFF8B5CF6);
const kBrowserAmber  = Color(0xFFF59E0B);
const kBrowserRed    = Color(0xFFEF4444);
const kBrowserCyan   = Color(0xFF06B6D4);
const kBrowserIndigo = Color(0xFF6366F1);
const kBrowserPink   = Color(0xFFEC4899);
const kBrowserTeal   = Color(0xFF14B8A6);

const List<Color> kBrowserDomainPalette = [
  Color(0xFF3B82F6), // Blue
  Color(0xFF8B5CF6), // Purple
  Color(0xFF10B981), // Green
  Color(0xFFF59E0B), // Amber
  Color(0xFFEC4899), // Pink
  Color(0xFF06B6D4), // Cyan
  Color(0xFF6366F1), // Indigo
  Color(0xFF14B8A6), // Teal
  Color(0xFFF97316), // Orange
  Color(0xFF0EA5E9), // Sky
  Color(0xFFA855F7), // Violet
  Color(0xFFE11D48), // Rose
];

// ─── Animation durations ─────────────────────────────────────────────────────

const kBrowserAnimDuration = Duration(milliseconds: 350);
const kBrowserHoverDuration = Duration(milliseconds: 150);

// ─── Card container ───────────────────────────────────────────────────────────

class BrowserCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;

  const BrowserCard({
    super.key,
    required this.child,
    this.padding,
    this.height,
    this.width,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppDesign.radiusLg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final content = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark
                ? theme.micaBackgroundColor.withValues(alpha: 0.8)
                : theme.micaBackgroundColor),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ??
              (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : theme.inactiveBackgroundColor.withValues(alpha: 0.5)),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}

// ─── Gradient icon box ───────────────────────────────────────────────────────

class BrowserGradientIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double boxSize;

  const BrowserGradientIconBox({
    super.key,
    required this.icon,
    required this.color,
    this.size = 20,
    this.boxSize = 38,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}

// ─── Domain Avatar Widget ─────────────────────────────────────────────────────

class BrowserDomainAvatar extends StatelessWidget {
  final String domain;
  final String? siteName;
  final double size;

  const BrowserDomainAvatar({
    super.key,
    required this.domain,
    this.siteName,
    this.size = 32,
  });

  Color get _color {
    final clean = domain.toLowerCase().replaceAll(RegExp(r'^(https?://)?(www\.)?'), '');
    int hash = 0;
    for (int i = 0; i < clean.length; i++) {
      hash = (hash * 31 + clean.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return kBrowserDomainPalette[hash % kBrowserDomainPalette.length];
  }

  String get _initials {
    final name = (siteName != null && siteName!.isNotEmpty)
        ? siteName!
        : domain.replaceAll(RegExp(r'^(https?://)?(www\.)?'), '');
    final parts = name.split(RegExp(r'[\.\s\-_]')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'W';
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].substring(0, math.min(2, parts[0].length)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final initials = _initials;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size > 28 ? 8 : 6),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

// ─── Category Metadata Helper ─────────────────────────────────────────────────

class CategoryMeta {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryMeta(this.name, this.icon, this.color);

  static CategoryMeta fromName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dev') || lower.contains('code') || lower.contains('tech') || lower.contains('program')) {
      return CategoryMeta(name, FluentIcons.code, kBrowserBlue);
    }
    if (lower.contains('entertain') || lower.contains('video') || lower.contains('stream') || lower.contains('music')) {
      return CategoryMeta(name, FluentIcons.video, kBrowserPurple);
    }
    if (lower.contains('social') || lower.contains('chat') || lower.contains('message') || lower.contains('community')) {
      return CategoryMeta(name, FluentIcons.chat, kBrowserPink);
    }
    if (lower.contains('productiv') || lower.contains('work') || lower.contains('office') || lower.contains('doc')) {
      return CategoryMeta(name, FluentIcons.task_list, kBrowserGreen);
    }
    if (lower.contains('educat') || lower.contains('learn') || lower.contains('school') || lower.contains('study') || lower.contains('science')) {
      return CategoryMeta(name, FluentIcons.education, kBrowserCyan);
    }
    if (lower.contains('shop') || lower.contains('store') || lower.contains('e-commerce') || lower.contains('buy')) {
      return CategoryMeta(name, FluentIcons.shopping_cart, kBrowserAmber);
    }
    if (lower.contains('news') || lower.contains('article') || lower.contains('blog') || lower.contains('read')) {
      return CategoryMeta(name, FluentIcons.news, kBrowserIndigo);
    }
    if (lower.contains('util') || lower.contains('tool') || lower.contains('search') || lower.contains('cloud')) {
      return CategoryMeta(name, FluentIcons.repair, kBrowserTeal);
    }
    if (lower.contains('game') || lower.contains('gaming')) {
      return CategoryMeta(name, FluentIcons.game, kBrowserRed);
    }
    return CategoryMeta(name, FluentIcons.tag, kBrowserBlue);
  }
}

// ─── Search box ──────────────────────────────────────────────────────────────

class BrowserSearchBox extends StatelessWidget {
  final String placeholder;
  final ValueChanged<String> onChanged;
  final double? width;
  final TextEditingController? controller;

  const BrowserSearchBox({
    super.key,
    required this.placeholder,
    required this.onChanged,
    this.width = 280,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: width,
      height: 38,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(AppDesign.radiusMd),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : theme.inactiveBackgroundColor.withValues(alpha: 0.6),
        ),
      ),
      child: TextBox(
        controller: controller,
        placeholder: placeholder,
        style: const TextStyle(fontSize: 13),
        onChanged: onChanged,
        decoration: WidgetStateProperty.all(const BoxDecoration()),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 10, right: 2),
          child: Icon(FluentIcons.search,
              size: 14,
              color: theme.typography.caption?.color?.withValues(alpha: 0.6)),
        ),
      ),
    );
  }
}

// ─── Bordered icon button ─────────────────────────────────────────────────────

class BrowserIconButton extends StatefulWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const BrowserIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 36,
  });

  @override
  State<BrowserIconButton> createState() => _BrowserIconButtonState();
}

class _BrowserIconButtonState extends State<BrowserIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = widget.color ?? theme.accentColor;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: kBrowserHoverDuration,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: _hovered
                  ? (widget.color != null
                      ? widget.color!.withValues(alpha: 0.12)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : theme.inactiveBackgroundColor))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDesign.radiusMd),
              border: Border.all(
                color: _hovered
                    ? (widget.color != null
                        ? widget.color!.withValues(alpha: 0.3)
                        : theme.accentColor.withValues(alpha: 0.4))
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : theme.inactiveBackgroundColor.withValues(alpha: 0.6)),
              ),
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: widget.size * 0.44,
                color: _hovered
                    ? activeColor
                    : theme.typography.body?.color?.withValues(alpha: 0.75),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Stat chip ───────────────────────────────────────────────────────────────

class BrowserStatChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final IconData? icon;

  const BrowserStatChip({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: textColor ?? color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor ?? color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Productivity Tag Chip ────────────────────────────────────────────────────

class ProductivityChip extends StatelessWidget {
  final bool isProductive;
  final VoidCallback? onTap;

  const ProductivityChip({
    super.key,
    required this.isProductive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isProductive ? kBrowserGreen : kBrowserAmber;
    final label = isProductive ? 'Productive' : 'Distracting';
    final icon = isProductive ? FluentIcons.check_mark : FluentIcons.alert_solid;

    final widget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: widget,
        ),
      );
    }
    return widget;
  }
}

// ─── Summary stat card ────────────────────────────────────────────────────────

class BrowserSummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;
  final Widget? trailing;

  const BrowserSummaryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return BrowserCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          BrowserGradientIconBox(
            icon: icon,
            color: color,
            size: 20,
            boxSize: 42,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.typography.caption?.color?.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.typography.subtitle?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class BrowserSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final Widget? trailing;

  const BrowserSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final accent = color ?? theme.accentColor;

    final leadingContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 14, color: accent),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.typography.bodyStrong?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.typography.caption?.color?.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );

    if (trailing == null) {
      return leadingContent;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 460;
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leadingContent,
              const SizedBox(height: 8),
              trailing!,
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: leadingContent),
            const SizedBox(width: 8),
            trailing!,
          ],
        );
      },
    );
  }
}

// ─── Progress Bar ─────────────────────────────────────────────────────────────

class BrowserProgressBar extends StatelessWidget {
  final double fraction; // 0.0 to 1.0
  final Color color;
  final double height;
  final Color? backgroundColor;

  const BrowserProgressBar({
    super.key,
    required this.fraction,
    required this.color,
    this.height = 6,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final clamped = fraction.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: height,
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            color: backgroundColor ??
                (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : theme.inactiveBackgroundColor.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: constraints.maxWidth * clamped,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: clamped > 0
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Circular Score Ring ──────────────────────────────────────────────────────

class BrowserCircularRing extends StatelessWidget {
  final double percentage; // 0 to 100
  final Color color;
  final double size;
  final double strokeWidth;
  final Widget? centerChild;

  const BrowserCircularRing({
    super.key,
    required this.percentage,
    required this.color,
    this.size = 56,
    this.strokeWidth = 5,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: percentage / 100.0,
              progressColor: color,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : theme.inactiveBackgroundColor.withValues(alpha: 0.6),
              strokeWidth: strokeWidth,
            ),
          ),
          if (centerChild != null) centerChild!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      final fgPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.progressColor != progressColor ||
      oldDelegate.backgroundColor != backgroundColor;
}

// ─── Tab definitions & Segmented Tab Bar ──────────────────────────────────────

enum BrowserTab { overview, websites, categories, limits, history, settings }

extension BrowserTabExt on BrowserTab {
  IconData get icon => switch (this) {
        BrowserTab.overview   => FluentIcons.grid_view_small,
        BrowserTab.websites   => FluentIcons.globe,
        BrowserTab.categories => FluentIcons.tag,
        BrowserTab.limits     => FluentIcons.time_picker,
        BrowserTab.history    => FluentIcons.history,
        BrowserTab.settings   => FluentIcons.settings,
      };
}

class BrowserSegmentedTabBar extends StatelessWidget {
  final BrowserTab currentTab;
  final ValueChanged<BrowserTab> onTabChanged;
  final Map<BrowserTab, String>? tabLabels;
  final Map<BrowserTab, int?>? tabCounts;

  const BrowserSegmentedTabBar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    this.tabLabels,
    this.tabCounts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tabs = BrowserTab.values.where((t) => t != BrowserTab.settings).toList();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(AppDesign.radiusMd + 2),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : theme.inactiveBackgroundColor.withValues(alpha: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: tabs.map((tab) {
            final isSelected = currentTab == tab;
            final defaultLabel = tab.name.isNotEmpty
                ? '${tab.name[0].toUpperCase()}${tab.name.substring(1)}'
                : tab.name;
            final label = tabLabels?[tab] ?? defaultLabel;
            final count = tabCounts?[tab];

            return _SegmentedTabItem(
              tab: tab,
              label: label,
              count: count,
              isSelected: isSelected,
              onTap: () => onTabChanged(tab),
              accentColor: theme.accentColor,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SegmentedTabItem extends StatefulWidget {
  final BrowserTab tab;
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;

  const _SegmentedTabItem({
    required this.tab,
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
    required this.accentColor,
  });

  @override
  State<_SegmentedTabItem> createState() => _SegmentedTabItemState();
}

class _SegmentedTabItemState extends State<_SegmentedTabItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: kBrowserHoverDuration,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? (isDark
                    ? widget.accentColor.withValues(alpha: 0.2)
                    : widget.accentColor.withValues(alpha: 0.12))
                : (_hovered
                    ? (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : theme.inactiveBackgroundColor.withValues(alpha: 0.5))
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(AppDesign.radiusSm + 2),
            border: Border.all(
              color: widget.isSelected
                  ? widget.accentColor.withValues(alpha: 0.35)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.tab.icon,
                size: 14,
                color: widget.isSelected
                    ? widget.accentColor
                    : theme.typography.caption?.color?.withValues(alpha: 0.65),
              ),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isSelected
                      ? widget.accentColor
                      : theme.typography.caption?.color?.withValues(alpha: 0.8),
                ),
              ),
              if (widget.count != null && widget.count! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? widget.accentColor
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : theme.inactiveBackgroundColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.count}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: widget.isSelected
                          ? Colors.white
                          : theme.typography.caption?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class BrowserEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const BrowserEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final captionColor = theme.typography.caption?.color;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 26, color: theme.accentColor.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: theme.typography.bodyStrong?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: captionColor?.withValues(alpha: 0.6),
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 10),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
