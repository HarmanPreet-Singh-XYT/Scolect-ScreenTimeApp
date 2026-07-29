import 'package:fluent_ui/fluent_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:screentime/l10n/app_localizations.dart';
import '../../../controller/data_controllers/alerts_limits_data_controller.dart'
    as app_summary_data;
import '../widgets/shared_widgets.dart';

class UsageChartTab extends StatelessWidget {
  final AppLocalizations l10n;
  final app_summary_data.AppUsageSummary appSummary;
  final List<FlSpot> dailyUsageSpots;
  final List<String> sortedDates;
  final double maxUsage;
  final FluentThemeData theme;

  const UsageChartTab({
    super.key,
    required this.l10n,
    required this.appSummary,
    required this.dailyUsageSpots,
    required this.sortedDates,
    required this.maxUsage,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final hasLimit =
        appSummary.limitStatus && appSummary.dailyLimit > Duration.zero;
    final limitMinutes =
        hasLimit ? appSummary.dailyLimit.inMinutes.toDouble() : 0.0;
    final avgUsage = dailyUsageSpots.isEmpty
        ? 0.0
        : dailyUsageSpots.map((s) => s.y).reduce((a, b) => a + b) /
            dailyUsageSpots.length;
    final peakSpot = dailyUsageSpots.isEmpty
        ? null
        : dailyUsageSpots.reduce((a, b) => a.y > b.y ? a : b);

    double yMax = maxUsage + 30;
    if (hasLimit && limitMinutes > yMax) yMax = limitMinutes + 20;
    final yInterval = _niceInterval(yMax);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.resources.dividerStrokeColorDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.usageOverPastWeek,
                    style: theme.typography.subtitle
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 10,
                  children: [
                    _legendPill(l10n.legendUsage, Colors.blue),
                    _legendPill(l10n.legendAverage, Colors.teal, dashed: true),
                    if (hasLimit)
                      _legendPill(l10n.legendLimit, Colors.red, dashed: true),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: dailyUsageSpots.isEmpty
                  ? Center(
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FluentIcons.chart,
                            size: 40,
                            color: theme.accentColor.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text(l10n.noHistoricalData,
                            style: TextStyle(
                                fontSize: 14, color: theme.inactiveColor)),
                      ],
                    ))
                  : LineChart(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubic,
                      LineChartData(
                        clipData: const FlClipData.all(),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: yInterval,
                          getDrawingHorizontalLine: (_) => FlLine(
                              color: theme.accentColor.withValues(alpha: 0.08),
                              strokeWidth: 1),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            interval: 1,
                            getTitlesWidget: (value, _) {
                              final idx = value.round();
                              if (idx < 0 || idx >= sortedDates.length)
                                return const SizedBox.shrink();
                              final isPeak = peakSpot?.x.round() == idx;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _formatDateForAxis(sortedDates[idx]),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isPeak
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isPeak
                                        ? theme.accentColor
                                        : theme.inactiveColor,
                                  ),
                                ),
                              );
                            },
                          )),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 48,
                            interval: yInterval,
                            getTitlesWidget: (value, _) {
                              if (value == 0) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Text(
                                  formatMinutesShort(value),
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: theme.inactiveColor),
                                ),
                              );
                            },
                          )),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(
                                color:
                                    theme.accentColor.withValues(alpha: 0.2)),
                            left: BorderSide(
                                color:
                                    theme.accentColor.withValues(alpha: 0.2)),
                          ),
                        ),
                        minX: 0,
                        maxX: (sortedDates.length - 1).toDouble(),
                        minY: 0,
                        maxY: yMax,
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBorder: BorderSide(
                                color:
                                    theme.accentColor.withValues(alpha: 0.3)),
                            tooltipBorderRadius: BorderRadius.circular(10),
                            getTooltipColor: (_) =>
                                theme.cardColor.withValues(alpha: 0.97),
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipItems: (spots) => spots.map((spot) {
                              if (spot.barIndex != 0) return null;
                              final idx = spot.x.round();
                              final date = idx < sortedDates.length
                                  ? sortedDates[idx]
                                  : '';
                              final overLimit =
                                  hasLimit && spot.y > limitMinutes;
                              return LineTooltipItem('', const TextStyle(),
                                  children: [
                                    TextSpan(
                                        text: '$date\n',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: theme.inactiveColor,
                                            fontWeight: FontWeight.w500)),
                                    TextSpan(
                                      text: formatMinutesLong(spot.y),
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: overLimit
                                              ? Colors.red
                                              : Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if (overLimit)
                                      TextSpan(
                                        text:
                                            '\n${l10n.overLimitBy(formatMinutesLong(spot.y - limitMinutes))}',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.red
                                                .withValues(alpha: 0.8)),
                                      ),
                                  ]);
                            }).toList(),
                          ),
                          handleBuiltInTouches: true,
                          getTouchedSpotIndicator: (_, spotIndexes) =>
                              spotIndexes
                                  .map(
                                    (_) => TouchedSpotIndicatorData(
                                      FlLine(
                                          color: Colors.blue
                                              .withValues(alpha: 0.4),
                                          strokeWidth: 1.5,
                                          dashArray: [4, 4]),
                                      FlDotData(
                                        show: true,
                                        getDotPainter: (_, __, ___, ____) =>
                                            FlDotCirclePainter(
                                                radius: 6,
                                                color: Colors.blue,
                                                strokeWidth: 2.5,
                                                strokeColor: Colors.white),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: dailyUsageSpots,
                            isCurved: true,
                            curveSmoothness: 0.35,
                            color: Colors.blue,
                            barWidth: 2.5,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, _, __, ___) {
                                  final isPeak = peakSpot?.x == spot.x;
                                  final over =
                                      hasLimit && spot.y > limitMinutes;
                                  return FlDotCirclePainter(
                                    radius: isPeak ? 6 : 4,
                                    color: over
                                        ? Colors.red
                                        : isPeak
                                            ? Colors.orange
                                            : Colors.blue,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                }),
                            belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.withValues(alpha: 0.25),
                                    Colors.blue.withValues(alpha: 0.0)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )),
                          ),
                          LineChartBarData(
                            spots: [
                              FlSpot(0, avgUsage),
                              FlSpot(
                                  (sortedDates.length - 1).toDouble(), avgUsage)
                            ],
                            isCurved: false,
                            color: Colors.teal.withValues(alpha: 0.7),
                            barWidth: 1.5,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            dashArray: [6, 4],
                          ),
                          if (hasLimit)
                            LineChartBarData(
                              spots: List.generate(sortedDates.length,
                                  (i) => FlSpot(i.toDouble(), limitMinutes)),
                              isCurved: false,
                              color: Colors.red.withValues(alpha: 0.75),
                              barWidth: 1.5,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              dashArray: [8, 4],
                            ),
                        ],
                      ),
                    ),
            ),
            if (dailyUsageSpots.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _chartStat(l10n.chartPeak,
                        formatMinutesLong(peakSpot?.y ?? 0), Colors.orange),
                    _divider(),
                    _chartStat(l10n.legendAverage, formatMinutesLong(avgUsage),
                        Colors.teal),
                    if (hasLimit) ...[
                      _divider(),
                      _chartStat(l10n.legendLimit,
                          formatMinutesLong(limitMinutes), Colors.red)
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _legendPill(String label, Color color, {bool dashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
              color: color.withValues(alpha: dashed ? 0.5 : 1.0),
              shape: BoxShape.circle),
        ),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: theme.inactiveColor,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _chartStat(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: theme.inactiveColor)),
      ],
    );
  }

  Widget _divider() => Container(
      width: 1, height: 30, color: theme.resources.dividerStrokeColorDefault);

  double _niceInterval(double maxVal) {
    if (maxVal <= 60) return 15;
    if (maxVal <= 120) return 30;
    if (maxVal <= 300) return 60;
    return 120;
  }

  String _formatDateForAxis(String dateString) {
    try {
      final d = DateFormat('MM/dd').parse(dateString);
      final now = DateTime.now();
      if (d.month == now.month && d.day == now.day) return l10n.todayChart;
      return DateFormat('EEE').format(d);
    } catch (_) {
      return dateString;
    }
  }
}
