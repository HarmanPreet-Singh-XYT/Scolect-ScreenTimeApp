import 'package:fluent_ui/fluent_ui.dart';
import '../../../controller/data_controllers/personalization/insight_models.dart';

class InsightCard extends StatelessWidget {
  final Insight insight;
  final VoidCallback onDismiss;

  const InsightCard({
    super.key,
    required this.insight,
    required this.onDismiss,
  });

  Color _stripeColor(FluentThemeData theme) {
    switch (insight.severity) {
      case InsightSeverity.positive:
        return const Color(0xff22C55E); // green
      case InsightSeverity.warning:
        return Colors.warningPrimaryColor;
      case InsightSeverity.neutral:
        return theme.accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final stripe = _stripeColor(theme);

    return Container(
      width: 300,
      padding: const EdgeInsets.fromLTRB(0, 12, 10, 12),
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
          // Colored stripe
          Container(
            width: 3,
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: stripe,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: theme.typography.body?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  insight.body,
                  style: theme.typography.caption?.copyWith(
                    color: theme.inactiveColor,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // Dismiss button
          GestureDetector(
            onTap: onDismiss,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                FluentIcons.cancel,
                size: 10,
                color: theme.inactiveColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Insight Carousel (horizontal scrollable row) ─────────────────────────────

class InsightCarousel extends StatelessWidget {
  final List<Insight> insights;
  final void Function(String id) onDismiss;

  const InsightCarousel({
    super.key,
    required this.insights,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: insights.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final insight = insights[index];
          return InsightCard(
            insight: insight,
            onDismiss: () => onDismiss(insight.id),
          );
        },
      ),
    );
  }
}
