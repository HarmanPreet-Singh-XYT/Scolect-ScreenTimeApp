import 'package:flutter/widgets.dart';

/// Shared width breakpoints for responsive layouts across desktop and the
/// web extension dashboard. Matches the ad-hoc breakpoints already used in
/// overview.dart / alerts_limits.dart so behavior stays consistent.
class Responsive {
  static const double mobileBreakpoint = 700.0;
  static const double tabletBreakpoint = 1000.0;
  static const double narrowBreakpoint = 400.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isMobileWidth(double width) => width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletBreakpoint;
}
