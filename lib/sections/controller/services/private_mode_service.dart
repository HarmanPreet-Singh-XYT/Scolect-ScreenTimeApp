import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../settings_data_controller.dart';

/// Password-gated session lock for "Private Mode" on desktop. Marking an
/// app/website private only affects whether it's shown in normal-mode lists —
/// tracking always continues regardless of lock state. See CLAUDE.md /
/// implementation plan for the full feature spec.
class PrivateModeController extends ChangeNotifier {
  static final PrivateModeController _instance =
      PrivateModeController._internal();
  factory PrivateModeController() => _instance;
  PrivateModeController._internal();

  static const _hashKey = 'privacy.passwordHash';
  static const _saltKey = 'privacy.passwordSalt';
  static const _includeInTotalsKey = 'privacy.includePrivateInTotals';
  static const _timeoutMinutesKey = 'privacy.sessionTimeoutMinutes';
  static const _backupCodeHashKey = 'privacy.backupCodeHash';
  static const _backupCodeSaltKey = 'privacy.backupCodeSalt';
  static const _securityQuestionKey = 'privacy.securityQuestion';
  static const _securityAnswerHashKey = 'privacy.securityAnswerHash';
  static const _securityAnswerSaltKey = 'privacy.securityAnswerSalt';

  Timer? _relockTimer;
  DateTime? _unlockExpiry;
  bool _showPrivateOnly = false;

  bool get isSetUp {
    final hash = SettingsManager().getSetting(_hashKey) as String?;
    return hash != null && hash.isNotEmpty;
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

  bool get includePrivateInTotals =>
      SettingsManager().getSetting(_includeInTotalsKey) as bool? ?? true;

  set includePrivateInTotals(bool value) {
    SettingsManager().updateSetting(_includeInTotalsKey, value);
    notifyListeners();
  }

  int get sessionTimeoutMinutes =>
      SettingsManager().getSetting(_timeoutMinutesKey) as int? ?? 5;

  set sessionTimeoutMinutes(int minutes) {
    SettingsManager().updateSetting(_timeoutMinutesKey, minutes);
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
    SettingsManager().updateSetting(_saltKey, salt);
    SettingsManager().updateSetting(_hashKey, _hash(password, salt));
    notifyListeners();
  }

  /// Clears the password only — items already marked private stay private,
  /// just inaccessible until a new password is set. Recovery is possible via
  /// a backup code or security question, see [recoverWithBackupCode] /
  /// [recoverWithSecurityAnswer].
  Future<void> resetPassword() async {
    SettingsManager().updateSetting(_hashKey, '');
    SettingsManager().updateSetting(_saltKey, '');
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
    SettingsManager().updateSetting(_backupCodeSaltKey, codeSalt);
    SettingsManager()
        .updateSetting(_backupCodeHashKey, _hash(backupCode, codeSalt));
    SettingsManager().updateSetting(_securityQuestionKey, securityQuestion);
    SettingsManager().updateSetting(_securityAnswerSaltKey, answerSalt);
    SettingsManager().updateSetting(
        _securityAnswerHashKey, _hash(securityAnswer, answerSalt));
    notifyListeners();
  }

  /// The stored security question text, or null if recovery hasn't been set up.
  String? get securityQuestion {
    final q = SettingsManager().getSetting(_securityQuestionKey) as String?;
    return (q == null || q.isEmpty) ? null : q;
  }

  /// Whether a backup code has been generated and not yet consumed.
  bool get hasBackupCode {
    final hash = SettingsManager().getSetting(_backupCodeHashKey) as String?;
    return hash != null && hash.isNotEmpty;
  }

  /// Verifies [code] against the stored backup code. On success, clears the
  /// password (same effect as [resetPassword]) AND consumes the backup code
  /// so it cannot be reused — the user must set a new password and new
  /// recovery options immediately after.
  bool recoverWithBackupCode(String code) {
    final storedHash =
        SettingsManager().getSetting(_backupCodeHashKey) as String? ?? '';
    final storedSalt =
        SettingsManager().getSetting(_backupCodeSaltKey) as String? ?? '';
    if (storedHash.isEmpty || _hash(code, storedSalt) != storedHash) {
      return false;
    }
    SettingsManager().updateSetting(_hashKey, '');
    SettingsManager().updateSetting(_saltKey, '');
    SettingsManager().updateSetting(_backupCodeHashKey, '');
    SettingsManager().updateSetting(_backupCodeSaltKey, '');
    lock();
    return true;
  }

  /// Verifies [answer] against the stored security answer. On success,
  /// clears the password AND the now-consumed backup code (same as
  /// [recoverWithBackupCode]) so the user must set both a new password and
  /// new recovery options immediately after.
  bool recoverWithSecurityAnswer(String answer) {
    final storedHash =
        SettingsManager().getSetting(_securityAnswerHashKey) as String? ?? '';
    final storedSalt =
        SettingsManager().getSetting(_securityAnswerSaltKey) as String? ?? '';
    if (storedHash.isEmpty || _hash(answer, storedSalt) != storedHash) {
      return false;
    }
    SettingsManager().updateSetting(_hashKey, '');
    SettingsManager().updateSetting(_saltKey, '');
    SettingsManager().updateSetting(_backupCodeHashKey, '');
    SettingsManager().updateSetting(_backupCodeSaltKey, '');
    lock();
    return true;
  }

  bool unlock(String password) {
    final storedHash = SettingsManager().getSetting(_hashKey) as String? ?? '';
    final storedSalt = SettingsManager().getSetting(_saltKey) as String? ?? '';
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
