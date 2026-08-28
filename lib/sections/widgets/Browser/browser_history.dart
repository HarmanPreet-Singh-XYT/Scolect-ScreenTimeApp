import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' show Colors;
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/data_controllers/applications_data_controller.dart'
    show DurationFormatter;
import 'package:screentime/sections/controller/data_controllers/browser_data_controller.dart';
import 'browser_shared.dart';

class BrowserHistory extends StatefulWidget {
  const BrowserHistory({super.key});

  @override
  State<BrowserHistory> createState() => _BrowserHistoryState();
}

class _BrowserHistoryState extends State<BrowserHistory> {
  final _provider = BrowserDataProvider();

  List<({String date, Duration totalTime, int siteCount})> _history = [];
  bool _isLoading = true;
  int _touchedIndex = -1;
  int _days = 7;

  @override
  void initState() {
    super.initState();
    _provider.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    _provider.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await _provider.fetchHistory(days: _days);
    // fetchHistory returns newest-first; reverse for chart (oldest → newest left→right)
    if (!mounted) return;
    setState(() {
      _history = data.reversed.toList();
      _isLoading = false;
      _touchedIndex = -1;
    });
  }

  // ── Stats ──────────────────────────────────────────────────────────────────

  Duration get _totalTime =>
      _history.fold(Duration.zero, (s, d) => s + d.totalTime);

  Duration get _avgPerDay {
    final active = _history.where((d) => d.totalTime > Duration.zero).length;
    if (active == 0) return Duration.zero;
    return Duration(seconds: (_totalTime.inSeconds / active).round());
  }

  ({String date, Duration totalTime, int siteCount}) get _peakDay {
    if (_history.isEmpty)
      return (date: '–', totalTime: Duration.zero, siteCount: 0);
    return _history.reduce((a, b) => a.totalTime >= b.totalTime ? a : b);
  }

  // ── Day label helpers ──────────────────────────────────────────────────────

  String _shortLabel(String dateKey) {
    // dateKey is 'YYYY-MM-DD'
    final parts = dateKey.split('-');
    if (parts.length < 3) return dateKey;
    final month = int.tryParse(parts[1]) ?? 0;
    final day = int.tryParse(parts[2]) ?? 0;
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[month]} $day';
  }

  String _dayOfWeek(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length < 3) return '';
    final dt = DateTime.tryParse(dateKey);
    if (dt == null) return '';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(dt.weekday - 1) % 7];
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accent = theme.accentColor;
    final captionColor = theme.typography.caption?.color;

    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    final hasData = _history.any((d) => d.totalTime > Duration.zero);
    final peak = _peakDay;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header + range picker ────────────────────────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.browserHistoryTitle,
                      style: theme.typography.subtitle
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(l10n.browserHistorySubtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: captionColor?.withValues(alpha: 0.6))),
                ],
              ),
              const Spacer(),
              // Range selector
              _RangePicker(
                selected: _days,
                onChanged: (v) {
                  _days = v;
                  _load();
                },
                accent: accent,
              ),
              const SizedBox(width: 8),
              BrowserIconButton(
                tooltip: l10n.refresh,
                icon: FluentIcons.refresh,
                onPressed: _load,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Summary cards ────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: BrowserSummaryCard(
                  icon: FluentIcons.calendar_week,
                  label: l10n.browserHistoryTotalWeek,
                  value: _totalTime.toHourMinuteFormat(),
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BrowserSummaryCard(
                  icon: FluentIcons.trending12,
                  label: l10n.browserHistoryAvgPerDay,
                  value: _avgPerDay.toHourMinuteFormat(),
                  color: kBrowserBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BrowserSummaryCard(
                  icon: FluentIcons.trophy,
                  label: l10n.browserHistoryPeakDay,
                  value: peak.totalTime > Duration.zero
                      ? '${_shortLabel(peak.date)} · ${peak.totalTime.toHourMinuteFormat()}'
                      : '–',
                  color: kBrowserAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Bar chart ────────────────────────────────────────────────────
          Expanded(
            child: BrowserCard(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: !hasData
                  ? BrowserEmptyState(
                      icon: FluentIcons.history,
                      title: l10n.browserHistoryNoData,
                      subtitle: l10n.browserNoWebsitesDesktopSubtitle,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _BarChart(
                          history: _history,
                          touchedIndex: _touchedIndex,
                          onTouch: (i) => setState(() => _touchedIndex = i),
                          accent: accent,
                          captionColor: captionColor,
                          shortLabel: _shortLabel,
                          dayOfWeek: _dayOfWeek,
                        )),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bar chart ────────────────────────────────────────────────────────────────

class _BarChart extends StatelessWidget {
  final List<({String date, Duration totalTime, int siteCount})> history;
  final int touchedIndex;
  final ValueChanged<int> onTouch;
  final Color accent;
  final Color? captionColor;
  final String Function(String) shortLabel;
  final String Function(String) dayOfWeek;

  const _BarChart({
    required this.history,
    required this.touchedIndex,
    required this.onTouch,
    required this.accent,
    required this.captionColor,
    required this.shortLabel,
    required this.dayOfWeek,
  });

  @override
  Widget build(BuildContext context) {
    final maxSecs = history.fold<int>(
        0, (m, d) => d.totalTime.inSeconds > m ? d.totalTime.inSeconds : m);
    final yMax = maxSecs == 0 ? 3600.0 : (maxSecs * 1.2).ceilToDouble();

    return BarChart(
      BarChartData(
        maxY: yMax,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => FluentTheme.of(context).micaBackgroundColor,
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = history[groupIndex];
              return BarTooltipItem(
                '${dayOfWeek(day.date)} ${shortLabel(day.date)}\n',
                TextStyle(
                  color: captionColor?.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: day.totalTime.toHourMinuteFormat(),
                    style: TextStyle(
                      color: accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: '\n${day.siteCount} sites',
                    style: TextStyle(
                      color: captionColor?.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            },
          ),
          touchCallback: (event, response) {
            if (event is FlTapUpEvent || event is FlPanEndEvent) {
              final idx = response?.spot?.touchedBarGroupIndex ?? -1;
              onTouch(idx);
            }
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= history.length)
                  return const SizedBox.shrink();
                final day = history[i];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dayOfWeek(day.date),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: i == touchedIndex
                              ? accent
                              : captionColor?.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        shortLabel(day.date),
                        style: TextStyle(
                          fontSize: 10,
                          color: captionColor?.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              interval: yMax / 4,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                final dur = Duration(seconds: value.toInt());
                final h = dur.inHours;
                final m = dur.inMinutes % 60;
                final label = h > 0 ? '${h}h' : '${m}m';
                return Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: captionColor?.withValues(alpha: 0.4),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yMax / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: captionColor?.withValues(alpha: 0.08) ??
                Colors.grey.withValues(alpha: 0.08),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(history.length, (i) {
          final day = history[i];
          final isTouched = i == touchedIndex;
          final isToday = i == history.length - 1;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: day.totalTime.inSeconds.toDouble(),
                width: history.length <= 7 ? 32 : 18,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
                gradient: LinearGradient(
                  colors: isTouched
                      ? [accent, accent.withValues(alpha: 0.7)]
                      : isToday
                          ? [
                              accent.withValues(alpha: 0.9),
                              accent.withValues(alpha: 0.5)
                            ]
                          : [
                              accent.withValues(alpha: 0.5),
                              accent.withValues(alpha: 0.25),
                            ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ],
            showingTooltipIndicators: isTouched ? [0] : [],
          );
        }),
      ),
      duration: const Duration(milliseconds: 300),
    );
  }
}

// ─── Range picker ─────────────────────────────────────────────────────────────

class _RangePicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  final Color accent;

  const _RangePicker({
    required this.selected,
    required this.onChanged,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final options = [7, 14, 30];
    final labels = ['7d', '14d', '30d'];

    return BrowserCard(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (i) {
          final sel = options[i] == selected;
          return GestureDetector(
            onTap: () => onChanged(options[i]),
            child: AnimatedContainer(
              duration: kBrowserHoverDuration,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color:
                    sel ? accent.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                  color: sel
                      ? accent
                      : theme.typography.caption?.color?.withValues(alpha: 0.6),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
