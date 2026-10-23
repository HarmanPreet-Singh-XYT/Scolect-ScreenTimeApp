// test/unit/utils/device_sync_exchange_test.dart
//
// Two independent DeviceSync instances exchanging data through one real folder,
// the way two computers share a Dropbox folder. No data store is involved, so
// this runs on every platform.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/utils/device_snapshot.dart';
import 'package:screentime/utils/device_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _idA = 'a' * 32;
final _idB = 'b' * 32;
final _day = DateTime(2026, 3, 18);

DeviceSnapshot Function(String, String, DateTime) _source(
        List<SnapshotApp> Function() apps) =>
    (id, name, now) => DeviceSnapshot(
          deviceId: id,
          deviceName: name,
          updatedAt: now,
          days: {DeviceSnapshot.dayKey(_day): apps()},
        );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory shared;
  var clockA = DateTime(2026, 3, 18, 10);

  late List<SnapshotApp> appsA;
  late List<SnapshotApp> appsB;
  late DeviceSync a;
  late DeviceSync b;

  Directory syncDir() => Directory('${shared.path}/${DeviceSync.folderName}');

  DeviceSync make(String id, String name, List<SnapshotApp> Function() apps,
          {DateTime Function()? now}) =>
      DeviceSync(
        idOverride: id,
        nameOverride: name,
        folderOverride: shared.path,
        snapshotSource: _source(apps),
        now: now,
        interval: const Duration(days: 1),
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsManager().init();
    shared = await Directory.systemTemp.createTemp('exchange');
    appsA = [const SnapshotApp('Code', 'Development', 3600, {9: 3600})];
    appsB = [const SnapshotApp('Photoshop', 'Creative', 1800, {11: 1800})];
    clockA = DateTime(2026, 3, 18, 10);
    a = make(_idA, 'MacBook', () => appsA, now: () => clockA);
    b = make(_idB, 'Desktop', () => appsB);
  });

  tearDown(() async {
    await a.resetForTesting();
    await b.resetForTesting();
    if (await shared.exists()) await shared.delete(recursive: true);
  });

  test('each device sees the other after a sync round, and never itself', () async {
    expect(await a.syncOnce(), isTrue);
    expect(a.peers, isEmpty); // B hasn't written yet

    expect(await b.syncOnce(), isTrue);
    expect(b.peers.map((p) => p.deviceName), ['MacBook']);
    expect(b.peers.single.totalOn(_day), const Duration(hours: 1));

    expect(await a.syncOnce(), isTrue);
    expect(a.peers.map((p) => p.deviceName), ['Desktop']);
    expect(a.peers.single.appsOn(_day).single.name, 'Photoshop');

    expect(syncDir().listSync().whereType<File>().map((f) => f.uri.pathSegments.last).toSet(),
        {'$_idA.json', '$_idB.json'});
  });

  test('changes made on one device reach the other on its next sync', () async {
    await a.syncOnce();
    await b.syncOnce();
    expect(b.peers.single.totalOn(_day), const Duration(hours: 1));

    appsA = [const SnapshotApp('Code', 'Development', 7200, {9: 3600, 10: 3600})];
    await a.syncOnce();
    await b.syncOnce();
    expect(b.peers.single.totalOn(_day), const Duration(hours: 2));
  });

  test('simultaneous syncs on both devices never corrupt either file', () async {
    for (var i = 0; i < 25; i++) {
      appsA = [SnapshotApp('Code', 'Development', 60 * (i + 1), {9: 60 * (i + 1)})];
      appsB = [SnapshotApp('Photoshop', 'Creative', 60 * (i + 2), {11: 60 * (i + 2)})];
      final results = await Future.wait([a.syncOnce(), b.syncOnce(), a.syncOnce(), b.syncOnce()]);
      expect(results, everyElement(isTrue), reason: 'round $i');
    }
    // Both files parse, and each device ends up seeing the other's latest data.
    for (final id in [_idA, _idB]) {
      final text = await File('${syncDir().path}/$id.json').readAsString();
      expect(DeviceSnapshot.parse(text), isNotNull, reason: id);
    }
    await a.syncOnce();
    await b.syncOnce();
    expect(a.peers.single.totalOn(_day), const Duration(seconds: 60 * 26));
    expect(b.peers.single.totalOn(_day), const Duration(seconds: 60 * 25));
    expect(syncDir().listSync().where((e) => e.path.endsWith('.tmp')), isEmpty);
  });

  test('a half-uploaded peer file is skipped and picked up once complete', () async {
    await a.syncOnce();
    final full = DeviceSnapshot(
      deviceId: _idB,
      deviceName: 'Desktop',
      updatedAt: DateTime(2026, 3, 18, 9),
      days: {DeviceSnapshot.dayKey(_day): appsB},
    ).toJson();
    final peerFile = File('${syncDir().path}/$_idB.json');

    await peerFile.writeAsString(full.substring(0, full.length ~/ 2)); // cut off mid-upload
    expect(await a.syncOnce(), isTrue);
    expect(a.peers, isEmpty);

    await peerFile.writeAsString(full);
    await a.syncOnce();
    expect(a.peers.single.deviceName, 'Desktop');
  });

  test('a peer that stops syncing keeps its last data; deleting its file removes it',
      () async {
    await a.syncOnce();
    await b.syncOnce();
    await a.syncOnce();
    expect(a.peers, hasLength(1));

    await b.removeOwnFile();
    await a.syncOnce();
    expect(a.peers, isEmpty);
    // A's own file is untouched.
    expect(File('${syncDir().path}/$_idA.json').existsSync(), isTrue);
  });

  test('sync-client conflict copies of a peer file are ignored', () async {
    await b.syncOnce();
    final original = File('${syncDir().path}/$_idB.json');
    await original.copy('${syncDir().path}/$_idB (conflicted copy 2026-03-18).json');
    await original.copy('${syncDir().path}/$_idB.json.sync-conflict');

    await a.syncOnce();
    expect(a.peers, hasLength(1));
  });

  test('a read-only or missing folder is reported, not thrown', () async {
    final broken = DeviceSync(
      idOverride: _idA,
      nameOverride: 'X',
      folderOverride: '${shared.path}/does/not/exist/\u0000bad',
      snapshotSource: _source(() => appsA),
    );
    expect(await broken.syncOnce(), isFalse);
    expect(broken.lastError, isNotNull);
  });

  group('refreshIfStale', () {
    late DateTime now;
    late int syncs;

    DeviceSync counting() {
      syncs = 0;
      final s = DeviceSync(
        idOverride: _idA,
        nameOverride: 'A',
        folderOverride: shared.path,
        snapshotSource: (id, name, n) {
          syncs++;
          return DeviceSnapshot(deviceId: id, deviceName: name, updatedAt: n, days: const {});
        },
        now: () => now,
        interval: const Duration(days: 1),
      );
      return s;
    }

    setUp(() => now = DateTime(2026, 3, 18, 10));

    test('does nothing while sync is turned off', () async {
      SettingsManager().updateSetting('deviceSync.enabled', false);
      final s = counting();
      await s.refreshIfStale();
      expect(syncs, 0);
    });

    test('syncs when stale, skips when fresh, syncs again later', () async {
      SettingsManager().updateSetting('deviceSync.enabled', true);
      final s = counting();

      await s.refreshIfStale();
      expect(syncs, 1);
      now = now.add(const Duration(seconds: 20));
      await s.refreshIfStale();
      expect(syncs, 1);
      now = now.add(const Duration(minutes: 2));
      await s.refreshIfStale();
      expect(syncs, 2);
    });
  });
}
