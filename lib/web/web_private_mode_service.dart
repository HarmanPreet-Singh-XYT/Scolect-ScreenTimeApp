import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'extension_settings.dart';

/// Password-gated session lock for "Private Mode" on the extension dashboard.
/// Mirrors PrivateModeController's API, but persists through ExtensionSettings
/// / chrome.storage.local instead of SettingsManager/SharedPreferences.
/// Desktop and extension keep independent unlock state and passwords by design.
class WebPrivateModeService extends ChangeNotifier {
  static final WebPrivateModeService _instance =
      WebPrivateModeService._internal();
  factory WebPrivateModeService() => _instance;
  WebPrivateModeService._internal();

  final ExtensionSettings _settings = ExtensionSettings();

  Timer? _relockTimer;
  DateTime? _unlockExpiry;

  Future<bool> get isSetUp async {
    await _settings.load();
    return _settings.privacyPasswordHash.isNotEmpty;
  }

  bool get isUnlocked {
    if (_unlockExpiry == null) return false;
    if (DateTime.now().isBefore(_unlockExpiry!)) return true;
    lock();
    return false;
  }

  bool get includePrivateInTotals => _settings.privacyIncludeInTotals;

  Future<void> setIncludePrivateInTotals(bool value) async {
    await _settings.setPrivacyOptions(includeInTotals: value);
    notifyListeners();
  }

  int get sessionTimeoutMinutes => _settings.privacySessionTimeoutMinutes;

  Future<void> setSessionTimeoutMinutes(int minutes) async {
    await _settings.setPrivacyOptions(sessionTimeoutMinutes: minutes);
  }

  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt$password')).toString();

  String _generateSalt() {
    final rand = Random.secure();
    return List<int>.generate(16, (_) => rand.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  Future<void> setPassword(String password) async {
    final salt = _generateSalt();
    await _settings.setPrivacyPassword(
      passwordHash: _hash(password, salt),
      passwordSalt: salt,
    );
    notifyListeners();
  }

  /// Clears the password only — items already marked private stay private,
  /// just inaccessible until a new password is set. There is no recovery
  /// flow, matching the app's local-only, no-account threat model.
  Future<void> resetPassword() async {
    await _settings.setPrivacyPassword(passwordHash: '', passwordSalt: '');
    lock();
  }

  Future<bool> unlock(String password) async {
    await _settings.load();
    final storedHash = _settings.privacyPasswordHash;
    final storedSalt = _settings.privacyPasswordSalt;
    if (storedHash.isEmpty || _hash(password, storedSalt) != storedHash) {
      return false;
    }
    _startSession();
    return true;
  }

  void _startSession() {
    _unlockExpiry = DateTime.now().add(Duration(minutes: sessionTimeoutMinutes));
    _relockTimer?.cancel();
    _relockTimer = Timer(Duration(minutes: sessionTimeoutMinutes), lock);
    notifyListeners();
  }

  /// Pushes the auto-relock deadline back out; call on private-mode UI activity.
  void extendSession() {
    if (!isUnlocked) return;
    _startSession();
  }

  void lock() {
    _relockTimer?.cancel();
    _relockTimer = null;
    _unlockExpiry = null;
    notifyListeners();
  }
}
