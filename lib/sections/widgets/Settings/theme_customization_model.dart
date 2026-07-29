import 'package:flutter/material.dart';

// ============== THEME MODEL ==============

class CustomThemeData {
  final String id;
  final String name;
  final bool isCustom;

  // Brand Colors
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color successColor;
  final Color warningColor;
  final Color errorColor;

  // Light Theme Colors
  final Color lightBackground;
  final Color lightSurface;
  final Color lightSurfaceSecondary;
  final Color lightBorder;
  final Color lightTextPrimary;
  final Color lightTextSecondary;

  // Dark Theme Colors
  final Color darkBackground;
  final Color darkSurface;
  final Color darkSurfaceSecondary;
  final Color darkBorder;
  final Color darkTextPrimary;
  final Color darkTextSecondary;

  const CustomThemeData({
    required this.id,
    required this.name,
    this.isCustom = false,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.successColor,
    required this.warningColor,
    required this.errorColor,
    required this.lightBackground,
    required this.lightSurface,
    required this.lightSurfaceSecondary,
    required this.lightBorder,
    required this.lightTextPrimary,
    required this.lightTextSecondary,
    required this.darkBackground,
    required this.darkSurface,
    required this.darkSurfaceSecondary,
    required this.darkBorder,
    required this.darkTextPrimary,
    required this.darkTextSecondary,
  });

  // ---- Serialization ----

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isCustom': isCustom,
        for (final entry in _colorMap().entries) entry.key: entry.value.value,
      };

  factory CustomThemeData.fromJson(Map<String, dynamic> json) =>
      CustomThemeData(
        id: json['id'] as String,
        name: json['name'] as String,
        isCustom: json['isCustom'] as bool? ?? false,
        primaryAccent: Color(json['primaryAccent'] as int),
        secondaryAccent: Color(json['secondaryAccent'] as int),
        successColor: Color(json['successColor'] as int),
        warningColor: Color(json['warningColor'] as int),
        errorColor: Color(json['errorColor'] as int),
        lightBackground: Color(json['lightBackground'] as int),
        lightSurface: Color(json['lightSurface'] as int),
        lightSurfaceSecondary: Color(json['lightSurfaceSecondary'] as int),
        lightBorder: Color(json['lightBorder'] as int),
        lightTextPrimary: Color(json['lightTextPrimary'] as int),
        lightTextSecondary: Color(json['lightTextSecondary'] as int),
        darkBackground: Color(json['darkBackground'] as int),
        darkSurface: Color(json['darkSurface'] as int),
        darkSurfaceSecondary: Color(json['darkSurfaceSecondary'] as int),
        darkBorder: Color(json['darkBorder'] as int),
        darkTextPrimary: Color(json['darkTextPrimary'] as int),
        darkTextSecondary: Color(json['darkTextSecondary'] as int),
      );

  // ---- Color Map (single source of truth for key-based access) ----

  /// Returns a map of all color keys to their current Color values.
  /// Used by [toJson], [getColor], and [updateColor] to eliminate repetitive
  /// switch statements across those three methods.
  Map<String, Color> _colorMap() => {
        'primaryAccent': primaryAccent,
        'secondaryAccent': secondaryAccent,
        'successColor': successColor,
        'warningColor': warningColor,
        'errorColor': errorColor,
        'lightBackground': lightBackground,
        'lightSurface': lightSurface,
        'lightSurfaceSecondary': lightSurfaceSecondary,
        'lightBorder': lightBorder,
        'lightTextPrimary': lightTextPrimary,
        'lightTextSecondary': lightTextSecondary,
        'darkBackground': darkBackground,
        'darkSurface': darkSurface,
        'darkSurfaceSecondary': darkSurfaceSecondary,
        'darkBorder': darkBorder,
        'darkTextPrimary': darkTextPrimary,
        'darkTextSecondary': darkTextSecondary,
      };

  /// Get color by key. Returns null for unknown keys.
  Color? getColor(String colorKey) => _colorMap()[colorKey];

  /// Returns a copy of this theme with one color replaced.
  CustomThemeData updateColor(String colorKey, Color color) {
    // Only create a new instance when the key is valid.
    if (!_colorMap().containsKey(colorKey)) return this;
    return copyWith(
      primaryAccent: colorKey == 'primaryAccent' ? color : null,
      secondaryAccent: colorKey == 'secondaryAccent' ? color : null,
      successColor: colorKey == 'successColor' ? color : null,
      warningColor: colorKey == 'warningColor' ? color : null,
      errorColor: colorKey == 'errorColor' ? color : null,
      lightBackground: colorKey == 'lightBackground' ? color : null,
      lightSurface: colorKey == 'lightSurface' ? color : null,
      lightSurfaceSecondary: colorKey == 'lightSurfaceSecondary' ? color : null,
      lightBorder: colorKey == 'lightBorder' ? color : null,
      lightTextPrimary: colorKey == 'lightTextPrimary' ? color : null,
      lightTextSecondary: colorKey == 'lightTextSecondary' ? color : null,
      darkBackground: colorKey == 'darkBackground' ? color : null,
      darkSurface: colorKey == 'darkSurface' ? color : null,
      darkSurfaceSecondary: colorKey == 'darkSurfaceSecondary' ? color : null,
      darkBorder: colorKey == 'darkBorder' ? color : null,
      darkTextPrimary: colorKey == 'darkTextPrimary' ? color : null,
      darkTextSecondary: colorKey == 'darkTextSecondary' ? color : null,
    );
  }

  // ---- copyWith ----

  CustomThemeData copyWith({
    String? id,
    String? name,
    bool? isCustom,
    Color? primaryAccent,
    Color? secondaryAccent,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
    Color? lightBackground,
    Color? lightSurface,
    Color? lightSurfaceSecondary,
    Color? lightBorder,
    Color? lightTextPrimary,
    Color? lightTextSecondary,
    Color? darkBackground,
    Color? darkSurface,
    Color? darkSurfaceSecondary,
    Color? darkBorder,
    Color? darkTextPrimary,
    Color? darkTextSecondary,
  }) =>
      CustomThemeData(
        id: id ?? this.id,
        name: name ?? this.name,
        isCustom: isCustom ?? this.isCustom,
        primaryAccent: primaryAccent ?? this.primaryAccent,
        secondaryAccent: secondaryAccent ?? this.secondaryAccent,
        successColor: successColor ?? this.successColor,
        warningColor: warningColor ?? this.warningColor,
        errorColor: errorColor ?? this.errorColor,
        lightBackground: lightBackground ?? this.lightBackground,
        lightSurface: lightSurface ?? this.lightSurface,
        lightSurfaceSecondary:
            lightSurfaceSecondary ?? this.lightSurfaceSecondary,
        lightBorder: lightBorder ?? this.lightBorder,
        lightTextPrimary: lightTextPrimary ?? this.lightTextPrimary,
        lightTextSecondary: lightTextSecondary ?? this.lightTextSecondary,
        darkBackground: darkBackground ?? this.darkBackground,
        darkSurface: darkSurface ?? this.darkSurface,
        darkSurfaceSecondary: darkSurfaceSecondary ?? this.darkSurfaceSecondary,
        darkBorder: darkBorder ?? this.darkBorder,
        darkTextPrimary: darkTextPrimary ?? this.darkTextPrimary,
        darkTextSecondary: darkTextSecondary ?? this.darkTextSecondary,
      );

  // ---- Convenience helpers used by AppDesign ----

  Color getBackground(bool isDark) => isDark ? darkBackground : lightBackground;
  Color getSurface(bool isDark) => isDark ? darkSurface : lightSurface;
  Color getSurfaceSecondary(bool isDark) =>
      isDark ? darkSurfaceSecondary : lightSurfaceSecondary;
  Color getBorder(bool isDark) => isDark ? darkBorder : lightBorder;
  Color getTextPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  Color getTextSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
}

// ============== THEME PRESETS ==============

class ThemePresets {
  ThemePresets._(); // prevent instantiation

  static const CustomThemeData defaultTheme = CustomThemeData(
    id: 'default',
    name: 'Default',
    primaryAccent: Color(0xFF6366F1),
    secondaryAccent: Color(0xFF8B5CF6),
    successColor: Color(0xFF10B981),
    warningColor: Color(0xFFF59E0B),
    errorColor: Color(0xFFEF4444),
    lightBackground: Color(0xFFEEF2F7),
    lightSurface: Color(0xFFFFFFFF),
    lightSurfaceSecondary: Color(0xFFE6EDF7),
    lightBorder: Color(0xFFCBD5E1),
    lightTextPrimary: Color(0xFF0F172A),
    lightTextSecondary: Color(0xFF475569),
    darkBackground: Color(0xFF0A0F1C),
    darkSurface: Color(0xFF141D2D),
    darkSurfaceSecondary: Color(0xFF121822),
    darkBorder: Color(0xFF1F2A3B),
    darkTextPrimary: Color(0xFFE0E5EB),
    darkTextSecondary: Color(0xFF7A8B9B),
  );

  static const CustomThemeData oceanBlue = CustomThemeData(
    id: 'ocean_blue',
    name: 'Ocean Blue',
    primaryAccent: Color(0xFF0EA5E9),
    secondaryAccent: Color(0xFF06B6D4),
    successColor: Color(0xFF14B8A6),
    warningColor: Color(0xFFFBBF24),
    errorColor: Color(0xFFF87171),
    lightBackground: Color(0xFFEFF6FF),
    lightSurface: Color(0xFFFFFFFF),
    lightSurfaceSecondary: Color(0xFFDCEFFE),
    lightBorder: Color(0xFFBAE6FD),
    lightTextPrimary: Color(0xFF0C4A6E),
    lightTextSecondary: Color(0xFF475569),
    darkBackground: Color(0xFF082F49),
    darkSurface: Color(0xFF0E4C6D),
    darkSurfaceSecondary: Color(0xFF0A3A57),
    darkBorder: Color(0xFF155E85),
    darkTextPrimary: Color(0xFFE0F2FE),
    darkTextSecondary: Color(0xFF7DD3FC),
  );

  static const CustomThemeData forestGreen = CustomThemeData(
    id: 'forest_green',
    name: 'Forest Green',
    primaryAccent: Color(0xFF10B981),
    secondaryAccent: Color(0xFF059669),
    successColor: Color(0xFF22C55E),
    warningColor: Color(0xFFF59E0B),
    errorColor: Color(0xFFEF4444),
    lightBackground: Color(0xFFF0FDF4),
    lightSurface: Color(0xFFFFFFFF),
    lightSurfaceSecondary: Color(0xFFDCFCE7),
    lightBorder: Color(0xFFBBF7D0),
    lightTextPrimary: Color(0xFF064E3B),
    lightTextSecondary: Color(0xFF475569),
    darkBackground: Color(0xFF022C22),
    darkSurface: Color(0xFF064E3B),
    darkSurfaceSecondary: Color(0xFF043A2E),
    darkBorder: Color(0xFF065F46),
    darkTextPrimary: Color(0xFFD1FAE5),
    darkTextSecondary: Color(0xFF6EE7B7),
  );

  static const CustomThemeData sunsetOrange = CustomThemeData(
    id: 'sunset_orange',
    name: 'Sunset Orange',
    primaryAccent: Color(0xFFF97316),
    secondaryAccent: Color(0xFFEA580C),
    successColor: Color(0xFF10B981),
    warningColor: Color(0xFFFBBF24),
    errorColor: Color(0xFFEF4444),
    lightBackground: Color(0xFFFFF7ED),
    lightSurface: Color(0xFFFFFFFF),
    lightSurfaceSecondary: Color(0xFFFFEDD5),
    lightBorder: Color(0xFFFED7AA),
    lightTextPrimary: Color(0xFF7C2D12),
    lightTextSecondary: Color(0xFF475569),
    darkBackground: Color(0xFF431407),
    darkSurface: Color(0xFF7C2D12),
    darkSurfaceSecondary: Color(0xFF5A1F0D),
    darkBorder: Color(0xFF9A3412),
    darkTextPrimary: Color(0xFFFED7AA),
    darkTextSecondary: Color(0xFFFB923C),
  );

  static const CustomThemeData purpleDream = CustomThemeData(
    id: 'purple_dream',
    name: 'Purple Dream',
    primaryAccent: Color(0xFFA855F7),
    secondaryAccent: Color(0xFF9333EA),
    successColor: Color(0xFF10B981),
    warningColor: Color(0xFFF59E0B),
    errorColor: Color(0xFFEF4444),
    lightBackground: Color(0xFFFAF5FF),
    lightSurface: Color(0xFFFFFFFF),
    lightSurfaceSecondary: Color(0xFFF3E8FF),
    lightBorder: Color(0xFFE9D5FF),
    lightTextPrimary: Color(0xFF581C87),
    lightTextSecondary: Color(0xFF475569),
    darkBackground: Color(0xFF3B0764),
    darkSurface: Color(0xFF581C87),
    darkSurfaceSecondary: Color(0xFF4A1472),
    darkBorder: Color(0xFF6B21A8),
    darkTextPrimary: Color(0xFFF3E8FF),
    darkTextSecondary: Color(0xFFD8B4FE),
  );

  static const CustomThemeData rosePink = CustomThemeData(
    id: 'rose_pink',
    name: 'Rose Pink',
    primaryAccent: Color(0xFFF43F5E),
    secondaryAccent: Color(0xFFE11D48),
    successColor: Color(0xFF10B981),
    warningColor: Color(0xFFF59E0B),
    errorColor: Color(0xFFEF4444),
    lightBackground: Color(0xFFFFF1F2),
    lightSurface: Color(0xFFFFFFFF),
    lightSurfaceSecondary: Color(0xFFFFE4E6),
    lightBorder: Color(0xFFFECDD3),
    lightTextPrimary: Color(0xFF881337),
    lightTextSecondary: Color(0xFF475569),
    darkBackground: Color(0xFF4C0519),
    darkSurface: Color(0xFF881337),
    darkSurfaceSecondary: Color(0xFF6B0E28),
    darkBorder: Color(0xFF9F1239),
    darkTextPrimary: Color(0xFFFFE4E6),
    darkTextSecondary: Color(0xFFFDA4AF),
  );

  static const CustomThemeData monochrome = CustomThemeData(
    id: 'monochrome',
    name: 'Monochrome',
    primaryAccent: Color(0xFF525252),
    secondaryAccent: Color(0xFF404040),
    successColor: Color(0xFF737373),
    warningColor: Color(0xFFA3A3A3),
    errorColor: Color(0xFF262626),
    lightBackground: Color(0xFFFAFAFA),
    lightSurface: Color(0xFFFFFFFF),
    lightSurfaceSecondary: Color(0xFFF5F5F5),
    lightBorder: Color(0xFFE5E5E5),
    lightTextPrimary: Color(0xFF171717),
    lightTextSecondary: Color(0xFF525252),
    darkBackground: Color(0xFF0A0A0A),
    darkSurface: Color(0xFF171717),
    darkSurfaceSecondary: Color(0xFF0F0F0F),
    darkBorder: Color(0xFF262626),
    darkTextPrimary: Color(0xFFFAFAFA),
    darkTextSecondary: Color(0xFFA3A3A3),
  );

  /// All built-in presets in display order.
  static const List<CustomThemeData> allPresets = [
    defaultTheme,
    oceanBlue,
    forestGreen,
    sunsetOrange,
    purpleDream,
    rosePink,
    monochrome,
  ];

  // O(1) lookup map — built once, lazily.
  static final Map<String, CustomThemeData> _presetsById = {
    for (final p in allPresets) p.id: p,
  };

  static CustomThemeData? getPresetById(String id) => _presetsById[id];
}
