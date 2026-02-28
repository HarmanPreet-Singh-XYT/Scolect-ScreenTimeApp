// line_chart_widget.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:screentime/sections/controller/data_controllers/reports_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screentime/l10n/app_localizations.dart';

enum ChartType { main, alternate }

enum DateDisplayMode { dayOfWeek, dayMonth, monthYear }

class LineChartWidget extends StatefulWidget {
  final ChartType chartType;
  final List<DailyScreenTime>? dailyScreenTimeData;
  final String periodType;
  // OPTIMIZATION: removed unused startDate / endDate parameters.
  final Function(DateTime) onDateSelected;

  const LineChartWidget({
    super.key,
    required this.chartType,
    this.dailyScreenTimeData,
    this.periodType = 'Custom Range',
    required this.onDateSelected,
  });

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget>
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // OPTIMIZATION: static const — shared across all instances; zero per-instance cost.
  static const Color _primaryColor = Color(0xFF34D399);
  static const Color _secondaryColor = Color(0xFF60A5FA);
  static const Color _gridColor = Color(0xFFE5E7EB);
  static const Color _textColor = Color(0xFF6B7280);
  static const Color _tooltipBg = Color(0xFF1F2937);

  // OPTIMIZATION: Cache computed spots & average so they aren't rebuilt on every
  // setState (which happens on every hover/touch event).
  List<FlSpot>? _cachedMainSpots;
  List<FlSpot>? _cachedAvgSpots;
  List<DailyScreenTime>? _lastData;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(LineChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dailyScreenTimeData != widget.dailyScreenTimeData) {
      _cachedMainSpots = null;
      _cachedAvgSpots = null;
      _lastData = null;
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // OPTIMIZATION: Recompute spots only when data or animation value changes,
  // not on every touch/hover setState.
  void _rebuildSpotsIfNeeded() {
    final data = widget.dailyScreenTimeData;
    if (data == _lastData && _cachedMainSpots != null) return;

    _lastData = data;
    if (data == null || data.isEmpty) {
      _cachedMainSpots = null;
      _cachedAvgSpots = null;
      return;
    }

    _cachedMainSpots = data.asMap().entries.map((entry) {
      final hours = entry.value.screenTime.inMinutes / 60.0;
      return FlSpot(entry.key.toDouble(), hours * _animation.value);
    }).toList();

    final totalMinutes =
        data.fold<int>(0, (sum, item) => sum + item.screenTime.inMinutes);
    final avgHours = totalMinutes / data.length / 60.0 * _animation.value;
    _cachedAvgSpots = List.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), avgHours),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        // Invalidate spot cache whenever animation ticks so gradient animates.
        _cachedMainSpots = null;
        _cachedAvgSpots = null;
        return LineChart(
          _getChartData(context),
          // BUGFIX: removed explicit `duration` here — the custom
          // AnimationController already drives the animation; having both
          // caused a double-animation artefact on data changes.
        );
      },
    );
  }

  LineChartData _getChartData(BuildContext context) {
    final data = widget.dailyScreenTimeData;
    _rebuildSpotsIfNeeded();

    double maxY = 6.0;
    if (data != null && data.isNotEmpty) {
      final maxHours = data
          .map((d) => d.screenTime.inMinutes / 60.0)
          .reduce((a, b) => a > b ? a : b);
      maxY = ((maxHours / 2).ceil() * 2 + 2).toDouble();
      maxY = maxY.clamp(4.0, 24.0);
    }

    final double maxX = (data?.length ?? 7).toDouble();

    return LineChartData(
      lineTouchData: _buildTouchData(context),
      gridData: _buildGridData(maxY),
      titlesData: _buildTitlesData(context, maxY),
      borderData: _buildBorderData(),
      lineBarsData: _buildLineBarsData(),
      minX: 0,
      maxX: maxX,
      maxY: maxY,
      minY: 0,
      backgroundColor: Colors.transparent,
      clipData: const FlClipData.all(),
    );
  }

  LineTouchData _buildTouchData(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LineTouchData(
      enabled: true,
      handleBuiltInTouches: true,
      touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
        if (event is FlTapUpEvent &&
            response?.lineBarSpots != null &&
            response!.lineBarSpots!.isNotEmpty) {
          final index = response.lineBarSpots!.first.x.toInt();
          final data = widget.dailyScreenTimeData;
          if (data != null && index >= 0 && index < data.length) {
            widget.onDateSelected(data[index].date);
          }
        }

        if (event is FlPointerHoverEvent || event is FlLongPressStart) {
          if (response?.lineBarSpots != null &&
              response!.lineBarSpots!.isNotEmpty) {
            setState(() {
              _touchedIndex = response.lineBarSpots!.first.x.toInt();
            });
          }
        } else if (event is FlPointerExitEvent || event is FlLongPressEnd) {
          setState(() => _touchedIndex = -1);
        }
      },
      touchTooltipData: LineTouchTooltipData(
        tooltipPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        tooltipMargin: 16,
        getTooltipColor: (_) => _tooltipBg,
        getTooltipItems: (spots) => _buildTooltipItems(spots, context, l10n),
      ),
      getTouchedSpotIndicator: (barData, spotIndexes) {
        return spotIndexes.map((index) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: _primaryColor.withValues(alpha: 0.3),
              strokeWidth: 2,
              dashArray: [5, 5],
            ),
            FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 8,
                color: Colors.white,
                strokeWidth: 3,
                strokeColor: _primaryColor,
              ),
            ),
          );
        }).toList();
      },
    );
  }

  List<LineTooltipItem?> _buildTooltipItems(
    List<LineBarSpot> spots,
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final data = widget.dailyScreenTimeData;
    return spots.map((spot) {
      final index = spot.x.toInt();
      if (data != null && index >= 0 && index < data.length) {
        final item = data[index];
        final hours = item.screenTime.inHours;
        final minutes = item.screenTime.inMinutes.remainder(60);
        final dateStr = DateFormat('EEE, MMM d').format(item.date);

        return LineTooltipItem(
          '',
          const TextStyle(),
          children: [
            TextSpan(
              text: dateStr,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const TextSpan(text: '\n'),
            TextSpan(
              text: hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ],
        );
      }
      return null;
    }).toList();
  }

  FlGridData _buildGridData(double maxY) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: maxY > 12 ? 4 : 2,
      getDrawingHorizontalLine: (value) => FlLine(
        color: _gridColor.withValues(alpha: 0.5),
        strokeWidth: 1,
        dashArray: value == 0 ? null : [5, 5],
      ),
    );
  }

  FlTitlesData _buildTitlesData(BuildContext context, double maxY) {
    return FlTitlesData(
      bottomTitles: AxisTitles(sideTitles: _buildBottomTitles()),
      leftTitles: AxisTitles(sideTitles: _buildLeftTitles(context, maxY)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  SideTitles _buildLeftTitles(BuildContext context, double maxY) {
    return SideTitles(
      showTitles: true,
      reservedSize: 44,
      interval: maxY > 12 ? 4 : 2,
      getTitlesWidget: (value, meta) {
        if (value == 0 || value == meta.max) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            '${value.toInt()}h',
            style: const TextStyle(
              color: _textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        );
      },
    );
  }

  SideTitles _buildBottomTitles() {
    final dataLength = widget.dailyScreenTimeData?.length ?? 7;

    double interval = 1;
    if (dataLength > 60) {
      interval = (dataLength / 6).ceilToDouble();
    } else if (dataLength > 30) {
      interval = 7;
    } else if (dataLength > 14) {
      interval = 3;
    } else if (dataLength > 7) {
      interval = 2;
    }

    return SideTitles(
      showTitles: true,
      reservedSize: 32,
      interval: interval,
      getTitlesWidget: _buildBottomTitleWidget,
    );
  }

  Widget _buildBottomTitleWidget(double value, TitleMeta meta) {
    final data = widget.dailyScreenTimeData;
    final index = value.toInt();

    if (data == null || index < 0 || index >= data.length) {
      return const SizedBox.shrink();
    }
    if (value == meta.min || value == meta.max) {
      return const SizedBox.shrink();
    }

    final date = data[index].date;
    final displayMode = _getDateDisplayMode();
    final text = _formatDate(date, displayMode);
    final isTouched = _touchedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          color: isTouched ? _primaryColor : _textColor,
          fontSize: 11,
          fontWeight: isTouched ? FontWeight.w600 : FontWeight.w500,
        ),
        child: Text(text),
      ),
    );
  }

  DateDisplayMode _getDateDisplayMode() {
    final len = widget.dailyScreenTimeData?.length ?? 7;
    if (len <= 14) return DateDisplayMode.dayOfWeek;
    if (len <= 90) return DateDisplayMode.dayMonth;
    return DateDisplayMode.monthYear;
  }

  // OPTIMIZATION: removed unused `context` parameter.
  String _formatDate(DateTime date, DateDisplayMode mode) {
    switch (mode) {
      case DateDisplayMode.dayOfWeek:
        return DateFormat('EEE').format(date);
      case DateDisplayMode.dayMonth:
        return DateFormat('d/M').format(date);
      case DateDisplayMode.monthYear:
        return DateFormat('MMM').format(date);
    }
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border(
        bottom: const BorderSide(color: _gridColor, width: 1),
        left: const BorderSide(color: _gridColor, width: 1),
        right: BorderSide.none,
        top: BorderSide.none,
      ),
    );
  }

  List<LineChartBarData> _buildLineBarsData() {
    final data = widget.dailyScreenTimeData;
    if (data == null || data.isEmpty) return [_buildPlaceholderLine()];

    return [
      _buildMainLine(data),
      if (widget.chartType == ChartType.alternate) _buildAverageLine(data),
    ];
  }

  LineChartBarData _buildMainLine(List<DailyScreenTime> data) {
    // _cachedMainSpots is always populated before this is called.
    final spots = _cachedMainSpots!;

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.35,
      preventCurveOverShooting: true,
      color: _primaryColor,
      barWidth: 3,
      isStrokeCapRound: true,
      shadow: Shadow(
        color: _primaryColor.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final isTouched = index == _touchedIndex;
          return FlDotCirclePainter(
            radius: isTouched ? 6 : 4,
            color: Colors.white,
            strokeWidth: isTouched ? 3 : 2,
            strokeColor: _primaryColor,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _primaryColor.withValues(alpha: 0.3 * _animation.value),
            _primaryColor.withValues(alpha: 0.05 * _animation.value),
            _primaryColor.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  LineChartBarData _buildAverageLine(List<DailyScreenTime> data) {
    return LineChartBarData(
      spots: _cachedAvgSpots!,
      isCurved: false,
      color: _secondaryColor.withValues(alpha: 0.6),
      barWidth: 2,
      dashArray: [8, 4],
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  LineChartBarData _buildPlaceholderLine() {
    return LineChartBarData(
      spots: const [
        FlSpot(0, 2),
        FlSpot(1, 3),
        FlSpot(2, 2.5),
        FlSpot(3, 4),
        FlSpot(4, 3.5),
        FlSpot(5, 4.5),
        FlSpot(6, 3),
      ],
      isCurved: true,
      curveSmoothness: 0.35,
      color: _gridColor,
      barWidth: 3,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: _gridColor.withValues(alpha: 0.2),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EnhancedLineChart
// ---------------------------------------------------------------------------

class EnhancedLineChart extends StatefulWidget {
  final List<DailyScreenTime>? dailyScreenTimeData;
  final String periodType;
  final Function(DateTime) onDateSelected;
  final bool showControls;

  const EnhancedLineChart({
    super.key,
    this.dailyScreenTimeData,
    required this.periodType,
    required this.onDateSelected,
    this.showControls = true,
  });

  @override
  State<EnhancedLineChart> createState() => _EnhancedLineChartState();
}

class _EnhancedLineChartState extends State<EnhancedLineChart> {
  bool _showAverage = false;

  // OPTIMIZATION: Cache stats so _buildSummary doesn't re-fold on every build.
  ({int avg, int max, int min})? _cachedStats;
  List<DailyScreenTime>? _lastData;

  ({int avg, int max, int min}) _getStats() {
    final data = widget.dailyScreenTimeData!;
    if (data == _lastData && _cachedStats != null) return _cachedStats!;

    _lastData = data;
    int total = 0, max = 0, min = data.first.screenTime.inMinutes;
    for (final item in data) {
      final m = item.screenTime.inMinutes;
      total += m;
      if (m > max) max = m;
      if (m < min) min = m;
    }
    _cachedStats = (avg: total ~/ data.length, max: max, min: min);
    return _cachedStats!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showControls) _buildControls(context),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 16),
            child: LineChartWidget(
              chartType: _showAverage ? ChartType.alternate : ChartType.main,
              dailyScreenTimeData: widget.dailyScreenTimeData,
              periodType: widget.periodType,
              onDateSelected: widget.onDateSelected,
            ),
          ),
        ),
        if (widget.dailyScreenTimeData != null &&
            widget.dailyScreenTimeData!.isNotEmpty)
          _buildSummary(context),
      ],
    );
  }

  Widget _buildControls(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildToggleChip(
            label: l10n.chart_average,
            isSelected: _showAverage,
            onTap: () => setState(() => _showAverage = !_showAverage),
            color: const Color(0xFF60A5FA),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final stats = _getStats();
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            label: l10n.chart_average,
            value: _formatMinutes(stats.avg),
            color: const Color(0xFF60A5FA),
          ),
          _buildDivider(),
          _buildStatItem(
            label: l10n.chart_peak,
            value: _formatMinutes(stats.max),
            color: const Color(0xFFF87171),
          ),
          _buildDivider(),
          _buildStatItem(
            label: l10n.chart_lowest,
            value: _formatMinutes(stats.min),
            color: const Color(0xFF34D399),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
  }
}
