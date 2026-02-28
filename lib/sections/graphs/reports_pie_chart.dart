// reports_pie_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPieChart extends StatefulWidget {
  final Map<String, double> dataMap;
  final List<Color> colorList;

  const ReportsPieChart({
    super.key,
    required this.dataMap,
    required this.colorList,
  });

  @override
  State<ReportsPieChart> createState() => _ReportsPieChartState();
}

class _ReportsPieChartState extends State<ReportsPieChart> {
  int _touchedIndex = -1;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollIndicator = false;

  // OPTIMIZATION: Cache entries & total so they aren't rebuilt on every paint.
  late List<MapEntry<String, double>> _entries;
  late double _total;

  @override
  void initState() {
    super.initState();
    _cacheData();
    // BUGFIX: Added `mounted` guard — widget might be disposed before the
    // post-frame callback fires (e.g. during fast navigation).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkIfScrollable();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(ReportsPieChart oldWidget) {
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
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkIfScrollable() {
    if (_scrollController.hasClients) {
      final canScroll = _scrollController.position.maxScrollExtent > 0 &&
          _scrollController.offset < _scrollController.position.maxScrollExtent;
      if (canScroll != _showScrollIndicator) {
        setState(() => _showScrollIndicator = canScroll);
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isAtBottom =
        _scrollController.offset >= _scrollController.position.maxScrollExtent;
    // OPTIMIZATION: Only rebuild if the indicator visibility actually changes.
    if (_showScrollIndicator == isAtBottom) {
      setState(() => _showScrollIndicator = !isAtBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
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
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: _buildSections(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Flexible(
          flex: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 100),
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _buildLegendItems(),
                    ),
                  ),
                ),
                if (_showScrollIndicator) ...[
                  // Fade overlay
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 30,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context)
                                  .scaffoldBackgroundColor
                                  .withValues(alpha: 0.0),
                              Theme.of(context).scaffoldBackgroundColor,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Down-arrow indicator
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              ?.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // OPTIMIZATION: Uses cached _entries / _total; no per-call fold.
  List<Widget> _buildLegendItems() {
    return _entries.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final percentage =
          (_total > 0) ? (data.value / _total * 100).toStringAsFixed(1) : '0.0';
      final isSelected = _touchedIndex == index;
      final color = widget.colorList[index % widget.colorList.length];

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${data.key} ($percentage%)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // OPTIMIZATION: Uses cached _entries / _total.
  List<PieChartSectionData> _buildSections() {
    return _entries.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == _touchedIndex;
      final percentage = _total > 0 ? (data.value / _total * 100) : 0.0;
      final color = widget.colorList[index % widget.colorList.length];

      return PieChartSectionData(
        color: color,
        value: data.value,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 65 : 55,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgePositionPercentageOffset: .98,
      );
    }).toList();
  }
}
