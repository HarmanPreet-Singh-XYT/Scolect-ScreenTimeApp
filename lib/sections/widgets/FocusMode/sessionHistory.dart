import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:screentime/l10n/app_localizations.dart';

// ─── Constants ────────────────────────────────────────────────────

const _kCompleteColor = Color(0xFF4CAF50);
const _kInProgressColor = Color(0xFFFF9800);
const _kWorkColor = Color(0xFFFF5C50);
const _kAnimDuration = Duration(milliseconds: 150);

final _dateFormat = DateFormat('MMM d, HH:mm');

// ─── Duration formatting (top-level, no instance needed) ──────────

String _formatDuration(Duration duration, AppLocalizations l10n) {
  final h = duration.inHours;
  final m = duration.inMinutes.remainder(60);

  if (h > 0 && m > 0) return l10n.hourMinuteFormat(h.toString(), m.toString());
  if (h > 0) return l10n.hourOnlyFormat(h.toString());
  return l10n.minuteFormat(m.toString());
}

// ─── Reusable header text style ───────────────────────────────────

TextStyle? _headerStyle(FluentThemeData theme) =>
    theme.typography.caption?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.typography.caption?.color?.withValues(alpha: 0.6),
    );

TextStyle? _fadedCaption(FluentThemeData theme, {double alpha = 0.6}) =>
    theme.typography.caption?.copyWith(
      color: theme.typography.caption?.color?.withValues(alpha: alpha),
    );

// ─── Session History ──────────────────────────────────────────────

class SessionHistory extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const SessionHistory({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final hStyle = _headerStyle(theme);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 350, minHeight: 100),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  _HeaderCell(label: l10n.dateHeader, flex: 2, style: hStyle),
                  _HeaderCell(
                      label: l10n.durationHeader,
                      align: TextAlign.center,
                      style: hStyle),
                  _HeaderCell(
                      label: l10n.statusHeader,
                      align: TextAlign.right,
                      style: hStyle),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // List
            Expanded(
              child: data.isEmpty
                  ? _EmptyState(theme: theme, l10n: l10n)
                  : ListView.separated(
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: _GroupedSessionRow(session: data[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small extracted widgets ──────────────────────────────────────

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    this.flex = 1,
    this.align = TextAlign.start,
    this.style,
  });

  final String label;
  final int flex;
  final TextAlign align;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        textAlign: align,
        style: style,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme, required this.l10n});

  final FluentThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FluentIcons.history,
              size: 32, color: theme.inactiveBackgroundColor),
          const SizedBox(height: 8),
          Text(
            l10n.noSessionsYet,
            overflow: TextOverflow.ellipsis,
            style: _fadedCaption(theme, alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

// ─── Session Row ──────────────────────────────────────────────────

class _GroupedSessionRow extends StatefulWidget {
  final Map<String, dynamic> session;
  const _GroupedSessionRow({required this.session});

  @override
  State<_GroupedSessionRow> createState() => _GroupedSessionRowState();
}

class _GroupedSessionRowState extends State<_GroupedSessionRow> {
  bool _isHovered = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final session = widget.session;

    final isComplete = session['isComplete'] as bool? ?? false;
    final isPomodoro = session['type'] == 'pomodoro';
    final startTime = session['startTime'] as DateTime;

    final totalDuration = (session['formattedTotalDuration'] as String?) ??
        _formatDuration(
            session['totalDuration'] as Duration? ?? Duration.zero, l10n);
    final workDuration = (session['formattedWorkDuration'] as String?) ??
        _formatDuration(
            session['workDuration'] as Duration? ?? Duration.zero, l10n);
    final workPhases = session['workPhases'] as int? ?? 0;

    final statusColor = isComplete ? _kCompleteColor : _kInProgressColor;
    final statusIcon = isComplete ? FluentIcons.check_mark : FluentIcons.clock;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: isPomodoro
            ? () => setState(() => _isExpanded = !_isExpanded)
            : null,
        child: AnimatedContainer(
          duration: _kAnimDuration,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.accentColor.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: _isExpanded
                ? Border.all(color: theme.accentColor.withValues(alpha: 0.2))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main row
              Row(
                children: [
                  // Status dot
                  _Dot(color: statusColor, size: 8),
                  const SizedBox(width: 12),

                  // Date column
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _dateFormat.format(startTime),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: theme.typography.body
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        if (isPomodoro)
                          Text(
                            l10n.workSessions(workPhases),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: _fadedCaption(theme),
                          ),
                      ],
                    ),
                  ),

                  // Duration
                  Expanded(
                    child: Text(
                      totalDuration,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: theme.typography.body?.copyWith(
                        color: theme.typography.body?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                  ),

                  // Status
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            isComplete ? l10n.complete : l10n.inProgress,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: theme.typography.caption?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chevron
                  if (isPomodoro) ...[
                    const SizedBox(width: 8),
                    Icon(
                      _isExpanded
                          ? FluentIcons.chevron_up
                          : FluentIcons.chevron_down,
                      size: 12,
                      color: theme.typography.caption?.color
                          ?.withValues(alpha: 0.5),
                    ),
                  ],
                ],
              ),

              // Expanded details
              if (_isExpanded && isPomodoro) ...[
                const SizedBox(height: 12),
                _ExpandedDetails(
                  theme: theme,
                  l10n: l10n,
                  workDuration: workDuration,
                  breakDuration:
                      (session['formattedBreakDuration'] as String?) ??
                          l10n.minuteFormat('0'),
                  phases: session['phases'] as int? ?? 0,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Expanded details panel ───────────────────────────────────────

class _ExpandedDetails extends StatelessWidget {
  const _ExpandedDetails({
    required this.theme,
    required this.l10n,
    required this.workDuration,
    required this.breakDuration,
    required this.phases,
  });

  final FluentThemeData theme;
  final AppLocalizations l10n;
  final String workDuration;
  final String breakDuration;
  final int phases;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.inactiveBackgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DetailRow(
              theme: theme,
              label: l10n.workTime,
              value: workDuration,
              color: _kWorkColor),
          const SizedBox(height: 8),
          _DetailRow(
              theme: theme,
              label: l10n.breakTime,
              value: breakDuration,
              color: _kCompleteColor),
          const SizedBox(height: 8),
          _DetailRow(
              theme: theme,
              label: l10n.phasesCompleted,
              value: '$phases / 8',
              color: theme.accentColor),
        ],
      ),
    );
  }
}

// ─── Detail row ───────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.theme,
    required this.label,
    required this.value,
    required this.color,
  });

  final FluentThemeData theme;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Dot(color: color, size: 4),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.typography.caption,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style:
                theme.typography.caption?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ─── Tiny reusable dot ────────────────────────────────────────────

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
