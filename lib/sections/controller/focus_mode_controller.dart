import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/main.dart';

import 'data_controllers/focus_mode_data_controller.dart';
import './notification_controller.dart';

enum TimerState { work, shortBreak, longBreak, idle }

class SessionPhase {
  final TimerState state;
  final int durationMinutes;
  final int index;

  const SessionPhase(this.state, this.durationMinutes, this.index);
}

class TimerUpdate {
  final TimerState state;
  final int secondsRemaining;
  final bool isRunning;
  final int completedSessions;
  final int completedFullSessions;
  final int currentPhaseIndex;

  const TimerUpdate({
    required this.state,
    required this.secondsRemaining,
    required this.isRunning,
    required this.completedSessions,
    required this.completedFullSessions,
    required this.currentPhaseIndex,
  });
}

class PomodoroTimerService {
  static final PomodoroTimerService _instance =
      PomodoroTimerService._internal();

  final FocusAnalyticsService _analyticsService = FocusAnalyticsService();
  final NotificationController _notificationController =
      NotificationController();
  final StreamController<TimerUpdate> _stateController =
      StreamController<TimerUpdate>.broadcast();

  Stream<TimerUpdate> get timerUpdates => _stateController.stream;

  // ────────────────────── Configuration ──────────────────────

  int _workDuration = 25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 15;
  bool _autoStart = false;
  bool _enableNotifications = true;

  // Callbacks
  Function()? _onWorkSessionStart;
  Function()? _onShortBreakStart;
  Function()? _onLongBreakStart;
  Function()? _onTimerComplete;

  // ────────────────────── State ──────────────────────

  static const int _totalPhases = 8; // 4 work + 3 short + 1 long

  List<SessionPhase> _sessionChain = [];
  TimerState _currentState = TimerState.idle;
  Timer? _timer;
  int _secondsRemaining = 0;
  int _currentPhaseIndex = -1;
  int _completedFullSessions = 0;

  // Session tracking
  DateTime? _currentSessionStart;
  DateTime? _currentPhaseStart;
  List<_PhaseRecord> _sessionPhases = [];

  // ────────────────────── Getters ──────────────────────

  TimerState get currentState => _currentState;
  int get secondsRemaining => _secondsRemaining;
  int get minutesRemaining => _secondsRemaining ~/ 60;
  int get secondsInCurrentMinute => _secondsRemaining % 60;
  bool get isRunning => _timer?.isActive ?? false;
  int get completedSessions => _completedWorkPeriods;
  int get completedFullSessions => _completedFullSessions;
  int get totalSessions => _completedFullSessions;
  int get currentPhaseIndex => _currentPhaseIndex;
  int get totalPhasesInSession => _totalPhases;

  /// Work periods sit at even indices (0, 2, 4, 6).
  /// Count only those *before* the current phase.
  int get _completedWorkPeriods {
    if (_currentPhaseIndex < 0) return 0;
    int count = 0;
    for (var i = 0; i < _currentPhaseIndex && i < _totalPhases; i += 2) {
      count++;
    }
    return count.clamp(0, 4);
  }

  // ────────────────────── Construction ──────────────────────

  PomodoroTimerService._internal() {
    _buildSessionChain();
  }

  factory PomodoroTimerService({
    required int workDuration,
    required int shortBreakDuration,
    required int longBreakDuration,
    bool autoStart = false,
    bool enableNotifications = true,
    Function()? onWorkSessionStart,
    Function()? onShortBreakStart,
    Function()? onLongBreakStart,
    Function()? onTimerComplete,
  }) {
    _instance.updateConfig(
      workDuration: workDuration,
      shortBreakDuration: shortBreakDuration,
      longBreakDuration: longBreakDuration,
      autoStart: autoStart,
      enableNotifications: enableNotifications,
      onWorkSessionStart: onWorkSessionStart,
      onShortBreakStart: onShortBreakStart,
      onLongBreakStart: onLongBreakStart,
      onTimerComplete: onTimerComplete,
    );
    return _instance;
  }

  // ────────────────────── Config / Init ──────────────────────

  void updateConfig({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    bool? autoStart,
    bool? enableNotifications,
    Function()? onWorkSessionStart,
    Function()? onShortBreakStart,
    Function()? onLongBreakStart,
    Function()? onTimerComplete,
  }) {
    _workDuration = workDuration ?? _workDuration;
    _shortBreakDuration = shortBreakDuration ?? _shortBreakDuration;
    _longBreakDuration = longBreakDuration ?? _longBreakDuration;
    _autoStart = autoStart ?? _autoStart;
    _enableNotifications = enableNotifications ?? _enableNotifications;
    _onWorkSessionStart = onWorkSessionStart ?? _onWorkSessionStart;
    _onShortBreakStart = onShortBreakStart ?? _onShortBreakStart;
    _onLongBreakStart = onLongBreakStart ?? _onLongBreakStart;
    _onTimerComplete = onTimerComplete ?? _onTimerComplete;
    _buildSessionChain();
  }

  Future<void> initialize() async {
    await _notificationController.initialize();
    _buildSessionChain();
  }

  void _buildSessionChain() {
    _sessionChain = List.generate(_totalPhases, (i) {
      if (i == 7)
        return SessionPhase(TimerState.longBreak, _longBreakDuration, i);
      return i.isEven
          ? SessionPhase(TimerState.work, _workDuration, i)
          : SessionPhase(TimerState.shortBreak, _shortBreakDuration, i);
    });
  }

  // ────────────────────── Timer Core ──────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _timerCallback);
  }

  void _timerCallback(Timer timer) {
    if (_secondsRemaining > 0) {
      _secondsRemaining--;
      _emitUpdate();

      if (_enableNotifications && _secondsRemaining == 60) {
        _notify('1 Minute Remaining',
            'Your ${_sessionTypeName} session will end in 1 minute.');
      }
    } else {
      timer.cancel();
      _timer = null;
      _handleTimerComplete();
    }
  }

  void _emitUpdate() {
    _stateController.add(TimerUpdate(
      state: _currentState,
      secondsRemaining: _secondsRemaining,
      isRunning: isRunning,
      completedSessions: _completedWorkPeriods,
      completedFullSessions: _completedFullSessions,
      currentPhaseIndex: _currentPhaseIndex,
    ));
  }

  // ────────────────────── Phase Navigation ──────────────────────

  void _startPhaseByIndex(int index) {
    if (_sessionChain.isEmpty) _buildSessionChain();
    if (index < 0 || index >= _sessionChain.length) return;

    // New session bookkeeping
    if (index == 0) {
      _currentSessionStart = DateTime.now();
      _sessionPhases = [];
    }

    _currentPhaseStart = DateTime.now();

    final phase = _sessionChain[index];
    _currentPhaseIndex = index;
    _currentState = phase.state;
    _secondsRemaining = phase.durationMinutes * 60;

    _emitUpdate();
    _startTimer();

    if (_enableNotifications && phase.state != TimerState.idle) {
      _notificationController.sendFocusNotification(_sessionTypeName, false);
    }
  }

  void _handleTimerComplete() {
    _recordPhaseCompletion();

    if (_currentPhaseIndex == _totalPhases - 1) {
      _completeSession();
    } else {
      final nextIndex = _currentPhaseIndex + 1;
      _startPhaseByIndex(nextIndex);
      _invokeCallbackForPhase(nextIndex);
    }
  }

  void _completeSession() {
    _currentSessionStart = null;
    _currentPhaseStart = null;
    _sessionPhases = [];
    _completedFullSessions++;

    navigationState.refreshCurrentScreen();
    _onTimerComplete?.call();

    if (_enableNotifications) {
      _notificationController.sendFocusNotification('Long Break', true);
    }

    if (_autoStart) {
      _startPhaseByIndex(0);
      _notify('New Session Starting', 'Starting a fresh Pomodoro session!');
    } else {
      _goIdle();
      _notify('Session Complete',
          'Great work! Press play when ready to start a new session.');
    }
  }

  // ────────────────────── Public Controls ──────────────────────

  void startWorkSession() => _startPhaseByIndex(0);
  void startShortBreak() => _startPhaseByIndex(1);
  void startLongBreak() => _startPhaseByIndex(_totalPhases - 1);

  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    _emitUpdate();
    _notifyIfActive(
        'Pomodoro Paused', 'Your $_sessionTypeName session has been paused.');
  }

  void resumeTimer() {
    if (!isRunning && _secondsRemaining > 0) {
      _startTimer();
      _notifyIfActive('Pomodoro Resumed',
          'Your $_sessionTypeName session has been resumed.');
    }
  }

  void restartCurrentSession() {
    pauseTimer();

    if (_currentPhaseIndex >= 0 && _currentPhaseIndex < _sessionChain.length) {
      _secondsRemaining =
          _sessionChain[_currentPhaseIndex].durationMinutes * 60;
    } else {
      _secondsRemaining = _workDuration * 60;
    }

    _currentPhaseStart = DateTime.now();
    _emitUpdate();

    if (_currentState != TimerState.idle) _startTimer();
  }

  void resetTimer() {
    pauseTimer();
    _goIdle();
    _notify('Pomodoro Reset', 'Your timer has been reset.');
  }

  void navigateBackward() {
    if (_currentPhaseIndex <= 0) {
      if (_currentPhaseIndex == 0) resetTimer();
      return;
    }
    _navigateTo(_currentPhaseIndex - 1);
  }

  void navigateForward() {
    if (_currentPhaseIndex == _totalPhases - 1) {
      _completeSession();
      return;
    }
    if (_currentPhaseIndex >= _totalPhases - 1) return;

    final target = _currentPhaseIndex < 0 ? 0 : _currentPhaseIndex + 1;
    _navigateTo(target);
    if (_currentPhaseIndex == 0) _onWorkSessionStart?.call();
  }

  void resetStats() {
    _currentPhaseIndex = -1;
    _completedFullSessions = 0;
    _clearSessionTracking();
    _emitUpdate();
    _notify('Stats Reset', 'Your Pomodoro statistics have been reset.');
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _stateController.close();
  }

  // ────────────────────── Private Helpers ──────────────────────

  void _navigateTo(int index) {
    pauseTimer();
    _startPhaseByIndex(index);
    _invokeCallbackForPhase(index);
  }

  void _goIdle() {
    _currentState = TimerState.idle;
    _currentPhaseIndex = -1;
    _secondsRemaining = _workDuration * 60;
    _clearSessionTracking();
    _emitUpdate();
  }

  void _clearSessionTracking() {
    _currentSessionStart = null;
    _currentPhaseStart = null;
    _sessionPhases = [];
  }

  String get _sessionTypeName => const {
        TimerState.work: 'Pomodoro Work',
        TimerState.shortBreak: 'Short Break',
        TimerState.longBreak: 'Long Break',
        TimerState.idle: 'Pomodoro',
      }[_currentState]!;

  static const _sessionTypeTag = {
    TimerState.work: 'POMODORO_WORK',
    TimerState.shortBreak: 'POMODORO_SHORT_BREAK',
    TimerState.longBreak: 'POMODORO_LONG_BREAK',
  };

  void _recordPhaseCompletion() {
    if (_currentPhaseStart == null || _currentState == TimerState.idle) return;

    final tag = _sessionTypeTag[_currentState];
    if (tag == null) return;

    final phaseEnd = DateTime.now();
    final actualDuration = phaseEnd.difference(_currentPhaseStart!);

    try {
      _analyticsService.createFocusSession(
        startTime: _currentPhaseStart!,
        duration: actualDuration,
        appsBlocked: [tag],
      );
    } catch (e) {
      debugPrint('Failed to save phase: $e');
    }

    _sessionPhases.add(_PhaseRecord(
      state: _currentState,
      plannedMinutes: _sessionChain[_currentPhaseIndex].durationMinutes,
      actualDuration: actualDuration,
      startTime: _currentPhaseStart!,
      endTime: phaseEnd,
    ));
  }

  void _invokeCallbackForPhase(int index) {
    if (index < 0 || index >= _sessionChain.length) return;
    final callback = {
      TimerState.work: _onWorkSessionStart,
      TimerState.shortBreak: _onShortBreakStart,
      TimerState.longBreak: _onLongBreakStart,
    }[_sessionChain[index].state];
    callback?.call();
  }

  void _notify(String title, String body) {
    if (_enableNotifications) {
      _notificationController.showPopupAlert(title, body);
    }
  }

  void _notifyIfActive(String title, String body) {
    if (_enableNotifications && _currentState != TimerState.idle) {
      _notificationController.showPopupAlert(title, body);
    }
  }
}

/// Typed record for completed phases (replaces Map<String, dynamic>).
class _PhaseRecord {
  final TimerState state;
  final int plannedMinutes;
  final Duration actualDuration;
  final DateTime startTime;
  final DateTime endTime;

  const _PhaseRecord({
    required this.state,
    required this.plannedMinutes,
    required this.actualDuration,
    required this.startTime,
    required this.endTime,
  });
}
