import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/utils/auto_updater_helper.dart';
import 'package:screentime/utils/update_service.dart';

/// Launch-time prompt shown when an update is available. Ticking the checkbox
/// silences it for that version only; a newer release prompts again.
class UpdatePromptDialog {
  UpdatePromptDialog._();

  static bool _shownThisLaunch = false;

  static Future<void> showIfNeeded(BuildContext context) async {
    if (_shownThisLaunch) return;
    final service = UpdateService();
    if (!await service.shouldPromptForUpdate() || !context.mounted) return;
    _shownThisLaunch = true;
    final update = service.availableUpdate!;
    await showDialog<void>(
      context: context,
      builder: (_) => _UpdatePromptContent(update: update),
    );
  }
}

class _UpdatePromptContent extends StatefulWidget {
  final UpdateInfo update;
  const _UpdatePromptContent({required this.update});

  @override
  State<_UpdatePromptContent> createState() => _UpdatePromptContentState();
}

class _UpdatePromptContentState extends State<_UpdatePromptContent> {
  static final _bulletPattern = RegExp(r'^[-•*]');
  bool _dontShowAgain = false;

  late final List<String> _bullets = widget.update.body
      .split('\n')
      .map((l) => l.trim())
      .where((l) => _bulletPattern.hasMatch(l))
      .map((l) => l.substring(1).trim())
      .where((l) => l.isNotEmpty)
      .toList(growable: false);

  Future<void> _close({required bool install}) async {
    if (_dontShowAgain) {
      await UpdateService().dismissPromptFor(widget.update.tagName);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    if (install) autoUpdater.checkForUpdates();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final bodyColor = theme.typography.body?.color?.withValues(alpha: 0.85);

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 440),
      title: Text(l10n.updatePromptTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.updatePromptVersion(widget.update.tagName)),
          if (_bullets.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l10n.updatePromptWhatsNew,
              style: theme.typography.bodyStrong,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in _bullets)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 7, right: 8),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: theme.accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                line,
                                style: TextStyle(height: 1.4, color: bodyColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Checkbox(
            checked: _dontShowAgain,
            onChanged: (v) => setState(() => _dontShowAgain = v ?? false),
            content: Text(l10n.updatePromptDontShowAgain),
          ),
        ],
      ),
      actions: [
        Button(
          onPressed: () => _close(install: false),
          child: Text(l10n.updatePromptLater),
        ),
        FilledButton(
          onPressed: () => _close(install: true),
          child: Text(l10n.updatePromptUpdateNow),
        ),
      ],
    );
  }
}
