import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/widgets/Settings/reusables.dart';
import 'package:screentime/sections/controller/services/private_mode_service.dart';
import 'package:screentime/web/web_private_mode_service.dart'
    if (dart.library.io) 'package:screentime/web/web_private_mode_service_stub.dart';

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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
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
        _loading = false;
      });
    } else {
      final controller = PrivateModeController();
      setState(() {
        _isSetUp = controller.isSetUp;
        _includeInTotals = controller.includePrivateInTotals;
        _timeoutMinutes = controller.sessionTimeoutMinutes;
        _loading = false;
      });
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
    if (result == true) await _refresh();
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
