import 'dart:async';
import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:screentime/app_design.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/data_controllers/applications_data_controller.dart'
    show DurationFormatter;
import 'package:screentime/sections/controller/data_controllers/insights_data.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/sections/widgets/Reports/insights/pill_toggle.dart';
import 'package:screentime/sections/widgets/Reports/insights/time_log_card.dart';
import 'package:screentime/utils/date_formats.dart';
import 'package:screentime/utils/device_sync.dart';
import 'package:screentime/utils/manual_log.dart';

part 'insights_extras.dart';

const int kHeatmapWeeks = 26;

/// Desktop analytics dashboard: hero highlights, 26-week activity heatmap,
/// week-over-week trends, 24-hour day timeline, time tracking & window search.
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
  Map<DateTime, Duration> _daily = const {};
  HistoryInsights _history = HistoryInsights.fromDaily(const {});
  LongestBlock? _longest;
  DayBookends? _bookends;
  List<TitleHit> _topTitles = const [];
  List<DeviceShare> _devices = const [];
  late DayTimeline _timeline;
  final TextEditingController _query = TextEditingController();
  List<TitleHit> _hits = const [];
  late bool _hasTitles;

  // The store scans are synchronous, so computing them in initState froze the
  // tab switch. Paint a first frame, then load in two yielded stages: the cheap
  // week/timeline numbers, then the 26-week history (the expensive one).
  bool _ready = false;
  bool _dailyReady = false;

  @override
  void initState() {
    super.initState();
    DeviceSync.instance.addListener(_onPeersChanged);
    ManualLog.instance.addListener(_onManualLogChanged);
    // Don't make the user wait for the next timer tick to see other devices.
    unawaited(DeviceSync.instance.refreshIfStale());
    unawaited(_initialLoad());
  }

  /// The overall daily limit from Alerts and Limits, if the user turned it on.
  /// Keys mirror `_Keys` in alerts_limits.dart.
  Duration? _overallGoal() {
    try {
      final settings = SettingsManager();
      if (settings.getSetting('limitsAlerts.overallLimit.enabled') != true) {
        return null;
      }
      final h = (settings.getSetting('limitsAlerts.overallLimit.hours') as num?) ?? 0;
      final m = (settings.getSetting('limitsAlerts.overallLimit.minutes') as num?) ?? 0;
      final goal = Duration(minutes: (h * 60 + m).round());
      return goal > Duration.zero ? goal : null;
    } catch (_) {
      return null;
    }
  }

  /// Everything that comes from the long scan plus the small follow-up reads.
  void _loadHistory() {
    _history = _data.history(kHeatmapWeeks * 7, goal: _overallGoal());
    _daily = _history.daily;
    _longest = _data.longestBlock();
    _topTitles = _data.topTitles();
    _devices = _data.hasPeers ? _data.deviceSplit() : const [];
    _bookends = _data.dayBookends(_day);
  }

  Future<void> _initialLoad() async {
    await Future<void>.delayed(Duration.zero); // let the first frame paint
    if (!mounted) return;
    final week = _data.compareWeeks();
    final timeline = _data.dayTimeline(_day);
    final hasTitles = _data.hasAnyTitles();
    setState(() {
      _week = week;
      _timeline = timeline;
      _hasTitles = hasTitles;
      _ready = true;
    });
    await Future<void>.delayed(Duration.zero); // paint before the heavy scan
    if (!mounted) return;
    setState(() {
      _loadHistory();
      _dailyReady = true;
    });
  }

  void _onPeersChanged() {
    if (!mounted) return;
    if (!_data.hasPeers && _data.allDevices) _data.allDevices = false;
    _reload();
  }

  void _onManualLogChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    DeviceSync.instance.removeListener(_onPeersChanged);
    ManualLog.instance.removeListener(_onManualLogChanged);
    _query.dispose();
    super.dispose();
  }

  /// Recomputes everything, e.g. after switching between this device and all.
  void _reload() {
    if (!_ready) return; // the initial load will pick up the new mode
    setState(() {
      _dailyReady = true;
      _week = _data.compareWeeks();
      _timeline = _data.dayTimeline(_day);
      _loadHistory();
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
      _bookends = _data.dayBookends(clamped);
    });
  }

  void _search(String text) =>
      setState(() => _hits = _data.searchTitles(text));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_ready) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 96),
        child: Center(child: ProgressRing()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1050;

        // Two cards side by side when wide, stacked otherwise. A null side
        // lets the other take the full row. Includes the trailing gap.
        Widget pair(Widget? first, Widget? second) {
          final a = first ?? second;
          final b = first == null ? null : second;
          if (a == null) return const SizedBox.shrink();
          if (b == null) {
            return Padding(padding: const EdgeInsets.only(bottom: 16), child: a);
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: a),
                      const SizedBox(width: 16),
                      Expanded(child: b),
                    ],
                  )
                : Column(children: [a, const SizedBox(height: 16), b]),
          );
        }

        final today = _data.today;
        final lastWeekDays = [
          for (var i = 6; i >= 0; i--)
            _daily[today.subtract(Duration(days: i))] ?? Duration.zero,
        ];
        final weekStart = today.subtract(const Duration(days: 6));
        final weekEntries = ManualLog.instance.entries
            .where((e) => !e.start.isBefore(weekStart))
            .toList();
        final highlights = _dailyReady
            ? _buildHighlights(context, l10n, _week, _history)
            : const <_Highlight>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sync Device Selector (when peers exist)
            if (_data.hasPeers) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: PillToggle(
                  options: [
                    PillOption(
                      selected: !_data.allDevices,
                      icon: FluentIcons.devices2,
                      label: l10n.insThisDevice,
                      onTap: () => _setAllDevices(false),
                    ),
                    PillOption(
                      selected: _data.allDevices,
                      icon: FluentIcons.cloud,
                      label: l10n.insAllDevices,
                      onTap: () => _setAllDevices(true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Top Hero Highlights Ribbon
            _HeroHighlights(
              week: _week,
              daily: _daily,
              dailyReady: _dailyReady,
              day: _day,
              timeline: _timeline,
            ),
            const SizedBox(height: 16),

            // Plain-language summary built from the numbers below
            if (_dailyReady && highlights.isNotEmpty) ...[
              _Card(
                title: l10n.insHighlightsTitle,
                icon: FluentIcons.lightbulb,
                accentColor: _warning(context),
                child: _HighlightsBody(items: highlights),
              ),
              const SizedBox(height: 16),
            ],

            // 26-Week Activity Heatmap (Full Width)
            _Card(
              title: l10n.insHeatmapTitle,
              icon: FluentIcons.calendar,
              accentColor: _success(context),
              trailing: _dailyReady ? _buildHeatmapSummaryBadge(context) : null,
              child: _dailyReady
                  ? ActivityHeatmap(
                      totals: _daily,
                      selected: _day,
                      onSelect: _selectDay,
                    )
                  : const SizedBox(
                      height: 160,
                      child: Center(child: ProgressRing()),
                    ),
            ),
            const SizedBox(height: 16),

            pair(
              _Card(
                title: l10n.insTrendsTitle,
                icon: FluentIcons.trending12,
                accentColor: _primary(context),
                child: _TrendsBody(week: _week),
              ),
              _Card(
                title: l10n.insTimelineTitle,
                icon: FluentIcons.timeline_delivery,
                accentColor: _warning(context),
                child: _TimelineBody(
                  timeline: _timeline,
                  bookends: _bookends,
                  canGoNext: _day.isBefore(_data.today),
                  onPrev: () => _selectDay(_day.subtract(const Duration(days: 1))),
                  onNext: () => _selectDay(_day.add(const Duration(days: 1))),
                ),
              ),
            ),

            if (_dailyReady) ...[
              // When you are most active (weekday x hour)
              if (_history.hasHourly) ...[
                _Card(
                  title: l10n.insPatternTitle,
                  icon: FluentIcons.clock,
                  accentColor: _secondary(context),
                  child: _PatternBody(history: _history),
                ),
                const SizedBox(height: 16),
              ],

              pair(
                _Card(
                  title: l10n.insRecordsTitle,
                  icon: FluentIcons.trophy,
                  accentColor: _warning(context),
                  child: _RecordsBody(history: _history, lastWeekDays: lastWeekDays),
                ),
                _history.hasFocusData
                    ? _Card(
                        title: l10n.insFocusTitle,
                        icon: FluentIcons.skype_circle_check,
                        accentColor: _success(context),
                        child: _FocusBody(history: _history),
                      )
                    : null,
              ),

              pair(
                _history.hasHabitsData || _longest != null
                    ? _Card(
                        title: l10n.insHabitsTitle,
                        icon: FluentIcons.repeat_all,
                        accentColor: _primary(context),
                        child: _HabitsBody(history: _history, longest: _longest),
                      )
                    : null,
                _history.trends.isEmpty
                    ? null
                    : _Card(
                        title: l10n.insAppTrendsTitle,
                        icon: FluentIcons.bar_chart_vertical,
                        accentColor: _secondary(context),
                        child: _AppTrendsBody(trends: _history.trends),
                      ),
              ),

              pair(
                _Card(
                  title: l10n.insTrackedVsLoggedTitle,
                  icon: FluentIcons.stopwatch,
                  accentColor: _primary(context),
                  child: _TrackedVsLoggedBody(
                    tracked: lastWeekDays.fold(Duration.zero, (a, d) => a + d),
                    entries: weekEntries,
                  ),
                ),
                _devices.length > 1
                    ? _Card(
                        title: l10n.insDevicesTitle,
                        icon: FluentIcons.devices2,
                        accentColor: _primary(context),
                        child: _DevicesBody(shares: _devices),
                      )
                    : (_topTitles.isEmpty
                        ? null
                        : _Card(
                            title: l10n.insTopWindowsTitle,
                            icon: FluentIcons.tab_center,
                            accentColor: _secondary(context),
                            child: _TopWindowsBody(hits: _topTitles),
                          )),
              ),

              if (_devices.length > 1 && _topTitles.isNotEmpty) ...[
                _Card(
                  title: l10n.insTopWindowsTitle,
                  icon: FluentIcons.tab_center,
                  accentColor: _secondary(context),
                  child: _TopWindowsBody(hits: _topTitles),
                ),
                const SizedBox(height: 16),
              ],
            ],

            // Manual time log + window title search
            pair(
              _Card(
                title: l10n.tlTitle,
                icon: FluentIcons.stopwatch,
                accentColor: _primary(context),
                child: const TimeLogCard(),
              ),
              _Card(
                title: l10n.insSearchTitle,
                icon: FluentIcons.search,
                accentColor: _secondary(context),
                child: _SearchBody(
                  controller: _query,
                  hits: _hits,
                  hasTitles: _hasTitles,
                  onChanged: _search,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeatmapSummaryBadge(BuildContext context) {
    final activeDays = _daily.values.where((d) => d > Duration.zero).length;
    final totalDuration = _daily.values.fold<Duration>(
      Duration.zero,
      (acc, d) => acc + d,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _success(context).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FluentIcons.check_mark, size: 10, color: _success(context)),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context)!.insActiveDaysSummary(
              activeDays,
              totalDuration.toHourMinuteFormat(),
            ),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _success(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card Container ────────────────────────────────────────────────────────

class _Card extends StatefulWidget {
  final String title;
  final IconData? icon;
  final Color? accentColor;
  final Widget? trailing;
  final Widget child;

  const _Card({
    required this.title,
    this.icon,
    this.accentColor,
    this.trailing,
    required this.child,
  });

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = widget.accentColor ?? theme.accentColor.normal;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surface(theme),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered
                ? accent.withValues(alpha: 0.45)
                : theme.resources.cardStrokeColorDefault,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (widget.icon != null) ...[
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(widget.icon, size: 14, color: accent),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          widget.title,
                          style: theme.typography.bodyStrong?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
            const SizedBox(height: 18),
            widget.child,
          ],
        ),
      ),
    );
  }
}

String _signed(Duration d) {
  final sign = d.isNegative ? '−' : '+';
  return '$sign${d.abs().toHourMinuteFormat()}';
}

// ─── Hero Highlights Banner ────────────────────────────────────────────────

class _HeroHighlights extends StatelessWidget {
  final WeekComparison week;
  final Map<DateTime, Duration> daily;
  final bool dailyReady;
  final DateTime day;
  final DayTimeline timeline;

  const _HeroHighlights({
    required this.week,
    required this.daily,
    required this.dailyReady,
    required this.day,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final log = ManualLog.instance;
    final running = log.running;
    final now = DateTime.now();
    final todayManual = log.forDay(now).fold<Duration>(
          Duration.zero,
          (acc, e) => acc + e.duration,
        );

    // Active days count & daily average
    final activeDays = daily.values.where((d) => d > Duration.zero).toList();
    final totalSecs = activeDays.fold<int>(0, (acc, d) => acc + d.inSeconds);
    final avgDaily = activeDays.isEmpty
        ? Duration.zero
        : Duration(seconds: totalSecs ~/ activeDays.length);

    final selectedDayDuration = Duration(seconds: timeline.totalSeconds);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;
        final isNarrow = constraints.maxWidth < 500;

        final columns = isNarrow ? 1 : (isCompact ? 2 : 4);
        final tiles = <Widget>[
            // Card 1: This Week vs Last Week
            _StatTile(
              label: l10n.insThisWeek,
              value: week.current.toHourMinuteFormat(),
              subtitle: l10n.insLastWeekValue(week.previous.toHourMinuteFormat()),
              badgeText: week.hasData ? _signed(week.delta) : null,
              isPositiveDelta: !week.delta.isNegative,
              icon: FluentIcons.calendar_week,
              accentColor: _primary(context),
            ),

            // Card 2: 26-Week Consistency
            _StatTile(
              label: l10n.insConsistency,
              value: dailyReady ? l10n.insDaysCount(activeDays.length) : '–',
              subtitle: dailyReady
                  ? l10n.insAvgPerActiveDay(avgDaily.toHourMinuteFormat())
                  : '',
              badgeText: dailyReady
                  ? '${(activeDays.length / (kHeatmapWeeks * 7) * 100).toStringAsFixed(0)}%'
                  : null,
              isPositiveDelta: true,
              icon: FluentIcons.flame_solid,
              accentColor: _success(context),
            ),

            // Card 3: Selected Day
            _StatTile(
              label: l10n.insSelectedDay,
              value: selectedDayDuration > Duration.zero
                  ? selectedDayDuration.toHourMinuteFormat()
                  : '0h 0m',
              subtitle: AppDateFormat.weekdayWithDate(day),
              badgeText: timeline.topApps.isNotEmpty
                  ? l10n.insAppsCount(timeline.topApps.length)
                  : null,
              icon: FluentIcons.timeline_delivery,
              accentColor: _warning(context),
            ),

            // Card 4: Manual Time Log status
            _StatTile(
              label: l10n.tlTitle,
              value: running != null
                  ? _clockFormat(log.runningElapsed)
                  : (todayManual > Duration.zero
                      ? todayManual.toHourMinuteFormat()
                      : l10n.insIdle),
              subtitle: running != null
                  ? running.label
                  : l10n.insTodayValue(todayManual.toHourMinuteFormat()),
              badgeText: running != null ? l10n.insLive : null,
              isPositiveDelta: running != null,
              isLive: running != null,
              icon: FluentIcons.stopwatch,
              accentColor: _primary(context),
            ),
        ];

        return Column(
          children: [
            for (var i = 0; i < tiles.length; i += columns) ...[
              if (i > 0) const SizedBox(height: 12),
              SizedBox(
                height: 92,
                child: Row(
                  children: [
                    for (var j = i; j < i + columns; j++) ...[
                      if (j > i) const SizedBox(width: 12),
                      Expanded(child: j < tiles.length ? tiles[j] : const SizedBox()),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  static String _clockFormat(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final String? badgeText;
  final bool isPositiveDelta;
  final bool isLive;
  final IconData icon;
  final Color accentColor;

  const _StatTile({
    required this.label,
    required this.value,
    required this.subtitle,
    this.badgeText,
    this.isPositiveDelta = true,
    this.isLive = false,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _surface(theme),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.resources.cardStrokeColorDefault,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.typography.caption?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  letterSpacing: 0.3,
                  color: theme.typography.caption?.color?.withValues(alpha: 0.75),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 12, color: accentColor),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: theme.typography.subtitle?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.typography.caption?.copyWith(
                        fontSize: 10,
                        color: theme.typography.caption?.color?.withValues(alpha: 0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isLive
                        ? _danger(context).withValues(alpha: 0.15)
                        : (isPositiveDelta
                            ? _success(context).withValues(alpha: 0.12)
                            : _warning(context).withValues(alpha: 0.12)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLive) ...[
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: _danger(context),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        badgeText!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isLive
                              ? _danger(context)
                              : (isPositiveDelta
                                  ? _success(context)
                                  : _warning(context)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Trends ────────────────────────────────────────────────────────────────

/// Card surface, matching the other Reports cards: mica in dark mode, white in
/// light mode.
Color _surface(FluentThemeData theme) =>
    theme.brightness == Brightness.dark ? theme.micaBackgroundColor : Colors.white;

// Semantic colors come from the user's theme so custom themes carry through.
Color _primary(BuildContext c) => AppDesign.of(c).primaryAccent;
Color _secondary(BuildContext c) => AppDesign.of(c).secondaryAccent;
Color _success(BuildContext c) => AppDesign.of(c).successColor;
Color _warning(BuildContext c) => AppDesign.of(c).warningColor;
Color _danger(BuildContext c) => AppDesign.of(c).errorColor;

class _TrendsBody extends StatelessWidget {
  final WeekComparison week;
  const _TrendsBody({required this.week});

  static Color _deltaColor(BuildContext context, Duration d) => d == Duration.zero
      ? (FluentTheme.of(context).typography.caption?.color ?? Colors.grey)
      : (d.isNegative ? _warning(context) : _success(context));

  /// "▲ +1h 20m · 12%" style chip; percent is omitted without a baseline.
  static Widget _deltaChip(BuildContext context, Duration cur, Duration prev,
      {bool large = false}) {
    final d = cur - prev;
    final color = _deltaColor(context, d);
    final pct = prev.inSeconds > 0
        ? ' · ${(d.inSeconds.abs() / prev.inSeconds * 100).round()}%'
        : '';
    final icon = d == Duration.zero
        ? FluentIcons.remove
        : (d.isNegative ? FluentIcons.sort_down : FluentIcons.sort_up);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 10 : 7, vertical: large ? 5 : 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(large ? 10 : 7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: large ? 11 : 9, color: color),
          SizedBox(width: large ? 5 : 3),
          Text(
            _signed(d),
            style: TextStyle(
              fontSize: large ? 12 : 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (pct.isNotEmpty)
            Text(
              pct,
              style: TextStyle(
                fontSize: large ? 12 : 11,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = theme.typography.caption?.color?.withValues(alpha: 0.7);
    final track = isDark ? Colors.grey[160].withValues(alpha: 0.3) : Colors.grey[40];
    final ghost = isDark ? Colors.grey[120] : Colors.grey[90];

    if (!week.hasData) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.chart, size: 28, color: theme.inactiveColor),
              const SizedBox(height: 8),
              Text(l10n.insNoData, style: theme.typography.caption),
            ],
          ),
        ),
      );
    }

    Widget bar(double fraction, Color color, {double height = 8}) => ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Container(
            height: height,
            color: track,
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: fraction.clamp(0.02, 1.0),
              child: Container(color: color),
            ),
          ),
        );

    Widget sectionTitle(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 12, color: muted),
              const SizedBox(width: 6),
              Text(
                text,
                style: theme.typography.caption?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontSize: 10.5,
                  color: muted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 1,
                  color: theme.resources.dividerStrokeColorDefault.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        );

    // This vs last week, bars scaled against the larger of the two.
    final weekMax = math.max(1, math.max(week.current.inSeconds, week.previous.inSeconds));
    Widget weekRow(String label, Duration value, Color color, {bool strong = false}) =>
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              SizedBox(
                width: 84,
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.caption?.copyWith(
                    fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
                    color: strong ? null : muted,
                  ),
                ),
              ),
              Expanded(child: bar(value.inSeconds / weekMax, color, height: 10)),
              const SizedBox(width: 10),
              SizedBox(
                width: 64,
                child: Text(
                  value.toHourMinuteFormat(),
                  textAlign: TextAlign.end,
                  style: theme.typography.caption?.copyWith(
                    fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );

    final catMax = week.categories.fold<int>(1, (m, c) {
      final v = math.max(c.current.inSeconds, c.previous.inSeconds);
      return v > m ? v : m;
    });

    Widget categoryRow(CategoryDelta c) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      c.category,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body
                          ?.copyWith(fontWeight: FontWeight.w600, fontSize: 12.5),
                    ),
                  ),
                  Text(c.current.toHourMinuteFormat(),
                      style: theme.typography.caption?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  _deltaChip(context, c.current, c.previous),
                ],
              ),
              const SizedBox(height: 5),
              // Current on top of last week's ghost bar.
              Stack(
                children: [
                  bar(c.previous.inSeconds / catMax, ghost, height: 5),
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: (c.current.inSeconds / catMax).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _primary(context),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

    Widget moverRow(AppDelta m) {
      final cur = m.current;
      final prev = m.previous;
      final d = cur - prev;
      final color = _deltaColor(context, d);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                d.isNegative ? FluentIcons.sort_down : FluentIcons.sort_up,
                size: 10,
                color: color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                m.name,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body
                    ?.copyWith(fontWeight: FontWeight.w600, fontSize: 12.5),
              ),
            ),
            Text(cur.toHourMinuteFormat(),
                style: theme.typography.caption?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            _deltaChip(context, cur, prev),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline: this week's total + change vs last week
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                week.current.toHourMinuteFormat(),
                overflow: TextOverflow.ellipsis,
                style: theme.typography.title?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _deltaChip(context, week.current, week.previous, large: true),
          ],
        ),
        weekRow(l10n.insThisWeek, week.current, _primary(context), strong: true),
        weekRow(l10n.insLastWeek, week.previous, ghost),

        if (week.categories.isNotEmpty) ...[
          sectionTitle(FluentIcons.tag, l10n.insByCategory),
          for (final c in week.categories.take(6)) categoryRow(c),
        ],

        if (week.movers.isNotEmpty) ...[
          sectionTitle(FluentIcons.stock_up, l10n.insBiggestChanges),
          for (final m in week.movers) moverRow(m),
        ],
      ],
    );
  }
}

// ─── Heatmap ───────────────────────────────────────────────────────────────

/// GitHub-style contribution calendar: 26 weeks, columns Monday through Sunday.
class ActivityHeatmap extends StatefulWidget {
  final Map<DateTime, Duration> totals;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  const ActivityHeatmap({
    super.key,
    required this.totals,
    required this.selected,
    required this.onSelect,
  });

  /// 0 = no activity, 1..4 = quartiles of the busiest day.
  static int level(Duration d, Duration max) {
    if (d <= Duration.zero || max <= Duration.zero) return 0;
    final ratio = d.inSeconds / max.inSeconds;
    if (ratio > 0.75) return 4;
    if (ratio > 0.5) return 3;
    if (ratio > 0.25) return 2;
    return 1;
  }

  @override
  State<ActivityHeatmap> createState() => _ActivityHeatmapState();
}

class _ActivityHeatmapState extends State<ActivityHeatmap> {
  static const _alphas = [0.0, 0.28, 0.52, 0.76, 1.0];
  static const double _gap = 3;
  static const double _labelWidth = 30;

  DateTime? _hovered;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final days = widget.totals.keys.toList()..sort();
    if (days.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(l10n.insNoData, style: theme.typography.caption),
        ),
      );
    }

    final last = days.last;
    final max = widget.totals.values
        .fold<Duration>(Duration.zero, (m, d) => d > m ? d : m);

    // Monday of the week containing `last`, then back 25 weeks.
    final lastMonday = last.subtract(Duration(days: last.weekday - 1));
    final firstMonday =
        lastMonday.subtract(const Duration(days: 7 * (kHeatmapWeeks - 1)));

    // Precalculate month label headers above columns
    final monthLabels = <int, String>{};
    int? lastMonth;
    for (var w = 0; w < kHeatmapWeeks; w++) {
      final mondayDate = firstMonday.add(Duration(days: w * 7));
      if (mondayDate.month != lastMonth) {
        lastMonth = mondayDate.month;
        monthLabels[w] = AppDateFormat.month(mondayDate);
      }
    }

    Widget cell(DateTime date, double size) {
      final inRange = widget.totals.containsKey(date);
      if (!inRange) return SizedBox(width: size, height: size);
      final d = widget.totals[date]!;
      final lv = ActivityHeatmap.level(d, max);
      final isSelected = date.year == widget.selected.year &&
          date.month == widget.selected.month &&
          date.day == widget.selected.day;
      final isHover = _hovered != null &&
          _hovered!.year == date.year &&
          _hovered!.month == date.month &&
          _hovered!.day == date.day;

      final baseColor = lv == 0
          ? (isDark
              ? Colors.grey[160].withValues(alpha: 0.35)
              : Colors.grey[40].withValues(alpha: 0.5))
          : theme.accentColor.withValues(alpha: _alphas[lv]);

      return Tooltip(
        message: l10n.insHeatmapTip(
          AppDateFormat.weekdayWithDate(date),
          d.toHourMinuteFormat(),
        ),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = date),
          onExit: (_) => setState(() => _hovered = null),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => widget.onSelect(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: size,
              height: size,
              transform: isHover
                  ? (Matrix4.identity()..translateByDouble(0.0, -1.5, 0.0, 1.0))
                  : Matrix4.identity(),
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(3.5),
                border: isSelected
                    ? Border.all(
                        color: theme.accentColor.normal,
                        width: 1.2,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.accentColor.withValues(alpha: 0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : (isHover
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null),
              ),
            ),
          ),
        ),
      );
    }

    Widget weekdayLabel(DateTime monday, int offset, double size) => SizedBox(
          height: size,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              AppDateFormat.weekdayShort(monday.add(Duration(days: offset))),
              style: TextStyle(
                fontSize: 10,
                color: theme.typography.caption?.color?.withValues(alpha: 0.6),
              ),
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cells grow to fill the card; below 11px we scroll instead of squash.
        LayoutBuilder(
          builder: (context, constraints) {
            final fit = (constraints.maxWidth - _labelWidth) / kHeatmapWeeks - _gap;
            final size = fit.clamp(11.0, 22.0);

            final matrix = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mon / Wed / Fri labels
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: _labelWidth,
                    child: Column(
                      children: [
                        for (var d = 0; d < 7; d++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: _gap),
                            child: d.isEven && d != 6
                                ? weekdayLabel(firstMonday, d, size)
                                : SizedBox(height: size),
                          ),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        for (var w = 0; w < kHeatmapWeeks; w++)
                          SizedBox(
                            width: size + _gap,
                            height: 18,
                            child: monthLabels.containsKey(w)
                                ? Text(
                                    monthLabels[w]!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: theme.typography.caption?.color
                                          ?.withValues(alpha: 0.75),
                                    ),
                                    overflow: TextOverflow.visible,
                                    softWrap: false,
                                  )
                                : null,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        for (var w = 0; w < kHeatmapWeeks; w++)
                          Padding(
                            padding: const EdgeInsets.only(right: _gap),
                            child: Column(
                              children: [
                                for (var d = 0; d < 7; d++)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: _gap),
                                    child: cell(
                                      firstMonday.add(Duration(days: w * 7 + d)),
                                      size,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            );

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: matrix,
            );
          },
        ),
        const SizedBox(height: 14),

        // Heatmap Legend & Selected Date Tag
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.insLess,
                  style: theme.typography.caption?.copyWith(fontSize: 11),
                ),
                const SizedBox(width: 8),
                for (var i = 0; i < 5; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: i == 0
                            ? (isDark
                                ? Colors.grey[160].withValues(alpha: 0.35)
                                : Colors.grey[40].withValues(alpha: 0.5))
                            : theme.accentColor.withValues(alpha: _alphas[i]),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                Text(
                  l10n.insMore,
                  style: theme.typography.caption?.copyWith(fontSize: 11),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.insSelectedSummary(
                  AppDateFormat.weekdayWithDate(widget.selected),
                  (widget.totals[widget.selected] ?? Duration.zero)
                      .toHourMinuteFormat(),
                ),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.accentColor.normal,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Day timeline ──────────────────────────────────────────────────────────

const List<Color> _palette = [
  Color(0xFF3B82F6), // Blue
  Color(0xFF10B981), // Emerald
  Color(0xFFF59E0B), // Amber
  Color(0xFFEC4899), // Pink
  Color(0xFF8B5CF6), // Purple
  Color(0xFF06B6D4), // Cyan
  Color(0xFFF97316), // Orange
  Color(0xFF14B8A6), // Teal
];

class _TimelineBody extends StatelessWidget {
  final DayTimeline timeline;
  final DayBookends? bookends;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _TimelineBody({
    required this.timeline,
    this.bookends,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const barHeight = 130.0;

    Color colorFor(String key) {
      if (key == DayTimeline.otherKey) {
        return isDark ? Colors.grey[130] : Colors.grey[90];
      }
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
      final hourStr = '${h.toString().padLeft(2, '0')}:00';

      return Expanded(
        child: Tooltip(
          message: total == 0
              ? hourStr
              : '$hourStr · ${Duration(seconds: total).toHourMinuteFormat()}',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: barHeight,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[160].withValues(alpha: 0.12)
                      : Colors.grey[30],
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
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
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Navigation Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? theme.inactiveBackgroundColor.withValues(alpha: 0.15)
                : theme.resources.subtleFillColorTertiary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Tooltip(
                message: l10n.insPrevDay,
                child: IconButton(
                  icon: const Icon(FluentIcons.chevron_left, size: 12),
                  onPressed: onPrev,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(FluentIcons.calendar, size: 12),
                    const SizedBox(width: 8),
                    Text(
                      AppDateFormat.weekdayFullWithDate(timeline.day),
                      textAlign: TextAlign.center,
                      style: theme.typography.bodyStrong?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
        ),
        const SizedBox(height: 16),

        if (timeline.isEmpty && timeline.unplacedSeconds < 60)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FluentIcons.timeline_delivery, size: 28, color: theme.inactiveColor),
                  const SizedBox(height: 8),
                  Text(l10n.insTimelineEmpty, style: theme.typography.caption),
                ],
              ),
            ),
          )
        else if (timeline.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.insTimelineUnplaced(
                    Duration(seconds: timeline.unplacedSeconds).toHourMinuteFormat()),
                style: theme.typography.caption?.copyWith(height: 1.4),
              ),
            ),
          )
        else ...[
          // Chart Canvas
          Stack(
            children: [
              // Dotted Guidelines
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: 1, color: theme.resources.dividerStrokeColorDefault.withValues(alpha: 0.3)),
                    Container(height: 1, color: theme.resources.dividerStrokeColorDefault.withValues(alpha: 0.3)),
                    Container(height: 1, color: theme.resources.dividerStrokeColorDefault.withValues(alpha: 0.5)),
                  ],
                ),
              ),

              // 24 Hour Bars
              SizedBox(
                height: barHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [for (var h = 0; h < 24; h++) hourBar(h)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Hour axis labels
          Row(
            children: [
              for (final h in [0, 4, 8, 12, 16, 20, 23])
                Expanded(
                  flex: h == 23 ? 3 : 4,
                  child: Text(
                    '${h.toString().padLeft(2, '0')}:00',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.typography.caption?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Legend of Top Apps
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              for (final a in timeline.topApps)
                _LegendPill(
                  color: colorFor(a.appId),
                  label: a.name,
                  duration: Duration(seconds: a.seconds).toHourMinuteFormat(),
                ),
              if (timeline.hours.any((h) => h.containsKey(DayTimeline.otherKey)))
                _LegendPill(
                  color: colorFor(DayTimeline.otherKey),
                  label: l10n.insTimelineOther,
                  duration: null,
                ),
            ],
          ),

          if (bookends != null) ...[
            const SizedBox(height: 14),
            _BookendsRow(bookends: bookends!),
          ],

          if (timeline.unplacedSeconds >= 60)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _warning(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _warning(context).withValues(alpha: 0.3)),
                ),
                child: Text(
                  l10n.insTimelineUnplaced(
                      Duration(seconds: timeline.unplacedSeconds).toHourMinuteFormat()),
                  style: theme.typography.caption?.copyWith(
                    color: _warning(context),
                    fontSize: 11,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _LegendPill extends StatelessWidget {
  final Color color;
  final String label;
  final String? duration;
  const _LegendPill({required this.color, required this.label, this.duration});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? theme.inactiveBackgroundColor.withValues(alpha: 0.15)
            : theme.resources.subtleFillColorTertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.typography.caption?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          if (duration != null) ...[
            const SizedBox(width: 4),
            Text(
              '· $duration',
              style: theme.typography.caption?.copyWith(
                fontSize: 11,
                color: theme.typography.caption?.color?.withValues(alpha: 0.65),
              ),
            ),
          ],
        ],
      ),
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
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hasTitles)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.inactiveBackgroundColor.withValues(alpha: 0.1)
                  : theme.resources.subtleFillColorTertiary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(FluentIcons.info, size: 16, color: theme.accentColor.normal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.insSearchDisabled,
                    style: theme.typography.caption?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          )
        else ...[
          TextBox(
            controller: controller,
            placeholder: l10n.insSearchHint,
            prefix: const Padding(
              padding: EdgeInsets.only(left: 10, right: 6),
              child: Icon(FluentIcons.search, size: 14),
            ),
            suffix: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(FluentIcons.cancel, size: 10),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),
          if (controller.text.trim().isNotEmpty && hits.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.inactiveBackgroundColor.withValues(alpha: 0.08)
                    : theme.resources.subtleFillColorTertiary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  l10n.insSearchNoResults,
                  style: theme.typography.caption?.copyWith(
                    color: theme.typography.caption?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          if (hits.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.insMatchingWindows(hits.length),
                style: theme.typography.caption?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: theme.accentColor.normal,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: math.min(hits.length, 30),
                itemBuilder: (context, index) {
                  final h = hits[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.inactiveBackgroundColor.withValues(alpha: 0.12)
                          : theme.resources.subtleFillColorTertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(FluentIcons.tab_center, size: 12, color: theme.accentColor.normal),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                _highlight(
                                  h.title,
                                  controller.text.trim(),
                                  theme.typography.body?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ) ??
                                      const TextStyle(fontSize: 12),
                                  theme.accentColor.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${h.appName} · ${AppDateFormat.weekdayWithDate(h.lastSeen)}',
                                style: theme.typography.caption?.copyWith(
                                  fontSize: 10,
                                  color: theme.typography.caption?.color?.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            Duration(seconds: h.seconds).toHourMinuteFormat(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.accentColor.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (hits.length > 30)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.insShowingFirst(30, hits.length),
                  style: theme.typography.caption?.copyWith(
                    fontSize: 10,
                    color: theme.typography.caption?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ),
          ],
        ],
      ],
    );
  }

  /// Bolds + tints every case-insensitive occurrence of [query] in [text].
  static TextSpan _highlight(
      String text, String query, TextStyle base, Color accent) {
    if (query.isEmpty) return TextSpan(text: text, style: base);
    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    // Lowercasing can change length for some scripts; skip highlight then.
    if (lower.length != text.length) return TextSpan(text: text, style: base);
    final spans = <TextSpan>[];
    var i = 0;
    while (i < text.length) {
      final at = lower.indexOf(q, i);
      if (at < 0) {
        spans.add(TextSpan(text: text.substring(i)));
        break;
      }
      if (at > i) spans.add(TextSpan(text: text.substring(i, at)));
      spans.add(TextSpan(
        text: text.substring(at, at + q.length),
        style: TextStyle(color: accent, fontWeight: FontWeight.w800),
      ));
      i = at + q.length;
    }
    return TextSpan(style: base, children: spans);
  }
}
