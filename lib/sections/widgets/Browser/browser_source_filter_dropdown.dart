// ─── Browser Source Filter Dropdown ───────────────────────────────────────────
//
// Desktop-only titlebar control that switches every website-derived number in
// the app (Overview, Reports, Alerts & Limits, Browser tab) to show either
// the combined total across all connected browsers, or just one specific
// browser's data. Mirrors PrivateModeToggleButton's role as a titlebar
// control surface that affects multiple pages at once.
//
// Hidden entirely until at least one browser extension has ever synced, since
// there's nothing to choose between otherwise.

import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/browser_source_filter.dart';

IconData iconForBrowser(String detectedBrowser) => switch (detectedBrowser) {
      'Chrome' => FluentIcons.globe,
      'Edge' => FluentIcons.globe,
      'Firefox' => FluentIcons.globe,
      'Brave' => FluentIcons.globe,
      'Opera' => FluentIcons.globe,
      'Safari' => FluentIcons.globe,
      _ => FluentIcons.unknown,
    };

class BrowserSourceFilterDropdown extends StatefulWidget {
  final bool isDark;

  const BrowserSourceFilterDropdown({super.key, this.isDark = false});

  @override
  State<BrowserSourceFilterDropdown> createState() =>
      _BrowserSourceFilterDropdownState();
}

class _BrowserSourceFilterDropdownState
    extends State<BrowserSourceFilterDropdown> {
  final _filter = BrowserSourceFilterProvider();
  final _dataStore = AppDataStore();

  @override
  void initState() {
    super.initState();
    _filter.addListener(_onChanged);
    _dataStore.addListener(_onChanged);
  }

  @override
  void dispose() {
    _filter.removeListener(_onChanged);
    _dataStore.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sources = _dataStore.browserSources;
    // Nothing to switch between yet — stay out of the way.
    if (sources.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final selectedId = _filter.selectedBrowserId;
    final selected = selectedId == null
        ? null
        : sources.where((s) => s.id == selectedId).firstOrNull;
    // The previously selected browser was removed from the registry — fall
    // back to "All Browsers" rather than silently filtering on a stale id.
    if (selectedId != null && selected == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _filter.selectBrowser(null);
      });
    }

    final label = selected?.localizedLabel(l10n) ?? l10n.browserSourceAllBrowsers;
    final icon = selected == null
        ? FluentIcons.devices3
        : iconForBrowser(selected.detectedBrowser);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropDownButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        items: [
          MenuFlyoutItem(
            leading: Icon(
              FluentIcons.devices3,
              size: 14,
              color: selectedId == null ? theme.accentColor : null,
            ),
            text: Text(
              l10n.browserSourceAllBrowsers,
              style: TextStyle(
                fontWeight: selectedId == null ? FontWeight.w600 : FontWeight.normal,
                color: selectedId == null ? theme.accentColor : null,
              ),
            ),
            onPressed: () => _filter.selectBrowser(null),
          ),
          for (final source in sources)
            MenuFlyoutItem(
              leading: Icon(
                iconForBrowser(source.detectedBrowser),
                size: 14,
                color: selectedId == source.id ? theme.accentColor : null,
              ),
              text: Text(
                source.localizedLabel(l10n),
                style: TextStyle(
                  fontWeight:
                      selectedId == source.id ? FontWeight.w600 : FontWeight.normal,
                  color: selectedId == source.id ? theme.accentColor : null,
                ),
              ),
              onPressed: () => _filter.selectBrowser(source.id),
            ),
        ],
      ),
    );
  }
}
