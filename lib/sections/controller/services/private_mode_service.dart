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

  Timer? _relockTimer;
  DateTime? _unlockExpiry;

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

  Future<void> setPassword(String password) async {
    final salt = _generateSalt();
    SettingsManager().updateSetting(_saltKey, salt);
    SettingsManager().updateSetting(_hashKey, _hash(password, salt));
    notifyListeners();
  }

  /// Clears the password only — items already marked private stay private,
  /// just inaccessible until a new password is set. There is no recovery
  /// flow, matching the app's local-only, no-account threat model.
  Future<void> resetPassword() async {
    SettingsManager().updateSetting(_hashKey, '');
    SettingsManager().updateSetting(_saltKey, '');
    lock();
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
    notifyListeners();
  }
}
