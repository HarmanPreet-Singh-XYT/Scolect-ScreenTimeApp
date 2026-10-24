import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/app_design.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/widgets/duration_fields.dart';
import 'package:screentime/utils/daily_digest.dart';
import 'package:screentime/utils/manual_log.dart';

/// Stopwatch and manual entries. Backed by [ManualLog], which is kept
/// separate from automatically tracked app time.
class TimeLogCard extends StatefulWidget {
  final ManualLog? log;
  const TimeLogCard({super.key, this.log});

  @override
  State<TimeLogCard> createState() => _TimeLogCardState();
}

class _TimeLogCardState extends State<TimeLogCard> {
  late final ManualLog _log = widget.log ?? ManualLog.instance;
  final TextEditingController _label = TextEditingController();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _log.addListener(_onChanged);
    _log.load().then((_) => _syncTicker());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _log.removeListener(_onChanged);
    _label.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    _syncTicker();
    setState(() {});
  }

  /// Ticks once a second, but only while the stopwatch is running.
  void _syncTicker() {
    if (_log.running != null && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (_log.running == null) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  static String _clock(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  Future<void> _addEntry() async {
    final entry = await showDialog<_NewEntry>(
      context: context,
      builder: (_) => const _AddEntryDialog(),
    );
    if (entry == null) return;
    await _log.add(label: entry.label, start: entry.start, duration: entry.duration);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final running = _log.running;
    final now = DateTime.now();
    final today = _log.forDay(now);
    final week = _log.totalsByLabel(now.subtract(const Duration(days: 6)), now);
    final weekRows = week.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxWeekSecs = weekRows.isEmpty
        ? 1
        : weekRows.fold<int>(1, (m, r) => r.value > m ? r.value : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tlDescription,
          style: theme.typography.caption?.copyWith(
            color: theme.typography.caption?.color?.withValues(alpha: 0.8),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),

        // Live Running Stopwatch or New Activity Starter
        if (running == null) ...[
          Row(
            children: [
              Expanded(
                child: TextBox(
                  controller: _label,
                  placeholder: l10n.tlHint,
                  maxLength: ManualLog.maxLabelLength,
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 10, right: 6),
                    child: Icon(FluentIcons.timer, size: 14),
                  ),
                  onSubmitted: (_) => _start(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _start,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.play, size: 11),
                    const SizedBox(width: 6),
                    Text(l10n.tlStart),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Button(
                onPressed: _addEntry,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.add, size: 11),
                    const SizedBox(width: 6),
                    Text(l10n.tlAddEntry),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          // Running State Banner with pulse indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.accentColor.withValues(alpha: isDark ? 0.22 : 0.12),
                  isDark ? theme.micaBackgroundColor : Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.resources.cardStrokeColorDefault,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppDesign.of(context).errorColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppDesign.of(context).errorColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        running.label,
                        style: theme.typography.bodyStrong?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _clock(_log.runningElapsed),
                        style: theme.typography.subtitle?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: theme.accentColor.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _log.stop,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(AppDesign.of(context).successColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.stop, size: 11),
                      const SizedBox(width: 6),
                      Text(l10n.tlStop),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Button(
                  onPressed: _log.discardRunning,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.cancel, size: 11),
                      const SizedBox(width: 6),
                      Text(l10n.tlDiscard),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 18),

        // Today's Activity Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(FluentIcons.clock, size: 12),
                const SizedBox(width: 6),
                Text(
                  l10n.tlToday,
                  style: theme.typography.caption?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            if (today.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${today.length}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: theme.accentColor.normal,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        if (today.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.inactiveBackgroundColor.withValues(alpha: 0.08)
                  : theme.resources.subtleFillColorTertiary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                l10n.tlNothingToday,
                style: theme.typography.caption?.copyWith(
                  color: theme.typography.caption?.color?.withValues(alpha: 0.6),
                ),
              ),
            ),
          )
        else
          Column(
            children: [
              for (final e in today)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.inactiveBackgroundColor.withValues(alpha: 0.15)
                        : theme.resources.subtleFillColorTertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.accentColor.normal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e.label,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.body?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          DailyDigest.formatDuration(e.duration),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.accentColor.normal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Tooltip(
                        message: l10n.deleteCustomTheme,
                        child: IconButton(
                          icon: const Icon(FluentIcons.delete, size: 12),
                          onPressed: () => _log.delete(e.id),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

        // This Week's Breakdown
        if (weekRows.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(FluentIcons.calendar_week, size: 12),
              const SizedBox(width: 6),
              Text(
                l10n.tlThisWeek,
                style: theme.typography.caption?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final r in weekRows.take(5))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      r.key,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.caption?.copyWith(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Container(
                        height: 5,
                        color: isDark ? Colors.grey[160] : Colors.grey[40],
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: (r.value / maxWeekSecs).clamp(0.02, 1.0),
                            child: Container(color: theme.accentColor.normal),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 55,
                    child: Text(
                      DailyDigest.formatDuration(Duration(seconds: r.value)),
                      textAlign: TextAlign.end,
                      style: theme.typography.caption?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _start() async {
    if (await _log.start(_label.text)) _label.clear();
  }
}

class _NewEntry {
  final String label;
  final DateTime start;
  final Duration duration;
  const _NewEntry(this.label, this.start, this.duration);
}

class _AddEntryDialog extends StatefulWidget {
  const _AddEntryDialog();

  @override
  State<_AddEntryDialog> createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<_AddEntryDialog> {
  final TextEditingController _label = TextEditingController();
  DateTime _date = DateTime.now();
  int _hours = 0;
  int _minutes = 30;
  String? _error;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  void _submit(AppLocalizations l10n) {
    final label = ManualLog.cleanLabel(_label.text);
    final duration = Duration(hours: _hours, minutes: _minutes);
    final error = label.isEmpty
        ? l10n.tlErrorLabel
        : (duration == Duration.zero ? l10n.tlErrorDuration : null);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    // Noon keeps the entry on the chosen day whatever the time zone.
    final start = DateTime(_date.year, _date.month, _date.day, 12);
    Navigator.of(context).pop(_NewEntry(label, start, duration));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ContentDialog(
      title: Text(l10n.tlAddEntry),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextBox(
            controller: _label,
            placeholder: l10n.tlHint,
            autofocus: true,
            maxLength: ManualLog.maxLabelLength,
          ),
          const SizedBox(height: 12),
          InfoLabel(
            label: l10n.tlDateLabel,
            child: DatePicker(
              selected: _date,
              endDate: DateTime.now(),
              onChanged: (d) => setState(() => _date = d),
            ),
          ),
          const SizedBox(height: 12),
          InfoLabel(
            label: l10n.tlDurationLabel,
            child: DurationFields(
              hours: _hours,
              minutes: _minutes,
              onHoursChanged: (v) => setState(() => _hours = v),
              onMinutesChanged: (v) => setState(() => _minutes = v),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      actions: [
        Button(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(onPressed: () => _submit(l10n), child: Text(l10n.save)),
      ],
    );
  }
}
