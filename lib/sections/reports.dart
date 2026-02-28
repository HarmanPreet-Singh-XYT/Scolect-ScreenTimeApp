import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/main.dart';
import 'package:screentime/sections/graphs/reports_line_chart.dart';
import 'package:screentime/sections/graphs/reports_pie_chart.dart';
import './controller/data_controllers/reports_controller.dart';
import 'package:screentime/sections/UI sections/Reports/application_usage.dart';
import 'package:screentime/sections/UI sections/Reports/top_boxes.dart';
import 'package:screentime/sections/controller/analytics_xlsx_exporter.dart';

enum PeriodType { last7Days, lastMonth, last3Months, lifetime, custom }

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  final UsageAnalyticsController _analyticsController =
      UsageAnalyticsController();
  AnalyticsXLSXExporter? _xlsxExporter;
  AnalyticsSummary? _analyticsSummary;
  bool _isLoading = true;
  bool _isExporting = false;
  String? _error;
  PeriodType _selectedPeriod = PeriodType.last7Days;
  bool _isInitialized = false;

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _specificDate;
  bool _isDateRangeMode = false;
  List<DailyScreenTime> graphData = [];

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _xlsxExporter = AnalyticsXLSXExporter(_analyticsController, _l10n);
      _initializeAndLoadData();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationState.registerRefreshCallback(_loadAnalyticsData);
      });
    }
  }

  // ==================== DATA LOADING ====================

  Future<void> _initializeAndLoadData() async {
    _setLoading();

    try {
      final initialized = await _analyticsController.initialize();
      if (!initialized) {
        _setError(_analyticsController.error ?? _l10n.failedToInitialize);
        return;
      }
      await _loadAnalyticsData();
    } catch (e) {
      _setError(_l10n.unexpectedError(e.toString()));
    }
  }

  Future<void> _loadAnalyticsData() async {
    _setLoading();

    try {
      final summary = await _fetchSummary();
      if (summary != null) {
        graphData = summary.dailyScreenTimeData;
      }
      setState(() {
        _analyticsSummary = summary;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      _setError(_l10n.errorLoadingAnalytics(e.toString()));
    }
  }

  Future<AnalyticsSummary?> _fetchSummary() {
    switch (_selectedPeriod) {
      case PeriodType.last7Days:
        return _analyticsController.getLastSevenDaysAnalytics();
      case PeriodType.lastMonth:
        return _analyticsController.getLastMonthAnalytics();
      case PeriodType.last3Months:
        return _analyticsController.getLastThreeMonthsAnalytics();
      case PeriodType.lifetime:
        return _analyticsController.getLifetimeAnalytics();
      case PeriodType.custom:
        return _fetchCustomSummary();
    }
  }

  Future<AnalyticsSummary?> _fetchCustomSummary() {
    if (_isDateRangeMode && _startDate != null && _endDate != null) {
      return _analyticsController.getSpecificDateRangeAnalytics(
          _startDate!, _endDate!);
    }
    if (!_isDateRangeMode && _specificDate != null) {
      return _analyticsController.getSpecificDayAnalytics(_specificDate!);
    }
    return Future.value(null);
  }

  Future<void> _loadSpecificDay(DateTime date) async {
    _setLoading();
    try {
      final summary = await _analyticsController.getSpecificDayAnalytics(date);
      setState(() {
        _analyticsSummary = summary;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      _setError(_l10n.errorLoadingAnalytics(e.toString()));
    }
  }

  void _setLoading() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
  }

  void _setError(String message) {
    setState(() {
      _error = message;
      _isLoading = false;
    });
  }

  // ==================== PERIOD LABELS ====================

  String _getPeriodLabel(PeriodType period) {
    switch (period) {
      case PeriodType.last7Days:
        return _l10n.last7Days;
      case PeriodType.lastMonth:
        return _l10n.lastMonth;
      case PeriodType.last3Months:
        return _l10n.last3Months;
      case PeriodType.lifetime:
        return _l10n.lifetime;
      case PeriodType.custom:
        return _l10n.custom;
    }
  }

  // ==================== EXPORT ====================

  Future<void> _showExportDialog() async {
    await showDialog(
      context: context,
      builder: (ctx) => _ExportDialog(
        l10n: _l10n,
        onExport: _exportComprehensiveReport,
      ),
    );
  }

  Future<void> _exportComprehensiveReport() async {
    if (_analyticsSummary == null || _xlsxExporter == null) return;

    setState(() => _isExporting = true);

    try {
      final success = await _xlsxExporter!.exportAnalyticsReport(
        summary: _analyticsSummary!,
        periodLabel: _getPeriodLabel(_selectedPeriod),
        startDate: _startDate,
        endDate: _endDate,
      );

      if (success) {
        _showInfoBar(
          title: _l10n.exportSuccessful,
          message: _l10n.beautifulExcelExportSuccess,
          severity: InfoBarSeverity.success,
        );
      }
    } catch (e) {
      _showInfoBar(
        title: _l10n.exportFailed,
        message: _l10n.failedToExportReport(e.toString()),
        severity: InfoBarSeverity.error,
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showInfoBar({
    required String title,
    required String message,
    required InfoBarSeverity severity,
  }) {
    displayInfoBar(context, builder: (context, close) {
      return InfoBar(
        title: Text(title),
        content: Text(message),
        severity: severity,
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
      );
    });
  }

  // ==================== DATE DIALOG ====================

  void _showDateRangeDialog() {
    final now = DateTime.now();
    DateTime startDate = _startDate ?? DateTime(now.year, now.month - 1, 1);
    DateTime endDate = _endDate ?? DateTime(now.year, now.month, now.day);
    DateTime specificDate = _specificDate ?? now;
    bool isRangeMode = _isDateRangeMode;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return ContentDialog(
            title: Text(_l10n.customDialogTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ToggleSwitch(
                        checked: isRangeMode,
                        onChanged: (v) => setDialogState(() => isRangeMode = v),
                      ),
                      const SizedBox(width: 8),
                      Text(isRangeMode ? _l10n.dateRange : _l10n.specificDate),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isRangeMode)
                    _DateRangeFields(
                      l10n: _l10n,
                      startDate: startDate,
                      endDate: endDate,
                      onStartChanged: (d) =>
                          setDialogState(() => startDate = d),
                      onEndChanged: (d) => setDialogState(() => endDate = d),
                    )
                  else
                    _SingleDateField(
                      l10n: _l10n,
                      date: specificDate,
                      onChanged: (d) => setDialogState(() => specificDate = d),
                    ),
                ],
              ),
            ),
            actions: [
              Button(
                child: Text(_l10n.cancel),
                onPressed: () => Navigator.pop(ctx),
              ),
              FilledButton(
                child: Text(_l10n.apply),
                onPressed: () {
                  if (isRangeMode && startDate.isAfter(endDate)) {
                    _showValidationError(ctx);
                    return;
                  }
                  Navigator.pop(ctx);
                  _applyCustomDate(
                    isRangeMode: isRangeMode,
                    startDate: startDate,
                    endDate: endDate,
                    specificDate: specificDate,
                  );
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _showValidationError(BuildContext dialogContext) {
    showDialog(
      context: dialogContext,
      builder: (ctx) => ContentDialog(
        title: Text(_l10n.invalidDateRange),
        content: Text(_l10n.startDateBeforeEndDate),
        actions: [
          Button(
            child: Text(_l10n.ok),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _applyCustomDate({
    required bool isRangeMode,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime specificDate,
  }) {
    setState(() {
      _isDateRangeMode = isRangeMode;
      _selectedPeriod = PeriodType.custom;
      if (isRangeMode) {
        _startDate = startDate;
        _endDate = endDate;
        _specificDate = null;
      } else {
        _specificDate = specificDate;
        _startDate = null;
        _endDate = null;
      }
    });
    _loadAnalyticsData();
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const _LoadingIndicator();
    if (_error != null) {
      return _ErrorDisplay(
        error: _error!,
        onRetry: _initializeAndLoadData,
      );
    }
    final summary = _analyticsSummary;
    if (summary == null) return const SizedBox.shrink();

    return Column(
      children: [
        TopBoxes(analyticsSummary: summary),
        const SizedBox(height: 20),
        _ChartsSection(
          summary: summary,
          graphData: graphData,
          periodLabel: _getPeriodLabel(_selectedPeriod),
          onDateSelected: _loadSpecificDay,
        ),
        const SizedBox(height: 20),
        ApplicationUsage(appUsageDetails: summary.appUsageDetails),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            _l10n.usageAnalytics,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          children: [
            if (_analyticsSummary != null && !_isLoading)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _ExportButton(
                  isExporting: _isExporting,
                  onPressed: _showExportDialog,
                  l10n: _l10n,
                ),
              ),
            ComboBox<PeriodType>(
              value: _selectedPeriod,
              items: PeriodType.values
                  .map((p) => ComboBoxItem<PeriodType>(
                        value: p,
                        child: Text(_getPeriodLabel(p)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value == null || value == _selectedPeriod) return;
                if (value == PeriodType.custom) {
                  _showDateRangeDialog();
                } else {
                  setState(() => _selectedPeriod = value);
                  _loadAnalyticsData();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

// ==================== EXTRACTED STATELESS WIDGETS ====================

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: ProgressRing(strokeWidth: 3),
          ),
          const SizedBox(height: 10),
          Text(l10n.loadingAnalyticsData),
        ],
      ),
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorDisplay({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          Icon(FluentIcons.error, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(error, style: TextStyle(color: Colors.red)),
          const SizedBox(height: 15),
          Button(
            onPressed: onRetry,
            child: Text(l10n.tryAgain),
          ),
        ],
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final bool isExporting;
  final VoidCallback onPressed;
  final AppLocalizations l10n;

  const _ExportButton({
    required this.isExporting,
    required this.onPressed,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isExporting ? null : onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isExporting)
            const SizedBox(
              width: 16,
              height: 16,
              child: ProgressRing(strokeWidth: 2),
            )
          else
            const Icon(FluentIcons.excel_document, size: 16),
          const SizedBox(width: 8),
          Text(isExporting ? l10n.exportingLabel : l10n.exportExcelLabel),
        ],
      ),
    );
  }
}

class _ExportDialog extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onExport;

  const _ExportDialog({required this.l10n, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(l10n.exportAnalyticsReport),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.chooseExportFormat),
          const SizedBox(height: 16),
          ListTile(
            title: Text(l10n.beautifulExcelReport),
            subtitle: Text(l10n.beautifulExcelReportDescription),
            leading: const Icon(FluentIcons.excel_document),
            onPressed: () {
              Navigator.pop(context);
              onExport();
            },
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            l10n.excelReportIncludes,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _FeatureItem(text: l10n.summarySheetDescription),
          _FeatureItem(text: l10n.dailyBreakdownDescription),
          _FeatureItem(text: l10n.appsSheetDescription),
          _FeatureItem(text: l10n.insightsDescription),
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          Icon(FluentIcons.check_mark, size: 12, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _DateRangeFields extends StatelessWidget {
  final AppLocalizations l10n;
  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTime> onStartChanged;
  final ValueChanged<DateTime> onEndChanged;

  const _DateRangeFields({
    required this.l10n,
    required this.startDate,
    required this.endDate,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(l10n.startDate),
            const SizedBox(width: 8),
            Expanded(
              child: DatePicker(selected: startDate, onChanged: onStartChanged),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(l10n.endDate),
            const SizedBox(width: 16),
            Expanded(
              child: DatePicker(selected: endDate, onChanged: onEndChanged),
            ),
          ],
        ),
      ],
    );
  }
}

class _SingleDateField extends StatelessWidget {
  final AppLocalizations l10n;
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _SingleDateField({
    required this.l10n,
    required this.date,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(l10n.date),
        const SizedBox(width: 24),
        Expanded(child: DatePicker(selected: date, onChanged: onChanged)),
      ],
    );
  }
}

class _ChartsSection extends StatelessWidget {
  final AnalyticsSummary summary;
  final List<DailyScreenTime> graphData;
  final String periodLabel;
  final Future<void> Function(DateTime) onDateSelected;

  const _ChartsSection({
    required this.summary,
    required this.graphData,
    required this.periodLabel,
    required this.onDateSelected,
  });

  static const _pieColors = [
    Color.fromRGBO(223, 250, 92, 1),
    Color.fromRGBO(129, 250, 112, 1),
    Color.fromRGBO(129, 182, 205, 1),
    Color.fromRGBO(91, 253, 199, 1),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final lineChart = CardContainer(
          title: l10n.dailyScreenTime,
          child: LineChartWidget(
            chartType: ChartType.main,
            dailyScreenTimeData: graphData,
            periodType: periodLabel,
            onDateSelected: onDateSelected,
          ),
        );

        final pieChart = _buildPieChart(l10n);

        if (constraints.maxWidth < 800) {
          return Column(
            children: [
              lineChart,
              const SizedBox(height: 20),
              pieChart,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: lineChart),
            const SizedBox(width: 20),
            Expanded(flex: 3, child: pieChart),
          ],
        );
      },
    );
  }

  Widget _buildPieChart(AppLocalizations l10n) {
    final dataMap = summary.categoryBreakdown;

    if (dataMap.isEmpty) {
      return CardContainer(
        title: l10n.categoryBreakdown,
        child: Center(child: Text(l10n.noDataAvailable)),
      );
    }

    return CardContainer(
      title: l10n.categoryBreakdown,
      child: ReportsPieChart(dataMap: dataMap, colorList: _pieColors),
    );
  }
}

// ==================== CARD CONTAINER ====================

class CardContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final double maxHeight;

  const CardContainer({
    super.key,
    required this.title,
    required this.child,
    this.maxHeight = 405,
  });

  static const _titleStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.inactiveBackgroundColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: _titleStyle,
            semanticsLabel: AppLocalizations.of(context)!.sectionLabel(title),
          ),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}
