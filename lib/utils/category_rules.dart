import 'package:flutter/foundation.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';

/// A user-defined rule that puts matching apps into a category.
class CategoryRule {
  final String id;
  final bool enabled;
  final String pattern;
  final String category;

  const CategoryRule({
    required this.id,
    required this.pattern,
    required this.category,
    this.enabled = true,
  });

  CategoryRule copyWith({bool? enabled, String? pattern, String? category}) =>
      CategoryRule(
        id: id,
        enabled: enabled ?? this.enabled,
        pattern: pattern ?? this.pattern,
        category: category ?? this.category,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'enabled': enabled,
        'pattern': pattern,
        'category': category,
      };

  static CategoryRule? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final pattern = raw['pattern'];
    final category = raw['category'];
    if (id is! String || pattern is! String || category is! String) return null;
    return CategoryRule(
      id: id,
      pattern: pattern,
      category: category,
      enabled: raw['enabled'] != false,
    );
  }
}

/// How much tracked time has no category, used to nudge the user to add rules.
class UncategorizedSummary {
  final Duration total;
  final Duration uncategorized;

  /// Uncategorized apps, largest first (appId, time).
  final List<MapEntry<String, Duration>> topApps;

  const UncategorizedSummary(this.total, this.uncategorized, this.topApps);

  double get share =>
      total.inSeconds == 0 ? 0 : uncategorized.inSeconds / total.inSeconds;
}

/// Ordered regex rules mapping apps to categories. The first enabled rule
/// whose pattern matches the app id or display name wins, and a rule beats the
/// built-in name list. Rules are applied when an app is first seen, or on
/// demand to apps already tracked.
class CategoryRules extends ChangeNotifier {
  CategoryRules({List<CategoryRule> Function()? source})
      : _source = source ?? _settingsSource;

  static final CategoryRules instance = CategoryRules();

  static const String settingKey = 'categoryRules';
  static const String uncategorized = 'Uncategorized';
  static const int maxPatternLength = 200;
  static const int maxInputLength = 256;

  /// Don't nag unless there is a meaningful amount of data to categorize.
  static const Duration hintMinTotal = Duration(hours: 1);
  static const double hintMinShare = 0.25;

  final List<CategoryRule> Function() _source;
  List<({CategoryRule rule, RegExp regex})>? _compiled;

  static List<CategoryRule> _settingsSource() {
    final raw = SettingsManager().getSetting(settingKey);
    if (raw is! List) return const [];
    return raw.map(CategoryRule.fromJson).whereType<CategoryRule>().toList();
  }

  List<CategoryRule> get rules => List.unmodifiable(_source());

  /// Call after the stored rule list changes.
  void refresh() {
    _compiled = null;
    notifyListeners();
  }

  /// Error code for an unusable [pattern], or null if it is fine.
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

  /// Mirrors the tracker's rule for what counts as productive by default.
  static bool isProductiveCategory(String category) =>
      !(category == 'Social Media' ||
          category == 'Entertainment' ||
          category == 'Gaming' ||
          category == uncategorized);

  List<({CategoryRule rule, RegExp regex})> _rules() => _compiled ??= [
        for (final r in _source())
          if (r.enabled &&
              r.category.trim().isNotEmpty &&
              validate(r.pattern) == null)
            (rule: r, regex: RegExp(r.pattern, caseSensitive: false)),
      ];

  static String _clip(String s) =>
      s.length > maxInputLength ? s.substring(0, maxInputLength) : s;

  /// The category from the first matching rule, or null if none match.
  String? categorize(String appId, String displayName) {
    final inputs = [appId, displayName].where((s) => s.isNotEmpty).map(_clip);
    for (final c in _rules()) {
      if (inputs.any(c.regex.hasMatch)) return c.rule.category.trim();
    }
    return null;
  }

  /// Re-categorizes apps that are already tracked. Returns how many changed.
  /// Rules the user wrote override the existing category, including one they
  /// set by hand, because applying is an explicit action.
  Future<int> applyToExistingApps(AppDataStore store) async {
    var changed = 0;
    for (final appId in store.allAppNames) {
      if (appId.startsWith('web:')) continue;
      final meta = store.getAppMetadata(appId);
      if (meta == null) continue;
      final category = categorize(
          appId, meta.displayName.isNotEmpty ? meta.displayName : appId);
      if (category == null || category == meta.category) continue;
      await store.updateAppMetadata(
        appId,
        category: category,
        isProductive: isProductiveCategory(category),
      );
      changed++;
    }
    return changed;
  }

  /// Time per category state over the last [days] days, native apps only.
  static UncategorizedSummary summarize(AppDataStore store, {int days = 7}) {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    final usage = store.getAllAppUsageForRange(start, end);
    var total = Duration.zero;
    var none = Duration.zero;
    final perApp = <String, Duration>{};
    usage.forEach((appId, records) {
      if (appId.startsWith('web:')) return;
      final spent = records.fold<Duration>(Duration.zero, (s, r) => s + r.timeSpent);
      if (spent == Duration.zero) return;
      total += spent;
      final category = store.getAppMetadata(appId)?.category ?? uncategorized;
      if (category == uncategorized) {
        none += spent;
        perApp[appId] = spent;
      }
    });
    final top = perApp.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return UncategorizedSummary(total, none, top.take(5).toList());
  }

  static bool shouldShowHint(UncategorizedSummary s) =>
      s.total >= hintMinTotal && s.share >= hintMinShare;
}
