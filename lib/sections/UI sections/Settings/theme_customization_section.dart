import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/UI sections/Settings/theme_customization_model.dart';
import 'package:screentime/sections/UI sections/Settings/theme_provider.dart';
import 'package:screentime/adaptive_fluent/adaptive_theme_fluent_ui.dart';
import 'package:screentime/main.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import './theme_helpers.dart';
import './reusables.dart';
import 'package:screentime/sections/UI sections/Settings/hover_state_mixin.dart';

// ============== THEME CUSTOMIZATION SECTION ==============

class ThemeCustomizationSection extends StatefulWidget {
  const ThemeCustomizationSection({super.key});

  @override
  State<ThemeCustomizationSection> createState() =>
      _ThemeCustomizationSectionState();
}

class _ThemeCustomizationSectionState extends State<ThemeCustomizationSection> {
  void _refreshTheme(BuildContext context, CustomThemeData theme) {
    FluentAdaptiveTheme.of(context).setTheme(
      light: buildLightTheme(theme),
      dark: buildDarkTheme(theme),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeCustomizationProvider>();
    final ft = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SettingsCard(
      title: l10n.themeCustomization,
      icon: FluentIcons.color,
      iconColor: Colors.magenta,
      trailing: Text(
        provider.currentTheme.name,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w500, color: ft.accentColor),
      ),
      children: [
        // ---- Preset grid ----
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.chooseThemePreset,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ft.typography.body?.color)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ThemePresets.allPresets.map((preset) {
                  return ThemePresetCard(
                    key: ValueKey(preset.id),
                    theme: preset,
                    isSelected: provider.currentTheme.id == preset.id,
                    onTap: () async {
                      await provider.setTheme(preset);
                      if (mounted) _refreshTheme(context, preset);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // ---- Custom themes list ----
        if (provider.customThemes.isNotEmpty) ...[
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.yourCustomThemes,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ft.typography.body?.color)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(FluentIcons.download, size: 14),
                          onPressed: () => _importTheme(context, provider),
                        ),
                        IconButton(
                          icon: const Icon(FluentIcons.add, size: 14),
                          onPressed: () =>
                              _createNewCustomTheme(context, provider),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...provider.customThemes.map((ct) => _CustomThemeListItem(
                      key: ValueKey(ct.id),
                      theme: ct,
                      isSelected: provider.currentTheme.id == ct.id,
                      onTap: () async {
                        await provider.setTheme(ct);
                        if (mounted) _refreshTheme(context, ct);
                      },
                      onEdit: () => _editCustomTheme(context, provider, ct),
                      onDelete: () => _deleteCustomTheme(context, provider, ct),
                      onExport: () => _exportTheme(context, provider, ct),
                    )),
              ],
            ),
          ),
        ],

        const Divider(),

        // ---- Action rows ----
        Column(
          children: [
            SettingRow(
              title: l10n.createCustomTheme,
              description: l10n.designOwnColorScheme,
              control: FilledButton(
                onPressed: () => _createNewCustomTheme(context, provider),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.add, size: 12),
                    const SizedBox(width: 6),
                    Text(l10n.newTheme, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
            SettingRow(
              title: l10n.importTheme,
              description: l10n.importFromFile,
              showDivider: provider.customThemes.isNotEmpty,
              control: Button(
                onPressed: () => _importTheme(context, provider),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.download, size: 12),
                    const SizedBox(width: 6),
                    Text(l10n.import, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ---- Edit current (custom only) ----
        if (provider.currentTheme.isCustom)
          SettingRow(
            title: l10n.editCurrentTheme,
            description: l10n.customizeColorsFor(provider.currentTheme.name),
            showDivider: false,
            control: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Button(
                  onPressed: () =>
                      _exportTheme(context, provider, provider.currentTheme),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.share, size: 12),
                      const SizedBox(width: 6),
                      Text(l10n.export, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _editCustomTheme(
                      context, provider, provider.currentTheme),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.edit, size: 12),
                      const SizedBox(width: 6),
                      Text(l10n.edit, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ---- Theme management ----

  void _createNewCustomTheme(
      BuildContext context, ThemeCustomizationProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => ThemeEditorDialog(
        initialTheme: ThemePresets.defaultTheme.copyWith(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          name: l10n.customThemeNumber(provider.customThemes.length + 1),
          isCustom: true,
        ),
        onSave: (theme) async {
          await provider.addCustomTheme(theme);
          await provider.setTheme(theme);
          if (mounted) {
            _refreshTheme(context, theme);
            _showSuccess(context, l10n.themeCreatedSuccessfully);
          }
        },
      ),
    );
  }

  void _editCustomTheme(BuildContext context,
      ThemeCustomizationProvider provider, CustomThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => ThemeEditorDialog(
        initialTheme: theme,
        onSave: (updated) async {
          await provider.updateCustomTheme(updated);
          if (provider.currentTheme.id == theme.id && mounted) {
            _refreshTheme(context, updated);
          }
          if (mounted) _showSuccess(context, l10n.themeUpdatedSuccessfully);
        },
      ),
    );
  }

  void _deleteCustomTheme(BuildContext context,
      ThemeCustomizationProvider provider, CustomThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => ContentDialog(
        title: Text(l10n.deleteCustomTheme),
        content: Text(l10n.confirmDeleteTheme(theme.name)),
        actions: [
          Button(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0xffff0000)),
            ),
            child: Text(l10n.delete),
            onPressed: () async {
              await provider.deleteCustomTheme(theme.id);
              if (mounted) {
                _refreshTheme(context, provider.currentTheme);
                Navigator.pop(context);
                _showSuccess(context, l10n.themeDeletedSuccessfully);
              }
            },
          ),
        ],
      ),
    );
  }

  // ---- Import / Export ----

  Future<void> _exportTheme(BuildContext context,
      ThemeCustomizationProvider provider, CustomThemeData theme) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (_) => _ExportOptionsDialog(theme: theme),
      );
      if (result == null || !mounted) return;

      final json = provider.exportTheme(theme);
      final fileName = '${theme.name.replaceAll(' ', '_')}_theme.json';

      switch (result) {
        case 'file':
          await _saveThemeToFile(json, fileName);
          if (mounted) _showSuccess(context, l10n.themeExportedSuccessfully);
        case 'clipboard':
          await Clipboard.setData(ClipboardData(text: json));
          if (mounted) _showSuccess(context, l10n.themeCopiedToClipboard);
        case 'share':
          await _shareTheme(json, fileName);
      }
    } catch (e) {
      if (mounted) _showError(context, '${l10n.exportFailed}: $e');
    }
  }

  Future<void> _importTheme(
      BuildContext context, ThemeCustomizationProvider provider) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (_) => const _ImportOptionsDialog(),
      );
      if (result == null || !mounted) return;

      String? json;
      if (result == 'file') {
        json = await _loadThemeFromFile();
      } else if (result == 'clipboard') {
        json = (await Clipboard.getData('text/plain'))?.text;
      }

      if (json == null || json.isEmpty) {
        if (mounted) _showError(context, l10n.noThemeDataFound);
        return;
      }

      final imported = await provider.importTheme(json);
      if (imported != null) {
        await provider.setTheme(imported);
        if (mounted) {
          _refreshTheme(context, imported);
          _showSuccess(context, l10n.themeImportedSuccessfully(imported.name));
        }
      } else {
        if (mounted) _showError(context, l10n.invalidThemeFormat);
      }
    } catch (e) {
      if (mounted) _showError(context, '${l10n.importFailed}: $e');
    }
  }

  // ---- File helpers ----

  Future<void> _saveThemeToFile(String data, String fileName) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName')..writeAsStringSync(data);
      await Share.shareXFiles([XFile(file.path)], subject: 'Theme Export');
    } else {
      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save JSON file',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (outputPath == null) throw Exception('Save cancelled');
      await File(outputPath).writeAsString(data);
    }
  }

  Future<String?> _loadThemeFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    if (file.bytes != null) return utf8.decode(file.bytes!);
    if (file.path != null) return File(file.path!).readAsString();
    return null;
  }

  Future<void> _shareTheme(String data, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName')..writeAsStringSync(data);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Custom Theme',
      text: 'Check out my custom theme!',
    );
  }

  // ---- Feedback ----

  void _showSuccess(BuildContext context, String message) => displayInfoBar(
        context,
        builder: (_, __) => InfoBar(
          title: Text(message),
          severity: InfoBarSeverity.success,
        ),
      );

  void _showError(BuildContext context, String message) => displayInfoBar(
        context,
        builder: (_, __) => InfoBar(
          title: const Text('Error'),
          content: Text(message),
          severity: InfoBarSeverity.error,
        ),
      );
}

// ============== EXPORT OPTIONS DIALOG ==============

class _ExportOptionsDialog extends StatelessWidget {
  final CustomThemeData theme;

  const _ExportOptionsDialog({required this.theme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ContentDialog(
      title: Row(children: [
        const Icon(FluentIcons.share, size: 20),
        const SizedBox(width: 12),
        Text(l10n.exportTheme),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.chooseExportMethod, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 16),
          _OptionButton(
            icon: FluentIcons.save,
            label: l10n.saveAsFile,
            description: l10n.saveThemeAsJSONFile,
            onPressed: () => Navigator.pop(context, 'file'),
          ),
          const SizedBox(height: 12),
          _OptionButton(
            icon: FluentIcons.copy,
            label: l10n.copyToClipboard,
            description: l10n.copyThemeJSONToClipboard,
            onPressed: () => Navigator.pop(context, 'clipboard'),
          ),
          const SizedBox(height: 12),
          _OptionButton(
            icon: FluentIcons.share,
            label: l10n.share,
            description: l10n.shareThemeViaSystemSheet,
            onPressed: () => Navigator.pop(context, 'share'),
          ),
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

// ============== IMPORT OPTIONS DIALOG ==============

class _ImportOptionsDialog extends StatelessWidget {
  const _ImportOptionsDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ContentDialog(
      title: Row(children: [
        const Icon(FluentIcons.download, size: 20),
        const SizedBox(width: 12),
        Text(l10n.importTheme),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.chooseImportMethod, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 16),
          _OptionButton(
            icon: FluentIcons.open_file,
            label: l10n.loadFromFile,
            description: l10n.selectJSONFileFromDevice,
            onPressed: () => Navigator.pop(context, 'file'),
          ),
          const SizedBox(height: 12),
          _OptionButton(
            icon: FluentIcons.paste,
            label: l10n.pasteFromClipboard,
            description: l10n.importFromClipboardJSON,
            onPressed: () => Navigator.pop(context, 'clipboard'),
          ),
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

// ============== OPTION BUTTON ==============

class _OptionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onPressed;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onPressed,
  });

  @override
  State<_OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<_OptionButton>
    with HoverStateMixin<_OptionButton> {
  @override
  Widget build(BuildContext context) {
    final ft = FluentTheme.of(context);
    return buildHoverable(
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovered
                ? ft.accentColor.withValues(alpha: 0.1)
                : ft.inactiveBackgroundColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHovered
                  ? ft.accentColor.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ft.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(widget.icon, size: 20, color: ft.accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.label,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(widget.description,
                        style: TextStyle(
                            fontSize: 11, color: ft.typography.caption?.color)),
                  ],
                ),
              ),
              Icon(FluentIcons.chevron_right,
                  size: 16, color: ft.typography.caption?.color),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== CUSTOM THEME LIST ITEM ==============

class _CustomThemeListItem extends StatefulWidget {
  final CustomThemeData theme;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onExport;

  const _CustomThemeListItem({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onExport,
  });

  @override
  State<_CustomThemeListItem> createState() => _CustomThemeListItemState();
}

class _CustomThemeListItemState extends State<_CustomThemeListItem>
    with HoverStateMixin<_CustomThemeListItem> {
  @override
  Widget build(BuildContext context) {
    final ft = FluentTheme.of(context);
    return buildHoverable(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? ft.accentColor.withValues(alpha: 0.1)
                : ft.inactiveBackgroundColor
                    .withValues(alpha: isHovered ? 0.3 : 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isSelected ? ft.accentColor : Colors.transparent,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              ColorDot(color: widget.theme.primaryAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.theme.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(FluentIcons.share, size: 12),
                onPressed: widget.onExport,
              ),
              IconButton(
                icon: const Icon(FluentIcons.edit, size: 12),
                onPressed: widget.onEdit,
              ),
              IconButton(
                icon: const Icon(FluentIcons.delete, size: 12),
                onPressed: widget.onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
