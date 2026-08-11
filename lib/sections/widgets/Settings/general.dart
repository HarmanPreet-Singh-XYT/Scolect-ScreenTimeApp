import 'package:screentime/utils/platform_utils.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/settings.dart';
import 'package:screentime/sections/widgets/Settings/reusables.dart';
import 'package:screentime/sections/widgets/Settings/theme_provider.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/web/extension_settings.dart'
    if (dart.library.io) 'package:screentime/web/extension_settings_stub.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kAnimDuration = Duration(milliseconds: 150);
final _kBorderRadius6 = BorderRadius.circular(6);

const _kFirstRadius = BorderRadius.only(
  topLeft: Radius.circular(5),
  bottomLeft: Radius.circular(5),
);
const _kLastRadius = BorderRadius.only(
  topRight: Radius.circular(5),
  bottomRight: Radius.circular(5),
);

// ============== GENERAL SECTION ==============

class GeneralSection extends StatelessWidget {
  final ValueChanged<Locale> setLocale;

  const GeneralSection({super.key, required this.setLocale});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final themeProvider = context.watch<ThemeCustomizationProvider>();

    final languageValue = settings.languageOptions
            .any((lang) => lang['code'] == settings.language)
        ? settings.language
        : 'en';

    return SettingsCard(
      title: l10n.generalSection,
      icon: FluentIcons.settings,
      children: [
        if (kIsWeb) ...[
          const _ExtensionModeCard(),
          const SizedBox(height: 16),
        ],
        SettingRow(
          title: l10n.themeTitle,
          description: l10n.themeDescription,
          control: _CompactThemeSelector(
            currentMode: themeProvider.themeMode,
            onModeChanged: themeProvider.setThemeMode,
            l10n: l10n,
          ),
        ),
        SettingRow(
          title: l10n.languageTitle,
          description: l10n.languageDescription,
          control: _SettingsComboBox<String>(
            value: languageValue,
            items: settings.languageOptions,
            labelBuilder: (lang) => lang['name']!,
            valueKey: 'code',
            onChanged: (value) {
              settings.updateSetting('language', value);
              setLocale(Locale(value));
            },
          ),
        ),
        SettingRow(
          title: l10n.voiceGenderTitle,
          description: l10n.voiceGenderDescription,
          control: _SettingsComboBox<String>(
            value: settings.voiceGender,
            items: settings.voiceGenderOptions,
            labelBuilder: (gender) => gender['labelKey'] == 'voiceGenderMale'
                ? l10n.voiceGenderMale
                : l10n.voiceGenderFemale,
            valueKey: 'value',
            onChanged: (value) => settings.updateSetting('voiceGender', value),
          ),
        ),
        if (!kIsWeb)
          SettingRow(
            title: l10n.trackingModeTitle,
            description: l10n.trackingModeDescription,
            control: _TrackingModeSelector(l10n: l10n),
          ),
        SettingRow(
          title: l10n.dailyResetTimeTitle,
          description: l10n.dailyResetTimeDescription,
          control: ComboBox<int>(
            value: settings.resetHour,
            items: List.generate(24, (i) {
              final hour = i == 0 ? 12 : (i > 12 ? i - 12 : i);
              final period = i < 12 ? 'AM' : 'PM';
              return ComboBoxItem(
                value: i,
                child: Text('$hour:00 $period'),
              );
            }),
            onChanged: (v) {
              if (v != null) {
                settings.updateSetting('resetHour', v);
              }
            },
          ),
        ),
        if (PlatformUtils.isMacOS)
          SettingRow(
            title: l10n.launchAtStartupTitle,
            description: l10n.launchAtStartupDescription,
            showDivider: false,
            control: ToggleSwitch(
              checked: settings.launchAtStartupVar,
              onChanged: (value) =>
                  settings.updateSetting('launchAtStartup', value),
            ),
          ),
        if (PlatformUtils.isWindows)
          SettingRow(
            title: l10n.launchMinimizedTitle,
            description: l10n.launchMinimizedDescription,
            showDivider: false,
            control: ToggleSwitch(
              checked: settings.launchAsMinimized,
              onChanged: (value) =>
                  settings.updateSetting('launchAsMinimized', value),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Settings ComboBox
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsComboBox<T> extends StatelessWidget {
  final T value;
  final List<Map<String, String>> items;
  final String Function(Map<String, String>) labelBuilder;
  final String valueKey;
  final ValueChanged<T> onChanged;

  const _SettingsComboBox({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.valueKey,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: ComboBox<T>(
        value: value,
        isExpanded: true,
        items: [
          for (final item in items)
            ComboBoxItem<T>(
              value: item[valueKey]! as T,
              child: Text(
                labelBuilder(item),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tracking Mode Selector
// ─────────────────────────────────────────────────────────────────────────────

class _TrackingModeSelector extends StatelessWidget {
  final AppLocalizations l10n;

  const _TrackingModeSelector({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isPrecise = settings.trackingMode == TrackingModeOptions.precise;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SegmentedButtonGroup(
          children: [
            _SegmentedButton(
              icon: FluentIcons.clock,
              tooltip: l10n.trackingModePolling,
              isSelected: !isPrecise,
              onTap: () => settings.updateSetting(
                  'trackingMode', TrackingModeOptions.polling),
              position: _SegmentPosition.first,
            ),
            _SegmentedButton(
              icon: FluentIcons.bullseye,
              tooltip: l10n.trackingModePrecise,
              isSelected: isPrecise,
              onTap: () => settings.updateSetting(
                  'trackingMode', TrackingModeOptions.precise),
              position: _SegmentPosition.last,
            ),
          ],
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: isPrecise
              ? l10n.trackingModePreciseHint
              : l10n.trackingModePollingHint,
          child: Icon(
            isPrecise ? FluentIcons.warning : FluentIcons.info,
            size: 14,
            color: isPrecise ? Colors.orange : Colors.grey[80],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact Theme Selector
// ─────────────────────────────────────────────────────────────────────────────

class _CompactThemeSelector extends StatelessWidget {
  final String currentMode;
  final ValueChanged<String> onModeChanged;
  final AppLocalizations l10n;

  const _CompactThemeSelector({
    required this.currentMode,
    required this.onModeChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return _SegmentedButtonGroup(
      children: [
        _SegmentedButton(
          icon: FluentIcons.sunny,
          tooltip: l10n.themeLight,
          isSelected: currentMode == ThemeOptions.light,
          onTap: () => onModeChanged(ThemeOptions.light),
          position: _SegmentPosition.first,
        ),
        _SegmentedButton(
          icon: FluentIcons.clear_night,
          tooltip: l10n.themeDark,
          isSelected: currentMode == ThemeOptions.dark,
          onTap: () => onModeChanged(ThemeOptions.dark),
          position: _SegmentPosition.middle,
        ),
        _SegmentedButton(
          icon: FluentIcons.devices2,
          tooltip: l10n.themeSystem,
          isSelected: currentMode == ThemeOptions.system,
          onTap: () => onModeChanged(ThemeOptions.system),
          position: _SegmentPosition.last,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Unified Segmented Button Group & Button
// ─────────────────────────────────────────────────────────────────────────────

enum _SegmentPosition { first, middle, last }

class _SegmentedButtonGroup extends StatelessWidget {
  final List<Widget> children;

  const _SegmentedButtonGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: _kBorderRadius6,
        border: Border.all(
          color: theme.inactiveBackgroundColor.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _SegmentedButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;
  final _SegmentPosition position;

  const _SegmentedButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
    this.position = _SegmentPosition.middle,
  });

  @override
  State<_SegmentedButton> createState() => _SegmentedButtonState();
}

class _SegmentedButtonState extends State<_SegmentedButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final bodyColor = theme.typography.body?.color;

    final Color bgColor;
    final Color iconColor;

    if (widget.isSelected) {
      bgColor = theme.accentColor;
      iconColor = Colors.white;
    } else if (_isHovering) {
      bgColor = theme.inactiveBackgroundColor.withValues(alpha: 0.5);
      iconColor = bodyColor ?? Colors.white;
    } else {
      bgColor = Colors.transparent;
      iconColor = bodyColor?.withValues(alpha: 0.7) ?? Colors.grey[100];
    }

    final borderRadius = switch (widget.position) {
      _SegmentPosition.first => _kFirstRadius,
      _SegmentPosition.last => _kLastRadius,
      _SegmentPosition.middle => BorderRadius.zero,
    };

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: _kAnimDuration,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: borderRadius,
            ),
            child: Icon(widget.icon, size: 14, color: iconColor),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Extension Mode Selector Card (Web Only)
// ─────────────────────────────────────────────────────────────────────────────

class _ExtensionModeCard extends StatefulWidget {
  const _ExtensionModeCard();

  @override
  State<_ExtensionModeCard> createState() => _ExtensionModeCardState();
}

class _ExtensionModeCardState extends State<_ExtensionModeCard> {
  final _settings = ExtensionSettings();
  final _urlController = TextEditingController();
  ExtensionMode _mode = ExtensionMode.standalone;
  bool _isLoading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _settings.load();
    if (!mounted) return;
    setState(() {
      _mode = _settings.mode;
      _urlController.text = _settings.desktopUrl;
      _isLoading = false;
    });
  }

  Future<void> _saveMode(ExtensionMode mode) async {
    setState(() => _saving = true);
    await _settings.setMode(mode);
    if (!mounted) return;
    setState(() {
      _mode = mode;
      _saving = false;
    });
  }

  Future<void> _saveUrl() async {
    await _settings.setDesktopUrl(_urlController.text.trim());
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    displayInfoBar(context, builder: (ctx, close) => InfoBar(
      title: Text(l10n.browserDesktopUrlSaved),
      action: Button(onPressed: close, child: Text(l10n.ok)),
    ));
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) return const SizedBox(height: 100, child: Center(child: ProgressRing()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingRow(
          title: l10n.browserExtensionMode,
          description: _mode.description,
          control: SizedBox(
            width: 130,
            child: ComboBox<ExtensionMode>(
              value: _mode,
              isExpanded: true,
              items: ExtensionMode.values
                  .map((m) => ComboBoxItem<ExtensionMode>(
                        value: m,
                        child: Text(m.label, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (mode) {
                if (mode != null && !_saving) _saveMode(mode);
              },
            ),
          ),
        ),
        if (_mode != ExtensionMode.standalone) ...[
          const SizedBox(height: 8),
          SettingRow(
            title: l10n.browserDesktopAppUrl,
            description: l10n.browserDesktopAppUrlDesc,
            showDivider: true,
            control: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  child: TextBox(
                    controller: _urlController,
                    placeholder: 'http://localhost:46000',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _saveUrl,
                  child: Text(l10n.saveButton),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
