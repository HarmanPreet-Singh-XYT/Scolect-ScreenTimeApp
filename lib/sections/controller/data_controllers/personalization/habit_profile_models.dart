import 'dart:convert';
import 'package:screentime/l10n/app_localizations.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum WorkStyle { deepFocus, taskSwitcher, balanced }

enum Chronotype { morningPerson, afternoonPeak, nightOwl, unknown }

// ─── HabitProfile ─────────────────────────────────────────────────────────────

class HabitProfile {
  final Chronotype chronotype;
  final WorkStyle workStyle;
  final String? mostCommonDistractionApp;
  final Duration avgFocusSessionLength;
  final int bestDayOfWeek; // 1=Mon … 7=Sun
  final int worstDayOfWeek;
  final Duration avgDailyScreenTime;
  final double avgProductivityScore;
  final int daysAnalyzed;
  final DateTime computedAt;
  final int peakFocusStartHour; // 0–23
  final int peakFocusEndHour;

  const HabitProfile({
    required this.chronotype,
    required this.workStyle,
    this.mostCommonDistractionApp,
    required this.avgFocusSessionLength,
    required this.bestDayOfWeek,
    required this.worstDayOfWeek,
    required this.avgDailyScreenTime,
    required this.avgProductivityScore,
    required this.daysAnalyzed,
    required this.computedAt,
    required this.peakFocusStartHour,
    required this.peakFocusEndHour,
  });

  String getChronotypeLabel(AppLocalizations l10n) {
    switch (chronotype) {
      case Chronotype.morningPerson:
        return l10n.chronotypeMorning;
      case Chronotype.afternoonPeak:
        return l10n.chronotypeAfternoon;
      case Chronotype.nightOwl:
        return l10n.chronotypeNight;
      case Chronotype.unknown:
        return l10n.chronotypeMixed;
    }
  }

  String getWorkStyleLabel(AppLocalizations l10n) {
    switch (workStyle) {
      case WorkStyle.deepFocus:
        return l10n.workStyleDeep;
      case WorkStyle.taskSwitcher:
        return l10n.workStyleSwitcher;
      case WorkStyle.balanced:
        return l10n.workStyleBalanced;
    }
  }

  String getPeakFocusWindow(AppLocalizations l10n) {
    String fmt(int h) {
      final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      if (h == 0) return l10n.timeFormatMidnight;
      if (h == 12) return l10n.timeFormatNoon;
      return h < 12 ? l10n.timeFormatAm(hour) : l10n.timeFormatPm(hour);
    }

    return '${fmt(peakFocusStartHour)} – ${fmt(peakFocusEndHour)}';
  }

  String getBestDayLabel(AppLocalizations l10n) => _weekdayName(bestDayOfWeek, l10n);
  String getWorstDayLabel(AppLocalizations l10n) => _weekdayName(worstDayOfWeek, l10n);

  static String _weekdayName(int day, AppLocalizations l10n) {
    switch (day) {
      case 1: return l10n.weekdayNameMonday;
      case 2: return l10n.weekdayNameTuesday;
      case 3: return l10n.weekdayNameWednesday;
      case 4: return l10n.weekdayNameThursday;
      case 5: return l10n.weekdayNameFriday;
      case 6: return l10n.weekdayNameSaturday;
      case 7: return l10n.weekdayNameSunday;
      default: return '—';
    }
  }

  Map<String, dynamic> toJson() => {
        'chronotype': chronotype.name,
        'workStyle': workStyle.name,
        'mostCommonDistractionApp': mostCommonDistractionApp,
        'avgFocusSessionLengthMs': avgFocusSessionLength.inMilliseconds,
        'bestDayOfWeek': bestDayOfWeek,
        'worstDayOfWeek': worstDayOfWeek,
        'avgDailyScreenTimeMs': avgDailyScreenTime.inMilliseconds,
        'avgProductivityScore': avgProductivityScore,
        'daysAnalyzed': daysAnalyzed,
        'computedAt': computedAt.toIso8601String(),
        'peakFocusStartHour': peakFocusStartHour,
        'peakFocusEndHour': peakFocusEndHour,
      };

  factory HabitProfile.fromJson(Map<String, dynamic> json) => HabitProfile(
        chronotype: Chronotype.values.byName(json['chronotype'] as String),
        workStyle: WorkStyle.values.byName(json['workStyle'] as String),
        mostCommonDistractionApp:
            json['mostCommonDistractionApp'] as String?,
        avgFocusSessionLength: Duration(
            milliseconds: json['avgFocusSessionLengthMs'] as int? ?? 0),
        bestDayOfWeek: json['bestDayOfWeek'] as int? ?? 1,
        worstDayOfWeek: json['worstDayOfWeek'] as int? ?? 7,
        avgDailyScreenTime: Duration(
            milliseconds: json['avgDailyScreenTimeMs'] as int? ?? 0),
        avgProductivityScore:
            (json['avgProductivityScore'] as num?)?.toDouble() ?? 0.0,
        daysAnalyzed: json['daysAnalyzed'] as int? ?? 0,
        computedAt: DateTime.parse(json['computedAt'] as String),
        peakFocusStartHour: json['peakFocusStartHour'] as int? ?? 9,
        peakFocusEndHour: json['peakFocusEndHour'] as int? ?? 11,
      );

  static HabitProfile? tryFromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return HabitProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  String toJsonString() => jsonEncode(toJson());
}
