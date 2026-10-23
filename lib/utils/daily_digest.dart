import 'package:screentime/sections/controller/app_data_controller.dart';

class DigestApp {
  final String name;
  final Duration time;
  const DigestApp(this.name, this.time);
}

/// End-of-day summary shown as a notification.
class DailyDigest {
  final DateTime day;
  final Duration total;
  final Duration? previousTotal;
  final List<DigestApp> topApps;

  const DailyDigest(this.day, this.total, this.previousTotal, this.topApps);

  bool get isEmpty => total == Duration.zero;

  /// Whether the digest for [logicalDay] is due: enabled, the configured hour
  /// has passed, and it hasn't been sent for that day yet.
  static bool isDue({
    required bool enabled,
    required int hour,
    required DateTime now,
    required DateTime logicalDay,
    required String lastSent,
  }) {
    if (!enabled) return false;
    if (now.hour < hour.clamp(0, 23)) return false;
    return lastSent != dayKey(logicalDay);
  }

  static String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String formatDuration(Duration d) {
    final h = d.inHours, m = d.inMinutes % 60;
    if (h > 0) return m > 0 ? '${h}h ${m}m' : '${h}h';
    if (m > 0) return '${m}m';
    return '${d.inSeconds % 60}s';
  }

  String get title => 'Your day: ${formatDuration(total)} on screen';

  String get body {
    final parts = <String>[];
    final prev = previousTotal;
    if (prev != null && prev > Duration.zero) {
      final delta = total - prev;
      if (delta.abs() >= const Duration(minutes: 1)) {
        parts.add(
            '${delta.isNegative ? '−' : '+'}${formatDuration(delta.abs())} vs yesterday.');
      } else {
        parts.add('About the same as yesterday.');
      }
    }
    if (topApps.isNotEmpty) {
      parts.add('Top: ${topApps.map((a) => '${a.name} ${formatDuration(a.time)}').join(', ')}.');
    }
    return parts.join(' ');
  }

  /// Builds the digest for [day]. Private apps and websites are always left
  /// out: a notification can be read by anyone looking at the screen.
  static DailyDigest build(AppDataStore store, DateTime day, {int topCount = 3}) {
    Duration total(DateTime d, [Map<String, Duration>? perApp]) {
      var sum = Duration.zero;
      for (final appId in store.allAppNames) {
        if (appId.startsWith('web:')) continue;
        if (store.getAppMetadata(appId)?.isPrivate ?? false) continue;
        final spent = store.getAppUsage(appId, d)?.timeSpent ?? Duration.zero;
        if (spent == Duration.zero) continue;
        sum += spent;
        perApp?[appId] = spent;
      }
      return sum;
    }

    final perApp = <String, Duration>{};
    final today = total(day, perApp);
    final yesterday = total(day.subtract(const Duration(days: 1)));
    final top = perApp.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return DailyDigest(
      day,
      today,
      yesterday,
      [for (final e in top.take(topCount)) DigestApp(store.displayNameFor(e.key), e.value)],
    );
  }
}
