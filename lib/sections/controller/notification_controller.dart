import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';

import 'data_controllers/alerts_limits_data_controller.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

class _NotificationType {
  const _NotificationType._();
  static const String focus = 'focus';
  static const String screenTime = 'screenTime';
  static const String appLimit = 'appLimit';
  static const String popup = 'popup';
}

// ============================================================================
// NOTIFICATION CONTROLLER
// ============================================================================

class NotificationController with ChangeNotifier {
  static final NotificationController _instance =
      NotificationController._internal();
  factory NotificationController() => _instance;
  NotificationController._internal();

  static final bool _isMacOS = Platform.isMacOS;
  static const int autoDismissSeconds = 5;
  static const Duration _permissionCacheDuration = Duration(seconds: 30);
  static const Duration _snoozeDelay = Duration(minutes: 15);
  static const String _settingsSection = 'notificationController';

  // Dependencies
  final SettingsManager _settingsManager = SettingsManager();
  final ScreenTimeDataController _screenTimeController =
      ScreenTimeDataController();

  // State
  Timer? _reminderTimer;
  bool _soundEnabled = true;
  int _reminderFrequency = 60;

  // Pending alerts: alertId → creation time
  final Map<int, DateTime> _pendingAlerts = {};

  // Popup alert callback
  Function(String title, String message,
      {Function? onClose, Function? onRemind})? _showAlertCallback;

  // Permission cache
  NotificationPermissionStatus? _cachedPermissionStatus;
  DateTime? _lastPermissionCheck;

  // Daily notification dedup tracking
  final Set<String> _notifiedApproachingApps = {};
  final Set<String> _notifiedExceededApps = {};
  bool _notifiedOverallApproaching = false;
  bool _notifiedOverallExceeded = false;

  // --------------------------------------------------------------------------
  // INITIALIZATION
  // --------------------------------------------------------------------------

  Future<void> initialize() async {
    await localNotifier.setup(
      appName: 'TimeMark',
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );

    _ensureSettingsSection();
    _loadSettings();

    if (_isMacOS) {
      await _checkAndCachePermission();
    }
  }

  void _ensureSettingsSection() {
    if (_settingsManager.getSetting(_settingsSection) == null) {
      _settingsManager.updateSetting(_settingsSection, {
        "reminderFrequency": 60,
      });
    }
  }

  void _loadSettings() {
    final notifications = _settingsManager.getSetting('notifications');
    final frequency =
        _settingsManager.getSetting('$_settingsSection.reminderFrequency');

    if (notifications != null) {
      _soundEnabled = notifications['sound'] ?? true;
    }
    _reminderFrequency = frequency ?? 60;
    notifyListeners();
  }

  void refreshSettings() => _loadSettings();

  // --------------------------------------------------------------------------
  // PERMISSIONS (macOS)
  // --------------------------------------------------------------------------

  NotificationPermissionStatus? get permissionStatus => _cachedPermissionStatus;

  bool get canSendNotifications {
    if (!_isMacOS) return true;
    return _cachedPermissionStatus?.isGranted ?? false;
  }

  Future<bool> _checkAndCachePermission() async {
    if (!_isMacOS) return true;

    if (_cachedPermissionStatus != null &&
        _lastPermissionCheck != null &&
        DateTime.now().difference(_lastPermissionCheck!) <
            _permissionCacheDuration) {
      return _cachedPermissionStatus!.isGranted;
    }

    try {
      _cachedPermissionStatus = await localNotifier.checkPermission();
      _lastPermissionCheck = DateTime.now();

      if (!_cachedPermissionStatus!.isGranted) {
        debugPrint(
            '🍎 macOS notification permission not granted: ${_cachedPermissionStatus!.status}');
      }
      return _cachedPermissionStatus!.isGranted;
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      return false;
    }
  }

  Future<void> refreshPermissionStatus() async {
    _cachedPermissionStatus = null;
    _lastPermissionCheck = null;
    await _checkAndCachePermission();
  }

  /// Returns false (and logs) if macOS permission is missing.
  Future<bool> _ensurePermission([String context = 'notification']) async {
    if (!_isMacOS) return true;
    final granted = await _checkAndCachePermission();
    if (!granted) {
      debugPrint('🍎 Cannot send $context: permission not granted');
    }
    return granted;
  }

  // --------------------------------------------------------------------------
  // SETTINGS – PUBLIC API
  // --------------------------------------------------------------------------

  bool getSoundEnabled() => _soundEnabled;
  int getReminderFrequency() => _reminderFrequency;

  bool getUseSystemNotifications() =>
      _settingsManager.getSetting('notifications')?['system'] ?? true;

  bool getUsePopupAlerts() =>
      _settingsManager.getSetting('notifications')?['popup'] ?? true;

  void setReminderFrequency(int seconds) {
    _reminderFrequency = seconds;
    _settingsManager.updateSetting(
        '$_settingsSection.reminderFrequency', seconds);
    notifyListeners();
  }

  void registerAlertHandler(
    Function(String title, String message,
            {Function? onClose, Function? onRemind})
        showAlert,
  ) {
    _showAlertCallback = showAlert;
  }

  // --------------------------------------------------------------------------
  // HELPERS
  // --------------------------------------------------------------------------

  int _generateId() => DateTime.now().millisecondsSinceEpoch % 10000;

  bool _isSettingEnabled(String path) =>
      _settingsManager.getSetting(path) ?? true;

  /// Builds the reminder body for a given [type] and optional [extraData].
  String _reminderBody(String type, [String? extraData]) {
    switch (type) {
      case _NotificationType.focus:
        return 'You have an unacknowledged focus alert';
      case _NotificationType.screenTime:
        return 'You have an unacknowledged screen time alert';
      case _NotificationType.appLimit:
        if (extraData != null) {
          return 'You have an unacknowledged app limit alert for $extraData';
        }
        return 'You have an unacknowledged app limit alert';
      default:
        return 'You have an unacknowledged alert';
    }
  }

  /// Builds the 15-min snooze body for a given [type] and optional [extraData].
  String _snoozeBody(String type, [String? extraData]) {
    switch (type) {
      case _NotificationType.focus:
        return 'This is your 15-minute reminder about your focus session';
      case _NotificationType.screenTime:
        return 'This is your 15-minute reminder about your screen time limit';
      case _NotificationType.appLimit:
        if (extraData != null) {
          return 'This is your 15-minute reminder about your app limit for $extraData';
        }
        return 'This is your 15-minute reminder about your app limit';
      default:
        return 'This is your 15-minute reminder';
    }
  }

  // --------------------------------------------------------------------------
  // CORE NOTIFICATION ENGINE
  // --------------------------------------------------------------------------

  Future<void> _sendNotification(
    String title,
    String body,
    String type, {
    String? extraData,
    bool includeRemindAction = true,
    bool scheduleReminder = true,
  }) async {
    final bool useSystem = getUseSystemNotifications();
    final bool usePopup = getUsePopupAlerts();

    final id = _generateId();
    _pendingAlerts[id] = DateTime.now();
    _reminderTimer?.cancel();

    void onClose() => _handleClose(id);
    void onRemind() => _handleRemind(id, type, extraData);

    // System notification
    if (useSystem) {
      await _showSystemNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        extraData: extraData,
        includeRemindAction: includeRemindAction,
      );
    }

    // In-app popup
    if (_showAlertCallback != null && usePopup) {
      _showAlertCallback!(
        title,
        body,
        onClose: onClose,
        onRemind: includeRemindAction ? onRemind : null,
      );

      _autoDismiss(id, type, extraData: extraData);
    }

    if (scheduleReminder) {
      _scheduleReminderIfNeeded(id, type, extraData);
    }
  }

  Future<void> _showSystemNotification({
    required int id,
    required String title,
    required String body,
    required String type,
    String? extraData,
    bool includeRemindAction = true,
  }) async {
    try {
      final actions = _soundEnabled
          ? [
              LocalNotificationAction(text: 'Close', type: 'close'),
              if (includeRemindAction)
                LocalNotificationAction(text: 'Remind Later', type: 'remind'),
            ]
          : null;

      final notification = LocalNotification(
        title: title,
        body: body,
        actions: actions,
      );

      notification.onClickAction = (actionIndex) {
        if (actionIndex == 0) {
          _handleClose(id);
        } else if (actionIndex == 1 && includeRemindAction) {
          _handleRemind(id, type, extraData);
        }
      };

      _autoDismiss(id, type, extraData: extraData);
      await notification.show();
    } catch (e) {
      debugPrint('Error showing system notification: $e');
    }
  }

  void _autoDismiss(int id, String type, {String? extraData}) {
    Timer(const Duration(seconds: autoDismissSeconds), () {
      if (_pendingAlerts.containsKey(id)) {
        _handleClose(id);
      }
    });
  }

  // --------------------------------------------------------------------------
  // REMINDER SCHEDULING
  // --------------------------------------------------------------------------

  void _scheduleReminderIfNeeded(int id, String type, [String? extraData]) {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(
      Duration(minutes: _reminderFrequency),
      (timer) {
        if (!_pendingAlerts.containsKey(id)) {
          timer.cancel();
          return;
        }
        _sendNotification(
          'Reminder',
          _reminderBody(type, extraData),
          type,
          extraData: extraData,
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // ACTION HANDLERS
  // --------------------------------------------------------------------------

  void _handleClose(int id) {
    _pendingAlerts.remove(id);
    _reminderTimer?.cancel();
  }

  void _handleRemind(int id, String type, [String? extraData]) {
    _pendingAlerts.remove(id);
    _reminderTimer?.cancel();

    Timer(_snoozeDelay, () {
      _sendNotification(
        '15-Minute Reminder',
        _snoozeBody(type, extraData),
        type,
        extraData: extraData,
      );
    });
  }

  // --------------------------------------------------------------------------
  // PUBLIC NOTIFICATION SENDERS
  // --------------------------------------------------------------------------

  Future<void> sendFocusNotification(String mode, bool isCompleted) async {
    if (!_isSettingEnabled('notifications.enabled') ||
        !_isSettingEnabled('notifications.focusMode')) {
      return;
    }
    if (!await _ensurePermission('focus notification')) return;

    final title = isCompleted ? '$mode Completed' : '$mode Started';
    final body = isCompleted
        ? 'Your $mode session has ended.'
        : 'Your $mode session has started.';

    await _sendNotification(
      title,
      body,
      _NotificationType.focus,
      includeRemindAction: false,
      scheduleReminder: false,
    );
  }

  Future<void> sendScreenTimeNotification(int limitInMinutes) async {
    if (!_isSettingEnabled('notifications.enabled') ||
        !_isSettingEnabled('limitsAlerts.overallLimit.enabled')) {
      return;
    }
    if (!await _ensurePermission('screen time notification')) return;

    await _sendNotification(
      'Screen Time Limit Reached',
      'You have reached your daily screen time limit of $limitInMinutes minutes.',
      _NotificationType.screenTime,
    );
  }

  Future<void> sendAppLimitNotification(
      String appName, int limitInMinutes) async {
    if (!_isSettingEnabled('notifications.enabled') ||
        !_isSettingEnabled('notifications.overallLimit.enabled')) {
      return;
    }
    if (!await _ensurePermission('app limit notification')) return;

    await _sendNotification(
      'App Time Limit Reached',
      'You have reached your time limit of $limitInMinutes minutes for $appName.',
      _NotificationType.appLimit,
      extraData: appName,
    );
  }

  Future<void> showPopupAlert(String title, String message) async {
    if (!getUsePopupAlerts() || _showAlertCallback == null) return;

    if (_isMacOS && getUseSystemNotifications()) {
      await _ensurePermission('popup alert notification');
      // Still show in-app popup even without system permission
    }

    final id = _generateId();
    _pendingAlerts[id] = DateTime.now();

    _showAlertCallback!(
      title,
      message,
      onClose: () => _handleClose(id),
      onRemind: () {
        _handleClose(id);
        Timer(_snoozeDelay, () => showPopupAlert('Reminder: $title', message));
      },
    );

    _scheduleReminderIfNeeded(id, _NotificationType.popup);
  }

  // --------------------------------------------------------------------------
  // SCREEN TIME MONITORING
  // --------------------------------------------------------------------------

  Future<void> checkAndSendNotifications() async {
    if (!await _ensurePermission('notification check')) return;

    await _checkAppLimits();
    await _checkOverallLimit();
  }

  Future<void> _checkAppLimits() async {
    final appSummaries = _screenTimeController.getAllAppsSummary();

    for (final app in appSummaries) {
      if (!app.limitStatus) continue;

      if (app.currentUsage >= app.dailyLimit) {
        if (_notifiedExceededApps.add(app.appName)) {
          await sendAppLimitNotification(app.appName, app.dailyLimit.inMinutes);
        }
      } else if (app.percentageOfLimitUsed >= 0.9) {
        if (_notifiedApproachingApps.add(app.appName)) {
          await showPopupAlert(
            'Approaching App Limit',
            "You're about to reach your daily limit for ${app.appName}",
          );
        }
      }
    }
  }

  Future<void> _checkOverallLimit() async {
    if (!_screenTimeController.overallLimitEnabled) return;

    final overallLimit = _screenTimeController.overallLimit;
    final currentUsage = _screenTimeController.getOverallUsage();

    if (currentUsage >= overallLimit) {
      if (!_notifiedOverallExceeded) {
        await sendScreenTimeNotification(overallLimit.inMinutes);
        _notifiedOverallExceeded = true;
      }
    } else if (currentUsage.inMinutes >= overallLimit.inMinutes * 0.9) {
      if (!_notifiedOverallApproaching) {
        await showPopupAlert(
          'Approaching Screen Time Limit',
          "You're about to reach your daily screen time limit of ${overallLimit.inMinutes} minutes",
        );
        _notifiedOverallApproaching = true;
      }
    }
  }

  // --------------------------------------------------------------------------
  // CLEANUP
  // --------------------------------------------------------------------------

  void resetNotifications() {
    _notifiedApproachingApps.clear();
    _notifiedExceededApps.clear();
    _notifiedOverallApproaching = false;
    _notifiedOverallExceeded = false;
  }

  void cancelAllReminders() {
    _pendingAlerts.clear();
    _reminderTimer?.cancel();
  }
}
