import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/data_controllers/applications_data_controller.dart'
    show DurationFormatter;
import 'package:screentime/sections/controller/data_controllers/insights_data.dart';
import 'package:screentime/sections/widgets/Reports/insights/time_log_card.dart';
import 'package:screentime/utils/date_formats.dart';
import 'package:screentime/utils/device_sync.dart';

const int kHeatmapWeeks = 26;

/// Desktop-only analytics: week comparison, activity heatmap, a day timeline
/// and window-title search. All numbers come from [InsightsData].
class InsightsView extends StatefulWidget {
  /// Overridable for tests.
  final InsightsData? data;
  const InsightsView({super.key, this.data});

  @override
  State<InsightsView> createState() => _InsightsViewState();
}

class _InsightsViewState extends State<InsightsView> {
  late final InsightsData _data = widget.data ??
      InsightsData(AppDataStore(), peers: () => DeviceSync.instance.peers);
  late DateTime _day = _data.today;
  late WeekComparison _week;
  late Map<DateTime, Duration> _daily;
  late DayTimeline _timeline;
  final TextEditingController _query = TextEditingController();
  List<TitleHit> _hits = const [];
  late bool _hasTitles;

  @override
  void initState() {
    super.initState();
    _week = _data.compareWeeks();
    _daily = _data.dailyTotals(kHeatmapWeeks * 7);
    _timeline = _data.dayTimeline(_day);
    _hasTitles = _data.hasAnyTitles();
    DeviceSync.instance.addListener(_onPeersChanged);
    // Don't make the user wait for the next timer tick to see other devices.
    unawaited(DeviceSync.instance.refreshIfStale());
  }

  void _onPeersChanged() {
    if (!mounted) return;
    if (!_data.hasPeers && _data.allDevices) _data.allDevices = false;
    _reload();
  }

  @override
  void dispose() {
    DeviceSync.instance.removeListener(_onPeersChanged);
    _query.dispose();
    super.dispose();
  }

  /// Recomputes everything, e.g. after switching between this device and all.
  void _reload() {
    setState(() {
      _week = _data.compareWeeks();
      _daily = _data.dailyTotals(kHeatmapWeeks * 7);
      _timeline = _data.dayTimeline(_day);
    });
  }

  void _setAllDevices(bool all) {
    if (_data.allDevices == all) return;
    _data.allDevices = all;
    _reload();
  }

  void _selectDay(DateTime day) {
    final today = _data.today;
    final clamped = day.isAfter(today) ? today : day;
    setState(() {
      _day = clamped;
      _timeline = _data.dayTimeline(clamped);
    });
  }

  void _search(String text) =>
      setState(() => _hits = _data.searchTitles(text));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_data.hasPeers) ...[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ToggleButton(
                  checked: !_data.allDevices,
                  onChanged: (_) => _setAllDevices(false),
                  child: Text(l10n.insThisDevice),
                ),
                const SizedBox(width: 8),
                ToggleButton(
                  checked: _data.allDevices,
                  onChanged: (_) => _setAllDevices(true),
                  child: Text(l10n.insAllDevices),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        _Card(title: l10n.tlTitle, child: const TimeLogCard()),
        const SizedBox(height: 16),
        _Card(
          title: l10n.insTrendsTitle,
          child: _TrendsBody(week: _week),
        ),
        const SizedBox(height: 16),
        _Card(
          title: l10n.insHeatmapTitle,
          child: ActivityHeatmap(
            totals: _daily,
            selected: _day,
            onSelect: _selectDay,
          ),
        ),
        const SizedBox(height: 16),
        _Card(
          title: l10n.insTimelineTitle,
          child: _TimelineBody(
            timeline: _timeline,
            canGoNext: _day.isBefore(_data.today),
            onPrev: () => _selectDay(_day.subtract(const Duration(days: 1))),
            onNext: () => _selectDay(_day.add(const Duration(days: 1))),
          ),
        ),
        const SizedBox(height: 16),
        _Card(
          title: l10n.insSearchTitle,
          child: _SearchBody(
            controller: _query,
            hits: _hits,
            hasTitles: _hasTitles,
            onChanged: _search,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.resources.dividerStrokeColorDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.typography.bodyStrong),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

String _signed(Duration d) {
  final sign = d.isNegative ? '−' : '+';
  return '$sign${d.abs().toHourMinuteFormat()}';
}

// ─── Trends ────────────────────────────────────────────────────────────────

class _TrendsBody extends StatelessWidget {
  final WeekComparison week;
  const _TrendsBody({required this.week});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    if (!week.hasData) {
      return Text(l10n.insNoData, style: theme.typography.caption);
    }

    Widget stat(String label, Duration value) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.typography.caption),
              Text(value.toHourMinuteFormat(), style: theme.typography.subtitle),
            ],
          ),
        );

    Widget deltaRow(String label, Duration cur, Duration prev) {
      final d = cur - prev;
      final color = d == Duration.zero
          ? theme.typography.caption?.color
          : (d.isNegative ? Colors.green : Colors.orange);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
            Text(cur.toHourMinuteFormat(), style: theme.typography.caption),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              child: Text(_signed(d),
                  textAlign: TextAlign.end,
                  style: theme.typography.bodyStrong?.copyWith(color: color)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          stat(l10n.insThisWeek, week.current),
          stat(l10n.insLastWeek, week.previous),
          stat('Δ', week.delta),
        ]),
        if (week.categories.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.insByCategory, style: theme.typography.caption),
          for (final c in week.categories.take(6))
            deltaRow(c.category, c.current, c.previous),
        ],
        if (week.movers.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.insBiggestChanges, style: theme.typography.caption),
          for (final m in week.movers) deltaRow(m.name, m.current, m.previous),
        ],
      ],
    );
  }
}

// ─── Heatmap ───────────────────────────────────────────────────────────────

/// GitHub-style grid: one column per week (Monday first), one row per weekday.
class ActivityHeatmap extends StatelessWidget {
  final Map<DateTime, Duration> totals;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  const ActivityHeatmap(
      {super.key,
      required this.totals,
      required this.selected,
      required this.onSelect});

  /// 0 = no activity, 1..4 = quartiles of the busiest day.
  static int level(Duration d, Duration max) {
    if (d <= Duration.zero || max <= Duration.zero) return 0;
    final ratio = d.inSeconds / max.inSeconds;
    if (ratio > 0.75) return 4;
    if (ratio > 0.5) return 3;
    if (ratio > 0.25) return 2;
    return 1;
  }

  static const _alphas = [0.0, 0.25, 0.45, 0.7, 1.0];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final days = totals.keys.toList()..sort();
    if (days.isEmpty) return Text(l10n.insNoData, style: theme.typography.caption);

    final last = days.last;
    final max = totals.values.fold<Duration>(Duration.zero, (m, d) => d > m ? d : m);
    // Monday of the week containing `last`, then back (weeks - 1) weeks.
    final lastMonday = last.subtract(Duration(days: last.weekday - 1));
    final firstMonday =
        lastMonday.subtract(const Duration(days: 7 * (kHeatmapWeeks - 1)));

    Widget cell(DateTime date) {
      final inRange = totals.containsKey(date);
      if (!inRange) return const SizedBox(width: 13, height: 13);
      final d = totals[date]!;
      final lv = level(d, max);
      final isSelected = date == selected;
      return Tooltip(
        message: l10n.insHeatmapTip(AppDateFormat.weekdayWithDate(date),
            d.toHourMinuteFormat()),
        child: GestureDetector(
          onTap: () => onSelect(date),
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: lv == 0
                  ? theme.inactiveBackgroundColor.withValues(alpha: 0.35)
                  : theme.accentColor.withValues(alpha: _alphas[lv]),
              borderRadius: BorderRadius.circular(3),
              border: isSelected
                  ? Border.all(color: theme.typography.body?.color ?? Colors.white, width: 1.5)
                  : null,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var w = 0; w < kHeatmapWeeks; w++)
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Column(
                    children: [
                      for (var d = 0; d < 7; d++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: cell(firstMonday.add(Duration(days: w * 7 + d))),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(l10n.insLess, style: theme.typography.caption),
            const SizedBox(width: 6),
            for (var i = 0; i < 5; i++)
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: i == 0
                        ? theme.inactiveBackgroundColor.withValues(alpha: 0.35)
                        : theme.accentColor.withValues(alpha: _alphas[i]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            const SizedBox(width: 3),
            Text(l10n.insMore, style: theme.typography.caption),
          ],
        ),
      ],
    );
  }
}

// ─── Day timeline ──────────────────────────────────────────────────────────

const List<Color> _palette = [
  Color(0xFF3B82F6),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFF8B5CF6),
  Color(0xFF06B6D4),
];

class _TimelineBody extends StatelessWidget {
  final DayTimeline timeline;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _TimelineBody({
    required this.timeline,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    const barHeight = 120.0;

    Color colorFor(String key) {
      if (key == DayTimeline.otherKey) return theme.inactiveColor.withValues(alpha: 0.6);
      final i = timeline.topApps.indexWhere((a) => a.appId == key);
      return _palette[(i < 0 ? 0 : i) % _palette.length];
    }

    Widget hourBar(int h) {
      final entries = timeline.hours[h].entries.toList()
        ..sort((a, b) {
          if (a.key == DayTimeline.otherKey) return 1;
          if (b.key == DayTimeline.otherKey) return -1;
          return a.key.compareTo(b.key);
        });
      final total = timeline.hourTotal(h);
      return Expanded(
        child: Tooltip(
          message: total == 0
              ? '${h.toString().padLeft(2, '0')}:00'
              : '${h.toString().padLeft(2, '0')}:00 · ${Duration(seconds: total).toHourMinuteFormat()}',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final e in entries.reversed)
                      Container(
                        height: (e.value / 3600.0).clamp(0.0, 1.0) * barHeight,
                        color: colorFor(e.key),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Tooltip(
              message: l10n.insPrevDay,
              child: IconButton(
                icon: const Icon(FluentIcons.chevron_left, size: 12),
                onPressed: onPrev,
              ),
            ),
            Expanded(
              child: Text(
                AppDateFormat.weekdayFullWithDate(timeline.day),
                textAlign: TextAlign.center,
                style: theme.typography.bodyStrong,
              ),
            ),
            Tooltip(
              message: l10n.insNextDay,
              child: IconButton(
                icon: const Icon(FluentIcons.chevron_right, size: 12),
                onPressed: canGoNext ? onNext : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (timeline.isEmpty && timeline.unplacedSeconds < 60)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(l10n.insTimelineEmpty, style: theme.typography.caption),
            ),
          )
        else if (timeline.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              l10n.insTimelineUnplaced(
                  Duration(seconds: timeline.unplacedSeconds).toHourMinuteFormat()),
              style: theme.typography.caption,
            ),
          )
        else ...[
          SizedBox(
            height: barHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [for (var h = 0; h < 24; h++) hourBar(h)],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final h in [0, 6, 12, 18, 23])
                Expanded(
                  flex: h == 23 ? 1 : 6,
                  child: Text('${h.toString().padLeft(2, '0')}:00',
                      style: theme.typography.caption),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              for (final a in timeline.topApps)
                _LegendDot(
                  color: colorFor(a.appId),
                  label:
                      '${a.name} · ${Duration(seconds: a.seconds).toHourMinuteFormat()}',
                ),
              if (timeline.hours.any((h) => h.containsKey(DayTimeline.otherKey)))
                _LegendDot(
                  color: colorFor(DayTimeline.otherKey),
                  label: l10n.insTimelineOther,
                ),
            ],
          ),
          if (timeline.unplacedSeconds >= 60)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.insTimelineUnplaced(
                    Duration(seconds: timeline.unplacedSeconds).toHourMinuteFormat()),
                style: theme.typography.caption,
              ),
            ),
        ],
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: FluentTheme.of(context).typography.caption),
      ],
    );
  }
}

// ─── Title search ──────────────────────────────────────────────────────────

class _SearchBody extends StatelessWidget {
  final TextEditingController controller;
  final List<TitleHit> hits;
  final bool hasTitles;
  final ValueChanged<String> onChanged;
  const _SearchBody({
    required this.controller,
    required this.hits,
    required this.hasTitles,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hasTitles)
          Text(l10n.insSearchDisabled, style: theme.typography.caption)
        else ...[
          TextBox(
            controller: controller,
            placeholder: l10n.insSearchHint,
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(FluentIcons.search, size: 12),
            ),
            onChanged: onChanged,
          ),
          const SizedBox(height: 8),
          if (controller.text.trim().isNotEmpty && hits.isEmpty)
            Text(l10n.insSearchNoResults, style: theme.typography.caption),
          for (final h in hits)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(h.title, overflow: TextOverflow.ellipsis),
                        Text(
                          '${h.appName} · ${AppDateFormat.weekdayWithDate(h.lastSeen)}',
                          style: theme.typography.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(Duration(seconds: h.seconds).toHourMinuteFormat(),
                      style: theme.typography.caption),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
