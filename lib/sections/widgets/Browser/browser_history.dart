import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' show Colors;
import 'package:screentime/l10n/app_localizations.dart';
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
  List<WebsiteBasicDetail> _selectedDaySites = [];
  bool _isLoading = true;
  bool _loadingDaySites = false;
  int _selectedIndex = -1;
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
    if (!mounted) return;

    final reversed = data.reversed.toList();
    final defaultIndex = reversed.isNotEmpty ? reversed.length - 1 : -1;

    setState(() {
      _history = reversed;
      _isLoading = false;
      _selectedIndex = defaultIndex;
    });

    if (defaultIndex >= 0) {
      _loadDaySites(reversed[defaultIndex].date);
    }
  }

  Future<void> _loadDaySites(String dateKey) async {
    final dt = DateTime.tryParse(dateKey);
    if (dt == null) return;
    setState(() => _loadingDaySites = true);
    try {
      final sites = await _provider.fetchWebsitesForDate(dt);
      if (!mounted) return;
      setState(() {
        _selectedDaySites = sites;
        _loadingDaySites = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingDaySites = false);
    }
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
    if (_history.isEmpty) {
      return (date: '–', totalTime: Duration.zero, siteCount: 0);
    }
    return _history.reduce((a, b) => a.totalTime >= b.totalTime ? a : b);
  }

  int get _activeDays =>
      _history.where((d) => d.totalTime > Duration.zero).length;

  // ── Day label helpers ──────────────────────────────────────────────────────

  String _shortLabel(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length < 3) return dateKey;
    final month = int.tryParse(parts[1]) ?? 0;
    final day = int.tryParse(parts[2]) ?? 0;
    const months = [
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
    final dt = DateTime.tryParse(dateKey);
    if (dt == null) return '';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(dt.weekday - 1) % 7];
  }

  String _fullDateLabel(String dateKey) {
    final dt = DateTime.tryParse(dateKey);
    if (dt == null) return dateKey;
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return '${days[(dt.weekday - 1) % 7]}, ${months[dt.month]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final accent = theme.accentColor;
    final captionColor = theme.typography.caption?.color;

    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    final hasData = _history.any((d) => d.totalTime > Duration.zero);
    final peak = _peakDay;
    final selectedDay = (_selectedIndex >= 0 && _selectedIndex < _history.length)
        ? _history[_selectedIndex]
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header + range picker ────────────────────────────────────────
          LayoutBuilder(
            builder: (context, headerConstraints) {
              final isNarrowHeader = headerConstraints.maxWidth < 520;
              final headerTitle = BrowserSectionHeader(
                icon: FluentIcons.history,
                title: l10n.browserHistoryTitle,
                subtitle: 'Historical web activity across the last $_days days',
                color: theme.accentColor,
              );

              final controls = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
              );

              if (isNarrowHeader) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerTitle,
                    const SizedBox(height: 10),
                    controls,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: headerTitle),
                  controls,
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // ── Summary cards ────────────────────────────────────────────────
          LayoutBuilder(
            builder: (context, summaryConstraints) {
              final width = summaryConstraints.maxWidth;

              final card1 = BrowserCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    BrowserGradientIconBox(
                      icon: FluentIcons.calendar_week,
                      color: accent,
                      size: 17,
                      boxSize: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${l10n.browserPeriodTotal} (${_days}d)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: captionColor?.withValues(alpha: 0.65),
                            ),
                          ),
                          Text(
                            _totalTime.toHourMinuteFormat(),
                            style: theme.typography.bodyStrong?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              final card2 = BrowserCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    BrowserGradientIconBox(
                      icon: FluentIcons.trending12,
                      color: kBrowserBlue,
                      size: 17,
                      boxSize: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.browserHistoryAvgPerDay,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: captionColor?.withValues(alpha: 0.65),
                            ),
                          ),
                          Text(
                            _avgPerDay.toHourMinuteFormat(),
                            style: theme.typography.bodyStrong?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              final card3 = BrowserCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    BrowserGradientIconBox(
                      icon: FluentIcons.trophy,
                      color: kBrowserAmber,
                      size: 17,
                      boxSize: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.browserHistoryPeakDay,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: captionColor?.withValues(alpha: 0.65),
                            ),
                          ),
                          Text(
                            peak.totalTime > Duration.zero
                                ? '${_shortLabel(peak.date)} · ${peak.totalTime.toHourMinuteFormat()}'
                                : '–',
                            style: theme.typography.bodyStrong?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              final card4 = BrowserCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    BrowserGradientIconBox(
                      icon: FluentIcons.check_mark,
                      color: kBrowserGreen,
                      size: 17,
                      boxSize: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.browserActiveDays,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: captionColor?.withValues(alpha: 0.65),
                            ),
                          ),
                          Text(
                            '$_activeDays / $_days ${l10n.browserDays}',
                            style: theme.typography.bodyStrong?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              if (width >= 620) {
                return Row(
                  children: [
                    Expanded(child: card1),
                    const SizedBox(width: 12),
                    Expanded(child: card2),
                    const SizedBox(width: 12),
                    Expanded(child: card3),
                    const SizedBox(width: 12),
                    Expanded(child: card4),
                  ],
                );
              } else if (width >= 380) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: card1),
                        const SizedBox(width: 12),
                        Expanded(child: card2),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: card3),
                        const SizedBox(width: 12),
                        Expanded(child: card4),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    card1,
                    const SizedBox(height: 8),
                    card2,
                    const SizedBox(height: 8),
                    card3,
                    const SizedBox(height: 8),
                    card4,
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 18),

          // ── Bar chart Card ───────────────────────────────────────────────
          BrowserCard(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: !hasData
                ? BrowserEmptyState(
                    icon: FluentIcons.history,
                    title: l10n.browserHistoryNoData,
                    subtitle: l10n.browserNoWebsitesDesktopSubtitle,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.browserHistoryTitle,
                            style: theme.typography.bodyStrong?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                l10n.browserDayInspectorPrompt,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: captionColor?.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 220,
                        child: _BarChart(
                          history: _history,
                          selectedIndex: _selectedIndex,
                          onSelect: (i) {
                            if (i >= 0 && i < _history.length) {
                              setState(() => _selectedIndex = i);
                          _loadDaySites(_history[i].date);
                            }
                          },
                          accent: accent,
                          captionColor: captionColor,
                          shortLabel: _shortLabel,
                          dayOfWeek: _dayOfWeek,
                        ),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 18),

          // ── Day Inspector ────────────────────────────────────────────────
          if (selectedDay != null) ...[
            BrowserCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, inspectorHeaderConstraints) {
                      final isNarrow = inspectorHeaderConstraints.maxWidth < 480;

                      final avatarAndText = Row(
                        children: [
                          BrowserDomainAvatar(
                            domain: selectedDay.date,
                            siteName: _dayOfWeek(selectedDay.date),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fullDateLabel(selectedDay.date),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${selectedDay.siteCount} websites visited · ${selectedDay.totalTime.toHourMinuteFormat()} active time',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: captionColor?.withValues(alpha: 0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );

                      final statChip = BrowserStatChip(
                        label: selectedDay.totalTime > _avgPerDay
                            ? l10n.browserVsAverage('+${((selectedDay.totalTime.inSeconds - _avgPerDay.inSeconds) / (_avgPerDay.inSeconds > 0 ? _avgPerDay.inSeconds : 1) * 100).round()}')
                            : l10n.browserVsAverage('${((selectedDay.totalTime.inSeconds - _avgPerDay.inSeconds) / (_avgPerDay.inSeconds > 0 ? _avgPerDay.inSeconds : 1) * 100).round()}'),
                        color: selectedDay.totalTime > _avgPerDay
                            ? kBrowserAmber
                            : kBrowserGreen,
                      );

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            avatarAndText,
                            const SizedBox(height: 8),
                            statChip,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: avatarAndText),
                          const SizedBox(width: 12),
                          statChip,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_loadingDaySites)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: ProgressRing(),
                      ),
                    )
                  else if (_selectedDaySites.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'No individual site records logged for this day.',
                          style: TextStyle(
                            fontSize: 12,
                            color: captionColor?.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _selectedDaySites.take(6).map((site) {
                        final catMeta = CategoryMeta.fromName(site.category);
                        final dayTotalSecs = selectedDay.totalTime.inSeconds;
                        final share = dayTotalSecs > 0
                            ? (site.timeSpent.inSeconds / dayTotalSecs).clamp(0.0, 1.0)
                            : 0.0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : theme.inactiveBackgroundColor.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: LayoutBuilder(
                              builder: (context, itemConstraints) {
                                final isItemNarrow = itemConstraints.maxWidth < 450;

                                if (isItemNarrow) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          BrowserDomainAvatar(
                                            domain: site.domain,
                                            siteName: site.siteName,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              site.displayName,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            site.formattedTimeSpent,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: theme.accentColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: BrowserProgressBar(
                                              fraction: share,
                                              color: catMeta.color,
                                              height: 3,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          BrowserStatChip(
                                            label: site.category,
                                            color: catMeta.color,
                                            icon: catMeta.icon,
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    BrowserDomainAvatar(
                                      domain: site.domain,
                                      siteName: site.siteName,
                                      size: 26,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            site.displayName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          BrowserProgressBar(
                                            fraction: share,
                                            color: catMeta.color,
                                            height: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    BrowserStatChip(
                                      label: site.category,
                                      color: catMeta.color,
                                      icon: catMeta.icon,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      site.formattedTimeSpent,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: theme.accentColor,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Bar chart ────────────────────────────────────────────────────────────────

class _BarChart extends StatelessWidget {
  final List<({String date, Duration totalTime, int siteCount})> history;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Color accent;
  final Color? captionColor;
  final String Function(String) shortLabel;
  final String Function(String) dayOfWeek;

  const _BarChart({
    required this.history,
    required this.selectedIndex,
    required this.onSelect,
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
                    text: '\n${day.siteCount} sites visited',
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
            if (event is FlTapUpEvent) {
              final idx = response?.spot?.touchedBarGroupIndex ?? -1;
              if (idx >= 0) onSelect(idx);
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
                if (i < 0 || i >= history.length) {
                  return const SizedBox.shrink();
                }
                final day = history[i];
                final isSelected = i == selectedIndex;
                return GestureDetector(
                  onTap: () => onSelect(i),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dayOfWeek(day.date),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected
                                ? accent
                                : captionColor?.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          shortLabel(day.date),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? accent
                                : captionColor?.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
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
          final isSelected = i == selectedIndex;
          final isToday = i == history.length - 1;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: day.totalTime.inSeconds.toDouble(),
                width: history.length <= 7 ? 34 : (history.length <= 14 ? 20 : 12),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
                gradient: LinearGradient(
                  colors: isSelected
                      ? [accent, accent.withValues(alpha: 0.8)]
                      : isToday
                          ? [
                              accent.withValues(alpha: 0.75),
                              accent.withValues(alpha: 0.45)
                            ]
                          : [
                              accent.withValues(alpha: 0.45),
                              accent.withValues(alpha: 0.2),
                            ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ],
            showingTooltipIndicators: isSelected ? [0] : [],
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
    final isDark = theme.brightness == Brightness.dark;
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
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: kBrowserHoverDuration,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: sel
                      ? (isDark
                          ? accent.withValues(alpha: 0.25)
                          : accent.withValues(alpha: 0.15))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    color: sel
                        ? accent
                        : theme.typography.caption?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
