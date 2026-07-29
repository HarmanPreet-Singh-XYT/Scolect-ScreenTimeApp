// ─── Extension Settings Tab ───────────────────────────────────────────────────
//
// Web-only settings page shown as the gear icon tab in the Browser view.

import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'browser_shared.dart';
import '../../../web/extension_settings.dart'
    if (dart.library.io) '../../../web/extension_settings_stub.dart';

class BrowserExtensionSettings extends StatefulWidget {
  final ValueChanged<ExtensionMode> onModeChanged;

  const BrowserExtensionSettings({
    super.key,
    required this.onModeChanged,
  });

  @override
  State<BrowserExtensionSettings> createState() => _BrowserExtensionSettingsState();
}

class _BrowserExtensionSettingsState extends State<BrowserExtensionSettings> {
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
    widget.onModeChanged(mode);
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

    if (_isLoading) return const Center(child: ProgressRing());

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Mode selector ─────────────────────────────────────────────────
          _SectionTitle(l10n.browserExtensionMode),
          const SizedBox(height: 12),
          ...ExtensionMode.values.map((mode) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ModeCard(
              mode: mode,
              selected: _mode == mode,
              saving: _saving,
              onTap: () => _saveMode(mode),
            ),
          )),

          const SizedBox(height: 24),

          // ── Desktop app URL (only when syncing to desktop) ────────────────
          if (_mode != ExtensionMode.standalone) ...[
            _SectionTitle(l10n.browserDesktopAppUrl),
            const SizedBox(height: 8),
            BrowserCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.browserDesktopAppUrlDesc,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.typography.caption?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
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
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── About ─────────────────────────────────────────────────────────
          _SectionTitle(l10n.browserAbout),
          const SizedBox(height: 8),
          BrowserCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AboutRow(l10n.browserAboutExtension, l10n.browserAboutExtensionValue),
                const SizedBox(height: 6),
                _AboutRow(l10n.browserAboutVersion, '1.0.0'),
                const SizedBox(height: 6),
                _AboutRow(l10n.browserAboutStorage, l10n.browserAboutStorageValue),
                const SizedBox(height: 6),
                _AboutRow(l10n.browserAboutHistory, l10n.browserAboutHistoryValue),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mode card ────────────────────────────────────────────────────────────────

class _ModeCard extends StatefulWidget {
  final ExtensionMode mode;
  final bool selected;
  final bool saving;
  final VoidCallback onTap;

  const _ModeCard({
    required this.mode,
    required this.selected,
    required this.saving,
    required this.onTap,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _hovered = false;

  static IconData _iconFor(ExtensionMode m) => switch (m) {
        ExtensionMode.standalone => FluentIcons.devices3,
        ExtensionMode.trackerOnly => FluentIcons.sync,
        ExtensionMode.hybrid => FluentIcons.combine,
      };

  static Color _colorFor(ExtensionMode m) => switch (m) {
        ExtensionMode.standalone => kBrowserBlue,
        ExtensionMode.trackerOnly => kBrowserGreen,
        ExtensionMode.hybrid => kBrowserPurple,
      };

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final color = _colorFor(widget.mode);
    final selected = widget.selected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.saving ? null : widget.onTap,
        child: AnimatedContainer(
          duration: kBrowserHoverDuration,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.08)
                : _hovered
                    ? theme.micaBackgroundColor.withValues(alpha: 0.5)
                    : theme.micaBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.4)
                  : theme.inactiveBackgroundColor.withValues(alpha: 0.5),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_iconFor(widget.mode), size: 16, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mode.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? color : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.mode.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.typography.caption?.color?.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (selected)
                Icon(FluentIcons.check_mark, size: 14, color: color)
              else
                const SizedBox(width: 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Text(
      text,
      style: theme.typography.bodyStrong?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;
  const _AboutRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.typography.caption?.color?.withValues(alpha: 0.5),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
