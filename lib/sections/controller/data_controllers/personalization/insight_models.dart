import 'dart:convert';

// ─── Insight Types ────────────────────────────────────────────────────────────

enum InsightType {
  weekdayPattern,
  appSequence,
  timeOfDayFocus,
  postHeavyUsage,
  streak,
}

enum InsightSeverity { positive, neutral, warning }

// ─── Insight ─────────────────────────────────────────────────────────────────

class Insight {
  final String id;
  final String title;
  final String body;
  final InsightType type;
  final InsightSeverity severity;
  final DateTime generatedAt;

  const Insight({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.severity,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'severity': severity.name,
        'generatedAt': generatedAt.toIso8601String(),
      };

  factory Insight.fromJson(Map<String, dynamic> json) => Insight(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        type: InsightType.values.byName(json['type'] as String),
        severity: InsightSeverity.values.byName(json['severity'] as String),
        generatedAt: DateTime.parse(json['generatedAt'] as String),
      );

  static List<Insight> listFromJson(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Insight.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<Insight> insights) =>
      jsonEncode(insights.map((i) => i.toJson()).toList());
}

// ─── Daily Narrative ─────────────────────────────────────────────────────────

class DailyNarrative {
  final String headline;
  final String? detail;
  final String? appNote;
  final String tone;

  const DailyNarrative({
    required this.headline,
    this.detail,
    this.appNote,
    required this.tone,
  });
}

// ─── Weekly Story ─────────────────────────────────────────────────────────────

class WeeklyStory {
  final int weekNumber;
  final String headline;
  final String? progressNote;
  final String? improvementArea;

  const WeeklyStory({
    required this.weekNumber,
    required this.headline,
    this.progressNote,
    this.improvementArea,
  });
}
