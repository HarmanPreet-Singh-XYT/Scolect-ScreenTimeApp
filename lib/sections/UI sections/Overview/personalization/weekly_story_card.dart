import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import '../../../controller/data_controllers/personalization/insight_models.dart';

class WeeklyStoryCard extends StatelessWidget {
  final WeeklyStory story;

  const WeeklyStoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final accent = theme.accentColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.resources.cardStrokeColorDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(FluentIcons.calendar_week, size: 14, color: accent),
              const SizedBox(width: 6),
              Text(
                l10n.weeklyStoryTitle,
                style: theme.typography.body?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l10n.weeklyStoryWeekNumber(story.weekNumber),
                  style: theme.typography.caption?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Headline
          Text(
            story.headline,
            style: theme.typography.body?.copyWith(
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          // Progress note
          if (story.progressNote != null) ...[
            const SizedBox(height: 8),
            _NoteRow(
              icon: FluentIcons.trending12,
              text: story.progressNote!,
              color: const Color(0xff22C55E),
              theme: theme,
            ),
          ],
          // Improvement area
          if (story.improvementArea != null) ...[
            const SizedBox(height: 6),
            _NoteRow(
              icon: FluentIcons.lightbulb,
              text: story.improvementArea!,
              color: Colors.warningPrimaryColor,
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final FluentThemeData theme;

  const _NoteRow({
    required this.icon,
    required this.text,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 12, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.typography.caption?.copyWith(
              color: theme.inactiveColor,
              fontSize: 11.5,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
