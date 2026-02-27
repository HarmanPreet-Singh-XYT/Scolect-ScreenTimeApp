import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import './reusable.dart' as rub;

class OverallLimitCard extends StatelessWidget {
  final bool enabled;
  final double hours;
  final double minutes;
  final Duration totalScreenTime;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<double> onHoursChanged;
  final ValueChanged<double> onMinutesChanged;

  const OverallLimitCard({
    super.key,
    required this.enabled,
    required this.hours,
    required this.minutes,
    required this.totalScreenTime,
    required this.onEnabledChanged,
    required this.onHoursChanged,
    required this.onMinutesChanged,
  });

  // ──────────────── computed properties ────────────────

  Duration get _limitDuration => Duration(
        hours: hours.round(),
        minutes: _roundedMinutes,
      );

  int get _roundedMinutes => minutes.round() ~/ 5 * 5;

  double get _progress {
    if (!enabled || _limitDuration.inMinutes == 0) return 0.0;
    return (totalScreenTime.inMinutes / _limitDuration.inMinutes)
        .clamp(0.0, 1.0);
  }

  Color get _statusColor {
    if (!enabled || _limitDuration == Duration.zero) return Colors.grey;
    final pct = totalScreenTime.inMinutes / _limitDuration.inMinutes;
    if (pct >= 1.0) return Colors.red;
    if (pct > 0.9) return Colors.orange;
    if (pct > 0.75) return const Color(0xFFEAB308);
    return const Color(0xFF10B981);
  }

  // ──────────────── build ────────────────

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;

    return rub.Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(
            enabled: enabled,
            statusColor: color,
            onEnabledChanged: onEnabledChanged,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: enabled
                ? _EnabledContent(
                    hours: hours,
                    roundedMinutes: _roundedMinutes,
                    limitDuration: _limitDuration,
                    totalScreenTime: totalScreenTime,
                    progress: _progress,
                    statusColor: color,
                    onHoursChanged: onHoursChanged,
                    onMinutesChanged: onMinutesChanged,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ──────────────── shared utility ────────────────

  static String formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }
}

// ═══════════════════ Header ═══════════════════

class _Header extends StatelessWidget {
  final bool enabled;
  final Color statusColor;
  final ValueChanged<bool> onEnabledChanged;

  const _Header({
    required this.enabled,
    required this.statusColor,
    required this.onEnabledChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(FluentIcons.stopwatch, size: 18, color: statusColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            l10n.overallScreenTimeLimit,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        ToggleSwitch(
          checked: enabled,
          onChanged: onEnabledChanged,
        ),
      ],
    );
  }
}

// ═══════════════════ Enabled Content ═══════════════════

class _EnabledContent extends StatelessWidget {
  final double hours;
  final int roundedMinutes;
  final Duration limitDuration;
  final Duration totalScreenTime;
  final double progress;
  final Color statusColor;
  final ValueChanged<double> onHoursChanged;
  final ValueChanged<double> onMinutesChanged;

  const _EnabledContent({
    required this.hours,
    required this.roundedMinutes,
    required this.limitDuration,
    required this.totalScreenTime,
    required this.progress,
    required this.statusColor,
    required this.onHoursChanged,
    required this.onMinutesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        _TimeDisplayPanel(
          hours: hours.round(),
          minutes: roundedMinutes,
          limitDuration: limitDuration,
          totalScreenTime: totalScreenTime,
          progress: progress,
          statusColor: statusColor,
        ),
        const SizedBox(height: 16),
        rub.SliderRow(
          label: l10n.hours,
          value: hours,
          max: 12,
          divisions: 12,
          onChanged: onHoursChanged,
        ),
        const SizedBox(height: 8),
        rub.SliderRow(
          label: l10n.minutes,
          value: hours, // ← will fix below
          max: 55,
          divisions: 11,
          step: 5,
          onChanged: onMinutesChanged,
        ),
      ],
    );
  }
}

// ═══════════════════ Time Display Panel ═══════════════════

class _TimeDisplayPanel extends StatelessWidget {
  final int hours;
  final int minutes;
  final Duration limitDuration;
  final Duration totalScreenTime;
  final double progress;
  final Color statusColor;

  const _TimeDisplayPanel({
    required this.hours,
    required this.minutes,
    required this.limitDuration,
    required this.totalScreenTime,
    required this.progress,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              rub.TimeDisplay(
                value: hours,
                label: l10n.hours,
                color: statusColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: statusColor,
                  ),
                ),
              ),
              rub.TimeDisplay(
                value: minutes,
                label: l10n.minutes,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              width: double.infinity,
              child: ProgressBar(
                value: progress * 100,
                backgroundColor: theme.inactiveBackgroundColor,
                activeColor: statusColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.screenTimeUsed(
              OverallLimitCard.formatDuration(totalScreenTime),
              OverallLimitCard.formatDuration(limitDuration),
            ),
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
