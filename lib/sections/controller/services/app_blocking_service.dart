import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../settings_data_controller.dart';

enum BlockingBehavior { none, soft, hard }

class AppBlockingService {
  static final AppBlockingService _instance = AppBlockingService._internal();
  factory AppBlockingService() => _instance;
  AppBlockingService._internal();

  static const _fwChannel = MethodChannel('foreground_window_plugin');
  static const _overlayChannel = MethodChannel('timemark/block_overlay');
  static const _settingsKey = 'limitsAlerts.blockingBehavior';

  // Current overlay state
  String? _activeAppName;
  int? _activePid;
  Timer? _graceTimer;

  // Per-day unblock: appName → 'yyyy-MM-dd'
  final Map<String, String> _unblockedToday = {};
  // Grace expiry
  final Map<String, DateTime> _gracePeriods = {};
  // Post-dismiss cooldown (30 s)
  final Map<String, DateTime> _cooldowns = {};

  BlockingBehavior get behavior {
    final val = SettingsManager().getSetting(_settingsKey) as String?;
    switch (val) {
      case 'soft': return BlockingBehavior.soft;
      case 'hard': return BlockingBehavior.hard;
      default:     return BlockingBehavior.none;
    }
  }

  void setBehavior(BlockingBehavior b) {
    final val = b == BlockingBehavior.soft ? 'soft'
               : b == BlockingBehavior.hard ? 'hard'
               : 'none';
    SettingsManager().updateSetting(_settingsKey, val);
  }

  // ── Called by BackgroundAppTracker ────────────────────────────────────────

  void onLimitedAppFocused({
    required String appName,
    required int pid,
    required Duration usedTime,
    required Duration limitTime,
  }) {
    if (behavior == BlockingBehavior.none) return;
    if (usedTime < limitTime) return;
    if (_isUnblockedToday(appName)) return;
    if (_isInGracePeriod(appName)) return;
    if (_isInCooldown(appName)) return;
    // Already showing overlay for this app — don't re-trigger
    if (_activeAppName == appName && _activePid != null) return;

    _activeAppName = appName;
    _activePid = pid;

    if (!Platform.isMacOS) return;

    // Show native floating panel, then listen for the user's button choice
    _showNativeOverlay(
      pid: pid,
      appName: appName,
      usedSeconds: usedTime.inSeconds,
      limitSeconds: limitTime.inSeconds,
    );

  }

  // ── Native overlay ────────────────────────────────────────────────────────

  Future<void> _showNativeOverlay({
    required int pid,
    required String appName,
    required int usedSeconds,
    required int limitSeconds,
  }) async {
    try {
      // Register callback handler before showing so we never miss an action
      _overlayChannel.setMethodCallHandler(_handleOverlayAction);
      await _overlayChannel.invokeMethod('show', {
        'pid': pid,
        'appName': appName,
        'usedSeconds': usedSeconds,
        'limitSeconds': limitSeconds,
        'hardBlock': behavior == BlockingBehavior.hard,
      });
    } catch (e) {
      debugPrint('⚠️ showNativeOverlay failed: $e');
    }
  }

  Future<dynamic> _handleOverlayAction(MethodCall call) async {
    if (call.method != 'onAction') return;
    final action = call.arguments as String? ?? '';
    final appName = _activeAppName ?? '';
    final pid = _activePid ?? 0;

    switch (action) {
      case 'minimize':
        await hideOtherApp(pid);
        _clearActive();
      case 'quit':
        await terminateOtherApp(pid);
        _clearActive();
      case 'grace':
        _startGrace(appName);
      case 'unblock':
        unblockForToday(appName);
        await _overlayChannel.invokeMethod('dismiss');
        _clearActive();
      case 'dismiss': // kept for safety but no longer surfaced in UI
        _clearActive();
    }
  }

  void _startGrace(String appName) {
    _gracePeriods[appName] = DateTime.now().add(const Duration(minutes: 5));
    _graceTimer?.cancel();
    var secondsLeft = 300;
    // Tell native panel to show countdown
    _overlayChannel.invokeMethod('startGrace', 300).catchError((_) {});
    _graceTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      secondsLeft--;
      if (secondsLeft <= 0) {
        t.cancel();
        _graceTimer = null;
        _overlayChannel.invokeMethod('dismiss').catchError((_) {});
        _clearActive();
      }
    });
  }

  void _clearActive() {
    _activeAppName = null;
    _activePid = null;
    _graceTimer?.cancel();
    _graceTimer = null;
    _overlayChannel.setMethodCallHandler(null);
  }

  // ── State helpers ─────────────────────────────────────────────────────────

  void grantGracePeriod(String appName) {
    _gracePeriods[appName] = DateTime.now().add(const Duration(minutes: 5));
  }

  void unblockForToday(String appName) {
    final today = DateTime.now();
    _unblockedToday[appName] =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  }

  bool _isUnblockedToday(String appName) {
    final stored = _unblockedToday[appName];
    if (stored == null) return false;
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return stored == todayStr;
  }

  bool _isInGracePeriod(String appName) {
    final expiry = _gracePeriods[appName];
    if (expiry == null) return false;
    if (DateTime.now().isBefore(expiry)) return true;
    _gracePeriods.remove(appName);
    return false;
  }

  bool _isInCooldown(String appName) {
    final expiry = _cooldowns[appName];
    if (expiry == null) return false;
    if (DateTime.now().isBefore(expiry)) return true;
    _cooldowns.remove(appName);
    return false;
  }

  // ── Native calls ──────────────────────────────────────────────────────────

  Future<void> hideOtherApp(int pid) async {
    if (!Platform.isMacOS) return;
    try {
      await _fwChannel.invokeMethod('hideOtherApp', {'pid': pid});
    } catch (e) {
      debugPrint('⚠️ hideOtherApp failed: $e');
    }
  }

  Future<void> terminateOtherApp(int pid) async {
    if (!Platform.isMacOS) return;
    try {
      await _fwChannel.invokeMethod('terminateOtherApp', {'pid': pid});
    } catch (e) {
      debugPrint('⚠️ terminateOtherApp failed: $e');
    }
  }

  void dispose() {
    _graceTimer?.cancel();
    _overlayChannel.setMethodCallHandler(null);
  }
}
