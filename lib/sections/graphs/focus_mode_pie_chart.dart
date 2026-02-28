// focus_mode_pie_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' show Colors;
import 'package:screentime/l10n/app_localizations.dart';

class FocusModePieChart extends StatefulWidget {
  final Map<String, double> dataMap;
  final List<Color> colorList;

  const FocusModePieChart({
    super.key,
    required this.dataMap,
    required this.colorList,
  });

  @override
  State<FocusModePieChart> createState() => _FocusModePieChartState();
}

class _FocusModePieChartState extends State<FocusModePieChart> {
  int _touchedIndex = -1;

  // OPTIMIZATION: Cache entries list so it isn't rebuilt on every paint.
  late List<MapEntry<String, double>> _entries;
  // OPTIMIZATION: Cache total so it isn't re-folded on every paint.
  late double _total;

  @override
  void initState() {
    super.initState();
    _cacheData();
  }

  @override
  void didUpdateWidget(FocusModePieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataMap != widget.dataMap) {
      _cacheData();
    }
  }

  void _cacheData() {
    _entries = widget.dataMap.entries.toList();
    _total = _entries.fold(0.0, (sum, e) => sum + e.value);
  }

  @override
  Widget build(BuildContext context) {
    if (_total == 0) return _buildEmptyState(context);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                sections: _buildSections(),
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildLegend(context),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FluentIcons.pie_double,
            size: 48,
            color: FluentTheme.of(context).inactiveBackgroundColor,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.focus_mode_no_data_yet,
            style: FluentTheme.of(context).typography.caption?.copyWith(
                  color: FluentTheme.of(context)
                      .typography
                      .caption
                      ?.color
                      ?.withValues(alpha: 0.5),
                ),
          ),
        ],
      ),
    );
  }

  // OPTIMIZATION: Uses cached _entries / _total; no re-fold on every paint.
  List<PieChartSectionData> _buildSections() {
    return List.generate(_entries.length, (index) {
      final isTouched = index == _touchedIndex;
      final entry = _entries[index];
      final percentage = (entry.value / _total) * 100;
      final color = widget.colorList[index % widget.colorList.length];

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 60 : 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: isTouched ? _buildBadge(color) : null,
        badgePositionPercentageOffset: 1.2,
      );
    });
  }

  Widget _buildBadge(Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(FluentIcons.check_mark, color: Colors.white, size: 12),
    );
  }

  // OPTIMIZATION: Uses cached _entries / _total; no extra list allocations.
  List<Widget> _buildLegend(BuildContext context) {
    return List.generate(_entries.length, (index) {
      final entry = _entries[index];
      final color = widget.colorList[index % widget.colorList.length];
      final percentage = (_entries[index].value / _total) * 100;
      final isTouched = index == _touchedIndex;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _touchedIndex = index),
          onExit: (_) => setState(() => _touchedIndex = -1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isTouched ? color.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isTouched
                    ? color.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isTouched ? 14 : 10,
                  height: isTouched ? 14 : 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: isTouched
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 4,
                            )
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: FluentTheme.of(context)
                            .typography
                            .body
                            ?.copyWith(
                              fontWeight:
                                  isTouched ? FontWeight.w600 : FontWeight.w400,
                              fontSize: 12,
                            ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
