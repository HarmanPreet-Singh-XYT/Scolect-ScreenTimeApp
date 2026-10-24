// test/unit/widgets/time_alerts_widgets_test.dart
//
// Widget tests for the time log card, category limits and daily digest UIs.

// ignore_for_file: depend_on_referenced_packages

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:screentime/sections/widgets/Settings/theme_provider.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/sections/widgets/Reports/insights/time_log_card.dart';
import 'package:screentime/sections/widgets/Settings/category_limits_section.dart';
import 'package:screentime/utils/category_limits.dart';
import 'package:screentime/utils/manual_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsManager().init();
    SettingsManager().updateSetting(CategoryLimits.settingKey, <dynamic>[]);
    CategoryLimits.instance.refresh();
  });

  group('TimeLogCard', () {
    late DateTime clock;
    late ManualLog log;

    setUp(() {
      clock = DateTime.now();
      log = ManualLog(now: () => clock);
    });

    testWidgets('start, tick, stop records an entry that can be deleted',
        (tester) async {
      await tester.pumpWidget(_app(TimeLogCard(log: log)));
      await tester.pumpAndSettle();
      expect(find.text('Nothing logged today.'), findsOneWidget);

      await tester.enterText(find.byType(TextBox), 'Writing report');
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      expect(find.text('Writing report'), findsOneWidget);
      expect(find.text('00:00:00'), findsOneWidget);

      clock = clock.add(const Duration(minutes: 12, seconds: 5));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:12:05'), findsOneWidget);

      await tester.tap(find.text('Stop'));
      await tester.pumpAndSettle();
      expect(log.entries.single.seconds, 12 * 60 + 5);
      expect(find.text('12m'), findsWidgets);
      expect(find.text('Nothing logged today.'), findsNothing);

      await tester.tap(find.byIcon(FluentIcons.delete));
      await tester.pumpAndSettle();
      expect(log.entries, isEmpty);
    });

    testWidgets('discard drops a running stopwatch', (tester) async {
      await tester.pumpWidget(_app(TimeLogCard(log: log)));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextBox), 'Oops');
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(log.running, isNull);
      expect(log.entries, isEmpty);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('starting without a label does nothing', (tester) async {
      await tester.pumpWidget(_app(TimeLogCard(log: log)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      expect(log.running, isNull);
    });

    testWidgets('manual entry dialog validates and then saves', (tester) async {
      await tester.pumpWidget(_app(TimeLogCard(log: log)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add entry'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter what you worked on.'), findsOneWidget);

      // NumberBox contains TextBoxes too, so target the label field by its hint.
      await tester.enterText(
          find
              .byWidgetPredicate(
                  (w) => w is TextBox && w.placeholder == 'What are you working on?')
              .last,
          'Team meeting');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(log.entries.single.label, 'Team meeting');
      expect(log.entries.single.seconds, 30 * 60); // default 0h 30m
    });
  });

  group('CategoryLimitsSection', () {
    testWidgets('adding a limit saves it with the chosen duration', (tester) async {
      await tester.pumpWidget(_app(const CategoryLimitsSection()));
      await tester.pumpAndSettle();
      expect(find.text('No rules yet.'), findsOneWidget);

      await tester.tap(find.text('Add limit'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextBox).first, 'Social Media');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final saved = CategoryLimits.instance.limits.single;
      expect(saved.category, 'Social Media');
      expect(saved.minutes, 60); // default 1h
      expect(find.text('Social Media'), findsOneWidget);
    });

    testWidgets('a limit without a category is rejected', (tester) async {
      await tester.pumpWidget(_app(const CategoryLimitsSection()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add limit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Choose a category.'), findsOneWidget);
      expect(CategoryLimits.instance.limits, isEmpty);
    });

    testWidgets('limits can be toggled and deleted', (tester) async {
      SettingsManager().updateSetting(CategoryLimits.settingKey, [
        const CategoryLimit(id: 'a', category: 'Gaming', minutes: 90).toJson(),
      ]);
      CategoryLimits.instance.refresh();
      await tester.pumpWidget(_app(const CategoryLimitsSection()));
      await tester.pumpAndSettle();
      expect(find.text('1h 30m'), findsOneWidget);

      await tester.tap(find.byType(ToggleSwitch));
      await tester.pumpAndSettle();
      expect(CategoryLimits.instance.limits.single.enabled, isFalse);

      await tester.tap(find.byIcon(FluentIcons.delete));
      await tester.pumpAndSettle();
      expect(CategoryLimits.instance.limits, isEmpty);
    });
  });

  group('DailyDigestSection', () {
    testWidgets('toggling stores the setting and reveals the hour picker',
        (tester) async {
      await tester.pumpWidget(_app(const DailyDigestSection()));
      await tester.pumpAndSettle();
      expect(find.byType(ComboBox<int>), findsNothing);

      await tester.tap(find.byType(ToggleSwitch));
      await tester.pumpAndSettle();
      expect(SettingsManager().getSetting('dailyDigest.enabled'), isTrue);
      expect(find.byType(ComboBox<int>), findsOneWidget);
      expect(find.text('21:00'), findsOneWidget);
    });
  });
}
