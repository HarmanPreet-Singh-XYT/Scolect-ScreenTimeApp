import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

// ──────────────── Color constants ────────────────

class _StatColors {
  static const blue = Color(0xFF3B82F6);
  static const blueBg = Color(0xFFEFF6FF);
  static const green = Color(0xFF10B981);
  static const greenBg = Color(0xFFECFDF5);
  static const amber = Color(0xFFF59E0B);
  static const amberBg = Color(0xFFFFFBEB);
  static const grey = Color(0xFF6B7280);
  static const greyBg = Color(0xFFF9FAFB);
  static const labelLight = Color(0xFF6B7280);
}

// ──────────────── Stat descriptor ────────────────

class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color lightBg;

  const _StatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.lightBg,
  });
}

// ──────────────── Main Widget ────────────────

class QuickStatsRow extends StatelessWidget {
  final Duration totalScreenTime;
  final int appsWithLimits;
  final int appsNearLimit;
  final bool isMedium;

  const QuickStatsRow({
    super.key,
    required this.totalScreenTime,
    required this.appsWithLimits,
    required this.appsNearLimit,
    required this.isMedium,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasWarning = appsNearLimit > 0;

    final stats = [
      _StatData(
        icon: FluentIcons.clock,
        label: l10n.todaysScreenTime,
        value: formatDuration(totalScreenTime),
        color: _StatColors.blue,
        lightBg: _StatColors.blueBg,
      ),
      _StatData(
        icon: FluentIcons.shield,
        label: l10n.activeLimits,
        value: appsWithLimits.toString(),
        color: _StatColors.green,
        lightBg: _StatColors.greenBg,
      ),
      _StatData(
        icon: FluentIcons.warning,
        label: l10n.nearLimit,
        value: appsNearLimit.toString(),
        color: hasWarning ? _StatColors.amber : _StatColors.grey,
        lightBg: hasWarning ? _StatColors.amberBg : _StatColors.greyBg,
      ),
    ];

    final children = stats.map((s) => _StatChip(data: s)).toList();

    return _ResponsiveLayout(
      isMedium: isMedium,
      children: children,
    );
  }

  /// Shared duration formatter — usable from other widgets.
  static String formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}

// ──────────────── Responsive Layout ────────────────
// Eliminates the manual if/else with index-based Expanded wrapping.

class _ResponsiveLayout extends StatelessWidget {
  final bool isMedium;
  final List<Widget> children;

  const _ResponsiveLayout({
    required this.isMedium,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (isMedium) {
      return Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: children[i]),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          children[i],
        ],
      ],
    );
  }
}

// ──────────────── Stat Chip ────────────────

class _StatChip extends StatelessWidget {
  final _StatData data;

  const _StatChip({required this.data});

  static final _chipRadius = BorderRadius.circular(12);
  static final _iconRadius = BorderRadius.circular(10);
  static const _chipPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 14);
  static const _iconPadding = EdgeInsets.all(10);

  @override
  Widget build(BuildContext context) {
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;
    final color = data.color;

    return Container(
      padding: _chipPadding,
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.15) : data.lightBg,
        borderRadius: _chipRadius,
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.15),
        ),
      ),
      child: Row(
        children: [
          _IconBadge(
            icon: data.icon,
            color: color,
            isDark: isDark,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : _StatColors.labelLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────── Icon Badge ────────────────

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isDark;

  const _IconBadge({
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _StatChip._iconPadding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: _StatChip._iconRadius,
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}
