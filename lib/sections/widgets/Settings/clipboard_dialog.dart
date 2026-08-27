import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:screentime/l10n/app_localizations.dart';

/// Enhanced clipboard import dialog with validation
class ClipboardImportDialog extends StatefulWidget {
  final ValueChanged<String> onImport;

  const ClipboardImportDialog({
    super.key,
    required this.onImport,
  });

  @override
  State<ClipboardImportDialog> createState() => _ClipboardImportDialogState();
}

class _ClipboardImportDialogState extends State<ClipboardImportDialog> {
  final _controller = TextEditingController();
  String? _errorMessage;

  static const _requiredFields = [
    'id',
    'name',
    'primaryAccent',
    'secondaryAccent',
    'lightBackground',
    'darkBackground',
  ];

  @override
  void initState() {
    super.initState();
    _loadFromClipboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadFromClipboard() async {
    try {
      final text = (await Clipboard.getData('text/plain'))?.text;
      if (text != null && mounted) {
        _controller.text = text;
        _validateJson(text);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _errorMessage = l10n.clipboardImportErrorLoadFailed(e.toString()));
      }
    }
  }

  void _validateJson(String text) {
    final l10n = AppLocalizations.of(context)!;
    if (text.isEmpty) {
      setState(() => _errorMessage = null);
      return;
    }

    String? error;
    try {
      final json = jsonDecode(text);
      if (json is! Map<String, dynamic>) {
        error = l10n.clipboardImportErrorNotJsonObject;
      } else {
        final missing = _requiredFields.where((f) => !json.containsKey(f));
        if (missing.isNotEmpty) {
          error = l10n.clipboardImportErrorMissingField(missing.first);
        }
      }
    } on FormatException {
      error = l10n.clipboardImportErrorInvalidJson;
    }

    setState(() => _errorMessage = error);
  }

  bool get _canImport => _errorMessage == null && _controller.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ContentDialog(
      title: Row(
        children: [
          const Icon(FluentIcons.paste, size: 20),
          const SizedBox(width: 12),
          Text(l10n.clipboardImportTitle),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.clipboardImportDescription,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextBox(
              controller: _controller,
              maxLines: 12,
              placeholder: l10n.clipboardImportPlaceholder,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              onChanged: _validateJson,
            ),
            const SizedBox(height: 12),
            _buildValidationStatus(theme, l10n),
          ],
        ),
      ),
      actions: [
        Button(
          child: Text(l10n.cancelButton),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          onPressed: _canImport
              ? () {
                  widget.onImport(_controller.text);
                  Navigator.pop(context);
                }
              : null,
          child: Text(l10n.import),
        ),
      ],
    );
  }

  Widget _buildValidationStatus(FluentThemeData theme, AppLocalizations l10n) {
    if (_errorMessage != null) {
      return _ValidationRow(
        icon: FluentIcons.error_badge,
        color: Colors.red,
        text: _errorMessage!,
        expanded: true,
      );
    }

    if (_controller.text.isNotEmpty) {
      return _ValidationRow(
        icon: FluentIcons.completed,
        color: Colors.green,
        text: l10n.clipboardImportValidData,
      );
    }

    return const SizedBox.shrink();
  }
}

class _ValidationRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final bool expanded;

  const _ValidationRow({
    required this.icon,
    required this.color,
    required this.text,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      style: TextStyle(fontSize: 11, color: color),
    );

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        if (expanded) Expanded(child: textWidget) else textWidget,
      ],
    );
  }
}
