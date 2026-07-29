import 'package:fluent_ui/fluent_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/data_controllers/applications_data_controller.dart';
import '../widgets/shared_widgets.dart';

class PatternsTab extends StatelessWidget {
  final AppLocalizations l10n;
  final ApplicationBasicDetail appBasicDetails;
  final ApplicationDetailedData appDetails;
  final Map<String, double> timeOfDayUsage;
  final FluentThemeData theme;

  const PatternsTab({
    super.key,
    required this.l10n,
    required this.appBasicDetails,
    required this.appDetails,
    required this.timeOfDayUsage,
    required this.theme,
  });

  static final _timeColors = {
    'Morning (6-12)': Colors.orange,
    'Afternoon (12-5)': Colors.yellow,
    'Evening (5-9)': Colors.purple,
    'Night (9-6)': Colors.blue,
  };

  Color _colorFor(String key) => _timeColors[key] ?? Colors.grey;

  String _localize(String key) {
    if (key.contains('Morning')) return l10n.morning;
    if (key.contains('Afternoon')) return l10n.afternoon;
    if (key.contains('Evening')) return l10n.evening;
    if (key.contains('Night')) return l10n.night;
    return key;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildCompactCard(
            context,
            l10n.usagePatternByTimeOfDay,
            FluentIcons.timeline_progress,
            theme,
            child: SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(PieChartData(
                      sections: timeOfDayUsage.entries
                          .map((e) => PieChartSectionData(
                                color: _colorFor(e.key),
                                value: e.value,
                                title: '${e.value.toInt()}%',
                                radius: 70,
                                titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ))
                          .toList(),
                      centerSpaceRadius: 30,
                      sectionsSpace: 2,
                    )),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: timeOfDayUsage.keys
                          .map((key) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                          color: _colorFor(key),
                                          borderRadius:
                                              BorderRadius.circular(2)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(_localize(key),
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          buildCompactCard(
            context,
            l10n.usageInsights,
            FluentIcons.lightbulb,
            theme,
            child: Text(_buildInsights(),
                style: theme.typography.body?.copyWith(height: 1.5)),
          ),
        ],
      ),
    );
  }

  String _buildInsights() {
    final primaryKey =
        timeOfDayUsage.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final growth = appDetails.comparisons.growthPercentage;

    final trendText = growth > 10
        ? l10n.significantIncrease(growth.toStringAsFixed(1))
        : growth > 5
            ? l10n.trendingUpward
            : growth < -10
                ? l10n.significantDecrease(growth.abs().toStringAsFixed(1))
                : growth < -5
                    ? l10n.trendingDownward
                    : l10n.consistentUsage;

    return '${l10n.primaryUsageTime(appBasicDetails.name, _localize(primaryKey))} $trendText';
  }
}
