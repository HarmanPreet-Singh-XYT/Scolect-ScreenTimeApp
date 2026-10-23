// test/unit/utils/category_rules_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:screentime/utils/category_rules.dart';

CategoryRules _rules(List<CategoryRule> r) => CategoryRules(source: () => r);

CategoryRule _r(String pattern, String category,
        {bool enabled = true, String? id}) =>
    CategoryRule(
        id: id ?? pattern, pattern: pattern, category: category, enabled: enabled);

void main() {
  group('categorize', () {
    test('no rules returns null so the built-in list is used', () {
      expect(_rules([]).categorize('com.x', 'X'), isNull);
    });

    test('matches the id or display name, case-insensitively', () {
      final rules = _rules([_r('figma', 'Creative')]);
      expect(rules.categorize('com.figma.Desktop', 'App'), 'Creative');
      expect(rules.categorize('com.x', 'FIGMA'), 'Creative');
      expect(rules.categorize('com.x', 'Notes'), isNull);
    });

    test('first matching rule wins', () {
      final rules = _rules([_r('code', 'Development'), _r('code|slack', 'Work')]);
      expect(rules.categorize('code', 'Code'), 'Development');
      expect(rules.categorize('slack', 'Slack'), 'Work');
    });

    test('disabled, invalid and category-less rules are skipped', () {
      final rules = _rules([
        _r('a', 'One', enabled: false),
        _r('(', 'Two'),
        _r('a', '  '),
        _r('a', 'Three'),
      ]);
      expect(rules.categorize('a', 'a'), 'Three');
    });

    test('category is trimmed', () {
      expect(_rules([_r('a', '  Study  ')]).categorize('a', 'a'), 'Study');
    });

    test('very long names are clipped before matching', () {
      final rules = _rules([_r('needle', 'X')]);
      expect(rules.categorize('id', '${'x' * 300}needle'), isNull);
    });
  });

  group('helpers', () {
    test('validate', () {
      expect(CategoryRules.validate('ok'), isNull);
      expect(CategoryRules.validate(' '), 'empty');
      expect(CategoryRules.validate('('), 'invalid');
      expect(CategoryRules.validate('a' * 201), 'too_long');
    });

    test('isProductiveCategory matches the tracker defaults', () {
      for (final c in ['Social Media', 'Entertainment', 'Gaming', 'Uncategorized']) {
        expect(CategoryRules.isProductiveCategory(c), isFalse, reason: c);
      }
      expect(CategoryRules.isProductiveCategory('Development'), isTrue);
      expect(CategoryRules.isProductiveCategory('My Custom'), isTrue);
    });

    test('hint only shows with enough data and a large uncategorized share', () {
      UncategorizedSummary s(int totalMin, int noneMin) => UncategorizedSummary(
          Duration(minutes: totalMin), Duration(minutes: noneMin), const []);
      expect(CategoryRules.shouldShowHint(s(120, 60)), isTrue);
      expect(CategoryRules.shouldShowHint(s(120, 10)), isFalse);
      expect(CategoryRules.shouldShowHint(s(30, 30)), isFalse);
      expect(s(0, 0).share, 0);
    });

    test('serialisation round trips and tolerates bad entries', () {
      final rule = _r('a', 'B', enabled: false);
      expect(CategoryRule.fromJson(rule.toJson())!.toJson(), rule.toJson());
      expect(CategoryRule.fromJson('x'), isNull);
      expect(CategoryRule.fromJson({'id': 'x', 'pattern': 'p'}), isNull);
    });
  });
}
