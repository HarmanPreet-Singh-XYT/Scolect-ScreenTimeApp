import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Outcome of checking a browser extension's credentials.
enum AuthStatus {
  /// Credentials match an approved browser (or approval isn't required).
  approved,

  /// Unknown browser; queued for the user to approve on the desktop.
  pending,

  /// The user previously denied this browser.
  denied,

  /// The browser id is known but the token doesn't match.
  invalid,

  /// No (or malformed) credentials were supplied.
  missing,
}

class PendingBrowser {
  final String id;
  final String name;
  final DateTime firstSeen;

  const PendingBrowser(
      {required this.id, required this.name, required this.firstSeen});
}

class ApprovedBrowser {
  final String id;
  final String name;
  final DateTime approvedAt;

  const ApprovedBrowser(
      {required this.id, required this.name, required this.approvedAt});
}

/// Authenticates browser extensions talking to the local sync server.
///
/// Each extension generates a random token once and sends it, with its browser
/// id, on every request. The first time an unknown browser appears it is held
/// as *pending* until the user approves it on the desktop. Only a SHA-256 hash
/// of the token is stored, and a known browser id presenting a different token
/// is rejected rather than re-queued, so an approved browser can't be
/// impersonated by a process that only knows its id.
class ExtensionAuth extends ChangeNotifier {
  ExtensionAuth({bool Function()? requireApproval})
      : _requireApproval = requireApproval ?? _settingRequiresApproval;

  static final ExtensionAuth instance = ExtensionAuth();

  static const String settingKey = 'browserExtensionRequireApproval';
  static const String _prefsKey = 'extension_auth_v1';
  static const int _maxPending = 20;

  static final RegExp _idPattern = RegExp(r'^[A-Za-z0-9-]{8,64}$');
  static final RegExp _tokenPattern = RegExp(r'^[A-Za-z0-9_-]{32,128}$');

  static bool _settingRequiresApproval() =>
      SettingsManager().getSetting(settingKey) == true;

  final bool Function() _requireApproval;

  final Map<String, _Entry> _approved = {};
  final Set<String> _denied = {};
  final Map<String, _PendingEntry> _pending = {};

  int _blockedCount = 0;
  DateTime? _lastBlockedAt;

  bool get isRequired => _requireApproval();

  /// Requests rejected since launch (missing/invalid/denied/pending).
  int get blockedCount => _blockedCount;
  DateTime? get lastBlockedAt => _lastBlockedAt;

  List<PendingBrowser> get pending => _pending.entries
      .map((e) => PendingBrowser(
          id: e.key, name: e.value.name, firstSeen: e.value.firstSeen))
      .toList()
    ..sort((a, b) => a.firstSeen.compareTo(b.firstSeen));

  List<ApprovedBrowser> get approved => _approved.entries
      .map((e) => ApprovedBrowser(
          id: e.key, name: e.value.name, approvedAt: e.value.approvedAt))
      .toList()
    ..sort((a, b) => a.approvedAt.compareTo(b.approvedAt));

  bool isApproved(String id) => _approved.containsKey(id);

  // ─── Persistence ─────────────────────────────────────────────────────────

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      _approved.clear();
      _denied.clear();
      if (raw == null) return;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      (json['approved'] as Map? ?? {}).forEach((id, v) {
        final m = v as Map;
        _approved['$id'] = _Entry(
          hash: m['hash'] as String,
          name: m['name'] as String? ?? '',
          approvedAt: DateTime.fromMillisecondsSinceEpoch(
              (m['approvedAt'] as num?)?.toInt() ?? 0),
        );
      });
      _denied.addAll(((json['denied'] as List?) ?? []).cast<String>());
    } catch (e) {
      debugPrint('⚠️ ExtensionAuth load failed: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode({
          'approved': {
            for (final e in _approved.entries)
              e.key: {
                'hash': e.value.hash,
                'name': e.value.name,
                'approvedAt': e.value.approvedAt.millisecondsSinceEpoch,
              }
          },
          'denied': _denied.toList(),
        }),
      );
    } catch (e) {
      debugPrint('⚠️ ExtensionAuth save failed: $e');
    }
  }

  // ─── Checking ────────────────────────────────────────────────────────────

  static String _hash(String token) =>
      sha256.convert(utf8.encode(token)).toString();

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  /// Validates [browserId]/[token]. Unknown browsers are queued as pending.
  AuthStatus check(String? browserId, String? token, {String? browserName}) {
    if (!isRequired) return AuthStatus.approved;

    if (browserId == null ||
        token == null ||
        !_idPattern.hasMatch(browserId) ||
        !_tokenPattern.hasMatch(token)) {
      return _blocked(AuthStatus.missing);
    }

    final known = _approved[browserId];
    if (known != null) {
      return _constantTimeEquals(known.hash, _hash(token))
          ? AuthStatus.approved
          : _blocked(AuthStatus.invalid);
    }

    if (_denied.contains(browserId)) return _blocked(AuthStatus.denied);

    final existing = _pending[browserId];
    if (existing != null) {
      // A different token for an id that's already waiting is a conflict, not
      // an update: keep the first one so it can't be swapped before approval.
      return _constantTimeEquals(existing.hash, _hash(token))
          ? _blocked(AuthStatus.pending)
          : _blocked(AuthStatus.invalid);
    }

    if (_pending.length >= _maxPending) return _blocked(AuthStatus.pending);

    _pending[browserId] = _PendingEntry(
      hash: _hash(token),
      name: (browserName ?? '').trim(),
      firstSeen: DateTime.now(),
    );
    notifyListeners();
    return _blocked(AuthStatus.pending);
  }

  AuthStatus _blocked(AuthStatus status) {
    if (status != AuthStatus.approved) {
      _blockedCount++;
      _lastBlockedAt = DateTime.now();
    }
    return status;
  }

  // ─── User decisions ──────────────────────────────────────────────────────

  Future<bool> approve(String id) async {
    final p = _pending.remove(id);
    if (p == null) return false;
    _denied.remove(id);
    _approved[id] =
        _Entry(hash: p.hash, name: p.name, approvedAt: DateTime.now());
    await _save();
    notifyListeners();
    return true;
  }

  Future<void> deny(String id) async {
    if (_pending.remove(id) == null) return;
    _denied.add(id);
    await _save();
    notifyListeners();
  }

  /// Removes an approved browser. It will be queued as pending again the next
  /// time it connects, since its token is no longer trusted.
  Future<void> revoke(String id) async {
    if (_approved.remove(id) == null) return;
    await _save();
    notifyListeners();
  }

  /// Lets a previously denied browser ask again.
  Future<void> clearDenied() async {
    if (_denied.isEmpty) return;
    _denied.clear();
    await _save();
    notifyListeners();
  }

  @visibleForTesting
  void resetForTesting() {
    _approved.clear();
    _denied.clear();
    _pending.clear();
    _blockedCount = 0;
    _lastBlockedAt = null;
  }
}

class _Entry {
  final String hash;
  final String name;
  final DateTime approvedAt;
  const _Entry(
      {required this.hash, required this.name, required this.approvedAt});
}

class _PendingEntry {
  final String hash;
  final String name;
  final DateTime firstSeen;
  const _PendingEntry(
      {required this.hash, required this.name, required this.firstSeen});
}
