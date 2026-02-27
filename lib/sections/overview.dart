import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/main.dart' as mn;
import './controller/data_controllers/overview_data_controller.dart';
import 'UI sections/Overview/bottom.dart';
import 'UI sections/Overview/statCards.dart';
import 'UI sections/Overview/main_app.dart';
import 'UI Sections/overview/changelog.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const _kFadeDuration = Duration(milliseconds: 600);
const _kHoverDuration = Duration(milliseconds: 200);
const _kRotateDuration = Duration(milliseconds: 300);
const _kCompactBreakpoint = 700.0;
const _kMediumBreakpoint = 1000.0;
const _kNarrowBreakpoint = 400.0;
const _kPurple = Color(0xffA855F7);
const _kGreen = Color(0xff22C55E);
const _kDefaultTime = '0h 0m';
const _kDefaultApp = 'None';
const _kDefaultSessions = '0';

// ─── Data holder (avoids passing 11 params individually) ────────────────────

class _OverviewSnapshot {
  final String totalScreenTime;
  final String totalProductiveTime;
  final String mostUsedApp;
  final String focusSessions;
  final List<Map<String, dynamic>> topApplications;
  final List<Map<String, dynamic>> categoryApplications;
  final List<Map<String, dynamic>> applicationLimits;
  final double screenTime;
  final double productiveScore;
  final bool hasData;

  const _OverviewSnapshot({
    required this.totalScreenTime,
    required this.totalProductiveTime,
    required this.mostUsedApp,
    required this.focusSessions,
    required this.topApplications,
    required this.categoryApplications,
    required this.applicationLimits,
    required this.screenTime,
    required this.productiveScore,
    required this.hasData,
  });

  static const empty = _OverviewSnapshot(
    totalScreenTime: _kDefaultTime,
    totalProductiveTime: _kDefaultTime,
    mostUsedApp: _kDefaultApp,
    focusSessions: _kDefaultSessions,
    topApplications: [],
    categoryApplications: [],
    applicationLimits: [],
    screenTime: 0,
    productiveScore: 0,
    hasData: false,
  );

  /// Build snapshot from API data — mapping done once, not in setState
  factory _OverviewSnapshot.fromOverviewData(OverviewData data) {
    final topApps = data.topApplications
        .map((app) => {
              'name': app.name,
              'category': app.category,
              'screenTime': app.formattedScreenTime,
              'percentageOfTotalTime': app.percentageOfTotalTime,
              'isVisible': app.isVisible,
            })
        .toList(growable: false);

    final categories = data.categoryBreakdown
        .map((cat) => {
              'name': cat.name,
              'totalScreenTime': cat.formattedTotalScreenTime,
              'percentageOfTotalTime': cat.percentageOfTotalTime,
            })
        .toList(growable: false);

    final limits = data.applicationLimits
        .map((limit) => {
              'name': limit.name,
              'category': limit.category,
              'dailyLimit': limit.formattedDailyLimit,
              'actualUsage': limit.formattedActualUsage,
              'percentageOfLimit': limit.percentageOfLimit,
              'percentageOfTotalTime': limit.percentageOfTotalTime,
            })
        .toList(growable: false);

    final sessions = data.focusSessions.toString();

    return _OverviewSnapshot(
      totalScreenTime: data.formattedTotalScreenTime,
      totalProductiveTime: data.formattedProductiveTime,
      mostUsedApp: data.mostUsedApp,
      focusSessions: sessions,
      topApplications: topApps,
      categoryApplications: categories,
      applicationLimits: limits,
      screenTime: data.screenTimePercentage / 100,
      productiveScore: data.productivityScore / 100,
      hasData: topApps.isNotEmpty ||
          categories.isNotEmpty ||
          limits.isNotEmpty ||
          data.focusSessions > 0,
    );
  }
}

// ─── View states ────────────────────────────────────────────────────────────

enum _ViewState { loading, error, empty, ready }

// ─── Overview ───────────────────────────────────────────────────────────────

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview>
    with SingleTickerProviderStateMixin {
  _OverviewSnapshot _snapshot = _OverviewSnapshot.empty;
  _ViewState _viewState = _ViewState.loading;
  String _errorMessage = '';

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: _kFadeDuration,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _loadData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      mn.navigationState.registerRefreshCallback(_loadData);
      ChangelogModal.showIfNeeded(context);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _viewState = _ViewState.loading);

    try {
      final data = await DailyOverviewData().fetchTodayOverview();
      final snapshot = _OverviewSnapshot.fromOverviewData(data);

      if (!mounted) return;

      setState(() {
        _snapshot = snapshot;
        _viewState = snapshot.hasData ? _ViewState.ready : _ViewState.empty;
      });

      _fadeController.forward(from: 0);
    } catch (e) {
      debugPrint('Error loading overview data: $e');
      if (!mounted) return;

      setState(() {
        _viewState = _ViewState.error;
        _errorMessage =
            AppLocalizations.of(context)!.errorLoadingData(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final Widget content = switch (_viewState) {
      _ViewState.loading => _LoadingState(l10n: l10n),
      _ViewState.error =>
        _ErrorState(l10n: l10n, message: _errorMessage, onRetry: _loadData),
      _ViewState.empty => _EmptyState(l10n: l10n, onRefresh: _loadData),
      _ViewState.ready => FadeTransition(
          opacity: _fadeAnimation,
          child: _ResponsiveOverviewContent(
            snapshot: _snapshot,
            refreshData: _loadData,
          ),
        ),
    };

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: content,
    );
  }
}

// ─── State Widgets (extracted as standalone, const-friendly) ────────────────

class _LoadingState extends StatelessWidget {
  final AppLocalizations l10n;
  const _LoadingState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const ProgressRing(strokeWidth: 3),
          const SizedBox(height: 20),
          Text(
            l10n.loadingProductivityData,
            style: TextStyle(
              color: FluentTheme.of(context).inactiveColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final AppLocalizations l10n;
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.l10n,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.warningPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                FluentIcons.error_badge,
                size: 40,
                color: Colors.warningPrimaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _ActionButton(onPressed: onRetry, label: l10n.tryAgain),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onRefresh;

  const _EmptyState({required this.l10n, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                FluentIcons.analytics_view,
                size: 48,
                color: theme.accentColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noActivityDataAvailable,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.startUsingApplications,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.inactiveColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRefresh,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.refresh, size: 14),
                    const SizedBox(width: 8),
                    Text(l10n.refreshData),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared action button ───────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  const _ActionButton({required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text(label),
      ),
    );
  }
}

// ─── Responsive Content ─────────────────────────────────────────────────────

class _ResponsiveOverviewContent extends StatelessWidget {
  final _OverviewSnapshot snapshot;
  final VoidCallback refreshData;

  const _ResponsiveOverviewContent({
    required this.snapshot,
    required this.refreshData,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < _kCompactBreakpoint;
        final isMedium = width < _kMediumBreakpoint;

        final hPad = isCompact ? 12.0 : (isMedium ? 18.0 : 24.0);
        final vSpace = isCompact ? 12.0 : (isMedium ? 16.0 : 20.0);

        final edgePadding = EdgeInsets.fromLTRB(
          hPad,
          hPad * 0.67,
          hPad,
          hPad,
        );

        final statsCards = StatsCards(
          totalScreenTime: snapshot.totalScreenTime,
          totalProductiveTime: snapshot.totalProductiveTime,
          mostUsedApp: snapshot.mostUsedApp,
          focusSessions: snapshot.focusSessions,
        );

        final header = _Header(refresh: refreshData);

        if (isCompact) {
          return SingleChildScrollView(
            padding: edgePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                SizedBox(height: vSpace),
                statsCards,
                SizedBox(height: vSpace),
                _MainContent(
                  topApps: snapshot.topApplications,
                  categories: snapshot.categoryApplications,
                  isCompact: true,
                ),
                SizedBox(height: vSpace),
                _BottomSection(
                  snapshot: snapshot,
                  isCompact: true,
                  isMedium: false,
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: edgePadding,
          child: Column(
            children: [
              header,
              SizedBox(height: vSpace),
              statsCards,
              SizedBox(height: vSpace),
              Expanded(
                flex: 5,
                child: _MainContent(
                  topApps: snapshot.topApplications,
                  categories: snapshot.categoryApplications,
                  isCompact: false,
                ),
              ),
              SizedBox(height: vSpace),
              Expanded(
                flex: 3,
                child: _BottomSection(
                  snapshot: snapshot,
                  isCompact: false,
                  isMedium: isMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback refresh;
  const _Header({required this.refresh});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < _kNarrowBreakpoint;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.overviewTitle,
                    style: theme.typography.subtitle?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isNarrow ? 18 : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _greeting(l10n),
                    style: TextStyle(
                      color: theme.inactiveColor,
                      fontSize: isNarrow ? 11 : 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _RefreshButton(onPressed: refresh, compact: isNarrow),
          ],
        );
      },
    );
  }

  static String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 17) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }
}

class _RefreshButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool compact;
  const _RefreshButton({required this.onPressed, this.compact = false});

  @override
  State<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<_RefreshButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final compact = widget.compact;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: _kHoverDuration,
        child: Button(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(
                vertical: compact ? 6 : 8,
                horizontal: compact ? 10 : 14,
              ),
            ),
          ),
          onPressed: widget.onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedRotation(
                turns: _isHovered ? 0.5 : 0,
                duration: _kRotateDuration,
                child: Icon(FluentIcons.refresh, size: compact ? 12 : 14),
              ),
              if (!compact) ...[
                const SizedBox(width: 8),
                Text(
                  l10n.refresh,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Main Content ───────────────────────────────────────────────────────────

class _MainContent extends StatelessWidget {
  final List<dynamic> topApps;
  final List<dynamic> categories;
  final bool isCompact;

  const _MainContent({
    required this.topApps,
    required this.categories,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final topList = TopApplicationsList(data: topApps);
    final catList = CategoryBreakdownList(data: categories);

    if (isCompact) {
      return Column(
        children: [
          SizedBox(height: 320, child: _ContentCard(child: topList)),
          const SizedBox(height: 12),
          SizedBox(height: 320, child: _ContentCard(child: catList)),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _ContentCard(child: topList)),
        const SizedBox(width: 16),
        Expanded(child: _ContentCard(child: catList)),
      ],
    );
  }
}

// ─── Content Card (shared themed container) ─────────────────────────────────

class _ContentCard extends StatelessWidget {
  final Widget child;
  const _ContentCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.resources.cardStrokeColorDefault,
        ),
      ),
      child: child,
    );
  }
}

// ─── Bottom Section ─────────────────────────────────────────────────────────

class _BottomSection extends StatelessWidget {
  final _OverviewSnapshot snapshot;
  final bool isCompact;
  final bool isMedium;

  const _BottomSection({
    required this.snapshot,
    required this.isCompact,
    required this.isMedium,
  });

  @override
  Widget build(BuildContext context) {
    final limitsCard = _ContentCard(
      child: ApplicationLimitsList(data: snapshot.applicationLimits),
    );

    // Build the actual progress cards with live data
    final stProgress = ProgressCard(
      title: 'Screen\nTime',
      value: snapshot.screenTime,
      color: _kPurple,
    );
    final psProgress = ProgressCard(
      title: 'Productive\nScore',
      value: snapshot.productiveScore,
      color: _kGreen,
    );

    if (isCompact) {
      return Column(
        children: [
          SizedBox(
            height: 140,
            child: Row(
              children: [
                Expanded(child: stProgress),
                const SizedBox(width: 12),
                Expanded(child: psProgress),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(height: 220, child: limitsCard),
        ],
      );
    }

    // Medium and expanded share the same structure, different flex
    final limitsFlex = isMedium ? 4 : 5;
    const progressFlex = 2;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: limitsFlex, child: limitsCard),
        const SizedBox(width: 16),
        Expanded(flex: progressFlex, child: stProgress),
        const SizedBox(width: 16),
        Expanded(flex: progressFlex, child: psProgress),
      ],
    );
  }
}
