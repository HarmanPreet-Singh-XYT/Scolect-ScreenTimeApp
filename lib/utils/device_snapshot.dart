import 'dart:convert';

import 'package:screentime/sections/controller/app_data_controller.dart';

/// One app's time on one day, as shared between devices. Keyed by display name
/// rather than app id so the same app lines up across macOS and Windows.
class SnapshotApp {
  final String name;
  final String category;
  final int seconds;
  final Map<int, int> hourly;

  const SnapshotApp(this.name, this.category, this.seconds, this.hourly);
}

/// A device's own usage for the last [DeviceSnapshot.windowDays] days, written
/// to the shared folder for other devices to read. Never contains private
/// apps, websites or window titles.
class DeviceSnapshot {
  static const int version = 1;
  static const int windowDays = 90;

  // Limits applied when reading a file written by another machine.
  static const int maxBytes = 5 * 1024 * 1024;
  static const int maxDays = 120;
  static const int maxAppsPerDay = 500;
  static const int maxNameLength = 120;
  static final RegExp idPattern = RegExp(r'^[a-f0-9]{32}$');
  static final RegExp _dayPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  final String deviceId;
  final String deviceName;
  final DateTime updatedAt;
  final Map<String, List<SnapshotApp>> days;

  const DeviceSnapshot({
    required this.deviceId,
    required this.deviceName,
    required this.updatedAt,
    required this.days,
  });

  static String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime? parseDay(String key) {
    if (!_dayPattern.hasMatch(key)) return null;
    final p = key.split('-').map(int.parse).toList();
    final d = DateTime(p[0], p[1], p[2]);
    // Reject things like 2026-02-31 that DateTime would silently roll over.
    return dayKey(d) == key ? d : null;
  }

  List<SnapshotApp> appsOn(DateTime day) => days[dayKey(day)] ?? const [];

  Duration totalOn(DateTime day) =>
      Duration(seconds: appsOn(day).fold(0, (s, a) => s + a.seconds));

  /// Builds this device's snapshot from the local store.
  static DeviceSnapshot build(
    AppDataStore store, {
    required String deviceId,
    required String deviceName,
    required DateTime now,
    int days = windowDays,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: days - 1));
    final byDay = <String, Map<String, _Acc>>{};

    store.getAllAppUsageForRange(start, today).forEach((appId, records) {
      if (appId.startsWith('web:')) return;
      final meta = store.getAppMetadata(appId);
      if (meta?.isPrivate ?? false) return;
      final name = _clip(store.displayNameFor(appId));
      if (name.isEmpty) return;
      for (final r in records) {
        if (r.timeSpent <= Duration.zero) continue;
        final acc = byDay
            .putIfAbsent(dayKey(r.date), () => {})
            .putIfAbsent(name, () => _Acc(meta?.category ?? 'Uncategorized'));
        acc.seconds += r.timeSpent.inSeconds;
        r.effectiveHourlySeconds
            .forEach((h, s) => acc.hourly[h] = (acc.hourly[h] ?? 0) + s);
      }
    });

    return DeviceSnapshot(
      deviceId: deviceId,
      deviceName: _clip(deviceName),
      updatedAt: now,
      days: {
        for (final e in byDay.entries)
          e.key: [
            for (final a in e.value.entries)
              a.value.toApp(a.key)
          ]
      },
    );
  }

  static String _clip(String s) {
    final t = s.trim();
    return t.length > maxNameLength ? t.substring(0, maxNameLength) : t;
  }

  /// JSON without [updatedAt], for detecting whether anything changed.
  String contentJson() => jsonEncode(_body());

  Map<String, dynamic> _body() => {
        'version': version,
        'deviceId': deviceId,
        'deviceName': deviceName,
        'days': {
          for (final e in (days.entries.toList()..sort((a, b) => a.key.compareTo(b.key))))
            e.key: [
              for (final a in (e.value.toList()..sort((x, y) => x.name.compareTo(y.name))))
                {
                  'n': a.name,
                  'c': a.category,
                  's': a.seconds,
                  if (a.hourly.isNotEmpty)
                    'h': {
                      for (final h in (a.hourly.entries.toList()
                            ..sort((x, y) => x.key.compareTo(y.key))))
                        '${h.key}': h.value
                    },
                }
            ]
        },
      };

  String toJson() => jsonEncode({..._body(), 'updatedAt': updatedAt.millisecondsSinceEpoch});

  /// Parses a file from another machine. Returns null for anything malformed,
  /// oversized or out of range; never throws.
  static DeviceSnapshot? parse(String text) {
    try {
      if (text.length > maxBytes) return null;
      final json = jsonDecode(text);
      if (json is! Map || json['version'] != version) return null;
      final id = json['deviceId'];
      if (id is! String || !idPattern.hasMatch(id)) return null;
      final name = json['deviceName'];
      final updated = json['updatedAt'];
      final rawDays = json['days'];
      if (name is! String || updated is! num || rawDays is! Map) return null;
      if (rawDays.length > maxDays) return null;

      final days = <String, List<SnapshotApp>>{};
      for (final e in rawDays.entries) {
        final key = e.key;
        final list = e.value;
        if (key is! String || parseDay(key) == null || list is! List) return null;
        if (list.length > maxAppsPerDay) return null;
        final apps = <SnapshotApp>[];
        for (final a in list) {
          if (a is! Map) return null;
          final n = a['n'], c = a['c'], s = a['s'];
          if (n is! String || c is! String || s is! num) return null;
          if (n.isEmpty || n.length > maxNameLength || c.length > maxNameLength) return null;
          final secs = s.toInt();
          if (secs < 0 || secs > 86400) return null;
          final hourly = <int, int>{};
          final h = a['h'];
          if (h is Map) {
            for (final he in h.entries) {
              final hour = int.tryParse('${he.key}');
              final hs = he.value;
              if (hour == null || hour < 0 || hour > 23 || hs is! num) return null;
              final v = hs.toInt();
              if (v < 0 || v > 3600) return null;
              hourly[hour] = v;
            }
          }
          apps.add(SnapshotApp(n, c, secs, hourly));
        }
        days[key] = apps;
      }

      return DeviceSnapshot(
        deviceId: id,
        deviceName: name.length > maxNameLength ? name.substring(0, maxNameLength) : name,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(updated.toInt()),
        days: days,
      );
    } catch (_) {
      return null;
    }
  }
}

class _Acc {
  final String category;
  int seconds = 0;
  final Map<int, int> hourly = {};
  _Acc(this.category);

  /// Clamped to what [DeviceSnapshot.parse] accepts, so a glitchy local total
  /// can never make our own file unreadable to other devices.
  SnapshotApp toApp(String name) => SnapshotApp(
        name,
        category,
        seconds.clamp(0, 86400),
        {for (final h in hourly.entries) if (h.key >= 0 && h.key <= 23) h.key: h.value.clamp(0, 3600)},
      );
}
