import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/UI%20sections/Settings/colorpicker.dart';
import 'package:screentime/sections/UI sections/Settings/theme_customization_model.dart';

// ============== SHARED HOVER MIXIN ==============
// Eliminates the repeated _isHovered + MouseRegion boilerplate found in every
// interactive widget.

mixin _HoverState<T extends StatefulWidget> on State<T> {
  bool isHovered = false;

  Widget buildHoverable({required Widget child}) => MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: child,
      );
}

// ============== THEME PRESET CARD ==============

class ThemePresetCard extends StatefulWidget {
  final CustomThemeData theme;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemePresetCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<ThemePresetCard> createState() => _ThemePresetCardState();
}

class _ThemePresetCardState extends State<ThemePresetCard>
    with _HoverState<ThemePresetCard> {
  @override
  Widget build(BuildContext context) {
    final ft = FluentTheme.of(context);

    return buildHoverable(
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 140,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? ft.accentColor.withValues(alpha: 0.15)
                : ft.inactiveBackgroundColor
                    .withValues(alpha: isHovered ? 0.5 : 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? ft.accentColor
                  : isHovered
                      ? ft.inactiveBackgroundColor
                      : Colors.transparent,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ColorDot(color: widget.theme.primaryAccent),
                  const SizedBox(width: 4),
                  ColorDot(color: widget.theme.secondaryAccent),
                  const SizedBox(width: 4),
                  ColorDot(color: widget.theme.successColor),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.theme.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: widget.isSelected ? ft.accentColor : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== COLOR DOT ==============

class ColorDot extends StatelessWidget {
  final Color color;

  const ColorDot({super.key, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      );
}

// ============== THEME EDITOR DIALOG ==============

class ThemeEditorDialog extends StatefulWidget {
  final CustomThemeData initialTheme;
  final ValueChanged<CustomThemeData> onSave;

  const ThemeEditorDialog({
    super.key,
    required this.initialTheme,
    required this.onSave,
  });

  @override
  State<ThemeEditorDialog> createState() => ThemeEditorDialogState();
}

class ThemeEditorDialogState extends State<ThemeEditorDialog> {
  late CustomThemeData _currentTheme;
  late final TextEditingController _nameController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.initialTheme;
    _nameController = TextEditingController(text: widget.initialTheme.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updateColor(String colorKey, Color color) => setState(
      () => _currentTheme = _currentTheme.updateColor(colorKey, color));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
      title: Row(
        children: [
          const Icon(FluentIcons.color, size: 20),
          const SizedBox(width: 12),
          Text(l10n.customizeTheme),
          const Spacer(),
          _LivePreviewBadge(
              color: _currentTheme.primaryAccent, label: l10n.preview),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Theme name
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextBox(
              controller: _nameController,
              placeholder: l10n.themeName,
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(FluentIcons.tag, size: 14),
              ),
            ),
          ),

          // Tabs
          SizedBox(
            height: 36,
            child: Row(
              children: [
                _TabButton(
                  label: l10n.brandColors,
                  icon: FluentIcons.color,
                  isSelected: _selectedTabIndex == 0,
                  onTap: () => setState(() => _selectedTabIndex = 0),
                ),
                const SizedBox(width: 8),
                _TabButton(
                  label: l10n.lightTheme,
                  icon: FluentIcons.sunny,
                  isSelected: _selectedTabIndex == 1,
                  onTap: () => setState(() => _selectedTabIndex = 1),
                ),
                const SizedBox(width: 8),
                _TabButton(
                  label: l10n.darkTheme,
                  icon: FluentIcons.clear_night,
                  isSelected: _selectedTabIndex == 2,
                  onTap: () => setState(() => _selectedTabIndex = 2),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              // IndexedStack keeps all three tab subtrees alive, avoiding
              // repeated build/dispose cycles when switching tabs.
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  _BrandColorsTab(
                      theme: _currentTheme, onColorChange: _updateColor),
                  _LightThemeTab(
                      theme: _currentTheme, onColorChange: _updateColor),
                  _DarkThemeTab(
                      theme: _currentTheme, onColorChange: _updateColor),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context),
        ),
        Button(
          child: Text(l10n.reset),
          onPressed: () => setState(() {
            _currentTheme = widget.initialTheme;
            _nameController.text = widget.initialTheme.name;
          }),
        ),
        FilledButton(
          child: Text(l10n.saveTheme),
          onPressed: () {
            final trimmed = _nameController.text.trim();
            widget.onSave(_currentTheme.copyWith(
              name: trimmed.isEmpty ? l10n.customTheme : trimmed,
            ));
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

// ============== LIVE PREVIEW BADGE ==============

class _LivePreviewBadge extends StatelessWidget {
  final Color color;
  final String label;

  const _LivePreviewBadge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      );
}

// ============== TAB BUTTON ==============

class _TabButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> with _HoverState<_TabButton> {
  @override
  Widget build(BuildContext context) {
    final ft = FluentTheme.of(context);

    return buildHoverable(
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? ft.accentColor.withValues(alpha: 0.15)
                : isHovered
                    ? ft.inactiveBackgroundColor.withValues(alpha: 0.5)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isSelected ? ft.accentColor : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: widget.isSelected ? ft.accentColor : null,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: widget.isSelected ? ft.accentColor : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== SHARED COLOR SECTION WIDGETS ==============

class _ColorSectionHeader extends StatelessWidget {
  final String title;
  final String description;

  const _ColorSectionHeader({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final ft = FluentTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ft.typography.body?.color)),
          const SizedBox(height: 2),
          Text(description,
              style:
                  TextStyle(fontSize: 11, color: ft.typography.caption?.color)),
        ],
      ),
    );
  }
}

class _ColorPickerRow extends StatelessWidget {
  final String label;
  final String? description;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const _ColorPickerRow({
    required this.label,
    this.description,
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ft = FluentTheme.of(context);
    final isDark = ft.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500)),
                if (description != null)
                  Text(description!,
                      style: TextStyle(
                          fontSize: 10, color: ft.typography.caption?.color)),
              ],
            ),
          ),

          // Color swatch
          GestureDetector(
            onTap: () => _showPicker(context),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Hex label
          GestureDetector(
            onTap: () => _showPicker(context),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 80,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: ft.inactiveBackgroundColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: ft.inactiveBackgroundColor, width: 1),
                ),
                child: Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final selected = await FluentColorPickerDialog.show(
      context: context,
      title: label,
      initialColor: color,
    );
    if (selected != null) onColorChanged(selected);
  }
}

// ============== TAB CONTENT WIDGETS ==============
// Each tab is a plain StatelessWidget; state lives in ThemeEditorDialog.

class _BrandColorsTab extends StatelessWidget {
  final CustomThemeData theme;
  final void Function(String, Color) onColorChange;

  const _BrandColorsTab({required this.theme, required this.onColorChange});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ColorSectionHeader(
            title: l10n.primaryColors, description: l10n.primaryColorsDesc),
        _ColorPickerRow(
            label: l10n.primaryAccent,
            description: l10n.primaryAccentDesc,
            color: theme.primaryAccent,
            onColorChanged: (c) => onColorChange('primaryAccent', c)),
        _ColorPickerRow(
            label: l10n.secondaryAccent,
            description: l10n.secondaryAccentDesc,
            color: theme.secondaryAccent,
            onColorChanged: (c) => onColorChange('secondaryAccent', c)),
        const SizedBox(height: 20),
        _ColorSectionHeader(
            title: l10n.semanticColors, description: l10n.semanticColorsDesc),
        _ColorPickerRow(
            label: l10n.successColor,
            description: l10n.successColorDesc,
            color: theme.successColor,
            onColorChanged: (c) => onColorChange('successColor', c)),
        _ColorPickerRow(
            label: l10n.warningColor,
            description: l10n.warningColorDesc,
            color: theme.warningColor,
            onColorChanged: (c) => onColorChange('warningColor', c)),
        _ColorPickerRow(
            label: l10n.errorColor,
            description: l10n.errorColorDesc,
            color: theme.errorColor,
            onColorChanged: (c) => onColorChange('errorColor', c)),
        const SizedBox(height: 20),
        _ThemePreviewCard(theme: theme, isDark: false),
      ],
    );
  }
}

class _LightThemeTab extends StatelessWidget {
  final CustomThemeData theme;
  final void Function(String, Color) onColorChange;

  const _LightThemeTab({required this.theme, required this.onColorChange});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ColorSectionHeader(
            title: l10n.backgroundColors,
            description: l10n.backgroundColorsLightDesc),
        _ColorPickerRow(
            label: l10n.background,
            description: l10n.backgroundDesc,
            color: theme.lightBackground,
            onColorChanged: (c) => onColorChange('lightBackground', c)),
        _ColorPickerRow(
            label: l10n.surface,
            description: l10n.surfaceDesc,
            color: theme.lightSurface,
            onColorChanged: (c) => onColorChange('lightSurface', c)),
        _ColorPickerRow(
            label: l10n.surfaceSecondary,
            description: l10n.surfaceSecondaryDesc,
            color: theme.lightSurfaceSecondary,
            onColorChanged: (c) => onColorChange('lightSurfaceSecondary', c)),
        _ColorPickerRow(
            label: l10n.border,
            description: l10n.borderDesc,
            color: theme.lightBorder,
            onColorChanged: (c) => onColorChange('lightBorder', c)),
        const SizedBox(height: 20),
        _ColorSectionHeader(
            title: l10n.textColors, description: l10n.textColorsLightDesc),
        _ColorPickerRow(
            label: l10n.textPrimary,
            description: l10n.textPrimaryDesc,
            color: theme.lightTextPrimary,
            onColorChanged: (c) => onColorChange('lightTextPrimary', c)),
        _ColorPickerRow(
            label: l10n.textSecondary,
            description: l10n.textSecondaryDesc,
            color: theme.lightTextSecondary,
            onColorChanged: (c) => onColorChange('lightTextSecondary', c)),
        const SizedBox(height: 20),
        _ThemePreviewCard(theme: theme, isDark: false),
      ],
    );
  }
}

class _DarkThemeTab extends StatelessWidget {
  final CustomThemeData theme;
  final void Function(String, Color) onColorChange;

  const _DarkThemeTab({required this.theme, required this.onColorChange});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ColorSectionHeader(
            title: l10n.backgroundColors,
            description: l10n.backgroundColorsDarkDesc),
        _ColorPickerRow(
            label: l10n.background,
            description: l10n.backgroundDesc,
            color: theme.darkBackground,
            onColorChanged: (c) => onColorChange('darkBackground', c)),
        _ColorPickerRow(
            label: l10n.surface,
            description: l10n.surfaceDesc,
            color: theme.darkSurface,
            onColorChanged: (c) => onColorChange('darkSurface', c)),
        _ColorPickerRow(
            label: l10n.surfaceSecondary,
            description: l10n.surfaceSecondaryDesc,
            color: theme.darkSurfaceSecondary,
            onColorChanged: (c) => onColorChange('darkSurfaceSecondary', c)),
        _ColorPickerRow(
            label: l10n.border,
            description: l10n.borderDesc,
            color: theme.darkBorder,
            onColorChanged: (c) => onColorChange('darkBorder', c)),
        const SizedBox(height: 20),
        _ColorSectionHeader(
            title: l10n.textColors, description: l10n.textColorsDarkDesc),
        _ColorPickerRow(
            label: l10n.textPrimary,
            description: l10n.textPrimaryDesc,
            color: theme.darkTextPrimary,
            onColorChanged: (c) => onColorChange('darkTextPrimary', c)),
        _ColorPickerRow(
            label: l10n.textSecondary,
            description: l10n.textSecondaryDesc,
            color: theme.darkTextSecondary,
            onColorChanged: (c) => onColorChange('darkTextSecondary', c)),
        const SizedBox(height: 20),
        _ThemePreviewCard(theme: theme, isDark: true),
      ],
    );
  }
}

// ============== THEME PREVIEW CARD ==============

class _ThemePreviewCard extends StatelessWidget {
  final CustomThemeData theme;
  final bool isDark;

  const _ThemePreviewCard({required this.theme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final background = theme.getBackground(isDark);
    final surface = theme.getSurface(isDark);
    final border = theme.getBorder(isDark);
    final textPrimary = theme.getTextPrimary(isDark);
    final textSecondary = theme.getTextSecondary(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.previewMode(isDark ? l10n.dark : l10n.light),
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.sampleCardTitle,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textPrimary)),
                const SizedBox(height: 4),
                Text(l10n.sampleSecondaryText,
                    style: TextStyle(fontSize: 11, color: textSecondary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _PreviewButton(
                        color: theme.primaryAccent, label: l10n.primary),
                    const SizedBox(width: 8),
                    _PreviewButton(
                        color: theme.successColor, label: l10n.success),
                    const SizedBox(width: 8),
                    _PreviewButton(color: theme.errorColor, label: l10n.error),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _PreviewSwatch(color: theme.primaryAccent, label: l10n.primary),
              _PreviewSwatch(
                  color: theme.secondaryAccent, label: l10n.secondary),
              _PreviewSwatch(color: theme.successColor, label: l10n.success),
              _PreviewSwatch(color: theme.warningColor, label: l10n.warning),
              _PreviewSwatch(color: theme.errorColor, label: l10n.error),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewButton extends StatelessWidget {
  final Color color;
  final String label;

  const _PreviewButton({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      );
}

class _PreviewSwatch extends StatelessWidget {
  final Color color;
  final String label;

  const _PreviewSwatch({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Container(
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(fontSize: 8),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      );
}
