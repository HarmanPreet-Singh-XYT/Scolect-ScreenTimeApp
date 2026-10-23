import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
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
    final running = _log.running;
    final now = DateTime.now();
    final today = _log.forDay(now);
    final week = _log.totalsByLabel(now.subtract(const Duration(days: 6)), now);
    final weekRows = week.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.tlDescription, style: theme.typography.caption),
        const SizedBox(height: 12),
        if (running == null)
          Row(
            children: [
              Expanded(
                child: TextBox(
                  controller: _label,
                  placeholder: l10n.tlHint,
                  maxLength: ManualLog.maxLabelLength,
                  onSubmitted: (_) => _start(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _start, child: Text(l10n.tlStart)),
              const SizedBox(width: 8),
              Button(onPressed: _addEntry, child: Text(l10n.tlAddEntry)),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(running.label, style: theme.typography.bodyStrong),
                    Text(_clock(_log.runningElapsed), style: theme.typography.subtitle),
                  ],
                ),
              ),
              FilledButton(onPressed: _log.stop, child: Text(l10n.tlStop)),
              const SizedBox(width: 8),
              Button(onPressed: _log.discardRunning, child: Text(l10n.tlDiscard)),
            ],
          ),
        const SizedBox(height: 16),
        Text(l10n.tlToday, style: theme.typography.caption),
        if (today.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(l10n.tlNothingToday, style: theme.typography.caption),
          ),
        for (final e in today)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(child: Text(e.label, overflow: TextOverflow.ellipsis)),
                Text(DailyDigest.formatDuration(e.duration),
                    style: theme.typography.caption),
                IconButton(
                  icon: const Icon(FluentIcons.delete, size: 12),
                  onPressed: () => _log.delete(e.id),
                ),
              ],
            ),
          ),
        if (weekRows.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(l10n.tlThisWeek, style: theme.typography.caption),
          for (final r in weekRows.take(6))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(child: Text(r.key, overflow: TextOverflow.ellipsis)),
                  Text(DailyDigest.formatDuration(Duration(seconds: r.value)),
                      style: theme.typography.caption),
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
