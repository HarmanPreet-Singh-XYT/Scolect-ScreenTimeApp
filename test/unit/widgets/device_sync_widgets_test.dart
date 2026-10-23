// test/unit/widgets/device_sync_widgets_test.dart

// ignore_for_file: depend_on_referenced_packages

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/sections/widgets/Settings/device_sync_section.dart';
import 'package:screentime/utils/device_snapshot.dart';
import 'package:screentime/utils/device_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSync extends DeviceSync {
  final List<String> calls = [];
  List<DeviceSnapshot> fakePeers = const [];
  String? fakeError;
  DateTime? fakeLast;

  @override
  List<DeviceSnapshot> get peers => fakePeers;
  @override
  String? get lastError => fakeError;
  @override
  DateTime? get lastSyncedAt => fakeLast;

  @override
  Future<void> setEnabled(bool value) async {
    calls.add('enabled:$value');
    SettingsManager().updateSetting('deviceSync.enabled', value);
    notifyListeners();
  }

  @override
  Future<void> setFolder(String path) async {
    calls.add('folder:$path');
    SettingsManager().updateSetting('deviceSync.folder', path);
    notifyListeners();
  }

  @override
  Future<bool> syncOnce() async {
    calls.add('sync');
    fakeLast = DateTime(2026, 3, 18, 10, 30);
    notifyListeners();
    return true;
  }

  @override
  Future<void> removeOwnFile() async => calls.add('remove');
}

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

  late _FakeSync sync;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsManager().init();
    sync = _FakeSync();
  });

  testWidgets('off by default: only the toggle is shown', (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(DeviceSyncSection(sync: sync)));
    await tester.pumpAndSettle();

    expect(find.text('Sync through a folder'), findsOneWidget);
    expect(find.text('Choose folder'), findsNothing);
    expect(find.text('Other devices'), findsNothing);
  });

  testWidgets('turning it on shows folder, status and other devices',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(DeviceSyncSection(sync: sync)));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ToggleSwitch));
    await tester.pumpAndSettle();

    expect(sync.calls, ['enabled:true']);
    expect(find.text('No folder chosen'), findsOneWidget);
    expect(find.text('Not synced yet'), findsOneWidget);
    expect(find.textContaining('No other devices found yet'), findsOneWidget);

    // "Sync now" needs a folder first.
    expect(tester.widget<Button>(find.widgetWithText(Button, 'Sync now')).onPressed, isNull);
  });

  testWidgets('choosing a folder, syncing, and listing peers', (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SettingsManager().updateSetting('deviceSync.enabled', true);
    sync.fakePeers = [
      DeviceSnapshot(
        deviceId: 'b' * 32,
        deviceName: 'Work PC',
        updatedAt: DateTime(2026, 3, 18, 9, 15),
        days: const {},
      )
    ];

    await tester.pumpWidget(_app(DeviceSyncSection(
      sync: sync,
      pickFolder: () async => '/tmp/shared',
    )));
    await tester.pumpAndSettle();
    expect(find.textContaining('Work PC'), findsOneWidget);

    await tester.tap(find.text('Choose folder'));
    await tester.pumpAndSettle();
    expect(sync.calls, ['folder:/tmp/shared']);
    expect(find.text('/tmp/shared'), findsOneWidget);

    await tester.tap(find.text('Sync now'));
    await tester.pumpAndSettle();
    expect(sync.calls.last, 'sync');
    expect(find.textContaining('Last synced'), findsOneWidget);
  });

  testWidgets('cancelling the folder picker changes nothing', (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SettingsManager().updateSetting('deviceSync.enabled', true);

    await tester.pumpWidget(
        _app(DeviceSyncSection(sync: sync, pickFolder: () async => null)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose folder'));
    await tester.pumpAndSettle();
    expect(sync.calls, isEmpty);
  });

  testWidgets('errors are shown, and turning sync off removes our file first',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SettingsManager().updateSetting('deviceSync.enabled', true);
    sync.fakeError = 'folder not writable';

    await tester.pumpWidget(_app(DeviceSyncSection(sync: sync)));
    await tester.pumpAndSettle();
    expect(find.text('Sync problem: folder not writable'), findsOneWidget);

    await tester.tap(find.byType(ToggleSwitch));
    await tester.pumpAndSettle();
    expect(sync.calls, ['remove', 'enabled:false']);
    expect(find.text('Choose folder'), findsNothing);
  });
}
