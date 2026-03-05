import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_data_controller.dart';

class FocusAnalyticsService {
  final AppDataStore _dataStore;

  static final FocusAnalyticsService _instance =
      FocusAnalyticsService._internal();

  factory FocusAnalyticsService() {
    return _instance;
  }

  FocusAnalyticsService._internal() : _dataStore = AppDataStore();

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER: Extract session type from appsBlocked
  // ═══════════════════════════════════════════════════════════════════════════

  String _getSessionType(List<String>? appsBlocked) {
    if (appsBlocked == null || appsBlocked.isEmpty) {
      return 'LEGACY_SESSION';
    }

    const List<String> pomodoroTags = [
      'POMODORO_WORK',
      'POMODORO_SHORT_BREAK',
      'POMODORO_LONG_BREAK',
    ];

    for (final tag in pomodoroTags) {
      if (appsBlocked.contains(tag)) {
        return tag;
      }
    }

    return 'REGULAR_FOCUS';
  }

  String _getSessionTypeLabel(String sessionType) {
    switch (sessionType) {
      case 'POMODORO_WORK':
        return 'Work Session';
      case 'POMODORO_SHORT_BREAK':
        return 'Short Break';
      case 'POMODORO_LONG_BREAK':
        return 'Long Break';
      default:
        return 'Focus Session';
    }
  }

  bool _isPomodoroPhase(String sessionType) {
    return sessionType == 'POMODORO_WORK' ||
        sessionType == 'POMODORO_SHORT_BREAK' ||
        sessionType == 'POMODORO_LONG_BREAK';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TIME DISTRIBUTION - Already efficient (single pass through sessions)
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> getTimeDistribution({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) {
      return _emptyTimeDistribution();
    }

    try {
      // 🚀 OPTIMIZED: getFocusSessionsRange uses cache for last year
      final List<FocusSessionRecord> sessions = _dataStore
          .getFocusSessionsRange(startDate, endDate)
          .where((session) => session.completed)
          .toList();

      if (sessions.isEmpty) {
        return _emptyTimeDistribution();
      }

      Duration workTime = Duration.zero;
      Duration shortBreakTime = Duration.zero;
      Duration longBreakTime = Duration.zero;

      // Single pass through sessions
      for (final session in sessions) {
        final String sessionType = _getSessionType(session.appsBlocked);

        switch (sessionType) {
          case 'POMODORO_WORK':
            workTime += session.duration;
            break;
          case 'POMODORO_SHORT_BREAK':
            shortBreakTime += session.duration;
            break;
          case 'POMODORO_LONG_BREAK':
            longBreakTime += session.duration;
            break;
          default:
            workTime += session.duration;
            break;
        }
      }

      final Duration totalTime = workTime + shortBreakTime + longBreakTime;

      final double workPercentage = totalTime.inSeconds > 0
          ? workTime.inSeconds / totalTime.inSeconds * 100
          : 0.0;
      final double shortBreakPercentage = totalTime.inSeconds > 0
          ? shortBreakTime.inSeconds / totalTime.inSeconds * 100
          : 0.0;
      final double longBreakPercentage = totalTime.inSeconds > 0
          ? longBreakTime.inSeconds / totalTime.inSeconds * 100
          : 0.0;

      return {
        'workTime': workTime,
        'shortBreakTime': shortBreakTime,
        'longBreakTime': longBreakTime,
        'totalTime': totalTime,
        'workPercentage': workPercentage,
        'shortBreakPercentage': shortBreakPercentage,
        'longBreakPercentage': longBreakPercentage,
        'formattedWorkTime': _formatDuration(workTime),
        'formattedShortBreakTime': _formatDuration(shortBreakTime),
        'formattedLongBreakTime': _formatDuration(longBreakTime),
        'formattedTotalTime': _formatDuration(totalTime),
      };
    } catch (e) {
      debugPrint("Error getting time distribution: $e");
      return _emptyTimeDistribution();
    }
  }

  Map<String, dynamic> _emptyTimeDistribution() {
    return {
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
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION COUNTING - Already efficient (single pass)
  // ═══════════════════════════════════════════════════════════════════════════

  int getCompletePomodoroSessionCount({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return 0;

    try {
      // 🚀 Uses cache for last year
      final List<FocusSessionRecord> sessions = _dataStore
          .getFocusSessionsRange(startDate, endDate)
          .where((session) => session.completed)
          .toList();

      int completeSessionCount = 0;
      for (final session in sessions) {
        final String sessionType = _getSessionType(session.appsBlocked);
        if (sessionType == 'POMODORO_LONG_BREAK') {
          completeSessionCount++;
        }
      }

      return completeSessionCount;
    } catch (e) {
      debugPrint("Error counting complete sessions: $e");
      return 0;
    }
  }

  int getWorkPhaseCount({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return 0;

    try {
      final List<FocusSessionRecord> sessions = _dataStore
          .getFocusSessionsRange(startDate, endDate)
          .where((session) => session.completed)
          .toList();

      int workCount = 0;
      for (final session in sessions) {
        final String sessionType = _getSessionType(session.appsBlocked);
        if (sessionType == 'POMODORO_WORK') {
          workCount++;
        }
      }

      return workCount;
    } catch (e) {
      debugPrint("Error counting work phases: $e");
      return 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION COUNT BY DAY - Already efficient
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, int> getSessionCountByDay({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return {};

    try {
      final Map<String, int> result = {};

      // 🚀 Single call to get all sessions in range (uses cache)
      final List<FocusSessionRecord> sessions =
          _dataStore.getFocusSessionsRange(startDate, endDate);

      // Initialize all days
      DateTime current =
          DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime end = DateTime(endDate.year, endDate.month, endDate.day);

      while (!current.isAfter(end)) {
        final String dateKey = _formatDate(current);
        result[dateKey] = 0;
        current = current.add(const Duration(days: 1));
      }

      // Single pass through sessions
      for (final session in sessions) {
        if (session.completed) {
          final String sessionType = _getSessionType(session.appsBlocked);

          if (sessionType == 'POMODORO_LONG_BREAK' ||
              sessionType == 'LEGACY_SESSION' ||
              sessionType == 'REGULAR_FOCUS') {
            final String dateKey = _formatDate(session.date);
            result[dateKey] = (result[dateKey] ?? 0) + 1;
          }
        }
      }

      return result;
    } catch (e) {
      debugPrint("Error getting session count by day: $e");
      return {};
    }
  }

  Map<String, int> getWorkPhaseCountByDay({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return {};

    try {
      final Map<String, int> result = {};
      final List<FocusSessionRecord> sessions =
          _dataStore.getFocusSessionsRange(startDate, endDate);

      DateTime current =
          DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime end = DateTime(endDate.year, endDate.month, endDate.day);

      while (!current.isAfter(end)) {
        final String dateKey = _formatDate(current);
        result[dateKey] = 0;
        current = current.add(const Duration(days: 1));
      }

      for (final session in sessions) {
        if (session.completed) {
          final String sessionType = _getSessionType(session.appsBlocked);

          if (sessionType == 'POMODORO_WORK') {
            final String dateKey = _formatDate(session.date);
            result[dateKey] = (result[dateKey] ?? 0) + 1;
          }
        }
      }

      return result;
    } catch (e) {
      debugPrint("Error getting work phase count by day: $e");
      return {};
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION HISTORY - Updated to include session identifiers for deletion
  // ═══════════════════════════════════════════════════════════════════════════

  List<Map<String, dynamic>> getSessionHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return [];

    try {
      final List<Map<String, dynamic>> result = [];

      // 🚀 Single call (uses cache for last year)
      final List<FocusSessionRecord> sessions =
          _dataStore.getFocusSessionsRange(startDate, endDate);

      // Build a map to track session indices per day
      final Map<String, List<FocusSessionRecord>> sessionsByDate = {};

      for (final session in sessions) {
        if (session.completed) {
          final String dateKey = _formatDate(session.date);
          sessionsByDate.putIfAbsent(dateKey, () => []);
          sessionsByDate[dateKey]!.add(session);
        }
      }

      // Process each date's sessions
      for (final entry in sessionsByDate.entries) {
        final String dateKey = entry.key;
        final List<FocusSessionRecord> daySessions = entry.value;

        // Sort by start time to match how they're stored
        daySessions.sort((a, b) => a.startTime.compareTo(b.startTime));

        for (int i = 0; i < daySessions.length; i++) {
          final session = daySessions[i];
          final String sessionType = _getSessionType(session.appsBlocked);
          final String sessionTypeLabel = _getSessionTypeLabel(sessionType);

          final String startTimeStr =
              DateFormat('yyyy-MM-dd HH:mm').format(session.startTime);
          final String durationStr = _formatDuration(session.duration);

          result.add({
            'date': startTimeStr,
            'duration': durationStr,
            'totalMinutes': session.duration.inMinutes,
            'sessionType': sessionType,
            'sessionTypeLabel': sessionTypeLabel,
            'isPomodoroPhase': _isPomodoroPhase(sessionType),
            'appsBlocked': session.appsBlocked,
            'rawSession': session,
            // NEW: Add deletion identifiers
            'sessionDate': session.date,
            'sessionIndex': i,
            'dateKey': dateKey,
          });
        }
      }

      result.sort((a, b) => b['date'].compareTo(a['date']));

      return result;
    } catch (e) {
      debugPrint("Error getting session history: $e");
      return [];
    }
  }

  List<Map<String, dynamic>> getGroupedPomodoroSessions({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return [];

    try {
      // 🚀 Single call (uses cache)
      final List<FocusSessionRecord> allSessions = _dataStore
          .getFocusSessionsRange(startDate, endDate)
          .where((session) => session.completed)
          .toList();

      allSessions.sort((a, b) => a.startTime.compareTo(b.startTime));

      final List<Map<String, dynamic>> groupedSessions = [];
      List<FocusSessionRecord> currentGroup = [];

      for (final session in allSessions) {
        final String sessionType = _getSessionType(session.appsBlocked);

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
          final groupedSession = _summarizeGroup(currentGroup);
          groupedSessions.add(groupedSession);
          currentGroup = [];
        }
      }

      if (currentGroup.isNotEmpty) {
        final groupedSession = _summarizeGroup(currentGroup, isComplete: false);
        groupedSessions.add(groupedSession);
      }

      groupedSessions.sort((a, b) =>
          (b['startTime'] as DateTime).compareTo(a['startTime'] as DateTime));

      return groupedSessions;
    } catch (e) {
      debugPrint("Error getting grouped sessions: $e");
      return [];
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
      final String sessionType = _getSessionType(session.appsBlocked);

      switch (sessionType) {
        case 'POMODORO_WORK':
          workDuration += session.duration;
          workPhases++;
          break;
        case 'POMODORO_SHORT_BREAK':
        case 'POMODORO_LONG_BREAK':
          breakDuration += session.duration;
          breakPhases++;
          break;
      }
    }

    return {
      'type': 'pomodoro',
      'startTime': group.first.startTime,
      'endTime': group.last.startTime.add(group.last.duration),
      'totalDuration': workDuration + breakDuration,
      'workDuration': workDuration,
      'breakDuration': breakDuration,
      'workPhases': workPhases,
      'breakPhases': breakPhases,
      'phases': group.length,
      'isComplete': isComplete,
      'formattedTotalDuration': _formatDuration(workDuration + breakDuration),
      'formattedWorkDuration': _formatDuration(workDuration),
      'formattedBreakDuration': _formatDuration(breakDuration),
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WEEKLY SUMMARY - Already efficient
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> getWeeklySummary({DateTime? targetDate}) {
    final DateTime now = targetDate ?? DateTime.now();

    final int weekday = now.weekday;
    final DateTime startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: weekday - 1));
    final DateTime endOfWeek = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day + 6,
      23,
      59,
      59,
    );

    // 🚀 All these methods use cache internally
    final Map<String, int> sessionsByDay = getSessionCountByDay(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );

    final Map<String, dynamic> timeDistribution = getTimeDistribution(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );

    final List<Map<String, dynamic>> groupedSessions =
        getGroupedPomodoroSessions(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );

    final Duration totalWorkTime =
        timeDistribution['workTime'] as Duration? ?? Duration.zero;
    final Duration totalShortBreakTime =
        timeDistribution['shortBreakTime'] as Duration? ?? Duration.zero;
    final Duration totalLongBreakTime =
        timeDistribution['longBreakTime'] as Duration? ?? Duration.zero;
    final Duration totalBreakTime = totalShortBreakTime + totalLongBreakTime;
    final Duration totalTime = totalWorkTime + totalBreakTime;

    final int totalCompleteSessions = groupedSessions
        .where((s) => s['isComplete'] == true && s['type'] == 'pomodoro')
        .length;

    final int totalWorkPhases = getWorkPhaseCount(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );

    final int avgSessionMinutes = totalCompleteSessions > 0
        ? (totalTime.inMinutes / totalCompleteSessions).round()
        : 0;

    final int avgWorkMinutes = totalCompleteSessions > 0
        ? (totalWorkTime.inMinutes / totalCompleteSessions).round()
        : 0;

    String mostProductiveDay = "None";
    int maxSessions = 0;

    sessionsByDay.forEach((day, count) {
      if (count > maxSessions) {
        maxSessions = count;
        mostProductiveDay = day;
      }
    });

    if (mostProductiveDay != "None") {
      try {
        final DateTime date = DateFormat('yyyy-MM-dd').parse(mostProductiveDay);
        mostProductiveDay = DateFormat('EEEE').format(date);
      } catch (e) {
        debugPrint("Error formatting most productive day: $e");
      }
    }

    return {
      'weekStart': startOfWeek,
      'weekEnd': endOfWeek,
      'totalSessions': totalCompleteSessions,
      'totalWorkPhases': totalWorkPhases,
      'totalTime': totalTime,
      'totalWorkTime': totalWorkTime,
      'totalBreakTime': totalBreakTime,
      'totalMinutes': totalTime.inMinutes,
      'totalWorkMinutes': totalWorkTime.inMinutes,
      'totalBreakMinutes': totalBreakTime.inMinutes,
      'avgSessionMinutes': avgSessionMinutes,
      'avgWorkMinutes': avgWorkMinutes,
      'formattedTotalTime': _formatDuration(totalTime),
      'formattedTotalWorkTime': _formatDuration(totalWorkTime),
      'formattedTotalBreakTime': _formatDuration(totalBreakTime),
      'mostProductiveDay': mostProductiveDay,
      'sessionsByDay': sessionsByDay,
      'timeDistribution': timeDistribution,
      'sessions': groupedSessions,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FOCUS TRENDS - Already efficient
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> getFocusTrends({
    int months = 3,
    bool useLifetimeIfLess = true,
  }) {
    if (!_dataStore.isInitialized) {
      return _emptyTrends();
    }

    try {
      final DateTime now = DateTime.now();
      final DateTime endDate = DateTime(now.year, now.month, now.day);
      DateTime startDate = DateTime(now.year, now.month - months, 1);

      if (useLifetimeIfLess) {
        final DateTime earliestPossible = DateTime(now.year - 1, now.month, 1);
        if (earliestPossible.isAfter(startDate)) {
          startDate = earliestPossible;
        }
      }

      final List<String> periods = [];
      final List<int> sessionCounts = [];
      final List<int> workPhaseCounts = [];
      final List<double> avgDuration = [];
      final List<int> totalFocusTime = [];

      DateTime currentStart = DateTime(startDate.year, startDate.month, 1);

      // 🚀 Each iteration uses cache internally
      while (!currentStart.isAfter(endDate)) {
        final DateTime nextMonth =
            DateTime(currentStart.year, currentStart.month + 1, 1);
        final DateTime currentEnd = nextMonth.subtract(const Duration(days: 1));
        final DateTime adjustedEnd =
            currentEnd.isAfter(endDate) ? endDate : currentEnd;

        final int completeSessionCount = getCompletePomodoroSessionCount(
          startDate: currentStart,
          endDate: adjustedEnd,
        );

        final int workPhaseCount = getWorkPhaseCount(
          startDate: currentStart,
          endDate: adjustedEnd,
        );

        final timeDistribution = getTimeDistribution(
          startDate: currentStart,
          endDate: adjustedEnd,
        );

        final Duration workTime =
            timeDistribution['workTime'] as Duration? ?? Duration.zero;
        final double avg = completeSessionCount > 0
            ? workTime.inMinutes / completeSessionCount
            : 0;

        periods.add(DateFormat('MMM yyyy').format(currentStart));
        sessionCounts.add(completeSessionCount);
        workPhaseCounts.add(workPhaseCount);
        avgDuration.add(avg);
        totalFocusTime.add(workTime.inMinutes);

        currentStart = nextMonth;
      }

      double percentageChange = 0.0;
      if (totalFocusTime.length >= 2 &&
          totalFocusTime[totalFocusTime.length - 2] > 0) {
        final int current = totalFocusTime.last;
        final int previous = totalFocusTime[totalFocusTime.length - 2];
        percentageChange = (current - previous) / previous * 100;
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
      debugPrint("Error getting focus trends: $e");
      return _emptyTrends();
    }
  }

  Map<String, dynamic> _emptyTrends() {
    return {
      'periods': <String>[],
      'sessionCounts': <int>[],
      'workPhaseCounts': <int>[],
      'avgDuration': <double>[],
      'totalFocusTime': <int>[],
      'percentageChange': 0.0,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes min';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE/DELETE SESSIONS - Updated for new API
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> createFocusSession({
    required DateTime startTime,
    required Duration duration,
    required List<String> appsBlocked,
  }) async {
    if (!_dataStore.isInitialized) return false;

    try {
      final DateTime date =
          DateTime(startTime.year, startTime.month, startTime.day);

      final FocusSessionRecord session = FocusSessionRecord(
        date: date,
        startTime: startTime,
        duration: duration,
        appsBlocked: appsBlocked,
        completed: true,
        breakCount: 0,
        totalBreakTime: Duration.zero,
      );

      return await _dataStore.recordFocusSession(session);
    } catch (e) {
      debugPrint("Error creating focus session: $e");
      return false;
    }
  }

  /// Delete a focus session using the new API
  ///
  /// You can pass either:
  /// - Both [sessionDate] and [sessionIndex] (recommended - new API)
  /// - A [sessionKey] string (backward compatibility - parses to extract date/index)
  ///
  /// The session history now includes 'sessionDate' and 'sessionIndex' fields
  /// that can be passed directly to this method.
  Future<bool> deleteFocusSession({
    DateTime? sessionDate,
    int? sessionIndex,
    String? sessionKey,
  }) async {
    if (!_dataStore.isInitialized) return false;

    try {
      DateTime? date = sessionDate;
      int? index = sessionIndex;

      // Backward compatibility: parse session key if provided
      if (date == null || index == null) {
        if (sessionKey == null) {
          debugPrint(
              "Error: Must provide either (sessionDate + sessionIndex) or sessionKey");
          return false;
        }

        // Try to parse the old session key format
        final parsed = _parseSessionKey(sessionKey);
        if (parsed == null) {
          debugPrint("Error: Could not parse session key: $sessionKey");
          return false;
        }

        date = parsed['date'] as DateTime;
        index = parsed['index'] as int;
      }

      return await _dataStore.deleteFocusSession(date, index);
    } catch (e) {
      debugPrint("Error deleting focus session: $e");
      return false;
    }
  }

  /// Parse a legacy session key into date and index
  /// Returns null if parsing fails
  Map<String, dynamic>? _parseSessionKey(String sessionKey) {
    try {
      // Expected format: "YYYY-MM-DD:timestamp"
      final parts = sessionKey.split(':');
      if (parts.length != 2) return null;

      final dateStr = parts[0];
      final timestampStr = parts[1];

      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      final milliseconds = int.parse(timestampStr);

      // To find the index, we need to get all sessions for that date
      // and find which index matches this timestamp
      final sessions = _dataStore.getFocusSessions(date);

      for (int i = 0; i < sessions.length; i++) {
        if (sessions[i].startTime.millisecondsSinceEpoch == milliseconds) {
          return {
            'date': date,
            'index': i,
          };
        }
      }

      return null;
    } catch (e) {
      debugPrint("Error parsing session key: $e");
      return null;
    }
  }

  /// Helper method to get a session deletion key for UI
  /// This is no longer needed with the new API, but kept for reference
  @Deprecated(
      'Use sessionDate and sessionIndex from getSessionHistory() instead')
  String getSessionDeletionKey(FocusSessionRecord session) {
    return '${_formatDate(session.date)}:${session.startTime.millisecondsSinceEpoch}';
  }
}
