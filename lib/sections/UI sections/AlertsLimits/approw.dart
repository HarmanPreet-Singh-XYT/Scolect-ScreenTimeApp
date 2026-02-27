import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/sections/controller/data_controllers/alerts_limits_data_controller.dart';
import 'package:screentime/l10n/app_localizations.dart';

class AppRow extends StatelessWidget {
  final AppUsageSummary app;
  final VoidCallback onEdit;
  final bool isLast;

  const AppRow({
    super.key,
    required this.app,
    required this.onEdit,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final statusColor = _statusColor;
    final progress = _progress;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HoverBuilder(
          builder: (isHovered) => AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isHovered
                  ? theme.accentColor.withValues(alpha: 0.04)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                _AppNameCell(
                  appName: app.appName,
                  isActive: app.limitStatus,
                  statusColor: statusColor,
                ),
                _CategoryCell(category: app.category),
                _DailyLimitCell(
                  dailyLimit: app.dailyLimit,
                  isActive: app.limitStatus,
                ),
                _UsageCell(
                  currentUsage: app.currentUsage,
                  dailyLimit: app.dailyLimit,
                  isActive: app.limitStatus,
                  statusColor: statusColor,
                  progress: progress,
                ),
                _EditCell(
                  isHovered: isHovered,
                  onEdit: onEdit,
                ),
              ],
            ),
          ),
        ),
        if (!isLast) _Divider(),
      ],
    );
  }

  // ──────────────── cached computed properties ────────────────

  double get _progress {
    if (!app.limitStatus || app.dailyLimit == Duration.zero) return 0.0;
    return (app.currentUsage.inMinutes / app.dailyLimit.inMinutes)
        .clamp(0.0, 1.0);
  }

  Color get _statusColor {
    if (!app.limitStatus || app.dailyLimit == Duration.zero) {
      return Colors.grey;
    }
    if (app.currentUsage >= app.dailyLimit) return Colors.red;
    if (app.isAboutToReachLimit) return Colors.orange;
    if (app.percentageOfLimitUsed > 0.75) return const Color(0xFFEAB308);
    return const Color(0xFF10B981);
  }

  static String formatDuration(Duration duration, AppLocalizations l10n) {
    if (duration == Duration.zero) return l10n.durationNone;
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    if (h > 0 && m > 0) return l10n.durationHoursMinutes(h, m);
    if (h > 0) return '${h}h';
    return l10n.durationMinutesOnly(m);
  }
}

// ═══════════════════ Lightweight Hover Builder ═══════════════════
// Only rebuilds the hovered subtree, not the entire parent.

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
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: widget.builder(_isHovered),
    );
  }

  void _setHovered(bool value) {
    if (_isHovered != value) setState(() => _isHovered = value);
  }
}

// ═══════════════════ Cell Widgets ═══════════════════

class _AppNameCell extends StatelessWidget {
  final String appName;
  final bool isActive;
  final Color statusColor;

  const _AppNameCell({
    required this.appName,
    required this.isActive,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            appName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                isActive ? l10n.active : l10n.off,
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryCell extends StatelessWidget {
  final String category;

  const _CategoryCell({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(
          category,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: theme.typography.body?.color?.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _DailyLimitCell extends StatelessWidget {
  final Duration dailyLimit;
  final bool isActive;

  const _DailyLimitCell({
    required this.dailyLimit,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(
          AppRow.formatDuration(dailyLimit, l10n),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? null : theme.inactiveColor,
          ),
        ),
      ),
    );
  }
}

class _UsageCell extends StatelessWidget {
  final Duration currentUsage;
  final Duration dailyLimit;
  final bool isActive;
  final Color statusColor;
  final double progress;

  const _UsageCell({
    required this.currentUsage,
    required this.dailyLimit,
    required this.isActive,
    required this.statusColor,
    required this.progress,
  });

  bool get _showProgress => isActive && dailyLimit != Duration.zero;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            Text(
              AppRow.formatDuration(currentUsage, l10n),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
            if (_showProgress) ...[
              const SizedBox(width: 10),
              Expanded(
                child: _ProgressBar(
                  progress: progress,
                  color: statusColor,
                  backgroundColor: theme.inactiveBackgroundColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  color:
                      theme.typography.caption?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditCell extends StatelessWidget {
  final bool isHovered;
  final VoidCallback onEdit;

  const _EditCell({
    required this.isHovered,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return SizedBox(
      width: 50,
      child: Center(
        child: IconButton(
          icon: Icon(
            FluentIcons.edit,
            size: 14,
            color: isHovered ? theme.accentColor : theme.inactiveColor,
          ),
          onPressed: onEdit,
        ),
      ),
    );
  }
}

// ═══════════════════ Shared Small Widgets ═══════════════════

class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final Color backgroundColor;

  const _ProgressBar({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  static final _radius = BorderRadius.circular(2);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: _radius,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: _radius,
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
    );
  }
}
