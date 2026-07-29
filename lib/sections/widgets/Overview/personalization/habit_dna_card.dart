import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import '../../../controller/data_controllers/personalization/habit_profile_models.dart';

class HabitDNACard extends StatelessWidget {
  final HabitProfile profile;

  const HabitDNACard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final accent = theme.accentColor;

    final avgMins = profile.avgFocusSessionLength.inMinutes;
    final avgFocusStr = avgMins >= 60
        ? '${avgMins ~/ 60}h ${avgMins.remainder(60)}m'
        : '${avgMins}m';

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
          // Header
          Row(
            children: [
              Icon(FluentIcons.graph_symbol, size: 14, color: accent),
              const SizedBox(width: 6),
              Text(
                l10n.habitDnaTitle,
                style: theme.typography.body?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
              const Spacer(),
              Text(
                l10n.habitDnaAnalyzed(profile.daysAnalyzed),
                style: theme.typography.caption?.copyWith(
                  color: theme.inactiveColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Grid of stats
          _GridRow(
            items: [
              _Stat(
                icon: FluentIcons.clock,
                label: l10n.habitDnaChronotype,
                value: profile.getChronotypeLabel(l10n),
                accent: accent,
              ),
              _Stat(
                icon: FluentIcons.focus,
                label: l10n.habitDnaWorkStyle,
                value: profile.getWorkStyleLabel(l10n),
                accent: accent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _GridRow(
            items: [
              _Stat(
                icon: FluentIcons.timer,
                label: l10n.habitDnaPeakFocus,
                value: profile.getPeakFocusWindow(l10n),
                accent: accent,
              ),
              _Stat(
                icon: FluentIcons.history,
                label: l10n.habitDnaAvgSession,
                value: avgMins > 0 ? avgFocusStr : '—',
                accent: accent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _GridRow(
            items: [
              _Stat(
                icon: FluentIcons.like,
                label: l10n.habitDnaBestDay,
                value: profile.getBestDayLabel(l10n),
                accent: const Color(0xff22C55E),
              ),
              _Stat(
                icon: FluentIcons.dislike,
                label: l10n.habitDnaRoughDay,
                value: profile.getWorstDayLabel(l10n),
                accent: Colors.warningPrimaryColor,
              ),
            ],
          ),
          if (profile.mostCommonDistractionApp != null) ...[
            const SizedBox(height: 10),
            _DistractionBadge(
              appName: profile.mostCommonDistractionApp!,
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }
}

class _GridRow extends StatelessWidget {
  final List<_Stat> items;
  const _GridRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: items[i]),
        ],
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: accent),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.typography.caption?.copyWith(
                    color: theme.inactiveColor,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: theme.typography.body?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DistractionBadge extends StatelessWidget {
  final String appName;
  final FluentThemeData theme;

  const _DistractionBadge({required this.appName, required this.theme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(FluentIcons.warning, size: 14, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.habitDnaKryptonite(appName),
              style: theme.typography.caption?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
