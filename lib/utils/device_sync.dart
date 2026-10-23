import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/utils/device_snapshot.dart';

/// Shares this device's usage through a folder that something else (Dropbox,
/// iCloud Drive, Syncthing…) keeps in sync, and reads the other devices' files.
///
/// Every device writes only its own `<deviceId>.json`, so the folder never has
/// two writers and there are no conflicts. Other devices' data is read-only: it
/// is never merged into the local store, only shown by Insights.
class DeviceSync extends ChangeNotifier {
  DeviceSync({
    AppDataStore? store,
    DateTime Function()? now,
    Duration interval = const Duration(minutes: 2),
    @visibleForTesting String? idOverride,
    @visibleForTesting String? nameOverride,
    @visibleForTesting String? folderOverride,
    @visibleForTesting
    DeviceSnapshot Function(String id, String name, DateTime now)? snapshotSource,
  })  : _store = store,
        _now = now ?? DateTime.now,
        _interval = interval,
        _idOverride = idOverride,
        _nameOverride = nameOverride,
        _folderOverride = folderOverride,
        _snapshotSource = snapshotSource;

  static final DeviceSync instance = DeviceSync();

  static const String folderName = 'Scolect Sync';
  static final RegExp _fileName = RegExp(r'^([a-f0-9]{32})\.json$');

  final AppDataStore? _store;
  final DateTime Function() _now;
  final Duration _interval;
  final String? _idOverride;
  final String? _nameOverride;
  final String? _folderOverride;
  final DeviceSnapshot Function(String id, String name, DateTime now)? _snapshotSource;
  Timer? _timer;
  bool _syncing = false;

  List<DeviceSnapshot> _peers = const [];
  DateTime? _lastSyncedAt;
  String? _lastError;
  String? _lastWrittenContent;

  AppDataStore get _dataStore => _store ?? AppDataStore();
  SettingsManager get _settings => SettingsManager();

  List<DeviceSnapshot> get peers => _peers;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  String? get lastError => _lastError;

  bool get enabled => _settings.getSetting('deviceSync.enabled') == true;
  String get folder =>
      _folderOverride ?? (_settings.getSetting('deviceSync.folder') as String?) ?? '';
  bool get isActive => _timer != null;

  /// Stable id for this install, created on first use.
  String get deviceId {
    final fixedId = _idOverride;
    if (fixedId != null) return fixedId;
    var id = (_settings.getSetting('deviceSync.deviceId') as String?) ?? '';
    if (!DeviceSnapshot.idPattern.hasMatch(id)) {
      final rng = Random.secure();
      id = List.generate(16, (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
      _settings.updateSetting('deviceSync.deviceId', id);
    }
    return id;
  }

  String get deviceName {
    final fixedName = _nameOverride;
    if (fixedName != null) return fixedName;
    final custom = ((_settings.getSetting('deviceSync.deviceName') as String?) ?? '').trim();
    if (custom.isNotEmpty) return custom;
    try {
      return Platform.localHostname;
    } catch (_) {
      return 'This device';
    }
  }

  Directory? _syncDir() {
    final f = folder.trim();
    return f.isEmpty ? null : Directory('$f${Platform.pathSeparator}$folderName');
  }

  // ─── Lifecycle ───────────────────────────────────────────────────────────

  /// Starts periodic syncing if it is enabled and a folder is chosen.
  Future<void> start() async {
    await stop();
    if (!enabled || folder.trim().isEmpty) return;
    _timer = Timer.periodic(_interval, (_) => syncOnce());
    await syncOnce();
    notifyListeners();
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }

  /// Syncs now unless it already did within [maxAge]. Called when a screen
  /// that shows other devices opens, so it isn't stuck on the last timer tick.
  /// Never throws.
  Future<void> refreshIfStale({Duration maxAge = const Duration(minutes: 1)}) async {
    try {
      if (!enabled || folder.trim().isEmpty) return;
      final last = _lastSyncedAt;
      if (last != null && _now().difference(last) < maxAge) return;
      await syncOnce();
    } catch (_) {}
  }

  Future<void> setEnabled(bool value) async {
    _settings.updateSetting('deviceSync.enabled', value);
    if (value) {
      await start();
    } else {
      await stop();
      _peers = const [];
      notifyListeners();
    }
  }

  Future<void> setFolder(String path) async {
    _settings.updateSetting('deviceSync.folder', path);
    _lastWrittenContent = null;
    _peers = const [];
    await start();
    notifyListeners();
  }

  void setDeviceName(String name) {
    _settings.updateSetting('deviceSync.deviceName', name.trim());
    _lastWrittenContent = null;
    notifyListeners();
  }

  // ─── Sync pass ───────────────────────────────────────────────────────────

  /// Writes our snapshot (if it changed) and reloads the other devices'.
  /// Returns true on success; failures are recorded in [lastError].
  Future<bool> syncOnce() async {
    if (_syncing) return true;
    _syncing = true;
    try {
      final dir = _syncDir();
      if (dir == null) return false;
      if (_snapshotSource == null && !_dataStore.isInitialized) return false;
      await dir.create(recursive: true);

      await _writeOwn(dir);
      _peers = await _readPeers(dir);
      _lastSyncedAt = _now();
      _lastError = null;
      return true;
    } catch (e) {
      _lastError = '$e';
      debugPrint('⚠️ Device sync failed: $e');
      return false;
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  Future<void> _writeOwn(Directory dir) async {
    final source = _snapshotSource;
    final snapshot = source != null
        ? source(deviceId, deviceName, _now())
        : DeviceSnapshot.build(
            _dataStore,
            deviceId: deviceId,
            deviceName: deviceName,
            now: _now(),
          );
    final content = snapshot.contentJson();
    if (content == _lastWrittenContent) return;

    // Write to a temp name and rename, so a sync client never uploads (and a
    // peer never reads) a half-written file.
    final target = File('${dir.path}${Platform.pathSeparator}${snapshot.deviceId}.json');
    final temp = File('${target.path}.tmp');
    await temp.writeAsString(snapshot.toJson(), flush: true);
    await temp.rename(target.path);
    _lastWrittenContent = content;
  }

  Future<List<DeviceSnapshot>> _readPeers(Directory dir) async {
    final own = deviceId;
    final peers = <DeviceSnapshot>[];
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      final match = _fileName.firstMatch(name);
      if (match == null || match.group(1) == own) continue;
      try {
        if (await entity.length() > DeviceSnapshot.maxBytes) continue;
        final snap = DeviceSnapshot.parse(await entity.readAsString());
        // The file name must agree with the id inside, or it is not trusted.
        if (snap != null && snap.deviceId == match.group(1)) peers.add(snap);
      } catch (_) {
        // A file mid-upload or unreadable: pick it up on the next pass.
      }
    }
    peers.sort((a, b) => a.deviceName.compareTo(b.deviceName));
    return peers;
  }

  /// Deletes this device's file from the folder, e.g. when turning sync off.
  Future<void> removeOwnFile() async {
    final dir = _syncDir();
    if (dir == null) return;
    final f = File('${dir.path}${Platform.pathSeparator}$deviceId.json');
    if (await f.exists()) await f.delete();
    _lastWrittenContent = null;
  }

  @visibleForTesting
  Future<void> resetForTesting() async {
    await stop();
    _peers = const [];
    _lastSyncedAt = null;
    _lastError = null;
    _lastWrittenContent = null;
  }
}
