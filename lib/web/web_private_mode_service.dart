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
  bool _showPrivateOnly = false;

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

  /// Whether existing pages (Overview, Applications, Browser, Reports,
  /// Alerts & Limits) should show ONLY private-tagged items in place of
  /// public ones. Driven by the titlebar toggle — distinct from [isUnlocked]
  /// since unlocking and switching the view are two separate user actions
  /// after the initial auto-switch-on-unlock.
  bool get showPrivateOnly => isUnlocked && _showPrivateOnly;

  /// Switches the view between public-only and private-only. Caller must
  /// already be unlocked — the titlebar toggle unlocks first, then calls
  /// this with `true` as part of the same interaction.
  void setShowPrivateOnly(bool value) {
    _showPrivateOnly = value;
    notifyListeners();
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

  /// Sets/changes the Private Mode password. Does NOT itself (re)generate
  /// backup code/security question — that's a separate explicit step via
  /// [setRecoveryOptions], normally shown right after this succeeds.
  Future<void> setPassword(String password) async {
    final salt = _generateSalt();
    await _settings.setPrivacyPassword(
      passwordHash: _hash(password, salt),
      passwordSalt: salt,
    );
    notifyListeners();
  }

  /// Clears the password only — items already marked private stay private,
  /// just inaccessible until a new password is set. Recovery is possible via
  /// a backup code or security question, see [recoverWithBackupCode] /
  /// [recoverWithSecurityAnswer].
  Future<void> resetPassword() async {
    await _settings.setPrivacyPassword(passwordHash: '', passwordSalt: '');
    lock();
  }

  /// Generates a human-friendly one-time backup code, e.g. `AB12-CD34-EF56-GH78`.
  /// Returned in plaintext for the caller to display once — only its salted
  /// hash is ever persisted.
  String generateBackupCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    String group() =>
        List.generate(4, (_) => chars[rand.nextInt(chars.length)]).join();
    return '${group()}-${group()}-${group()}-${group()}';
  }

  /// Persists a freshly generated backup code + security question/answer,
  /// hashing+salting the code and answer (question text is stored in clear
  /// since it must be displayed during recovery, not verified).
  Future<void> setRecoveryOptions({
    required String backupCode,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    final codeSalt = _generateSalt();
    final answerSalt = _generateSalt();
    await _settings.setPrivacyRecovery(
      backupCodeHash: _hash(backupCode, codeSalt),
      backupCodeSalt: codeSalt,
      securityQuestion: securityQuestion,
      securityAnswerHash: _hash(securityAnswer, answerSalt),
      securityAnswerSalt: answerSalt,
    );
    notifyListeners();
  }

  /// The stored security question text, or null if recovery hasn't been set
  /// up. Async on web, matching the async convention already established for
  /// [isSetUp].
  Future<String?> get securityQuestion async {
    await _settings.load();
    final q = _settings.privacySecurityQuestion;
    return q.isEmpty ? null : q;
  }

  /// Whether a backup code has been generated and not yet consumed.
  Future<bool> get hasBackupCode async {
    await _settings.load();
    return _settings.privacyBackupCodeHash.isNotEmpty;
  }

  /// Verifies [code] against the stored backup code. On success, clears the
  /// password (same effect as [resetPassword]) AND consumes the backup code
  /// so it cannot be reused — the user must set a new password and new
  /// recovery options immediately after.
  Future<bool> recoverWithBackupCode(String code) async {
    await _settings.load();
    final storedHash = _settings.privacyBackupCodeHash;
    final storedSalt = _settings.privacyBackupCodeSalt;
    if (storedHash.isEmpty || _hash(code, storedSalt) != storedHash) {
      return false;
    }
    await _settings.setPrivacyPassword(passwordHash: '', passwordSalt: '');
    await _settings.clearPrivacyBackupCode();
    lock();
    return true;
  }

  /// Verifies [answer] against the stored security answer. On success,
  /// clears the password AND the now-consumed backup code (same as
  /// [recoverWithBackupCode]) so the user must set both a new password and
  /// new recovery options immediately after.
  Future<bool> recoverWithSecurityAnswer(String answer) async {
    await _settings.load();
    final storedHash = _settings.privacySecurityAnswerHash;
    final storedSalt = _settings.privacySecurityAnswerSalt;
    if (storedHash.isEmpty || _hash(answer, storedSalt) != storedHash) {
      return false;
    }
    await _settings.setPrivacyPassword(passwordHash: '', passwordSalt: '');
    await _settings.clearPrivacyBackupCode();
    lock();
    return true;
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
    _showPrivateOnly = false;
    notifyListeners();
  }
}
