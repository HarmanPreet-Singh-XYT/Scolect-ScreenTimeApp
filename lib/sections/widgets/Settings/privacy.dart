import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/widgets/Settings/reusables.dart';
import 'package:screentime/sections/controller/services/private_mode_service.dart';
import 'package:screentime/web/web_private_mode_service.dart'
    if (dart.library.io) 'package:screentime/web/web_private_mode_service_stub.dart';
import 'package:screentime/sections/UI sections/Privacy/private_mode_recovery_setup_dialog.dart';
import 'package:screentime/sections/UI sections/Privacy/private_mode_recovery_dialog.dart';
import 'package:screentime/sections/UI sections/Privacy/private_mode_unlock_dialog.dart';

// ============== PRIVACY SECTION ==============
//
// Lets the user set a password that gates "Private Mode": apps/websites
// flagged private are hidden from normal lists until unlocked. Desktop and
// the web extension dashboard keep independent passwords/unlock sessions —
// see CLAUDE.md-adjacent implementation plan for rationale.

class PrivacySection extends StatefulWidget {
  const PrivacySection({super.key});

  @override
  State<PrivacySection> createState() => _PrivacySectionState();
}

class _PrivacySectionState extends State<PrivacySection> {
  bool _isSetUp = false;
  bool _includeInTotals = true;
  int _timeoutMinutes = 5;
  bool _showPrivateOnly = false;
  bool _loading = true;

  void _onPrivateModeChanged() {
    if (mounted) _refresh();
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WebPrivateModeService().addListener(_onPrivateModeChanged);
    } else {
      PrivateModeController().addListener(_onPrivateModeChanged);
    }
    _refresh();
  }

  @override
  void dispose() {
    if (kIsWeb) {
      WebPrivateModeService().removeListener(_onPrivateModeChanged);
    } else {
      PrivateModeController().removeListener(_onPrivateModeChanged);
    }
    super.dispose();
  }

  Future<void> _refresh() async {
    if (kIsWeb) {
      final service = WebPrivateModeService();
      final setUp = await service.isSetUp;
      if (!mounted) return;
      setState(() {
        _isSetUp = setUp;
        _includeInTotals = service.includePrivateInTotals;
        _timeoutMinutes = service.sessionTimeoutMinutes;
        _showPrivateOnly = service.showPrivateOnly;
        _loading = false;
      });
    } else {
      final controller = PrivateModeController();
      setState(() {
        _isSetUp = controller.isSetUp;
        _includeInTotals = controller.includePrivateInTotals;
        _timeoutMinutes = controller.sessionTimeoutMinutes;
        _showPrivateOnly = controller.showPrivateOnly;
        _loading = false;
      });
    }
  }

  /// Mirrors PrivateModeToggleButton's tap behavior — same auto-switch-on-
  /// unlock UX, just reachable from Settings too.
  Future<void> _toggleShowPrivateOnly(bool value) async {
    if (!value) {
      if (kIsWeb) {
        WebPrivateModeService().setShowPrivateOnly(false);
      } else {
        PrivateModeController().setShowPrivateOnly(false);
      }
      return;
    }

    final alreadyUnlocked = kIsWeb
        ? WebPrivateModeService().isUnlocked
        : PrivateModeController().isUnlocked;
    if (alreadyUnlocked) {
      if (kIsWeb) {
        WebPrivateModeService().setShowPrivateOnly(true);
      } else {
        PrivateModeController().setShowPrivateOnly(true);
      }
      return;
    }

    final unlocked = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PrivateModeUnlockDialog(
        onUnlock: (password) => kIsWeb
            ? WebPrivateModeService().unlock(password)
            : Future.value(PrivateModeController().unlock(password)),
        onForgotPassword: () => showPrivateModeRecoveryFlow(context),
      ),
    );
    if (unlocked == true) {
      if (kIsWeb) {
        WebPrivateModeService().setShowPrivateOnly(true);
      } else {
        PrivateModeController().setShowPrivateOnly(true);
      }
    }
  }

  Future<void> _setIncludeInTotals(bool value) async {
    if (kIsWeb) {
      await WebPrivateModeService().setIncludePrivateInTotals(value);
    } else {
      PrivateModeController().includePrivateInTotals = value;
    }
    setState(() => _includeInTotals = value);
  }

  Future<void> _setTimeoutMinutes(int minutes) async {
    if (kIsWeb) {
      await WebPrivateModeService().setSessionTimeoutMinutes(minutes);
    } else {
      PrivateModeController().sessionTimeoutMinutes = minutes;
    }
    setState(() => _timeoutMinutes = minutes);
  }

  Future<void> _openSetPasswordDialog({required bool isChange}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _SetPasswordDialog(isChange: isChange),
    );
    if (result != true) return;
    await _refresh();
    // Regenerate recovery options whenever the password is set/changed —
    // both first-time setup and password change go through this dialog.
    if (!mounted) return;
    await _openRecoverySetupDialog();
  }

  Future<void> _openRecoverySetupDialog() async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PrivateModeRecoverySetupDialog(),
    );
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ContentDialog(
        title: Text(l10n.privateModeResetPasswordTitle),
        content: Text(l10n.privateModeResetPasswordDescription),
        actions: [
          Button(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          FilledButton(
            child: Text(l10n.privateModeResetPasswordAction),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (kIsWeb) {
      await WebPrivateModeService().resetPassword();
    } else {
      await PrivateModeController().resetPassword();
    }
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SettingsCard(
      title: l10n.privateModeSectionTitle,
      icon: FluentIcons.lock,
      children: _loading
          ? [const SizedBox(height: 40, child: Center(child: ProgressRing()))]
          : [
              SettingRow(
                title: _isSetUp
                    ? l10n.privateModeChangePasswordTitle
                    : l10n.privateModeSetPasswordTitle,
                description: l10n.privateModePasswordDescription,
                control: Button(
                  child: Text(_isSetUp
                      ? l10n.privateModeChangePasswordAction
                      : l10n.privateModeSetPasswordAction),
                  onPressed: () =>
                      _openSetPasswordDialog(isChange: _isSetUp),
                ),
              ),
              if (_isSetUp) ...[
                SettingRow(
                  title: _showPrivateOnly
                      ? l10n.privateModeHideAction
                      : l10n.privateModeShowAction,
                  description: l10n.privateModeShowOnlyDescription,
                  control: ToggleSwitch(
                    checked: _showPrivateOnly,
                    onChanged: _toggleShowPrivateOnly,
                  ),
                ),
                SettingRow(
                  title: l10n.privateModeIncludeInTotalsTitle,
                  description: l10n.privateModeIncludeInTotalsDescription,
                  control: ToggleSwitch(
                    checked: _includeInTotals,
                    onChanged: _setIncludeInTotals,
                  ),
                ),
                SettingRow(
                  title: l10n.privateModeSessionTimeoutTitle,
                  description: l10n.privateModeSessionTimeoutDescription,
                  control: ComboBox<int>(
                    value: _timeoutMinutes,
                    items: const [1, 5, 10, 15, 30]
                        .map((m) => ComboBoxItem(value: m, child: Text('$m min')))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) _setTimeoutMinutes(v);
                    },
                  ),
                ),
                SettingRow(
                  title: l10n.privateModeRecoveryOptionsTitle,
                  description: l10n.privateModeRecoveryOptionsDescription,
                  control: Button(
                    onPressed: _openRecoverySetupDialog,
                    child: Text(l10n.privateModeRegenerateRecoveryAction),
                  ),
                ),
                SettingRow(
                  title: l10n.privateModeResetPasswordTitle,
                  description: l10n.privateModeResetPasswordDescription,
                  showDivider: false,
                  control: Button(
                    onPressed: _resetPassword,
                    child: Text(l10n.privateModeResetPasswordAction),
                  ),
                ),
              ],
            ],
    );
  }
}

// ============== SET / CHANGE PASSWORD DIALOG ==============

class _SetPasswordDialog extends StatefulWidget {
  final bool isChange;
  const _SetPasswordDialog({required this.isChange});

  @override
  State<_SetPasswordDialog> createState() => _SetPasswordDialogState();
}

class _SetPasswordDialogState extends State<_SetPasswordDialog> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (_passwordController.text.isEmpty) {
      setState(() => _error = l10n.privateModePasswordEmpty);
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      setState(() => _error = l10n.privateModePasswordMismatch);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    if (kIsWeb) {
      await WebPrivateModeService().setPassword(_passwordController.text);
    } else {
      await PrivateModeController().setPassword(_passwordController.text);
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 380),
      title: Text(widget.isChange
          ? l10n.privateModeChangePasswordTitle
          : l10n.privateModeSetPasswordTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextBox(
            controller: _passwordController,
            obscureText: true,
            autofocus: true,
            placeholder: l10n.privateModePasswordPlaceholder,
          ),
          const SizedBox(height: 10),
          TextBox(
            controller: _confirmController,
            obscureText: true,
            placeholder: l10n.privateModeConfirmPasswordPlaceholder,
            onSubmitted: (_) => _save(l10n),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          onPressed: _saving ? null : () => _save(l10n),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

// ============== SHARED RECOVERY FLOW ==============
//
// Entry point for the "Forgot password?" link on PrivateModeUnlockDialog.
// Call sites (applications.dart, browser_websites.dart) wire this in as
// `onForgotPassword` after popping their own unlock dialog. On successful
// recovery, walks the user through: recovery dialog -> new password ->
// new recovery setup (backup code is single-use and gets consumed on
// successful recovery, so both password and recovery options must be
// re-established immediately).
Future<void> showPrivateModeRecoveryFlow(BuildContext context) async {
  final recovered = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PrivateModeRecoveryDialog(),
  );
  if (recovered != true || !context.mounted) return;

  final passwordSet = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _SetPasswordDialog(isChange: false),
  );
  if (passwordSet != true || !context.mounted) return;

  await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PrivateModeRecoverySetupDialog(),
  );
}

/// Entry point for first-time password setup from the titlebar or settings.
/// Returns true if password and recovery options were set successfully.
Future<bool> showPrivateModeSetPasswordFlow(BuildContext context) async {
  final passwordSet = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _SetPasswordDialog(isChange: false),
  );
  if (passwordSet != true || !context.mounted) return false;

  await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PrivateModeRecoverySetupDialog(),
  );
  return true;
}

