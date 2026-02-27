import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/sections/controller/data_controllers/alerts_limits_data_controller.dart';
import 'package:screentime/l10n/app_localizations.dart';
import './reusable.dart' as rub;
import './approw.dart';

class ApplicationLimitsCard extends StatelessWidget {
  final List<AppUsageSummary> appSummaries;
  final ScreenTimeDataController controller;
  final VoidCallback onDataChanged;

  const ApplicationLimitsCard({
    super.key,
    required this.appSummaries,
    required this.controller,
    required this.onDataChanged,
  });

  // ──────────────────────────── constants ────────────────────────────

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF6B7280),
  );

  static const _sectionLabelStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );

  // ──────────────────────────── build ────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filteredApps =
        appSummaries.where((app) => app.appName.trim().isNotEmpty).toList();

    return rub.Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(
            count: filteredApps.length,
            onAdd: () => _showLimitDialog(context),
          ),
          _TableHeader(headerStyle: _headerStyle),
          if (filteredApps.isEmpty)
            _EmptyState()
          else
            ...filteredApps.asMap().entries.map((entry) => AppRow(
                  app: entry.value,
                  onEdit: () => _showLimitDialog(context, app: entry.value),
                  isLast: entry.key == filteredApps.length - 1,
                )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ──────────────────────── unified dialog ───────────────────────────

  void _showLimitDialog(BuildContext context, {AppUsageSummary? app}) {
    final isEdit = app != null;
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    String? selectedApp = app?.appName;
    double hours = app?.dailyLimit.inHours.toDouble() ?? 1.0;
    double minutes = (app?.dailyLimit.inMinutes ?? 0) % 60.0;
    bool limitEnabled = app?.limitStatus ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final totalMinutes = (hours * 60 + minutes).round();
          final formattedTime = formatDuration(hours.round(), minutes.round());
          final canSubmit = isEdit || (selectedApp != null && totalMinutes > 0);

          return ContentDialog(
            title: _DialogTitle(
              icon: isEdit ? FluentIcons.edit : FluentIcons.add,
              label: isEdit
                  ? l10n.editLimitTitle(app.appName)
                  : l10n.addApplicationLimit,
            ),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App selector — only for add mode
                  if (!isEdit) ...[
                    Text(l10n.selectApplication, style: _sectionLabelStyle),
                    const SizedBox(height: 8),
                    ComboBox<String>(
                      placeholder: Text(
                        l10n.selectApplicationPlaceholder,
                        style: TextStyle(
                          color: theme.resources.textFillColorSecondary,
                        ),
                      ),
                      isExpanded: true,
                      items: appSummaries
                          .where((a) => a.appName.trim().isNotEmpty)
                          .map((a) => ComboBoxItem<String>(
                                value: a.appName,
                                child: Text(a.appName,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      value: selectedApp,
                      onChanged: (v) => setState(() => selectedApp = v),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],

                  // Toggle
                  _ToggleRow(
                    label: l10n.enableLimit,
                    value: limitEnabled,
                    onChanged: (v) => setState(() => limitEnabled = v),
                  ),

                  const SizedBox(height: 24),

                  if (isEdit) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                  ],

                  // Time sliders
                  _TimePicker(
                    enabled: limitEnabled,
                    formattedTime: formattedTime,
                    hours: hours,
                    minutes: minutes,
                    hoursLabel: l10n.hours,
                    minutesLabel: l10n.minutes,
                    dailyLimitLabel: l10n.dailyLimit,
                    onHoursChanged: (v) => setState(() => hours = v),
                    onMinutesChanged: (v) => setState(() => minutes = v),
                  ),
                ],
              ),
            ),
            actions: [
              Button(
                child: Text(l10n.cancel),
                onPressed: () => Navigator.pop(context),
              ),
              FilledButton(
                onPressed: canSubmit
                    ? () {
                        final duration = Duration(
                          hours: hours.round(),
                          minutes: minutes.round() ~/ 5 * 5,
                        );
                        controller.updateAppLimit(
                          selectedApp!,
                          duration,
                          limitEnabled,
                        );
                        onDataChanged();
                        Navigator.pop(context);
                      }
                    : null,
                child: Text(isEdit ? l10n.save : l10n.add),
              ),
            ],
          );
        },
      ),
    );
  }

  // ──────────────────────── static helpers ───────────────────────────

  static String formatDuration(int hours, int minutes) {
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    if (minutes > 0) return '${minutes}m';
    return '0m';
  }
}

// ════════════════════════ Extracted Widgets ══════════════════════════

class _Header extends StatelessWidget {
  final int count;
  final VoidCallback onAdd;

  const _Header({required this.count, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(FluentIcons.app_icon_default,
                size: 18, color: theme.accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.applicationLimits,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  l10n.applicationsTracked(count),
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        theme.typography.caption?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            onPressed: onAdd,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FluentIcons.add, size: 12),
                const SizedBox(width: 6),
                Text(l10n.addLimit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final TextStyle headerStyle;

  const _TableHeader({required this.headerStyle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final borderColor = theme.inactiveBackgroundColor.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.03),
        border: Border(
          top: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 3, child: Text(l10n.applicationHeader, style: headerStyle)),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(l10n.categoryHeader, style: headerStyle),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(l10n.dailyLimitHeader, style: headerStyle),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(l10n.currentUsageHeader, style: headerStyle),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(l10n.edit,
                style: headerStyle, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FluentIcons.app_icon_default,
                size: 48, color: theme.inactiveColor),
            const SizedBox(height: 16),
            Text(
              l10n.noApplicationsToDisplay,
              style: TextStyle(color: theme.inactiveColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogTitle extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DialogTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.accentColor, size: 20),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.resources.dividerStrokeColorDefault),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ToggleSwitch(checked: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final bool enabled;
  final String formattedTime;
  final double hours;
  final double minutes;
  final String hoursLabel;
  final String minutesLabel;
  final String dailyLimitLabel;
  final ValueChanged<double> onHoursChanged;
  final ValueChanged<double> onMinutesChanged;

  const _TimePicker({
    required this.enabled,
    required this.formattedTime,
    required this.hours,
    required this.minutes,
    required this.hoursLabel,
    required this.minutesLabel,
    required this.dailyLimitLabel,
    required this.onHoursChanged,
    required this.onMinutesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !enabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dailyLimitLabel,
                style: ApplicationLimitsCard._sectionLabelStyle),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.accentColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            rub.SliderRow(
              label: hoursLabel,
              value: hours,
              max: 12,
              divisions: 12,
              onChanged: onHoursChanged,
            ),
            const SizedBox(height: 12),
            rub.SliderRow(
              label: minutesLabel,
              value: minutes,
              max: 55,
              divisions: 11,
              step: 5,
              onChanged: onMinutesChanged,
            ),
          ],
        ),
      ),
    );
  }
}
