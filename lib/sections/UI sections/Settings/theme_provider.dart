import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screentime/sections/UI sections/Settings/theme_customization_model.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';

// ============== THEME CUSTOMIZATION PROVIDER ==============

class ThemeCustomizationProvider extends ChangeNotifier {
  CustomThemeData _currentTheme = ThemePresets.defaultTheme;
  List<CustomThemeData> _customThemes = [];
  String _themeMode = ThemeOptions.defaultTheme;

  static const String _currentThemeKey = 'current_theme_id';
  static const String _customThemesKey = 'custom_themes';

  ThemeCustomizationProvider() {
    _loadThemes();
  }

  // ---- Getters ----

  CustomThemeData get currentTheme => _currentTheme;
  List<CustomThemeData> get customThemes => List.unmodifiable(_customThemes);
  String get themeMode => _themeMode;
  List<String> get availableThemeModes => ThemeOptions.available;

  AdaptiveThemeMode get adaptiveThemeMode {
    switch (_themeMode) {
      case ThemeOptions.dark:
        return AdaptiveThemeMode.dark;
      case ThemeOptions.light:
        return AdaptiveThemeMode.light;
      default:
        return AdaptiveThemeMode.system;
    }
  }

  // ---- Load ----

  Future<void> _loadThemes() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load custom themes
      final customThemesJson = prefs.getString(_customThemesKey);
      if (customThemesJson != null) {
        final List<dynamic> decoded = jsonDecode(customThemesJson) as List;
        _customThemes = decoded
            .map((json) =>
                CustomThemeData.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Resolve current theme: preset → custom → fallback
      final savedId = prefs.getString(_currentThemeKey);
      if (savedId != null) {
        _currentTheme = ThemePresets.getPresetById(savedId) ??
            _customThemes.cast<CustomThemeData?>().firstWhere(
                  (t) => t?.id == savedId,
                  orElse: () => null,
                ) ??
            ThemePresets.defaultTheme;
      }

      // Load theme mode
      final savedMode =
          SettingsManager().getSetting('theme.selected') as String?;
      _themeMode =
          (savedMode != null && ThemeOptions.available.contains(savedMode))
              ? savedMode
              : ThemeOptions.defaultTheme;

      notifyListeners();
    } catch (e, stack) {
      debugPrint('Error loading themes: $e\n$stack');
      _currentTheme = ThemePresets.defaultTheme;
      _themeMode = ThemeOptions.defaultTheme;
    }
  }

  // ---- Persistence helpers ----

  Future<void> _saveCurrentTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentThemeKey, _currentTheme.id);
    } catch (e) {
      debugPrint('Error saving current theme: $e');
    }
  }

  Future<void> _saveCustomThemes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _customThemesKey,
        jsonEncode(_customThemes.map((t) => t.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving custom themes: $e');
    }
  }

  // ---- Theme mode ----

  Future<void> setThemeMode(String mode) async {
    _themeMode = ThemeOptions.available.contains(mode)
        ? mode
        : ThemeOptions.defaultTheme;
    SettingsManager().updateSetting('theme.selected', _themeMode);
    notifyListeners();
  }

  // ---- Custom theme CRUD ----

  Future<void> setTheme(CustomThemeData theme) async {
    _currentTheme = theme;
    await _saveCurrentTheme();
    notifyListeners();
  }

  Future<void> addCustomTheme(CustomThemeData theme) async {
    _customThemes.add(theme);
    await _saveCustomThemes();
    notifyListeners();
  }

  Future<void> updateCustomTheme(CustomThemeData updated) async {
    final index = _customThemes.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;

    _customThemes[index] = updated;
    if (_currentTheme.id == updated.id) {
      _currentTheme = updated;
      await _saveCurrentTheme();
    }
    await _saveCustomThemes();
    notifyListeners();
  }

  Future<void> deleteCustomTheme(String themeId) async {
    _customThemes.removeWhere((t) => t.id == themeId);
    if (_currentTheme.id == themeId) {
      _currentTheme = ThemePresets.defaultTheme;
      await _saveCurrentTheme();
    }
    await _saveCustomThemes();
    notifyListeners();
  }

  Future<void> resetToDefault() async {
    _currentTheme = ThemePresets.defaultTheme;
    _themeMode = ThemeOptions.defaultTheme;
    await _saveCurrentTheme();
    SettingsManager().updateSetting('theme.selected', _themeMode);
    notifyListeners();
  }

  Future<void> clearAllCustomThemes() async {
    _customThemes.clear();
    if (_currentTheme.isCustom) {
      _currentTheme = ThemePresets.defaultTheme;
      await _saveCurrentTheme();
    }
    await _saveCustomThemes();
    notifyListeners();
  }

  // ---- Import / Export ----

  String exportTheme(CustomThemeData theme) => jsonEncode(theme.toJson());

  Future<CustomThemeData?> importTheme(String jsonString) async {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final imported = CustomThemeData.fromJson(json).copyWith(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        isCustom: true,
      );
      await addCustomTheme(imported);
      return imported;
    } catch (e) {
      debugPrint('Error importing theme: $e');
      return null;
    }
  }
}
