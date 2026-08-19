import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart' as flutter_widgets;
import 'package:screentime/app_design.dart';
import 'package:screentime/onboarding/onboarding_mockups.dart';
import 'package:screentime/web/chrome_storage_interop.dart'
    if (dart.library.io) 'package:screentime/web/chrome_storage_interop_stub.dart';

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

enum _VisualType { welcome, puzzle, sync, shield, dashboard, rocket }

const List<_SlideData> _slides = [
  _SlideData(
    emoji: '👋',
    accentColor: Color(0xFF6366F1),
    title: 'Welcome to Scolect',
    description:
        'The Scolect browser extension tracks time spent on every website — giving you a full picture of where your day goes online.',
    chips: ['Automatic tracking', 'Zero setup', 'Privacy-first'],
    visualType: _VisualType.welcome,
  ),
  _SlideData(
    emoji: '🔌',
    accentColor: Color(0xFF8B5CF6),
    title: 'Works Right in Your Browser',
    description:
        'No accounts, no sign-ups. The extension runs silently in the background and tracks every domain you visit, automatically.',
    chips: ['Always-on', 'All websites', 'No login needed'],
    visualType: _VisualType.puzzle,
  ),
  _SlideData(
    emoji: '📊',
    accentColor: Color(0xFF6366F1),
    title: 'Your Usage, Right Here',
    description:
        'This dashboard shows a breakdown of every site you visit — time spent, visit counts, and daily trends. All stored locally.',
    chips: ['Daily breakdown', 'Visit counts', 'Local storage only'],
    visualType: _VisualType.dashboard,
  ),
  _SlideData(
    emoji: '🔗',
    accentColor: Color(0xFF10B981),
    title: 'Sync with the Desktop App',
    description:
        'Install the Scolect desktop app to merge browser and desktop usage into one unified timeline. Limits set on desktop apply here too.',
    chips: ['Unified view', 'Shared limits', 'Auto-sync'],
    visualType: _VisualType.sync,
  ),
  _SlideData(
    emoji: '🔒',
    accentColor: Color(0xFFF59E0B),
    title: '100% Private',
    description:
        'All data stays in your browser\'s local storage — nothing is sent to any server. You own your data, always.',
    chips: ['On-device only', 'No cloud', 'Open source'],
    visualType: _VisualType.shield,
  ),
  _SlideData(
    emoji: '🚀',
    accentColor: Color(0xFF8B5CF6),
    title: "You're All Set",
    description:
        'Scolect is now tracking your browser usage. Head to the dashboard to see your first data as you browse.',
    chips: ['Tracking active', 'Ready to explore'],
    visualType: _VisualType.rocket,
  ),
];

// ============================================================================
// SCREEN
// ============================================================================

class WebOnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const WebOnboardingScreen({super.key, required this.onComplete});

  @override
  State<WebOnboardingScreen> createState() => _WebOnboardingScreenState();
}

class _WebOnboardingScreenState extends State<WebOnboardingScreen>
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
    await chromeStorageSet({'onboarding_completed': true});
    widget.onComplete();
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
        return Stack(
          children: [
            // Background
            _WebOnboardingBackground(
              accentColor: animatedAccent,
              isDark: isDark,
            ),

            // Page content
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                return _WebOnboardingSlide(
                  slide: _slides[index],
                  isDark: isDark,
                );
              },
            ),

            // Skip button (must be after PageView in stack to receive taps)
            if (!isLast)
              Positioned(
                top: 20,
                right: 24,
                child: HyperlinkButton(
                  onPressed: _complete,
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

                      // Next / Get Started
                      SizedBox(
                        width: 160,
                        height: 44,
                        child: _GradientButton(
                          label: isLast ? 'Go to Dashboard' : 'Next',
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
        );
      },
    );
  }
}

// ============================================================================
// BACKGROUND
// ============================================================================

class _WebOnboardingBackground extends StatelessWidget {
  final Color accentColor;
  final bool isDark;

  const _WebOnboardingBackground({
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        isDark ? AppDesignLegacy.darkBackground : AppDesignLegacy.lightBackground;

    return Stack(
      children: [
        Container(color: bg),
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

class _WebOnboardingSlide extends StatelessWidget {
  final _SlideData slide;
  final bool isDark;

  const _WebOnboardingSlide({required this.slide, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppDesignLegacy.darkTextPrimary : AppDesignLegacy.lightTextPrimary;
    final textSecondary =
        isDark ? AppDesignLegacy.darkTextSecondary : AppDesignLegacy.lightTextSecondary;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              _SlideVisual(slide: slide, isDark: isDark),
              const SizedBox(height: 40),
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                slide.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
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
      _VisualType.puzzle => _PuzzleVisual(accentColor: slide.accentColor, isDark: isDark),
      _VisualType.sync => SyncMockup(accentColor: slide.accentColor, isDark: isDark),
      _VisualType.shield => PrivacyMockup(accentColor: slide.accentColor, isDark: isDark),
      _VisualType.dashboard => ReportsMockup(accentColor: slide.accentColor, isDark: isDark),
      _VisualType.rocket => ReadyMockup(
          accentColor: slide.accentColor,
          isDark: isDark,
          items: const [
            'Tracking active',
            '100% local storage',
            'Ready to explore',
          ],
        ),
      _VisualType.welcome => WelcomeMockup(accentColor: slide.accentColor, isDark: isDark),
    };
  }
}

// Browser + puzzle piece visual: extension icon on a browser window
class _PuzzleVisual extends StatelessWidget {
  final Color accentColor;
  final bool isDark;
  const _PuzzleVisual({required this.accentColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surfaceColor =
        isDark ? AppDesignLegacy.darkSurface : AppDesignLegacy.lightSurface;
    final borderColor =
        isDark ? AppDesignLegacy.darkBorder : AppDesignLegacy.lightBorder;

    return SizedBox(
      width: 200,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow
          Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: RadialGradient(colors: [
                accentColor.withValues(alpha: 0.18),
                Colors.transparent,
              ]),
            ),
          ),
          // Browser window
          Container(
            width: 180,
            height: 130,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Chrome bar
                Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppDesignLegacy.darkSurfaceSecondary
                        : AppDesignLegacy.lightSurfaceSecondary,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(9)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      ...List.generate(3, (i) {
                        final colors = [
                          const Color(0xFFFF5F57),
                          const Color(0xFFFFBD2E),
                          const Color(0xFF28CA42),
                        ];
                        return Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors[i].withValues(alpha: 0.8),
                          ),
                        );
                      }),
                      const Spacer(),
                      // Extension icon slot in toolbar
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: accentColor,
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🔌', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content placeholder lines
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(3, (i) {
                        return Container(
                          height: 6,
                          width: [120.0, 80.0, 100.0][i],
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? AppDesignLegacy.darkTextSecondary
                                    : AppDesignLegacy.lightTextSecondary)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
