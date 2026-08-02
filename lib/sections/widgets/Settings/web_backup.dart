// ─── Web Extension Backup / Restore ──────────────────────────────────────────
//
// Exports all chrome.storage.local data to a downloadable JSON file.
// Imports by letting the user pick a JSON file and restoring the keys.
//
// Web-only: returns SizedBox.shrink() on non-web platforms.

import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screentime/l10n/app_localizations.dart';

import 'web_backup_impl.dart'
    if (dart.library.io) 'web_backup_stub.dart';
import 'reusables.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────

class WebBackupSection extends StatefulWidget {
  const WebBackupSection({super.key});

  @override
  State<WebBackupSection> createState() => _WebBackupSectionState();
}

class _WebBackupSectionState extends State<WebBackupSection> {
  bool _exporting = false;
  bool _importing = false;

  // ── Export ─────────────────────────────────────────────────────────────────

  Future<void> _handleExport() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      await downloadStorageAsJson();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        displayInfoBar(context, builder: (ctx, close) => InfoBar(
          title: Text(l10n.webExportSuccessTitle),
          content: Text(l10n.webExportSuccessMessage),
          action: Button(onPressed: close, child: Text(l10n.ok)),
          severity: InfoBarSeverity.success,
        ));
      }
    } catch (e) {
      if (mounted) _showError('Export failed: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ── Import ─────────────────────────────────────────────────────────────────

  Future<void> _handleImport() async {
    if (_importing) return;

    final confirmed = await _showConfirmDialog();
    if (confirmed != true || !mounted) return;

    setState(() => _importing = true);
    try {
      final jsonText = await pickAndReadJsonFile();
      if (jsonText == null) {
        if (mounted) setState(() => _importing = false);
        return;
      }

      final count = await restoreStorageFromJson(jsonText);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        displayInfoBar(context, builder: (ctx, close) => InfoBar(
          title: Text(l10n.webImportSuccessTitle),
          content: Text(l10n.webImportSuccessMessage(count)),
          action: Button(onPressed: close, child: Text(l10n.ok)),
          severity: InfoBarSeverity.success,
        ));
      }
    } catch (e) {
      if (mounted) _showError('Import failed: $e');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<bool?> _showConfirmDialog() {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Row(
          children: [
            Icon(FluentIcons.warning, color: Colors.orange, size: 20),
            const SizedBox(width: 10),
            Text(l10n.webImportConfirmTitle),
          ],
        ),
        content: Text(l10n.webImportConfirmMessage),
        actions: [
          Button(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.orange),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.webImportConfirmButton),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    displayInfoBar(context, builder: (ctx, close) => InfoBar(
      title: Text(AppLocalizations.of(ctx)!.error),
      content: Text(message),
      action: Button(onPressed: close, child: Text(AppLocalizations.of(ctx)!.ok)),
      severity: InfoBarSeverity.error,
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    return SettingsCard(
      title: l10n.backupRestoreSection,
      icon: FluentIcons.cloud_upload,
      iconColor: Colors.blue,
      children: [
        SettingRow(
          title: l10n.exportDataTitle,
          description: l10n.webExportDataDescription,
          control: _ActionButton(
            icon: FluentIcons.cloud_upload,
            label: l10n.exportButton,
            color: Colors.blue,
            loading: _exporting,
            onPressed: _handleExport,
          ),
        ),
        SettingRow(
          title: l10n.importDataTitle,
          description: l10n.webImportDataDescription,
          showDivider: false,
          control: _ActionButton(
            icon: FluentIcons.cloud_download,
            label: l10n.importButton,
            color: Colors.green,
            loading: _importing,
            onPressed: _handleImport,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action button with loading spinner
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.loading,
    required this.onPressed,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hoverAlpha = _hovered ? 0.15 : 0.08;
    final borderAlpha = _hovered ? 0.6 : 0.3;

    return MouseRegion(
      cursor: widget.loading ? SystemMouseCursors.wait : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.loading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: hoverAlpha),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.color.withValues(alpha: borderAlpha),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.loading)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: ProgressRing(
                    strokeWidth: 1.5,
                    activeColor: widget.color,
                  ),
                )
              else
                Icon(widget.icon, size: 12, color: widget.color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
