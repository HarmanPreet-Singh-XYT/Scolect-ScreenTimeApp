import 'package:flutter/foundation.dart';
import 'settings_data_controller.dart';

/// Desktop-only global filter for which browser source's website usage is
/// currently being viewed. `null` means "All Browsers" (the combined total
/// across every connected browser plus any legacy untagged data recorded
/// before per-source tracking existed). A specific id restricts every
/// website-derived number in the app (Overview, Reports, Alerts & Limits,
/// Browser tab) to that one browser's data only.
///
/// This is a singleton (mirrors [AppDataStore]'s own pattern) so it can be
/// read from data-layer code that isn't wrapped in a BuildContext, while
/// still being registered as a ChangeNotifier in the widget tree so UI can
/// react to changes via Provider.
class BrowserSourceFilterProvider extends ChangeNotifier {
  static const String _settingKey = 'browser.selectedSourceFilter';

  static final BrowserSourceFilterProvider _instance =
      BrowserSourceFilterProvider._internal();
  factory BrowserSourceFilterProvider() => _instance;
  BrowserSourceFilterProvider._internal() {
    _selectedBrowserId = SettingsManager().getSetting(_settingKey) as String?;
  }

  String? _selectedBrowserId;

  /// The currently selected browser source id, or null for "All Browsers".
  String? get selectedBrowserId => _selectedBrowserId;

  void selectBrowser(String? browserId) {
    if (_selectedBrowserId == browserId) return;
    _selectedBrowserId = browserId;
    SettingsManager().updateSetting(_settingKey, browserId);
    notifyListeners();
  }

  /// Called when a previously-selected browser source is removed from the
  /// registry — falls back to "All Browsers" rather than silently filtering
  /// on an id that no longer exists.
  void clearIfSelected(String browserId) {
    if (_selectedBrowserId == browserId) selectBrowser(null);
  }
}
