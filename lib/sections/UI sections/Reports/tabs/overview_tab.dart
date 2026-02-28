import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mt;
import 'package:intl/intl.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/data_controllers/applications_data_controller.dart';
import '../../../controller/data_controllers/reports_controller.dart';
import '../../../controller/data_controllers/alerts_limits_data_controller.dart'
    as app_summary_data;
import '../widgets/shared_widgets.dart';

class OverviewTab extends StatelessWidget {
  final AppUsageSummary app;
  final AppLocalizations l10n;
  final app_summary_data.AppUsageSummary appSummary;
  final ApplicationBasicDetail appBasicDetails;
  final ApplicationDetailedData appDetails;
  final FluentThemeData theme;

  const OverviewTab({
    super.key,
    required this.app,
    required this.l10n,
    required this.appSummary,
    required this.appBasicDetails,
    required this.appDetails,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final weeklyData = appDetails.usageTrends.daily;
    final sortedKeys = _sortedDateKeys(weeklyData);
    final weeklyTotal = Duration(
      minutes:
          weeklyData.values.map((d) => d.inMinutes).fold(0, (a, b) => a + b),
    );

    final hasLimit =
        appSummary.limitStatus && appSummary.dailyLimit > Duration.zero;
    final limitProgress = hasLimit
        ? (appBasicDetails.screenTime.inSeconds /
                appSummary.dailyLimit.inSeconds)
            .clamp(0.0, 1.0)
        : 0.0;
    final overLimit =
        hasLimit && appBasicDetails.screenTime > appSummary.dailyLimit;

    String mostActiveDay = '—';
    Duration mostActiveDuration = Duration.zero;
    for (final e in weeklyData.entries) {
      if (e.value > mostActiveDuration) {
        mostActiveDuration = e.value;
        mostActiveDay = _formatDayLabel(e.key, l10n);
      }
    }

    final growthPct = appDetails.comparisons.growthPercentage;
    final isIncrease = growthPct > 0;
    final growthLabel = growthPct == 0
        ? l10n.sameAsLastWeek
        : isIncrease
            ? l10n.moreUsageThanLastWeek(growthPct.abs().toStringAsFixed(1))
            : l10n.lessUsageThanLastWeek(growthPct.abs().toStringAsFixed(1));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                  child: buildStatCard(
                      context,
                      l10n.today,
                      appBasicDetails.formattedScreenTime,
                      FluentIcons.calendar_day,
                      Colors.blue,
                      theme)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildStatCard(
                      context,
                      l10n.dailyLimit,
                      hasLimit
                          ? formatDuration(appSummary.dailyLimit)
                          : l10n.noLimit,
                      FluentIcons.timer,
                      Colors.orange,
                      theme)),
              const SizedBox(width: 10),
              Expanded(
                  child: buildStatCard(
                      context,
                      l10n.weeklyTotal,
                      formatDuration(weeklyTotal),
                      FluentIcons.calendar_week,
                      Colors.purple,
                      theme)),
            ],
          ),
          const SizedBox(height: 12),
          if (hasLimit) ...[
            buildCompactCard(
              context,
              l10n.todaysLimitUsage,
              FluentIcons.timer,
              theme,
              child: _buildLimitProgress(overLimit, limitProgress, appSummary),
            ),
            const SizedBox(height: 12),
          ],
          buildCompactCard(
            context,
            l10n.thisWeekAtAGlance,
            FluentIcons.chart,
            theme,
            child:
                _buildSparkline(weeklyData, sortedKeys, hasLimit, appSummary),
          ),
          const SizedBox(height: 12),
          buildCompactCard(
            context,
            l10n.hourlyActivityHeatmap,
            FluentIcons.clock,
            theme,
            child: _buildHourlyHeatmap(appDetails.hourlyBreakdown),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildCompactCard(
                  context,
                  l10n.sessions,
                  FluentIcons.issue_tracking,
                  theme,
                  child: Column(children: [
                    buildInfoRow(l10n.totalSessions,
                        '${appDetails.sessionBreakdown.totalSessions}', theme),
                    buildInfoRow(
                        l10n.avgSession,
                        formatDuration(
                            appDetails.sessionBreakdown.averageSessionDuration),
                        theme),
                    buildInfoRow(
                        l10n.longestSession,
                        appDetails
                            .sessionBreakdown.formattedLongestSessionDuration,
                        theme),
                  ]),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildCompactCard(
                  context,
                  l10n.thisWeek,
                  FluentIcons.calendar_week,
                  theme,
                  child: Column(children: [
                    buildInfoRow(l10n.mostActive, mostActiveDay, theme),
                    buildInfoRow(l10n.peakUsage,
                        formatDuration(mostActiveDuration), theme),
                    buildInfoRow(
                        l10n.dailyAverage,
                        appDetails.usageInsights.formattedAverageDailyUsage,
                        theme),
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildCompactCard(
                  context,
                  l10n.productivityScore,
                  FluentIcons.like,
                  theme,
                  child: _buildProductivityScore(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildCompactCard(
                  context,
                  l10n.streaks,
                  FluentIcons.lightning_bolt,
                  theme,
                  child: _buildStreakTracker(weeklyData, sortedKeys, hasLimit),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildWeekOverWeekBanner(growthPct, isIncrease, growthLabel),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildLimitProgress(bool overLimit, double limitProgress,
      app_summary_data.AppUsageSummary appSummary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              appBasicDetails.formattedScreenTime,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: overLimit ? Colors.red : Colors.blue),
            ),
            Text(
              formatDuration(appSummary.dailyLimit),
              style: TextStyle(fontSize: 12, color: theme.inactiveColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(children: [
            Container(
                height: 10,
                decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6))),
            FractionallySizedBox(
              widthFactor: limitProgress,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: overLimit
                        ? [Colors.red.light, Colors.red]
                        : limitProgress > 0.75
                            ? [Colors.orange.light, Colors.orange]
                            : [Colors.blue.light, Colors.blue],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 6),
        Text(
          overLimit
              ? l10n.limitExceededBy(formatDuration(
                  appBasicDetails.screenTime - appSummary.dailyLimit))
              : l10n.timeRemaining(formatDuration(
                  appSummary.dailyLimit - appBasicDetails.screenTime)),
          style: TextStyle(
              fontSize: 11,
              color: overLimit ? Colors.red : theme.inactiveColor,
              fontWeight: overLimit ? FontWeight.w600 : FontWeight.normal),
        ),
      ],
    );
  }

  Widget _buildSparkline(
      Map<String, Duration> weeklyData,
      List<String> sortedDates,
      bool hasLimit,
      app_summary_data.AppUsageSummary appSummary) {
    if (sortedDates.isEmpty)
      return Text(l10n.noData, style: TextStyle(color: theme.inactiveColor));

    final limitMinutes =
        hasLimit ? appSummary.dailyLimit.inMinutes.toDouble() : 0.0;
    final maxMins = weeklyData.values
        .map((d) => d.inMinutes.toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);
    final scaleMax = maxMins == 0 ? 1.0 : maxMins;

    return SizedBox(
      height: 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: sortedDates.map((date) {
          final mins = (weeklyData[date] ?? Duration.zero).inMinutes.toDouble();
          final heightFraction = mins / scaleMax;
          final over = hasLimit && limitMinutes > 0 && mins > limitMinutes;
          final isToday = _isToday(date);
          final isPeak = mins == maxMins && maxMins > 0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isToday || isPeak)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        formatMinutesShort(mins),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: over
                              ? Colors.red
                              : isToday
                                  ? theme.accentColor
                                  : Colors.orange,
                        ),
                      ),
                    ),
                  Flexible(
                    child: FractionallySizedBox(
                      heightFactor: heightFraction.clamp(0.04, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: over
                                ? [Colors.red.light, Colors.red]
                                : isToday
                                    ? [
                                        theme.accentColor
                                            .withValues(alpha: 0.7),
                                        theme.accentColor
                                      ]
                                    : [
                                        Colors.blue.withValues(alpha: 0.4),
                                        Colors.blue.withValues(alpha: 0.75)
                                      ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateForAxis(date),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? theme.accentColor : theme.inactiveColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHourlyHeatmap(Map<int, Duration> hourlyBreakdown) {
    final maxSecs = hourlyBreakdown.values
        .map((d) => d.inSeconds.toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int row = 0; row < 2; row++) ...[
          Row(
            children: List.generate(12, (col) {
              final hour = row * 12 + col;
              final secs =
                  (hourlyBreakdown[hour] ?? Duration.zero).inSeconds.toDouble();
              final intensity = maxSecs > 0 ? secs / maxSecs : 0.0;
              final cellColor = intensity == 0
                  ? theme.accentColor.withValues(alpha: 0.06)
                  : Color.lerp(Colors.blue.withValues(alpha: 0.2), Colors.blue,
                      intensity)!;

              return Expanded(
                child: Tooltip(
                  message:
                      '${_formatHour(hour)}: ${formatMinutesShort(secs / 60)}',
                  child: Container(
                    height: 20,
                    margin: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(3)),
                  ),
                ),
              );
            }),
          ),
          if (row == 0) const SizedBox(height: 2),
        ],
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['12a', '6a', '12p', '6p', '11p']
              .map((t) => Text(t,
                  style: TextStyle(fontSize: 9, color: theme.inactiveColor)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildProductivityScore() {
    int score = app.isProductive ? 65 : 35;
    final growth = appDetails.comparisons.growthPercentage;

    if (app.isProductive) {
      if (growth < -10)
        score += 15;
      else if (growth < 0)
        score += 8;
      else if (growth > 20) score -= 10;
    } else {
      if (growth > 10)
        score -= 15;
      else if (growth > 0)
        score -= 8;
      else if (growth < -20) score += 10;
    }
    score = score.clamp(0, 100);

    final scoreColor = score >= 70
        ? Colors.green
        : score >= 45
            ? Colors.orange
            : Colors.red;
    final label = score >= 70
        ? l10n.productivityScoreGreat
        : score >= 45
            ? l10n.productivityScoreModerate
            : l10n.productivityScoreNeedsAttention;

    return Row(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            fit: StackFit.expand,
            children: [
              mt.CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 5,
                backgroundColor: scoreColor.withValues(alpha: 0.15),
                color: scoreColor,
              ),
              Center(
                  child: Text('$score',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: scoreColor))),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: scoreColor)),
              const SizedBox(height: 4),
              Text(
                app.isProductive
                    ? l10n.productiveAppMotivation
                    : l10n.nonProductiveAppSuggestion,
                style: TextStyle(
                    fontSize: 11, color: theme.inactiveColor, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreakTracker(Map<String, Duration> weeklyData,
      List<String> sortedKeys, bool hasLimit) {
    int usedStreak = 0;
    int overLimitStreak = 0;

    for (final date in sortedKeys.reversed) {
      if ((weeklyData[date] ?? Duration.zero) > Duration.zero)
        usedStreak++;
      else
        break;
    }

    if (hasLimit) {
      for (final date in sortedKeys.reversed) {
        if ((weeklyData[date] ?? Duration.zero) > appSummary.dailyLimit)
          overLimitStreak++;
        else
          break;
      }
    }

    return Column(
      children: [
        _streakRow(
            FluentIcons.calendar,
            Colors.blue,
            l10n.daysUsedInARow,
            '$usedStreak ${usedStreak != 1 ? l10n.daysPlural : l10n.daysSingular}',
            null),
        if (hasLimit) ...[
          const SizedBox(height: 10),
          _streakRow(
            overLimitStreak > 0
                ? FluentIcons.warning
                : FluentIcons.shield_alert,
            overLimitStreak > 0 ? Colors.red : Colors.green,
            overLimitStreak > 0
                ? l10n.daysOverLimitInARow
                : l10n.withinLimitAllWeek,
            overLimitStreak > 0
                ? '$overLimitStreak ${overLimitStreak != 1 ? l10n.daysPlural : l10n.daysSingular}'
                : '✓',
            overLimitStreak > 0 ? Colors.red : Colors.green,
          ),
        ],
      ],
    );
  }

  Widget _streakRow(IconData icon, Color iconColor, String label, String value,
      Color? valueColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(label,
                style: TextStyle(fontSize: 11, color: theme.inactiveColor))),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: valueColor ?? theme.accentColor)),
      ],
    );
  }

  Widget _buildWeekOverWeekBanner(
      double growthPct, bool isIncrease, String growthLabel) {
    final color = growthPct == 0
        ? Colors.blue
        : isIncrease
            ? Colors.red
            : Colors.green;
    final icon = growthPct == 0
        ? FluentIcons.subtract_shape
        : isIncrease
            ? FluentIcons.trending12
            : FluentIcons.arrow_down_right8;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.06),
            color.withValues(alpha: 0.02)
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.weekOverWeek,
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.inactiveColor,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(growthLabel,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  List<String> _sortedDateKeys(Map<String, Duration> data) => data.keys.toList()
    ..sort((a, b) {
      try {
        return DateFormat('MM/dd')
            .parse(a)
            .compareTo(DateFormat('MM/dd').parse(b));
      } catch (_) {
        return 0;
      }
    });

  bool _isToday(String dateString) {
    try {
      final d = DateFormat('MM/dd').parse(dateString);
      final now = DateTime.now();
      return d.month == now.month && d.day == now.day;
    } catch (_) {
      return false;
    }
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    return hour < 12 ? '$hour AM' : '${hour - 12} PM';
  }

  String _formatDayLabel(String dateString, AppLocalizations l10n) {
    try {
      final d = DateFormat('MM/dd').parse(dateString);
      final now = DateTime.now();
      if (d.month == now.month && d.day == now.day) return l10n.today;
      if (d.month == now.month && d.day == now.day - 1) return l10n.yesterday;
      return DateFormat('EEEE').format(d);
    } catch (_) {
      return dateString;
    }
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
