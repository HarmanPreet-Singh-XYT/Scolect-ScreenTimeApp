import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_data_controller.dart';

class FocusAnalyticsService {
  final AppDataStore _dataStore;

  static final FocusAnalyticsService _instance =
      FocusAnalyticsService._internal();

  factory FocusAnalyticsService() => _instance;

  FocusAnalyticsService._internal() : _dataStore = AppDataStore();

  // Cached DateFormat instances (avoid re-creating per call)
  static final _dateFormat = DateFormat('yyyy-MM-dd');
  static final _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final _dayOfWeekFormat = DateFormat('EEEE');
  static final _monthYearFormat = DateFormat('MMM yyyy');

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION TYPE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  static const _pomodoroTags = {
    'POMODORO_WORK',
    'POMODORO_SHORT_BREAK',
    'POMODORO_LONG_BREAK',
  };

  static const _sessionTypeLabels = {
    'POMODORO_WORK': 'Work Session',
    'POMODORO_SHORT_BREAK': 'Short Break',
    'POMODORO_LONG_BREAK': 'Long Break',
  };

  String _getSessionType(List<String>? appsBlocked) {
    if (appsBlocked == null || appsBlocked.isEmpty) return 'LEGACY_SESSION';

    for (final tag in appsBlocked) {
      if (_pomodoroTags.contains(tag)) return tag;
    }

    return 'REGULAR_FOCUS';
  }

  String _getSessionTypeLabel(String sessionType) =>
      _sessionTypeLabels[sessionType] ?? 'Focus Session';

  bool _isPomodoroPhase(String sessionType) =>
      _pomodoroTags.contains(sessionType);
  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED: Get completed sessions once for a date range
  // ═══════════════════════════════════════════════════════════════════════════

  List<FocusSessionRecord> _getCompletedSessions(
      DateTime startDate, DateTime endDate) {
    if (!_dataStore.isInitialized) return const [];
    return _dataStore
        .getFocusSessionsRange(startDate, endDate)
        .where((s) => s.completed)
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COMBINED ANALYTICS: Single pass for time distribution + counts
  // ═══════════════════════════════════════════════════════════════════════════

  /// Computes all session-level analytics in a single pass.
  /// Returns time distribution, session counts, work phase counts,
  /// and per-day breakdowns simultaneously.
  _SessionAnalytics _analyzeSessionsBatch(
    List<FocusSessionRecord> completedSessions,
    DateTime startDate,
    DateTime endDate,
  ) {
    Duration workTime = Duration.zero;
    Duration shortBreakTime = Duration.zero;
    Duration longBreakTime = Duration.zero;
    int completeSessionCount = 0;
    int workPhaseCount = 0;

    final sessionCountByDay = <String, int>{};
    final workPhaseCountByDay = <String, int>{};

    // Initialize all days
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    while (!current.isAfter(end)) {
      final dateKey = _dateFormat.format(current);
      sessionCountByDay[dateKey] = 0;
      workPhaseCountByDay[dateKey] = 0;
      current = current.add(const Duration(days: 1));
    }

    // Single pass through all sessions
    for (final session in completedSessions) {
      final sessionType = _getSessionType(session.appsBlocked);
      final dateKey = _dateFormat.format(session.date);

      switch (sessionType) {
        case 'POMODORO_WORK':
          workTime += session.duration;
          workPhaseCount++;
          workPhaseCountByDay.update(dateKey, (v) => v + 1, ifAbsent: () => 1);
          break;
        case 'POMODORO_SHORT_BREAK':
          shortBreakTime += session.duration;
          break;
        case 'POMODORO_LONG_BREAK':
          longBreakTime += session.duration;
          completeSessionCount++;
          sessionCountByDay.update(dateKey, (v) => v + 1, ifAbsent: () => 1);
          break;
        case 'LEGACY_SESSION':
        case 'REGULAR_FOCUS':
          workTime += session.duration;
          sessionCountByDay.update(dateKey, (v) => v + 1, ifAbsent: () => 1);
          break;
      }
    }

    return _SessionAnalytics(
      workTime: workTime,
      shortBreakTime: shortBreakTime,
      longBreakTime: longBreakTime,
      completeSessionCount: completeSessionCount,
      workPhaseCount: workPhaseCount,
      sessionCountByDay: sessionCountByDay,
      workPhaseCountByDay: workPhaseCountByDay,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TIME DISTRIBUTION
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> getTimeDistribution({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return _emptyTimeDistribution;

    try {
      final sessions = _getCompletedSessions(startDate, endDate);
      if (sessions.isEmpty) return _emptyTimeDistribution;

      final analytics = _analyzeSessionsBatch(sessions, startDate, endDate);
      return analytics.toTimeDistributionMap();
    } catch (e) {
      debugPrint('Error getting time distribution: $e');
      return _emptyTimeDistribution;
    }
  }

  static final Map<String, dynamic> _emptyTimeDistribution = {
    'workTime': Duration.zero,
    'shortBreakTime': Duration.zero,
    'longBreakTime': Duration.zero,
    'totalTime': Duration.zero,
    'workPercentage': 0.0,
    'shortBreakPercentage': 0.0,
    'longBreakPercentage': 0.0,
    'formattedWorkTime': '0 min',
    'formattedShortBreakTime': '0 min',
    'formattedLongBreakTime': '0 min',
    'formattedTotalTime': '0 min',
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION COUNTING
  // ═══════════════════════════════════════════════════════════════════════════

  int getCompletePomodoroSessionCount({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return 0;

    try {
      final sessions = _getCompletedSessions(startDate, endDate);
      int count = 0;
      for (final session in sessions) {
        if (_getSessionType(session.appsBlocked) == 'POMODORO_LONG_BREAK') {
          count++;
        }
      }
      return count;
    } catch (e) {
      debugPrint('Error counting complete sessions: $e');
      return 0;
    }
  }

  int getWorkPhaseCount({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return 0;

    try {
      final sessions = _getCompletedSessions(startDate, endDate);
      int count = 0;
      for (final session in sessions) {
        if (_getSessionType(session.appsBlocked) == 'POMODORO_WORK') {
          count++;
        }
      }
      return count;
    } catch (e) {
      debugPrint('Error counting work phases: $e');
      return 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION COUNT BY DAY
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, int> getSessionCountByDay({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return {};

    try {
      final sessions = _getCompletedSessions(startDate, endDate);
      final analytics = _analyzeSessionsBatch(sessions, startDate, endDate);
      return analytics.sessionCountByDay;
    } catch (e) {
      debugPrint('Error getting session count by day: $e');
      return {};
    }
  }

  Map<String, int> getWorkPhaseCountByDay({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return {};

    try {
      final sessions = _getCompletedSessions(startDate, endDate);
      final analytics = _analyzeSessionsBatch(sessions, startDate, endDate);
      return analytics.workPhaseCountByDay;
    } catch (e) {
      debugPrint('Error getting work phase count by day: $e');
      return {};
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION HISTORY
  // ═══════════════════════════════════════════════════════════════════════════

  List<Map<String, dynamic>> getSessionHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return const [];

    try {
      final sessions = _dataStore.getFocusSessionsRange(startDate, endDate);
      final sessionsByDate = <String, List<FocusSessionRecord>>{};

      for (final session in sessions) {
        if (!session.completed) continue;
        final dateKey = _dateFormat.format(session.date);
        sessionsByDate.putIfAbsent(dateKey, () => []).add(session);
      }

      final result = <Map<String, dynamic>>[];

      for (final entry in sessionsByDate.entries) {
        final daySessions = entry.value
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

        for (int i = 0; i < daySessions.length; i++) {
          final session = daySessions[i];
          final sessionType = _getSessionType(session.appsBlocked);

          result.add({
            'date': _dateTimeFormat.format(session.startTime),
            'duration': _formatDuration(session.duration),
            'totalMinutes': session.duration.inMinutes,
            'sessionType': sessionType,
            'sessionTypeLabel': _getSessionTypeLabel(sessionType),
            'isPomodoroPhase': _isPomodoroPhase(sessionType),
            'appsBlocked': session.appsBlocked,
            'rawSession': session,
            'sessionDate': session.date,
            'sessionIndex': i,
            'dateKey': entry.key,
          });
        }
      }

      result
          .sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
      return result;
    } catch (e) {
      debugPrint('Error getting session history: $e');
      return const [];
    }
  }

  List<Map<String, dynamic>> getGroupedPomodoroSessions({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return const [];

    try {
      final allSessions = _getCompletedSessions(startDate, endDate)
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

      final groupedSessions = <Map<String, dynamic>>[];
      var currentGroup = <FocusSessionRecord>[];

      for (final session in allSessions) {
        final sessionType = _getSessionType(session.appsBlocked);

        if (!_isPomodoroPhase(sessionType)) {
          groupedSessions.add({
            'type': 'regular_focus',
            'startTime': session.startTime,
            'totalDuration': session.duration,
            'workDuration': session.duration,
            'breakDuration': Duration.zero,
            'phases': 1,
            'isComplete': true,
          });
          continue;
        }

        currentGroup.add(session);

        if (sessionType == 'POMODORO_LONG_BREAK') {
          groupedSessions.add(_summarizeGroup(currentGroup));
          currentGroup = [];
        }
      }

      if (currentGroup.isNotEmpty) {
        groupedSessions.add(_summarizeGroup(currentGroup, isComplete: false));
      }

      groupedSessions.sort((a, b) =>
          (b['startTime'] as DateTime).compareTo(a['startTime'] as DateTime));

      return groupedSessions;
    } catch (e) {
      debugPrint('Error getting grouped sessions: $e');
      return const [];
    }
  }

  Map<String, dynamic> _summarizeGroup(
    List<FocusSessionRecord> group, {
    bool isComplete = true,
  }) {
    if (group.isEmpty) {
      return {
        'type': 'pomodoro',
        'startTime': DateTime.now(),
        'totalDuration': Duration.zero,
        'workDuration': Duration.zero,
        'breakDuration': Duration.zero,
        'phases': 0,
        'isComplete': false,
      };
    }

    Duration workDuration = Duration.zero;
    Duration breakDuration = Duration.zero;
    int workPhases = 0;
    int breakPhases = 0;

    for (final session in group) {
      final sessionType = _getSessionType(session.appsBlocked);

      if (sessionType == 'POMODORO_WORK') {
        workDuration += session.duration;
        workPhases++;
      } else if (sessionType == 'POMODORO_SHORT_BREAK' ||
          sessionType == 'POMODORO_LONG_BREAK') {
        breakDuration += session.duration;
        breakPhases++;
      }
    }

    final totalDuration = workDuration + breakDuration;

    return {
      'type': 'pomodoro',
      'startTime': group.first.startTime,
      'endTime': group.last.startTime.add(group.last.duration),
      'totalDuration': totalDuration,
      'workDuration': workDuration,
      'breakDuration': breakDuration,
      'workPhases': workPhases,
      'breakPhases': breakPhases,
      'phases': group.length,
      'isComplete': isComplete,
      'formattedTotalDuration': _formatDuration(totalDuration),
      'formattedWorkDuration': _formatDuration(workDuration),
      'formattedBreakDuration': _formatDuration(breakDuration),
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WEEKLY SUMMARY - OPTIMIZED: Single fetch + batch analysis
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> getWeeklySummary({DateTime? targetDate}) {
    final now = targetDate ?? DateTime.now();
    final weekday = now.weekday;
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: weekday - 1));
    final endOfWeek = DateTime(
        startOfWeek.year, startOfWeek.month, startOfWeek.day + 6, 23, 59, 59);

    // ── Single fetch of all completed sessions for the week ──
    final completedSessions = _getCompletedSessions(startOfWeek, endOfWeek);

    // ── Single pass batch analysis ──
    final analytics =
        _analyzeSessionsBatch(completedSessions, startOfWeek, endOfWeek);

    // ── Grouped sessions (needs sorted input) ──
    final sortedSessions = List<FocusSessionRecord>.from(completedSessions)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final groupedSessions = _buildGroupedSessions(sortedSessions);

    final totalBreakTime = analytics.shortBreakTime + analytics.longBreakTime;
    final totalTime = analytics.workTime + totalBreakTime;

    final totalCompleteSessions = groupedSessions
        .where((s) => s['isComplete'] == true && s['type'] == 'pomodoro')
        .length;

    final avgSessionMinutes = totalCompleteSessions > 0
        ? (totalTime.inMinutes / totalCompleteSessions).round()
        : 0;
    final avgWorkMinutes = totalCompleteSessions > 0
        ? (analytics.workTime.inMinutes / totalCompleteSessions).round()
        : 0;

    // Most productive day
    String mostProductiveDay = 'None';
    int maxSessions = 0;
    analytics.sessionCountByDay.forEach((day, count) {
      if (count > maxSessions) {
        maxSessions = count;
        mostProductiveDay = day;
      }
    });

    if (mostProductiveDay != 'None') {
      try {
        mostProductiveDay =
            _dayOfWeekFormat.format(_dateFormat.parse(mostProductiveDay));
      } catch (e) {
        debugPrint('Error formatting most productive day: $e');
      }
    }

    return {
      'weekStart': startOfWeek,
      'weekEnd': endOfWeek,
      'totalSessions': totalCompleteSessions,
      'totalWorkPhases': analytics.workPhaseCount,
      'totalTime': totalTime,
      'totalWorkTime': analytics.workTime,
      'totalBreakTime': totalBreakTime,
      'totalMinutes': totalTime.inMinutes,
      'totalWorkMinutes': analytics.workTime.inMinutes,
      'totalBreakMinutes': totalBreakTime.inMinutes,
      'avgSessionMinutes': avgSessionMinutes,
      'avgWorkMinutes': avgWorkMinutes,
      'formattedTotalTime': _formatDuration(totalTime),
      'formattedTotalWorkTime': _formatDuration(analytics.workTime),
      'formattedTotalBreakTime': _formatDuration(totalBreakTime),
      'mostProductiveDay': mostProductiveDay,
      'sessionsByDay': analytics.sessionCountByDay,
      'timeDistribution': analytics.toTimeDistributionMap(),
      'sessions': groupedSessions,
    };
  }

  /// Build grouped pomodoro sessions from pre-sorted completed sessions
  List<Map<String, dynamic>> _buildGroupedSessions(
      List<FocusSessionRecord> sortedSessions) {
    final groupedSessions = <Map<String, dynamic>>[];
    var currentGroup = <FocusSessionRecord>[];

    for (final session in sortedSessions) {
      final sessionType = _getSessionType(session.appsBlocked);

      if (!_isPomodoroPhase(sessionType)) {
        groupedSessions.add({
          'type': 'regular_focus',
          'startTime': session.startTime,
          'totalDuration': session.duration,
          'workDuration': session.duration,
          'breakDuration': Duration.zero,
          'phases': 1,
          'isComplete': true,
        });
        continue;
      }

      currentGroup.add(session);

      if (sessionType == 'POMODORO_LONG_BREAK') {
        groupedSessions.add(_summarizeGroup(currentGroup));
        currentGroup = [];
      }
    }

    if (currentGroup.isNotEmpty) {
      groupedSessions.add(_summarizeGroup(currentGroup, isComplete: false));
    }

    groupedSessions.sort((a, b) =>
        (b['startTime'] as DateTime).compareTo(a['startTime'] as DateTime));

    return groupedSessions;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FOCUS TRENDS - OPTIMIZED: Single fetch + monthly slicing
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> getFocusTrends({
    int months = 3,
    bool useLifetimeIfLess = true,
  }) {
    if (!_dataStore.isInitialized) return _emptyTrends;

    try {
      final now = DateTime.now();
      final endDate = DateTime(now.year, now.month, now.day);
      DateTime startDate = DateTime(now.year, now.month - months, 1);

      if (useLifetimeIfLess) {
        final earliestPossible = DateTime(now.year - 1, now.month, 1);
        if (earliestPossible.isAfter(startDate)) {
          startDate = earliestPossible;
        }
      }

      // ── Single fetch for entire range ──
      final allSessions = _getCompletedSessions(startDate, endDate);

      // ── Pre-classify all sessions once ──
      final classifiedSessions = <_ClassifiedSession>[];
      for (final session in allSessions) {
        classifiedSessions.add(_ClassifiedSession(
          session: session,
          type: _getSessionType(session.appsBlocked),
        ));
      }

      final periods = <String>[];
      final sessionCounts = <int>[];
      final workPhaseCounts = <int>[];
      final avgDuration = <double>[];
      final totalFocusTime = <int>[];

      DateTime currentStart = DateTime(startDate.year, startDate.month, 1);

      while (!currentStart.isAfter(endDate)) {
        final nextMonth =
            DateTime(currentStart.year, currentStart.month + 1, 1);
        final currentEnd = nextMonth.subtract(const Duration(days: 1));
        final adjustedEnd = currentEnd.isAfter(endDate) ? endDate : currentEnd;

        // Filter sessions for this month
        int monthCompleteCount = 0;
        int monthWorkCount = 0;
        Duration monthWorkTime = Duration.zero;

        for (final cs in classifiedSessions) {
          final sessionDate = cs.session.date;
          if (sessionDate.isBefore(currentStart) ||
              sessionDate.isAfter(adjustedEnd)) {
            continue;
          }

          switch (cs.type) {
            case 'POMODORO_WORK':
              monthWorkTime += cs.session.duration;
              monthWorkCount++;
              break;
            case 'POMODORO_LONG_BREAK':
              monthCompleteCount++;
              break;
            case 'LEGACY_SESSION':
            case 'REGULAR_FOCUS':
              monthWorkTime += cs.session.duration;
              break;
          }
        }

        final avg = monthCompleteCount > 0
            ? monthWorkTime.inMinutes / monthCompleteCount
            : 0.0;

        periods.add(_monthYearFormat.format(currentStart));
        sessionCounts.add(monthCompleteCount);
        workPhaseCounts.add(monthWorkCount);
        avgDuration.add(avg);
        totalFocusTime.add(monthWorkTime.inMinutes);

        currentStart = nextMonth;
      }

      double percentageChange = 0.0;
      if (totalFocusTime.length >= 2) {
        final previous = totalFocusTime[totalFocusTime.length - 2];
        if (previous > 0) {
          percentageChange = (totalFocusTime.last - previous) / previous * 100;
        }
      }

      return {
        'periods': periods,
        'sessionCounts': sessionCounts,
        'workPhaseCounts': workPhaseCounts,
        'avgDuration': avgDuration,
        'totalFocusTime': totalFocusTime,
        'percentageChange': percentageChange,
      };
    } catch (e) {
      debugPrint('Error getting focus trends: $e');
      return _emptyTrends;
    }
  }

  static final Map<String, dynamic> _emptyTrends = {
    'periods': <String>[],
    'sessionCounts': <int>[],
    'workPhaseCounts': <int>[],
    'avgDuration': <double>[],
    'totalFocusTime': <int>[],
    'percentageChange': 0.0,
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // FORMAT HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return minutes > 0 ? '$hours hr $minutes min' : '$hours hr';
    }
    return '$minutes min';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE/DELETE SESSIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> createFocusSession({
    required DateTime startTime,
    required Duration duration,
    required List<String> appsBlocked,
  }) async {
    if (!_dataStore.isInitialized) return false;

    try {
      final date = DateTime(startTime.year, startTime.month, startTime.day);

      return await _dataStore.recordFocusSession(FocusSessionRecord(
        date: date,
        startTime: startTime,
        duration: duration,
        appsBlocked: appsBlocked,
        completed: true,
        breakCount: 0,
        totalBreakTime: Duration.zero,
      ));
    } catch (e) {
      debugPrint('Error creating focus session: $e');
      return false;
    }
  }

  Future<bool> deleteFocusSession({
    DateTime? sessionDate,
    int? sessionIndex,
    String? sessionKey,
  }) async {
    if (!_dataStore.isInitialized) return false;

    try {
      DateTime? date = sessionDate;
      int? index = sessionIndex;

      if (date == null || index == null) {
        if (sessionKey == null) {
          debugPrint(
              'Error: Must provide either (sessionDate + sessionIndex) or sessionKey');
          return false;
        }

        final parsed = _parseSessionKey(sessionKey);
        if (parsed == null) {
          debugPrint('Error: Could not parse session key: $sessionKey');
          return false;
        }

        date = parsed.date;
        index = parsed.index;
      }

      return await _dataStore.deleteFocusSession(date, index);
    } catch (e) {
      debugPrint('Error deleting focus session: $e');
      return false;
    }
  }

  _ParsedSessionKey? _parseSessionKey(String sessionKey) {
    try {
      final parts = sessionKey.split(':');
      if (parts.length != 2) return null;

      final date = _dateFormat.parse(parts[0]);
      final milliseconds = int.parse(parts[1]);

      final sessions = _dataStore.getFocusSessions(date);
      for (int i = 0; i < sessions.length; i++) {
        if (sessions[i].startTime.millisecondsSinceEpoch == milliseconds) {
          return _ParsedSessionKey(date: date, index: i);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error parsing session key: $e');
      return null;
    }
  }

  @Deprecated(
      'Use sessionDate and sessionIndex from getSessionHistory() instead')
  String getSessionDeletionKey(FocusSessionRecord session) {
    return '${_dateFormat.format(session.date)}:${session.startTime.millisecondsSinceEpoch}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INTERNAL DATA CLASSES
// ═══════════════════════════════════════════════════════════════════════════

class _SessionAnalytics {
  final Duration workTime;
  final Duration shortBreakTime;
  final Duration longBreakTime;
  final int completeSessionCount;
  final int workPhaseCount;
  final Map<String, int> sessionCountByDay;
  final Map<String, int> workPhaseCountByDay;

  const _SessionAnalytics({
    required this.workTime,
    required this.shortBreakTime,
    required this.longBreakTime,
    required this.completeSessionCount,
    required this.workPhaseCount,
    required this.sessionCountByDay,
    required this.workPhaseCountByDay,
  });

  Map<String, dynamic> toTimeDistributionMap() {
    final totalTime = workTime + shortBreakTime + longBreakTime;
    final totalSeconds = totalTime.inSeconds;
    final hasTotalTime = totalSeconds > 0;

    return {
      'workTime': workTime,
      'shortBreakTime': shortBreakTime,
      'longBreakTime': longBreakTime,
      'totalTime': totalTime,
      'workPercentage':
          hasTotalTime ? workTime.inSeconds / totalSeconds * 100 : 0.0,
      'shortBreakPercentage':
          hasTotalTime ? shortBreakTime.inSeconds / totalSeconds * 100 : 0.0,
      'longBreakPercentage':
          hasTotalTime ? longBreakTime.inSeconds / totalSeconds * 100 : 0.0,
      'formattedWorkTime': _formatDurationStatic(workTime),
      'formattedShortBreakTime': _formatDurationStatic(shortBreakTime),
      'formattedLongBreakTime': _formatDurationStatic(longBreakTime),
      'formattedTotalTime': _formatDurationStatic(totalTime),
    };
  }

  static String _formatDurationStatic(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return minutes > 0 ? '$hours hr $minutes min' : '$hours hr';
    }
    return '$minutes min';
  }
}

class _ClassifiedSession {
  final FocusSessionRecord session;
  final String type;

  const _ClassifiedSession({required this.session, required this.type});
}

class _ParsedSessionKey {
  final DateTime date;
  final int index;

  const _ParsedSessionKey({required this.date, required this.index});
}
