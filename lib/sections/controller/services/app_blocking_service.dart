import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../settings_data_controller.dart';
import '../../../foreground_window_plugin.dart';

enum BlockingBehavior { none, soft, hard }

class AppBlockingService {
  static final AppBlockingService _instance = AppBlockingService._internal();
  factory AppBlockingService() => _instance;
  AppBlockingService._internal();

  static const _fwChannel = MethodChannel('foreground_window_plugin');
  static const _overlayChannel = MethodChannel('timemark/block_overlay');
  static const _settingsKey = 'limitsAlerts.blockingBehavior';

  // Current overlay state
  String? _activeAppId;
  int? _activePid;
  Timer? _graceTimer;

  // All per-app state below is keyed by the stable appId, not the display
  // name, so "unblock for today"/grace/cooldown correctly survive a
  // mid-day change in how an app's name resolves.

  // Per-day unblock: appId → 'yyyy-MM-dd'
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
    required String appId,
    required String displayName,
    required int pid,
    required Duration usedTime,
    required Duration limitTime,
  }) {
    if (behavior == BlockingBehavior.none) return;
    if (usedTime < limitTime) return;
    if (_isUnblockedToday(appId)) return;
    if (_isInGracePeriod(appId)) return;
    if (_isInCooldown(appId)) return;
    // Already showing overlay for this app — don't re-trigger
    if (_activeAppId == appId && _activePid != null) return;

    _activeAppId = appId;
    _activePid = pid;

    if (!Platform.isMacOS && !Platform.isWindows) return;

    // Show native floating panel, then listen for the user's button choice
    _showNativeOverlay(
      pid: pid,
      appName: displayName,
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
    final appId = _activeAppId ?? '';
    final pid = _activePid ?? 0;

    switch (action) {
      case 'minimize':
        await hideOtherApp(pid);
        _clearActive();
      case 'quit':
        await terminateOtherApp(pid);
        _clearActive();
      case 'grace':
        _startGrace(appId);
      case 'unblock':
        unblockForToday(appId);
        await _overlayChannel.invokeMethod('dismiss');
        _clearActive();
      case 'dismiss': // kept for safety but no longer surfaced in UI
        _clearActive();
    }
  }

  void _startGrace(String appId) {
    _gracePeriods[appId] = DateTime.now().add(const Duration(minutes: 5));
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
    _activeAppId = null;
    _activePid = null;
    _graceTimer?.cancel();
    _graceTimer = null;
    _overlayChannel.setMethodCallHandler(null);
  }

  // ── State helpers ─────────────────────────────────────────────────────────

  void grantGracePeriod(String appId) {
    _gracePeriods[appId] = DateTime.now().add(const Duration(minutes: 5));
  }

  void unblockForToday(String appId) {
    final today = DateTime.now();
    _unblockedToday[appId] =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  }

  bool _isUnblockedToday(String appId) {
    final stored = _unblockedToday[appId];
    if (stored == null) return false;
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return stored == todayStr;
  }

  bool _isInGracePeriod(String appId) {
    final expiry = _gracePeriods[appId];
    if (expiry == null) return false;
    if (DateTime.now().isBefore(expiry)) return true;
    _gracePeriods.remove(appId);
    return false;
  }

  bool _isInCooldown(String appId) {
    final expiry = _cooldowns[appId];
    if (expiry == null) return false;
    if (DateTime.now().isBefore(expiry)) return true;
    _cooldowns.remove(appId);
    return false;
  }

  // ── Native calls ──────────────────────────────────────────────────────────

  Future<void> hideOtherApp(int pid) async {
    try {
      if (Platform.isMacOS) {
        await _fwChannel.invokeMethod('hideOtherApp', {'pid': pid});
      } else if (Platform.isWindows) {
        await ForegroundWindowPlugin.hideOtherApp(pid);
      }
    } catch (e) {
      debugPrint('hideOtherApp failed: $e');
    }
  }

  Future<void> terminateOtherApp(int pid) async {
    try {
      if (Platform.isMacOS) {
        await _fwChannel.invokeMethod('terminateOtherApp', {'pid': pid});
      } else if (Platform.isWindows) {
        await ForegroundWindowPlugin.terminateOtherApp(pid);
      }
    } catch (e) {
      debugPrint('terminateOtherApp failed: $e');
    }
  }

  void dispose() {
    _graceTimer?.cancel();
    _overlayChannel.setMethodCallHandler(null);
  }
}
