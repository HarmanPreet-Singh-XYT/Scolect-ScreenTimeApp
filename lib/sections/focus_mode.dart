import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:audioplayers/audioplayers.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/main.dart' as mn;
import 'package:screentime/sections/UI%20sections/FocusMode/audio.dart';
import 'package:screentime/sections/UI%20sections/FocusMode/helper.dart';
import 'package:screentime/sections/UI%20sections/FocusMode/permissionbanner.dart';
import 'package:screentime/sections/UI%20sections/FocusMode/sessionHistory.dart';
import 'package:screentime/sections/controller/data_controllers/focus_mode_data_controller.dart';
import 'package:screentime/sections/graphs/focus_mode_history.dart';
import 'package:screentime/sections/graphs/focus_mode_pie_chart.dart';
import 'package:screentime/sections/graphs/focus_mode_trends.dart';

import 'controller/settings_data_controller.dart';
import './controller/focus_mode_controller.dart';

// ─── Constants ────────────────────────────────────────────────────

const _kWorkColor = Color(0xFFFF5C50);
const _kBreakColor = Color(0xFF4CAF50);
const _kLongBreakColor = Color(0xFF42A5F5);
const _kSessionsUntilLongBreak = 4;

const _kDefaultWeekdays = <String, int>{
  'Monday': 0,
  'Tuesday': 0,
  'Wednesday': 0,
  'Thursday': 0,
  'Friday': 0,
  'Saturday': 0,
  'Sunday': 0,
};

final _dateParser = DateFormat('yyyy-MM-dd');
final _weekdayFormatter = DateFormat('EEEE');

// ─── Settings key constants ───────────────────────────────────────

const _kPrefix = 'focusModeSettings';
const _kWorkKey = '$_kPrefix.workDuration';
const _kShortBreakKey = '$_kPrefix.shortBreak';
const _kLongBreakKey = '$_kPrefix.longBreak';
const _kAutoStartKey = '$_kPrefix.autoStart';
const _kBlockKey = '$_kPrefix.blockDistractions';
const _kSoundsKey = '$_kPrefix.enableSoundsNotifications';
const _kModeKey = '$_kPrefix.selectedMode';
const _kVoiceKey = '$_kPrefix.voiceGender';

// ─── Helper: color for timer state ────────────────────────────────

Color _colorForState(TimerState state) => switch (state) {
      TimerState.work || TimerState.idle => _kWorkColor,
      TimerState.shortBreak || TimerState.longBreak => _kBreakColor,
    };

double _totalSecondsForState(
    TimerState state, double work, double shortBrk, double longBrk) {
  return switch (state) {
    TimerState.work || TimerState.idle => work * 60,
    TimerState.shortBreak => shortBrk * 60,
    TimerState.longBreak => longBrk * 60,
  };
}

String _formatTime(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

// ═══════════════════════════════════════════════════════════════════
// FocusMode — analytics dashboard
// ═══════════════════════════════════════════════════════════════════

class FocusMode extends StatefulWidget {
  const FocusMode({super.key});

  @override
  State<FocusMode> createState() => _FocusModeState();
}

class _FocusModeState extends State<FocusMode>
    with SingleTickerProviderStateMixin {
  final _analytics = FocusAnalyticsService();

  double workPct = 0, shortBreakPct = 0, longBreakPct = 0;
  List<Map<String, dynamic>> sessionHistory = [];
  Map<String, int> sessionCountByDay = Map.of(_kDefaultWeekdays);
  Map<String, dynamic> focusTrends = const {
    'periods': [],
    'sessionCounts': [],
    'avgDuration': [],
    'totalFocusTime': [],
    'percentageChange': 0,
  };
  Map<String, dynamic> weeklySummary = const {};
  bool isLoading = true;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => mn.navigationState.registerRefreshCallback(_loadData));
    _loadData();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 30));

      final dist =
          _analytics.getTimeDistribution(startDate: start, endDate: now);
      final hist =
          _analytics.getGroupedPomodoroSessions(startDate: start, endDate: now);
      final byDay =
          _analytics.getSessionCountByDay(startDate: start, endDate: now);
      final trends = _analytics.getFocusTrends(months: 3);
      final summary = _analytics.getWeeklySummary();

      setState(() {
        workPct = dist['workPercentage'] ?? 0;
        shortBreakPct = dist['shortBreakPercentage'] ?? 0;
        longBreakPct = dist['longBreakPercentage'] ?? 0;
        sessionHistory = hist;
        sessionCountByDay = _latestByWeekday(byDay);
        focusTrends = trends;
        weeklySummary = summary;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading focus mode data: $e');
      setState(() {
        workPct = 5;
        shortBreakPct = 6;
        longBreakPct = 8;
        isLoading = false;
      });
    }
    _animCtrl.forward(from: 0);
  }

  static Map<String, int> _latestByWeekday(Map<String, int> raw) {
    final result = Map<String, int>.of(_kDefaultWeekdays);
    final latestDates = <String, DateTime>{};

    for (final entry in raw.entries) {
      try {
        final date = _dateParser.parse(entry.key);
        final weekday = _weekdayFormatter.format(date);
        final prev = latestDates[weekday];
        if (prev == null || date.isAfter(prev)) {
          latestDates[weekday] = date;
          result[weekday] = entry.value;
        }
      } catch (e) {
        debugPrint('Error parsing date: ${entry.key} - $e');
      }
    }
    return result;
  }

  // ─── Localized day helper ─────────────────────────────────────

  static String _localizedDay(String key, AppLocalizations l10n) =>
      switch (key.toLowerCase()) {
        'monday' => l10n.day_monday,
        'tuesday' => l10n.day_tuesday,
        'wednesday' => l10n.day_wednesday,
        'thursday' => l10n.day_thursday,
        'friday' => l10n.day_friday,
        'saturday' => l10n.day_saturday,
        'sunday' => l10n.day_sunday,
        _ => l10n.none,
      };

  // ─── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ScaffoldPage(
        padding: EdgeInsets.zero,
        content: Center(child: ProgressRing()),
      );
    }

    final l10n = AppLocalizations.of(context)!;

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: FadeTransition(
        opacity: _fadeAnim,
        child: LayoutBuilder(builder: (context, constraints) {
          final small = constraints.maxWidth < 700;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(onRefresh: _loadData),
                const SizedBox(height: 24),
                const NotificationPermissionBanner(),
                _buildResponsiveRow(
                  small: small,
                  mainFlex: 3,
                  sideFlex: 2,
                  main: const _AnimatedCard(child: Meter()),
                  side: Column(children: [
                    _QuickStatCard(
                      title: l10n.timeDistributionSection,
                      child: FocusModePieChart(
                        dataMap: {
                          l10n.workSession: workPct,
                          l10n.shortBreak: shortBreakPct,
                          l10n.longBreak: longBreakPct,
                        },
                        colorList: const [
                          _kWorkColor,
                          _kBreakColor,
                          _kLongBreakColor
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _WeeklySummaryCard(
                      summary: weeklySummary,
                      localizedDay: _localizedDay,
                    ),
                  ]),
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                    title: l10n.historySection, icon: FluentIcons.chart),
                const SizedBox(height: 12),
                _AnimatedCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FocusModeHistoryChart(data: sessionCountByDay),
                  ),
                ),
                const SizedBox(height: 20),
                _buildResponsiveRow(
                  small: small,
                  mainFlex: 3,
                  sideFlex: 2,
                  main: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                          title: l10n.trendsSection,
                          icon: FluentIcons.trending12),
                      const SizedBox(height: 12),
                      _AnimatedCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: FocusModeTrends(data: focusTrends),
                        ),
                      ),
                    ],
                  ),
                  side: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                          title: l10n.sessionHistorySection,
                          icon: FluentIcons.history),
                      const SizedBox(height: 12),
                      _AnimatedCard(
                          child: SessionHistory(data: sessionHistory)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Builds a responsive row/column layout.
  Widget _buildResponsiveRow({
    required bool small,
    required int mainFlex,
    required int sideFlex,
    required Widget main,
    required Widget side,
  }) {
    if (small) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [main, const SizedBox(height: 20), side],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: mainFlex, child: main),
        const SizedBox(width: 20),
        Expanded(flex: sideFlex, child: side),
      ],
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _kWorkColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(FluentIcons.timer, color: _kWorkColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.focusModeTitle,
                  style: theme.typography.subtitle
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(l10n.focusModeSubtitle,
                  style: theme.typography.caption?.copyWith(
                    color:
                        theme.typography.caption?.color?.withValues(alpha: 0.7),
                  )),
            ],
          ),
        ]),
        IconButton(
            icon: const Icon(FluentIcons.refresh, size: 18),
            onPressed: onRefresh),
      ],
    );
  }
}

// ─── Section title ──────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Row(children: [
      Icon(icon, size: 16, color: theme.accentColor),
      const SizedBox(width: 8),
      Text(title,
          style: theme.typography.bodyStrong
              ?.copyWith(fontWeight: FontWeight.w600)),
    ]);
  }
}

// ─── Quick stat card ────────────────────────────────────────────

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: FluentTheme.of(context)
                    .typography
                    .bodyStrong
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// ─── Weekly summary card ────────────────────────────────────────

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({
    required this.summary,
    required this.localizedDay,
  });

  final Map<String, dynamic> summary;
  final String Function(String key, AppLocalizations l10n) localizedDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    final totalSessions = summary['totalSessions'] as int? ?? 0;
    final totalWorkPhases = summary['totalWorkPhases'] as int? ?? 0;
    final formattedTime =
        (summary['formattedTotalTime'] as String?) ?? l10n.minuteFormat('0');
    final avgMin = summary['avgSessionMinutes'] as int? ?? 0;
    final dayKey = (summary['mostProductiveDay'] as String?) ?? 'None';
    final dayName = localizedDay(dayKey, l10n);

    final totalMin = summary['totalMinutes'] as int? ?? 0;
    final workMin = summary['totalWorkMinutes'] as int? ?? 0;
    final breakMin = summary['totalBreakMinutes'] as int? ?? 0;

    return _AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.thisWeek,
                    style: theme.typography.bodyStrong
                        ?.copyWith(fontWeight: FontWeight.w600)),
                if (totalSessions > 0)
                  _Badge(
                      label: l10n.sessionsCount(totalSessions),
                      color: _kBreakColor),
              ],
            ),
            const SizedBox(height: 16),

            // Total time
            _LabelValue(label: l10n.totalTime, value: formattedTime),
            const SizedBox(height: 8),

            // Progress bar
            _TimeBreakdownBar(
                totalMin: totalMin, workMin: workMin, breakMin: breakMin),
            const SizedBox(height: 8),
            Row(children: [
              _LegendDot(
                  label: l10n.work,
                  value: l10n.minuteShortFormat(workMin.toString()),
                  color: _kWorkColor),
              const SizedBox(width: 16),
              _LegendDot(
                  label: l10n.breaks,
                  value: l10n.minuteShortFormat(breakMin.toString()),
                  color: _kBreakColor),
            ]),
            const SizedBox(height: 16),

            // Mini stats
            Row(children: [
              Expanded(
                  child: _MiniStat(
                      label: l10n.workPhases,
                      value: '$totalWorkPhases',
                      color: _kWorkColor)),
              const SizedBox(width: 12),
              Expanded(
                  child: _MiniStat(
                      label: l10n.averageLength,
                      value: avgMin > 0
                          ? l10n.minuteShortFormat(avgMin.toString())
                          : '-',
                      color: _kLongBreakColor)),
            ]),

            if (dayName != l10n.none) ...[
              const SizedBox(height: 12),
              _StatRow(
                  label: l10n.mostProductive,
                  value: dayName,
                  icon: FluentIcons.emoji),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Small reusable widgets ─────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: FluentTheme.of(context)
              .typography
              .caption
              ?.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue(
      {required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.typography.body),
        Text(value,
            style: theme.typography.bodyStrong
                ?.copyWith(fontWeight: FontWeight.w600, color: valueColor)),
      ],
    );
  }
}

class _TimeBreakdownBar extends StatelessWidget {
  const _TimeBreakdownBar({
    required this.totalMin,
    required this.workMin,
    required this.breakMin,
  });
  final int totalMin, workMin, breakMin;

  @override
  Widget build(BuildContext context) {
    final workPct = totalMin > 0 ? workMin / totalMin : 0.0;
    final breakPct = totalMin > 0 ? breakMin / totalMin : 0.0;

    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: FluentTheme.of(context).inactiveBackgroundColor,
      ),
      child: Row(children: [
        if (workPct > 0)
          Flexible(
            flex: (workPct * 100).round(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                  left: const Radius.circular(4),
                  right: breakPct > 0 ? Radius.zero : const Radius.circular(4),
                ),
                color: _kWorkColor,
              ),
            ),
          ),
        if (breakPct > 0)
          Flexible(
            flex: (breakPct * 100).round(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                  left: workPct > 0 ? Radius.zero : const Radius.circular(4),
                  right: const Radius.circular(4),
                ),
                color: _kBreakColor,
              ),
            ),
          ),
      ]),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot(
      {required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text('$label: $value', style: FluentTheme.of(context).typography.caption),
    ]);
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: theme.typography.subtitle
                ?.copyWith(fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: theme.typography.caption?.copyWith(
                color:
                    theme.typography.caption?.color?.withValues(alpha: 0.7))),
      ]),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(
      {required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: theme.accentColor),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: theme.typography.body)),
      Text(value,
          style: theme.typography.bodyStrong
              ?.copyWith(fontWeight: FontWeight.w600)),
    ]);
  }
}

// ─── Animated card wrapper ──────────────────────────────────────

class _AnimatedCard extends StatefulWidget {
  final Widget child;
  const _AnimatedCard({required this.child});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: theme.micaBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered
                ? theme.accentColor.withValues(alpha: 0.3)
                : theme.inactiveBackgroundColor,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: theme.accentColor.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                ]
              : const [],
        ),
        child: widget.child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Meter — Pomodoro timer widget
// ═══════════════════════════════════════════════════════════════════

class Meter extends StatefulWidget {
  const Meter({super.key});

  @override
  State<Meter> createState() => _MeterState();
}

class _MeterState extends State<Meter> with TickerProviderStateMixin {
  final _settings = SettingsManager();
  final _audioPlayer = AudioPlayer();

  StreamSubscription<TimerUpdate>? _timerSub;
  late PomodoroTimerService _timerService;

  // Settings
  double workDuration = 25, shortBreak = 5, longBreak = 15;
  bool autoStart = false, blockDistractions = false, enableSounds = true;
  String selectedMode = 'Custom';
  late String _voiceGender;

  // Timer display state
  String _displayTime = '25:00';
  double _pct = 1.0;
  bool _isRunning = false;
  TimerState _state = TimerState.idle;

  // Animations
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _btnScaleCtrl;
  late final Animation<double> _btnScaleAnim;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initTimerService();
    _initAnimations();
    _timerSub = _timerService.timerUpdates.listen(_onTimerUpdate);
    _syncDisplay();
  }

  @override
  void dispose() {
    _timerSub?.cancel();
    _pulseCtrl.dispose();
    _btnScaleCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ─── Settings ───────────────────────────────────────────────

  void _loadSettings() {
    workDuration = _settings.getSetting(_kWorkKey);
    shortBreak = _settings.getSetting(_kShortBreakKey);
    longBreak = _settings.getSetting(_kLongBreakKey);
    autoStart = _settings.getSetting(_kAutoStartKey);
    blockDistractions = _settings.getSetting(_kBlockKey);
    enableSounds = _settings.getSetting(_kSoundsKey);
    selectedMode = _settings.getSetting(_kModeKey);
    _voiceGender =
        _settings.getSetting(_kVoiceKey) ?? VoiceGenderOptions.defaultGender;
  }

  // ─── Animations ─────────────────────────────────────────────

  void _initAnimations() {
    _pulseCtrl = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _pulseAnim = Tween(begin: 1.0, end: 1.02)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _btnScaleCtrl = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    _btnScaleAnim = Tween(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _btnScaleCtrl, curve: Curves.easeInOut));
  }

  // ─── Timer service ──────────────────────────────────────────

  void _initTimerService() {
    _timerService = PomodoroTimerService(
      workDuration: workDuration.toInt(),
      shortBreakDuration: shortBreak.toInt(),
      longBreakDuration: longBreak.toInt(),
      autoStart: autoStart,
      enableNotifications: enableSounds,
      onWorkSessionStart: _onWorkStart,
      onShortBreakStart: _onShortBreakStart,
      onLongBreakStart: _onLongBreakStart,
      onTimerComplete: _onTimerComplete,
    );
  }

  void _syncDisplay() {
    final svc = _timerService;
    final total = _totalSecondsForState(
        svc.currentState, workDuration, shortBreak, longBreak);
    _displayTime =
        _formatTime(svc.minutesRemaining * 60 + svc.secondsInCurrentMinute);
    _pct = svc.secondsRemaining > 0 ? svc.secondsRemaining / total : 1.0;
    _isRunning = svc.isRunning;
    _state = svc.currentState;
  }

  void _onTimerUpdate(TimerUpdate update) {
    if (!mounted) return;
    final prev = _state;

    final total = _totalSecondsForState(
        update.state, workDuration, shortBreak, longBreak);

    setState(() {
      _state = update.state;
      _isRunning = update.isRunning;
      _displayTime = _formatTime(update.secondsRemaining);
      _pct =
          update.secondsRemaining > 0 ? update.secondsRemaining / total : 1.0;
    });

    // State transition sounds
    if (prev != _state && prev != TimerState.idle) {
      switch (_state) {
        case TimerState.work:
          _onWorkStart();
        case TimerState.shortBreak:
          _onShortBreakStart();
        case TimerState.longBreak:
          _onLongBreakStart();
        case TimerState.idle:
          break;
      }
    }

    // Pulse animation
    if (_isRunning && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!_isRunning && _pulseCtrl.isAnimating) {
      _pulseCtrl
        ..stop()
        ..reset();
    }
  }

  // ─── Sound callbacks ────────────────────────────────────────

  void _playSound(String type) {
    if (!mounted || !enableSounds) return;
    SoundManager.playSound(
      context: context,
      soundType: type,
      voiceGender: _voiceGender,
    ).catchError((e) => debugPrint('❌ Sound error ($type): $e'));
  }

  void _onWorkStart() => _playSound('work_start');
  void _onShortBreakStart() => _playSound('break_start');
  void _onLongBreakStart() => _playSound('long_break_start');
  void _onTimerComplete() => _playSound('timer_complete');

  // ─── Actions ────────────────────────────────────────────────

  void _handlePlayPause() {
    _btnScaleCtrl.forward().then((_) => _btnScaleCtrl.reverse());

    final wasIdle = _timerService.currentState == TimerState.idle;
    final wasRunning = _isRunning;

    setState(() {
      if (wasRunning) {
        _timerService.pauseTimer();
      } else if (wasIdle || _timerService.secondsRemaining == 0) {
        _timerService.startWorkSession();
        if (mounted) _onWorkStart();
      } else {
        _timerService.resumeTimer();
      }
    });
  }

  String _statusText(AppLocalizations l10n) => switch (_state) {
        TimerState.work => _isRunning ? l10n.focusTime : l10n.paused,
        TimerState.shortBreak =>
          _isRunning ? l10n.shortBreakStatus : l10n.paused,
        TimerState.longBreak => _isRunning ? l10n.longBreakStatus : l10n.paused,
        TimerState.idle => l10n.readyToFocus,
      };

  // ─── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final color = _colorForState(_state);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSessionChips(l10n),
          const SizedBox(height: 32),
          _buildTimerRing(l10n, theme, color),
          const SizedBox(height: 36),
          _buildControls(context, l10n, color),
          const SizedBox(height: 24),
          _buildCounter(context, theme, l10n),
        ],
      ),
    );
  }

  Widget _buildSessionChips(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SessionChip(
          label: l10n.focus,
          isActive: _state == TimerState.work || _state == TimerState.idle,
          color: _kWorkColor,
          onTap: () {
            if (_state != TimerState.work && _state != TimerState.idle) {
              setState(() {
                _timerService.startWorkSession();
                if (mounted) _onWorkStart();
              });
            }
          },
        ),
        const SizedBox(width: 8),
        SessionChip(
          label: l10n.shortBreakLabel(5),
          isActive: _state == TimerState.shortBreak,
          color: _kBreakColor,
          onTap: () {
            if (_state != TimerState.shortBreak) {
              setState(() {
                _timerService.startShortBreak();
                if (mounted) _onShortBreakStart();
              });
            }
          },
        ),
        const SizedBox(width: 8),
        SessionChip(
          label: l10n.longBreakLabel(15),
          isActive: _state == TimerState.longBreak,
          color: _kLongBreakColor,
          onTap: () {
            if (_state != TimerState.longBreak) {
              setState(() {
                _timerService.startLongBreak();
                if (mounted) _onLongBreakStart();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildTimerRing(
      AppLocalizations l10n, FluentThemeData theme, Color color) {
    final statusText = _statusText(l10n);

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) => Transform.scale(
        scale: _isRunning ? _pulseAnim.value : 1.0,
        child: child,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isRunning)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 5),
                ],
              ),
            ),
          CircularPercentIndicator(
            radius: 120,
            lineWidth: 12,
            animation: true,
            animationDuration: 300,
            backgroundColor:
                theme.inactiveBackgroundColor.withValues(alpha: 0.3),
            percent: _pct.clamp(0.0, 1.0),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: color,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_displayTime,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 52,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: color,
                    )),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    statusText,
                    key: ValueKey(statusText),
                    style: theme.typography.caption?.copyWith(
                      color: theme.typography.caption?.color
                          ?.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
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

  Widget _buildControls(
      BuildContext context, AppLocalizations l10n, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ControlButton(
            icon: FluentIcons.refresh,
            onPressed: () => setState(() {
                  _timerService.resetStats();
                  _timerService.resetTimer();
                }),
            tooltip: l10n.restartSession),
        const SizedBox(width: 16),
        ControlButton(
            icon: FluentIcons.previous,
            onPressed: () => setState(() => _timerService.navigateBackward()),
            tooltip: 'Previous Phase'),
        const SizedBox(width: 20),
        ScaleTransition(
          scale: _btnScaleAnim,
          child: PlayPauseButton(
              isRunning: _isRunning, color: color, onPressed: _handlePlayPause),
        ),
        const SizedBox(width: 20),
        ControlButton(
            icon: FluentIcons.next,
            onPressed: () => setState(() => _timerService.navigateForward()),
            tooltip: 'Next Phase'),
        const SizedBox(width: 16),
        ControlButton(
            icon: FluentIcons.settings,
            onPressed: () => _showSettingsDialog(context),
            tooltip: l10n.settings),
      ],
    );
  }

  Widget _buildCounter(
      BuildContext context, FluentThemeData theme, AppLocalizations l10n) {
    final progress = _timerService.completedSessions % _kSessionsUntilLongBreak;

    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_kSessionsUntilLongBreak, (i) {
          final done = i < progress;
          final current = i == progress &&
              (_state == TimerState.work || _state == TimerState.idle);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: current ? 24 : 10,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: done
                    ? _kWorkColor
                    : current
                        ? _kWorkColor.withValues(alpha: 0.5)
                        : theme.inactiveBackgroundColor,
                boxShadow: (done || current)
                    ? [
                        BoxShadow(
                            color: _kWorkColor.withValues(alpha: 0.3),
                            blurRadius: 4)
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
      const SizedBox(height: 8),
      Text(
        l10n.sessionsCompleted(_timerService.completedFullSessions),
        style: theme.typography.caption?.copyWith(
            color: theme.typography.caption?.color?.withValues(alpha: 0.5)),
      ),
    ]);
  }

  // ─── Settings dialog ────────────────────────────────────────

  void _saveSettings({
    required double work,
    required double shortBrk,
    required double longBrk,
    required bool auto,
    required bool block,
    required bool sounds,
    required String mode,
  }) {
    _settings.updateSetting(_kWorkKey, work);
    _settings.updateSetting(_kShortBreakKey, shortBrk);
    _settings.updateSetting(_kLongBreakKey, longBrk);
    _settings.updateSetting(_kAutoStartKey, auto);
    _settings.updateSetting(_kBlockKey, block);
    _settings.updateSetting(_kSoundsKey, sounds);
    _settings.updateSetting(_kModeKey, mode);

    setState(() {
      workDuration = work;
      shortBreak = shortBrk;
      longBreak = longBrk;
      autoStart = auto;
      blockDistractions = block;
      enableSounds = sounds;
      selectedMode = mode;

      _timerService.updateConfig(
        workDuration: work.toInt(),
        shortBreakDuration: shortBrk.toInt(),
        longBreakDuration: longBrk.toInt(),
        autoStart: auto,
        enableNotifications: sounds,
      );
      if (!_timerService.isRunning) _timerService.resetTimer();
    });
  }

  void _showSettingsDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    var dWork = workDuration;
    var dShort = shortBreak;
    var dLong = longBreak;
    var dAuto = autoStart;
    var dBlock = blockDistractions;
    var dSounds = enableSounds;
    var dMode = selectedMode;

    await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDlg) {
        void applyPreset(double w, double s, double l) {
          setDlg(() {
            dWork = w;
            dShort = s;
            dLong = l;
          });
        }

        return ContentDialog(
          constraints: const BoxConstraints(maxWidth: 420),
          title: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: FluentTheme.of(ctx).accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(FluentIcons.settings,
                  size: 18, color: FluentTheme.of(ctx).accentColor),
            ),
            const SizedBox(width: 12),
            Text(l10n.focusModeSettingsTitle),
          ]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.focusModePreset,
                    style: FluentTheme.of(ctx).typography.bodyStrong),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ComboBox<String>(
                    value: dMode,
                    isExpanded: true,
                    items: [
                      l10n.modeCustom,
                      l10n.modeDeepWork,
                      l10n.modeQuickTasks,
                      l10n.modeReading,
                    ]
                        .map((m) => ComboBoxItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setDlg(() => dMode = v);
                      if (v == l10n.modeDeepWork) applyPreset(60, 10, 30);
                      if (v == l10n.modeQuickTasks) applyPreset(25, 5, 15);
                      if (v == l10n.modeReading) applyPreset(45, 10, 20);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _SliderSetting(
                    label: l10n.focusDuration,
                    value: dWork,
                    display: l10n.minutesFormat(dWork.toInt()),
                    min: 15,
                    max: 120,
                    divisions: 21,
                    color: _kWorkColor,
                    onChanged: (v) => setDlg(() {
                          dWork = v;
                          dMode = l10n.modeCustom;
                        })),
                const SizedBox(height: 16),
                _SliderSetting(
                    label: l10n.shortBreakDuration,
                    value: dShort,
                    display: l10n.minutesFormat(dShort.toInt()),
                    min: 1,
                    max: 15,
                    divisions: 14,
                    color: _kBreakColor,
                    onChanged: (v) => setDlg(() {
                          dShort = v;
                          dMode = l10n.modeCustom;
                        })),
                const SizedBox(height: 16),
                _SliderSetting(
                    label: l10n.longBreakDuration,
                    value: dLong,
                    display: l10n.minutesFormat(dLong.toInt()),
                    min: 5,
                    max: 60,
                    divisions: 11,
                    color: _kLongBreakColor,
                    onChanged: (v) => setDlg(() {
                          dLong = v;
                          dMode = l10n.modeCustom;
                        })),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FluentTheme.of(ctx)
                        .inactiveBackgroundColor
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(children: [
                    _ToggleRow(
                        label: l10n.autoStartNextSession,
                        value: dAuto,
                        icon: FluentIcons.play,
                        onChanged: (v) => setDlg(() => dAuto = v!)),
                    const SizedBox(height: 12),
                    _ToggleRow(
                        label: l10n.enableSounds,
                        value: dSounds,
                        icon: FluentIcons.ringer,
                        onChanged: (v) => setDlg(() => dSounds = v!)),
                  ]),
                ),
              ],
            ),
          ),
          actions: [
            Button(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(FluentIcons.refresh, size: 12),
                const SizedBox(width: 6),
                Text(l10n.resetAll),
              ]),
              onPressed: () => setDlg(() {
                dWork = 25;
                dShort = 5;
                dLong = 15;
                dAuto = false;
                dBlock = false;
                dSounds = true;
                dMode = l10n.modeCustom;
              }),
            ),
            FilledButton(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(FluentIcons.save, size: 12),
                const SizedBox(width: 6),
                Text(l10n.save),
              ]),
              onPressed: () {
                _saveSettings(
                    work: dWork,
                    shortBrk: dShort,
                    longBrk: dLong,
                    auto: dAuto,
                    block: dBlock,
                    sounds: dSounds,
                    mode: dMode);
                Navigator.pop(ctx, l10n.saved);
              },
            ),
          ],
        );
      }),
    );
  }
}

// ─── Dialog sub-widgets ─────────────────────────────────────────

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.label,
    required this.value,
    required this.display,
    required this.min,
    required this.max,
    required this.divisions,
    required this.color,
    required this.onChanged,
  });

  final String label, display;
  final double value, min, max;
  final int divisions;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: theme.typography.body),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(display,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ),
      ]),
      const SizedBox(height: 8),
      SliderTheme(
        data: SliderThemeData(
          thumbColor: WidgetStateProperty.all(color),
          activeColor: WidgetStateProperty.all(color),
        ),
        child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged),
      ),
    ]);
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final IconData icon;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Row(children: [
      Icon(icon, size: 16, color: theme.accentColor),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: theme.typography.body)),
      ToggleSwitch(checked: value, onChanged: onChanged),
    ]);
  }
}
