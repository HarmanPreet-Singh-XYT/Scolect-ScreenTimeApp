part of 'insights_view.dart';

// Long-range insights built from [HistoryInsights]: highlights, activity
// pattern, streaks and records, focus split, habits, app trends, tracked vs
// logged time, device split and most-used windows.

/// Monday 2024-01-01, so weekday names can be formatted from an index.
DateTime _weekdayDate(int index) => DateTime(2024, 1, 1 + index);

String _hourLabel(BuildContext context, int hour) =>
    DateFormat.j(Localizations.localeOf(context).toString())
        .format(DateTime(2000, 1, 1, hour));

String _timeOfDay(BuildContext context, DateTime t) =>
    DateFormat.jm(Localizations.localeOf(context).toString()).format(t);

String _secs(int s) => Duration(seconds: s).toHourMinuteFormat();

Color _mutedOf(FluentThemeData theme) =>
    (theme.typography.caption?.color ?? Colors.grey).withValues(alpha: 0.7);

Color _trackOf(FluentThemeData theme) => theme.brightness == Brightness.dark
    ? Colors.grey[160].withValues(alpha: 0.3)
    : Colors.grey[40];

Color _tileFill(FluentThemeData theme) => theme.brightness == Brightness.dark
    ? theme.inactiveBackgroundColor.withValues(alpha: 0.15)
    : theme.resources.subtleFillColorTertiary;

/// A small label/value block used across the extra cards.
class _Fact extends StatelessWidget {
  final String label;
  final String value;
  final String? note;
  final Color? color;
  final Widget? trailing;
  const _Fact({
    required this.label,
    required this.value,
    this.note,
    this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _tileFill(theme),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.caption?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _mutedOf(theme),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.bodyStrong?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 2),
            Text(
              note!,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.caption?.copyWith(
                fontSize: 10.5,
                color: _mutedOf(theme),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Lays [children] out in equal columns, wrapping to rows of [columns].
class _FactGrid extends StatelessWidget {
  final List<Widget> children;
  final int columns;
  const _FactGrid({required this.children, this.columns = 2});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i += columns) ...[
          if (i > 0) const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = i; j < math.min(i + columns, children.length); j++) ...[
                  if (j > i) const SizedBox(width: 8),
                  Expanded(child: children[j]),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// A change chip for second counts, with the arrow pointing the same way as
/// the number. [upIsGood] flips the colors (e.g. productive time rising).
class _SecondsDelta extends StatelessWidget {
  final int delta;
  final bool upIsGood;

  /// For changes that are neither good nor bad (e.g. average session length).
  final bool neutral;
  const _SecondsDelta({
    required this.delta,
    this.upIsGood = true,
    this.neutral = false,
  });

  @override
  Widget build(BuildContext context) {
    if (delta == 0) return const SizedBox.shrink();
    final up = delta > 0;
    final good = up == upIsGood;
    final color = neutral ? (FluentTheme.of(context).typography.caption?.color ?? Colors.grey) : (good ? _success(context) : _warning(context));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(up ? FluentIcons.sort_up : FluentIcons.sort_down, size: 9, color: color),
          const SizedBox(width: 3),
          Text(
            '${up ? '+' : '−'}${_secs(delta.abs())}',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

/// Change in a plain rate such as opens per hour; fewer is calmer.
class _OpensDelta extends StatelessWidget {
  final double current;
  final double previous;
  const _OpensDelta({required this.current, required this.previous});

  @override
  Widget build(BuildContext context) {
    final d = current - previous;
    if (d.abs() < 0.05) return const SizedBox.shrink();
    final up = d > 0;
    final color = up ? _warning(context) : _success(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(up ? FluentIcons.sort_up : FluentIcons.sort_down, size: 9, color: color),
          const SizedBox(width: 3),
          Text(
            '${up ? '+' : '−'}${d.abs().toStringAsFixed(1)}',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Highlights ────────────────────────────────────────────────────────────

class _Highlight {
  final IconData icon;
  final Color color;
  final String text;
  const _Highlight(this.icon, this.color, this.text);
}

List<_Highlight> _buildHighlights(
  BuildContext context,
  AppLocalizations l10n,
  WeekComparison week,
  HistoryInsights h,
) {
  final out = <_Highlight>[];

  if (week.previous > Duration.zero && week.current != week.previous) {
    final pct = (week.delta.inSeconds.abs() / week.previous.inSeconds * 100).round();
    final up = !week.delta.isNegative;
    if (pct > 0) {
      out.add(_Highlight(
        up ? FluentIcons.trending12 : FluentIcons.chart_y_angle,
        up ? _success(context) : _warning(context),
        up ? l10n.insHlWeekUp(pct) : l10n.insHlWeekDown(pct),
      ));
    }
    if (week.movers.isNotEmpty) {
      final m = week.movers.first;
      out.add(_Highlight(
        FluentIcons.stock_up,
        _primary(context),
        l10n.insHlDriver(m.name, _signed(m.delta)),
      ));
    }
  }

  if (h.currentStreak >= 2) {
    out.add(_Highlight(
      FluentIcons.flame_solid,
      _warning(context),
      h.goal != null
          ? l10n.insHlStreakGoal(h.currentStreak)
          : l10n.insHlStreakActive(h.currentStreak),
    ));
  }

  final peak = h.peakHour;
  if (peak != null) {
    out.add(_Highlight(FluentIcons.clock, _secondary(context),
        l10n.insHlPeak(_hourLabel(context, peak))));
  }
  final wd = h.busiestWeekday;
  if (wd != null) {
    out.add(_Highlight(FluentIcons.calendar_day, _secondary(context),
        l10n.insHlWeekday(AppDateFormat.weekdayFull(_weekdayDate(wd)))));
  }

  final prodTotal = h.productive.current + h.other.current;
  if (prodTotal > 0) {
    out.add(_Highlight(FluentIcons.skype_circle_check, _success(context),
        l10n.insHlFocus((h.productive.current / prodTotal * 100).round())));
  }
  if (h.lateNight.current >= 15 * 60) {
    out.add(_Highlight(
        FluentIcons.clear_night, _primary(context), l10n.insHlLate(_secs(h.lateNight.current))));
  }
  return out;
}

class _HighlightsBody extends StatelessWidget {
  final List<_Highlight> items;
  const _HighlightsBody({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final h in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: h.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: h.color.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(h.icon, size: 13, color: h.color),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    h.text,
                    style: theme.typography.body?.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Activity pattern (weekday x hour) ─────────────────────────────────────

class _PatternBody extends StatelessWidget {
  final HistoryInsights history;
  const _PatternBody({required this.history});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final muted = _mutedOf(theme);

    if (!history.hasHourly) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text(l10n.insNoData, style: theme.typography.caption)),
      );
    }

    var maxCell = 1;
    for (final d in history.weekdayHour) {
      for (final v in d) {
        if (v > maxCell) maxCell = v;
      }
    }
    final peak = history.peakHour;
    final wd = history.busiestWeekday;
    var peakDay = 0;
    if (peak != null) {
      for (var d = 1; d < 7; d++) {
        if (history.weekdayHour[d][peak] > history.weekdayHour[peakDay][peak]) {
          peakDay = d;
        }
      }
    }

    Widget cell(int day, int hour) {
      final v = history.weekdayHour[day][hour];
      final level = v == 0 ? 0.0 : (v / maxCell).clamp(0.12, 1.0);
      return Expanded(
        child: Tooltip(
          message:
              '${AppDateFormat.weekdayFull(_weekdayDate(day))} ${_hourLabel(context, hour)} · ${_secs(v ~/ math.max(1, history.weekdayCount[day]))}',
          child: Container(
            height: 18,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: level == 0
                  ? _trackOf(theme).withValues(alpha: 0.5)
                  : _secondary(context).withValues(alpha: 0.12 + level * 0.88),
              borderRadius: BorderRadius.circular(3),
              border: peak == hour && peakDay == day
                  ? Border.all(color: theme.typography.body?.color ?? Colors.white, width: 1.4)
                  : null,
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
            const SizedBox(width: 38),
            for (var h = 0; h < 24; h++)
              Expanded(
                child: h % 6 == 0
                    ? Text(
                        _hourLabel(context, h),
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: TextStyle(fontSize: 10, color: muted),
                      )
                    : const SizedBox(),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (var d = 0; d < 7; d++)
          Row(
            children: [
              SizedBox(
                width: 38,
                child: Text(
                  AppDateFormat.weekdayShort(_weekdayDate(d)),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: d == wd ? FontWeight.w800 : FontWeight.w500,
                    color: d == wd ? _secondary(context) : muted,
                  ),
                ),
              ),
              for (var h = 0; h < 24; h++) cell(d, h),
            ],
          ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(l10n.insLess, style: TextStyle(fontSize: 10, color: muted)),
            const SizedBox(width: 6),
            for (final a in const [0.12, 0.36, 0.6, 0.8, 1.0])
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: 3),
                decoration: BoxDecoration(
                  color: _secondary(context).withValues(alpha: a),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            const SizedBox(width: 3),
            Text(l10n.insMore, style: TextStyle(fontSize: 10, color: muted)),
          ],
        ),
        const SizedBox(height: 12),
        _FactGrid(
          columns: 2,
          children: [
            if (peak != null)
              _Fact(
                label: l10n.insPeakHour,
                value: _hourLabel(context, peak),
                color: _secondary(context),
              ),
            if (wd != null)
              _Fact(
                label: l10n.insBusiestWeekday,
                value: AppDateFormat.weekdayFull(_weekdayDate(wd)),
                note: l10n.insAvgPerDay(_secs(history.weekdayAverage(wd).round())),
                color: _secondary(context),
              ),
          ],
        ),
      ],
    );
  }
}

// ─── Streaks and records ───────────────────────────────────────────────────

class _RecordsBody extends StatelessWidget {
  final HistoryInsights history;
  final List<Duration> lastWeekDays; // oldest first, 7 entries
  const _RecordsBody({required this.history, required this.lastWeekDays});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final goal = history.goal;
    final b = history.busiestDay;
    final l = history.lightestDay;
    final w = history.busiestWeek;

    final hit = goal == null
        ? 0
        : lastWeekDays.where((d) => d > Duration.zero && d <= goal).length;
    final tracked = lastWeekDays.where((d) => d > Duration.zero).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FactGrid(
          children: [
            _Fact(
              label: l10n.insCurrentStreak,
              value: l10n.insDaysCount(history.currentStreak),
              color: _warning(context),
            ),
            _Fact(
              label: l10n.insLongestStreak,
              value: l10n.insDaysCount(history.longestStreak),
            ),
            if (b != null)
              _Fact(
                label: l10n.insBusiestDay,
                value: b.value.toHourMinuteFormat(),
                note: AppDateFormat.weekdayWithDate(b.key),
              ),
            if (l != null)
              _Fact(
                label: l10n.insLightestDay,
                value: l.value.toHourMinuteFormat(),
                note: AppDateFormat.weekdayWithDate(l.key),
              ),
            if (w != null)
              _Fact(
                label: l10n.insBusiestWeek,
                value: w.value.toHourMinuteFormat(),
                note:
                    '${AppDateFormat.dayMonth(w.key)} – ${AppDateFormat.dayMonth(w.key.add(const Duration(days: 6)))}',
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (history.longestStreak > 0) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 8,
              color: _trackOf(theme),
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor:
                    (history.currentStreak / history.longestStreak).clamp(0.02, 1.0),
                child: Container(color: _warning(context)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            history.currentStreak >= history.longestStreak
                ? l10n.insStreakAtRecord
                : l10n.insStreakToRecord(
                    history.longestStreak - history.currentStreak + 1),
            style: theme.typography.caption?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
        ],
        if (goal != null) ...[
          Row(
            children: [
              for (final d in lastWeekDays)
                Expanded(
                  child: Container(
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: d <= Duration.zero
                          ? _trackOf(theme)
                          : (d <= goal ? _success(context) : _warning(context)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.insGoalProgress(hit, tracked),
              style: theme.typography.caption?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(l10n.insStreakGoalNote(goal.toHourMinuteFormat()),
              style: theme.typography.caption?.copyWith(
                fontSize: 10.5,
                color: _mutedOf(theme),
              )),
        ] else
          Text(l10n.insStreakActiveNote,
              style: theme.typography.caption?.copyWith(
                fontSize: 10.5,
                color: _mutedOf(theme),
              )),
      ],
    );
  }
}

// ─── Focus vs everything else + late night ─────────────────────────────────

class _FocusBody extends StatelessWidget {
  final HistoryInsights history;
  const _FocusBody({required this.history});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final p = history.productive;
    final o = history.other;
    final total = p.current + o.current;

    if (total == 0 && p.previous + o.previous == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text(l10n.insNoData, style: theme.typography.caption)),
      );
    }

    Widget legend(Color c, String label, int secs, WeekPair pair, bool upIsGood) => Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: theme.typography.body
                      ?.copyWith(fontWeight: FontWeight.w600, fontSize: 12.5)),
            ),
            Text(_secs(secs),
                style: theme.typography.caption?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            _SecondsDelta(delta: pair.delta, upIsGood: upIsGood),
          ],
        );

    final share = total == 0 ? 0 : (p.current / total * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.insFocusShare(share),
          style: theme.typography.title?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _success(context),
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                if (p.current > 0)
                  Expanded(flex: p.current, child: Container(color: _success(context))),
                if (o.current > 0)
                  Expanded(flex: o.current, child: Container(color: _trackOf(theme))),
                if (total == 0) Expanded(child: Container(color: _trackOf(theme))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        legend(_success(context), l10n.insProductive, p.current, p, true),
        const SizedBox(height: 8),
        legend(
          theme.brightness == Brightness.dark ? Colors.grey[120] : Colors.grey[90],
          l10n.insOtherApps,
          o.current,
          o,
          false,
        ),
      ],
    );
  }
}

// ─── Usage habits ──────────────────────────────────────────────────────────

class _HabitsBody extends StatelessWidget {
  final HistoryInsights history;
  final LongestBlock? longest;
  const _HabitsBody({required this.history, required this.longest});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final o = history.opens;
    final span = history.activeSeconds;

    String avgSession(int secs, int opens) =>
        opens == 0 ? '–' : _secs(secs ~/ opens);
    String perHour(int secs, int opens) =>
        secs == 0 ? '–' : (opens * 3600 / secs).toStringAsFixed(1);

    final rows = <Widget>[
      _Fact(
        label: l10n.insAvgSession,
        value: avgSession(span.current, o.current),
        color: _primary(context),
        trailing: o.current > 0 && o.previous > 0
            ? _SecondsDelta(
                delta: span.current ~/ o.current - span.previous ~/ o.previous,
                neutral: true,
              )
            : null,
      ),
      _Fact(
        label: l10n.insOpensPerHour,
        value: perHour(span.current, o.current),
        note: l10n.insVsLastWeek,
        color: _primary(context),
        trailing: span.current > 0 && span.previous > 0
            ? _OpensDelta(
                current: o.current * 3600 / span.current,
                previous: o.previous * 3600 / span.previous,
              )
            : null,
      ),
      if (longest != null)
        _Fact(
          label: l10n.insLongestBlock,
          value: l10n.insLongestBlockValue(_secs(longest!.seconds), longest!.appName),
          note: AppDateFormat.weekdayWithDate(longest!.day),
        ),
      _Fact(
        label: l10n.insLateNight,
        value: _secs(history.lateNight.current),
        note: l10n.insVsLastWeek,
        trailing: _SecondsDelta(delta: history.lateNight.delta, upIsGood: false),
      ),
    ];

    if (o.current + o.previous == 0 && history.lateNight.current == 0 && longest == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text(l10n.insNoData, style: theme.typography.caption)),
      );
    }
    return _FactGrid(children: rows);
  }
}

// ─── Top apps over four weeks ──────────────────────────────────────────────

class _AppTrendsBody extends StatelessWidget {
  final List<AppTrend> trends;
  const _AppTrendsBody({required this.trends});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    var maxWeek = 1;
    for (final t in trends) {
      for (final v in t.weeklySeconds) {
        if (v > maxWeek) maxWeek = v;
      }
    }

    Widget spark(AppTrend t, Color color) => SizedBox(
          height: 30,
          width: 96,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < t.weeklySeconds.length; i++)
                Expanded(
                  child: Tooltip(
                    message: i == t.weeklySeconds.length - 1
                        ? '${l10n.insThisWeek}: ${_secs(t.weeklySeconds[i])}'
                        : '${l10n.insWeeksAgo(t.weeklySeconds.length - 1 - i)}: ${_secs(t.weeklySeconds[i])}',
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: math.max(3.0, t.weeklySeconds[i] / maxWeek * 30),
                      decoration: BoxDecoration(
                        color: i == t.weeklySeconds.length - 1
                            ? color
                            : color.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );

    final muted = _mutedOf(theme);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              const SizedBox(width: 18),
              const Spacer(),
              SizedBox(
                width: 96,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.insWeeksAgo(3), style: TextStyle(fontSize: 9.5, color: muted)),
                    Text(l10n.insNow, style: TextStyle(fontSize: 9.5, color: muted)),
                  ],
                ),
              ),
              const SizedBox(width: 10 + 62 + 8 + 74),
            ],
          ),
        ),
        for (var i = 0; i < trends.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _palette[i % _palette.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    trends[i].name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 12.5),
                  ),
                ),
                const SizedBox(width: 10),
                spark(trends[i], _palette[i % _palette.length]),
                const SizedBox(width: 10),
                SizedBox(
                  width: 62,
                  child: Text(
                    _secs(trends[i].weeklySeconds.last),
                    textAlign: TextAlign.end,
                    style: theme.typography.caption?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 74,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _SecondsDelta(
                      delta: trends[i].weeklySeconds.last -
                          trends[i].weeklySeconds[trends[i].weeklySeconds.length - 2],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Tracked vs logged ─────────────────────────────────────────────────────

class _TrackedVsLoggedBody extends StatelessWidget {
  final Duration tracked; // last 7 days of app time
  final List<ManualEntry> entries; // last 7 days
  const _TrackedVsLoggedBody({required this.tracked, required this.entries});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final logged = entries.fold<int>(0, (s, e) => s + e.seconds);

    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text(l10n.insNothingLogged, style: theme.typography.caption)),
      );
    }

    final perLabel = <String, int>{};
    for (final e in entries) {
      perLabel[e.label] = (perLabel[e.label] ?? 0) + e.seconds;
    }
    final top = perLabel.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = tracked.inSeconds + logged;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                if (tracked.inSeconds > 0)
                  Expanded(flex: tracked.inSeconds, child: Container(color: _primary(context))),
                if (logged > 0)
                  Expanded(
                      flex: logged,
                      child: Container(color: _secondary(context))),
                if (total == 0) Expanded(child: Container(color: _trackOf(theme))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _FactGrid(children: [
          _Fact(label: l10n.insTracked, value: tracked.toHourMinuteFormat(), color: _primary(context)),
          _Fact(label: l10n.insLogged, value: _secs(logged), color: _secondary(context)),
        ]),
        const SizedBox(height: 10),
        for (final e in top.take(3))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: Text(e.key,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body?.copyWith(fontSize: 12.5)),
                ),
                Text(_secs(e.value),
                    style: theme.typography.caption?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Devices ───────────────────────────────────────────────────────────────

class _DevicesBody extends StatelessWidget {
  final List<DeviceShare> shares;
  const _DevicesBody({required this.shares});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final max = shares.fold<int>(1, (m, d) => d.seconds > m ? d.seconds : m);
    return Column(
      children: [
        for (final d in shares)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(d.isThisDevice ? FluentIcons.devices2 : FluentIcons.cloud,
                        size: 12, color: _mutedOf(theme)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        d.isThisDevice ? l10n.insThisDevice : d.name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body
                            ?.copyWith(fontWeight: FontWeight.w600, fontSize: 12.5),
                      ),
                    ),
                    Text(_secs(d.seconds),
                        style: theme.typography.caption?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Container(
                    height: 6,
                    color: _trackOf(theme),
                    alignment: AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      widthFactor: (d.seconds / max).clamp(0.02, 1.0),
                      child: Container(
                          color: d.isThisDevice ? _primary(context) : _secondary(context)),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Most-used windows ─────────────────────────────────────────────────────

class _TopWindowsBody extends StatelessWidget {
  final List<TitleHit> hits;
  const _TopWindowsBody({required this.hits});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final max = hits.fold<int>(1, (m, h) => h.seconds > m ? h.seconds : m);
    return Column(
      children: [
        for (final h in hits)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        h.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body
                            ?.copyWith(fontWeight: FontWeight.w600, fontSize: 12.5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(h.appName,
                        style: theme.typography.caption
                            ?.copyWith(fontSize: 10.5, color: _mutedOf(theme))),
                    const SizedBox(width: 10),
                    Text(_secs(h.seconds),
                        style: theme.typography.caption?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Container(
                    height: 4,
                    color: _trackOf(theme),
                    alignment: AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      widthFactor: (h.seconds / max).clamp(0.02, 1.0),
                      child: Container(color: theme.accentColor.normal),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── First / last app of the day ───────────────────────────────────────────

class _BookendsRow extends StatelessWidget {
  final DayBookends bookends;
  const _BookendsRow({required this.bookends});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _FactGrid(children: [
      _Fact(
        label: l10n.insFirstApp,
        value: bookends.firstApp,
        note: _timeOfDay(context, bookends.firstAt),
        color: _success(context),
      ),
      _Fact(
        label: l10n.insLastApp,
        value: bookends.lastApp,
        note: _timeOfDay(context, bookends.lastAt),
        color: _success(context),
      ),
    ]);
  }
}
