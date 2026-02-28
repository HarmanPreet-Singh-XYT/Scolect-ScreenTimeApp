import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math' show max;

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

class ThemeOptions {
  const ThemeOptions._();
  static const String system = "System";
  static const String dark = "Dark";
  static const String light = "Light";
  static const List<String> available = [system, dark, light];
  static const String defaultTheme = system;
}

class LanguageOptions {
  const LanguageOptions._();
  static const List<Map<String, String>> available = [
    {'code': 'en', 'name': 'English'},
    {'code': 'zh', 'name': '中文 (Chinese)'},
    {'code': 'hi', 'name': 'हिन्दी (Hindi)'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'ar', 'name': 'العربية (Arabic)'},
    {'code': 'bn', 'name': 'বাংলা (Bengali)'},
    {'code': 'pt', 'name': 'Português'},
    {'code': 'ru', 'name': 'Русский (Russian)'},
    {'code': 'ur', 'name': 'اردو (Urdu)'},
    {'code': 'id', 'name': 'Bahasa Indonesia'},
    {'code': 'ja', 'name': '日本語 (Japanese)'},
  ];
  static const String defaultLanguage = "en";

  // Pre-computed set for O(1) lookup
  static final Set<String> _validCodes =
      available.map((l) => l['code']!).toSet();

  static bool isValidCode(String code) => _validCodes.contains(code);
}

class VoiceGenderOptions {
  const VoiceGenderOptions._();
  static const String male = "male";
  static const String female = "female";
  static const List<Map<String, String>> available = [
    {'value': male, 'labelKey': 'voiceGenderMale'},
    {'value': female, 'labelKey': 'voiceGenderFemale'},
  ];
  static const String defaultGender = female;
}

class FocusModeOptions {
  const FocusModeOptions._();
  static const String custom = "Custom";
  static const List<String> available = [custom];
  static const String defaultMode = custom;
}

class CategoryOptions {
  const CategoryOptions._();
  static const String all = "All";
  static const List<String> available = [all];
  static const String defaultCategory = all;
}

class IdleTimeoutOptions {
  const IdleTimeoutOptions._();
  static const List<Map<String, dynamic>> presets = [
    {'value': 30},
    {'value': 60},
    {'value': 120},
    {'value': 300},
    {'value': 600},
    {'value': -1},
  ];
  static const int defaultTimeout = 600;
  static const int minTimeout = 10;
  static const int maxTimeout = 3600;

  static int clamp(int value) => value.clamp(minTimeout, maxTimeout);
}

class TrackingModeOptions {
  const TrackingModeOptions._();
  static const String polling = "polling";
  static const String precise = "precise";
  static const List<String> available = [polling, precise];
  static const String defaultMode = precise;
}

// ============================================================================
// MIGRATIONS
// ============================================================================

class SettingsMigrations {
  const SettingsMigrations._();
  static const int currentVersion = 1;
  static const String versionKey = "screenTime_settings_migration_version";
  static const String crashFixVersion = "2.0.8";
}

// ============================================================================
// SETTINGS MANAGER
// ============================================================================

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  static const String _storageKey = "screenTime_settings";
  static const String _changelogKey = 'last_shown_changelog_version';

  late SharedPreferences _prefs;
  late Map<String, dynamic> settings;

  static final bool _isMacOS = Platform.isMacOS;

  Map<String, String> versionInfo = {
    "version": "2.0.8",
    "type": "Stable Build",
  };

  // --------------------------------------------------------------------------
  // DEFAULT SETTINGS (built lazily once)
  // --------------------------------------------------------------------------

  Map<String, dynamic> _buildDefaultSettings() => {
        "theme": {"selected": ThemeOptions.defaultTheme},
        "language": {"selected": LanguageOptions.defaultLanguage},
        "launchAtStartup": true,
        "launchAsMinimized": false,
        "notifications": {
          "enabled": !_isMacOS,
          "focusMode": !_isMacOS,
          "screenTime": !_isMacOS,
          "appScreenTime": !_isMacOS,
        },
        "limitsAlerts": {
          "popup": true,
          "frequent": true,
          "sound": !_isMacOS,
          "system": !_isMacOS,
          "overallLimit": {"enabled": false, "hours": 2, "minutes": 0},
        },
        "applications": {
          "tracking": true,
          "isHidden": false,
          "selectedCategory": CategoryOptions.defaultCategory,
        },
        "focusModeSettings": {
          "selectedMode": FocusModeOptions.defaultMode,
          "workDuration": 25.0,
          "shortBreak": 5.0,
          "longBreak": 15.0,
          "autoStart": false,
          "blockDistractions": false,
          "enableSoundsNotifications": true,
          "voiceGender": VoiceGenderOptions.defaultGender,
          "notificationBannerDismissed": false,
        },
        "notificationController": {"reminderFrequency": 5},
        "tracking": {
          "mode": TrackingModeOptions.defaultMode,
          "idleDetection": true,
          "idleTimeout": IdleTimeoutOptions.defaultTimeout,
          "monitorAudio": false,
          "monitorControllers": false,
          "monitorHIDDevices": false,
          "monitorKeyboard": true,
          "audioThreshold": 0.01,
        },
      };

  // --------------------------------------------------------------------------
  // INITIALIZATION
  // --------------------------------------------------------------------------

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    settings = _buildDefaultSettings();
    _loadSettings();
    await _runMigrations();

    if (_isMacOS) {
      debugPrint(
          "🍎 Running on macOS — notifications disabled by default (requires permission)");
    }
  }

  // --------------------------------------------------------------------------
  // MIGRATIONS
  // --------------------------------------------------------------------------

  Future<void> _runMigrations() async {
    final bool hasExistingSettings = _prefs.getString(_storageKey) != null;

    if (!hasExistingSettings) {
      await _prefs.setInt(
          SettingsMigrations.versionKey, SettingsMigrations.currentVersion);
      debugPrint(
          "🆕 New user — stamped migration version ${SettingsMigrations.currentVersion}");
      return;
    }

    int migratedVersion = _prefs.getInt(SettingsMigrations.versionKey) ?? 0;

    if (migratedVersion < 1) {
      await _migrateCrashProneSettings();
      await _prefs.setInt(SettingsMigrations.versionKey, 1);
    }

    // Future: if (migratedVersion < 2) { ... }
  }

  Future<void> _migrateCrashProneSettings() async {
    final String? lastSeenVersion = _prefs.getString(_changelogKey);
    final bool isOldUser = lastSeenVersion != null &&
        _isVersionBelow(lastSeenVersion, SettingsMigrations.crashFixVersion);

    if (!isOldUser) {
      debugPrint(
          "ℹ️ Migration 1: Skipped — already on ${SettingsMigrations.crashFixVersion}+");
      return;
    }

    debugPrint("🔧 Migration 1: Old user on $lastSeenVersion — disabling "
        "monitorControllers, monitorHIDDevices & monitorAudio");

    final tracking = settings["tracking"];
    if (tracking is Map<String, dynamic>) {
      tracking
        ..["monitorControllers"] = false
        ..["monitorHIDDevices"] = false
        ..["monitorAudio"] = false;
    }

    _saveSettings();
    debugPrint("✅ Migration 1: Crash-prone settings disabled and saved");
  }

  /// Returns `true` if [version] is strictly below [target].
  static bool _isVersionBelow(String version, String target) {
    try {
      final v = version.replaceAll('v', '').split('.').map(int.parse).toList();
      final t = target.replaceAll('v', '').split('.').map(int.parse).toList();
      final len = max(v.length, t.length);

      for (int i = 0; i < len; i++) {
        final vPart = i < v.length ? v[i] : 0;
        final tPart = i < t.length ? t[i] : 0;
        if (vPart != tPart) return vPart < tPart;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // --------------------------------------------------------------------------
  // LOAD / SAVE / MERGE
  // --------------------------------------------------------------------------

  void _loadSettings() {
    final String? storedSettings = _prefs.getString(_storageKey);
    if (storedSettings == null) return;

    final Map<String, dynamic> loaded = jsonDecode(storedSettings);
    _mergeSettings(settings, loaded);
    _validateSettings();
  }

  void _validateSettings() {
    // Theme
    _validateChoice(
      settings["theme"],
      "selected",
      ThemeOptions.available,
      ThemeOptions.defaultTheme,
    );

    // Language
    final lang = settings["language"]?["selected"];
    if (lang == null || !LanguageOptions.isValidCode(lang)) {
      settings["language"]["selected"] = LanguageOptions.defaultLanguage;
    }

    // Focus mode
    _validateNestedChoice(
      "focusModeSettings",
      "selectedMode",
      FocusModeOptions.available,
      FocusModeOptions.defaultMode,
    );

    // Category
    _validateNestedChoice(
      "applications",
      "selectedCategory",
      CategoryOptions.available,
      CategoryOptions.defaultCategory,
    );

    // Tracking
    final tracking = settings["tracking"];
    if (tracking is Map<String, dynamic>) {
      // Mode
      if (!TrackingModeOptions.available.contains(tracking["mode"] ?? '')) {
        tracking["mode"] = TrackingModeOptions.defaultMode;
      }

      // Idle timeout
      tracking["idleTimeout"] = IdleTimeoutOptions.clamp(
        tracking["idleTimeout"] ?? IdleTimeoutOptions.defaultTimeout,
      );

      // Audio threshold
      final double threshold =
          (tracking["audioThreshold"] as num?)?.toDouble() ?? 0.001;
      tracking["audioThreshold"] = threshold.clamp(0.0001, 0.1);

      // Monitor keyboard default
      tracking["monitorKeyboard"] ??= !_isMacOS;
    }
  }

  void _validateChoice(
    Map<String, dynamic>? map,
    String key,
    List<String> valid,
    String fallback,
  ) {
    if (map == null || !valid.contains(map[key])) {
      map?[key] = fallback;
    }
  }

  void _validateNestedChoice(
    String section,
    String key,
    List<String> valid,
    String fallback,
  ) {
    final map = settings[section];
    if (map is Map<String, dynamic> &&
        map.containsKey(key) &&
        !valid.contains(map[key])) {
      map[key] = fallback;
    }
  }

  void _mergeSettings(
      Map<String, dynamic> target, Map<String, dynamic> source) {
    for (final entry in source.entries) {
      final value = entry.value;
      final existing = target[entry.key];
      if (value is Map<String, dynamic> && existing is Map<String, dynamic>) {
        _mergeSettings(existing, value);
      } else {
        target[entry.key] = value;
      }
    }
  }

  void _saveSettings() {
    _prefs.setString(_storageKey, jsonEncode(settings));
  }

  // --------------------------------------------------------------------------
  // PUBLIC API — Read
  // --------------------------------------------------------------------------

  dynamic getSetting(String key) {
    dynamic current = settings;
    for (final k in key.split(".")) {
      if (current is Map && current.containsKey(k)) {
        current = current[k];
      } else {
        debugPrint("❌ ERROR: Setting not found: $key");
        return null;
      }
    }
    return current;
  }

  bool get requiresNotificationPermission => _isMacOS;

  List<String> getAvailableThemes() => ThemeOptions.available;
  List<Map<String, String>> getAvailableLanguages() =>
      LanguageOptions.available;
  List<String> getAvailableFocusModes() => FocusModeOptions.available;
  List<String> getAvailableCategories() => CategoryOptions.available;
  List<Map<String, dynamic>> getIdleTimeoutPresets() =>
      IdleTimeoutOptions.presets;
  List<Map<String, String>> getAvailableVoiceGenders() =>
      VoiceGenderOptions.available;
  List<String> getAvailableTrackingModes() => TrackingModeOptions.available;

  // --------------------------------------------------------------------------
  // PUBLIC API — Write
  // --------------------------------------------------------------------------

  void updateSetting(String key, dynamic value, [BuildContext? context]) {
    final keys = key.split(".");

    if (keys.length == 1) {
      if (!settings.containsKey(keys[0])) {
        debugPrint("❌ ERROR: Invalid setting: ${keys[0]}");
        return;
      }
      settings[keys[0]] = value;
    } else {
      _setNestedValue(keys, value);
    }

    _saveSettings();
    _logSettingUpdate(keys[0], key, value);
  }

  void _setNestedValue(List<String> keys, dynamic value) {
    Map<String, dynamic> current = settings;
    for (int i = 0; i < keys.length - 1; i++) {
      final k = keys[i];
      final next = current[k];
      if (next is Map<String, dynamic>) {
        current = next;
      } else {
        final newMap = <String, dynamic>{};
        current[k] = newMap;
        current = newMap;
        debugPrint(
            "${next == null ? 'Creating missing' : 'Converting to map'}: $k");
      }
    }
    current[keys.last] = value;
  }

  void _logSettingUpdate(String root, String key, dynamic value) {
    switch (root) {
      case "notificationController":
        debugPrint("🔔 Updated notification setting: $key = $value");
        break;
      case "tracking":
        debugPrint("📊 Updated tracking setting: $key = $value");
        break;
    }
  }

  Future<void> saveSetting(String key, dynamic value) async {
    await _prefs.setString(key, value.toString());
  }

  // --------------------------------------------------------------------------
  // PUBLIC API — Theme
  // --------------------------------------------------------------------------

  void applyTheme(String themeName, BuildContext context) {
    final adaptive = AdaptiveTheme.of(context);
    switch (themeName) {
      case ThemeOptions.dark:
        adaptive.setDark();
        debugPrint("🎨 Theme set to Dark mode");
        break;
      case ThemeOptions.light:
        adaptive.setLight();
        debugPrint("🎨 Theme set to Light mode");
        break;
      default:
        adaptive.setSystem();
        debugPrint("🎨 Theme set to System default mode");
        break;
    }
  }

  void applyCurrentTheme(BuildContext context) {
    final theme = getSetting("theme.selected") ?? ThemeOptions.defaultTheme;
    applyTheme(theme, context);
  }

  // --------------------------------------------------------------------------
  // PUBLIC API — Bulk operations
  // --------------------------------------------------------------------------

  void enableAllNotifications() {
    settings["notifications"] = {
      "enabled": true,
      "focusMode": true,
      "screenTime": true,
      "appScreenTime": true,
    };
    (settings["limitsAlerts"] as Map<String, dynamic>)
      ..["sound"] = true
      ..["system"] = true;
    settings["focusModeSettings"]["enableSoundsNotifications"] = true;
    _saveSettings();
    debugPrint("🔔 All notifications enabled");
  }

  Future<void> resetSettings([BuildContext? context]) async {
    settings = _buildDefaultSettings();
    _saveSettings();
    debugPrint("✅ Settings reset to default values");
    if (_isMacOS) {
      debugPrint("🍎 macOS detected — notifications reset to disabled");
    }
  }
}
