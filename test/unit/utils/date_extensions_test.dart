import 'package:flutter_test/flutter_test.dart';
import 'package:screentime/utils/date_extensions.dart';

void main() {
  test('addDays keeps midnight across DST changes (any timezone)', () {
    final base = DateTime(2026, 1, 1);
    for (var n = -400; n <= 400; n++) {
      final d = base.addDays(n);
      expect(d.hour, 0, reason: 'offset $n landed at ${d.hour}:00');
      expect(DateTime(2026, 1, 1 + n), d);
    }
  });

  test('addDays keeps the time of day', () {
    expect(DateTime(2026, 3, 1, 15, 30).addDays(40), DateTime(2026, 4, 10, 15, 30));
  });

  test('addDays works on UTC dates', () {
    final d = DateTime.utc(2026, 1, 31, 8).addDays(1);
    expect(d, DateTime.utc(2026, 2, 1, 8));
    expect(d.isUtc, isTrue);
  });
}
