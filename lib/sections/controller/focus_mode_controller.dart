import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/main.dart';

import 'data_controllers/focus_mode_data_controller.dart';
import './notification_controller.dart';

enum TimerState { work, shortBreak, longBreak, idle }

// Define the session phase structure
class SessionPhase {
  final TimerState state;
  final int durationMinutes;
  final int index; // Position in the chain (0-7)

  SessionPhase(this.state, this.durationMinutes, this.index);
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
    _instance._workDuration = workDuration;
    _instance._shortBreakDuration = shortBreakDuration;
    _instance._longBreakDuration = longBreakDuration;
    _instance._autoStart = autoStart;
    _instance._enableNotifications = enableNotifications;
    _instance._onWorkSessionStart = onWorkSessionStart;
    _instance._onShortBreakStart = onShortBreakStart;
    _instance._onLongBreakStart = onLongBreakStart;
    _instance._onTimerComplete = onTimerComplete;

    // BUILD SESSION CHAIN IMMEDIATELY
    _instance._buildSessionChain();

    return _instance;
  }

  PomodoroTimerService._internal() {
    // Initialize with default chain
    _buildSessionChain();
  }

  // Config variables
  int _workDuration = 25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 15;
  bool _autoStart = false;
  bool _enableNotifications = true;

  // Session chain tracking
  int _currentPhaseIndex = -1; // -1 = idle, 0-7 = positions in chain
  List<SessionPhase> _sessionChain = [];

  // Session statistics
  int _completedFullSessions = 0;

  // Track current session for database - FIXED VERSION
  DateTime? _currentSessionStart;
  DateTime? _currentSessionEnd;
  DateTime? _currentPhaseStart; // Track when current phase started
  List<Map<String, dynamic>> _sessionPhases =
      []; // Track all phases with durations

  // Timer state
  TimerState _currentState = TimerState.idle;
  int _secondsRemaining = 0;
  Timer? _timer;

  // Callbacks
  Function()? _onWorkSessionStart;
  Function()? _onShortBreakStart;
  Function()? _onLongBreakStart;
  Function()? _onTimerComplete;

  // Getters
  TimerState get currentState => _currentState;
  int get secondsRemaining => _secondsRemaining;
  int get minutesRemaining => _secondsRemaining ~/ 60;
  int get secondsInCurrentMinute => _secondsRemaining % 60;
  bool get isRunning => _timer != null && _timer!.isActive;
  int get completedSessions => _getCompletedWorkPeriods(); // For UI dots (0-3)
  int get completedFullSessions => _completedFullSessions;
  int get totalSessions => _completedFullSessions;
  int get currentPhaseIndex => _currentPhaseIndex;
  int get totalPhasesInSession => 8; // 4 work + 3 short breaks + 1 long break

  // Calculate completed work periods from current phase index
  int _getCompletedWorkPeriods() {
    if (_currentPhaseIndex < 0) return 0;

    // Count work periods we've COMPLETED (not the current one)
    int count = 0;
    for (int i = 0; i < _currentPhaseIndex && i < 8; i++) {
      if (i % 2 == 0) {
        // Work periods are at even indices
        count++;
      }
    }
    return count.clamp(0, 4);
  }

  // Build the session chain based on current durations
  void _buildSessionChain() {
    debugPrint('🔨 Building session chain...');
    _sessionChain = [
      SessionPhase(TimerState.work, _workDuration, 0),
      SessionPhase(TimerState.shortBreak, _shortBreakDuration, 1),
      SessionPhase(TimerState.work, _workDuration, 2),
      SessionPhase(TimerState.shortBreak, _shortBreakDuration, 3),
      SessionPhase(TimerState.work, _workDuration, 4),
      SessionPhase(TimerState.shortBreak, _shortBreakDuration, 5),
      SessionPhase(TimerState.work, _workDuration, 6),
      SessionPhase(TimerState.longBreak, _longBreakDuration, 7),
    ];
    debugPrint('✅ Session chain built with ${_sessionChain.length} phases');
  }

  Future<void> initialize() async {
    debugPrint('🚀 Initializing PomodoroTimerService...');
    await _notificationController.initialize();
    _buildSessionChain();
    debugPrint('✅ PomodoroTimerService initialized');
  }

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

    _buildSessionChain(); // Rebuild chain with new durations
  }

  void _timerCallback(Timer timer) {
    if (_secondsRemaining > 0) {
      _secondsRemaining--;

      _stateController.add(TimerUpdate(
        state: _currentState,
        secondsRemaining: _secondsRemaining,
        isRunning: isRunning,
        completedSessions: _getCompletedWorkPeriods(),
        completedFullSessions: _completedFullSessions,
        currentPhaseIndex: _currentPhaseIndex,
      ));

      if (_enableNotifications && _secondsRemaining == 60) {
        _notificationController.showPopupAlert('1 Minute Remaining',
            'Your ${_getSessionTypeName()} session will end in 1 minute.');
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
      completedSessions: _getCompletedWorkPeriods(),
      completedFullSessions: _completedFullSessions,
      currentPhaseIndex: _currentPhaseIndex,
    ));
  }

  // Start a specific phase by index
  void _startPhaseByIndex(int index) {
    debugPrint('🎯 _startPhaseByIndex called with index: $index');

    if (_sessionChain.isEmpty) {
      debugPrint('⚠️ Session chain is empty! Building it now...');
      _buildSessionChain();
    }

    if (index < 0 || index >= _sessionChain.length) {
      debugPrint(
          '❌ Invalid phase index: $index (chain length: ${_sessionChain.length})');
      return;
    }

    // Start tracking if this is the beginning of a new session
    if (index == 0) {
      _currentSessionStart = DateTime.now();
      _sessionPhases = []; // Reset phase tracking
      debugPrint('🆕 Starting NEW Pomodoro session at $_currentSessionStart');
    }

    // Track when this phase starts
    _currentPhaseStart = DateTime.now();

    SessionPhase phase = _sessionChain[index];
    _currentPhaseIndex = index;
    _currentState = phase.state;
    _secondsRemaining = phase.durationMinutes * 60;

    debugPrint(
        '📍 Moving to phase $index: ${phase.state} (${phase.durationMinutes}m = $_secondsRemaining seconds)');

    _emitUpdate(); // Emit update before starting timer
    _startTimer();

    // Send notifications
    if (_enableNotifications) {
      switch (phase.state) {
        case TimerState.work:
          _notificationController.sendFocusNotification('Pomodoro Work', false);
          break;
        case TimerState.shortBreak:
          _notificationController.sendFocusNotification('Short Break', false);
          break;
        case TimerState.longBreak:
          _notificationController.sendFocusNotification('Long Break', false);
          break;
        case TimerState.idle:
          break;
      }
    }
  }

  void startWorkSession() {
    debugPrint('▶️ startWorkSession called');
    _startPhaseByIndex(0); // Always start from the beginning of the chain
  }

  void startShortBreak() {
    debugPrint('☕ startShortBreak called');
    // Find the first short break phase
    _startPhaseByIndex(1);
  }

  void startLongBreak() {
    debugPrint('🌴 startLongBreak called');
    _startPhaseByIndex(7); // Last phase in the chain
  }

  void restartCurrentSession() {
    debugPrint(
        '🔄 restartCurrentSession called (current phase: $_currentPhaseIndex)');
    pauseTimer();

    // Restart the current phase
    if (_currentPhaseIndex >= 0 && _currentPhaseIndex < _sessionChain.length) {
      SessionPhase phase = _sessionChain[_currentPhaseIndex];
      _secondsRemaining = phase.durationMinutes * 60;
      _currentPhaseStart = DateTime.now(); // Reset phase start time
      debugPrint(
          'Resetting to ${phase.durationMinutes} minutes ($_secondsRemaining seconds)');
    } else {
      _secondsRemaining = _workDuration * 60;
      debugPrint(
          'No valid phase, defaulting to work duration: $_secondsRemaining seconds');
    }

    _emitUpdate();

    if (_currentState != TimerState.idle) {
      _startTimer();
    }
  }

  void _startTimer() {
    debugPrint('⏱️ Starting timer with $_secondsRemaining seconds remaining');
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _timerCallback);
  }

  void pauseTimer() {
    debugPrint('⏸️ Pausing timer');
    _timer?.cancel();
    _timer = null;
    _emitUpdate();

    if (_enableNotifications && _currentState != TimerState.idle) {
      _notificationController.showPopupAlert('Pomodoro Paused',
          'Your ${_getSessionTypeName()} session has been paused.');
    }
  }

  String _getSessionTypeName() {
    switch (_currentState) {
      case TimerState.work:
        return 'Pomodoro Work';
      case TimerState.shortBreak:
        return 'Short Break';
      case TimerState.longBreak:
        return 'Long Break';
      case TimerState.idle:
        return 'Pomodoro';
    }
  }

  void resumeTimer() {
    debugPrint('▶️ Resuming timer');
    if (!isRunning && _secondsRemaining > 0) {
      _startTimer();

      if (_enableNotifications && _currentState != TimerState.idle) {
        _notificationController.showPopupAlert('Pomodoro Resumed',
            'Your ${_getSessionTypeName()} session has been resumed.');
      }
    }
  }

  void resetTimer() {
    debugPrint('🔄 Resetting timer to idle');
    pauseTimer();
    _currentState = TimerState.idle;
    _currentPhaseIndex = -1;
    _secondsRemaining = _workDuration * 60;

    // Clear session tracking
    _currentSessionStart = null;
    _currentSessionEnd = null;
    _currentPhaseStart = null;
    _sessionPhases = [];

    _emitUpdate();

    if (_enableNotifications) {
      _notificationController.showPopupAlert(
          'Pomodoro Reset', 'Your timer has been reset.');
    }
  }

  // Record phase completion with actual duration and SAVE TO DATABASE
  Future<void> _recordPhaseCompletion() async {
    if (_currentPhaseStart == null) return;

    final phaseEnd = DateTime.now();
    final actualDuration = phaseEnd.difference(_currentPhaseStart!);

    debugPrint('📊 Recording phase completion:');
    debugPrint('   Type: $_currentState');
    debugPrint(
        '   Planned: ${_sessionChain[_currentPhaseIndex].durationMinutes} min');
    debugPrint(
        '   Actual: ${actualDuration.inMinutes} min ${actualDuration.inSeconds % 60} sec');

    String sessionTypeTag;
    switch (_currentState) {
      case TimerState.work:
        sessionTypeTag = 'POMODORO_WORK';
        break;
      case TimerState.shortBreak:
        sessionTypeTag = 'POMODORO_SHORT_BREAK';
        break;
      case TimerState.longBreak:
        sessionTypeTag = 'POMODORO_LONG_BREAK';
        break;
      case TimerState.idle:
        return;
    }

    try {
      debugPrint(
          '💾 Saving phase to database: $_currentState as $sessionTypeTag');
      await _analyticsService.createFocusSession(
        startTime: _currentPhaseStart!,
        duration: actualDuration,
        appsBlocked: [sessionTypeTag],
      );
      debugPrint('✅ Phase saved successfully');
    } catch (e) {
      debugPrint('❌ Failed to save phase: $e');
    }

    _sessionPhases.add({
      'type': _currentState.toString(),
      'plannedMinutes': _sessionChain[_currentPhaseIndex].durationMinutes,
      'actualDuration': actualDuration,
      'startTime': _currentPhaseStart,
      'endTime': phaseEnd,
    });
  }

  // Complete the full Pomodoro session (extracted method)
  Future<void> _completeSession() async {
    debugPrint('🎯 _completeSession called');
    debugPrint('   Current phase: $_currentPhaseIndex');
    debugPrint('   Phases completed: ${_sessionPhases.length}');

    // Await the final phase (long break) save
    await _recordPhaseCompletion();

    _currentSessionEnd = DateTime.now();

    if (_currentSessionStart != null && _sessionPhases.isNotEmpty) {
      final totalDuration =
          _currentSessionEnd!.difference(_currentSessionStart!);

      final workDuration = _sessionPhases
          .where((phase) => phase['type'] == 'TimerState.work')
          .fold<Duration>(Duration.zero,
              (sum, phase) => sum + (phase['actualDuration'] as Duration));

      debugPrint('✅ COMPLETE Pomodoro session summary:');
      debugPrint('   Session start: $_currentSessionStart');
      debugPrint('   Session end: $_currentSessionEnd');
      debugPrint('   Total elapsed time: ${totalDuration.inMinutes} minutes');
      debugPrint('   Total work time: ${workDuration.inMinutes} minutes');
      debugPrint('   Phases saved to DB: ${_sessionPhases.length}');
    }

    _completedFullSessions++;
    debugPrint(
        '🎉 Completed full Pomodoro session! Total: $_completedFullSessions');

    // Reset state BEFORE refreshing UI
    _currentSessionStart = null;
    _currentSessionEnd = null;
    _currentPhaseStart = null;
    _sessionPhases = [];

    // ✨ Refresh AFTER DB write is confirmed complete
    navigationState.refreshCurrentScreen();

    if (_onTimerComplete != null) {
      debugPrint('📞 Calling onTimerComplete callback');
      _onTimerComplete!();
    }

    if (_enableNotifications) {
      _notificationController.sendFocusNotification('Long Break', true);
    }

    if (_autoStart) {
      debugPrint('▶️ Auto-starting NEW session (autoStart=true)');
      _startPhaseByIndex(0);

      if (_enableNotifications) {
        _notificationController.showPopupAlert(
            'New Session Starting', 'Starting a fresh Pomodoro session!');
      }
    } else {
      debugPrint('⏸️ Session complete. Going to idle (autoStart=false)');
      _timer?.cancel();
      _timer = null;
      _currentState = TimerState.idle;
      _currentPhaseIndex = -1;
      _secondsRemaining = _workDuration * 60;
      _emitUpdate();

      if (_enableNotifications) {
        _notificationController.showPopupAlert('Session Complete',
            'Great work! Press play when ready to start a new session.');
      }
    }
  }

  void _handleTimerComplete() {
    debugPrint('━━━━━━━━━━ TIMER COMPLETE ━━━━━━━━━━');
    debugPrint('Completed phase index: $_currentPhaseIndex');
    debugPrint('Completed state: $_currentState');

    if (_currentPhaseIndex == 7) {
      debugPrint('✅ Long break completed - FULL SESSION DONE');
      // _completeSession handles recording the final phase itself
      _completeSession();
    } else {
      // Record this phase before advancing
      _recordPhaseCompletion().then((_) {
        debugPrint('▶️ Auto-advancing to next phase');
        _startPhaseByIndex(_currentPhaseIndex + 1);

        if (_currentPhaseIndex >= 0 &&
            _currentPhaseIndex < _sessionChain.length) {
          SessionPhase nextPhase = _sessionChain[_currentPhaseIndex];
          switch (nextPhase.state) {
            case TimerState.work:
              if (_onWorkSessionStart != null) _onWorkSessionStart!();
              break;
            case TimerState.shortBreak:
              if (_onShortBreakStart != null) _onShortBreakStart!();
              break;
            case TimerState.longBreak:
              if (_onLongBreakStart != null) _onLongBreakStart!();
              break;
            case TimerState.idle:
              break;
          }
        }

        debugPrint('Current phase index after handling: $_currentPhaseIndex');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      });
    }
  }

  // Navigate backward in the session chain (like a linked list)
  void navigateBackward() {
    debugPrint('⏮️ Navigating backward from phase $_currentPhaseIndex');

    if (_currentPhaseIndex <= 0) {
      debugPrint('Already at beginning or idle');
      if (_currentPhaseIndex == 0) {
        resetTimer(); // Go to idle
      }
      return;
    }

    // Move to previous phase in the chain
    int newIndex = _currentPhaseIndex - 1;
    debugPrint('Moving to phase $newIndex');

    pauseTimer();
    _startPhaseByIndex(newIndex);

    // Call appropriate callback
    if (newIndex >= 0 && newIndex < _sessionChain.length) {
      SessionPhase phase = _sessionChain[newIndex];
      switch (phase.state) {
        case TimerState.work:
          if (_onWorkSessionStart != null) _onWorkSessionStart!();
          break;
        case TimerState.shortBreak:
          if (_onShortBreakStart != null) _onShortBreakStart!();
          break;
        case TimerState.longBreak:
          if (_onLongBreakStart != null) _onLongBreakStart!();
          break;
        case TimerState.idle:
          break;
      }
    }
  }

  // Navigate forward in the session chain (like a linked list)
  void navigateForward() {
    debugPrint('⏭️ Navigating forward from phase $_currentPhaseIndex');

    // If at long break (phase 7), complete the session
    if (_currentPhaseIndex == 7) {
      debugPrint('📍 At long break - completing session when forwarding');
      _completeSession();
      return;
    }

    if (_currentPhaseIndex >= 7) {
      debugPrint('Already at or past end of session');
      return;
    }

    // If idle, start from beginning
    if (_currentPhaseIndex < 0) {
      debugPrint('Starting from idle - going to phase 0');
      _startPhaseByIndex(0);
      if (_onWorkSessionStart != null) _onWorkSessionStart!();
      return;
    }

    // Move to next phase in the chain
    int newIndex = _currentPhaseIndex + 1;
    debugPrint('Moving to phase $newIndex');

    pauseTimer();
    _startPhaseByIndex(newIndex);

    // Call appropriate callback
    if (newIndex >= 0 && newIndex < _sessionChain.length) {
      SessionPhase phase = _sessionChain[newIndex];
      switch (phase.state) {
        case TimerState.work:
          if (_onWorkSessionStart != null) _onWorkSessionStart!();
          break;
        case TimerState.shortBreak:
          if (_onShortBreakStart != null) _onShortBreakStart!();
          break;
        case TimerState.longBreak:
          if (_onLongBreakStart != null) _onLongBreakStart!();
          break;
        case TimerState.idle:
          break;
      }
    }
  }

  void resetStats() {
    debugPrint('🔄 Resetting all stats');
    _currentPhaseIndex = -1;
    _completedFullSessions = 0;
    _currentSessionStart = null;
    _currentSessionEnd = null;
    _currentPhaseStart = null;
    _sessionPhases = [];
    _emitUpdate();

    if (_enableNotifications) {
      _notificationController.showPopupAlert(
          'Stats Reset', 'Your Pomodoro statistics have been reset.');
    }
  }

  void dispose() {
    debugPrint('🗑️ Disposing PomodoroTimerService');
    _timer?.cancel();
    _timer = null;
    _stateController.close();
  }
}

class TimerUpdate {
  final TimerState state;
  final int secondsRemaining;
  final bool isRunning;
  final int completedSessions;
  final int completedFullSessions;
  final int currentPhaseIndex;

  TimerUpdate({
    required this.state,
    required this.secondsRemaining,
    required this.isRunning,
    required this.completedSessions,
    required this.completedFullSessions,
    required this.currentPhaseIndex,
  });
}
