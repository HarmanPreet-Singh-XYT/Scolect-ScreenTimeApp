import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum UpdateStatus { idle, checking, upToDate, updateAvailable, error }

class UpdateInfo {
  final String tagName;
  final String name;
  final String body;
  final String publishedAt;
  final String htmlUrl;

  const UpdateInfo({
    required this.tagName,
    required this.name,
    required this.body,
    required this.publishedAt,
    required this.htmlUrl,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
        tagName: json['tag_name'] ?? '',
        name: json['name'] ?? '',
        body: json['body'] ?? '',
        publishedAt: json['published_at'] ?? '',
        htmlUrl: json['html_url'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'tag_name': tagName,
        'name': name,
        'body': body,
        'published_at': publishedAt,
        'html_url': htmlUrl,
      };
}

class UpdateService extends ChangeNotifier {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  // Platform-aware endpoint — server returns the correct release per platform.
  // A Windows-only release won't show as update on macOS and vice versa.
  static String get _updateEndpoint {
    final platform = Platform.isMacOS ? 'macos' : 'windows';
    return 'https://api.scolect.com/update?platform=$platform';
  }

  static const String _lastCheckKey = 'last_update_check';
  static const String _cachedUpdateKey = 'cached_update_info';
  static const Duration _checkInterval = Duration(hours: 6);

  UpdateStatus _status = UpdateStatus.idle;
  UpdateInfo? _availableUpdate;
  String? _errorMessage;
  Timer? _periodicTimer;
  String _currentVersion = '';

  UpdateStatus get status => _status;
  UpdateInfo? get availableUpdate => _availableUpdate;
  String? get errorMessage => _errorMessage;
  bool get hasUpdate => _status == UpdateStatus.updateAvailable;

  /// Call once at startup from main.dart (only when autoUpdates = true)
  Future<void> initialize(String currentVersion) async {
    _currentVersion = currentVersion;
    await _restoreCachedUpdate(); // instant, no network wait
    await _checkIfDue();
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(_checkInterval, (_) => checkForUpdates());
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkIfDue() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckMs = prefs.getInt(_lastCheckKey);
    if (lastCheckMs == null) {
      await checkForUpdates();
      return;
    }
    final elapsed = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastCheckMs));
    if (elapsed >= _checkInterval) await checkForUpdates();
  }

  /// Force an immediate check — called by "Check Updates" button
  Future<void> checkForUpdates() async {
    if (_status == UpdateStatus.checking) return;
    _status = UpdateStatus.checking;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse(_updateEndpoint))
          .timeout(const Duration(seconds: 15));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        // Server wraps response in { success, message, data: {...} }
        final data = (body['data'] ?? body) as Map<String, dynamic>;
        final update = UpdateInfo.fromJson(data);

        if (_isNewerVersion(update.tagName, _currentVersion)) {
          _availableUpdate = update;
          _status = UpdateStatus.updateAvailable;
          await prefs.setString(_cachedUpdateKey, json.encode(update.toJson()));
        } else {
          _availableUpdate = null;
          _status = UpdateStatus.upToDate;
          await prefs.remove(_cachedUpdateKey);
        }
      } else {
        _status = UpdateStatus.error;
        _errorMessage = 'Server returned ${response.statusCode}';
      }
    } catch (e) {
      _status = UpdateStatus.error;
      _errorMessage = e.toString();
      debugPrint('UpdateService error: $e');
    }

    notifyListeners();
  }

  /// Restores last known update from disk so the banner shows instantly
  /// on next launch without waiting for a network call
  Future<void> _restoreCachedUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cachedUpdateKey);
      if (cached != null) {
        _availableUpdate = UpdateInfo.fromJson(
          json.decode(cached) as Map<String, dynamic>,
        );
        _status = UpdateStatus.updateAvailable;
        notifyListeners();
      }
    } catch (_) {}
  }

  bool _isNewerVersion(String remoteTag, String currentVersion) {
    try {
      final remote = _parseVersion(remoteTag);
      final current = _parseVersion(currentVersion);
      for (int i = 0; i < 3; i++) {
        if (remote[i] > current[i]) return true;
        if (remote[i] < current[i]) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  List<int> _parseVersion(String v) {
    final clean = v.replaceAll(RegExp(r'[^0-9.]'), '');
    final parts = clean.split('.');
    return [
      int.tryParse(parts.elementAtOrNull(0) ?? '0') ?? 0,
      int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0,
      int.tryParse(parts.elementAtOrNull(2) ?? '0') ?? 0,
    ];
  }

  Future<String> getLastCheckText() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_lastCheckKey);
    if (ms == null) return 'Never';
    final diff =
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ms));
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
