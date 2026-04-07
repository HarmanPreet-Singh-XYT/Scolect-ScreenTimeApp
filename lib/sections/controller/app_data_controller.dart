import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:synchronized/synchronized.dart';

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

  AppMetadata({
    required this.category,
    required this.isProductive,
    this.isTracking = true,
    this.isVisible = true,
    this.dailyLimit = Duration.zero,
    this.limitStatus = false,
  });
}

class AppDataStore extends ChangeNotifier {
  static final AppDataStore _instance = AppDataStore._internal();
  static const String _usageBoxName = 'harman_screentime_app_usage_box';
  static const String _focusBoxName = 'harman_screentime_focus_session_box';
  static const String _metadataBoxName = 'harman_screentime_app_metadata_box';

  Box<AppUsageRecord>? _usageBox;
  Box<FocusSessionRecord>? _focusBox;
  Box<AppMetadata>? _metadataBox;

  bool _isInitialized = false;
  String? _lastError;
  DateTime? _lastMaintenanceDate;

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
        // Platform-specific initialization
        String hivePath;

        if (Platform.isMacOS || Platform.isWindows) {
          final docsDir = await getApplicationDocumentsDirectory();
          final newHivePath = '${docsDir.path}/Scolect';
          final newDir = Directory(newHivePath);

          // Migration logic
          String? oldHivePath;
          if (Platform.isMacOS) {
            final supportDir = await getApplicationSupportDirectory();
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
                  final boxNames = [_usageBoxName, _focusBoxName, _metadataBoxName];
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

          if (!await Directory(hivePath).exists()) {
            await Directory(hivePath).create(recursive: true);
          }
          Hive.init(hivePath);
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

        // Open boxes
        _usageBox = await _openBoxWithRetry<AppUsageRecord>(_usageBoxName);
        _focusBox = await _openBoxWithRetry<FocusSessionRecord>(_focusBoxName);
        _metadataBox = await _openBoxWithRetry<AppMetadata>(_metadataBoxName);

        if (_usageBox == null || _focusBox == null || _metadataBox == null) {
          _lastError = "Failed to open one or more Hive boxes";
          return false;
        }

        // Load optimized cache
        await _loadOptimizedRuntimeCache();

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
            final parts = key.split('::');
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

          await _usageBox!.putAll(batch);
          usageCommitted = batch.length;
          _dirtyUsageKeys.clear();
        }

        if (_dirtyFocusKeys.isNotEmpty && _focusBox != null) {
          final batch = <String, FocusSessionRecord>{};

          for (var key in _dirtyFocusKeys) {
            final parts = key.split('::');
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

        if (e.toString().contains('corrupted') ||
            e.toString().contains('not found') ||
            e.toString().contains('lock') ||
            e.toString().contains('permission')) {
          try {
            debugPrint("Attempting to delete and recreate box: $boxName");
            try {
              final box = Hive.box(boxName);
              if (box.isOpen) await box.close();
            } catch (_) {}
            await Hive.deleteBoxFromDisk(boxName);
            debugPrint("Deleted corrupted box: $boxName, retrying...");
          } catch (deleteError) {
            debugPrint("Error deleting box: $deleteError");
          }
        }

        await Future.delayed(Duration(milliseconds: 200 * (1 << attempts)));
      }
    }

    return null;
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
      ]) {
        final String boxName = boxInfo['name'] as String;
        final Box? box = boxInfo['box'] as Box?;
        final Lock lock = boxInfo['lock'] as Lock;

        await lock.synchronized(() async {
          try {
            if (box != null && box.isOpen) {
              try {
                box.keys.take(1).toList();
                debugPrint("Box $boxName is healthy");
              } catch (e) {
                debugPrint("Box $boxName is corrupted, repairing: $e");

                try {
                  await box.close();
                } catch (_) {}

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
    if (!_isInitialized ||
        _usageBox == null ||
        _focusBox == null ||
        _metadataBox == null) {
      _lastError = "AppDataStore not initialized. Call init() first.";
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
  }) async {
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
      );

      _metadataCache[appName] = updated;

      // Invalidate cached app names list
      _cachedAppNames = null;

      _metadataBox!.put(appName, updated).catchError((e) {
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

  AppMetadata? getAppMetadata(String appName) {
    if (!_ensureInitialized()) return null;
    try {
      return _metadataCache[appName];
    } catch (e) {
      _lastError = "Error getting metadata for $appName: $e";
      debugPrint(_lastError);
      return null;
    }
  }

  Future<bool> deleteAppMetadata(String appName) async {
    if (!_ensureInitialized()) return false;

    try {
      _metadataCache.remove(appName);

      // Invalidate cached app names list
      _cachedAppNames = null;

      if (_metadataBox!.containsKey(appName)) {
        _metadataBox!.delete(appName).catchError((e) {
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
        _dirtyUsageKeys.add('$dateKey::$appName');
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
      if (_usageBox != null) {
        final hiveKey = _makeUsageKey(appName, date);
        final record = _usageBox!.get(hiveKey);

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
      for (var dateEntry in _usageCacheByDate.entries) {
        final date = _parseDate(dateEntry.key);
        if (date != null && !date.isBefore(start) && !date.isAfter(end)) {
          for (var appEntry in dateEntry.value.entries) {
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
              final record = _usageBox!.get(hiveKey);
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
        _dirtyFocusKeys.add('$dateKey::$index');
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
        // Fast path: sum from cache
        return dayRecords.values.fold(
          Duration.zero,
          (sum, record) => sum + record.timeSpent,
        );
      }

      // Slow path: check Hive
      Duration total = Duration.zero;
      if (_usageBox != null) {
        for (final appName in allAppNames) {
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
          final metadata = _metadataCache[entry.key];
          if (metadata?.isProductive ?? false) {
            total += entry.value.timeSpent;
          }
        }
      } else if (_usageBox != null) {
        // Fallback to Hive
        for (final appName in allAppNames) {
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
          if (entry.value.timeSpent > maxTime) {
            maxTime = entry.value.timeSpent;
            mostUsed = entry.key;
          }
        }
      } else if (_usageBox != null) {
        for (final appName in allAppNames) {
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
          final metadata = _metadataCache[entry.key];
          if (metadata != null) {
            final category = metadata.category;
            result[category] =
                (result[category] ?? Duration.zero) + entry.value.timeSpent;
          }
        }
      } else if (_usageBox != null) {
        for (final appName in allAppNames) {
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

        if (progressCallback != null) progressCallback(0.4);

        await Hive.deleteBoxFromDisk(_usageBoxName);
        if (progressCallback != null) progressCallback(0.6);

        await Hive.deleteBoxFromDisk(_focusBoxName);
        if (progressCallback != null) progressCallback(0.8);

        await Hive.deleteBoxFromDisk(_metadataBoxName);
        if (progressCallback != null) progressCallback(0.9);

        _usageBox = await _openBoxWithRetry<AppUsageRecord>(_usageBoxName);
        _focusBox = await _openBoxWithRetry<FocusSessionRecord>(_focusBoxName);
        _metadataBox = await _openBoxWithRetry<AppMetadata>(_metadataBoxName);

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
    );
  }

  @override
  void write(BinaryWriter writer, AppMetadata obj) {
    writer.writeByte(6);
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
  }
}
