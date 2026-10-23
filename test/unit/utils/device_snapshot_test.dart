// test/unit/utils/device_snapshot_test.dart
//
// The parser reads files written by other machines, so these focus on what it
// must refuse.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:screentime/utils/device_snapshot.dart';

final _id = 'a' * 32;

Map<String, dynamic> _valid({Map<String, dynamic>? days, Object? id, Object? version}) => {
      'version': version ?? 1,
      'deviceId': id ?? _id,
      'deviceName': 'Laptop',
      'updatedAt': 1700000000000,
      'days': days ??
          {
            '2026-03-18': [
              {'n': 'Code', 'c': 'Development', 's': 3600, 'h': {'9': 1800, '10': 1800}},
              {'n': 'Chat', 'c': 'Social Media', 's': 600},
            ]
          },
    };

DeviceSnapshot? _parse(Map<String, dynamic> m) => DeviceSnapshot.parse(jsonEncode(m));

void main() {
  group('round trip', () {
    test('serialises and parses back the same data', () {
      final snap = DeviceSnapshot.parse(jsonEncode(_valid()))!;
      expect(snap.deviceId, _id);
      expect(snap.deviceName, 'Laptop');
      expect(snap.updatedAt, DateTime.fromMillisecondsSinceEpoch(1700000000000));
      expect(snap.totalOn(DateTime(2026, 3, 18)), const Duration(seconds: 4200));
      expect(snap.appsOn(DateTime(2026, 3, 18)).first.hourly, {9: 1800, 10: 1800});

      final again = DeviceSnapshot.parse(snap.toJson())!;
      expect(again.contentJson(), snap.contentJson());
    });

    test('contentJson ignores updatedAt so unchanged data is detectable', () {
      final a = DeviceSnapshot.parse(jsonEncode(_valid()))!;
      final b = DeviceSnapshot.parse(jsonEncode({..._valid(), 'updatedAt': 1800000000000}))!;
      expect(a.contentJson(), b.contentJson());
    });

    test('contentJson is stable regardless of input order', () {
      final reordered = _valid(days: {
        '2026-03-18': [
          {'n': 'Chat', 'c': 'Social Media', 's': 600},
          {'n': 'Code', 'c': 'Development', 's': 3600, 'h': {'10': 1800, '9': 1800}},
        ]
      });
      expect(_parse(reordered)!.contentJson(), _parse(_valid())!.contentJson());
    });
  });

  group('rejects bad files', () {
    test('wrong version, bad id, wrong types', () {
      expect(_parse(_valid(version: 2)), isNull);
      expect(_parse(_valid(id: 'short')), isNull);
      expect(_parse(_valid(id: 'A' * 32)), isNull); // upper case
      expect(_parse(_valid(id: '../../etc/passwd')), isNull);
      expect(DeviceSnapshot.parse('not json'), isNull);
      expect(DeviceSnapshot.parse('[]'), isNull);
      expect(DeviceSnapshot.parse('{}'), isNull);
      expect(DeviceSnapshot.parse(''), isNull);
    });

    test('impossible dates and day keys', () {
      for (final key in ['2026-02-31', '2026-13-01', 'yesterday', '2026-3-1', '']) {
        expect(_parse(_valid(days: {key: <dynamic>[]})), isNull, reason: key);
      }
      expect(DeviceSnapshot.parseDay('2026-02-28'), DateTime(2026, 2, 28));
      expect(DeviceSnapshot.parseDay('2026-02-31'), isNull);
    });

    test('out-of-range numbers', () {
      Map<String, dynamic> one(Map<String, dynamic> app) => _valid(days: {'2026-03-18': [app]});
      expect(_parse(one({'n': 'A', 'c': 'X', 's': -1})), isNull);
      expect(_parse(one({'n': 'A', 'c': 'X', 's': 86401})), isNull);
      expect(_parse(one({'n': 'A', 'c': 'X', 's': 10, 'h': {'24': 5}})), isNull);
      expect(_parse(one({'n': 'A', 'c': 'X', 's': 10, 'h': {'-1': 5}})), isNull);
      expect(_parse(one({'n': 'A', 'c': 'X', 's': 10, 'h': {'3': 3601}})), isNull);
      expect(_parse(one({'n': 'A', 'c': 'X', 's': 10, 'h': {'x': 5}})), isNull);
    });

    test('empty, oversized or malformed app entries', () {
      Map<String, dynamic> one(Object app) => _valid(days: {'2026-03-18': [app]});
      expect(_parse(one({'n': '', 'c': 'X', 's': 1})), isNull);
      expect(_parse(one({'n': 'a' * 121, 'c': 'X', 's': 1})), isNull);
      expect(_parse(one({'n': 'A', 'c': 'X'})), isNull);
      expect(_parse(one('string')), isNull);
    });

    test('too many days or apps', () {
      final tooManyDays = {
        for (var i = 0; i < DeviceSnapshot.maxDays + 1; i++)
          DeviceSnapshot.dayKey(DateTime(2025, 1, 1).add(Duration(days: i))): <dynamic>[]
      };
      expect(_parse(_valid(days: tooManyDays)), isNull);

      final tooManyApps = {
        '2026-03-18': [
          for (var i = 0; i < DeviceSnapshot.maxAppsPerDay + 1; i++)
            {'n': 'app$i', 'c': 'X', 's': 1}
        ]
      };
      expect(_parse(_valid(days: tooManyApps)), isNull);
    });

    test('oversized text is refused before parsing', () {
      final big = 'x' * (DeviceSnapshot.maxBytes + 1);
      expect(DeviceSnapshot.parse(big), isNull);
    });

    test('long device names are clipped, not rejected', () {
      final snap = _parse({..._valid(), 'deviceName': 'n' * 500})!;
      expect(snap.deviceName.length, DeviceSnapshot.maxNameLength);
    });
  });
}
