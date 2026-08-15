// ─── Extension Settings (Web Only) ───────────────────────────────────────────
//
// Stores and retrieves:
//  - Extension mode (standalone / trackerOnly / hybrid)
//  - Per-domain metadata (category, isTracking, isProductive, dailyLimitSeconds)
//
// Data lives in chrome.storage.local under 'scolect_settings'.

import 'chrome_storage_interop.dart';

// ─── Enums / Models ───────────────────────────────────────────────────────────

enum ExtensionMode { standalone, trackerOnly, hybrid }

extension ExtensionModeExt on ExtensionMode {
  String get key => switch (this) {
        ExtensionMode.standalone => 'standalone',
        ExtensionMode.trackerOnly => 'trackerOnly',
        ExtensionMode.hybrid => 'hybrid',
      };

  String get label => switch (this) {
        ExtensionMode.standalone => 'Standalone',
        ExtensionMode.trackerOnly => 'Tracker Only',
        ExtensionMode.hybrid => 'Hybrid',
      };

  String get description => switch (this) {
        ExtensionMode.standalone =>
          'Full dashboard. Data stored locally in the browser.',
        ExtensionMode.trackerOnly =>
          'Tracks sites and syncs to the Scolect desktop app. No local dashboard.',
        ExtensionMode.hybrid =>
          'Full dashboard + syncs to the Scolect desktop app.',
      };

  static ExtensionMode fromKey(String key) => switch (key) {
        'trackerOnly' => ExtensionMode.trackerOnly,
        'hybrid'      => ExtensionMode.hybrid,
        _             => ExtensionMode.standalone,
      };
}

class WebsiteMetadata {
  final String category;
  final bool isTracking;
  final bool isProductive;
  final int dailyLimitSeconds; // 0 = no limit
  final String siteName;

  const WebsiteMetadata({
    this.category = 'Uncategorized',
    this.isTracking = true,
    this.isProductive = false,
    this.dailyLimitSeconds = 0,
    this.siteName = '',
  });

  Duration get dailyLimit => Duration(seconds: dailyLimitSeconds);

  WebsiteMetadata copyWith({
    String? category,
    bool? isTracking,
    bool? isProductive,
    int? dailyLimitSeconds,
    String? siteName,
  }) =>
      WebsiteMetadata(
        category: category ?? this.category,
        isTracking: isTracking ?? this.isTracking,
        isProductive: isProductive ?? this.isProductive,
        dailyLimitSeconds: dailyLimitSeconds ?? this.dailyLimitSeconds,
        siteName: siteName ?? this.siteName,
      );

  factory WebsiteMetadata.fromMap(Map<String, dynamic> m) => WebsiteMetadata(
        category: m['category'] as String? ?? 'Uncategorized',
        isTracking: m['isTracking'] as bool? ?? true,
        isProductive: m['isProductive'] as bool? ?? false,
        dailyLimitSeconds: m['dailyLimitSeconds'] as int? ?? 0,
        siteName: m['siteName'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'category': category,
        'isTracking': isTracking,
        'isProductive': isProductive,
        'dailyLimitSeconds': dailyLimitSeconds,
        if (siteName.isNotEmpty) 'siteName': siteName,
      };
}

// ─── Settings singleton ───────────────────────────────────────────────────────

const _kSettingsKey = 'scolect_settings';

class ExtensionSettings {
  ExtensionSettings._();
  static final ExtensionSettings _instance = ExtensionSettings._();
  factory ExtensionSettings() => _instance;

  ExtensionMode _mode = ExtensionMode.standalone;
  String _desktopUrl = 'http://localhost:46000';
  final Map<String, WebsiteMetadata> _metadata = {};
  bool _loaded = false;
  int _overallLimitSeconds = 0;
  bool _overallLimitEnabled = false;
  bool _idleDetection = true;
  int _idleTimeoutSeconds = 60;
  bool _pauseOnWindowBlur = false;
  bool _pauseOnTabUnfocus = false;
  bool _ignoreIdleOnMedia = true;
  bool _ignoreWindowBlurOnMedia = true;

  ExtensionMode get mode => _mode;
  String get desktopUrl => _desktopUrl;
  int get overallLimitSeconds => _overallLimitSeconds;
  bool get overallLimitEnabled => _overallLimitEnabled;
  bool get idleDetection => _idleDetection;
  int get idleTimeoutSeconds => _idleTimeoutSeconds;
  bool get pauseOnWindowBlur => _pauseOnWindowBlur;
  bool get pauseOnTabUnfocus => _pauseOnTabUnfocus;
  bool get ignoreIdleOnMedia => _ignoreIdleOnMedia;
  bool get ignoreWindowBlurOnMedia => _ignoreWindowBlurOnMedia;

  // ── Load ────────────────────────────────────────────────────────────────────

  Future<void> load() async {
    final all = await chromeStorageGet([_kSettingsKey]);
    final raw = all[_kSettingsKey] as Map<String, dynamic>? ?? {};
    _mode = ExtensionModeExt.fromKey(raw['mode'] as String? ?? 'standalone');
    _desktopUrl = raw['desktopUrl'] as String? ?? 'http://localhost:46000';
    _overallLimitSeconds = raw['overallLimitSeconds'] as int? ?? 0;
    _overallLimitEnabled = raw['overallLimitEnabled'] as bool? ?? false;
    _idleDetection = raw['idleDetection'] as bool? ?? true;
    _idleTimeoutSeconds = raw['idleTimeoutSeconds'] as int? ?? 60;
    _pauseOnWindowBlur = raw['pauseOnWindowBlur'] as bool? ?? false;
    _pauseOnTabUnfocus = raw['pauseOnTabUnfocus'] as bool? ?? false;
    _ignoreIdleOnMedia = raw['ignoreIdleOnMedia'] as bool? ?? true;
    _ignoreWindowBlurOnMedia = raw['ignoreWindowBlurOnMedia'] as bool? ?? true;

    final metaRaw = raw['metadata'] as Map<String, dynamic>? ?? {};
    _metadata.clear();
    metaRaw.forEach((domain, v) {
      if (v is Map<String, dynamic>) {
        _metadata[domain] = WebsiteMetadata.fromMap(v);
      }
    });
    _loaded = true;
  }

  Future<void> _ensureLoaded() async {
    if (!_loaded) await load();
  }

  // ── Getters ─────────────────────────────────────────────────────────────────

  Future<ExtensionMode> getMode() async {
    await _ensureLoaded();
    return _mode;
  }

  Future<WebsiteMetadata> getMetadata(String domain) async {
    await _ensureLoaded();
    return _metadata[domain] ?? const WebsiteMetadata();
  }

  Future<Map<String, WebsiteMetadata>> getAllMetadata() async {
    await _ensureLoaded();
    return Map.unmodifiable(_metadata);
  }

  // ── Setters ─────────────────────────────────────────────────────────────────

  Future<void> setMode(ExtensionMode mode) async {
    await _ensureLoaded();
    _mode = mode;
    await _persist();
  }

  Future<void> setDesktopUrl(String url) async {
    await _ensureLoaded();
    _desktopUrl = url;
    await _persist();
  }

  Future<void> setOverallLimit({required int seconds, required bool enabled}) async {
    await _ensureLoaded();
    _overallLimitSeconds = seconds;
    _overallLimitEnabled = enabled;
    await _persist();
  }

  Future<void> setIdleDetection({required bool enabled, required int timeoutSeconds}) async {
    await _ensureLoaded();
    _idleDetection = enabled;
    _idleTimeoutSeconds = timeoutSeconds;
    await _persist();
  }

  Future<void> setFocusDetectionOptions({
    bool? pauseOnWindowBlur,
    bool? pauseOnTabUnfocus,
    bool? ignoreIdleOnMedia,
    bool? ignoreWindowBlurOnMedia,
  }) async {
    await _ensureLoaded();
    if (pauseOnWindowBlur != null) _pauseOnWindowBlur = pauseOnWindowBlur;
    if (pauseOnTabUnfocus != null) _pauseOnTabUnfocus = pauseOnTabUnfocus;
    if (ignoreIdleOnMedia != null) _ignoreIdleOnMedia = ignoreIdleOnMedia;
    if (ignoreWindowBlurOnMedia != null) _ignoreWindowBlurOnMedia = ignoreWindowBlurOnMedia;
    await _persist();
  }

  Future<void> updateMetadata(
    String domain, {
    String? category,
    bool? isTracking,
    bool? isProductive,
    Duration? dailyLimit,
    String? siteName,
  }) async {
    await _ensureLoaded();
    final current = _metadata[domain] ?? const WebsiteMetadata();
    final newSiteName = siteName ?? current.siteName;
    if (newSiteName.isNotEmpty && newSiteName != domain && _metadata.containsKey(newSiteName)) {
      _metadata.remove(newSiteName);
    }
    _metadata[domain] = current.copyWith(
      category: category,
      isTracking: isTracking,
      isProductive: isProductive,
      dailyLimitSeconds: dailyLimit?.inSeconds,
      siteName: siteName,
    );
    await _persist();
  }

  Future<void> clearAllData() async {
    final all = await chromeStorageGetAll();
    // Remove all daily usage keys and any cached state that references them.
    // Also clear the active tracking session so the SW doesn't re-write the
    // just-deleted data on its next tick.
    final toRemove = all.keys.where((k) =>
      k.startsWith('scolect_day_') ||
      k == 'scolect_active' ||
      k == 'scolect_app_metadata' ||
      k == 'scolect_focus_sessions' ||
      k == 'scolect_local_focus' ||
      k == 'scolect_blocked_domains' ||
      k == 'scolect_unblocked_today'
    ).toList();
    for (final key in toRemove) {
      await chromeStorageRemove(key);
    }
    // Clear per-domain metadata from scolect_settings and the in-memory cache.
    _metadata.clear();
    _overallLimitSeconds = 0;
    _overallLimitEnabled = false;
    _idleDetection = true;
    _idleTimeoutSeconds = 60;
    _pauseOnWindowBlur = false;
    _pauseOnTabUnfocus = false;
    _ignoreIdleOnMedia = true;
    _ignoreWindowBlurOnMedia = true;
    _loaded = false;
    await chromeStorageSet({
      _kSettingsKey: {
        'mode': _mode.key,
        'desktopUrl': _desktopUrl,
        'overallLimitSeconds': 0,
        'overallLimitEnabled': false,
        'idleDetection': true,
        'idleTimeoutSeconds': 60,
        'pauseOnWindowBlur': false,
        'pauseOnTabUnfocus': false,
        'ignoreIdleOnMedia': true,
        'ignoreWindowBlurOnMedia': true,
        'metadata': <String, dynamic>{},
      },
    });
    // Reset the app_state domains list so the popup and provider show empty immediately.
    final stateRaw = all['scolect_app_state'] as Map<String, dynamic>? ?? {};
    await chromeStorageSet({
      'scolect_app_state': {
        ...stateRaw,
        'todayDomains': <dynamic>[],
        'activeDomain': null,
        'totalSeconds': 0,
        'focusActive': false,
        'sessionLabel': null,
        'endTimeEpochMs': null,
      },
    });
    // If syncing to desktop, tell the background to clear web data there too.
    if (_mode == ExtensionMode.hybrid || _mode == ExtensionMode.trackerOnly) {
      triggerExtensionSync(); // reuses the existing sendMessage channel
      // Ask background to POST /clear-web-data to the desktop.
      await chromeStorageSet({'scolect_clear_web_data': true});
    }
  }

  // ── Persist ─────────────────────────────────────────────────────────────────

  Future<void> _persist() async {
    await chromeStorageSet({
      _kSettingsKey: {
        'mode': _mode.key,
        'desktopUrl': _desktopUrl,
        'overallLimitSeconds': _overallLimitSeconds,
        'overallLimitEnabled': _overallLimitEnabled,
        'idleDetection': _idleDetection,
        'idleTimeoutSeconds': _idleTimeoutSeconds,
        'pauseOnWindowBlur': _pauseOnWindowBlur,
        'pauseOnTabUnfocus': _pauseOnTabUnfocus,
        'ignoreIdleOnMedia': _ignoreIdleOnMedia,
        'ignoreWindowBlurOnMedia': _ignoreWindowBlurOnMedia,
        'metadata': {
          for (final e in _metadata.entries) e.key: e.value.toMap(),
        },
      },
    });
    // Notify background of mode change
    _notifyBackground();
  }

  void _notifyBackground() {
    try {
      // Fire-and-forget message to background worker
      // Uses a JS eval since we can't import chrome.runtime here without interop
      chromeStorageGet([]); // no-op to ensure available, actual notify via background alarm
    } catch (_) {}
  }
}
