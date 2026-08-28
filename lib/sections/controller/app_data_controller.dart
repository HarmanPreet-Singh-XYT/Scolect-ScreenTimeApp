import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:synchronized/synchronized.dart';
import 'package:screentime/web/chrome_storage_interop.dart' if (dart.library.io) 'package:screentime/web/chrome_storage_interop_stub.dart';
import '../../web/web_browser_data_provider.dart' if (dart.library.io) '../../web/web_browser_data_provider_stub.dart';
import 'settings_data_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/browser_extension_server_stub.dart'
    if (dart.library.io) '../../utils/browser_extension_server.dart';

// TypeAdapters for complex types
@HiveType(typeId: 1)
class AppUsageRecord {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final Duration timeSpent;

  @HiveField(2)
  final int openCount;

  @HiveField(3)
  final List<TimeRange> usagePeriods;

  AppUsageRecord({
    required this.date,
    required this.timeSpent,
    required this.openCount,
    required this.usagePeriods,
  });

  AppUsageRecord merge(AppUsageRecord other) {
    return AppUsageRecord(
      date: date,
      timeSpent: timeSpent + other.timeSpent,
      openCount: openCount + other.openCount,
      usagePeriods: [...usagePeriods, ...other.usagePeriods],
    );
  }

  AppUsageRecord copyWith({
    DateTime? date,
    Duration? timeSpent,
    int? openCount,
    List<TimeRange>? usagePeriods,
  }) {
    return AppUsageRecord(
      date: date ?? this.date,
      timeSpent: timeSpent ?? this.timeSpent,
      openCount: openCount ?? this.openCount,
      usagePeriods: usagePeriods ?? this.usagePeriods,
    );
  }
}

@HiveType(typeId: 2)
class TimeRange {
  @HiveField(0)
  final DateTime startTime;

  @HiveField(1)
  final DateTime endTime;

  TimeRange({
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);
}

@HiveType(typeId: 3)
class FocusSessionRecord {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final Duration duration;

  @HiveField(3)
  final List<String> appsBlocked;

  @HiveField(4)
  final bool completed;

  @HiveField(5)
  final int breakCount;

  @HiveField(6)
  final Duration totalBreakTime;

  FocusSessionRecord({
    required this.date,
    required this.startTime,
    required this.duration,
    required this.appsBlocked,
    required this.completed,
    required this.breakCount,
    required this.totalBreakTime,
  });

  Duration get focusTime => duration - totalBreakTime;
}

@HiveType(typeId: 4)
class AppMetadata {
  @HiveField(0)
  final String category;

  @HiveField(1)
  final bool isProductive;

  @HiveField(2)
  final bool isTracking;

  @HiveField(3)
  final bool isVisible;

  @HiveField(4)
  final Duration dailyLimit;

  @HiveField(5)
  final bool limitStatus;

  @HiveField(6)
  final String siteName; // empty string means "use domain as display name"

  @HiveField(7)
  final bool isPrivate;

  @HiveField(8)
  final String displayName; // empty string means "use the storage key as display name"

  @HiveField(9)
  final int updatedAt; // epoch ms for last-write-wins sync

  AppMetadata({
    required this.category,
    required this.isProductive,
    this.isTracking = true,
    this.isVisible = true,
    this.dailyLimit = Duration.zero,
    this.limitStatus = false,
    this.siteName = '',
    this.isPrivate = false,
    this.displayName = '',
    this.updatedAt = 0,
  });

  AppMetadata copyWith({
    String? category,
    bool? isProductive,
    bool? isTracking,
    bool? isVisible,
    Duration? dailyLimit,
    bool? limitStatus,
    String? siteName,
    bool? isPrivate,
    String? displayName,
    int? updatedAt,
  }) {
    return AppMetadata(
      category: category ?? this.category,
      isProductive: isProductive ?? this.isProductive,
      isTracking: isTracking ?? this.isTracking,
      isVisible: isVisible ?? this.isVisible,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      limitStatus: limitStatus ?? this.limitStatus,
      siteName: siteName ?? this.siteName,
      isPrivate: isPrivate ?? this.isPrivate,
      displayName: displayName ?? this.displayName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: 6)
class BrowserSource {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String detectedBrowser;

  @HiveField(2)
  final DateTime firstSeen;

  @HiveField(3)
  final DateTime lastSeen;

  @HiveField(4)
  final String displayName; // empty string means "use the default label"

  /// Stable ordinal assigned once when this source is first registered
  /// (1, 2, 3, ...), used to build the default "Browser N" label. Kept
  /// separate from displayName so the default label can be localized at
  /// display time instead of being frozen as an English string in storage.
  /// 0 means "unset" (sources created before this field existed) — those
  /// fall back to showing detectedBrowser instead of a numbered label.
  @HiveField(5)
  final int sourceIndex;

  /// Timestamp (epoch ms) when displayName was last modified. Used for
  /// deterministic Last-Write-Wins synchronization between desktop and extension.
  @HiveField(6)
  final int nameUpdatedAt;

  BrowserSource({
    required this.id,
    required this.detectedBrowser,
    required this.firstSeen,
    required this.lastSeen,
    this.displayName = '',
    this.sourceIndex = 0,
    this.nameUpdatedAt = 0,
  });

  /// Plain-English fallback label, for call sites without a BuildContext.
  /// Prefer [localizedLabel] wherever an AppLocalizations instance is
  /// available (anywhere in the widget tree).
  String get label {
    if (displayName.isNotEmpty) return displayName;
    final index = sourceIndex > 0 ? sourceIndex : 1;
    final hasBrowser =
        detectedBrowser.isNotEmpty && detectedBrowser != 'Unknown';
    return hasBrowser ? 'Browser $index ($detectedBrowser)' : 'Browser $index';
  }

  /// User-assigned name if set, otherwise a localized "Browser N (BrowserName)" default.
  String localizedLabel(AppLocalizations l10n) {
    if (displayName.isNotEmpty) return displayName;
    final index = sourceIndex > 0 ? sourceIndex : 1;
    final base = l10n.browserSourceDefaultName(index);
    final hasBrowser =
        detectedBrowser.isNotEmpty && detectedBrowser != 'Unknown';
    return hasBrowser ? '$base ($detectedBrowser)' : base;
  }

  BrowserSource copyWith({
    String? detectedBrowser,
    DateTime? firstSeen,
    DateTime? lastSeen,
    String? displayName,
    int? sourceIndex,
    int? nameUpdatedAt,
  }) {
    return BrowserSource(
      id: id,
      detectedBrowser: detectedBrowser ?? this.detectedBrowser,
      firstSeen: firstSeen ?? this.firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
      displayName: displayName ?? this.displayName,
      sourceIndex: sourceIndex ?? this.sourceIndex,
      nameUpdatedAt: nameUpdatedAt ?? this.nameUpdatedAt,
    );
  }
}

class AppDataStore extends ChangeNotifier {
  static final AppDataStore _instance = AppDataStore._internal();
  static const String _usageBoxName = 'harman_screentime_app_usage_box';
  static const String _focusBoxName = 'harman_screentime_focus_session_box';
  static const String _metadataBoxName = 'harman_screentime_app_metadata_box';
  static const String _webUsageBoxName = 'scolect_web_usage_box';
  static const String _webMetadataBoxName = 'scolect_web_metadata_box';
  static const String _browserSourcesBoxName = 'scolect_browser_sources_box';

  Box<AppUsageRecord>? _usageBox;
  Box<FocusSessionRecord>? _focusBox;
  Box<AppMetadata>? _metadataBox;
  Box<AppUsageRecord>? _webUsageBox;
  Box<AppMetadata>? _webMetadataBox;
  Box<BrowserSource>? _browserSourcesBox;

  bool _isInitialized = false;
  String? _lastError;
  DateTime? _lastMaintenanceDate;

  /// Directory the native Hive boxes are currently opened from. Used by the
  /// appId-key migration to locate box files for backup. Native (desktop)
  /// only — unset on web, where this migration never runs.
  String? _activeHiveDirPath;

  // Locks for thread safety
  final Lock _initLock = Lock();
  final Lock _usageBoxLock = Lock();
  final Lock _focusBoxLock = Lock();
  final Lock _metadataBoxLock = Lock();
  final Lock _runtimeCacheLock = Lock();

  // ============================================================
  // OPTIMIZED CACHE CONFIGURATION - BALANCED FOR < 2 MB
  // ============================================================

  /// Usage records: Keep last 60 days (balance between speed and memory)
  static const int _usageCacheDays = 60;

  /// Focus sessions: Keep last 1 year (very lightweight, ~365 KB)
  static const int _focusCacheDays = 365;

  /// Maximum usage records in cache (prevents unbounded growth)
  static const int _maxUsageCacheSize = 6000;

  // ============================================================
  // OPTIMIZED RUNTIME CACHE - Restructured for faster queries
  // ============================================================

  /// NEW: Date-indexed usage cache for O(1) date lookups
  /// Structure: "YYYY-MM-DD" -> {"appName" -> AppUsageRecord}
  final Map<String, Map<String, AppUsageRecord>> _usageCacheByDate = {};

  /// Focus cache: "YYYY-MM-DD" -> [FocusSessionRecord, ...]
  final Map<String, List<FocusSessionRecord>> _focusCacheByDate = {};

  /// Metadata cache: Always fully cached (tiny, ~10 KB)
  final Map<String, AppMetadata> _metadataCache = {};

  /// Cached list of app names (rebuilt only when metadata changes)
  List<String>? _cachedAppNames;

  /// Date string cache to avoid repeated formatting
  final Map<DateTime, String> _dateStringCache = {};

  /// Track dirty records for periodic commits
  final Set<String> _dirtyUsageKeys = {};
  final Set<String> _dirtyFocusKeys = {};

  /// In-memory-only delimiter for dirty-key composite strings (never
  /// persisted to Hive). Uses the ASCII unit separator instead of "::"
  /// because appId values (e.g. Windows executable paths) are otherwise
  /// unconstrained strings and must never collide with the delimiter.
  static const String _dirtyKeySeparator = '';

  /// Periodic persistence
  Timer? _persistenceTimer;
  final Duration _persistenceInterval = const Duration(minutes: 1);
  bool _hasDirtyData = false;

  factory AppDataStore() => _instance;
  AppDataStore._internal();

  bool get isInitialized => _isInitialized;
  String? get lastError => _lastError;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<bool> init() async {
    return await _initLock.synchronized(() async {
      if (_isInitialized) return true;

      try {
        if (kIsWeb) {
          await _initWebData();
          _isInitialized = true;
          return true;
        }

        // Platform-specific initialization
        String hivePath;

        String? _supportDirPath;
        if (!kIsWeb && (Platform.isMacOS || Platform.isWindows)) {
          final docsDir = await getApplicationDocumentsDirectory();
          final supportDir = await getApplicationSupportDirectory();
          _supportDirPath = supportDir.path;
          final newHivePath = '${docsDir.path}/Scolect';
          final newDir = Directory(newHivePath);

          // Migration logic
          String? oldHivePath;
          if (Platform.isMacOS) {
            oldHivePath = '${supportDir.path}/harman_screentime';
          } else if (Platform.isWindows) {
            // On Windows, if we were previously using initFlutter(),
            // it likely used the documents root directly.
            oldHivePath = docsDir.path;
          }

          if (oldHivePath != null && !await newDir.exists()) {
            final oldDir = Directory(oldHivePath);
            if (await oldDir.exists()) {
              try {
                if (Platform.isMacOS) {
                  debugPrint('📦 Migrating Hive data to Documents/Scolect...');
                  await oldDir.rename(newHivePath);
                  debugPrint('✅ Migration complete');
                  hivePath = newHivePath;
                } else if (Platform.isWindows) {
                  // On Windows, we move only the specific box files if they exist in root
                  final boxNames = [_usageBoxName, _focusBoxName, _metadataBoxName, _webUsageBoxName, _webMetadataBoxName, _browserSourcesBoxName];
                  bool migratedAny = false;

                  await newDir.create(recursive: true);

                  for (final name in boxNames) {
                    for (final ext in ['.hive', '.lock']) {
                      final file = File('${oldDir.path}/$name$ext');
                      if (await file.exists()) {
                        if (!migratedAny) {
                          debugPrint('📦 Migrating Windows Hive files to Documents/Scolect...');
                          migratedAny = true;
                        }
                        await file.rename('${newDir.path}/$name$ext');
                      }
                    }
                  }
                  if (migratedAny) debugPrint('✅ Windows Migration complete');
                  hivePath = newHivePath;
                } else {
                  hivePath = newHivePath;
                }
              } catch (e) {
                debugPrint('⚠️ Migration failed: $e, falling back to old path');
                hivePath = oldHivePath;
              }
            } else {
              hivePath = newHivePath;
            }
          } else {
            hivePath = newHivePath;
          }

          // On macOS, Documents folder requires user consent (TCC). If the
          // directory can't be opened for read+write (as Hive does), fall back
          // to Application Support which is always accessible.
          if (Platform.isMacOS) {
            bool documentsAccessible = false;
            try {
              final dir = Directory(hivePath);
              if (!await dir.exists()) await dir.create(recursive: true);
              // Probe using RandomAccessFile (same as Hive's box open) to
              // accurately detect sandbox permission blocks.
              final probeFile = File('${hivePath}/.hive_probe');
              final raf = await probeFile.open(mode: FileMode.append);
              await raf.close();
              await probeFile.delete();
              documentsAccessible = true;
            } catch (e) {
              debugPrint('⚠️ Documents folder not accessible ($e), falling back to Application Support');
            }
            if (!documentsAccessible) {
              hivePath = '${supportDir.path}/Scolect';
              debugPrint('📁 Using Application Support: $hivePath');
            }
          }

          if (!await Directory(hivePath).exists()) {
            await Directory(hivePath).create(recursive: true);
          }
          Hive.init(hivePath);
          _activeHiveDirPath = hivePath;
        } else {
          await Hive.initFlutter();
        }

        // Register adapters
        if (!Hive.isAdapterRegistered(1))
          Hive.registerAdapter(AppUsageRecordAdapter());
        if (!Hive.isAdapterRegistered(2))
          Hive.registerAdapter(TimeRangeAdapter());
        if (!Hive.isAdapterRegistered(3))
          Hive.registerAdapter(FocusSessionRecordAdapter());
        if (!Hive.isAdapterRegistered(4))
          Hive.registerAdapter(AppMetadataAdapter());
        if (!Hive.isAdapterRegistered(5))
          Hive.registerAdapter(DurationAdapter());
        if (!Hive.isAdapterRegistered(6))
          Hive.registerAdapter(BrowserSourceAdapter());

        // Open boxes — on macOS, the probe may pass but Hive's internal file
        // access can still be blocked by the sandbox (errno = 1). If that
        // happens, reinitialize Hive to Application Support and retry all boxes
        // from the new path.
        _usageBox = await _openBoxWithRetry<AppUsageRecord>(_usageBoxName);
        if (_usageBox == null && !kIsWeb && Platform.isMacOS && _supportDirPath != null) {
          final fallbackPath = '$_supportDirPath/Scolect';
          debugPrint('⚠️ Box open failed on macOS, falling back to Application Support: $fallbackPath');
          await Hive.close();
          await Directory(fallbackPath).create(recursive: true);
          Hive.init(fallbackPath);
          _activeHiveDirPath = fallbackPath;
          // Re-open all boxes from the fallback path — not just _usageBox.
          _usageBox     = await _openBoxWithRetry<AppUsageRecord>(_usageBoxName);
          _focusBox     = await _openBoxWithRetry<FocusSessionRecord>(_focusBoxName);
          _metadataBox  = await _openBoxWithRetry<AppMetadata>(_metadataBoxName);
          _webUsageBox  = await _openBoxWithRetry<AppUsageRecord>(_webUsageBoxName);
          _webMetadataBox = await _openBoxWithRetry<AppMetadata>(_webMetadataBoxName);
          _browserSourcesBox = await _openBoxWithRetry<BrowserSource>(_browserSourcesBoxName);
        } else {
          _focusBox       = await _openBoxWithRetry<FocusSessionRecord>(_focusBoxName);
          _metadataBox    = await _openBoxWithRetry<AppMetadata>(_metadataBoxName);
          _webUsageBox    = await _openBoxWithRetry<AppUsageRecord>(_webUsageBoxName);
          _webMetadataBox = await _openBoxWithRetry<AppMetadata>(_webMetadataBoxName);
          _browserSourcesBox = await _openBoxWithRetry<BrowserSource>(_browserSourcesBoxName);
        }

        if (_usageBox == null || _focusBox == null || _metadataBox == null ||
            _webUsageBox == null || _webMetadataBox == null || _browserSourcesBox == null) {
          _lastError = "Failed to open one or more Hive boxes";
          return false;
        }

        // Load optimized cache
        await _loadOptimizedRuntimeCache();

        // One-time migration: annotate legacy display-name-keyed metadata
        // entries with a displayName field ahead of the appId key scheme.
        // Native (desktop) only — never runs on web.
        if (!kIsWeb) {
          await _migrateToAppIdKeys();
          await _migrateBrowserSourceIndices();
        }

        _isInitialized = true;
        _startPeriodicPersistence();
        _schedulePeriodicMaintenance();
        notifyListeners();

        debugPrint('═══════════════════════════════════════════════════════');
        debugPrint('✅ AppDataStore initialized with OPTIMIZED cache');
        debugPrint('   Usage dates cached: ${_usageCacheByDate.length}');
        debugPrint('   Focus dates cached: ${_focusCacheByDate.length}');
        debugPrint('   Metadata cache: ${_metadataCache.length} apps');
        debugPrint(
            '   Est. memory: ${getEstimatedMemoryUsageMB().toStringAsFixed(2)} MB');
        debugPrint('═══════════════════════════════════════════════════════');

        return true;
      } catch (e) {
        _lastError = "Error initializing AppDataStore: $e";
        debugPrint(_lastError);
        return false;
      }
    });
  }

  // ============================================================
  // OPTIMIZED CACHE LOADING
  // ============================================================

  Future<void> _loadOptimizedRuntimeCache() async {
    debugPrint('📦 Loading optimized runtime cache...');
    final stopwatch = Stopwatch()..start();

    try {
      final usageCutoff =
          DateTime.now().subtract(Duration(days: _usageCacheDays));
      final focusCutoff =
          DateTime.now().subtract(Duration(days: _focusCacheDays));

      int loadedUsage = 0;
      int skippedUsage = 0;
      int loadedFocus = 0;
      int skippedFocus = 0;

      // Load recent usage records - using values iterator for efficiency
      if (_usageBox != null) {
        for (var entry in _usageBox!.toMap().entries) {
          final record = entry.value;
          if (record.date.isAfter(usageCutoff)) {
            final dateKey = _formatDateKey(record.date);
            final appName = _extractAppNameFromKey(entry.key.toString());

            _usageCacheByDate.putIfAbsent(dateKey, () => {});
            _usageCacheByDate[dateKey]![appName] = record;
            loadedUsage++;
          } else {
            skippedUsage++;
          }
        }
      }

      // Load recent web usage records from dedicated web box
      if (_webUsageBox != null) {
        for (var entry in _webUsageBox!.toMap().entries) {
          final record = entry.value;
          if (record.date.isAfter(usageCutoff)) {
            final dateKey = _formatDateKey(record.date);
            final appName = _extractAppNameFromKey(entry.key.toString());

            _usageCacheByDate.putIfAbsent(dateKey, () => {});
            _usageCacheByDate[dateKey]![appName] = record;
            loadedUsage++;
          } else {
            skippedUsage++;
          }
        }
      }

      // Load focus sessions from last year - grouped by date
      if (_focusBox != null) {
        for (var entry in _focusBox!.toMap().entries) {
          final record = entry.value;
          if (record.date.isAfter(focusCutoff)) {
            final dateKey = _formatDateKey(record.date);

            _focusCacheByDate.putIfAbsent(dateKey, () => []);
            _focusCacheByDate[dateKey]!.add(record);
            loadedFocus++;
          } else {
            skippedFocus++;
          }
        }
      }

      // Load ALL metadata (always needed, tiny ~10 KB)
      if (_metadataBox != null) {
        for (var entry in _metadataBox!.toMap().entries) {
          _metadataCache[entry.key.toString()] = entry.value;
        }
      }

      // Load ALL web metadata from dedicated web metadata box
      if (_webMetadataBox != null) {
        for (var entry in _webMetadataBox!.toMap().entries) {
          _metadataCache[entry.key.toString()] = entry.value;
        }
      }

      stopwatch.stop();

      final usageMemKB = loadedUsage * 500 ~/ 1024; // More realistic estimate
      final focusMemKB = loadedFocus * 200 ~/ 1024;
      final metaMemKB = _metadataCache.length * 100 ~/ 1024;

      debugPrint(
          '   ✓ Usage: $loadedUsage cached (~${usageMemKB}KB), $skippedUsage on disk');
      debugPrint(
          '   ✓ Focus: $loadedFocus cached (~${focusMemKB}KB), $skippedFocus on disk');
      debugPrint(
          '   ✓ Metadata: ${_metadataCache.length} apps (~${metaMemKB}KB)');
      debugPrint('✅ Cache loaded in ${stopwatch.elapsedMilliseconds}ms');
      debugPrint(
          '   Total: ~${(usageMemKB + focusMemKB + metaMemKB) ~/ 1024}MB in memory');
    } catch (e) {
      debugPrint('❌ Error loading runtime cache: $e');
    }
  }

  String _extractAppNameFromKey(String key) {
    final colonIndex = key.lastIndexOf(':');
    if (colonIndex != -1) {
      return key.substring(0, colonIndex);
    }
    return key;
  }

  // ============================================================
  // ONE-TIME MIGRATION: appId key scheme
  // ============================================================
  //
  // Historical native-app tracking was keyed by a volatile display name
  // (programName), which can fragment a single real app into multiple
  // entries if its resolved name changes across launches. Going forward,
  // apps are tracked under a stable appId (bundle identifier on macOS,
  // executable path on Windows) instead.
  //
  // There is no way to retroactively know what appId an old display-name
  // key "should" have had (that data was never captured), so this
  // migration only annotates existing metadata with a displayName field
  // equal to its own current key — preserving existing category/limit/
  // isPrivate settings exactly as they are. The actual reconciliation
  // between an old name-keyed entry and a freshly observed appId happens
  // lazily, the first time that appId is seen (see
  // absorbLegacyEntryIfPresent, called from application_controller.dart).
  static const String _appIdMigrationSettingKey =
      'migrations.appIdKeyMigrationDone';

  Future<void> _migrateToAppIdKeys() async {
    try {
      final alreadyDone =
          SettingsManager().getSetting(_appIdMigrationSettingKey) == true;
      if (alreadyDone) return;

      // Fresh install: nothing to migrate, nothing to protect. Mark done
      // immediately so this check is skipped on every future launch.
      final isFreshInstall =
          (_usageBox?.isEmpty ?? true) && (_metadataBox?.isEmpty ?? true);
      if (isFreshInstall) {
        SettingsManager()
            .updateSetting(_appIdMigrationSettingKey, true);
        debugPrint('🆕 appId migration: fresh install, nothing to migrate');
        return;
      }

      debugPrint('📦 appId migration: backing up native Hive boxes...');
      final backedUp = await _backupBoxesForMigration();
      if (!backedUp) {
        debugPrint(
            '⚠️ appId migration: backup failed, aborting — will retry on next launch');
        return;
      }

      int annotated = 0;
      if (_metadataBox != null) {
        for (final key in _metadataBox!.keys.whereType<String>().toList()) {
          final metadata = _metadataBox!.get(key);
          if (metadata == null || metadata.displayName.isNotEmpty) continue;

          final updated = metadata.copyWith(displayName: key);
          await _metadataBox!.put(key, updated);
          _metadataCache[key] = updated;
          annotated++;
        }
      }

      SettingsManager().updateSetting(_appIdMigrationSettingKey, true);
      debugPrint(
          '✅ appId migration: annotated $annotated legacy metadata entries');
    } catch (e) {
      debugPrint('❌ appId migration failed: $e');
      // Leave the flag unset so this is retried on next launch rather than
      // silently skipped — nothing destructive has happened either way.
    }
  }

  Future<void> _migrateBrowserSourceIndices() async {
    if (_browserSourcesBox == null) return;
    var nextIdx = 1;
    for (final key in _browserSourcesBox!.keys.toList()) {
      final src = _browserSourcesBox!.get(key);
      if (src != null) {
        if (src.sourceIndex <= 0) {
          await _browserSourcesBox!.put(key, src.copyWith(sourceIndex: nextIdx));
        }
        if (src.sourceIndex >= nextIdx) {
          nextIdx = src.sourceIndex + 1;
        }
      }
    }
  }

  /// Copies (never moves) the current native Hive box files into a
  /// timestamped backup folder before the appId migration writes anything.
  /// Returns false if the backup could not be completed, in which case the
  /// caller must not proceed with migration.
  Future<bool> _backupBoxesForMigration() async {
    final dirPath = _activeHiveDirPath;
    if (dirPath == null) {
      debugPrint('⚠️ appId migration: no active Hive directory known, skipping backup');
      return false;
    }

    try {
      await _usageBox?.flush();
      await _metadataBox?.flush();

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(RegExp(r'[:.]'), '-');
      final backupDir =
          Directory('$dirPath/backup_pre_appid_migration_$timestamp');
      await backupDir.create(recursive: true);

      final boxNames = [_usageBoxName, _metadataBoxName];
      for (final name in boxNames) {
        for (final ext in ['.hive', '.lock']) {
          final source = File('$dirPath/$name$ext');
          if (await source.exists()) {
            await source.copy('${backupDir.path}/$name$ext');
          }
        }
      }

      debugPrint('✅ appId migration: backup written to ${backupDir.path}');
      return true;
    } catch (e) {
      debugPrint('❌ appId migration: backup failed: $e');
      return false;
    }
  }

  Box<AppUsageRecord> _usageBoxFor(String appName) =>
      appName.startsWith('web:') ? _webUsageBox! : _usageBox!;

  Box<AppMetadata> _metadataBoxFor(String appName) =>
      appName.startsWith('web:') ? _webMetadataBox! : _metadataBox!;

  // ============================================================
  // BROWSER SOURCE REGISTRY
  // ============================================================
  //
  // Tracks which browser extensions/profiles have ever synced to this
  // desktop app, keyed by the UUID each extension generates once and
  // persists forever (see web/background.js getBrowserId()). This is
  // metadata about *sources*, not usage — it is intentionally untouched by
  // clearWebData() (which only deletes usage history) so a renamed browser
  // doesn't need to be renamed again after clearing data.

  BrowserSource? getBrowserSource(String id) {
    if (!_ensureInitialized() || _browserSourcesBox == null) return null;
    return _browserSourcesBox!.get(id);
  }

  /// Registers a sync from [id], updating lastSeen (and detectedBrowser, in
  /// case the same browser reports a more specific UA than before). Creates
  /// a new entry with firstSeen = now if this id has never been seen, given
  /// the next sourceIndex so it defaults to a localized "Browser N (BrowserName)" label
  /// rather than the plain detected browser name. User-assigned displayName is
  /// always preserved across calls once set.
  Future<void> upsertBrowserSource(
    String id,
    String detectedBrowser, {
    String? displayName,
    int nameUpdatedAt = 0,
  }) async {
    if (!_ensureInitialized() || _browserSourcesBox == null) return;
    final now = DateTime.now();
    final existing = _browserSourcesBox!.get(id);

    final String targetDisplayName;
    final int targetUpdatedAt;

    if (existing == null) {
      targetDisplayName = (displayName != null && displayName.isNotEmpty) ? displayName : '';
      targetUpdatedAt = targetDisplayName.isNotEmpty
          ? (nameUpdatedAt > 0 ? nameUpdatedAt : now.millisecondsSinceEpoch)
          : 0;
    } else {
      // Last-Write-Wins: only adopt incoming name if its timestamp is newer than what we have
      if (displayName != null && displayName.isNotEmpty && nameUpdatedAt > existing.nameUpdatedAt) {
        targetDisplayName = displayName;
        targetUpdatedAt = nameUpdatedAt;
      } else {
        targetDisplayName = existing.displayName;
        targetUpdatedAt = existing.nameUpdatedAt;
      }
    }

    final updated = existing == null
        ? BrowserSource(
            id: id,
            detectedBrowser: detectedBrowser,
            firstSeen: now,
            lastSeen: now,
            displayName: targetDisplayName,
            nameUpdatedAt: targetUpdatedAt,
            sourceIndex: _browserSourcesBox!.length + 1,
          )
        : existing.copyWith(
            detectedBrowser: detectedBrowser,
            lastSeen: now,
            displayName: targetDisplayName,
            nameUpdatedAt: targetUpdatedAt,
            sourceIndex: existing.sourceIndex > 0
                ? existing.sourceIndex
                : _browserSourcesBox!.length,
          );
    await _browserSourcesBox!.put(id, updated).catchError((e) {
      debugPrint('⚠️ Error saving browser source to Hive: $e');
    });
    notifyListeners();
  }

  Future<void> renameBrowserSource(
    String id,
    String displayName, {
    int? updatedAt,
  }) async {
    if (!_ensureInitialized() || _browserSourcesBox == null) return;
    final existing = _browserSourcesBox!.get(id);
    if (existing == null) return;

    final timestamp = updatedAt ?? DateTime.now().millisecondsSinceEpoch;
    // Don't overwrite if existing is already newer
    if (updatedAt != null && timestamp < existing.nameUpdatedAt) return;

    await _browserSourcesBox!.put(
      id,
      existing.copyWith(displayName: displayName, nameUpdatedAt: timestamp),
    );
    BrowserExtensionServer.broadcastBrowserRenamed(
      id,
      displayName,
      nameUpdatedAt: timestamp,
    );
    notifyListeners();
  }

  Future<void> removeBrowserSource(String id) async {
    if (!_ensureInitialized() || _browserSourcesBox == null) return;
    await _browserSourcesBox!.delete(id);
    notifyListeners();
  }

  List<BrowserSource> get browserSources {
    if (!_ensureInitialized() || _browserSourcesBox == null) return [];
    final sources = _browserSourcesBox!.values.toList();
    sources.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
    return sources;
  }

  // ============================================================
  // PERIODIC PERSISTENCE - Only runs when needed
  // ============================================================

  void _startPeriodicPersistence() {
    // Don't start timer immediately - schedule only when data is dirty
    _scheduleNextPersistence();
  }

  void _scheduleNextPersistence() {
    if (!_hasDirtyData) return;

    _persistenceTimer?.cancel();
    _persistenceTimer = Timer(_persistenceInterval, () {
      _commitRuntimeCacheToHive();
    });
  }

  void _markDirty() {
    if (!_hasDirtyData) {
      _hasDirtyData = true;
      _scheduleNextPersistence();
    }
  }

  Future<void> _commitRuntimeCacheToHive() async {
    if (!_isInitialized || !_hasDirtyData) return;

    try {
      final stopwatch = Stopwatch()..start();
      int usageCommitted = 0;
      int focusCommitted = 0;

      await _runtimeCacheLock.synchronized(() async {
        if (_dirtyUsageKeys.isNotEmpty && _usageBox != null) {
          // Batch write for better performance
          final batch = <String, AppUsageRecord>{};

          for (var key in _dirtyUsageKeys) {
            final parts = key.split(_dirtyKeySeparator);
            if (parts.length == 2) {
              final dateKey = parts[0];
              final appName = parts[1];
              final record = _usageCacheByDate[dateKey]?[appName];
              if (record != null) {
                final hiveKey = _makeUsageKey(appName, record.date);
                batch[hiveKey] = record;
              }
            }
          }

          final appBatch = <String, AppUsageRecord>{};
          final webBatch = <String, AppUsageRecord>{};
          for (final entry in batch.entries) {
            // The hive key format is "appName:YYYY-MM-DD" — extract appName
            final appName = entry.key.substring(0, entry.key.lastIndexOf(':'));
            if (appName.startsWith('web:')) {
              webBatch[entry.key] = entry.value;
            } else {
              appBatch[entry.key] = entry.value;
            }
          }
          if (appBatch.isNotEmpty) await _usageBox!.putAll(appBatch);
          if (webBatch.isNotEmpty && _webUsageBox != null) await _webUsageBox!.putAll(webBatch);
          usageCommitted = batch.length;
          _dirtyUsageKeys.clear();
        }

        if (_dirtyFocusKeys.isNotEmpty && _focusBox != null) {
          final batch = <String, FocusSessionRecord>{};

          for (var key in _dirtyFocusKeys) {
            final parts = key.split(_dirtyKeySeparator);
            if (parts.length == 2) {
              final dateKey = parts[0];
              final index = int.tryParse(parts[1]);
              if (index != null) {
                final sessions = _focusCacheByDate[dateKey];
                if (sessions != null && index < sessions.length) {
                  final session = sessions[index];
                  final hiveKey = _makeFocusKey(
                      session.date, session.startTime.millisecondsSinceEpoch);
                  batch[hiveKey] = session;
                }
              }
            }
          }

          await _focusBox!.putAll(batch);
          focusCommitted = batch.length;
          _dirtyFocusKeys.clear();
        }

        _hasDirtyData = false;
      });

      stopwatch.stop();

      if (usageCommitted > 0 || focusCommitted > 0) {
        debugPrint(
            '💾 Committed: $usageCommitted usage, $focusCommitted focus (${stopwatch.elapsedMilliseconds}ms)');
      }
    } catch (e) {
      debugPrint('❌ Error committing to Hive: $e');
    }
  }

  Future<void> forceCommitToHive() async {
    debugPrint('🔄 Force committing all data to Hive...');
    await _commitRuntimeCacheToHive();
  }

  // ============================================================
  // BOX MANAGEMENT
  // ============================================================

  Future<Box<T>?> _openBoxWithRetry<T>(String boxName,
      {int maxRetries = 3}) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await Hive.openBox<T>(
          boxName,
          compactionStrategy: (entries, deletedEntries) {
            return deletedEntries > 15 && deletedEntries / entries > 0.15;
          },
        );
      } catch (e) {
        attempts++;
        debugPrint("Box opening attempt $attempts failed: $e");

        if (attempts >= maxRetries) {
          _lastError =
              "Failed to open box $boxName after $maxRetries attempts: $e";
          debugPrint(_lastError);
          return null;
        }

        // On any failure (not just known corruption strings), back up and
        // delete the box so the next attempt starts with a clean file.
        // Previously only pattern-matched errors triggered deletion, meaning
        // unknown Hive errors would retry against the same broken file.
        try {
          debugPrint("Backing up and recreating box: $boxName");
          try {
            final box = Hive.box(boxName);
            if (box.isOpen) await box.close();
          } catch (_) {}
          await _backupBoxFile(boxName);
          await Hive.deleteBoxFromDisk(boxName);
          debugPrint("Deleted box: $boxName, retrying...");
        } catch (deleteError) {
          debugPrint("Error deleting box: $deleteError");
        }

        await Future.delayed(Duration(milliseconds: 200 * (1 << attempts)));
      }
    }

    return null;
  }

  /// Renames the .hive file to .hive.bak before deletion so manual recovery
  /// is possible. Silently no-ops if the file doesn't exist or path is unknown.
  Future<void> _backupBoxFile(String boxName) async {
    if (kIsWeb) return;
    try {
      // Derive the Hive directory from the same logic used in init():
      // prefer Documents/Scolect, fall back to Application Support/Scolect.
      String? hiveDirPath;
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        final candidate = '${docsDir.path}/Scolect';
        if (await Directory(candidate).exists()) {
          hiveDirPath = candidate;
        }
      } catch (_) {}

      if (hiveDirPath == null) {
        try {
          final supportDir = await getApplicationSupportDirectory();
          final candidate = '${supportDir.path}/Scolect';
          if (await Directory(candidate).exists()) {
            hiveDirPath = candidate;
          }
        } catch (_) {}
      }

      if (hiveDirPath == null) return;

      final src = File('$hiveDirPath/$boxName.hive');
      if (await src.exists()) {
        final dst = File('$hiveDirPath/$boxName.hive.bak');
        if (await dst.exists()) await dst.delete();
        await src.rename(dst.path);
        debugPrint('📦 Backed up $boxName.hive → $boxName.hive.bak');
      }
    } catch (e) {
      debugPrint('⚠️ Could not back up $boxName: $e');
    }
  }

  Future<void> checkAndRepairBoxes() async {
    debugPrint("Running database maintenance check...");

    await _initLock.synchronized(() async {
      for (final boxInfo in [
        {'name': _usageBoxName, 'box': _usageBox, 'lock': _usageBoxLock},
        {'name': _focusBoxName, 'box': _focusBox, 'lock': _focusBoxLock},
        {
          'name': _metadataBoxName,
          'box': _metadataBox,
          'lock': _metadataBoxLock
        },
        {'name': _webUsageBoxName, 'box': _webUsageBox, 'lock': _usageBoxLock},
        {
          'name': _webMetadataBoxName,
          'box': _webMetadataBox,
          'lock': _metadataBoxLock
        },
      ]) {
        final String boxName = boxInfo['name'] as String;
        final Box? box = boxInfo['box'] as Box?;
        final Lock lock = boxInfo['lock'] as Lock;

        await lock.synchronized(() async {
          try {
            if (box != null && box.isOpen) {
              try {
                // Read all keys (not just 1) to stress the full key index.
                // A single-key probe passes even when corruption sits in the
                // middle of the file and only surfaces on real reads later.
                box.keys.toList();
                debugPrint("Box $boxName is healthy");
              } catch (e) {
                debugPrint("Box $boxName is corrupted, repairing: $e");

                try {
                  await box.close();
                } catch (_) {}

                // Back up before wiping so manual recovery is possible.
                await _backupBoxFile(boxName);

                try {
                  await Hive.deleteBoxFromDisk(boxName);
                } catch (deleteError) {
                  debugPrint("Error deleting box: $deleteError");
                }

                if (boxName == _usageBoxName) {
                  _usageBox = await _openBoxWithRetry<AppUsageRecord>(boxName);
                } else if (boxName == _focusBoxName) {
                  _focusBox =
                      await _openBoxWithRetry<FocusSessionRecord>(boxName);
                } else if (boxName == _metadataBoxName) {
                  _metadataBox = await _openBoxWithRetry<AppMetadata>(boxName);
                } else if (boxName == _webUsageBoxName) {
                  _webUsageBox = await _openBoxWithRetry<AppUsageRecord>(boxName);
                } else if (boxName == _webMetadataBoxName) {
                  _webMetadataBox = await _openBoxWithRetry<AppMetadata>(boxName);
                }
              }
            } else {
              debugPrint("Box $boxName is not open, attempting to open");
              if (boxName == _usageBoxName) {
                _usageBox = await _openBoxWithRetry<AppUsageRecord>(boxName);
              } else if (boxName == _focusBoxName) {
                _focusBox =
                    await _openBoxWithRetry<FocusSessionRecord>(boxName);
              } else if (boxName == _metadataBoxName) {
                _metadataBox = await _openBoxWithRetry<AppMetadata>(boxName);
              } else if (boxName == _webUsageBoxName) {
                _webUsageBox = await _openBoxWithRetry<AppUsageRecord>(boxName);
              } else if (boxName == _webMetadataBoxName) {
                _webMetadataBox = await _openBoxWithRetry<AppMetadata>(boxName);
              }
            }
          } catch (e) {
            debugPrint("Error checking box $boxName: $e");
          }
        });
      }

      _lastMaintenanceDate = DateTime.now();
    });
  }

  void _schedulePeriodicMaintenance() {
    final now = DateTime.now();
    if (_lastMaintenanceDate == null ||
        now.difference(_lastMaintenanceDate!).inHours > 24) {
      checkAndRepairBoxes();
    }
  }

  bool _ensureInitialized() {
    if (!_isInitialized) {
      _lastError = "AppDataStore not initialized. Call init() first.";
      debugPrint(_lastError);
      return false;
    }
    
    // On web, we don't use Hive boxes, so they will be null.
    if (!kIsWeb && (_usageBox == null || _focusBox == null || _metadataBox == null ||
        _webUsageBox == null || _webMetadataBox == null)) {
      _lastError = "AppDataStore Hive boxes not initialized.";
      debugPrint(_lastError);
      return false;
    }
    
    return true;
  }

  // ============================================================
  // METADATA OPERATIONS
  // ============================================================

  List<String> get allAppNames {
    if (!_ensureInitialized()) return [];
    try {
      // Return cached list if available
      return _cachedAppNames ??= _metadataCache.keys.toList();
    } catch (e) {
      _lastError = "Error getting app names: $e";
      debugPrint(_lastError);
      return [];
    }
  }

  Future<bool> updateAppMetadata(
    String appName, {
    String? category,
    bool? isProductive,
    bool? isTracking,
    bool? isVisible,
    Duration? dailyLimit,
    bool? limitStatus,
    String? siteName,
    bool? isPrivate,
    String? displayName,
    int? updatedAt,
  }) async {
    if (kIsWeb) {
      final effectiveLimit = (limitStatus == false) ? Duration.zero : dailyLimit;
      await WebBrowserDataProvider().updateWebsiteMetadata(
        appName,
        category: category,
        isProductive: isProductive,
        isTracking: isTracking,
        isVisible: isVisible,
        dailyLimit: effectiveLimit,
        siteName: siteName,
        isPrivate: isPrivate,
      );
    }

    if (!_ensureInitialized()) return false;

    try {
      AppMetadata? existing = _metadataCache[appName];
      String defaultCategory =
          appName.startsWith(':') ? 'Idle' : 'Uncategorized';

      final AppMetadata updated = AppMetadata(
        category: category ?? existing?.category ?? defaultCategory,
        isProductive: isProductive ?? existing?.isProductive ?? false,
        isTracking: isTracking ?? existing?.isTracking ?? true,
        isVisible: isVisible ?? existing?.isVisible ?? true,
        dailyLimit: dailyLimit ?? existing?.dailyLimit ?? Duration.zero,
        limitStatus: limitStatus ?? existing?.limitStatus ?? false,
        siteName: siteName ?? existing?.siteName ?? '',
        isPrivate: isPrivate ?? existing?.isPrivate ?? false,
        displayName: displayName ?? existing?.displayName ?? '',
        updatedAt: updatedAt ?? DateTime.now().millisecondsSinceEpoch,
      );

      _metadataCache[appName] = updated;

      // Invalidate cached app names list
      _cachedAppNames = null;

      _metadataBoxFor(appName).put(appName, updated).catchError((e) {
        debugPrint('⚠️ Error saving metadata to Hive: $e');
      });

      notifyListeners();
      return true;
    } catch (e) {
      _lastError = "Error updating app metadata for $appName: $e";
      debugPrint(_lastError);
      return false;
    }
  }

  AppMetadata? getAppMetadata(String appName, {String? sourceId}) {
    if (!_ensureInitialized()) return null;
    try {
      if (sourceId != null && sourceId.isNotEmpty && appName.startsWith('web:')) {
        final scopedKey = '$appName::$sourceId';
        final scoped = _metadataCache[scopedKey];
        if (scoped != null) return scoped;
      }
      return _metadataCache[appName];
    } catch (e) {
      _lastError = "Error getting metadata for $appName: $e";
      debugPrint(_lastError);
      return null;
    }
  }

  /// Resolves a storage key (appId, or a legacy display-name key) to the
  /// text that should be shown to the user. Falls back to the raw key when
  /// no display name has been recorded yet (e.g. legacy entries that predate
  /// the appId migration, or brand-new entries not yet annotated).
  String displayNameFor(String appId) {
    final metadata = _metadataCache[appId];
    if (metadata != null && metadata.displayName.isNotEmpty) {
      return metadata.displayName;
    }
    return appId;
  }

  /// Best-effort merge of a legacy display-name-keyed entry into a newly
  /// observed stable [newAppId]. Historical desktop-app records were keyed
  /// by [programName] (a display string that can drift across launches),
  /// so when [newAppId] is seen for the first time, this looks for an old
  /// entry still sitting under that display name and — if found — absorbs
  /// its usage history and metadata (category/limit/isPrivate/etc.) into
  /// the new appId-keyed entry, then deletes the old one.
  ///
  /// Returns the merged metadata on success, or null if no legacy entry
  /// was found under [programName] (caller should create fresh metadata).
  /// Native (non-"web:") entries only — web/browser tracking is unaffected
  /// by this migration.
  Future<AppMetadata?> absorbLegacyEntryIfPresent(
    String newAppId,
    String programName,
  ) async {
    if (!_ensureInitialized()) return null;
    if (programName.isEmpty || programName == newAppId) return null;
    if (newAppId.startsWith('web:') || programName.startsWith('web:')) {
      return null;
    }
    if (_metadataBox == null || _usageBox == null) return null;

    try {
      final legacyMetadata = _metadataBox!.get(programName);
      if (legacyMetadata == null) return null;

      // Move every usage record keyed under the old display-name to the
      // new appId key, merging with anything already recorded under the
      // new key (e.g. a few seconds tracked before this merge check ran).
      final legacyKeys =
          _usageBox!.keys.whereType<String>().where((k) {
        final lastColon = k.lastIndexOf(':');
        if (lastColon == -1) return false;
        return k.substring(0, lastColon) == programName;
      }).toList();

      for (final legacyKey in legacyKeys) {
        final legacyRecord = _usageBox!.get(legacyKey);
        if (legacyRecord == null) continue;

        final dateKey = _formatDateKey(legacyRecord.date);
        final newHiveKey = _makeUsageKey(newAppId, legacyRecord.date);
        final existingNewRecord = _usageBox!.get(newHiveKey);
        final mergedRecord = existingNewRecord != null
            ? existingNewRecord.merge(legacyRecord)
            : legacyRecord;

        await _usageBox!.put(newHiveKey, mergedRecord);
        await _usageBox!.delete(legacyKey);

        // Keep the in-memory cache consistent with what's now on disk.
        _usageCacheByDate.putIfAbsent(dateKey, () => {});
        _usageCacheByDate[dateKey]![newAppId] = mergedRecord;
        _usageCacheByDate[dateKey]?.remove(programName);
      }

      final mergedMetadata = legacyMetadata.copyWith(displayName: programName);
      await _metadataBox!.put(newAppId, mergedMetadata);
      await _metadataBox!.delete(programName);

      _metadataCache[newAppId] = mergedMetadata;
      _metadataCache.remove(programName);
      _cachedAppNames = null;

      debugPrint(
          '🔗 Merged legacy entry "$programName" into appId "$newAppId" '
          '(${legacyKeys.length} usage record(s))');

      notifyListeners();
      return mergedMetadata;
    } catch (e) {
      debugPrint('⚠️ Error absorbing legacy entry for $programName: $e');
      return null;
    }
  }

  Future<bool> deleteAppMetadata(String appName) async {
    if (!_ensureInitialized()) return false;

    try {
      _metadataCache.remove(appName);

      // Invalidate cached app names list
      _cachedAppNames = null;

      if (_metadataBoxFor(appName).containsKey(appName)) {
        _metadataBoxFor(appName).delete(appName).catchError((e) {
          debugPrint('⚠️ Error deleting metadata from Hive: $e');
        });
      }

      notifyListeners();
      return true;
    } catch (e) {
      _lastError = "Error deleting metadata for $appName: $e";
      debugPrint(_lastError);
      return false;
    }
  }

  // ============================================================
  // APP USAGE OPERATIONS
  // ============================================================

  // Safe even though appName may now be a Windows executable path containing
  // its own colon (e.g. "C:\Program Files\App\app.exe"): _formatDateKey never
  // produces a colon, so splitting on the LAST colon (see
  // _extractAppNameFromKey and the commit-batch split above) always isolates
  // the date suffix correctly regardless of how many colons precede it.
  String _makeUsageKey(String appName, DateTime date) {
    final safeName = appName.length > 244 ? appName.substring(0, 244) : appName;
    return '$safeName:${_formatDateKey(date)}';
  }

  String _makeFocusKey(DateTime date, int millisecondsSinceEpoch) {
    return '${_formatDateKey(date)}:$millisecondsSinceEpoch';
  }

  Future<bool> recordAppUsage(
    String appName,
    DateTime date,
    Duration timeSpent,
    int openCount,
    List<TimeRange> usagePeriods,
  ) async {
    if (!_ensureInitialized()) return false;

    try {
      return await _runtimeCacheLock.synchronized(() async {
        final dateKey = _formatDateKey(date);

        // Initialize date map if needed
        _usageCacheByDate.putIfAbsent(dateKey, () => {});

        final existing = _usageCacheByDate[dateKey]![appName];

        if (existing != null) {
          final List<TimeRange> optimizedPeriods = _optimizeUsagePeriods(
            [...existing.usagePeriods, ...usagePeriods],
          );

          final AppUsageRecord updated = AppUsageRecord(
            date: date,
            timeSpent: existing.timeSpent + timeSpent,
            openCount: existing.openCount + openCount,
            usagePeriods: optimizedPeriods,
          );

          _usageCacheByDate[dateKey]![appName] = updated;
        } else {
          final AppUsageRecord record = AppUsageRecord(
            date: date,
            timeSpent: timeSpent,
            openCount: openCount,
            usagePeriods: usagePeriods,
          );

          _usageCacheByDate[dateKey]![appName] = record;
        }

        // Mark as dirty for persistence
        _dirtyUsageKeys.add('$dateKey$_dirtyKeySeparator$appName');
        _markDirty();

        notifyListeners();
        return true;
      });
    } catch (e) {
      _lastError = "Error recording app usage for $appName: $e";
      debugPrint(_lastError);
      return false;
    }
  }

  Future<bool> setAppUsage(
    String appName,
    DateTime date,
    Duration timeSpent,
    int openCount,
    List<TimeRange> usagePeriods,
  ) async {
    if (!_ensureInitialized()) return false;

    try {
      return await _runtimeCacheLock.synchronized(() async {
        final dateKey = _formatDateKey(date);
        _usageCacheByDate.putIfAbsent(dateKey, () => {});

        final AppUsageRecord record = AppUsageRecord(
          date: date,
          timeSpent: timeSpent,
          openCount: openCount,
          usagePeriods: usagePeriods,
        );

        _usageCacheByDate[dateKey]![appName] = record;
        _dirtyUsageKeys.add('$dateKey$_dirtyKeySeparator$appName');
        _markDirty();

        notifyListeners();
        return true;
      });
    } catch (e) {
      _lastError = "Error setting app usage for $appName: $e";
      debugPrint(_lastError);
      return false;
    }
  }

  List<TimeRange> _optimizeUsagePeriods(List<TimeRange> periods) {
    if (periods.length <= 10) return periods;

    // Check if already sorted
    bool isSorted = true;
    for (int i = 1; i < periods.length; i++) {
      if (periods[i].startTime.isBefore(periods[i - 1].startTime)) {
        isSorted = false;
        break;
      }
    }

    if (!isSorted) {
      periods.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    List<TimeRange> optimizedPeriods = [];
    TimeRange current = periods.first;

    for (int i = 1; i < periods.length; i++) {
      TimeRange next = periods[i];

      if (next.startTime.difference(current.endTime).inSeconds <= 5) {
        current =
            TimeRange(startTime: current.startTime, endTime: next.endTime);
      } else {
        optimizedPeriods.add(current);
        current = next;
      }
    }

    optimizedPeriods.add(current);

    if (optimizedPeriods.length > 10) {
      return optimizedPeriods.sublist(optimizedPeriods.length - 10);
    }

    return optimizedPeriods;
  }

  /// Get single app usage - O(1) lookup with date-indexed cache
  AppUsageRecord? getAppUsage(String appName, DateTime date) {
    if (!_ensureInitialized()) return null;

    try {
      final dateKey = _formatDateKey(date);

      // O(1) lookup in cache
      final record = _usageCacheByDate[dateKey]?[appName];
      if (record != null) {
        return record;
      }

      // Fallback to Hive (slower but works)
      final targetUsageBox = appName.startsWith('web:') ? _webUsageBox : _usageBox;
      if (targetUsageBox != null) {
        final hiveKey = _makeUsageKey(appName, date);
        final record = targetUsageBox.get(hiveKey);

        // Cache if within extended window (90 days) and space available
        if (record != null) {
          final age = DateTime.now().difference(record.date).inDays;
          final totalRecords =
              _usageCacheByDate.values.fold(0, (sum, map) => sum + map.length);

          if (age <= 90 && totalRecords < _maxUsageCacheSize) {
            _usageCacheByDate.putIfAbsent(dateKey, () => {});
            _usageCacheByDate[dateKey]![appName] = record;
          }
        }

        return record;
      }

      return null;
    } catch (e) {
      _lastError = "Error getting app usage for $appName: $e";
      debugPrint(_lastError);
      return null;
    }
  }

  /// Aggregates website usage for [webAppName] (a plain 'web:$domain' key,
  /// no source suffix) across per-browser-source records.
  ///
  /// - [sourceId] == null: combines the legacy untagged record ('web:$domain',
  ///   written before multi-browser support existed) with every per-source
  ///   record ('web:$domain::$id') for every known [browserSources] entry —
  ///   this is the "All Browsers" view.
  /// - [sourceId] != null: returns only the record for that one source
  ///   ('web:$domain::$sourceId'). Legacy untagged data is intentionally
  ///   excluded here since it can't be attributed to any specific browser.
  AppUsageRecord? getWebsiteUsage(String webAppName, DateTime date, {String? sourceId}) {
    if (sourceId != null) {
      return getAppUsage('$webAppName::$sourceId', date);
    }

    AppUsageRecord? combined = getAppUsage(webAppName, date);
    for (final source in browserSources) {
      final perSource = getAppUsage('$webAppName::${source.id}', date);
      if (perSource == null) continue;
      combined = combined == null ? perSource : combined.merge(perSource);
    }
    return combined;
  }

  /// Get app usage for date range - optimized for batch queries
  List<AppUsageRecord> getAppUsageRange(
    String appName,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (!_ensureInitialized()) return [];

    try {
      final List<AppUsageRecord> result = [];
      DateTime currentDate =
          DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime endOfRange =
          DateTime(endDate.year, endDate.month, endDate.day);

      while (!currentDate.isAfter(endOfRange)) {
        final record = getAppUsage(appName, currentDate);
        if (record != null) {
          result.add(record);
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }

      return result;
    } catch (e) {
      _lastError = "Error getting app usage range for $appName: $e";
      debugPrint(_lastError);
      return [];
    }
  }

  // ============================================================
  // OPTIMIZED BATCH OPERATIONS FOR ANALYTICS
  // ============================================================

  /// Get total usage per app for date range (HIGHLY OPTIMIZED)
  Map<String, Duration> getAppUsageTotals(
      DateTime startDate, DateTime endDate) {
    if (!_ensureInitialized()) return {};

    try {
      final Map<String, Duration> totals = {};
      final DateTime start =
          DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime end = DateTime(endDate.year, endDate.month, endDate.day);

      int cacheHits = 0;
      int hiveReads = 0;

      // Iterate through cache efficiently - O(days) instead of O(days * apps)
      // Skip web:* entries — browser domain data belongs only to the Browser
      // section and must not appear in native app totals or Reports.
      for (var dateEntry in _usageCacheByDate.entries) {
        final date = _parseDate(dateEntry.key);
        if (date != null && !date.isBefore(start) && !date.isAfter(end)) {
          for (var appEntry in dateEntry.value.entries) {
            if (appEntry.key.startsWith('web:')) continue;
            totals[appEntry.key] = (totals[appEntry.key] ?? Duration.zero) +
                appEntry.value.timeSpent;
            cacheHits++;
          }
        }
      }

      // Check Hive for any dates not in cache
      if (_usageBox != null) {
        DateTime current = start;
        while (!current.isAfter(end)) {
          final dateKey = _formatDateKey(current);

          // Skip if date already in cache
          if (!_usageCacheByDate.containsKey(dateKey)) {
            for (final appName in allAppNames) {
              if (appName.startsWith('web:')) continue; // browser-only — skip
              final hiveKey = _makeUsageKey(appName, current);
              final record = _usageBox!.get(hiveKey);
              if (record != null) {
                totals[appName] =
                    (totals[appName] ?? Duration.zero) + record.timeSpent;
                hiveReads++;
              }
            }
          }

          current = current.add(const Duration(days: 1));
        }
      }

      if (hiveReads > 0) {
        debugPrint(
            '📊 Batch query: $cacheHits cache hits, $hiveReads Hive reads');
      }

      return totals;
    } catch (e) {
      _lastError = "Error getting app usage totals: $e";
      debugPrint(_lastError);
      return {};
    }
  }

  /// Get all usage records for date range (all apps) - HIGHLY OPTIMIZED
  Map<String, List<AppUsageRecord>> getAllAppUsageForRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    if (!_ensureInitialized()) return {};

    try {
      final Map<String, List<AppUsageRecord>> result = {};
      final stopwatch = Stopwatch()..start();
      final DateTime start =
          DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime end = DateTime(endDate.year, endDate.month, endDate.day);

      int cacheHits = 0;
      int hiveReads = 0;

      // Efficiently scan cache
      for (var dateEntry in _usageCacheByDate.entries) {
        final date = _parseDate(dateEntry.key);
        if (date != null && !date.isBefore(start) && !date.isAfter(end)) {
          for (var appEntry in dateEntry.value.entries) {
            result.putIfAbsent(appEntry.key, () => []);
            result[appEntry.key]!.add(appEntry.value);
            cacheHits++;
          }
        }
      }

      // Check Hive for missing dates
      if (_usageBox != null) {
        DateTime current = start;
        while (!current.isAfter(end)) {
          final dateKey = _formatDateKey(current);

          if (!_usageCacheByDate.containsKey(dateKey)) {
            for (final appName in allAppNames) {
              final hiveKey = _makeUsageKey(appName, current);
              final record = _usageBoxFor(appName).get(hiveKey);
              if (record != null) {
                result.putIfAbsent(appName, () => []);
                result[appName]!.add(record);
                hiveReads++;
              }
            }
          }

          current = current.add(const Duration(days: 1));
        }
      }

      stopwatch.stop();

      if (hiveReads > 0) {
        debugPrint(
            '📊 Batch load: $cacheHits cache hits, $hiveReads Hive reads in ${stopwatch.elapsedMilliseconds}ms');
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error in batch load: $e');
      return {};
    }
  }

  // ============================================================
  // FOCUS SESSION OPERATIONS
  // ============================================================

  Future<bool> recordFocusSession(FocusSessionRecord session) async {
    if (!_ensureInitialized()) return false;

    try {
      return await _runtimeCacheLock.synchronized(() async {
        final dateKey = _formatDateKey(session.date);

        _focusCacheByDate.putIfAbsent(dateKey, () => []);
        final sessions = _focusCacheByDate[dateKey]!;
        sessions.add(session);

        // Mark as dirty
        final index = sessions.length - 1;
        _dirtyFocusKeys.add('$dateKey$_dirtyKeySeparator$index');
        _markDirty();

        notifyListeners();
        return true;
      });
    } catch (e) {
      _lastError = "Error recording focus session: $e";
      debugPrint(_lastError);
      return false;
    }
  }

  /// Get focus sessions - O(1) lookup with date-indexed cache
  List<FocusSessionRecord> getFocusSessions(DateTime date) {
    if (!_ensureInitialized()) return [];

    try {
      final dateKey = _formatDateKey(date);

      // Check cache first (should have everything from last year)
      final cached = _focusCacheByDate[dateKey];
      if (cached != null) {
        return List.from(cached);
      }

      // Check Hive for old sessions not in cache
      final List<FocusSessionRecord> result = [];
      if (_focusBox != null) {
        for (final key in _focusBox!.keys) {
          if (key.toString().startsWith(dateKey)) {
            final session = _focusBox!.get(key);
            if (session != null) {
              result.add(session);
            }
          }
        }
      }

      return result;
    } catch (e) {
      _lastError = "Error getting focus sessions for : $e";
      debugPrint(_lastError);
      return [];
    }
  }

  List<FocusSessionRecord> getFocusSessionsRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    if (!_ensureInitialized()) return [];

    try {
      final List<FocusSessionRecord> result = [];
      DateTime currentDate =
          DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime endOfRange =
          DateTime(endDate.year, endDate.month, endDate.day);

      while (!currentDate.isAfter(endOfRange)) {
        result.addAll(getFocusSessions(currentDate));
        currentDate = currentDate.add(const Duration(days: 1));
      }

      return result;
    } catch (e) {
      _lastError = "Error getting focus sessions range: $e";
      debugPrint(_lastError);
      return [];
    }
  }

  Future<bool> deleteFocusSession(DateTime date, int sessionIndex) async {
    if (!_ensureInitialized()) return false;

    try {
      return await _runtimeCacheLock.synchronized(() async {
        final dateKey = _formatDateKey(date);
        final sessions = _focusCacheByDate[dateKey];

        if (sessions != null && sessionIndex < sessions.length) {
          final session = sessions.removeAt(sessionIndex);

          // Remove from Hive
          final hiveKey = _makeFocusKey(
              session.date, session.startTime.millisecondsSinceEpoch);
          if (_focusBox!.containsKey(hiveKey)) {
            _focusBox!.delete(hiveKey).catchError((e) {
              debugPrint('⚠️ Error deleting focus session from Hive: $e');
            });
          }

          notifyListeners();
          return true;
        }
        return false;
      });
    } catch (e) {
      _lastError = "Error deleting focus session: $e";
      debugPrint(_lastError);
      return false;
    }
  }

  // ============================================================
  // ANALYTICS & DERIVED DATA
  // ============================================================

  Duration getTotalScreenTime(DateTime date) {
    if (!_ensureInitialized()) return Duration.zero;

    try {
      final dateKey = _formatDateKey(date);
      final dayRecords = _usageCacheByDate[dateKey];

      if (dayRecords != null) {
        // Fast path: sum from cache — exclude web:* (browser domains tracked
        // separately in the Browser section, must not inflate native totals)
        return dayRecords.entries.fold(
          Duration.zero,
          (sum, e) => e.key.startsWith('web:') ? sum : sum + e.value.timeSpent,
        );
      }

      // Slow path: check Hive
      Duration total = Duration.zero;
      if (_usageBox != null) {
        for (final appName in allAppNames) {
          if (appName.startsWith('web:')) continue; // browser-only — skip
          final record = getAppUsage(appName, date);
          if (record != null) {
            total += record.timeSpent;
          }
        }
      }

      return total;
    } catch (e) {
      _lastError = "Error calculating total screen time: $e";
      debugPrint(_lastError);
      return Duration.zero;
    }
  }

  /// Get total screen time for range - OPTIMIZED
  Duration getTotalScreenTimeRange(DateTime startDate, DateTime endDate) {
    if (!_ensureInitialized()) return Duration.zero;

    try {
      Duration total = Duration.zero;
      final DateTime start =
          DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime end = DateTime(endDate.year, endDate.month, endDate.day);

      // Fast path: scan cache
      for (var dateEntry in _usageCacheByDate.entries) {
        final date = _parseDate(dateEntry.key);
        if (date != null && !date.isBefore(start) && !date.isAfter(end)) {
          for (var record in dateEntry.value.values) {
            total += record.timeSpent;
          }
        }
      }

      // Check Hive for missing dates
      DateTime current = start;
      while (!current.isAfter(end)) {
        final dateKey = _formatDateKey(current);
        if (!_usageCacheByDate.containsKey(dateKey)) {
          total += getTotalScreenTime(current);
        }
        current = current.add(Duration(days: 1));
      }

      return total;
    } catch (e) {
      _lastError = "Error calculating total screen time range: $e";
      debugPrint(_lastError);
      return Duration.zero;
    }
  }

  Duration getProductiveTime(DateTime date) {
    if (!_ensureInitialized()) return Duration.zero;

    try {
      final dateKey = _formatDateKey(date);
      final dayRecords = _usageCacheByDate[dateKey];

      Duration total = Duration.zero;

      if (dayRecords != null) {
        for (var entry in dayRecords.entries) {
          if (entry.key.startsWith('web:')) continue; // browser-only — skip
          final metadata = _metadataCache[entry.key];
          if (metadata?.isProductive ?? false) {
            total += entry.value.timeSpent;
          }
        }
      } else if (_usageBox != null) {
        // Fallback to Hive
        for (final appName in allAppNames) {
          if (appName.startsWith('web:')) continue; // browser-only — skip
          final metadata = _metadataCache[appName];
          if (metadata?.isProductive ?? false) {
            final record = getAppUsage(appName, date);
            if (record != null) {
              total += record.timeSpent;
            }
          }
        }
      }

      return total;
    } catch (e) {
      _lastError = "Error calculating productive time: $e";
      debugPrint(_lastError);
      return Duration.zero;
    }
  }

  String getMostUsedApp(DateTime date) {
    if (!_ensureInitialized()) return "None";

    try {
      final dateKey = _formatDateKey(date);
      final dayRecords = _usageCacheByDate[dateKey];

      String mostUsed = "None";
      Duration maxTime = Duration.zero;

      if (dayRecords != null) {
        for (var entry in dayRecords.entries) {
          if (entry.key.startsWith('web:')) continue; // browser-only — skip
          if (entry.value.timeSpent > maxTime) {
            maxTime = entry.value.timeSpent;
            mostUsed = entry.key;
          }
        }
      } else if (_usageBox != null) {
        for (final appName in allAppNames) {
          if (appName.startsWith('web:')) continue; // browser-only — skip
          final record = getAppUsage(appName, date);
          if (record != null && record.timeSpent > maxTime) {
            maxTime = record.timeSpent;
            mostUsed = appName;
          }
        }
      }

      return mostUsed;
    } catch (e) {
      _lastError = "Error finding most used app: $e";
      debugPrint(_lastError);
      return "Error";
    }
  }

  int getFocusSessionsCount(DateTime date) {
    if (!_ensureInitialized()) return 0;

    try {
      return getFocusSessions(date)
          .where((session) => session.completed)
          .length;
    } catch (e) {
      _lastError = "Error counting focus sessions: $e";
      debugPrint(_lastError);
      return 0;
    }
  }

  Duration getTotalFocusTime(DateTime date) {
    if (!_ensureInitialized()) return Duration.zero;

    try {
      Duration total = Duration.zero;

      for (final session in getFocusSessions(date)) {
        if (session.completed) {
          total += session.focusTime;
        }
      }

      return total;
    } catch (e) {
      _lastError = "Error calculating total focus time: $e";
      debugPrint(_lastError);
      return Duration.zero;
    }
  }

  Map<String, Duration> getCategoryBreakdown(DateTime date) {
    if (!_ensureInitialized()) return {};

    try {
      final Map<String, Duration> result = {};
      final dateKey = _formatDateKey(date);
      final dayRecords = _usageCacheByDate[dateKey];

      if (dayRecords != null) {
        for (var entry in dayRecords.entries) {
          if (entry.key.startsWith('web:')) continue; // browser-only — skip
          final metadata = _metadataCache[entry.key];
          if (metadata != null) {
            final category = metadata.category;
            result[category] =
                (result[category] ?? Duration.zero) + entry.value.timeSpent;
          }
        }
      } else if (_usageBox != null) {
        for (final appName in allAppNames) {
          if (appName.startsWith('web:')) continue; // browser-only — skip
          final metadata = _metadataCache[appName];
          final record = getAppUsage(appName, date);

          if (metadata != null && record != null) {
            final category = metadata.category;
            result[category] =
                (result[category] ?? Duration.zero) + record.timeSpent;
          }
        }
      }

      return result;
    } catch (e) {
      _lastError = "Error calculating category breakdown: $e";
      debugPrint(_lastError);
      return {};
    }
  }

  /// Get category breakdown for range - HIGHLY OPTIMIZED
  Map<String, Duration> getCategoryBreakdownRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    if (!_ensureInitialized()) return {};

    try {
      final Map<String, Duration> aggregated = {};
      final DateTime start =
          DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime end = DateTime(endDate.year, endDate.month, endDate.day);

      // Fast path: scan cache
      for (var dateEntry in _usageCacheByDate.entries) {
        final date = _parseDate(dateEntry.key);
        if (date != null && !date.isBefore(start) && !date.isAfter(end)) {
          for (var appEntry in dateEntry.value.entries) {
            if (appEntry.key.startsWith('web:')) continue; // browser-only — skip
            final metadata = _metadataCache[appEntry.key];
            if (metadata != null) {
              aggregated[metadata.category] =
                  (aggregated[metadata.category] ?? Duration.zero) +
                      appEntry.value.timeSpent;
            }
          }
        }
      }

      // Check Hive for missing dates
      DateTime current = start;
      while (!current.isAfter(end)) {
        final dateKey = _formatDateKey(current);
        if (!_usageCacheByDate.containsKey(dateKey)) {
          final dayBreakdown = getCategoryBreakdown(current);
          for (final entry in dayBreakdown.entries) {
            aggregated[entry.key] =
                (aggregated[entry.key] ?? Duration.zero) + entry.value;
          }
        }
        current = current.add(Duration(days: 1));
      }

      return aggregated;
    } catch (e) {
      _lastError = "Error calculating category breakdown range: $e";
      debugPrint(_lastError);
      return {};
    }
  }

  /// Get top N apps for date range - HIGHLY OPTIMIZED
  List<MapEntry<String, Duration>> getTopAppsRange(
    DateTime startDate,
    DateTime endDate, {
    int limit = 10,
  }) {
    if (!_ensureInitialized()) return [];

    try {
      // Use optimized batch method
      final appTotals = getAppUsageTotals(startDate, endDate);

      final sorted = appTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted.take(limit).toList();
    } catch (e) {
      _lastError = "Error getting top apps range: $e";
      debugPrint(_lastError);
      return [];
    }
  }

  double getProductivityScore(DateTime date) {
    if (!_ensureInitialized()) return 0.0;

    try {
      final total = getTotalScreenTime(date);
      final productive = getProductiveTime(date);
      final sessions = getFocusSessionsCount(date);

      if (total.inMinutes < 10) {
        return 0.0;
      }

      final productiveRatio = productive.inSeconds / total.inSeconds;
      final sessionBonus = (sessions * 0.5).clamp(0.0, 10.0);
      final rawScore = (productiveRatio * 80) + sessionBonus;

      return rawScore.clamp(0.0, 100.0);
    } catch (e) {
      _lastError = "Error calculating productivity score: $e";
      debugPrint(_lastError);
      return 0.0;
    }
  }

  Duration getAverageScreenTime(DateTime startDate, DateTime endDate) {
    if (!_ensureInitialized()) return Duration.zero;

    try {
      int totalSeconds = 0;
      int daysWithData = 0;

      DateTime current =
          DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime end = DateTime(endDate.year, endDate.month, endDate.day);

      while (!current.isAfter(end)) {
        final Duration dayTotal = getTotalScreenTime(current);

        if (dayTotal.inSeconds > 0) {
          totalSeconds += dayTotal.inSeconds;
          daysWithData++;
        }

        current = current.add(const Duration(days: 1));
      }

      if (daysWithData == 0) {
        return Duration.zero;
      }

      return Duration(seconds: totalSeconds ~/ daysWithData);
    } catch (e) {
      _lastError = "Error calculating average screen time: $e";
      debugPrint(_lastError);
      return Duration.zero;
    }
  }

  double getFocusTrend(DateTime currentWeekStart, DateTime previousWeekStart) {
    if (!_ensureInitialized()) return 0.0;

    try {
      final DateTime currentWeekEnd =
          currentWeekStart.add(const Duration(days: 6));
      final DateTime previousWeekEnd =
          previousWeekStart.add(const Duration(days: 6));

      final Duration currentWeekFocus =
          getFocusSessionsRange(currentWeekStart, currentWeekEnd)
              .where((session) => session.completed)
              .fold(Duration.zero, (sum, session) => sum + session.focusTime);

      final Duration previousWeekFocus =
          getFocusSessionsRange(previousWeekStart, previousWeekEnd)
              .where((session) => session.completed)
              .fold(Duration.zero, (sum, session) => sum + session.focusTime);

      if (previousWeekFocus.inSeconds == 0) return 0.0;

      return (currentWeekFocus.inSeconds - previousWeekFocus.inSeconds) /
          previousWeekFocus.inSeconds *
          100;
    } catch (e) {
      _lastError = "Error calculating focus trend: $e";
      debugPrint(_lastError);
      return 0.0;
    }
  }

  String _formatDateKey(DateTime date) {
    // Cache date strings to avoid repeated formatting
    return _dateStringCache.putIfAbsent(date, () {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    });
  }

  DateTime? _parseDate(String dateKey) {
    try {
      final parts = dateKey.split('-');
      if (parts.length != 3) return null;
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // CLEAR ALL DATA
  // ============================================================

  /// Clears only the web (browser extension) usage and metadata boxes.
  /// Called remotely via POST /clear-web-data when the extension clears its data.
  Future<void> clearWebData() async {
    await _initLock.synchronized(() async {
      if (!_ensureInitialized()) return;
      await _runtimeCacheLock.synchronized(() async {
        for (final dateMap in _usageCacheByDate.values) {
          dateMap.removeWhere((key, _) => key.startsWith('web:'));
        }
        _metadataCache.removeWhere((key, _) => key.startsWith('web:'));
        _dirtyUsageKeys.removeWhere((key) => key.contains('web:'));
        _cachedAppNames = null;
      });
      if (_webUsageBox != null && _webUsageBox!.isOpen) await _webUsageBox!.close();
      if (_webMetadataBox != null && _webMetadataBox!.isOpen) await _webMetadataBox!.close();
      await Hive.deleteBoxFromDisk(_webUsageBoxName);
      await Hive.deleteBoxFromDisk(_webMetadataBoxName);
      _webUsageBox = await _openBoxWithRetry<AppUsageRecord>(_webUsageBoxName);
      _webMetadataBox = await _openBoxWithRetry<AppMetadata>(_webMetadataBoxName);
      debugPrint('✅ Web data cleared');
      notifyListeners();
    });
  }

  Future<bool> clearAllData({Function(double)? progressCallback}) async {
    return await _initLock.synchronized(() async {
      if (!_ensureInitialized()) return false;

      try {
        debugPrint('🗑️ Clearing all data...');

        if (progressCallback != null) progressCallback(0.1);

        await _runtimeCacheLock.synchronized(() async {
          _usageCacheByDate.clear();
          _focusCacheByDate.clear();
          _metadataCache.clear();
          _cachedAppNames = null;
          _dateStringCache.clear();
          _dirtyUsageKeys.clear();
          _dirtyFocusKeys.clear();
          _hasDirtyData = false;
        });

        if (progressCallback != null) progressCallback(0.2);

        if (_usageBox != null && _usageBox!.isOpen) await _usageBox!.close();
        if (_focusBox != null && _focusBox!.isOpen) await _focusBox!.close();
        if (_metadataBox != null && _metadataBox!.isOpen)
          await _metadataBox!.close();
        if (_webUsageBox != null && _webUsageBox!.isOpen) await _webUsageBox!.close();
        if (_webMetadataBox != null && _webMetadataBox!.isOpen)
          await _webMetadataBox!.close();

        if (progressCallback != null) progressCallback(0.4);

        await Hive.deleteBoxFromDisk(_usageBoxName);
        if (progressCallback != null) progressCallback(0.6);

        await Hive.deleteBoxFromDisk(_focusBoxName);
        if (progressCallback != null) progressCallback(0.8);

        await Hive.deleteBoxFromDisk(_metadataBoxName);
        await Hive.deleteBoxFromDisk(_webUsageBoxName);
        await Hive.deleteBoxFromDisk(_webMetadataBoxName);
        if (progressCallback != null) progressCallback(0.9);

        _usageBox = await _openBoxWithRetry<AppUsageRecord>(_usageBoxName);
        _focusBox = await _openBoxWithRetry<FocusSessionRecord>(_focusBoxName);
        _metadataBox = await _openBoxWithRetry<AppMetadata>(_metadataBoxName);
        _webUsageBox = await _openBoxWithRetry<AppUsageRecord>(_webUsageBoxName);
        _webMetadataBox = await _openBoxWithRetry<AppMetadata>(_webMetadataBoxName);

        if (progressCallback != null) progressCallback(1.0);

        debugPrint('✅ All data cleared successfully');
        notifyListeners();
        return true;
      } catch (e) {
        _lastError = "Error clearing data: $e";
        debugPrint(_lastError);
        return false;
      }
    });
  }

  // ============================================================
  // CLOSE & DISPOSE
  // ============================================================

  Future<void> closeHive() async {
    return await _initLock.synchronized(() async {
      try {
        await forceCommitToHive();

        _persistenceTimer?.cancel();
        _persistenceTimer = null;

        if (_usageBox != null && _usageBox!.isOpen) await _usageBox!.close();
        if (_focusBox != null && _focusBox!.isOpen) await _focusBox!.close();
        if (_metadataBox != null && _metadataBox!.isOpen)
          await _metadataBox!.close();
        if (_webUsageBox != null && _webUsageBox!.isOpen) await _webUsageBox!.close();
        if (_webMetadataBox != null && _webMetadataBox!.isOpen)
          await _webMetadataBox!.close();

        await Hive.close();
        _isInitialized = false;
      } catch (e) {
        _lastError = "Error closing Hive: $e";
        debugPrint(_lastError);
      }
    });
  }

  @override
  Future<void> dispose() async {
    await _initLock.synchronized(() async {
      try {
        await forceCommitToHive();

        _persistenceTimer?.cancel();
        _persistenceTimer = null;

        if (_usageBox != null && _usageBox!.isOpen) await _usageBox!.close();
        if (_focusBox != null && _focusBox!.isOpen) await _focusBox!.close();
        if (_metadataBox != null && _metadataBox!.isOpen)
          await _metadataBox!.close();
        if (_webUsageBox != null && _webUsageBox!.isOpen) await _webUsageBox!.close();
        if (_webMetadataBox != null && _webMetadataBox!.isOpen)
          await _webMetadataBox!.close();

        _isInitialized = false;
      } catch (e) {
        debugPrint("Error closing Hive boxes: $e");
      }
    });

    super.dispose();
  }

  void handleAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      debugPrint("App going to background, committing data to Hive");
      forceCommitToHive();
    } else if (state == AppLifecycleState.resumed) {
      debugPrint("App resumed, checking database health");
      checkAndRepairBoxes();
    }
  }

  // ============================================================
  // DEBUG INFO
  // ============================================================

  Map<String, dynamic> getRuntimeCacheStats() {
    final totalUsageRecords =
        _usageCacheByDate.values.fold(0, (sum, map) => sum + map.length);
    final totalFocusSessions =
        _focusCacheByDate.values.fold(0, (sum, list) => sum + list.length);

    return {
      'usageDatesInCache': _usageCacheByDate.length,
      'usageRecordsInCache': totalUsageRecords,
      'focusDatesInCache': _focusCacheByDate.length,
      'focusSessionsInCache': totalFocusSessions,
      'metadataInCache': _metadataCache.length,
      'dirtyUsageRecords': _dirtyUsageKeys.length,
      'dirtyFocusSessions': _dirtyFocusKeys.length,
      'hasDirtyData': _hasDirtyData,
      'persistenceIntervalSeconds': _persistenceInterval.inSeconds,
      'persistenceTimerActive': _persistenceTimer?.isActive ?? false,
      'usageCacheDays': _usageCacheDays,
      'focusCacheDays': _focusCacheDays,
      'maxUsageCacheSize': _maxUsageCacheSize,
      'dateStringsCached': _dateStringCache.length,
      'cachedAppNamesValid': _cachedAppNames != null,
    };
  }

  /// Get estimated memory usage in MB (more realistic calculations)
  double getEstimatedMemoryUsageMB() {
    final totalUsageRecords =
        _usageCacheByDate.values.fold(0, (sum, map) => sum + map.length);
    final totalFocusSessions =
        _focusCacheByDate.values.fold(0, (sum, list) => sum + list.length);

    // More realistic byte estimates (including Dart object overhead)
    final usageBytes = totalUsageRecords * 500; // ~500 bytes per record
    final focusBytes = totalFocusSessions * 200; // ~200 bytes per session
    final metadataBytes =
        _metadataCache.length * 100; // ~100 bytes per metadata
    final dateMapOverhead = _usageCacheByDate.length * 64; // Map overhead
    final focusMapOverhead = _focusCacheByDate.length * 64;
    final dateStringBytes = _dateStringCache.length * 24; // Small strings

    final totalBytes = usageBytes +
        focusBytes +
        metadataBytes +
        dateMapOverhead +
        focusMapOverhead +
        dateStringBytes;

    return totalBytes / (1024 * 1024);
  }

  // ============================================================
  // WEB STORAGE INTEGRATION
  // ============================================================

  Future<void> _initWebData() async {
    final now = DateTime.now();
    final List<String> keysToFetch = [];
    final List<DateTime> dates = [];
    
    for (int i = 0; i < 60; i++) {
      final d = now.subtract(Duration(days: i));
      final dateKey = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      keysToFetch.add('scolect_day_$dateKey');
      dates.add(DateTime(d.year, d.month, d.day));
    }
    
    keysToFetch.add('scolect_focus_sessions');
    keysToFetch.add('scolect_app_metadata');
    
    final result = await chromeStorageGet(keysToFetch);
    
    for (int i = 0; i < dates.length; i++) {
      final date = dates[i];
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final storageKey = 'scolect_day_$dateStr';
      final dayData = result[storageKey] as Map<dynamic, dynamic>? ?? {};
      final domains = (dayData['domains'] as List<dynamic>?) ?? [];
      
      final mapForDate = <String, AppUsageRecord>{};
      for (var d in domains) {
        final domain = d['domain'] as String? ?? 'unknown';
        final seconds = d['seconds'] as num? ?? 0;
        final visits = d['visits'] as num? ?? 0;
        
        mapForDate[domain] = AppUsageRecord(
          date: date,
          timeSpent: Duration(seconds: seconds.toInt()),
          openCount: visits.toInt(),
          usagePeriods: [],
        );
        
        if (!_metadataCache.containsKey(domain)) {
          _metadataCache[domain] = AppMetadata(
            category: 'Web',
            isProductive: true,
            isTracking: true,
            isVisible: true,
          );
        }
      }
      _usageCacheByDate[dateStr] = mapForDate;
    }
    
    final focusData = result['scolect_focus_sessions'] as List<dynamic>? ?? [];
    for (var f in focusData) {
      if (f is Map) {
        final fs = FocusSessionRecord(
          date: DateTime.fromMillisecondsSinceEpoch((f['date'] as num?)?.toInt() ?? 0),
          startTime: DateTime.fromMillisecondsSinceEpoch((f['startTime'] as num?)?.toInt() ?? 0),
          duration: Duration(seconds: (f['duration'] as num?)?.toInt() ?? 0),
          appsBlocked: (f['appsBlocked'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          completed: f['completed'] ?? true,
          breakCount: (f['breakCount'] as num?)?.toInt() ?? 0,
          totalBreakTime: Duration(seconds: (f['totalBreakTime'] as num?)?.toInt() ?? 0),
        );
        final dateStr = _formatDateKey(fs.date);
        _focusCacheByDate.putIfAbsent(dateStr, () => []).add(fs);
      }
    }
    
    final metaData = result['scolect_app_metadata'] as Map<dynamic, dynamic>? ?? {};
    for (var entry in metaData.entries) {
      final domain = entry.key.toString();
      final val = entry.value as Map<dynamic, dynamic>;
      _metadataCache[domain] = AppMetadata(
        category: val['category'] ?? 'Web',
        isProductive: val['isProductive'] ?? true,
        isTracking: val['isTracking'] ?? true,
        isVisible: val['isVisible'] ?? true,
        dailyLimit: Duration(seconds: (val['dailyLimit'] as num?)?.toInt() ?? 0),
        limitStatus: val['limitStatus'] ?? false,
        siteName: val['siteName'] as String? ?? '',
      );
    }
    
    _cachedAppNames = null;
  }
}

// ============================================================
// HIVE TYPE ADAPTERS
// ============================================================

class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final int typeId = 5;

  @override
  Duration read(BinaryReader reader) {
    return Duration(microseconds: reader.readInt());
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    writer.writeInt(obj.inMicroseconds);
  }
}

class AppUsageRecordAdapter extends TypeAdapter<AppUsageRecord> {
  @override
  final int typeId = 1;

  @override
  AppUsageRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return AppUsageRecord(
      date: fields[0] as DateTime,
      timeSpent: fields[1] as Duration,
      openCount: fields[2] as int,
      usagePeriods: (fields[3] as List).cast<TimeRange>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppUsageRecord obj) {
    writer.writeByte(4);
    writer.writeByte(0);
    writer.write(obj.date);
    writer.writeByte(1);
    writer.write(obj.timeSpent);
    writer.writeByte(2);
    writer.write(obj.openCount);
    writer.writeByte(3);
    writer.write(obj.usagePeriods);
  }
}

class TimeRangeAdapter extends TypeAdapter<TimeRange> {
  @override
  final int typeId = 2;

  @override
  TimeRange read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return TimeRange(
      startTime: fields[0] as DateTime,
      endTime: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TimeRange obj) {
    writer.writeByte(2);
    writer.writeByte(0);
    writer.write(obj.startTime);
    writer.writeByte(1);
    writer.write(obj.endTime);
  }
}

class FocusSessionRecordAdapter extends TypeAdapter<FocusSessionRecord> {
  @override
  final int typeId = 3;

  @override
  FocusSessionRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return FocusSessionRecord(
      date: fields[0] as DateTime,
      startTime: fields[1] as DateTime,
      duration: fields[2] as Duration,
      appsBlocked: (fields[3] as List).cast<String>(),
      completed: fields[4] as bool,
      breakCount: fields[5] as int,
      totalBreakTime: fields[6] as Duration,
    );
  }

  @override
  void write(BinaryWriter writer, FocusSessionRecord obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.date);
    writer.writeByte(1);
    writer.write(obj.startTime);
    writer.writeByte(2);
    writer.write(obj.duration);
    writer.writeByte(3);
    writer.write(obj.appsBlocked);
    writer.writeByte(4);
    writer.write(obj.completed);
    writer.writeByte(5);
    writer.write(obj.breakCount);
    writer.writeByte(6);
    writer.write(obj.totalBreakTime);
  }
}

class AppMetadataAdapter extends TypeAdapter<AppMetadata> {
  @override
  final int typeId = 4;

  @override
  AppMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return AppMetadata(
      category: fields[0] as String,
      isProductive: fields[1] as bool,
      isTracking: fields[2] as bool,
      isVisible: fields[3] as bool,
      dailyLimit: fields[4] as Duration,
      limitStatus: fields[5] as bool,
      siteName: fields.containsKey(6) ? (fields[6] as String? ?? '') : '',
      isPrivate: fields.containsKey(7) ? (fields[7] as bool? ?? false) : false,
      displayName: fields.containsKey(8) ? (fields[8] as String? ?? '') : '',
    );
  }

  @override
  void write(BinaryWriter writer, AppMetadata obj) {
    writer.writeByte(9);
    writer.writeByte(0);
    writer.write(obj.category);
    writer.writeByte(1);
    writer.write(obj.isProductive);
    writer.writeByte(2);
    writer.write(obj.isTracking);
    writer.writeByte(3);
    writer.write(obj.isVisible);
    writer.writeByte(4);
    writer.write(obj.dailyLimit);
    writer.writeByte(5);
    writer.write(obj.limitStatus);
    writer.writeByte(6);
    writer.write(obj.siteName);
    writer.writeByte(7);
    writer.write(obj.isPrivate);
    writer.writeByte(8);
    writer.write(obj.displayName);
  }
}

class BrowserSourceAdapter extends TypeAdapter<BrowserSource> {
  @override
  final int typeId = 6;

  @override
  BrowserSource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return BrowserSource(
      id: fields[0] as String,
      detectedBrowser: fields[1] as String,
      firstSeen: fields[2] as DateTime,
      lastSeen: fields[3] as DateTime,
      displayName: fields.containsKey(4) ? (fields[4] as String? ?? '') : '',
      sourceIndex: fields.containsKey(5) ? (fields[5] as int? ?? 0) : 0,
      nameUpdatedAt: fields.containsKey(6) ? (fields[6] as int? ?? 0) : 0,
    );
  }

  @override
  void write(BinaryWriter writer, BrowserSource obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.detectedBrowser);
    writer.writeByte(2);
    writer.write(obj.firstSeen);
    writer.writeByte(3);
    writer.write(obj.lastSeen);
    writer.writeByte(4);
    writer.write(obj.displayName);
    writer.writeByte(5);
    writer.write(obj.sourceIndex);
    writer.writeByte(6);
    writer.write(obj.nameUpdatedAt);
  }
}
