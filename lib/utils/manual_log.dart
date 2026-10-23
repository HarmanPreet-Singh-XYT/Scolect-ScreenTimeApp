import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One block of time the user logged by hand or with the stopwatch.
class ManualEntry {
  final String id;
  final String label;
  final DateTime start;
  final int seconds;

  const ManualEntry({
    required this.id,
    required this.label,
    required this.start,
    required this.seconds,
  });

  Duration get duration => Duration(seconds: seconds);

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'start': start.millisecondsSinceEpoch,
        'seconds': seconds,
      };

  static ManualEntry? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'], label = raw['label'], start = raw['start'], secs = raw['seconds'];
    if (id is! String || label is! String || start is! num || secs is! num) {
      return null;
    }
    return ManualEntry(
      id: id,
      label: label,
      start: DateTime.fromMillisecondsSinceEpoch(start.toInt()),
      seconds: secs.toInt(),
    );
  }
}

class RunningStopwatch {
  final String label;
  final DateTime start;
  const RunningStopwatch(this.label, this.start);
}

/// Time the user logs themselves (meetings, reading, offline work), kept apart
/// from automatically tracked app time so it never double-counts. Persisted in
/// SharedPreferences, including a running stopwatch so it survives a restart.
class ManualLog extends ChangeNotifier {
  ManualLog({DateTime Function()? now}) : _now = now ?? DateTime.now;

  static final ManualLog instance = ManualLog();

  static const String _prefsKey = 'manual_log_v1';
  static const int maxEntries = 5000;
  static const int maxLabelLength = 60;
  static const Duration maxEntryDuration = Duration(hours: 24);

  final DateTime Function() _now;
  final List<ManualEntry> _entries = [];
  RunningStopwatch? _running;
  int _counter = 0;

  /// Newest first.
  List<ManualEntry> get entries => List.unmodifiable(_entries);
  RunningStopwatch? get running => _running;

  Duration get runningElapsed =>
      _running == null ? Duration.zero : _now().difference(_running!.start);

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static String cleanLabel(String label) {
    final t = label.trim().replaceAll(RegExp(r'\s+'), ' ');
    return t.length > maxLabelLength ? t.substring(0, maxLabelLength) : t;
  }

  String _newId() => '${_now().microsecondsSinceEpoch}-${_counter++}';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      _entries.clear();
      _running = null;
      if (raw == null) return;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _entries.addAll(((json['entries'] as List?) ?? [])
          .map(ManualEntry.fromJson)
          .whereType<ManualEntry>());
      _entries.sort((a, b) => b.start.compareTo(a.start));
      final r = json['running'];
      if (r is Map && r['label'] is String && r['start'] is num) {
        _running = RunningStopwatch(r['label'] as String,
            DateTime.fromMillisecondsSinceEpoch((r['start'] as num).toInt()));
      }
    } catch (e) {
      debugPrint('⚠️ ManualLog load failed: $e');
    }
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode({
          'entries': _entries.map((e) => e.toJson()).toList(),
          if (_running != null)
            'running': {
              'label': _running!.label,
              'start': _running!.start.millisecondsSinceEpoch,
            },
        }),
      );
    } catch (e) {
      debugPrint('⚠️ ManualLog save failed: $e');
    }
  }

  /// Starts the stopwatch. Returns false if one is already running or the
  /// label is empty.
  Future<bool> start(String label) async {
    final clean = cleanLabel(label);
    if (_running != null || clean.isEmpty) return false;
    _running = RunningStopwatch(clean, _now());
    await _save();
    notifyListeners();
    return true;
  }

  /// Stops the stopwatch and records the elapsed time (at least one second,
  /// at most [maxEntryDuration] in case it was left running).
  Future<ManualEntry?> stop() async {
    final r = _running;
    if (r == null) return null;
    var secs = _now().difference(r.start).inSeconds;
    if (secs < 1) secs = 1;
    if (secs > maxEntryDuration.inSeconds) secs = maxEntryDuration.inSeconds;
    _running = null;
    final entry = _insert(r.label, r.start, secs);
    await _save();
    notifyListeners();
    return entry;
  }

  /// Discards a running stopwatch without recording anything.
  Future<void> discardRunning() async {
    if (_running == null) return;
    _running = null;
    await _save();
    notifyListeners();
  }

  /// Logs time after the fact. Returns null for an empty label or a
  /// non-positive duration; durations are capped at [maxEntryDuration].
  Future<ManualEntry?> add(
      {required String label,
      required DateTime start,
      required Duration duration}) async {
    final clean = cleanLabel(label);
    if (clean.isEmpty || duration.inSeconds <= 0) return null;
    final secs = duration > maxEntryDuration
        ? maxEntryDuration.inSeconds
        : duration.inSeconds;
    final entry = _insert(clean, start, secs);
    await _save();
    notifyListeners();
    return entry;
  }

  ManualEntry _insert(String label, DateTime start, int seconds) {
    final entry =
        ManualEntry(id: _newId(), label: label, start: start, seconds: seconds);
    _entries.add(entry);
    _entries.sort((a, b) => b.start.compareTo(a.start));
    if (_entries.length > maxEntries) {
      _entries.removeRange(maxEntries, _entries.length);
    }
    return entry;
  }

  Future<void> delete(String id) async {
    final before = _entries.length;
    _entries.removeWhere((e) => e.id == id);
    if (_entries.length == before) return;
    await _save();
    notifyListeners();
  }

  /// Entries that started on [day].
  List<ManualEntry> forDay(DateTime day) {
    final d = _day(day);
    return _entries.where((e) => _day(e.start) == d).toList();
  }

  /// Seconds per label for entries starting on or between [from] and [to].
  Map<String, int> totalsByLabel(DateTime from, DateTime to) {
    final a = _day(from), b = _day(to);
    final totals = <String, int>{};
    for (final e in _entries) {
      final d = _day(e.start);
      if (d.isBefore(a) || d.isAfter(b)) continue;
      totals[e.label] = (totals[e.label] ?? 0) + e.seconds;
    }
    return totals;
  }

  @visibleForTesting
  void resetForTesting() {
    _entries.clear();
    _running = null;
  }
}
