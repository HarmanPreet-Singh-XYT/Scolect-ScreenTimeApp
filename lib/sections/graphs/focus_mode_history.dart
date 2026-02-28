// focus_mode_history.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:screentime/l10n/app_localizations.dart';

class FocusModeHistoryChart extends StatefulWidget {
  final Map<String, int> data;

  const FocusModeHistoryChart({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => FocusModeHistoryChartState();
}

class FocusModeHistoryChartState extends State<FocusModeHistoryChart> {
  int _touchedIndex = -1;

  // OPTIMIZATION: Static English day keys used as fallback — allocated once.
  static const List<String> _englishDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // OPTIMIZATION: Compute total + max in a single fold instead of two separate passes.
  ({int total, int max}) _computeStats() {
    int total = 0, max = 0;
    for (final v in widget.data.values) {
      total += v;
      if (v > max) max = v;
    }
    return (total: total, max: max);
  }

  // OPTIMIZATION: Resolve a value by trying the localized name first, then English.
  int _valueForDay(String localizedName, int index) =>
      widget.data[localizedName] ?? widget.data[_englishDays[index]] ?? 0;

  @override
  Widget build(BuildContext context) {
    // OPTIMIZATION: Resolve l10n once per build, not inside every helper.
    final l10n = AppLocalizations.of(context)!;
    final stats = _computeStats();

    // Build localized day lists once per build.
    final localizedFull = [
      l10n.day_monday,
      l10n.day_tuesday,
      l10n.day_wednesday,
      l10n.day_thursday,
      l10n.day_friday,
      l10n.day_saturday,
      l10n.day_sunday,
    ];
    final localizedAbbr = [
      l10n.day_mondayAbbr,
      l10n.day_tuesdayAbbr,
      l10n.day_wednesdayAbbr,
      l10n.day_thursdayAbbr,
      l10n.day_fridayAbbr,
      l10n.day_saturdayAbbr,
      l10n.day_sundayAbbr,
    ];

    final maxValue = stats.max == 0 ? 10 : stats.max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              _buildSummaryChip(
                context,
                label: l10n.focus_mode_this_week,
                value: '${stats.total} sessions',
                color: const Color(0xFF42A5F5),
              ),
              const SizedBox(width: 12),
              _buildSummaryChip(
                context,
                label: l10n.focus_mode_best_day,
                value: _getBestDay(l10n, localizedFull),
                color: const Color(0xFF4CAF50),
              ),
            ],
          ),
        ),
        AspectRatio(
          aspectRatio: 2.5,
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBorderRadius: BorderRadius.circular(8),
                  tooltipPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  getTooltipColor: (group) =>
                      FluentTheme.of(context).micaBackgroundColor,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${localizedFull[groupIndex]}\n',
                      TextStyle(
                        color: FluentTheme.of(context).typography.body?.color,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: l10n.focus_mode_sessions_count(rod.toY.toInt()),
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        barTouchResponse == null ||
                        barTouchResponse.spot == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                  });
                },
              ),
              titlesData: _getTitlesData(context, localizedAbbr),
              borderData: FlBorderData(show: false),
              barGroups: _getBarGroups(context, maxValue, localizedFull),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval:
                    (maxValue / 4).ceilToDouble().clamp(1, double.infinity),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: FluentTheme.of(context)
                      .inactiveBackgroundColor
                      .withValues(alpha: 0.5),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxValue * 1.2).ceilToDouble().clamp(5, double.infinity),
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryChip(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: FluentTheme.of(context).typography.caption?.copyWith(
                      color: FluentTheme.of(context)
                          .typography
                          .caption
                          ?.color
                          ?.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
              ),
              Text(
                value,
                style: FluentTheme.of(context).typography.body?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // BUGFIX + OPTIMIZATION: Accept pre-built localized list; no longer rebuilds
  // the map on every call, and resolves via the same localized keys used elsewhere.
  String _getBestDay(AppLocalizations l10n, List<String> localizedFull) {
    if (widget.data.isEmpty) return '-';

    String bestKey = '';
    int maxSessions = 0;

    widget.data.forEach((day, count) {
      if (count > maxSessions) {
        maxSessions = count;
        bestKey = day;
      }
    });

    if (maxSessions == 0) return '-';

    // Try to match bestKey against localized names first, then English.
    for (int i = 0; i < 7; i++) {
      if (bestKey == localizedFull[i] || bestKey == _englishDays[i]) {
        return localizedFull[i];
      }
    }
    return bestKey;
  }

  // OPTIMIZATION: Accept pre-built abbr list instead of rebuilding inside.
  FlTitlesData _getTitlesData(BuildContext context, List<String> abbr) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            final isToday = DateTime.now().weekday - 1 == index;
            return SideTitleWidget(
              meta: meta,
              space: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    abbr[index],
                    style: TextStyle(
                      color: isToday
                          ? const Color(0xFF4CAF50)
                          : FluentTheme.of(context)
                              .typography
                              .body
                              ?.color
                              ?.withValues(alpha: 0.6),
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            if (value == 0) return const SizedBox.shrink();
            return SideTitleWidget(
              meta: meta,
              child: Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: FluentTheme.of(context)
                      .typography
                      .body
                      ?.color
                      ?.withValues(alpha: 0.4),
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  // OPTIMIZATION: Accept pre-built localized full list; single-pass value lookup.
  List<BarChartGroupData> _getBarGroups(
      BuildContext context, int maxValue, List<String> localizedFull) {
    final todayIndex = DateTime.now().weekday - 1;

    return List.generate(7, (index) {
      final value = _valueForDay(localizedFull[index], index);
      final isTouched = index == _touchedIndex;
      final isToday = index == todayIndex;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            width: isTouched ? 20 : 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            gradient: LinearGradient(
              colors: isToday
                  ? [const Color(0xFF4CAF50), const Color(0xFF81C784)]
                  : isTouched
                      ? [const Color(0xFF42A5F5), const Color(0xFF90CAF9)]
                      : [
                          const Color(0xFF42A5F5).withValues(alpha: 0.7),
                          const Color(0xFF90CAF9).withValues(alpha: 0.7),
                        ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxValue * 1.2,
              color: FluentTheme.of(context)
                  .inactiveBackgroundColor
                  .withValues(alpha: 0.2),
            ),
          ),
        ],
      );
    });
  }
}
