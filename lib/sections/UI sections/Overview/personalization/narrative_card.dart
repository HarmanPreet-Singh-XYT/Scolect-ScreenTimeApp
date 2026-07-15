import 'package:fluent_ui/fluent_ui.dart';
import '../../../controller/data_controllers/personalization/insight_models.dart';

class NarrativeCard extends StatelessWidget {
  final DailyNarrative narrative;

  const NarrativeCard({super.key, required this.narrative});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final accent = theme.accentColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.resources.cardStrokeColorDefault,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left accent line
          Container(
            width: 3,
            height: 48,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Headline + tone badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        narrative.headline,
                        style: theme.typography.body?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ToneBadge(tone: narrative.tone, accent: accent),
                  ],
                ),
                // Detail line
                if (narrative.detail != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    narrative.detail!,
                    style: theme.typography.body?.copyWith(
                      color: theme.inactiveColor,
                      fontSize: 12.5,
                    ),
                  ),
                ],
                // App note line
                if (narrative.appNote != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    narrative.appNote!,
                    style: theme.typography.body?.copyWith(
                      color: theme.inactiveColor,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToneBadge extends StatelessWidget {
  final String tone;
  final Color accent;

  const _ToneBadge({required this.tone, required this.accent});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    Color bg;
    Color fg;
    if (tone.contains('Solid') || tone.contains('Light') || tone.contains('Decent')) {
      bg = accent.withValues(alpha: 0.15);
      fg = accent;
    } else {
      bg = Colors.warningPrimaryColor.withValues(alpha: 0.12);
      fg = Colors.warningPrimaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tone,
        style: theme.typography.caption?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
