import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screentime/sections/widgets/Settings/theme_customization_model.dart';
import 'package:screentime/sections/widgets/Settings/theme_provider.dart';

// ============================================================================
// DYNAMIC APP DESIGN - Works with ThemeCustomizationProvider
// ============================================================================

class AppDesign {
  final CustomThemeData _themeData;

  const AppDesign._(this._themeData);

  // Static method to get current AppDesign from context
  static AppDesign of(BuildContext context) {
    final themeProvider = context.watch<ThemeCustomizationProvider>();
    return AppDesign._(themeProvider.currentTheme);
  }

  // Static method to read (without listening) - use for one-time reads
  static AppDesign read(BuildContext context) {
    final themeProvider = context.read<ThemeCustomizationProvider>();
    return AppDesign._(themeProvider.currentTheme);
  }

  // Brand Colors
  Color get primaryAccent => _themeData.primaryAccent;
  Color get secondaryAccent => _themeData.secondaryAccent;
  Color get successColor => _themeData.successColor;
  Color get warningColor => _themeData.warningColor;
  Color get errorColor => _themeData.errorColor;

  // Light Theme Colors
  static Color get lightBackground => const Color(0xFFEEF2F7);
  static Color get lightSurface => const Color(0xFFFFFFFF);
  static Color get lightSurfaceSecondary => const Color(0xFFE6EDF7);
  static Color get lightBorder => const Color(0xFFCBD5E1);
  Color get lightTextPrimary => _themeData.lightTextPrimary;
  Color get lightTextSecondary => _themeData.lightTextSecondary;

  // Dark Theme Colors
  static Color get darkBackground => const Color(0xFF0A0F1C);
  static Color get darkSurface => const Color(0xFF141D2D);
  static Color get darkSurfaceSecondary => const Color(0xFF121822);
  static Color get darkBorder => const Color(0xFF1F2A3B);
  Color get darkTextPrimary => _themeData.darkTextPrimary;
  Color get darkTextSecondary => _themeData.darkTextSecondary;

  // Spacing (static - doesn't change with theme)
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;

  // Border Radius (static)
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;

  // Font sizes (static) — use these instead of ad hoc literals so text
  // stays on one scale across sections.
  static const double fontXs = 11.0;
  static const double fontSm = 12.0;
  static const double fontMd = 13.0;
  static const double fontLg = 14.0;
  static const double fontXl = 16.0;
  static const double fontXxl = 18.0;

  // Animations (static)
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animMedium = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 350);

  // Sidebar (static)
  static const double sidebarExpandedWidth = 280.0;
  static const double sidebarCollapsedWidth = 68.0;

  // Card elevation (static) — pair a blurRadius with an alpha so card
  // shadows read consistently at rest vs. on hover.
  static const double shadowBlurRest = 8.0;
  static const double shadowBlurHover = 16.0;
  static const double shadowAlphaRest = 0.15;
  static const double shadowAlphaHover = 0.3;

  List<BoxShadow> cardShadow(Color color, {bool hovered = false}) => [
        BoxShadow(
          color: color.withValues(
            alpha: hovered ? shadowAlphaHover : shadowAlphaRest,
          ),
          blurRadius: hovered ? shadowBlurHover : shadowBlurRest,
          offset: const Offset(0, 4),
        ),
      ];

  /// Plain ambient elevation for surfaces resting on the page background
  /// (not a colored hover glow) — a subtle dark shadow lifting a card off
  /// its surroundings.
  static const List<BoxShadow> ambientShadow = [
    BoxShadow(
      color: Color(0x0D000000), // black @ 0.05 alpha
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // Gradients
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
}

// ============================================================================
// BACKWARD COMPATIBILITY - For widgets that can't easily access context
// ============================================================================

class AppDesignLegacy {
  // Brand Colors (default values)
  static const Color primaryAccent = Color(0xFF6366F1);
  static const Color secondaryAccent = Color(0xFF8B5CF6);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);

  // Light Theme
  static const Color lightBackground = Color(0xFFEEF2F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFE6EDF7);
  static const Color lightBorder = Color(0xFFCBD5E1);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);

  // Dark Theme
  static const Color darkBackground = Color(0xFF0A0F1C);
  static const Color darkSurface = Color(0xFF141D2D);
  static const Color darkSurfaceSecondary = Color(0xFF121822);
  static const Color darkBorder = Color(0xFF1F2A3B);
  static const Color darkTextPrimary = Color(0xFFE0E5EB);
  static const Color darkTextSecondary = Color(0xFF7A8B9B);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;

  // Border Radius
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;

  // Font sizes
  static const double fontXs = 11.0;
  static const double fontSm = 12.0;
  static const double fontMd = 13.0;
  static const double fontLg = 14.0;
  static const double fontXl = 16.0;
  static const double fontXxl = 18.0;

  // Animations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animMedium = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 350);

  // Sidebar
  static const double sidebarExpandedWidth = 280.0;
  static const double sidebarCollapsedWidth = 68.0;

  // Card elevation
  static const double shadowBlurRest = 8.0;
  static const double shadowBlurHover = 16.0;
  static const double shadowAlphaRest = 0.15;
  static const double shadowAlphaHover = 0.3;

  static List<BoxShadow> cardShadow(Color color, {bool hovered = false}) => [
        BoxShadow(
          color: color.withValues(
            alpha: hovered ? shadowAlphaHover : shadowAlphaRest,
          ),
          blurRadius: hovered ? shadowBlurHover : shadowBlurRest,
          offset: const Offset(0, 4),
        ),
      ];

  static const List<BoxShadow> ambientShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryAccent, secondaryAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient subtleGradient(bool isDark) => LinearGradient(
        colors: [
          primaryAccent.withValues(alpha: isDark ? 0.15 : 0.08),
          secondaryAccent.withValues(alpha: isDark ? 0.15 : 0.08),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
