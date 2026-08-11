// Shared constants, widgets, and utilities used across all Browser sub-pages.
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/app_design.dart';

// ─── Colors ──────────────────────────────────────────────────────────────────

const kBrowserGreen  = Color(0xFF10B981);
const kBrowserBlue   = Color(0xFF3B82F6);
const kBrowserPurple = Color(0xFF8B5CF6);
const kBrowserAmber  = Color(0xFFF59E0B);
const kBrowserRed    = Color(0xFFEF4444);

// ─── Animation durations ─────────────────────────────────────────────────────

const kBrowserAnimDuration = Duration(milliseconds: 400);
const kBrowserHoverDuration = Duration(milliseconds: 150);

// ─── Card container ───────────────────────────────────────────────────────────

class BrowserCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? height;

  const BrowserCard({
    super.key,
    required this.child,
    this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      height: height,
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(AppDesign.radiusLg),
        border: Border.all(
          color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Gradient icon box (matches Applications pattern) ─────────────────────────

class BrowserGradientIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const BrowserGradientIconBox({
    super.key,
    required this.icon,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: size, color: color),
    );
  }
}

// ─── Search box ──────────────────────────────────────────────────────────────

class BrowserSearchBox extends StatelessWidget {
  final String placeholder;
  final ValueChanged<String> onChanged;
  final double? width;

  const BrowserSearchBox({
    super.key,
    required this.placeholder,
    required this.onChanged,
    this.width = 260,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      width: width,
      height: 36,
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(AppDesign.radiusMd),
        border: Border.all(
          color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
        ),
      ),
      child: TextBox(
        placeholder: placeholder,
        style: const TextStyle(fontSize: 13),
        onChanged: onChanged,
        decoration: WidgetStateProperty.all(const BoxDecoration()),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Icon(FluentIcons.search,
              size: 14,
              color: theme.typography.caption?.color?.withValues(alpha: 0.5)),
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

  const BrowserIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<BrowserIconButton> createState() => _BrowserIconButtonState();
}

class _BrowserIconButtonState extends State<BrowserIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _hovered
                  ? theme.inactiveBackgroundColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDesign.radiusMd),
              border: Border.all(
                color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(widget.icon,
                size: 16,
                color: theme.typography.body?.color?.withValues(alpha: 0.7)),
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

  const BrowserStatChip({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor ?? Colors.white,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ─── Summary stat card ────────────────────────────────────────────────────────

class BrowserSummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const BrowserSummaryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return BrowserCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.typography.caption?.color?.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.typography.subtitle?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Tab bar ─────────────────────────────────────────────────────────────────

enum BrowserTab { overview, websites, categories, limits, history, settings }

class _TabButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.accent,
  });

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: kBrowserHoverDuration,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.selected
                ? widget.accent.withValues(alpha: 0.15)
                : _hovered
                    ? theme.inactiveBackgroundColor.withValues(alpha: 0.5)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDesign.radiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: widget.selected
                    ? widget.accent
                    : theme.typography.caption?.color?.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: widget.selected
                      ? widget.accent
                      : theme.typography.caption?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension BrowserTabExt on BrowserTab {
  IconData get icon => switch (this) {
        BrowserTab.overview    => FluentIcons.grid_view_small,
        BrowserTab.websites    => FluentIcons.globe,
        BrowserTab.categories  => FluentIcons.tag,
        BrowserTab.limits      => FluentIcons.time_picker,
        BrowserTab.history     => FluentIcons.history,
        BrowserTab.settings    => FluentIcons.settings,
      };
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class BrowserEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const BrowserEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final captionColor = theme.typography.caption?.color;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 40, color: captionColor?.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.typography.body?.copyWith(
              fontWeight: FontWeight.w600,
              color: captionColor?.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: captionColor?.withValues(alpha: 0.35),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
