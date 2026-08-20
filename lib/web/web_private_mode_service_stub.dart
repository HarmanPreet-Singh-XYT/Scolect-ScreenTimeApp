// ─── Stub for desktop builds ──────────────────────────────────────────────────
// Never instantiated at runtime on desktop; only exists so conditional imports
// compile successfully on non-web platforms. Desktop uses PrivateModeController.

import 'package:flutter/foundation.dart';

class WebPrivateModeService extends ChangeNotifier {
  static final WebPrivateModeService _instance =
      WebPrivateModeService._internal();
  factory WebPrivateModeService() => _instance;
  WebPrivateModeService._internal();

  Future<bool> get isSetUp async => false;
  bool get isUnlocked => false;
  bool get showPrivateOnly => false;
  void setShowPrivateOnly(bool value) {}
  bool get includePrivateInTotals => true;
  int get sessionTimeoutMinutes => 5;

  Future<void> setIncludePrivateInTotals(bool value) async {}
  Future<void> setSessionTimeoutMinutes(int minutes) async {}
  Future<void> setPassword(String password) async {}
  Future<void> resetPassword() async {}
  Future<bool> unlock(String password) async => false;
  void extendSession() {}
  void lock() {}

  String generateBackupCode() => '';
  Future<void> setRecoveryOptions({
    required String backupCode,
    required String securityQuestion,
    required String securityAnswer,
  }) async {}
  Future<String?> get securityQuestion async => null;
  Future<bool> get hasBackupCode async => false;
  Future<bool> recoverWithBackupCode(String code) async => false;
  Future<bool> recoverWithSecurityAnswer(String answer) async => false;
}
