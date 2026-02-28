import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

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
      if (mounted)
        setState(() => _errorMessage = 'Failed to load clipboard: $e');
    }
  }

  void _validateJson(String text) {
    if (text.isEmpty) {
      setState(() => _errorMessage = null);
      return;
    }

    String? error;
    try {
      final json = jsonDecode(text);
      if (json is! Map<String, dynamic>) {
        error = 'Expected a JSON object';
      } else {
        final missing = _requiredFields.where((f) => !json.containsKey(f));
        if (missing.isNotEmpty) {
          error = 'Missing required field: ${missing.first}';
        }
      }
    } on FormatException {
      error = 'Invalid JSON format';
    }

    setState(() => _errorMessage = error);
  }

  bool get _canImport => _errorMessage == null && _controller.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return ContentDialog(
      title: const Row(
        children: [
          Icon(FluentIcons.paste, size: 20),
          SizedBox(width: 12),
          Text('Import from Clipboard'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste or edit the theme JSON data below:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextBox(
              controller: _controller,
              maxLines: 12,
              placeholder: 'Paste theme JSON here...',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              onChanged: _validateJson,
            ),
            const SizedBox(height: 12),
            _buildValidationStatus(theme),
          ],
        ),
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          onPressed: _canImport
              ? () {
                  widget.onImport(_controller.text);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Import'),
        ),
      ],
    );
  }

  Widget _buildValidationStatus(FluentThemeData theme) {
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
        text: 'Valid theme data',
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
