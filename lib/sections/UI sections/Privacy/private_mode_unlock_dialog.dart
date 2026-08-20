import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

/// Password prompt to reveal private apps/websites. This is a security
/// prompt, not an informational dialog — unlike the rest of the app's
/// dialogs it must NOT be dismissible by tapping the backdrop, so callers
/// should show it with `barrierDismissible: false`.
class PrivateModeUnlockDialog extends StatefulWidget {
  /// Returns true on a correct password.
  final Future<bool> Function(String password) onUnlock;

  /// Called when the user taps "Forgot password?" — the caller drives the
  /// actual recovery dialog + follow-up new-password flow since those pop
  /// this dialog first. If null, no "Forgot password?" link is shown.
  final VoidCallback? onForgotPassword;

  const PrivateModeUnlockDialog({
    super.key,
    required this.onUnlock,
    this.onForgotPassword,
  });

  @override
  State<PrivateModeUnlockDialog> createState() =>
      _PrivateModeUnlockDialogState();
}

class _PrivateModeUnlockDialogState extends State<PrivateModeUnlockDialog> {
  final _controller = TextEditingController();
  bool _submitting = false;
  bool _incorrect = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || _controller.text.isEmpty) return;
    setState(() {
      _submitting = true;
      _incorrect = false;
    });
    final ok = await widget.onUnlock(_controller.text);
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
      constraints: const BoxConstraints(maxWidth: 380),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(FluentIcons.lock, size: 20, color: theme.accentColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              l10n.privateModeUnlockTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextBox(
            controller: _controller,
            obscureText: true,
            autofocus: true,
            placeholder: l10n.privateModePasswordPlaceholder,
            onSubmitted: (_) => _submit(),
          ),
          if (_incorrect) ...[
            const SizedBox(height: 8),
            Text(
              l10n.privateModeIncorrectPassword,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
          if (widget.onForgotPassword != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: HyperlinkButton(
                onPressed: () {
                  Navigator.pop(context, false);
                  widget.onForgotPassword!();
                },
                child: Text(l10n.privateModeForgotPassword),
              ),
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
