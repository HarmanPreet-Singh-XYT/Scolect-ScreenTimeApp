import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets;
import 'package:screentime/app_design.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/main.dart';
import 'package:screentime/onboarding/onboarding_mockups.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';

// ============================================================================
// DATA
// ============================================================================

class _SlideData {
  final String emoji;
  final Color accentColor;
  final String title;
  final String description;
  final List<String> chips;
  final _VisualType visualType;

  const _SlideData({
    required this.emoji,
    required this.accentColor,
    required this.title,
    required this.description,
    this.chips = const [],
    this.visualType = _VisualType.welcome,
  });
}

enum _VisualType { welcome, appTracking, reports, limits, focusMode, browser, ready }

const List<Color> _slideColors = [
  Color(0xFF6366F1),
  Color(0xFF60A5FA),
  Color(0xFF8B5CF6),
  Color(0xFFF59E0B),
  Color(0xFF10B981),
  Color(0xFF6366F1),
  Color(0xFF8B5CF6),
];

List<_SlideData> _getSlides(AppLocalizations l10n) => [
  _SlideData(
    emoji: '⏱️',
    accentColor: _slideColors[0],
    title: l10n.onboardingWelcomeTitle,
    description: l10n.onboardingWelcomeDesc,
    chips: const ['Privacy-first', 'Open Source', 'On-device'],
    visualType: _VisualType.welcome,
  ),
  _SlideData(
    emoji: '📱',
    accentColor: _slideColors[1],
    title: l10n.onboardingEveryAppTitle,
    description: l10n.onboardingEveryAppDesc,
    chips: const ['Zero setup', 'Runs in the background', 'Per-app tracking'],
    visualType: _VisualType.appTracking,
  ),
  _SlideData(
    emoji: '📊',
    accentColor: _slideColors[2],
    title: l10n.onboardingSeeTimeTitle,
    description: l10n.onboardingSeeTimeDesc,
    chips: const ['Daily reports', 'Weekly trends', 'App breakdown'],
    visualType: _VisualType.reports,
  ),
  _SlideData(
    emoji: '🔔',
    accentColor: _slideColors[3],
    title: l10n.onboardingSmartLimitsTitle,
    description: l10n.onboardingSmartLimitsDesc,
    chips: const ['Per-app limits', 'Total limit', 'Custom alerts'],
    visualType: _VisualType.limits,
  ),
  _SlideData(
    emoji: '🎯',
    accentColor: _slideColors[4],
    title: l10n.onboardingDeepFocusTitle,
    description: l10n.onboardingDeepFocusDesc,
    chips: const ['Pomodoro timer', 'App blocking', 'Ambient sounds'],
    visualType: _VisualType.focusMode,
  ),
  _SlideData(
    emoji: '🌐',
    accentColor: _slideColors[5],
    title: l10n.onboardingTrackBrowserTitle,
    description: l10n.onboardingTrackBrowserDesc,
    chips: const ['Chrome extension', 'Website tracking', 'Syncs automatically'],
    visualType: _VisualType.browser,
  ),
  _SlideData(
    emoji: '🚀',
    accentColor: _slideColors[6],
    title: l10n.onboardingAllSetTitle,
    description: l10n.onboardingAllSetDesc,
    chips: const ['100% private', 'No account needed', 'Always free'],
    visualType: _VisualType.ready,
  ),
];

// ============================================================================
// SCREEN
// ============================================================================

class OnboardingScreen extends StatefulWidget {
  final Function(Locale) setLocale;

  const OnboardingScreen({super.key, required this.setLocale});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCompleting = false;

  late final AnimationController _bgAnimController;
  late Animation<Color?> _bgColorAnim;

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: AppDesignLegacy.animSlow,
    );
    _updateBgAnimation(_slideColors[0], _slideColors[0]);
  }

  void _updateBgAnimation(Color from, Color to) {
    _bgColorAnim = ColorTween(begin: from, end: to).animate(
      CurvedAnimation(parent: _bgAnimController, curve: Curves.easeInOut),
    );
  }

  void _goToPage(int page) {
    if (page == _currentPage) return;
    final prev = _slideColors[_currentPage];
    final next = _slideColors[page];
    _bgAnimController.reset();
    _updateBgAnimation(prev, next);
    _bgAnimController.forward();
    _pageController.animateToPage(
      page,
      duration: AppDesignLegacy.animSlow,
      curve: Curves.easeInOutCubic,
    );
    setState(() => _currentPage = page);
  }

  void _next() {
    if (_currentPage < _slideColors.length - 1) {
      _goToPage(_currentPage + 1);
    } else {
      _complete();
    }
  }

  void _back() {
    if (_currentPage > 0) _goToPage(_currentPage - 1);
  }

  Future<void> _complete() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    await SettingsManager().markOnboardingCompleted();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      FluentPageRoute(
        builder: (_) => HomePage(setLocale: widget.setLocale),
      ),
    );
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slides = _getSlides(l10n);
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;
    final slide = slides[_currentPage];
    final isLast = _currentPage == slides.length - 1;

    return flutter_widgets.AnimatedBuilder(
      animation: _bgAnimController,
      builder: (context, child) {
        final animatedAccent = _bgColorAnim.value ?? slide.accentColor;
        return ScaffoldPage(
          padding: EdgeInsets.zero,
          content: Stack(
            children: [
              // Background
              _OnboardingBackground(
                accentColor: animatedAccent,
                isDark: isDark,
              ),

              // Skip button
              Positioned(
                top: 20,
                right: 24,
                child: AnimatedOpacity(
                  opacity: isLast ? 0.0 : 1.0,
                  duration: AppDesignLegacy.animMedium,
                  child: HyperlinkButton(
                    onPressed: isLast ? null : () => _goToPage(slides.length - 1),
                    child: Text(
                      l10n.onboardingSkip,
                      style: TextStyle(
                        color: isDark
                            ? AppDesignLegacy.darkTextSecondary
                            : AppDesignLegacy.lightTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),

              // Page content
              PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  return _OnboardingSlide(
                    slide: slides[index],
                    isDark: isDark,
                  );
                },
              ),

              // Bottom controls
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Column(
                  children: [
                    // Dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(slides.length, (i) {
                        final isActive = i == _currentPage;
                        return GestureDetector(
                          onTap: () => _goToPage(i),
                          child: AnimatedContainer(
                            duration: AppDesignLegacy.animMedium,
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? slide.accentColor
                                  : slide.accentColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Back button
                        AnimatedOpacity(
                          opacity: _currentPage > 0 ? 1.0 : 0.0,
                          duration: AppDesignLegacy.animMedium,
                          child: SizedBox(
                            width: 120,
                            height: 44,
                            child: GestureDetector(
                              onTap: _currentPage > 0 ? _back : null,
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                      AppDesignLegacy.radiusMd),
                                  border: Border.all(
                                    color: isDark
                                        ? AppDesignLegacy.darkBorder
                                        : AppDesignLegacy.lightBorder,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    l10n.onboardingBack,
                                    style: TextStyle(
                                      color: isDark
                                          ? AppDesignLegacy.darkTextPrimary
                                          : AppDesignLegacy.lightTextPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Next / Get Started button
                        SizedBox(
                          width: 160,
                          height: 44,
                          child: _GradientButton(
                            label: isLast ? l10n.onboardingGetStarted : l10n.onboardingNext,
                            accentColor: slide.accentColor,
                            isLoading: _isCompleting,
                            onPressed: _next,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// BACKGROUND
// ============================================================================

class _OnboardingBackground extends StatelessWidget {
  final Color accentColor;
  final bool isDark;

  const _OnboardingBackground({
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        isDark ? AppDesignLegacy.darkBackground : AppDesignLegacy.lightBackground;

    return Stack(
      children: [
        // Base background
        Container(color: bg),

        // Top-right decorative blob
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withValues(alpha: isDark ? 0.18 : 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Bottom-left decorative blob
        Positioned(
          bottom: -100,
          left: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Subtle center glow
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0, -0.2),
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withValues(alpha: isDark ? 0.06 : 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SLIDE
// ============================================================================

class _OnboardingSlide extends StatelessWidget {
  final _SlideData slide;
  final bool isDark;

  const _OnboardingSlide({required this.slide, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppDesignLegacy.darkTextPrimary : AppDesignLegacy.lightTextPrimary;
    final textSecondary =
        isDark ? AppDesignLegacy.darkTextSecondary : AppDesignLegacy.lightTextSecondary;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Visual
              _SlideVisual(slide: slide, isDark: isDark),
              const SizedBox(height: 48),

              // Title
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                slide.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),

              // Chips
              if (slide.chips.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: slide.chips
                      .map((chip) => _FeatureChip(
                            label: chip,
                            accentColor: slide.accentColor,
                            isDark: isDark,
                          ))
                      .toList(),
                ),

              // Space for bottom controls
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// VISUALS
// ============================================================================

class _SlideVisual extends StatelessWidget {
  final _SlideData slide;
  final bool isDark;

  const _SlideVisual({required this.slide, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return switch (slide.visualType) {
      _VisualType.welcome =>
        WelcomeMockup(accentColor: slide.accentColor, isDark: isDark),
      _VisualType.appTracking =>
        AppTrackingMockup(accentColor: slide.accentColor, isDark: isDark),
      _VisualType.reports =>
        ReportsMockup(accentColor: slide.accentColor, isDark: isDark),
      _VisualType.limits =>
        LimitsMockup(accentColor: slide.accentColor, isDark: isDark),
      _VisualType.focusMode =>
        FocusModeMockup(accentColor: slide.accentColor, isDark: isDark),
      _VisualType.browser =>
        BrowserMockup(accentColor: slide.accentColor, isDark: isDark),
      _VisualType.ready => ReadyMockup(
          accentColor: slide.accentColor,
          isDark: isDark,
          items: const [
            'Tracking active',
            '100% on-device storage',
            'Ready when you are',
          ],
        ),
    };
  }
}

// ============================================================================
// FEATURE CHIP
// ============================================================================

class _FeatureChip extends StatelessWidget {
  final String label;
  final Color accentColor;
  final bool isDark;

  const _FeatureChip({
    required this.label,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: accentColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ============================================================================
// GRADIENT BUTTON
// ============================================================================

class _GradientButton extends StatelessWidget {
  final String label;
  final Color accentColor;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _GradientButton({
    required this.label,
    required this.accentColor,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor,
              Color.lerp(accentColor, const Color(0xFF8B5CF6), 0.5)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDesignLegacy.radiusMd),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: ProgressRing(strokeWidth: 2),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
        ),
      ),
    );
  }
}
