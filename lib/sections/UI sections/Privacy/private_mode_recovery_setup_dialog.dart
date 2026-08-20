import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/services/private_mode_service.dart';
import 'package:screentime/web/web_private_mode_service.dart'
    if (dart.library.io) 'package:screentime/web/web_private_mode_service_stub.dart';
import 'package:screentime/sections/controller/_backup_code_save_web.dart'
    if (dart.library.io) 'package:screentime/sections/controller/_backup_code_save_io.dart';

/// Shown right after a Private Mode password is (re)set, on both first setup
/// and password change — walks the user through choosing a security question
/// and generating a backup code, satisfying "regenerate recovery options
/// whenever the password changes."
///
/// Two-step flow in one dialog: (1) pick/write a security question + answer,
/// (2) generate + display the backup code with copy/download actions and a
/// required "I've saved this" confirmation before the dialog can be closed.
class PrivateModeRecoverySetupDialog extends StatefulWidget {
  const PrivateModeRecoverySetupDialog({super.key});

  @override
  State<PrivateModeRecoverySetupDialog> createState() =>
      _PrivateModeRecoverySetupDialogState();
}

class _PrivateModeRecoverySetupDialogState
    extends State<PrivateModeRecoverySetupDialog> {
  int _step = 0;

  // Step 1 state
  String? _selectedQuestionKey;
  final _customQuestionController = TextEditingController();
  final _answerController = TextEditingController();
  String? _questionError;
  String? _answerError;

  // Step 2 state
  String? _backupCode;
  bool _saved = false;
  bool _generating = false;

  @override
  void dispose() {
    _customQuestionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  List<MapEntry<String, String>> _presetQuestions(AppLocalizations l10n) => [
        MapEntry('petName', l10n.privateModeQuestionPetName),
        MapEntry('birthCity', l10n.privateModeQuestionBirthCity),
        MapEntry('firstSchool', l10n.privateModeQuestionFirstSchool),
        MapEntry('motherMaidenName', l10n.privateModeQuestionMotherMaidenName),
        MapEntry('favoriteBook', l10n.privateModeQuestionFavoriteBook),
      ];

  String? _resolvedQuestionText(AppLocalizations l10n) {
    if (_selectedQuestionKey == null) return null;
    if (_selectedQuestionKey == 'custom') {
      return _customQuestionController.text.trim();
    }
    final match = _presetQuestions(l10n)
        .where((e) => e.key == _selectedQuestionKey)
        .toList();
    return match.isEmpty ? null : match.first.value;
  }

  Future<void> _continueToBackupCode(AppLocalizations l10n) async {
    final questionText = _resolvedQuestionText(l10n);
    setState(() {
      _questionError =
          (questionText == null || questionText.isEmpty) ? l10n.privateModeChooseSecurityQuestion : null;
      _answerError =
          _answerController.text.trim().isEmpty ? l10n.privateModeSecurityAnswerEmpty : null;
    });
    if (_questionError != null || _answerError != null) return;

    setState(() => _generating = true);

    final code = kIsWeb
        ? WebPrivateModeService().generateBackupCode()
        : PrivateModeController().generateBackupCode();

    if (kIsWeb) {
      await WebPrivateModeService().setRecoveryOptions(
        backupCode: code,
        securityQuestion: questionText!,
        securityAnswer: _answerController.text.trim(),
      );
    } else {
      await PrivateModeController().setRecoveryOptions(
        backupCode: code,
        securityQuestion: questionText!,
        securityAnswer: _answerController.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() {
      _backupCode = code;
      _generating = false;
      _step = 1;
    });
  }

  Future<void> _copyCode(AppLocalizations l10n) async {
    if (_backupCode == null) return;
    await Clipboard.setData(ClipboardData(text: _backupCode!));
    if (!mounted) return;
    displayInfoBar(
      context,
      builder: (_, __) => InfoBar(
        title: Text(l10n.privateModeBackupCodeCopied),
        severity: InfoBarSeverity.success,
      ),
    );
  }

  Future<void> _downloadCode(AppLocalizations l10n) async {
    if (_backupCode == null) return;
    await saveTextFile(
      'Scolect Private Mode backup code:\n\n$_backupCode\n\n'
      'Keep this somewhere safe. You will need it if you forget your Private Mode password.',
      'scolect_private_mode_backup_code.txt',
      l10n.privateModeDownloadBackupCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 420),
      title: Text(l10n.privateModeSetupRecoveryTitle),
      content: _step == 0 ? _buildQuestionStep(l10n) : _buildBackupCodeStep(l10n),
      actions: _step == 0
          ? [
              FilledButton(
                onPressed: _generating ? null : () => _continueToBackupCode(l10n),
                child: Text(l10n.save),
              ),
            ]
          : [
              FilledButton(
                onPressed: _saved ? () => Navigator.pop(context, true) : null,
                child: Text(l10n.save),
              ),
            ],
    );
  }

  Widget _buildQuestionStep(AppLocalizations l10n) {
    final presets = _presetQuestions(l10n);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.privateModeSecurityQuestionLabel,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ComboBox<String>(
          isExpanded: true,
          value: _selectedQuestionKey,
          placeholder: Text(l10n.privateModeChooseSecurityQuestion),
          items: [
            ...presets.map(
              (e) => ComboBoxItem(value: e.key, child: Text(e.value)),
            ),
            ComboBoxItem(
              value: 'custom',
              child: Text(l10n.privateModeSecurityQuestionCustomOption),
            ),
          ],
          onChanged: (v) => setState(() => _selectedQuestionKey = v),
        ),
        if (_selectedQuestionKey == 'custom') ...[
          const SizedBox(height: 10),
          TextBox(
            controller: _customQuestionController,
            placeholder: l10n.privateModeChooseSecurityQuestion,
          ),
        ],
        if (_questionError != null) ...[
          const SizedBox(height: 6),
          Text(_questionError!, style: TextStyle(color: Colors.red, fontSize: 12)),
        ],
        const SizedBox(height: 16),
        Text(l10n.privateModeSecurityAnswerLabel,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextBox(
          controller: _answerController,
          placeholder: l10n.privateModeSecurityAnswerPlaceholder,
        ),
        if (_answerError != null) ...[
          const SizedBox(height: 6),
          Text(_answerError!, style: TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildBackupCodeStep(AppLocalizations l10n) {
    final theme = FluentTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.privateModeBackupCodeGeneratedTitle,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: theme.accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _backupCode ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Button(
                onPressed: () => _copyCode(l10n),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(FluentIcons.copy, size: 14),
                    const SizedBox(width: 6),
                    Text(l10n.privateModeCopyBackupCode),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Button(
                onPressed: () => _downloadCode(l10n),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(FluentIcons.download, size: 14),
                    const SizedBox(width: 6),
                    Text(l10n.privateModeDownloadBackupCode),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          l10n.privateModeBackupCodeWarning,
          style: TextStyle(fontSize: 12, color: theme.resources.textFillColorSecondary),
        ),
        const SizedBox(height: 12),
        Checkbox(
          checked: _saved,
          onChanged: (v) => setState(() => _saved = v ?? false),
          content: Text(l10n.privateModeIveSavedThis),
        ),
      ],
    );
  }
}
