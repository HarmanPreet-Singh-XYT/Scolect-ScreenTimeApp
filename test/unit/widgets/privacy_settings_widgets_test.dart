// test/unit/widgets/privacy_settings_widgets_test.dart
//
// Widget tests for the extension approval and privacy filter UIs.

// ignore_for_file: depend_on_referenced_packages

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/sections/widgets/Settings/category_rules_section.dart';
import 'package:screentime/sections/widgets/Settings/extension_access.dart';
import 'package:screentime/utils/category_rules.dart';
import 'package:screentime/sections/widgets/Settings/privacy_filters_section.dart';
import 'package:screentime/utils/extension_auth.dart';
import 'package:screentime/utils/privacy_filters.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _id = '11111111-2222-3333-4444-555555555555';
final _token = 'a' * 64;

Widget _app(Widget child) => FluentApp(
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
    ExtensionAuth.instance.resetForTesting();
    SettingsManager().updateSetting(ExtensionAuth.settingKey, true);
    SettingsManager().updateSetting(PrivacyFilters.settingKey, <dynamic>[]);
    PrivacyFilters.instance.refresh();
    SettingsManager().updateSetting(CategoryRules.settingKey, <dynamic>[]);
    CategoryRules.instance.refresh();
  });

  testWidgets('approval banner is hidden until a browser is pending',
      (tester) async {
    await tester.pumpWidget(_app(const ExtensionApprovalBanner()));
    await tester.pumpAndSettle();
    expect(find.text('A browser wants to sync with Scolect'), findsNothing);

    ExtensionAuth.instance.check(_id, _token, browserName: 'Chrome');
    await tester.pumpAndSettle();
    expect(find.text('A browser wants to sync with Scolect'), findsOneWidget);
    expect(find.textContaining('Chrome'), findsWidgets);
  });

  testWidgets('approving from the banner approves the browser',
      (tester) async {
    await tester.pumpWidget(_app(const ExtensionApprovalBanner()));
    await tester.pumpAndSettle();
    ExtensionAuth.instance.check(_id, _token, browserName: 'Chrome');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();

    expect(ExtensionAuth.instance.isApproved(_id), isTrue);
    expect(find.text('A browser wants to sync with Scolect'), findsNothing);
  });

  testWidgets('settings card lists approved browsers and can revoke them',
      (tester) async {
    ExtensionAuth.instance.check(_id, _token, browserName: 'Firefox');
    await ExtensionAuth.instance.approve(_id);

    await tester.pumpWidget(_app(const ExtensionAccessSection()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Firefox'), findsOneWidget);

    await tester.tap(find.text('Revoke'));
    await tester.pumpAndSettle();
    expect(ExtensionAuth.instance.isApproved(_id), isFalse);
  });

  testWidgets('adding a rule through the dialog saves and applies it',
      (tester) async {
    await tester.pumpWidget(_app(const PrivacyFiltersSection()));
    await tester.pumpAndSettle();
    expect(find.text('No rules yet.'), findsOneWidget);

    await tester.tap(find.text('Add rule'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextBox).first, 'bank');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('bank'), findsOneWidget);
    expect(PrivacyFilters.instance.applyToApp('com.mybank', 'x').excluded, isTrue);
  });

  testWidgets('an invalid pattern shows an error and is not saved',
      (tester) async {
    await tester.pumpWidget(_app(const PrivacyFiltersSection()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add rule'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextBox).first, '(');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text("This isn't a valid regular expression."), findsOneWidget);
    expect(PrivacyFilters.instance.rules, isEmpty);
  });

  testWidgets('toggling and deleting a rule updates the engine', (tester) async {
    SettingsManager().updateSetting(PrivacyFilters.settingKey, [
      const PrivacyFilterRule(id: 'r1', pattern: 'bank').toJson(),
    ]);
    PrivacyFilters.instance.refresh();

    await tester.pumpWidget(_app(const PrivacyFiltersSection()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ToggleSwitch));
    await tester.pumpAndSettle();
    expect(PrivacyFilters.instance.applyToApp('com.mybank', 'x').excluded, isFalse);

    await tester.tap(find.byIcon(FluentIcons.delete));
    await tester.pumpAndSettle();
    expect(PrivacyFilters.instance.rules, isEmpty);
  });

  testWidgets('adding a category rule saves it and it takes effect',
      (tester) async {
    await tester.pumpWidget(_app(const CategoryRulesSection()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add rule'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextBox).first, 'figma');
    await tester.enterText(find.byType(TextBox).last, 'Design');
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('figma'), findsOneWidget);
    expect(find.text('→ Design'), findsOneWidget);
    expect(CategoryRules.instance.categorize('com.figma', 'Figma'), 'Design');
  });

  testWidgets('a category rule without a category is rejected', (tester) async {
    await tester.pumpWidget(_app(const CategoryRulesSection()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add rule'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextBox).first, 'figma');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a category.'), findsOneWidget);
    expect(CategoryRules.instance.rules, isEmpty);
  });

  testWidgets('category rules can be reordered and deleted', (tester) async {
    SettingsManager().updateSetting(CategoryRules.settingKey, [
      const CategoryRule(id: 'a', pattern: 'aaa', category: 'One').toJson(),
      const CategoryRule(id: 'b', pattern: 'bbb', category: 'Two').toJson(),
    ]);
    CategoryRules.instance.refresh();
    await tester.pumpWidget(_app(const CategoryRulesSection()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(FluentIcons.chevron_up).last);
    await tester.pumpAndSettle();
    expect(CategoryRules.instance.rules.map((r) => r.id), ['b', 'a']);

    await tester.tap(find.byIcon(FluentIcons.delete).first);
    await tester.pumpAndSettle();
    expect(CategoryRules.instance.rules.map((r) => r.id), ['a']);
  });
}
