import 'package:flutter/material.dart';
import 'package:screentime/sections/UI sections/Settings/theme_customization_model.dart';

// ============== APP DESIGN ==============
//
// Thin wrapper around [CustomThemeData] that adds spacing/radius/animation
// constants and gradient helpers. [AppDesignConstants] has been merged here
// as static const members to remove duplication.

class AppDesign {
  const AppDesign(this.themeData);

  factory AppDesign.defaultTheme() =>
      const AppDesign(ThemePresets.defaultTheme);

  final CustomThemeData themeData;

  // ---- Brand colors (delegates to themeData) ----
  Color get primaryAccent => themeData.primaryAccent;
  Color get secondaryAccent => themeData.secondaryAccent;
  Color get successColor => themeData.successColor;
  Color get warningColor => themeData.warningColor;
  Color get errorColor => themeData.errorColor;

  // ---- Light theme ----
  Color get lightBackground => themeData.lightBackground;
  Color get lightSurface => themeData.lightSurface;
  Color get lightSurfaceSecondary => themeData.lightSurfaceSecondary;
  Color get lightBorder => themeData.lightBorder;
  Color get lightTextPrimary => themeData.lightTextPrimary;
  Color get lightTextSecondary => themeData.lightTextSecondary;

  // ---- Dark theme ----
  Color get darkBackground => themeData.darkBackground;
  Color get darkSurface => themeData.darkSurface;
  Color get darkSurfaceSecondary => themeData.darkSurfaceSecondary;
  Color get darkBorder => themeData.darkBorder;
  Color get darkTextPrimary => themeData.darkTextPrimary;
  Color get darkTextSecondary => themeData.darkTextSecondary;

  // ---- Mode-aware helpers (delegates to themeData) ----
  Color getBackground(bool isDark) => themeData.getBackground(isDark);
  Color getSurface(bool isDark) => themeData.getSurface(isDark);
  Color getSurfaceSecondary(bool isDark) =>
      themeData.getSurfaceSecondary(isDark);
  Color getBorder(bool isDark) => themeData.getBorder(isDark);
  Color getTextPrimary(bool isDark) => themeData.getTextPrimary(isDark);
  Color getTextSecondary(bool isDark) => themeData.getTextSecondary(isDark);

  // ---- Gradients ----
  LinearGradient get primaryGradient => LinearGradient(
        colors: [primaryAccent, secondaryAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient subtleGradient(bool isDark) => LinearGradient(
        colors: [
          primaryAccent.withValues(alpha: isDark ? 0.15 : 0.08),
          secondaryAccent.withValues(alpha: isDark ? 0.15 : 0.08),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ---- Spacing ----
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;

  // ---- Border radius ----
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;

  // ---- Animation durations ----
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animMedium = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 350);

  // ---- Sidebar ----
  static const double sidebarExpandedWidth = 280.0;
  static const double sidebarCollapsedWidth = 68.0;
}

// ---- Backward-compatibility alias ----
// Any code still importing AppDesignConstants continues to compile unchanged.
typedef AppDesignConstants = AppDesign;
