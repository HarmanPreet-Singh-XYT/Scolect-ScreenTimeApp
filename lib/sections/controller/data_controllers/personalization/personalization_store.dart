import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit_profile_models.dart';

// ─── PersonalizationStore ─────────────────────────────────────────────────────
// Singleton. Persists dismissed insight IDs and HabitProfile to SharedPreferences.
// Must call init() once at app startup, after SettingsManager().init().

class PersonalizationStore {
  static final PersonalizationStore _instance =
      PersonalizationStore._internal();
  factory PersonalizationStore() => _instance;
  PersonalizationStore._internal();

  static const String _dismissedKey = 'personalization_dismissed_insights';
  static const String _profileKey = 'personalization_habit_profile';
  static const String _lastComputedKey = 'personalization_last_computed';

  late SharedPreferences _prefs;
  bool _initialized = false;

  Set<String> _dismissedIds = {};
  HabitProfile? _cachedProfile;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _loadDismissed();
    _cachedProfile =
        HabitProfile.tryFromJsonString(_prefs.getString(_profileKey));
    _initialized = true;
  }

  void _loadDismissed() {
    final list = _prefs.getStringList(_dismissedKey) ?? [];
    _dismissedIds = list.toSet();
  }

  // ── Dismissed insights ─────────────────────────────────────────────────────

  bool isInsightDismissed(String id) => _dismissedIds.contains(id);

  Future<void> dismissInsight(String id) async {
    _dismissedIds.add(id);
    await _prefs.setStringList(_dismissedKey, _dismissedIds.toList());
  }

  // ── HabitProfile ───────────────────────────────────────────────────────────

  HabitProfile? get cachedProfile => _cachedProfile;

  Future<void> saveProfile(HabitProfile profile) async {
    _cachedProfile = profile;
    await _prefs.setString(_profileKey, profile.toJsonString());
    await _prefs.setString(
        _lastComputedKey, DateTime.now().toIso8601String());
  }

  DateTime? get lastComputedAt {
    final s = _prefs.getString(_lastComputedKey);
    return s != null ? DateTime.tryParse(s) : null;
  }

  bool get needsRecompute {
    final last = lastComputedAt;
    if (last == null) return true;
    return DateTime.now().difference(last).inHours >= 24;
  }

  // ── First-ever tracking date ────────────────────────────────────────────────
  // Stored once; used by WeeklyStory to compute ordinal week number.

  static const String _firstDateKey = 'personalization_first_date';

  Future<void> setFirstDateIfAbsent(DateTime date) async {
    if (_prefs.getString(_firstDateKey) == null) {
      await _prefs.setString(_firstDateKey, date.toIso8601String());
    }
  }

  DateTime? get firstTrackingDate {
    final s = _prefs.getString(_firstDateKey);
    return s != null ? DateTime.tryParse(s) : null;
  }
}
