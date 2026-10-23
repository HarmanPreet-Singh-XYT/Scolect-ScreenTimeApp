import 'package:flutter/foundation.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';

/// What a rule matches against.
enum FilterTarget { app, website, both }

/// What happens to a match.
enum FilterAction {
  /// Never record it.
  exclude,

  /// Record it under [PrivacyFilterRule.replacement] instead of its real name.
  redact,
}

class PrivacyFilterRule {
  final String id;
  final bool enabled;
  final String pattern;
  final FilterTarget target;
  final FilterAction action;
  final String replacement;

  const PrivacyFilterRule({
    required this.id,
    required this.pattern,
    this.enabled = true,
    this.target = FilterTarget.both,
    this.action = FilterAction.exclude,
    this.replacement = '',
  });

  PrivacyFilterRule copyWith({
    bool? enabled,
    String? pattern,
    FilterTarget? target,
    FilterAction? action,
    String? replacement,
  }) =>
      PrivacyFilterRule(
        id: id,
        enabled: enabled ?? this.enabled,
        pattern: pattern ?? this.pattern,
        target: target ?? this.target,
        action: action ?? this.action,
        replacement: replacement ?? this.replacement,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'enabled': enabled,
        'pattern': pattern,
        'target': target.name,
        'action': action.name,
        'replacement': replacement,
      };

  static PrivacyFilterRule? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final pattern = raw['pattern'];
    final id = raw['id'];
    if (pattern is! String || id is! String) return null;
    return PrivacyFilterRule(
      id: id,
      pattern: pattern,
      enabled: raw['enabled'] != false,
      target: FilterTarget.values.firstWhere((t) => t.name == raw['target'],
          orElse: () => FilterTarget.both),
      action: FilterAction.values.firstWhere((a) => a.name == raw['action'],
          orElse: () => FilterAction.exclude),
      replacement: raw['replacement'] as String? ?? '',
    );
  }
}

/// Result of running a name through the filters.
class FilterResult {
  /// True when the item must not be recorded at all.
  final bool excluded;

  /// The (possibly redacted) name to record under.
  final String name;

  const FilterResult.excluded()
      : excluded = true,
        name = '';
  const FilterResult.keep(this.name) : excluded = false;
}

/// User-defined regex rules that keep chosen apps and websites out of the
/// tracked data. Rules apply as data is recorded; history already stored is
/// not rewritten.
class PrivacyFilters extends ChangeNotifier {
  PrivacyFilters({List<PrivacyFilterRule> Function()? source})
      : _source = source ?? _settingsSource;

  static final PrivacyFilters instance = PrivacyFilters();

  static const String settingKey = 'privacyFilters';
  static const String defaultReplacement = 'Redacted';

  /// Regex input is capped so a pathological pattern can't stall tracking on
  /// a very long window title.
  static const int maxPatternLength = 200;
  static const int maxInputLength = 256;

  final List<PrivacyFilterRule> Function() _source;
  List<_Compiled>? _compiled;

  static List<PrivacyFilterRule> _settingsSource() {
    final raw = SettingsManager().getSetting(settingKey);
    if (raw is! List) return const [];
    return raw.map(PrivacyFilterRule.fromJson).whereType<PrivacyFilterRule>().toList();
  }

  List<PrivacyFilterRule> get rules => List.unmodifiable(_source());

  /// Call after the underlying rule list changes.
  void refresh() {
    _compiled = null;
    notifyListeners();
  }

  /// Returns an error message if [pattern] can't be used, otherwise null.
  static String? validate(String pattern) {
    if (pattern.trim().isEmpty) return 'empty';
    if (pattern.length > maxPatternLength) return 'too_long';
    try {
      RegExp(pattern, caseSensitive: false);
    } on FormatException {
      return 'invalid';
    }
    return null;
  }

  List<_Compiled> _rules() {
    return _compiled ??= [
      for (final r in _source())
        if (r.enabled && validate(r.pattern) == null)
          _Compiled(r, RegExp(r.pattern, caseSensitive: false)),
    ];
  }

  static String _clip(String s) =>
      s.length > maxInputLength ? s.substring(0, maxInputLength) : s;

  FilterResult _apply(
      bool Function(FilterTarget) targets, List<String> candidates, String name) {
    final inputs = candidates.where((c) => c.isNotEmpty).map(_clip).toList();
    PrivacyFilterRule? redact;
    for (final c in _rules()) {
      if (!targets(c.rule.target)) continue;
      if (!inputs.any(c.regex.hasMatch)) continue;
      if (c.rule.action == FilterAction.exclude) return const FilterResult.excluded();
      redact ??= c.rule;
    }
    if (redact != null) {
      final r = redact.replacement.trim();
      return FilterResult.keep(r.isEmpty ? defaultReplacement : r);
    }
    return FilterResult.keep(name);
  }

  /// Filters a native app. Rules match against both the app id and its
  /// display name. A redacted app is recorded under the replacement for both.
  FilterResult applyToApp(String appId, String displayName) => _apply(
        (t) => t != FilterTarget.website,
        [appId, displayName],
        appId,
      );

  /// Filters a window title. Excluded titles must not be stored (the time
  /// still counts towards the app); redacted ones are stored under the
  /// replacement.
  FilterResult applyToTitle(String title) => _apply(
        (t) => t != FilterTarget.website,
        [title],
        title,
      );

  /// Filters a website domain.
  FilterResult applyToDomain(String domain) => _apply(
        (t) => t != FilterTarget.app,
        [domain],
        domain,
      );

  /// Applies the website rules to a batch of per-domain usage entries as sent
  /// by the extension. Excluded domains are dropped; redacted domains are
  /// merged under their replacement, summing seconds and visits (the
  /// extension reports cumulative daily totals for every domain in each
  /// batch, so the sum is the redacted total).
  List<Map<String, dynamic>> filterDomainEntries(List<dynamic> entries) {
    if (_rules().isEmpty) {
      return entries.whereType<Map<String, dynamic>>().toList();
    }
    final out = <Map<String, dynamic>>[];
    final merged = <String, Map<String, dynamic>>{};
    for (final raw in entries) {
      if (raw is! Map<String, dynamic>) continue;
      final domain = raw['domain'];
      if (domain is! String || domain.isEmpty) {
        out.add(raw);
        continue;
      }
      final result = applyToDomain(domain);
      if (result.excluded) continue;
      if (result.name == domain) {
        out.add(raw);
        continue;
      }
      final existing = merged[result.name];
      if (existing == null) {
        merged[result.name] = {
          ...raw,
          'domain': result.name,
          'siteName': result.name,
        };
      } else {
        existing['seconds'] = _num(existing['seconds']) + _num(raw['seconds']);
        existing['visits'] = _num(existing['visits']) + _num(raw['visits']);
      }
    }
    return [...out, ...merged.values];
  }

  static int _num(Object? v) => v is num ? v.toInt() : 0;
}

class _Compiled {
  final PrivacyFilterRule rule;
  final RegExp regex;
  const _Compiled(this.rule, this.regex);
}
