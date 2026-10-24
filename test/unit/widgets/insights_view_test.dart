// test/unit/widgets/insights_view_test.dart
//
// Widget tests for the Insights view, driven by a fake InsightsData so no
// storage is needed.

// ignore_for_file: depend_on_referenced_packages

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/data_controllers/insights_data.dart';
import 'package:screentime/sections/widgets/Reports/insights/insights_view.dart';
import 'package:screentime/sections/widgets/Settings/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _today = DateTime(2026, 3, 18);

HistoryInsights _richHistory(Map<DateTime, Duration> daily) {
  final grid = List.generate(7, (d) => List.generate(24, (h) => (h >= 9 && h <= 17) ? (d < 5 ? 3000 : 600) : (h >= 23 ? 400 : 0)));
  return HistoryInsights(
    daily: daily,
    weekdayHour: grid,
    weekdayCount: List.filled(7, 26),
    goal: const Duration(hours: 4),
    currentStreak: 4,
    longestStreak: 9,
    busiestDay: MapEntry(_today.subtract(const Duration(days: 12)), const Duration(hours: 9, minutes: 5)),
    lightestDay: MapEntry(_today.subtract(const Duration(days: 3)), const Duration(minutes: 20)),
    busiestWeek: MapEntry(_today.subtract(const Duration(days: 40)), const Duration(hours: 41)),
    productive: const WeekPair(20000, 15000),
    other: const WeekPair(9000, 12000),
    lateNight: const WeekPair(3000, 1000),
    opens: const WeekPair(120, 150),
    activeSeconds: const WeekPair(30000, 28000),
    trends: const [
      AppTrend('Code', [3600, 7200, 5400, 9000]),
      AppTrend('A very long application name that should be clipped nicely', [100, 200, 300, 400]),
    ],
  );
}

class _FakeInsights extends InsightsData {
  _FakeInsights({this.titles = true, this.empty = false, this.peers = false})
      : super(AppDataStore(), now: () => _today);

  final bool peers;
  int unplaced = 0;
  final List<bool> totalsRequestedWithAllDevices = [];

  @override
  bool get hasPeers => peers;

  final bool titles;
  final bool empty;
  final List<String> searches = [];
  final List<DateTime> timelineRequests = [];

  @override
  Map<DateTime, Duration> dailyTotals(int days) {
    totalsRequestedWithAllDevices.add(allDevices);
    return _totals(days);
  }

  bool rich = false;

  @override
  HistoryInsights history(int days, {Duration? goal}) => rich
      ? _richHistory(dailyTotals(days))
      : HistoryInsights.fromDaily(dailyTotals(days));

  @override
  LongestBlock? longestBlock({int days = 7}) =>
      rich ? LongestBlock(5400, 'Code', _today) : null;

  @override
  DayBookends? dayBookends(DateTime day) => rich
      ? DayBookends('Mail', DateTime(2026, 3, 18, 8, 5), 'Code', DateTime(2026, 3, 18, 22, 40))
      : null;

  @override
  List<TitleHit> topTitles({int days = 7, int limit = 5}) =>
      rich ? [TitleHit('', 'Code', 'Scolect - main.dart', 3600, _today)] : const [];

  Map<DateTime, Duration> _totals(int days) => {
        for (var i = 0; i < days; i++)
          _today.subtract(Duration(days: days - 1 - i)):
              empty ? Duration.zero : Duration(minutes: (i % 5) * 30),
      };

  @override
  WeekComparison compareWeeks({int moversLimit = 5}) => empty
      ? const WeekComparison(Duration.zero, Duration.zero, [], [])
      : const WeekComparison(
          Duration(hours: 10),
          Duration(hours: 8),
          [CategoryDelta('Development', Duration(hours: 6), Duration(hours: 3))],
          [AppDelta('code', 'Code', Duration(hours: 6), Duration(hours: 3))],
        );

  @override
  DayTimeline dayTimeline(DateTime day, {int topApps = 6}) {
    timelineRequests.add(day);
    final hours = List.generate(24, (_) => <String, int>{});
    if (!empty && day == _today) hours[9]['code'] = 1800;
    return DayTimeline(
      day,
      empty || day != _today ? const [] : const [TimelineSegment('code', 'Code', 1800)],
      hours,
      unplacedSeconds: unplaced,
    );
  }

  @override
  bool hasAnyTitles({int days = 30}) => titles;

  @override
  List<TitleHit> searchTitles(String query, {int days = 30, int limit = 50}) {
    searches.add(query);
    return query == 'scolect'
        ? [TitleHit('code', 'Code', 'Scolect - main.dart', 3600, _today)]
        : const [];
  }
}

Widget _app(Widget child) => ChangeNotifierProvider(
      create: (_) => ThemeCustomizationProvider(),
      child: _themedApp(child),
    );

Widget _themedApp(Widget child) => FluentApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: ScaffoldPage(content: SingleChildScrollView(child: child)),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  // The Time log card also has a TextBox, so find the search field by its hint.
  Finder searchBox() => find.byWidgetPredicate(
      (w) => w is TextBox && w.placeholder == 'Search document, page or project names');

  group('ActivityHeatmap.level', () {
    const max = Duration(hours: 4);
    test('buckets durations relative to the busiest day', () {
      expect(ActivityHeatmap.level(Duration.zero, max), 0);
      expect(ActivityHeatmap.level(const Duration(minutes: 30), max), 1);
      expect(ActivityHeatmap.level(const Duration(hours: 1, minutes: 30), max), 2);
      expect(ActivityHeatmap.level(const Duration(hours: 2, minutes: 30), max), 3);
      expect(ActivityHeatmap.level(max, max), 4);
    });

    test('no data at all stays at level 0', () {
      expect(ActivityHeatmap.level(const Duration(hours: 1), Duration.zero), 0);
    });
  });

  testWidgets('renders trends, heatmap, timeline and search', (tester) async {
    tester.view.physicalSize = const Size(1400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(InsightsView(data: _FakeInsights())));
    await tester.pumpAndSettle();

    expect(find.text('This week vs last week'), findsOneWidget);
    expect(find.text('Development'), findsOneWidget);
    expect(find.text('Biggest changes'), findsOneWidget);
    expect(find.text('Code'), findsWidgets);
    expect(find.text('Daily activity, last 26 weeks'), findsOneWidget);
    expect(find.text('Day timeline'), findsOneWidget);
    expect(find.text('Search window titles'), findsOneWidget);
    expect(find.text('+3h'), findsWidgets);
  });

  for (final width in [1400.0, 700.0, 420.0]) {
    testWidgets('long-range cards lay out without overflow at ${width.toInt()}px',
        (tester) async {
      tester.view.physicalSize = Size(width, 6000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(InsightsView(data: _FakeInsights()..rich = true)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Highlights'), findsOneWidget);
      expect(find.text('When you are most active'), findsOneWidget);
      expect(find.text('Streaks and records'), findsOneWidget);
      expect(find.text('Focus vs everything else'), findsOneWidget);
      expect(find.text('Usage habits'), findsOneWidget);
      expect(find.text('Top apps, last 4 weeks'), findsOneWidget);
      expect(find.text('First app of the day'), findsOneWidget);
      expect(find.text('Most-used windows this week'), findsOneWidget);
    });
  }

  testWidgets('shows empty states when there is no data', (tester) async {
    tester.view.physicalSize = const Size(1400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
        _app(InsightsView(data: _FakeInsights(titles: false, empty: true))));
    await tester.pumpAndSettle();

    expect(find.text('Not enough data yet.'), findsOneWidget);
    expect(find.text('No activity recorded for this day.'), findsOneWidget);
    expect(find.textContaining('turn on recording'), findsOneWidget);
    expect(searchBox(), findsNothing);
  });

  testWidgets('previous/next day buttons move the timeline; next stops at today',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fake = _FakeInsights();

    await tester.pumpWidget(_app(InsightsView(data: fake)));
    await tester.pumpAndSettle();

    IconButton next() => tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, FluentIcons.chevron_right));
    expect(next().onPressed, isNull); // already on today

    await tester.tap(find.widgetWithIcon(IconButton, FluentIcons.chevron_left));
    await tester.pumpAndSettle();
    expect(fake.timelineRequests.last, _today.subtract(const Duration(days: 1)));
    expect(next().onPressed, isNotNull);

    await tester.tap(find.widgetWithIcon(IconButton, FluentIcons.chevron_right));
    await tester.pumpAndSettle();
    expect(fake.timelineRequests.last, _today);
  });

  testWidgets('searching lists matching windows and reports no matches',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fake = _FakeInsights();

    await tester.pumpWidget(_app(InsightsView(data: fake)));
    await tester.pumpAndSettle();

    await tester.enterText(searchBox(), 'scolect');
    await tester.pumpAndSettle();
    expect(find.text('Scolect - main.dart'), findsOneWidget);

    await tester.enterText(searchBox(), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Scolect - main.dart'), findsNothing);
    expect(find.text('No matching windows in the last 30 days.'), findsOneWidget);
  });

  testWidgets('tapping a heatmap cell selects that day', (tester) async {
    tester.view.physicalSize = const Size(1400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fake = _FakeInsights();

    await tester.pumpWidget(_app(InsightsView(data: fake)));
    await tester.pumpAndSettle();
    final before = fake.timelineRequests.length;

    // The last cell in the grid belongs to a recent day; any tap selects a day.
    await tester.tap(find
        .descendant(
            of: find.byType(ActivityHeatmap),
            matching: find.byType(GestureDetector))
        .first);
    await tester.pumpAndSettle();

    expect(fake.timelineRequests.length, greaterThan(before));
  });

  testWidgets('the device toggle only appears when other devices exist',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(InsightsView(data: _FakeInsights())));
    await tester.pumpAndSettle();
    expect(find.text('All devices'), findsNothing);

    // A new key forces fresh state; the view keeps its data object for life.
    await tester.pumpWidget(
        _app(InsightsView(key: UniqueKey(), data: _FakeInsights(peers: true))));
    await tester.pumpAndSettle();
    expect(find.text('This device'), findsOneWidget);
    expect(find.text('All devices'), findsOneWidget);
  });

  testWidgets('switching to All devices reloads the numbers with peers included',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fake = _FakeInsights(peers: true);

    await tester.pumpWidget(_app(InsightsView(data: fake)));
    await tester.pumpAndSettle();
    expect(fake.totalsRequestedWithAllDevices, [false]);

    await tester.tap(find.text('All devices'));
    await tester.pumpAndSettle();
    expect(fake.allDevices, isTrue);
    expect(fake.totalsRequestedWithAllDevices.last, isTrue);

    await tester.tap(find.text('This device'));
    await tester.pumpAndSettle();
    expect(fake.allDevices, isFalse);
    expect(fake.totalsRequestedWithAllDevices.last, isFalse);
  });

  testWidgets('unplaced time is explained next to the timeline', (tester) async {
    tester.view.physicalSize = const Size(1400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fake = _FakeInsights()..unplaced = 25 * 60;

    await tester.pumpWidget(_app(InsightsView(data: fake)));
    await tester.pumpAndSettle();
    expect(find.textContaining("25m of this day isn't shown above"), findsOneWidget);
  });

  testWidgets('a day with only unplaced time is not called empty', (tester) async {
    tester.view.physicalSize = const Size(1400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fake = _FakeInsights(empty: true)..unplaced = 40 * 60;

    await tester.pumpWidget(_app(InsightsView(data: fake)));
    await tester.pumpAndSettle();
    expect(find.text('No activity recorded for this day.'), findsNothing);
    expect(find.textContaining("40m of this day isn't shown above"), findsOneWidget);
  });

  testWidgets('tiny amounts of unplaced time are not worth mentioning',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fake = _FakeInsights()..unplaced = 30;

    await tester.pumpWidget(_app(InsightsView(data: fake)));
    await tester.pumpAndSettle();
    expect(find.textContaining("isn't shown above"), findsNothing);
  });
}
