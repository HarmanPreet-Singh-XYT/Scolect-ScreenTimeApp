// background_app_tracker.dart
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:desktop_screenstate/desktop_screenstate.dart';
import 'package:screentime/foreground_window_plugin.dart';
import 'package:screentime/sections/controller/notification_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_focus/window_focus.dart';
import 'app_data_controller.dart';
import 'categories_controller.dart';

enum TrackingMode {
  polling,
  precise,
}

class BackgroundAppTracker {
  // ============================================================
  // SINGLETON
  // ============================================================
  static final BackgroundAppTracker _instance =
      BackgroundAppTracker._internal();
  factory BackgroundAppTracker() => _instance;
  BackgroundAppTracker._internal();

  // ============================================================
  // CONTROLLERS
  // ============================================================
  final NotificationController _notificationController =
      NotificationController();

  // ============================================================
  // STATE
  // ============================================================
  TrackingMode _trackingMode = TrackingMode.precise;
  bool _isTracking = false;
  bool _isUserActive = true;
  AppLocalizations? _localizations;
  String _currentLocale = 'en';
  AppDataStore? _appDataStore;

  final StreamController<String> _appUpdateController =
      StreamController<String>.broadcast();
  Stream<String> get appUpdates => _appUpdateController.stream;

  // ============================================================
  // SCREEN STATE — three independent flags
  // ALL must be false for tracking to be active.
  // ============================================================
  bool _systemAsleep = false;
  bool _screenOff = false;
  bool _locked = false;

  // Debounce timers for resume events — macOS fires spurious unlock/awaked
  // before screenOff/locked, so we delay acting on them briefly.
  Timer? _unlockDebounce;
  Timer? _awakedDebounce;

  bool get _screenStateAllowsTracking =>
      !_systemAsleep && !_screenOff && !_locked;

  // Called by the DesktopScreenState listener
  void _onScreenStateEvent(String event) {
    debugPrint('🖥️ Screen state: $event');

    // Debounce resume events — macOS emits:
    //   locked → unlocked → screenOff → locked → unlocked (real)
    // The spurious unlocked/awaked in the middle must be ignored.
    if (event == 'unlocked') {
      _unlockDebounce?.cancel();
      _unlockDebounce = Timer(const Duration(milliseconds: 500), () {
        _applyScreenStateEvent('unlocked');
      });
      return;
    }

    if (event == 'awaked') {
      _awakedDebounce?.cancel();
      _awakedDebounce = Timer(const Duration(milliseconds: 500), () {
        _applyScreenStateEvent('awaked');
      });
      return;
    }

    // For immediate pause events, cancel any pending resume debounces
    // so a spurious unlock doesn't fire after we've already locked again.
    if (event == 'locked' || event == 'screenOff' || event == 'sleep') {
      _unlockDebounce?.cancel();
      _unlockDebounce = null;
      _awakedDebounce?.cancel();
      _awakedDebounce = null;
    }

    _applyScreenStateEvent(event);
  }

  void _applyScreenStateEvent(String event) {
    final wasAllowed = _screenStateAllowsTracking;

    // For PAUSE events: save BEFORE flipping the flag.
    // If we flip first, _screenStateAllowsTracking becomes false and
    // _saveCurrentAppTime would skip the save — losing elapsed time.
    if ((event == 'sleep' || event == 'screenOff' || event == 'locked') &&
        wasAllowed) {
      if (_trackingMode == TrackingMode.precise) {
        _commitCurrentAppTime();
      }
    }

    // Flip the flag
    switch (event) {
      case 'sleep':
        _systemAsleep = true;
        break;
      case 'screenOff':
        _screenOff = true;
        break;
      case 'locked':
        _locked = true;
        break;
      // Any resume event clears ALL flags — handles macOS quirks where
      // screenOn is never sent after lock-wake, or awaked skips screenOn etc.
      case 'awaked':
      case 'screenOn':
      case 'unlocked':
        _systemAsleep = false;
        _screenOff = false;
        _locked = false;
        break;
    }

    // For RESUME events: reset start time so sleep/off/lock duration
    // is never counted as app usage
    if (!wasAllowed && _screenStateAllowsTracking) {
      debugPrint('▶️ Resuming tracking');
      if (_trackingMode == TrackingMode.precise) {
        _currentAppStartTime = DateTime.now();
      }
    }

    debugPrint(
        '   flags → asleep=$_systemAsleep off=$_screenOff locked=$_locked allows=$_screenStateAllowsTracking');
  }

  // ============================================================
  // WINDOW FOCUS PLUGIN
  // ============================================================
  WindowFocus? _windowFocusPlugin;

  // ============================================================
  // POLLING STATE
  // ============================================================
  Timer? _pollingTimer;

  // ============================================================
  // PRECISE MODE STATE
  // ============================================================
  String _currentApp = '';
  DateTime _currentAppStartTime = DateTime.now();
  Timer? _selfTrackingHeartbeat;
  Timer? _universalHeartbeat;

  static const String _selfAppName = 'Scolect - Track Screen Time & App Usage';

  final Map<String, AppMetadata> _metadataCache = {};
  bool _metadataCacheLoaded = false;

  // ============================================================
  // GETTERS
  // ============================================================
  TrackingMode get trackingMode => _trackingMode;
  bool get isTracking => _isTracking;
  bool get isUserActive => _isUserActive;

  // ============================================================
  // INITIALIZATION
  // ============================================================
  Future<void> initializeTracking({String? locale}) async {
    try {
      _currentLocale =
          locale ?? SettingsManager().getSetting("language.selected") ?? 'en';
      await _loadLocalizations(_currentLocale);

      String modeString =
          SettingsManager().getSetting("tracking.mode") ?? 'polling';
      _trackingMode =
          modeString == 'precise' ? TrackingMode.precise : TrackingMode.polling;

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🚀 INITIALIZING BACKGROUND APP TRACKER');
      debugPrint('   Locale: $_currentLocale | Mode: ${_trackingMode.name}');
      debugPrint('═══════════════════════════════════════════════════════');

      await _initializeAppDataStore();
      await _loadMetadataCache();
      await _initializeWindowFocusPlugin();

      // Wire up screen state listener BEFORE starting tracking
      DesktopScreenState.instance.isActive.addListener(_onScreenStateChanged);
      debugPrint('✅ ScreenState listener attached');

      if (_trackingMode == TrackingMode.polling) {
        await _startPollingMode();
      } else {
        await _startPreciseMode();
      }

      _isTracking = true;

      debugPrint(
          '✅ BACKGROUND TRACKER INITIALIZED — mode: ${_trackingMode.name}');
    } catch (e) {
      debugPrint('❌ Tracking initialization error: $e');
    }
  }

  void _onScreenStateChanged() {
    final state = DesktopScreenState.instance.isActive.value;
    _onScreenStateEvent(state.name); // .name gives the enum string e.g. 'sleep'
  }

  // ============================================================
  // APP DATA STORE
  // ============================================================
  Future<void> _initializeAppDataStore() async {
    if (_appDataStore == null) {
      _appDataStore = AppDataStore();
      await _appDataStore!.init();
      debugPrint('✅ AppDataStore initialized');
    }
  }

  // ============================================================
  // METADATA CACHE
  // ============================================================
  Future<void> _loadMetadataCache() async {
    if (_appDataStore == null) return;
    try {
      final allApps = _appDataStore!.allAppNames;
      for (final appName in allApps) {
        final metadata = _appDataStore!.getAppMetadata(appName);
        if (metadata != null) _metadataCache[appName] = metadata;
      }
      _metadataCacheLoaded = true;
      debugPrint('✅ Metadata cache loaded: ${_metadataCache.length} apps');
    } catch (e) {
      debugPrint('❌ Error loading metadata cache: $e');
    }
  }

  // ============================================================
  // WINDOW FOCUS PLUGIN
  // ============================================================
  Future<void> _initializeWindowFocusPlugin() async {
    bool idleDetectionEnabled =
        SettingsManager().getSetting("tracking.idleDetection") ?? true;
    int idleTimeoutSeconds =
        SettingsManager().getSetting("tracking.idleTimeout") ?? 60;
    bool monitorAudio =
        SettingsManager().getSetting("tracking.monitorAudio") ?? false;
    bool monitorControllers =
        SettingsManager().getSetting("tracking.monitorControllers") ?? false;
    bool monitorHIDDevices =
        SettingsManager().getSetting("tracking.monitorHIDDevices") ?? false;
    bool monitorKeyboard =
        SettingsManager().getSetting("tracking.monitorKeyboard") ??
            !Platform.isMacOS;
    double audioThreshold =
        SettingsManager().getSetting("tracking.audioThreshold") ?? 0.001;

    _windowFocusPlugin = WindowFocus(
      debug: false,
      duration: Duration(seconds: idleTimeoutSeconds),
      monitorAudio: monitorAudio,
      monitorControllers: monitorControllers,
      monitorHIDDevices: monitorHIDDevices,
      audioThreshold: audioThreshold,
      monitorKeyboard: monitorKeyboard,
    );

    _windowFocusPlugin!.addFocusChangeListener(_handleFocusChange);

    if (idleDetectionEnabled) {
      _windowFocusPlugin!.addUserActiveListener(_handleUserActivityChange);
    } else {
      _isUserActive = true;
    }

    debugPrint('✅ WindowFocus plugin initialized');
  }

  // ============================================================
  // MODE SWITCHING
  // ============================================================
  Future<void> setTrackingMode(TrackingMode mode) async {
    if (_trackingMode == mode) return;

    debugPrint('🔄 Switching mode: ${_trackingMode.name} → ${mode.name}');

    await _stopCurrentMode();
    _trackingMode = mode;
    SettingsManager().updateSetting("tracking.mode", mode.name);

    if (mode == TrackingMode.polling) {
      await _startPollingMode();
    } else {
      await _startPreciseMode();
    }
  }

  Future<void> _stopCurrentMode() async {
    if (_trackingMode == TrackingMode.polling) {
      _pollingTimer?.cancel();
      _pollingTimer = null;
    } else {
      _saveCurrentAppTime();
      _stopSelfTrackingHeartbeat();
      _stopUniversalHeartbeat();
      _currentApp = '';
      _currentAppStartTime = DateTime.now();
    }
  }

  // ============================================================
  // POLLING MODE
  // ============================================================
  Future<void> _startPollingMode() async {
    _pollingTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _executePollingTracking(),
    );
    _executePollingTracking();
    debugPrint('✅ Polling mode started');
  }

  Future<void> _executePollingTracking() async {
    try {
      if (!_screenStateAllowsTracking) {
        debugPrint('⏸️ Polling skipped: screen inactive');
        return;
      }

      bool idleDetectionEnabled =
          SettingsManager().getSetting("tracking.idleDetection") ?? true;
      if (idleDetectionEnabled && !_isUserActive) return;

      final Map<String, dynamic>? currentAppInfo =
          await _getCurrentActiveAppInfo();
      if (currentAppInfo == null) return;

      String appTitle = currentAppInfo['title'] ?? '';

      if (appTitle.contains("Windows Explorer")) appTitle = "";
      if (appTitle == "Productive ScreenTime" || appTitle == "screentime")
        return;
      if (appTitle == "loginwindow" || appTitle == "LockApp") return;

      AppMetadata? metadata = await _getOrCreateMetadata(appTitle);

      if (metadata != null && metadata.isTracking && metadata.isVisible) {
        final now = DateTime.now();
        final startTime = now.subtract(const Duration(minutes: 1));
        await _appDataStore?.recordAppUsage(
          appTitle,
          now,
          const Duration(minutes: 1),
          1,
          [TimeRange(startTime: startTime, endTime: now)],
        );
        debugPrint('📊 Polling: $appTitle (+1 min)');
      }

      _notificationController.checkAndSendNotifications();
      _appUpdateController.add(appTitle);
    } catch (e) {
      debugPrint('❌ Polling error: $e');
    }
  }

  Future<void> reanchorTracking() async {
    if (!_isTracking) return;
    await Future.delayed(const Duration(seconds: 2));

    if (_trackingMode == TrackingMode.precise) {
      _currentAppStartTime = DateTime.now();
      if (_currentApp.isNotEmpty) {
        await _getOrCreateMetadata(_currentApp);
        final now = DateTime.now();
        await _appDataStore
            ?.recordAppUsage(_currentApp, now, Duration.zero, 1, []);
        debugPrint('✅ Re-anchored: $_currentApp');
      }
    } else {
      await _executePollingTracking();
    }
    _appUpdateController.add(_currentApp);
  }

  // ============================================================
  // PRECISE MODE
  // ============================================================
  Future<void> _startPreciseMode() async {
    if (!_metadataCacheLoaded) await _loadMetadataCache();
    _startUniversalHeartbeat();
    debugPrint('✅ Precise mode started');
  }

  void _startSelfTrackingHeartbeat() {
    _selfTrackingHeartbeat?.cancel();
    _selfTrackingHeartbeat = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _heartbeatSelfApp(),
    );
  }

  void _stopSelfTrackingHeartbeat() {
    _selfTrackingHeartbeat?.cancel();
    _selfTrackingHeartbeat = null;
  }

  void _startUniversalHeartbeat() {
    _universalHeartbeat?.cancel();
    _universalHeartbeat = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _heartbeatCurrentApp(),
    );
  }

  void _stopUniversalHeartbeat() {
    _universalHeartbeat?.cancel();
    _universalHeartbeat = null;
  }

  void _heartbeatCurrentApp() {
    if (!_isTracking) return;
    if (_currentApp.isEmpty || _currentApp == _selfAppName) return;
    if (!_screenStateAllowsTracking) return;

    bool idleDetectionEnabled =
        SettingsManager().getSetting("tracking.idleDetection") ?? true;
    if (idleDetectionEnabled && !_isUserActive) return;

    final metadata = _appDataStore?.getAppMetadata(_currentApp);
    if (metadata != null && (!metadata.isTracking || !metadata.isVisible))
      return;

    final now = DateTime.now();
    final elapsed = now.difference(_currentAppStartTime);
    if (elapsed.inSeconds <= 0) return;

    _appDataStore?.recordAppUsage(
      _currentApp,
      now,
      elapsed,
      0,
      [TimeRange(startTime: _currentAppStartTime, endTime: now)],
    );
    _currentAppStartTime = now;
    debugPrint('💓 Heartbeat: $_currentApp (+${elapsed.inSeconds}s)');
  }

  void _heartbeatSelfApp() {
    if (!_isTracking || _currentApp != _selfAppName) return;
    if (!_screenStateAllowsTracking) return;

    bool idleDetectionEnabled =
        SettingsManager().getSetting("tracking.idleDetection") ?? true;
    if (idleDetectionEnabled && !_isUserActive) return;

    final metadata = _appDataStore?.getAppMetadata(_currentApp);
    if (metadata != null && (!metadata.isTracking || !metadata.isVisible))
      return;

    final now = DateTime.now();
    final elapsed = now.difference(_currentAppStartTime);
    if (elapsed.inSeconds <= 0) return;

    _appDataStore?.recordAppUsage(
      _currentApp,
      now,
      elapsed,
      0,
      [TimeRange(startTime: _currentAppStartTime, endTime: now)],
    );
    _currentAppStartTime = now;
    debugPrint('💓 Self-heartbeat: +${elapsed.inSeconds}s');
  }

  // ============================================================
  // FOCUS CHANGE
  // ============================================================
  String _sanitizeWindowTitle(String title) {
    return title
        .replaceAll('\u0000', '')
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '')
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        .trim();
  }

  void _handleFocusChange(AppWindowDto window) async {
    if (_trackingMode == TrackingMode.polling) return;

    if ((window.appName != "Widgets.exe" && window.windowTitle == "") ||
        (window.appName == "explorer.exe" &&
            window.windowTitle == "Program Manager")) return;

    String newApp = await _getCurrentActiveApp();
    if (newApp == "SearchHost" || newApp == "Application Frame Host") {
      newApp = _sanitizeWindowTitle(window.windowTitle);
    }

    if (newApp == "Productive ScreenTime") return;
    if (newApp == "screentime") newApp = _selfAppName;
    if (newApp == "loginwindow" ||
        newApp == "LockApp" ||
        newApp == "UnlockingApp") return;

    if (newApp != _currentApp) {
      _saveCurrentAppTime();

      _currentApp = newApp;
      _currentAppStartTime = DateTime.now();

      await _ensureMetadataExists(newApp);

      final metadata = _appDataStore?.getAppMetadata(newApp);
      if (metadata != null && (!metadata.isTracking || !metadata.isVisible)) {
        _stopSelfTrackingHeartbeat();
        _appUpdateController.add(_currentApp);
        return;
      }

      if (_currentApp == _selfAppName) {
        _startSelfTrackingHeartbeat();
      } else {
        _stopSelfTrackingHeartbeat();
      }

      debugPrint('📱 App: $newApp');
      _appUpdateController.add(_currentApp);
    }
  }

  // ============================================================
  // USER ACTIVITY
  // ============================================================
  void _handleUserActivityChange(bool isActive) {
    if (_trackingMode == TrackingMode.precise) {
      if (!isActive && _isUserActive) _saveCurrentAppTime();
      if (isActive && !_isUserActive) _currentAppStartTime = DateTime.now();
    }
    _isUserActive = isActive;
    debugPrint('👤 User: ${isActive ? "active" : "idle"}');
  }

  // ============================================================
  // SAVE CURRENT APP TIME
  // Two variants:
  //   _saveCurrentAppTime()    — checks screen state (normal use)
  //   _commitCurrentAppTime()  — skips screen state check (used by
  //                              _onScreenStateEvent BEFORE flag is flipped)
  // ============================================================
  void _saveCurrentAppTime() {
    if (_trackingMode != TrackingMode.precise) return;
    if (!_screenStateAllowsTracking) return;

    bool idleDetectionEnabled =
        SettingsManager().getSetting("tracking.idleDetection") ?? true;
    if (idleDetectionEnabled && !_isUserActive) return;

    _commitCurrentAppTime();
  }

  void _commitCurrentAppTime() {
    if (_currentApp.isEmpty) return;

    final metadata = _appDataStore?.getAppMetadata(_currentApp);
    if (metadata != null && (!metadata.isTracking || !metadata.isVisible))
      return;

    final now = DateTime.now();
    final elapsed = now.difference(_currentAppStartTime);
    if (elapsed.inSeconds <= 0) return;

    _appDataStore?.recordAppUsage(
      _currentApp,
      now,
      elapsed,
      1,
      [TimeRange(startTime: _currentAppStartTime, endTime: now)],
    ).then((_) {
      debugPrint('💾 Committed: $_currentApp (${elapsed.inSeconds}s)');
    }).catchError((e) {
      debugPrint('❌ Commit error: $e');
    });

    _currentAppStartTime = now;
    _notificationController.checkAndSendNotifications();
  }

  // ============================================================
  // METADATA
  // ============================================================
  Future<AppMetadata?> _getOrCreateMetadata(String appTitle) async {
    if (appTitle == "Productive ScreenTime" || appTitle == "screentime")
      return null;

    if (_appDataStore != null) {
      final existing = _appDataStore!.getAppMetadata(appTitle);
      if (existing != null) {
        _metadataCache[appTitle] = existing;
        return existing;
      }
    }

    String appCategory =
        appTitle.isEmpty ? 'Idle' : _categorizeAppWithLocale(appTitle);
    bool isProductive = !(appCategory == "Social Media" ||
        appCategory == "Entertainment" ||
        appCategory == "Gaming" ||
        appCategory == "Uncategorized");

    if (_appDataStore != null) {
      await _appDataStore!.updateAppMetadata(appTitle,
          category: appCategory, isProductive: isProductive);
      final created = _appDataStore!.getAppMetadata(appTitle);
      if (created != null) {
        _metadataCache[appTitle] = created;
        return created;
      }
    }

    return null;
  }

  Future<void> _ensureMetadataExists(String appTitle) async {
    await _getOrCreateMetadata(appTitle).catchError((e) {
      debugPrint('⚠️ Metadata error for $appTitle: $e');
    });
  }

  Future<void> refreshMetadataCache() async {
    _metadataCache.clear();
    _metadataCacheLoaded = false;
    await _loadMetadataCache();
  }

  Future<void> clearMetadataCache() async {
    _metadataCache.clear();
    _metadataCacheLoaded = false;
    await _loadMetadataCache();
  }

  Future<void> updateMetadataInCache(
      String appTitle, AppMetadata metadata) async {
    _metadataCache[appTitle] = metadata;
    if (_appDataStore != null) {
      await _appDataStore!.updateAppMetadata(appTitle,
          category: metadata.category,
          isProductive: metadata.isProductive,
          isTracking: metadata.isTracking,
          isVisible: metadata.isVisible,
          dailyLimit: metadata.dailyLimit,
          limitStatus: metadata.limitStatus);
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================
  Future<Map<String, dynamic>?> _getCurrentActiveAppInfo() async {
    try {
      WindowInfo info = await ForegroundWindowPlugin.getForegroundWindowInfo();
      return {'title': info.programName};
    } catch (e) {
      return null;
    }
  }

  Future<String> _getCurrentActiveApp() async {
    try {
      WindowInfo info = await ForegroundWindowPlugin.getForegroundWindowInfo();
      return info.programName;
    } catch (e) {
      return '';
    }
  }

  // ============================================================
  // LOCALIZATION
  // ============================================================
  Future<void> _loadLocalizations(String localeCode) async {
    try {
      final locale = ui.Locale(localeCode);
      _localizations = await AppLocalizations.delegate.load(locale);
    } catch (e) {
      _localizations =
          await AppLocalizations.delegate.load(const ui.Locale('en'));
    }
  }

  Future<void> updateLocale(String locale) async {
    _currentLocale = locale;
    await _loadLocalizations(locale);
  }

  // ============================================================
  // CATEGORIZATION
  // ============================================================
  String _categorizeAppWithLocale(String appTitle) {
    if (_localizations == null) return _categorizeAppEnglishOnly(appTitle);

    for (var category in AppCategories.categories) {
      if (category.apps
          .any((app) => appTitle.toLowerCase().contains(app.toLowerCase()))) {
        return category.name;
      }
    }
    for (var category in AppCategories.categories) {
      for (var app in category.apps) {
        if (appTitle
            .toLowerCase()
            .contains(_getLocalizedAppName(app).toLowerCase())) {
          return category.name;
        }
      }
    }
    return "Uncategorized";
  }

  String _categorizeAppEnglishOnly(String appTitle) {
    for (var category in AppCategories.categories) {
      if (category.apps
          .any((app) => appTitle.toLowerCase().contains(app.toLowerCase()))) {
        return category.name;
      }
    }
    return "Uncategorized";
  }

  String _getLocalizedAppName(String appName) {
    if (_localizations == null) return appName;
    try {
      switch (appName) {
        case "Microsoft Word":
          return _localizations!.appMicrosoftWord;
        case "Excel":
          return _localizations!.appExcel;
        case "PowerPoint":
          return _localizations!.appPowerPoint;
        case "Google Docs":
          return _localizations!.appGoogleDocs;
        case "Notion":
          return _localizations!.appNotion;
        case "Evernote":
          return _localizations!.appEvernote;
        case "Trello":
          return _localizations!.appTrello;
        case "Asana":
          return _localizations!.appAsana;
        case "Slack":
          return _localizations!.appSlack;
        case "Microsoft Teams":
          return _localizations!.appMicrosoftTeams;
        case "Zoom":
          return _localizations!.appZoom;
        case "Google Calendar":
          return _localizations!.appGoogleCalendar;
        case "Apple Calendar":
          return _localizations!.appAppleCalendar;
        case "Visual Studio Code":
          return _localizations!.appVisualStudioCode;
        case "Terminal":
          return _localizations!.appTerminal;
        case "Command Prompt":
          return _localizations!.appCommandPrompt;
        case "Chrome":
          return _localizations!.appChrome;
        case "Firefox":
          return _localizations!.appFirefox;
        case "Safari":
          return _localizations!.appSafari;
        case "Edge":
          return _localizations!.appEdge;
        case "Opera":
          return _localizations!.appOpera;
        case "Brave":
          return _localizations!.appBrave;
        case "Netflix":
          return _localizations!.appNetflix;
        case "YouTube":
          return _localizations!.appYouTube;
        case "Spotify":
          return _localizations!.appSpotify;
        case "Apple Music":
          return _localizations!.appAppleMusic;
        case "Calculator":
          return _localizations!.appCalculator;
        case "Notes":
          return _localizations!.appNotes;
        case "System Preferences":
          return _localizations!.appSystemPreferences;
        case "Task Manager":
          return _localizations!.appTaskManager;
        case "File Explorer":
          return _localizations!.appFileExplorer;
        case "Dropbox":
          return _localizations!.appDropbox;
        case "Google Drive":
          return _localizations!.appGoogleDrive;
        default:
          return appName;
      }
    } catch (e) {
      return appName;
    }
  }

  // ============================================================
  // SETTINGS
  // ============================================================
  Future<void> updateIdleDetection(bool enabled) async {
    SettingsManager().updateSetting("tracking.idleDetection", enabled);
    if (!enabled) _isUserActive = true;
  }

  Future<void> updateIdleTimeout(int seconds) async {
    SettingsManager().updateSetting("tracking.idleTimeout", seconds);
    await _windowFocusPlugin?.setIdleThreshold(
        duration: Duration(seconds: seconds));
  }

  Future<void> updateAudioMonitoring(bool enabled) async {
    SettingsManager().updateSetting("tracking.monitorAudio", enabled);
    await _windowFocusPlugin?.setAudioMonitoring(enabled);
  }

  Future<void> updateControllerMonitoring(bool enabled) async {
    SettingsManager().updateSetting("tracking.monitorControllers", enabled);
    await _windowFocusPlugin?.setControllerMonitoring(enabled);
  }

  Future<void> updateHIDMonitoring(bool enabled) async {
    SettingsManager().updateSetting("tracking.monitorHIDDevices", enabled);
    await _windowFocusPlugin?.setHIDMonitoring(enabled);
  }

  Future<void> updateKeyboardMonitoring(bool enabled) async {
    SettingsManager().updateSetting("tracking.monitorKeyboard", enabled);
    await _windowFocusPlugin?.setKeyboardMonitoring(enabled);
  }

  Future<void> updateAudioThreshold(double threshold) async {
    SettingsManager().updateSetting("tracking.audioThreshold", threshold);
    await _windowFocusPlugin?.setAudioThreshold(threshold);
  }

  // ============================================================
  // PERMISSIONS
  // ============================================================
  Future<bool> checkInputMonitoringPermission() async {
    if (_windowFocusPlugin == null) return true;
    try {
      return await _windowFocusPlugin!.checkInputMonitoringPermission();
    } catch (e) {
      return false;
    }
  }

  Future<void> openInputMonitoringSettings() async {
    await _windowFocusPlugin?.openInputMonitoringSettings();
  }

  Future<PermissionStatus> checkAllPermissions() async {
    if (_windowFocusPlugin == null) {
      return PermissionStatus(screenRecording: true, inputMonitoring: true);
    }
    try {
      return await _windowFocusPlugin!.checkAllPermissions();
    } catch (e) {
      return PermissionStatus(screenRecording: false, inputMonitoring: false);
    }
  }

  // ============================================================
  // STOP & DISPOSE
  // ============================================================
  Future<void> stopTracking() async {
    debugPrint('🛑 Stopping tracking');
    _isTracking = false;

    DesktopScreenState.instance.isActive.removeListener(_onScreenStateChanged);

    if (_trackingMode == TrackingMode.precise) _saveCurrentAppTime();
    await _stopCurrentMode();
    await _appDataStore?.forceCommitToHive();

    _windowFocusPlugin?.dispose();
    _windowFocusPlugin = null;
    _isUserActive = true;
  }

  void dispose() {
    stopTracking();
    _appUpdateController.close();
    _appDataStore = null;
  }

  // ============================================================
  // DEBUG
  // ============================================================
  Map<String, dynamic> getTrackingInfo() {
    return {
      'trackingMode': _trackingMode.name,
      'isTracking': _isTracking,
      'currentApp': _currentApp,
      'isUserActive': _isUserActive,
      'screenState': {
        'systemAsleep': _systemAsleep,
        'screenOff': _screenOff,
        'locked': _locked,
        'allowsTracking': _screenStateAllowsTracking,
      },
      'currentAppElapsed':
          DateTime.now().difference(_currentAppStartTime).inSeconds,
      'metadataCacheSize': _metadataCache.length,
      if (_appDataStore != null)
        'runtimeCache': _appDataStore!.getRuntimeCacheStats(),
    };
  }

  Map<String, AppMetadata> getMetadataCache() =>
      Map.unmodifiable(_metadataCache);

  String getStatusSummary() {
    return '''
═══════════════════════════════════════════════════════
📊 TRACKER STATUS
   Mode: ${_trackingMode.name} | Tracking: $_isTracking | User Active: $_isUserActive
   Current App: $_currentApp
   Screen: asleep=$_systemAsleep off=$_screenOff locked=$_locked → allows=${_screenStateAllowsTracking}
═══════════════════════════════════════════════════════''';
  }
}
