import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:screentime/sections/controller/data_controllers/reports_controller.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class AnalyticsXLSXExporter {
  final UsageAnalyticsController _analyticsController;
  final AppLocalizations l10n;

  AnalyticsXLSXExporter(this._analyticsController, this.l10n);

  // Beautiful color palette
  static const _primaryBlue = '#4A90E2';
  static const _accentPurple = '#9B59B6';
  static const _successGreen = '#2ECC71';
  static const _warningOrange = '#F39C12';
  static const _dangerRed = '#E74C3C';
  static const _lightGray = '#ECF0F1';
  static const _headerBg = '#2C3E50';
  static const _productiveColor = '#27AE60';
  static const _unproductiveColor = '#E67E22';

  /// Export comprehensive analytics report to Excel
  Future<bool> exportAnalyticsReport({
    required AnalyticsSummary summary,
    required String periodLabel,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Ask user for save location
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: l10n.saveAnalyticsReport,
        fileName: 'analytics_report_${_getFileTimestamp()}.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputPath == null) {
        return false; // User cancelled
      }

      // Create Excel workbook
      var excel = Excel.createExcel();

      // Create sheets first (this will make Summary the first sheet)
      _createSummarySheet(excel, summary, periodLabel, startDate, endDate);
      _createDailyBreakdownSheet(excel, summary);
      _createAppDetailsSheet(excel, summary);
      _createInsightsSheet(excel, summary);

      // Remove default Sheet1 after creating other sheets
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      // Save file
      var fileBytes = excel.save();
      if (fileBytes != null) {
        File(outputPath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error exporting Excel: $e');
      return false;
    }
  }

  /// Create the main summary sheet
  void _createSummarySheet(
    Excel excel,
    AnalyticsSummary summary,
    String periodLabel,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    var sheet = excel[l10n.sheetSummary];

    int row = 0;

    // Title Section
    _setCell(sheet, 0, row, l10n.usageAnalyticsReportTitle,
        fontSize: 18, bold: true, fontColor: _headerBg);
    _mergeCells(sheet, row, row, 0, 3);
    row += 2;

    // Report Info
    _setCell(sheet, 0, row, l10n.generated, bold: true);
    _setCell(sheet, 1, row,
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));
    row++;

    _setCell(sheet, 0, row, l10n.period, bold: true);
    _setCell(sheet, 1, row, periodLabel);
    row++;

    if (startDate != null && endDate != null) {
      _setCell(sheet, 0, row, l10n.dateRange, bold: true);
      _setCell(
          sheet,
          1,
          row,
          l10n.dateRangeValue(
            DateFormat('yyyy-MM-dd').format(startDate),
            DateFormat('yyyy-MM-dd').format(endDate),
          ));
      row++;
    }
    row += 2;

    // Key Metrics Section
    _setCell(sheet, 0, row, l10n.keyMetrics,
        fontSize: 14, bold: true, bgColor: _primaryBlue, fontColor: '#FFFFFF');
    _mergeCells(sheet, row, row, 0, 3);
    row++;

    // Header row
    _setCell(sheet, 0, row, l10n.metric, bold: true, bgColor: _lightGray);
    _setCell(sheet, 1, row, l10n.value, bold: true, bgColor: _lightGray);
    _setCell(sheet, 2, row, l10n.change, bold: true, bgColor: _lightGray);
    _setCell(sheet, 3, row, l10n.trend, bold: true, bgColor: _lightGray);
    row++;

    // Total Screen Time
    _setCell(sheet, 0, row, l10n.totalScreenTime);
    _setCell(sheet, 1, row, _formatDuration(summary.totalScreenTime),
        bold: true);
    var screenTimeChange = summary.screenTimeComparisonPercent;
    _setCell(sheet, 2, row,
        '${screenTimeChange >= 0 ? "+" : ""}${screenTimeChange.toStringAsFixed(1)}%',
        fontColor: screenTimeChange > 0 ? _dangerRed : _successGreen);
    _setCell(
        sheet, 3, row, screenTimeChange > 0 ? l10n.trendUp : l10n.trendDown);
    row++;

    // Productive Time
    _setCell(sheet, 0, row, l10n.productiveTime);
    _setCell(sheet, 1, row, _formatDuration(summary.productiveTime),
        bold: true, fontColor: _productiveColor);
    var prodTimeChange = summary.productiveTimeComparisonPercent;
    _setCell(sheet, 2, row,
        '${prodTimeChange >= 0 ? "+" : ""}${prodTimeChange.toStringAsFixed(1)}%',
        fontColor: prodTimeChange > 0 ? _successGreen : _dangerRed);
    _setCell(sheet, 3, row, prodTimeChange > 0 ? l10n.trendUp : l10n.trendDown);
    row++;

    // Productivity Percentage
    final productivityPercentage = summary.totalScreenTime.inMinutes > 0
        ? (summary.productiveTime.inMinutes /
            summary.totalScreenTime.inMinutes *
            100)
        : 0.0;
    _setCell(sheet, 0, row, l10n.productivityRate);
    _setCell(sheet, 1, row, '${productivityPercentage.toStringAsFixed(1)}%',
        bold: true,
        fontColor:
            productivityPercentage >= 50 ? _successGreen : _warningOrange);
    _setCell(sheet, 2, row, '');
    _setCell(
        sheet,
        3,
        row,
        productivityPercentage >= 70
            ? l10n.trendExcellent
            : (productivityPercentage >= 50
                ? l10n.trendGood
                : l10n.trendNeedsImprovement));
    row++;

    // Focus Sessions
    _setCell(sheet, 0, row, l10n.focusSessions);
    _setCell(sheet, 1, row, summary.focusSessionsCount.toString(), bold: true);
    var focusChange = summary.focusSessionsComparisonPercent;
    _setCell(sheet, 2, row,
        '${focusChange >= 0 ? "+" : ""}${focusChange.toStringAsFixed(1)}%',
        fontColor: focusChange > 0 ? _successGreen : _dangerRed);
    _setCell(sheet, 3, row,
        summary.focusSessionsCount > 0 ? l10n.trendActive : l10n.trendNone);
    row++;

    // Most Used App
    _setCell(sheet, 0, row, l10n.mostUsedApp);
    _setCell(sheet, 1, row, summary.mostUsedApp, bold: true);
    _setCell(sheet, 2, row, _formatDuration(summary.mostUsedAppTime));
    _setCell(sheet, 3, row, l10n.trendTop);
    row += 3;

    // Category Breakdown Section
    if (summary.categoryBreakdown.isNotEmpty) {
      _setCell(sheet, 0, row, l10n.categoryBreakdown,
          fontSize: 14,
          bold: true,
          bgColor: _accentPurple,
          fontColor: '#FFFFFF');
      _mergeCells(sheet, row, row, 0, 2);
      row++;

      _setCell(sheet, 0, row, l10n.category, bold: true, bgColor: _lightGray);
      _setCell(sheet, 1, row, l10n.percentage, bold: true, bgColor: _lightGray);
      _setCell(sheet, 2, row, l10n.visual, bold: true, bgColor: _lightGray);
      row++;

      final sortedCategories = summary.categoryBreakdown.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (var entry in sortedCategories) {
        _setCell(sheet, 0, row, entry.key);
        _setCell(sheet, 1, row, '${entry.value.toStringAsFixed(1)}%',
            bold: true);

        // Create a simple text-based bar
        var barLength = (entry.value / 5).round();
        var bar = '|' * barLength;
        _setCell(sheet, 2, row, bar, fontColor: _primaryBlue);
        row++;
      }
    }

    // Set column widths
    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 30);
    sheet.setColumnWidth(2, 20);
    sheet.setColumnWidth(3, 20);
  }

  /// Create daily breakdown sheet
  void _createDailyBreakdownSheet(Excel excel, AnalyticsSummary summary) {
    if (summary.dailyScreenTimeData.isEmpty) return;

    var sheet = excel[l10n.sheetDailyBreakdown];
    int row = 0;

    // Title
    _setCell(sheet, 0, row, l10n.dailyScreenTime,
        fontSize: 16, bold: true, fontColor: _headerBg);
    _mergeCells(sheet, row, row, 0, 4);
    row += 2;

    // Statistics
    _setCell(sheet, 0, row, l10n.statistics, bold: true, bgColor: _lightGray);
    _mergeCells(sheet, row, row, 0, 4);
    row++;

    if (summary.dailyScreenTimeData.isNotEmpty) {
      final totalMinutes = summary.dailyScreenTimeData
          .fold(0, (sum, day) => sum + day.screenTime.inMinutes);
      final avgMinutes = totalMinutes / summary.dailyScreenTimeData.length;
      final maxDay = summary.dailyScreenTimeData
          .reduce((a, b) => a.screenTime > b.screenTime ? a : b);
      final minDay = summary.dailyScreenTimeData
          .reduce((a, b) => a.screenTime < b.screenTime ? a : b);

      _setCell(sheet, 0, row, l10n.averageDaily);
      _setCell(
          sheet, 1, row, _formatDuration(Duration(minutes: avgMinutes.round())),
          bold: true, fontSize: 12);
      row++;

      _setCell(sheet, 0, row, l10n.highestDay);
      _setCell(sheet, 1, row, DateFormat('EEEE, MMM d').format(maxDay.date));
      _setCell(sheet, 2, row, _formatDuration(maxDay.screenTime),
          bold: true, fontColor: _dangerRed);
      row++;

      _setCell(sheet, 0, row, l10n.lowestDay);
      _setCell(sheet, 1, row, DateFormat('EEEE, MMM d').format(minDay.date));
      _setCell(sheet, 2, row, _formatDuration(minDay.screenTime),
          bold: true, fontColor: _successGreen);
    }

    row += 3;

    // Data table
    _setCell(sheet, 0, row, l10n.date,
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 1, row, l10n.day,
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 2, row, l10n.hours,
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 3, row, l10n.minutes,
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 4, row, l10n.visual,
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    row++;

    final maxMinutes = summary.dailyScreenTimeData
        .map((d) => d.screenTime.inMinutes)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    for (var dailyData in summary.dailyScreenTimeData) {
      var isWeekend = dailyData.date.weekday == DateTime.saturday ||
          dailyData.date.weekday == DateTime.sunday;

      _setCell(sheet, 0, row, DateFormat('yyyy-MM-dd').format(dailyData.date),
          bgColor: isWeekend ? '#FFF3E0' : null);
      _setCell(sheet, 1, row, DateFormat('EEEE').format(dailyData.date),
          bgColor: isWeekend ? '#FFF3E0' : null);
      _setCell(sheet, 2, row,
          (dailyData.screenTime.inMinutes / 60).toStringAsFixed(2),
          bold: true, bgColor: isWeekend ? '#FFF3E0' : null);
      _setCell(sheet, 3, row, dailyData.screenTime.inMinutes.toString(),
          bgColor: isWeekend ? '#FFF3E0' : null);

      // Visual bar
      var barLength =
          ((dailyData.screenTime.inMinutes / maxMinutes) * 20).round();
      var bar = '|' * barLength;
      var color = dailyData.screenTime.inHours >= 8
          ? _dangerRed
          : dailyData.screenTime.inHours >= 4
              ? _warningOrange
              : _successGreen;
      _setCell(sheet, 4, row, bar,
          fontColor: color, bgColor: isWeekend ? '#FFF3E0' : null);

      row++;
    }

    // Set column widths
    sheet.setColumnWidth(0, 15);
    sheet.setColumnWidth(1, 15);
    sheet.setColumnWidth(2, 12);
    sheet.setColumnWidth(3, 12);
    sheet.setColumnWidth(4, 25);
  }

  /// Create app details sheet
  void _createAppDetailsSheet(Excel excel, AnalyticsSummary summary) {
    if (summary.appUsageDetails.isEmpty) return;

    var sheet = excel[l10n.sheetApps];
    int row = 0;

    // Title
    _setCell(sheet, 0, row, l10n.applicationUsageDetails,
        fontSize: 16, bold: true, fontColor: _headerBg);
    _mergeCells(sheet, row, row, 0, 6);
    row += 2;

    final productiveApps =
        summary.appUsageDetails.where((app) => app.isProductive).length;

    _setCell(sheet, 0, row, l10n.totalApps, bold: true);
    _setCell(sheet, 1, row, summary.appUsageDetails.length.toString());
    _setCell(sheet, 3, row, l10n.productiveApps, bold: true);
    _setCell(sheet, 4, row, '$productiveApps', fontColor: _successGreen);
    row += 2;

    // Header
    _setCell(sheet, 0, row, l10n.rank,
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 1, row, l10n.application,
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 2, row, l10n.category,
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 3, row, l10n.time,
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 4, row, l10n.percentOfTotal,
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 5, row, l10n.type,
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 6, row, l10n.usageLevel,
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    row++;

    int rank = 1;
    final totalMinutes = summary.totalScreenTime.inMinutes;

    for (var appDetail in summary.appUsageDetails) {
      final percentage = totalMinutes > 0
          ? (appDetail.totalTime.inMinutes / totalMinutes * 100)
          : 0.0;

      // Rank with medal for top 3
      var rankText = rank.toString();
      if (rank == 1) rankText = '#1';
      if (rank == 2) rankText = '#2';
      if (rank == 3) rankText = '#3';

      _setCell(sheet, 0, row, rankText, bold: rank <= 3);
      _setCell(sheet, 1, row, appDetail.appName, bold: rank <= 3);
      _setCell(sheet, 2, row, appDetail.category);
      _setCell(sheet, 3, row, _formatDuration(appDetail.totalTime), bold: true);
      _setCell(sheet, 4, row, '${percentage.toStringAsFixed(1)}%');

      // Productive indicator with color
      var typeText = appDetail.isProductive ? l10n.productive : l10n.leisure;
      var typeColor =
          appDetail.isProductive ? _productiveColor : _unproductiveColor;
      _setCell(sheet, 5, row, typeText, fontColor: typeColor, bold: true);

      // Usage level visualization
      String usageLevel;
      String usageColor;
      if (percentage >= 20) {
        usageLevel = l10n.usageLevelVeryHigh;
        usageColor = _dangerRed;
      } else if (percentage >= 10) {
        usageLevel = l10n.usageLevelHigh;
        usageColor = _warningOrange;
      } else if (percentage >= 5) {
        usageLevel = l10n.usageLevelMedium;
        usageColor = _primaryBlue;
      } else {
        usageLevel = l10n.usageLevelLow;
        usageColor = _successGreen;
      }
      _setCell(sheet, 6, row, usageLevel, fontColor: usageColor);

      rank++;
      row++;
    }

    // Set column widths
    sheet.setColumnWidth(0, 8);
    sheet.setColumnWidth(1, 30);
    sheet.setColumnWidth(2, 18);
    sheet.setColumnWidth(3, 12);
    sheet.setColumnWidth(4, 12);
    sheet.setColumnWidth(5, 15);
    sheet.setColumnWidth(6, 20);
  }

  /// Create insights sheet
  void _createInsightsSheet(Excel excel, AnalyticsSummary summary) {
    var sheet = excel[l10n.sheetInsights];
    int row = 0;

    // Title
    _setCell(sheet, 0, row, l10n.keyInsightsTitle,
        fontSize: 16, bold: true, fontColor: _headerBg);
    _mergeCells(sheet, row, row, 0, 2);
    row += 2;

    final insights = _generateInsights(summary);

    for (var insight in insights) {
      // Determine indicator and color based on insight content
      String indicator = '*';
      String? bgColor;

      if (insight.contains(l10n.trendExcellent) ||
          insight.contains(l10n.trendGood)) {
        indicator = '[+]';
        bgColor = '#E8F5E9';
      } else if (insight.contains(l10n.directionIncreased)) {
        indicator = '[^]';
        bgColor = '#FCE4EC';
      } else if (insight.contains(l10n.directionDecreased)) {
        indicator = '[v]';
        bgColor = '#F3E5F5';
      }

      _setCell(sheet, 0, row, indicator, fontSize: 14, bold: true);
      _setCell(sheet, 1, row, insight, bgColor: bgColor);
      _mergeCells(sheet, row, row, 1, 2);
      row += 2;
    }

    row += 2;

    // Recommendations section
    _setCell(sheet, 0, row, l10n.personalizedRecommendations,
        fontSize: 14, bold: true, bgColor: _accentPurple, fontColor: '#FFFFFF');
    _mergeCells(sheet, row, row, 0, 2);
    row += 2;

    final recommendations = _generateRecommendations(summary);
    int recNum = 1;
    for (var rec in recommendations) {
      _setCell(sheet, 0, row, '$recNum.',
          fontColor: _accentPurple, fontSize: 12, bold: true);
      _setCell(sheet, 1, row, rec, bgColor: '#F5F5F5');
      _mergeCells(sheet, row, row, 1, 2);
      row += 2;
      recNum++;
    }

    // Set column widths
    sheet.setColumnWidth(0, 8);
    sheet.setColumnWidth(1, 50);
    sheet.setColumnWidth(2, 30);
  }

  /// Generate insights based on the data
  List<String> _generateInsights(AnalyticsSummary summary) {
    List<String> insights = [];

    // Screen time insights
    final hoursPerDay = summary.dailyScreenTimeData.isNotEmpty
        ? summary.totalScreenTime.inHours / summary.dailyScreenTimeData.length
        : 0;

    if (hoursPerDay > 8) {
      insights.add(l10n.insightHighDailyUsage(hoursPerDay.toStringAsFixed(1)));
    } else if (hoursPerDay < 2) {
      insights.add(l10n.insightLowDailyUsage(hoursPerDay.toStringAsFixed(1)));
    } else {
      insights.add(l10n.insightModerateUsage(hoursPerDay.toStringAsFixed(1)));
    }

    // Productivity insights
    final productivityPercentage = summary.totalScreenTime.inMinutes > 0
        ? (summary.productiveTime.inMinutes /
            summary.totalScreenTime.inMinutes *
            100)
        : 0.0;

    if (productivityPercentage >= 70) {
      insights.add(l10n.insightExcellentProductivity(
          productivityPercentage.toStringAsFixed(0)));
    } else if (productivityPercentage >= 50) {
      insights.add(l10n
          .insightGoodProductivity(productivityPercentage.toStringAsFixed(0)));
    } else if (productivityPercentage < 30 &&
        summary.totalScreenTime.inMinutes > 0) {
      insights.add(l10n
          .insightLowProductivity(productivityPercentage.toStringAsFixed(0)));
    }

    // Focus session insights
    if (summary.focusSessionsCount > 0) {
      final daysWithData = summary.dailyScreenTimeData.length;
      final avgSessionsPerDay =
          daysWithData > 0 ? summary.focusSessionsCount / daysWithData : 0;
      insights.add(l10n.insightFocusSessions(
          summary.focusSessionsCount, avgSessionsPerDay.toStringAsFixed(1)));

      if (summary.focusSessionsCount >= 20) {
        insights.add(l10n.insightGreatFocusHabit(summary.focusSessionsCount));
      }
    } else {
      insights.add(l10n.insightNoFocusSessions);
    }

    // Comparison insights
    if (summary.screenTimeComparisonPercent.abs() > 10) {
      final direction = summary.screenTimeComparisonPercent > 0
          ? l10n.directionIncreased
          : l10n.directionDecreased;
      insights.add(l10n.insightScreenTimeTrend(direction,
          summary.screenTimeComparisonPercent.abs().toStringAsFixed(0)));
    }

    if (summary.productiveTimeComparisonPercent.abs() > 10) {
      final direction = summary.productiveTimeComparisonPercent > 0
          ? l10n.directionIncreased
          : l10n.directionDecreased;
      insights.add(l10n.insightProductiveTimeTrend(direction,
          summary.productiveTimeComparisonPercent.abs().toStringAsFixed(0)));
    }

    // Category insights
    if (summary.categoryBreakdown.isNotEmpty) {
      final topCategory = summary.categoryBreakdown.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      insights.add(l10n.insightTopCategory(
          topCategory.key, topCategory.value.toStringAsFixed(0)));
    }

    // App usage insights
    if (summary.mostUsedApp != "None" &&
        summary.mostUsedAppTime.inMinutes > 0) {
      final percentage = summary.totalScreenTime.inMinutes > 0
          ? (summary.mostUsedAppTime.inMinutes /
              summary.totalScreenTime.inMinutes *
              100)
          : 0.0;
      insights.add(l10n.insightMostUsedApp(
          summary.mostUsedApp,
          percentage.toStringAsFixed(0),
          _formatDuration(summary.mostUsedAppTime)));
    }

    // Daily pattern insights
    if (summary.dailyScreenTimeData.isNotEmpty) {
      final sortedDays = summary.dailyScreenTimeData.toList()
        ..sort((a, b) => b.screenTime.compareTo(a.screenTime));

      if (sortedDays.length >= 2) {
        final highestDay = sortedDays.first;
        final lowestDay = sortedDays.last;

        if (highestDay.screenTime.inMinutes >
            lowestDay.screenTime.inMinutes * 2) {
          insights.add(l10n.insightUsageVaries(
              DateFormat('EEEE').format(highestDay.date),
              (highestDay.screenTime.inMinutes / lowestDay.screenTime.inMinutes)
                  .toStringAsFixed(1),
              DateFormat('EEEE').format(lowestDay.date)));
        }
      }
    }

    return insights.isEmpty ? [l10n.insightNoInsights] : insights;
  }

  /// Generate personalized recommendations
  List<String> _generateRecommendations(AnalyticsSummary summary) {
    List<String> recommendations = [];

    final productivityPercentage = summary.totalScreenTime.inMinutes > 0
        ? (summary.productiveTime.inMinutes /
            summary.totalScreenTime.inMinutes *
            100)
        : 0.0;

    if (productivityPercentage < 50) {
      recommendations.add(l10n.recScheduleFocusSessions);
      recommendations.add(l10n.recSetAppLimits);
    }

    if (summary.focusSessionsCount < 5 &&
        summary.dailyScreenTimeData.length >= 7) {
      recommendations.add(l10n.recAimForFocusSessions);
    }

    final hoursPerDay = summary.dailyScreenTimeData.isNotEmpty
        ? summary.totalScreenTime.inHours / summary.dailyScreenTimeData.length
        : 0;

    if (hoursPerDay > 8) {
      recommendations.add(l10n.recTakeBreaks);
      recommendations.add(l10n.recSetDailyGoals);
    }

    if (summary.categoryBreakdown.isNotEmpty) {
      final entertainment = summary.categoryBreakdown.entries
          .where((e) =>
              e.key.toLowerCase().contains('entertainment') ||
              e.key.toLowerCase().contains('social') ||
              e.key.toLowerCase().contains('leisure'))
          .fold(0.0, (sum, e) => sum + e.value);

      if (entertainment > 40) {
        recommendations.add(l10n.recBalanceEntertainment);
      }
    }

    if (summary.screenTimeComparisonPercent > 20) {
      recommendations.add(l10n.recReviewUsagePatterns);
    }

    if (summary.productiveTimeComparisonPercent < -20) {
      recommendations.add(l10n.recScheduleFocusedWork);
    }

    if (recommendations.isEmpty) {
      recommendations.add(l10n.recKeepUpGreatWork);
      recommendations.add(l10n.recContinueFocusSessions);
    }

    return recommendations;
  }

  /// Helper method to set cell value and formatting
  void _setCell(
    Sheet sheet,
    int col,
    int row,
    dynamic value, {
    bool bold = false,
    int fontSize = 11,
    String? bgColor,
    String? fontColor,
  }) {
    var cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
    );
    cell.value = TextCellValue(value.toString());

    // Build CellStyle with only non-null values
    CellStyle style;

    if (bgColor != null && fontColor != null) {
      style = CellStyle(
        bold: bold,
        fontSize: fontSize,
        backgroundColorHex: ExcelColor.fromHexString(bgColor),
        fontColorHex: ExcelColor.fromHexString(fontColor),
      );
    } else if (bgColor != null) {
      style = CellStyle(
        bold: bold,
        fontSize: fontSize,
        backgroundColorHex: ExcelColor.fromHexString(bgColor),
      );
    } else if (fontColor != null) {
      style = CellStyle(
        bold: bold,
        fontSize: fontSize,
        fontColorHex: ExcelColor.fromHexString(fontColor),
      );
    } else {
      style = CellStyle(
        bold: bold,
        fontSize: fontSize,
      );
    }

    cell.cellStyle = style;
  }

  /// Helper to merge cells
  void _mergeCells(
      Sheet sheet, int startRow, int endRow, int startCol, int endCol) {
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: startCol, rowIndex: startRow),
      CellIndex.indexByColumnRow(columnIndex: endCol, rowIndex: endRow),
    );
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return l10n.durationHoursMinutes(hours, minutes);
    } else {
      return l10n.durationMinutesOnly(minutes);
    }
  }

  /// Get timestamp for filename
  String _getFileTimestamp() {
    return DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  }
}
