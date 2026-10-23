import 'package:flutter/foundation.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';

/// A daily time cap for a whole category of apps.
class CategoryLimit {
  final String id;
  final String category;
  final int minutes;
  final bool enabled;

  const CategoryLimit({
    required this.id,
    required this.category,
    required this.minutes,
    this.enabled = true,
  });

  Duration get limit => Duration(minutes: minutes);

  CategoryLimit copyWith({String? category, int? minutes, bool? enabled}) =>
      CategoryLimit(
        id: id,
        category: category ?? this.category,
        minutes: minutes ?? this.minutes,
        enabled: enabled ?? this.enabled,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'minutes': minutes,
        'enabled': enabled,
      };

  static CategoryLimit? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'], category = raw['category'], minutes = raw['minutes'];
    if (id is! String || category is! String || minutes is! num) return null;
    return CategoryLimit(
      id: id,
      category: category,
      minutes: minutes.toInt(),
      enabled: raw['enabled'] != false,
    );
  }
}

enum LimitState { under, approaching, reached }

class CategoryLimitStatus {
  final CategoryLimit limit;
  final Duration used;
  final LimitState state;
  const CategoryLimitStatus(this.limit, this.used, this.state);
}

/// Daily per-category limits that raise alerts (they never block apps).
class CategoryLimits extends ChangeNotifier {
  CategoryLimits({List<CategoryLimit> Function()? source})
      : _source = source ?? _settingsSource;

  static final CategoryLimits instance = CategoryLimits();

  static const String settingKey = 'categoryLimits';
  static const double approachingThreshold = 0.9;
  static const int maxMinutes = 24 * 60;

  final List<CategoryLimit> Function() _source;

  static List<CategoryLimit> _settingsSource() {
    final raw = SettingsManager().getSetting(settingKey);
    if (raw is! List) return const [];
    return raw.map(CategoryLimit.fromJson).whereType<CategoryLimit>().toList();
  }

  List<CategoryLimit> get limits => List.unmodifiable(_source());

  bool get hasActiveLimits =>
      _source().any((l) => l.enabled && l.minutes > 0 && l.category.trim().isNotEmpty);

  /// Call after the stored limits change.
  void refresh() => notifyListeners();

  static String _norm(String c) => c.trim().toLowerCase();

  /// Time today per category (lower-cased key), native apps only.
  static Map<String, Duration> usageByCategory(AppDataStore store, DateTime day) {
    final usage = <String, Duration>{};
    for (final appId in store.allAppNames) {
      if (appId.startsWith('web:')) continue;
      final spent = store.getAppUsage(appId, day)?.timeSpent ?? Duration.zero;
      if (spent == Duration.zero) continue;
      final category = store.getAppMetadata(appId)?.category ?? 'Uncategorized';
      final key = _norm(category);
      usage[key] = (usage[key] ?? Duration.zero) + spent;
    }
    return usage;
  }

  /// Status of every active limit given `usage` (keys from [usageByCategory]).
  List<CategoryLimitStatus> evaluate(Map<String, Duration> usage) {
    final result = <CategoryLimitStatus>[];
    for (final l in _source()) {
      if (!l.enabled || l.minutes <= 0 || l.category.trim().isEmpty) continue;
      final used = usage[_norm(l.category)] ?? Duration.zero;
      final state = used >= l.limit
          ? LimitState.reached
          : (used.inSeconds >= l.limit.inSeconds * approachingThreshold
              ? LimitState.approaching
              : LimitState.under);
      result.add(CategoryLimitStatus(l, used, state));
    }
    return result;
  }
}
