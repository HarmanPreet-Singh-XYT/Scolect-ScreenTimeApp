// test/unit/utils/privacy_filters_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:screentime/utils/privacy_filters.dart';

PrivacyFilters _filters(List<PrivacyFilterRule> rules) =>
    PrivacyFilters(source: () => rules);

PrivacyFilterRule _rule(
  String pattern, {
  FilterTarget target = FilterTarget.both,
  FilterAction action = FilterAction.exclude,
  String replacement = '',
  bool enabled = true,
}) =>
    PrivacyFilterRule(
      id: pattern,
      pattern: pattern,
      target: target,
      action: action,
      replacement: replacement,
      enabled: enabled,
    );

void main() {
  group('apps', () {
    test('no rules keeps the name', () {
      final r = _filters([]).applyToApp('com.x', 'X');
      expect(r.excluded, isFalse);
      expect(r.name, 'com.x');
    });

    test('exclude matches the id or the display name, case-insensitively', () {
      final f = _filters([_rule('bank')]);
      expect(f.applyToApp('com.mybank.app', 'App').excluded, isTrue);
      expect(f.applyToApp('com.x', 'My BANK').excluded, isTrue);
      expect(f.applyToApp('com.x', 'Notes').excluded, isFalse);
    });

    test('redact swaps the name; empty replacement uses the default', () {
      expect(
          _filters([_rule('bank', action: FilterAction.redact, replacement: 'Finance')])
              .applyToApp('com.mybank', 'Bank')
              .name,
          'Finance');
      expect(
          _filters([_rule('bank', action: FilterAction.redact)])
              .applyToApp('com.mybank', 'Bank')
              .name,
          PrivacyFilters.defaultReplacement);
    });

    test('exclude wins over redact regardless of order', () {
      final f = _filters([
        _rule('bank', action: FilterAction.redact, replacement: 'Finance'),
        _rule('mybank'),
      ]);
      expect(f.applyToApp('com.mybank', 'Bank').excluded, isTrue);
    });

    test('website-only rules do not touch apps', () {
      final f = _filters([_rule('bank', target: FilterTarget.website)]);
      expect(f.applyToApp('com.mybank', 'Bank').excluded, isFalse);
    });

    test('disabled and invalid rules are ignored', () {
      final f = _filters([_rule('bank', enabled: false), _rule('(')]);
      expect(f.applyToApp('com.mybank', 'Bank').excluded, isFalse);
    });
  });

  group('domains', () {
    test('exclude and target handling', () {
      final f = _filters([_rule(r'(^|\.)bank\.com$', target: FilterTarget.website)]);
      expect(f.applyToDomain('www.bank.com').excluded, isTrue);
      expect(f.applyToDomain('notbank.com').excluded, isFalse);
      expect(_filters([_rule('bank', target: FilterTarget.app)])
          .applyToDomain('bank.com')
          .excluded, isFalse);
    });

    test('filterDomainEntries drops excluded and merges redacted entries', () {
      final f = _filters([
        _rule('secret', action: FilterAction.exclude),
        _rule(r'\.bank\.com$', action: FilterAction.redact, replacement: 'Banking'),
      ]);
      final out = f.filterDomainEntries([
        {'domain': 'a.secret.io', 'seconds': 100, 'visits': 1},
        {'domain': 'login.bank.com', 'seconds': 60, 'visits': 2},
        {'domain': 'pay.bank.com', 'seconds': 40, 'visits': 3},
        {'domain': 'example.com', 'seconds': 10, 'visits': 1},
      ]);

      expect(out.map((e) => e['domain']), unorderedEquals(['example.com', 'Banking']));
      final banking = out.firstWhere((e) => e['domain'] == 'Banking');
      expect(banking['seconds'], 100);
      expect(banking['visits'], 5);
      expect(banking['siteName'], 'Banking');
    });

    test('without rules the entries pass through untouched', () {
      final entries = [
        {'domain': 'a.com', 'seconds': 1, 'visits': 1}
      ];
      expect(_filters([]).filterDomainEntries(entries), entries);
    });
  });

  group('titles', () {
    test('exclude drops the title, redact replaces it, others pass through', () {
      final f = _filters([
        _rule('chase', action: FilterAction.exclude),
        _rule('salary', action: FilterAction.redact, replacement: 'Private doc'),
      ]);
      expect(f.applyToTitle('Chase - Accounts').excluded, isTrue);
      expect(f.applyToTitle('Salary 2026.xlsx').name, 'Private doc');
      expect(f.applyToTitle('Notes').name, 'Notes');
    });

    test('website-only rules do not apply to titles', () {
      final f = _filters([_rule('chase', target: FilterTarget.website)]);
      expect(f.applyToTitle('Chase - Accounts').excluded, isFalse);
    });
  });

  group('validation and limits', () {
    test('validate rejects empty, oversized and malformed patterns', () {
      expect(PrivacyFilters.validate('ok.*'), isNull);
      expect(PrivacyFilters.validate('  '), 'empty');
      expect(PrivacyFilters.validate('('), 'invalid');
      expect(PrivacyFilters.validate('a' * 201), 'too_long');
    });

    test('very long input is clipped before matching', () {
      final f = _filters([_rule('needle')]);
      final title = '${'x' * 300}needle';
      expect(f.applyToApp('id', title).excluded, isFalse);
    });
  });

  group('serialisation', () {
    test('round trips and tolerates bad entries', () {
      final rule = _rule('a', target: FilterTarget.app, action: FilterAction.redact, replacement: 'R');
      final back = PrivacyFilterRule.fromJson(rule.toJson())!;
      expect(back.toJson(), rule.toJson());
      expect(PrivacyFilterRule.fromJson('nope'), isNull);
      expect(PrivacyFilterRule.fromJson({'pattern': 1}), isNull);
      expect(PrivacyFilterRule.fromJson({'id': 'x', 'pattern': 'p', 'target': 'zzz'})!.target,
          FilterTarget.both);
    });
  });
}
