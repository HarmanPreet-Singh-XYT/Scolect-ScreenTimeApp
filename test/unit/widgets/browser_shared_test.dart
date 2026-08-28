import 'package:flutter_test/flutter_test.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/sections/widgets/Browser/browser_shared.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CategoryMeta mapping tests', () {
    test('correctly maps developer category', () {
      final meta = CategoryMeta.fromName('Development');
      expect(meta.icon, equals(FluentIcons.code));
      expect(meta.color, equals(kBrowserBlue));
    });

    test('correctly maps social category', () {
      final meta = CategoryMeta.fromName('Social Media');
      expect(meta.icon, equals(FluentIcons.chat));
      expect(meta.color, equals(kBrowserPink));
    });

    test('correctly maps video/media category', () {
      final meta = CategoryMeta.fromName('Entertainment / Video');
      expect(meta.icon, equals(FluentIcons.video));
      expect(meta.color, equals(kBrowserPurple));
    });

    test('correctly maps productivity category', () {
      final meta = CategoryMeta.fromName('Productivity');
      expect(meta.icon, equals(FluentIcons.task_list));
      expect(meta.color, equals(kBrowserGreen));
    });

    test('correctly maps education category', () {
      final meta = CategoryMeta.fromName('Education');
      expect(meta.icon, equals(FluentIcons.education));
      expect(meta.color, equals(kBrowserCyan));
    });

    test('correctly maps shopping category', () {
      final meta = CategoryMeta.fromName('Shopping');
      expect(meta.icon, equals(FluentIcons.shopping_cart));
      expect(meta.color, equals(kBrowserAmber));
    });

    test('falls back to default tag icon for unknown category', () {
      final meta = CategoryMeta.fromName('Unknown Category XYZ');
      expect(meta.icon, equals(FluentIcons.tag));
      expect(meta.color, equals(kBrowserBlue));
    });
  });

  group('Browser Domain Avatar Widget tests', () {
    testWidgets('renders domain initials properly', (tester) async {
      await tester.pumpWidget(
        const FluentApp(
          home: Center(
            child: BrowserDomainAvatar(
              domain: 'github.com',
              siteName: 'GitHub',
              size: 32,
            ),
          ),
        ),
      );

      expect(find.text('GI'), findsOneWidget);
    });

    testWidgets('strips www prefix for initial extraction', (tester) async {
      await tester.pumpWidget(
        const FluentApp(
          home: Center(
            child: BrowserDomainAvatar(
              domain: 'www.youtube.com',
              size: 32,
            ),
          ),
        ),
      );

      expect(find.text('YC'), findsOneWidget);
    });
  });

  group('Browser Segmented Tab Bar tests', () {
    testWidgets('renders tabs with badges', (tester) async {
      BrowserTab selectedTab = BrowserTab.overview;

      await tester.pumpWidget(
        FluentApp(
          home: Center(
            child: BrowserSegmentedTabBar(
              currentTab: selectedTab,
              onTabChanged: (t) => selectedTab = t,
              tabCounts: const {
                BrowserTab.websites: 42,
                BrowserTab.categories: 8,
                BrowserTab.limits: 3,
              },
            ),
          ),
        ),
      );

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Websites'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Limits'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);

      // Badge counts
      expect(find.text('42'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });
}
