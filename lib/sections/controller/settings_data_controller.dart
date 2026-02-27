import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

// Theme constants
class ThemeOptions {
  static const String system = "System";
  static const String dark = "Dark";
  static const String light = "Light";
  static const List<String> available = [system, dark, light];
  static const String defaultTheme = system;
}

// Language constants
class LanguageOptions {
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
}

class VoiceGenderOptions {
  static const String male = "male";
  static const String female = "female";
  static const List<Map<String, String>> available = [
    {'value': male, 'labelKey': 'voiceGenderMale'},
    {'value': female, 'labelKey': 'voiceGenderFemale'},
  ];
  static const String defaultGender = female;
}

// Focus mode constants
class FocusModeOptions {
  static const String custom = "Custom";
  static const List<String> available = [custom];
  static const String defaultMode = custom;
}

// App category constants
class CategoryOptions {
  static const String all = "All";
  static const List<String> available = [all];
  static const String defaultCategory = all;
}

// Idle timeout preset options
class IdleTimeoutOptions {
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
}

// Tracking mode options
class TrackingModeOptions {
  static const String polling = "polling";
  static const String precise = "precise";
  static const List<String> available = [polling, precise];
  static const String defaultMode = precise;
}

// ============================================================================
// MIGRATIONS
// ============================================================================

class SettingsMigrations {
  /// Bump this number each time you add a new migration block.
  static const int currentVersion = 1;
  static const String versionKey = "screenTime_settings_migration_version";

  /// The version at which monitorControllers, monitorHIDDevices, and
  /// monitorAudio were disabled due to crashing. Any user whose
  /// last_shown_changelog_version is strictly below this will be migrated.
  static const String crashFixVersion = "2.0.8";
}

// ============================================================================
// SETTINGS MANAGER
// ============================================================================

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();

  factory SettingsManager() {
    return _instance;
  }

  SettingsManager._internal();

  late SharedPreferences _prefs;

  bool get _isMacOS => Platform.isMacOS;

  Map<String, dynamic> get _defaultNotificationSettings => {
        "enabled": !_isMacOS,
        "focusMode": !_isMacOS,
        "screenTime": !_isMacOS,
        "appScreenTime": !_isMacOS,
      };

  Map<String, dynamic> get _defaultLimitsAlertsSettings => {
        "popup": true,
        "frequent": true,
        "sound": !_isMacOS,
        "system": !_isMacOS,
        "overallLimit": {"enabled": false, "hours": 2, "minutes": 0}
      };

  Map<String, dynamic> get _defaultSettings => {
        "theme": {
          "selected": ThemeOptions.defaultTheme,
        },
        "language": {
          "selected": LanguageOptions.defaultLanguage,
        },
        "launchAtStartup": true,
        "launchAsMinimized": false,
        "notifications": _defaultNotificationSettings,
        "limitsAlerts": _defaultLimitsAlertsSettings,
        "applications": {
          "tracking": true,
          "isHidden": false,
          "selectedCategory": CategoryOptions.defaultCategory
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
        "notificationController": {
          "reminderFrequency": 5,
        },
        "tracking": {
          "mode": TrackingModeOptions.defaultMode,
          "idleDetection": true,
          "idleTimeout": IdleTimeoutOptions.defaultTimeout,
          "monitorAudio": false,
          "monitorControllers": false,
          "monitorHIDDevices": false,
          "monitorKeyboard": true,
          "audioThreshold": 0.01,
        }
      };

  late Map<String, dynamic> settings;

  Map<String, String> versionInfo = {
    "version": "2.0.8",
    "type": "Stable Build"
  };

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    settings = Map<String, dynamic>.from(_defaultSettings);
    _loadSettings();
    await _runMigrations();

    if (_isMacOS) {
      debugPrint(
          "🍎 Running on macOS - notifications disabled by default (requires permission)");
    }
  }

  // --------------------------------------------------------------------------
  // MIGRATIONS
  // --------------------------------------------------------------------------

  Future<void> _runMigrations() async {
    final bool hasExistingSettings =
        _prefs.getString("screenTime_settings") != null;

    // New user: no saved settings → defaults are already correct (all false),
    // just stamp the current migration version and return.
    if (!hasExistingSettings) {
      await _prefs.setInt(
          SettingsMigrations.versionKey, SettingsMigrations.currentVersion);
      debugPrint(
          "🆕 New user — stamped migration version ${SettingsMigrations.currentVersion}");
      return;
    }

    int migratedVersion = _prefs.getInt(SettingsMigrations.versionKey) ?? 0;

    // ------------------------------------------------------------------
    // Migration 1 — disable monitorControllers, monitorHIDDevices, and
    // monitorAudio for existing users who were on a version below 2.0.8,
    // as these settings caused app crashes.
    // ------------------------------------------------------------------
    if (migratedVersion < 1) {
      const String changelogKey = 'last_shown_changelog_version';
      final String? lastSeenVersion = _prefs.getString(changelogKey);

      final bool isOldUser = lastSeenVersion != null &&
          _isVersionBelow(lastSeenVersion, SettingsMigrations.crashFixVersion);

      if (isOldUser) {
        debugPrint("🔧 Migration 1: Old user on $lastSeenVersion — disabling "
            "monitorControllers, monitorHIDDevices & monitorAudio");

        if (settings.containsKey("tracking")) {
          settings["tracking"]["monitorControllers"] = false;
          settings["tracking"]["monitorHIDDevices"] = false;
          settings["tracking"]["monitorAudio"] = false;
        }

        _saveSettings();
        debugPrint("✅ Migration 1: Crash-prone settings disabled and saved");
      } else {
        debugPrint(
            "ℹ️ Migration 1: Skipped — no old changelog version found or "
            "already on ${SettingsMigrations.crashFixVersion}+");
      }

      await _prefs.setInt(SettingsMigrations.versionKey, 1);
    }

    // Add future migrations here:
    // if (migratedVersion < 2) { ... await _prefs.setInt(..., 2); }
  }

  /// Returns true if [version] is strictly below [target].
  /// Handles optional leading "v" (e.g. "v2.0.7" < "2.0.8").
  bool _isVersionBelow(String version, String target) {
    try {
      final v = version.replaceAll('v', '').split('.').map(int.parse).toList();
      final t = target.replaceAll('v', '').split('.').map(int.parse).toList();

      for (int i = 0; i < max(v.length, t.length); i++) {
        final vPart = i < v.length ? v[i] : 0;
        final tPart = i < t.length ? t[i] : 0;
        if (vPart < tPart) return true;
        if (vPart > tPart) return false;
      }
      return false; // equal versions are not below
    } catch (_) {
      return false; // unparseable → safe default, don't force-disable
    }
  }

  // --------------------------------------------------------------------------
  // LOAD / SAVE
  // --------------------------------------------------------------------------

  void _loadSettings() {
    String? storedSettings = _prefs.getString("screenTime_settings");
    if (storedSettings != null) {
      Map<String, dynamic> loadedSettings = jsonDecode(storedSettings);
      _mergeSettings(settings, loadedSettings);

      // Validate theme
      if (!ThemeOptions.available.contains(settings["theme"]["selected"])) {
        settings["theme"]["selected"] = ThemeOptions.defaultTheme;
      }

      // Validate language
      String currentLang = settings["language"]["selected"];
      bool isValidLang =
          LanguageOptions.available.any((lang) => lang['code'] == currentLang);
      if (!isValidLang) {
        settings["language"]["selected"] = LanguageOptions.defaultLanguage;
      }

      // Validate focus mode
      if (settings.containsKey("focusModeSettings") &&
          settings["focusModeSettings"].containsKey("selectedMode") &&
          !FocusModeOptions.available
              .contains(settings["focusModeSettings"]["selectedMode"])) {
        settings["focusModeSettings"]["selectedMode"] =
            FocusModeOptions.defaultMode;
      }

      // Validate category
      if (settings.containsKey("applications") &&
          settings["applications"].containsKey("selectedCategory") &&
          !CategoryOptions.available
              .contains(settings["applications"]["selectedCategory"])) {
        settings["applications"]["selectedCategory"] =
            CategoryOptions.defaultCategory;
      }

      // Validate tracking settings
      if (settings.containsKey("tracking")) {
        // Validate tracking mode
        String trackingMode =
            settings["tracking"]["mode"] ?? TrackingModeOptions.defaultMode;
        if (!TrackingModeOptions.available.contains(trackingMode)) {
          settings["tracking"]["mode"] = TrackingModeOptions.defaultMode;
        }

        // Validate idleTimeout
        int idleTimeout = settings["tracking"]["idleTimeout"] ??
            IdleTimeoutOptions.defaultTimeout;
        if (idleTimeout < IdleTimeoutOptions.minTimeout) {
          idleTimeout = IdleTimeoutOptions.minTimeout;
        }
        if (idleTimeout > IdleTimeoutOptions.maxTimeout) {
          idleTimeout = IdleTimeoutOptions.maxTimeout;
        }
        settings["tracking"]["idleTimeout"] = idleTimeout;

        // Validate audioThreshold
        double audioThreshold = settings["tracking"]["audioThreshold"] ?? 0.001;
        if (audioThreshold < 0.0001) audioThreshold = 0.0001;
        if (audioThreshold > 0.1) audioThreshold = 0.1;
        settings["tracking"]["audioThreshold"] = audioThreshold;

        // Ensure monitorKeyboard exists with platform-specific default
        if (!settings["tracking"].containsKey("monitorKeyboard")) {
          settings["tracking"]["monitorKeyboard"] = !Platform.isMacOS;
        }
      }
    }
  }

  void _mergeSettings(
      Map<String, dynamic> target, Map<String, dynamic> source) {
    source.forEach((key, value) {
      if (value is Map<String, dynamic> &&
          target.containsKey(key) &&
          target[key] is Map) {
        _mergeSettings(target[key], value);
      } else {
        target[key] = value;
      }
    });
  }

  void _saveSettings() {
    _prefs.setString("screenTime_settings", jsonEncode(settings));
  }

  // --------------------------------------------------------------------------
  // PUBLIC API
  // --------------------------------------------------------------------------

  void updateSetting(String key, dynamic value, [BuildContext? context]) async {
    List<String> keys = key.split(".");

    if (keys.length == 1) {
      if (settings.containsKey(keys[0])) {
        settings[keys[0]] = value;
      } else {
        debugPrint("❌ ERROR: Invalid setting: ${keys[0]}");
      }
    } else {
      Map<String, dynamic> current = settings;

      for (int i = 0; i < keys.length - 1; i++) {
        if (!current.containsKey(keys[i])) {
          current[keys[i]] = <String, dynamic>{};
          debugPrint("Creating missing nested setting: ${keys[i]}");
        } else if (current[keys[i]] is! Map) {
          current[keys[i]] = <String, dynamic>{};
          debugPrint("Converting to map: ${keys[i]}");
        }
        current = current[keys[i]];
      }

      current[keys.last] = value;
    }

    _saveSettings();

    if (keys.isNotEmpty) {
      if (keys[0] == "notificationController") {
        debugPrint("🔔 Updated notification setting: $key = $value");
      } else if (keys[0] == "tracking") {
        debugPrint("📊 Updated tracking setting: $key = $value");
      }
    }
  }

  void applyTheme(String themeName, BuildContext context) {
    switch (themeName) {
      case ThemeOptions.dark:
        AdaptiveTheme.of(context).setDark();
        debugPrint("🎨 Theme set to Dark mode");
        break;
      case ThemeOptions.light:
        AdaptiveTheme.of(context).setLight();
        debugPrint("🎨 Theme set to Light mode");
        break;
      case ThemeOptions.system:
      default:
        AdaptiveTheme.of(context).setSystem();
        debugPrint("🎨 Theme set to System default mode");
        break;
    }
  }

  void applyCurrentTheme(BuildContext context) {
    String currentTheme =
        getSetting("theme.selected") ?? ThemeOptions.defaultTheme;
    applyTheme(currentTheme, context);
  }

  dynamic getSetting(String key) {
    List<String> keys = key.split(".");
    dynamic current = settings;

    for (String k in keys) {
      if (current is Map && current.containsKey(k)) {
        current = current[k];
      } else {
        debugPrint("❌ ERROR: Setting not found: $key");
        return null;
      }
    }
    return current;
  }

  Future<void> saveSetting(String key, dynamic value) async {
    await _prefs.setString(key, value.toString());
  }

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

  bool get requiresNotificationPermission => _isMacOS;

  void enableAllNotifications() {
    settings["notifications"] = {
      "enabled": true,
      "focusMode": true,
      "screenTime": true,
      "appScreenTime": true,
    };
    settings["limitsAlerts"]["sound"] = true;
    settings["limitsAlerts"]["system"] = true;
    settings["focusModeSettings"]["enableSoundsNotifications"] = true;
    _saveSettings();
    debugPrint("🔔 All notifications enabled");
  }

  Future<void> resetSettings([BuildContext? context]) async {
    settings = Map<String, dynamic>.from(_defaultSettings);
    _saveSettings();

    debugPrint("✅ Settings reset to default values");
    if (_isMacOS) {
      debugPrint("🍎 macOS detected - notifications reset to disabled");
    }
  }
}
