// test/unit/utils/category_limits_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:screentime/utils/category_limits.dart';
import 'package:screentime/utils/daily_digest.dart';

CategoryLimits _limits(List<CategoryLimit> l) => CategoryLimits(source: () => l);

CategoryLimit _l(String category, int minutes, {bool enabled = true, String? id}) =>
    CategoryLimit(id: id ?? category, category: category, minutes: minutes, enabled: enabled);

void main() {
  group('evaluate', () {
    test('under, approaching (90%) and reached', () {
      final limits = _limits([_l('Social Media', 100)]);
      LimitState at(int minutes) => limits
          .evaluate({'social media': Duration(minutes: minutes)})
          .single
          .state;

      expect(at(0), LimitState.under);
      expect(at(89), LimitState.under);
      expect(at(90), LimitState.approaching);
      expect(at(99), LimitState.approaching);
      expect(at(100), LimitState.reached);
      expect(at(500), LimitState.reached);
    });

    test('category matching ignores case and surrounding spaces', () {
      final s = _limits([_l('  Gaming ', 10)]).evaluate({'gaming': const Duration(minutes: 10)});
      expect(s.single.state, LimitState.reached);
      expect(s.single.used, const Duration(minutes: 10));
    });

    test('disabled, zero-minute and blank limits are skipped', () {
      final s = _limits([
        _l('A', 10, enabled: false),
        _l('B', 0),
        _l('  ', 10),
        _l('C', 10),
      ]).evaluate({'a': const Duration(hours: 5), 'c': const Duration(minutes: 1)});
      expect(s.map((e) => e.limit.category), ['C']);
    });

    test('a category with no usage is simply under its limit', () {
      expect(_limits([_l('Gaming', 30)]).evaluate({}).single.state, LimitState.under);
    });

    test('hasActiveLimits', () {
      expect(_limits([]).hasActiveLimits, isFalse);
      expect(_limits([_l('A', 10, enabled: false)]).hasActiveLimits, isFalse);
      expect(_limits([_l('A', 10)]).hasActiveLimits, isTrue);
    });

    test('serialisation round trips and tolerates bad entries', () {
      final l = _l('A', 15, enabled: false);
      expect(CategoryLimit.fromJson(l.toJson())!.toJson(), l.toJson());
      expect(CategoryLimit.fromJson('x'), isNull);
      expect(CategoryLimit.fromJson({'id': 'x', 'category': 'A'}), isNull);
    });
  });

  group('daily digest', () {
    test('isDue only after the hour, once per day, when enabled', () {
      bool due({bool enabled = true, int hour = 21, int nowHour = 22, String last = ''}) =>
          DailyDigest.isDue(
            enabled: enabled,
            hour: hour,
            now: DateTime(2026, 3, 18, nowHour, 5),
            logicalDay: DateTime(2026, 3, 18),
            lastSent: last,
          );
      expect(due(), isTrue);
      expect(due(nowHour: 21), isTrue);
      expect(due(nowHour: 20), isFalse);
      expect(due(enabled: false), isFalse);
      expect(due(last: '2026-03-18'), isFalse);
      expect(due(last: '2026-03-17'), isTrue);
      expect(due(hour: 99, nowHour: 23), isTrue); // out-of-range hour is clamped
    });

    test('body compares with yesterday and lists the top apps', () {
      final d = DailyDigest(
        DateTime(2026, 3, 18),
        const Duration(hours: 5, minutes: 20),
        const Duration(hours: 4, minutes: 35),
        const [
          DigestApp('Code', Duration(hours: 2, minutes: 10)),
          DigestApp('Chrome', Duration(hours: 1)),
        ],
      );
      expect(d.title, 'Your day: 5h 20m on screen');
      expect(d.body, '+45m vs yesterday. Top: Code 2h 10m, Chrome 1h.');
    });

    test('body handles lower, equal and missing previous totals', () {
      String body(Duration total, Duration? prev) =>
          DailyDigest(DateTime(2026, 3, 18), total, prev, const []).body;
      expect(body(const Duration(hours: 1), const Duration(hours: 2)), '−1h vs yesterday.');
      expect(body(const Duration(hours: 1), const Duration(hours: 1)), 'About the same as yesterday.');
      expect(body(const Duration(hours: 1), Duration.zero), '');
      expect(body(const Duration(hours: 1), null), '');
    });
  });
}
