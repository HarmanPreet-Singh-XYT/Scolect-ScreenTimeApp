import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets;
import 'package:screentime/app_design.dart';
import 'package:screentime/main.dart';
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
    this.visualType = _VisualType.circle,
  });
}

enum _VisualType { circle, barChart, browser, rings, clock, rocket }

const List<_SlideData> _slides = [
  _SlideData(
    emoji: '⏱️',
    accentColor: Color(0xFF6366F1),
    title: 'Welcome to Scolect',
    description:
        'Take control of your time. Scolect runs silently in the background — tracking every app, every session, every minute.',
    chips: ['Privacy-first', 'Open Source', 'On-device'],
    visualType: _VisualType.clock,
  ),
  _SlideData(
    emoji: '📊',
    accentColor: Color(0xFF8B5CF6),
    title: 'See Where Your Time Goes',
    description:
        'Beautiful daily and weekly reports show your most-used apps, total screen time, and usage trends at a glance.',
    chips: ['Daily reports', 'Weekly trends', 'App breakdown'],
    visualType: _VisualType.barChart,
  ),
  _SlideData(
    emoji: '🔔',
    accentColor: Color(0xFFF59E0B),
    title: 'Smart Limits & Alerts',
    description:
        'Set daily time limits per app or for your total screen time. Get notified before you hit your limits — not after.',
    chips: ['Per-app limits', 'Total limit', 'Custom alerts'],
    visualType: _VisualType.rings,
  ),
  _SlideData(
    emoji: '🎯',
    accentColor: Color(0xFF10B981),
    title: 'Deep Focus Mode',
    description:
        'Block distracting apps during Pomodoro sessions. Custom work and break intervals with optional ambient sounds keep you in the zone.',
    chips: ['Pomodoro timer', 'App blocking', 'Ambient sounds'],
    visualType: _VisualType.circle,
  ),
  _SlideData(
    emoji: '🌐',
    accentColor: Color(0xFF6366F1),
    title: 'Track Browser Time Too',
    description:
        'Install the free browser extension to capture time spent on websites — not just native apps. Full picture, one dashboard.',
    chips: ['Chrome extension', 'Website tracking', 'Syncs automatically'],
    visualType: _VisualType.browser,
  ),
  _SlideData(
    emoji: '🚀',
    accentColor: Color(0xFF8B5CF6),
    title: "You're All Set",
    description:
        'Scolect is ready to track. Your data stays entirely on-device — completely private, never uploaded anywhere.',
    chips: ['100% private', 'No account needed', 'Always free'],
    visualType: _VisualType.rocket,
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
    _updateBgAnimation(_slides[0].accentColor, _slides[0].accentColor);
  }

  void _updateBgAnimation(Color from, Color to) {
    _bgColorAnim = ColorTween(begin: from, end: to).animate(
      CurvedAnimation(parent: _bgAnimController, curve: Curves.easeInOut),
    );
  }

  void _goToPage(int page) {
    if (page == _currentPage) return;
    final prev = _slides[_currentPage].accentColor;
    final next = _slides[page].accentColor;
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
    if (_currentPage < _slides.length - 1) {
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
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;
    final slide = _slides[_currentPage];
    final isLast = _currentPage == _slides.length - 1;

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
                    onPressed: isLast ? null : () => _goToPage(_slides.length - 1),
                    child: Text(
                      'Skip',
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
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _OnboardingSlide(
                    slide: _slides[index],
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
                      children: List.generate(_slides.length, (i) {
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
                                    'Back',
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
                            label: isLast ? 'Get Started' : 'Next',
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
      _VisualType.barChart => _BarChartVisual(accentColor: slide.accentColor),
      _VisualType.browser => _BrowserVisual(accentColor: slide.accentColor, isDark: isDark),
      _VisualType.rings => _RingsVisual(accentColor: slide.accentColor, emoji: slide.emoji),
      _VisualType.clock => _ClockVisual(accentColor: slide.accentColor, emoji: slide.emoji),
      _VisualType.rocket => _RocketVisual(accentColor: slide.accentColor, emoji: slide.emoji),
      _VisualType.circle => _CircleVisual(accentColor: slide.accentColor, emoji: slide.emoji),
    };
  }
}

class _CircleVisual extends StatelessWidget {
  final Color accentColor;
  final String emoji;

  const _CircleVisual({required this.accentColor, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                accentColor.withValues(alpha: 0.25),
                Colors.transparent,
              ]),
            ),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.65)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.45),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          Text(emoji, style: const TextStyle(fontSize: 52)),
        ],
      ),
    );
  }
}

class _ClockVisual extends StatelessWidget {
  final Color accentColor;
  final String emoji;

  const _ClockVisual({required this.accentColor, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.25),
                width: 2,
              ),
              gradient: RadialGradient(colors: [
                accentColor.withValues(alpha: 0.15),
                Colors.transparent,
              ]),
            ),
          ),
          // Middle ring
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
          ),
          // Inner filled circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.5),
                  blurRadius: 36,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Text(emoji, style: const TextStyle(fontSize: 44)),
        ],
      ),
    );
  }
}

class _BarChartVisual extends StatelessWidget {
  final Color accentColor;

  const _BarChartVisual({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final bars = [0.45, 0.70, 0.55, 0.90, 0.65, 0.80, 0.50];

    return SizedBox(
      width: 200,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow
          Container(
            width: 200,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: RadialGradient(colors: [
                accentColor.withValues(alpha: 0.15),
                Colors.transparent,
              ]),
            ),
          ),
          // Bars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(bars.length, (i) {
              final height = bars[i] * 120;
              final isHighest = bars[i] == bars.reduce(math.max);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: 18,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: isHighest
                          ? [accentColor, accentColor.withValues(alpha: 0.7)]
                          : [
                              accentColor.withValues(alpha: 0.6),
                              accentColor.withValues(alpha: 0.35),
                            ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: isHighest
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.5),
                              blurRadius: 12,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _RingsVisual extends StatelessWidget {
  final Color accentColor;
  final String emoji;

  const _RingsVisual({required this.accentColor, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.18),
                width: 12,
              ),
            ),
          ),
          // Middle ring
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.4),
                width: 10,
              ),
            ),
          ),
          // Inner ring
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.7),
                width: 8,
              ),
            ),
          ),
          // Center
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.6),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          Text(emoji, style: const TextStyle(fontSize: 30)),
        ],
      ),
    );
  }
}

class _BrowserVisual extends StatelessWidget {
  final Color accentColor;
  final bool isDark;

  const _BrowserVisual({required this.accentColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surfaceColor =
        isDark ? AppDesignLegacy.darkSurface : AppDesignLegacy.lightSurface;
    final borderColor =
        isDark ? AppDesignLegacy.darkBorder : AppDesignLegacy.lightBorder;

    return SizedBox(
      width: 220,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow behind browser
          Container(
            width: 220,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: RadialGradient(colors: [
                accentColor.withValues(alpha: 0.2),
                Colors.transparent,
              ]),
            ),
          ),
          // Browser window frame
          Container(
            width: 200,
            height: 140,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Browser chrome (top bar)
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppDesignLegacy.darkSurfaceSecondary
                        : AppDesignLegacy.lightSurfaceSecondary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(9),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      // Traffic lights
                      ...List.generate(3, (i) {
                        final colors = [
                          const Color(0xFFFF5F57),
                          const Color(0xFFFFBD2E),
                          const Color(0xFF28CA42),
                        ];
                        return Container(
                          margin: const EdgeInsets.only(right: 5),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors[i].withValues(alpha: 0.8),
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      // URL bar
                      Expanded(
                        child: Container(
                          height: 16,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: borderColor.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content area — simulated progress bars / data rows
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (i) {
                        final widths = [0.8, 0.55, 0.7];
                        return Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentColor.withValues(alpha: 0.2),
                              ),
                              child: Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accentColor.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 6,
                                    width: double.infinity *
                                        widths[i],
                                    decoration: BoxDecoration(
                                      color: (isDark
                                              ? AppDesignLegacy.darkTextSecondary
                                              : AppDesignLegacy.lightTextSecondary)
                                          .withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FractionallySizedBox(
                                    widthFactor: widths[i],
                                    child: Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: accentColor.withValues(
                                            alpha: 0.5 - i * 0.1),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Globe emoji overlay
          Positioned(
            bottom: 6,
            right: 12,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.5),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🌐', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RocketVisual extends StatelessWidget {
  final Color accentColor;
  final String emoji;

  const _RocketVisual({required this.accentColor, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Star burst rays
          ...List.generate(8, (i) {
            final angle = (i * math.pi / 4);
            final radius = 80.0;
            return Positioned(
              left: 100 + math.cos(angle) * radius - 1,
              top: 100 + math.sin(angle) * radius - 20,
              child: Transform.rotate(
                angle: angle,
                child: Container(
                  width: 2,
                  height: 20,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            );
          }),
          // Outer glow
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                accentColor.withValues(alpha: 0.2),
                Colors.transparent,
              ]),
            ),
          ),
          // Inner circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.5),
                  blurRadius: 48,
                  spreadRadius: 6,
                ),
              ],
            ),
          ),
          Text(emoji, style: const TextStyle(fontSize: 52)),
        ],
      ),
    );
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
