import 'package:fluent_ui/fluent_ui.dart';

Widget buildStatCard(BuildContext context, String label, String value,
    IconData icon, Color color, FluentThemeData theme) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 8),
        Text(value,
            style: theme.typography.subtitle
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.typography.caption
              ?.copyWith(color: theme.inactiveColor, fontSize: 11),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

Widget buildCompactCard(
    BuildContext context, String title, IconData icon, FluentThemeData theme,
    {required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: theme.resources.dividerStrokeColorDefault),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: theme.accentColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: theme.typography.bodyStrong?.copyWith(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

Widget buildInfoRow(String label, String value, FluentThemeData theme,
    {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.typography.body?.copyWith(color: theme.inactiveColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: theme.typography.body
              ?.copyWith(fontWeight: FontWeight.w600, color: valueColor),
        ),
      ],
    ),
  );
}

String formatDuration(Duration duration) {
  final h = duration.inHours;
  final m = duration.inMinutes.remainder(60);
  return h > 0 ? '${h}h ${m}m' : '${m}m';
}

String formatMinutesShort(double minutes) {
  if (minutes >= 60) {
    final h = (minutes / 60).floor();
    final m = (minutes % 60).round();
    return m == 0 ? '${h}h' : '${h}h${m}m';
  }
  return '${minutes.round()}m';
}

String formatMinutesLong(double minutes) {
  final h = (minutes / 60).floor();
  final m = (minutes % 60).round();
  return h > 0 ? '${h}h ${m}m' : '${m}m';
}
