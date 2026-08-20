import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/services/private_mode_service.dart';
import 'package:screentime/web/web_private_mode_service.dart'
    if (dart.library.io) 'package:screentime/web/web_private_mode_service_stub.dart';

/// Recovery flow reachable via "Forgot password?" on [PrivateModeUnlockDialog].
/// Offers backup-code entry OR security-question entry. This is a
/// security-sensitive prompt like the unlock dialog — callers should show it
/// with `barrierDismissible: false`.
///
/// Returns `true` via [Navigator.pop] if recovery succeeded (password + old
/// backup code have been cleared server-side); the caller is responsible for
/// following up with a new-password flow and a fresh recovery-setup flow.
class PrivateModeRecoveryDialog extends StatefulWidget {
  const PrivateModeRecoveryDialog({super.key});

  @override
  State<PrivateModeRecoveryDialog> createState() =>
      _PrivateModeRecoveryDialogState();
}

enum _RecoveryTab { backupCode, securityQuestion }

class _PrivateModeRecoveryDialogState extends State<PrivateModeRecoveryDialog> {
  _RecoveryTab _tab = _RecoveryTab.backupCode;
  final _codeController = TextEditingController();
  final _answerController = TextEditingController();
  bool _submitting = false;
  bool _incorrect = false;
  String? _securityQuestion;
  bool _loadingQuestion = true;

  @override
  void initState() {
    super.initState();
    _loadSecurityQuestion();
  }

  Future<void> _loadSecurityQuestion() async {
    final question = kIsWeb
        ? await WebPrivateModeService().securityQuestion
        : PrivateModeController().securityQuestion;
    if (!mounted) return;
    setState(() {
      _securityQuestion = question;
      _loadingQuestion = false;
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final input = _tab == _RecoveryTab.backupCode
        ? _codeController.text.trim()
        : _answerController.text.trim();
    if (_submitting || input.isEmpty) return;

    setState(() {
      _submitting = true;
      _incorrect = false;
    });

    final bool ok;
    if (_tab == _RecoveryTab.backupCode) {
      ok = kIsWeb
          ? await WebPrivateModeService().recoverWithBackupCode(input)
          : PrivateModeController().recoverWithBackupCode(input);
    } else {
      ok = kIsWeb
          ? await WebPrivateModeService().recoverWithSecurityAnswer(input)
          : PrivateModeController().recoverWithSecurityAnswer(input);
    }

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _submitting = false;
      _incorrect = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 400),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(FluentIcons.unlock, size: 20, color: theme.accentColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              l10n.privateModeRecoveryTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ToggleSwitch(
            checked: _tab == _RecoveryTab.securityQuestion,
            onChanged: _loadingQuestion
                ? null
                : (v) => setState(() {
                      _tab = v ? _RecoveryTab.securityQuestion : _RecoveryTab.backupCode;
                      _incorrect = false;
                    }),
            content: Text(_tab == _RecoveryTab.securityQuestion
                ? l10n.privateModeRecoveryTabSecurityQuestion
                : l10n.privateModeRecoveryTabBackupCode),
          ),
          const SizedBox(height: 12),
          if (_tab == _RecoveryTab.backupCode)
            TextBox(
              controller: _codeController,
              autofocus: true,
              placeholder: l10n.privateModeBackupCodePlaceholder,
              onSubmitted: (_) => _submit(),
            )
          else if (_loadingQuestion)
            const Center(child: ProgressRing())
          else if (_securityQuestion == null)
            Text(
              l10n.privateModeRecoveryIncorrect,
              style: TextStyle(color: Colors.red, fontSize: 12),
            )
          else ...[
            Text(_securityQuestion!,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextBox(
              controller: _answerController,
              autofocus: true,
              placeholder: l10n.privateModeSecurityAnswerPlaceholder,
              onSubmitted: (_) => _submit(),
            ),
          ],
          if (_incorrect) ...[
            const SizedBox(height: 8),
            Text(
              l10n.privateModeRecoveryIncorrect,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(l10n.privateModeUnlockAction),
        ),
      ],
    );
  }
}
