import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/widgets/duration_fields.dart';
import 'package:screentime/sections/controller/categories_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/sections/widgets/Settings/reusables.dart';
import 'package:screentime/utils/category_limits.dart';
import 'package:screentime/utils/daily_digest.dart';

// ============== CATEGORY LIMITS + DAILY DIGEST ==============

void _saveLimits(List<CategoryLimit> limits) {
  SettingsManager().updateSetting(
      CategoryLimits.settingKey, limits.map((l) => l.toJson()).toList());
  CategoryLimits.instance.refresh();
}

class CategoryLimitsSection extends StatefulWidget {
  const CategoryLimitsSection({super.key});

  @override
  State<CategoryLimitsSection> createState() => _CategoryLimitsSectionState();
}

class _CategoryLimitsSectionState extends State<CategoryLimitsSection> {
  final CategoryLimits _limits = CategoryLimits.instance;

  Future<void> _edit([CategoryLimit? existing]) async {
    final result = await showDialog<CategoryLimit>(
      context: context,
      builder: (_) => _LimitDialog(existing: existing),
    );
    if (result == null) return;
    final list = [..._limits.limits];
    final i = list.indexWhere((l) => l.id == result.id);
    if (i >= 0) {
      list[i] = result;
    } else {
      list.add(result);
    }
    _saveLimits(list);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return ListenableBuilder(
      listenable: _limits,
      builder: (context, _) {
        final limits = _limits.limits;
        return SettingsCard(
          title: l10n.clTitle,
          icon: FluentIcons.timer,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(l10n.clDescription, style: theme.typography.caption),
            ),
            if (limits.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(l10n.pfNoRules, style: theme.typography.caption),
              ),
            for (final l in limits)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    ToggleSwitch(
                      checked: l.enabled,
                      onChanged: (v) => _saveLimits([
                        for (final x in _limits.limits)
                          x.id == l.id ? x.copyWith(enabled: v) : x
                      ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.category,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.bodyStrong),
                          Text(DailyDigest.formatDuration(l.limit),
                              style: theme.typography.caption),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(FluentIcons.edit, size: 14),
                      onPressed: () => _edit(l),
                    ),
                    IconButton(
                      icon: const Icon(FluentIcons.delete, size: 14),
                      onPressed: () => _saveLimits(
                          _limits.limits.where((x) => x.id != l.id).toList()),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Button(onPressed: _edit, child: Text(l10n.clAdd)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LimitDialog extends StatefulWidget {
  final CategoryLimit? existing;
  const _LimitDialog({this.existing});

  @override
  State<_LimitDialog> createState() => _LimitDialogState();
}

class _LimitDialogState extends State<_LimitDialog> {
  late final TextEditingController _category =
      TextEditingController(text: widget.existing?.category ?? '');
  late int _hours = (widget.existing?.minutes ?? 60) ~/ 60;
  late int _minutes = (widget.existing?.minutes ?? 60) % 60;
  String? _error;

  static List<String> get _suggestions => [
        for (final c in AppCategories.categories)
          if (c.name != 'All') c.name
      ];

  @override
  void dispose() {
    _category.dispose();
    super.dispose();
  }

  void _submit(AppLocalizations l10n) {
    final category = _category.text.trim();
    final minutes = _hours * 60 + _minutes;
    final error = category.isEmpty
        ? l10n.clErrorCategory
        : (minutes <= 0 ? l10n.clErrorLimit : null);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(CategoryLimit(
      id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      category: category,
      minutes: minutes.clamp(1, CategoryLimits.maxMinutes),
      enabled: widget.existing?.enabled ?? true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ContentDialog(
      title: Text(widget.existing == null ? l10n.clAdd : l10n.clEdit),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLabel(
            label: l10n.crCategoryLabel,
            child: AutoSuggestBox<String>(
              controller: _category,
              placeholder: l10n.crCategoryHint,
              items: [
                for (final n in _suggestions)
                  AutoSuggestBoxItem<String>(value: n, label: n),
              ],
              onChanged: (_, __) {
                if (_error != null) setState(() => _error = null);
              },
            ),
          ),
          const SizedBox(height: 12),
          InfoLabel(
            label: l10n.clLimitLabel,
            child: DurationFields(
              hours: _hours,
              minutes: _minutes,
              onHoursChanged: (v) => setState(() => _hours = v),
              onMinutesChanged: (v) => setState(() => _minutes = v),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      actions: [
        Button(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(onPressed: () => _submit(l10n), child: Text(l10n.save)),
      ],
    );
  }
}

class DailyDigestSection extends StatefulWidget {
  const DailyDigestSection({super.key});

  @override
  State<DailyDigestSection> createState() => _DailyDigestSectionState();
}

class _DailyDigestSectionState extends State<DailyDigestSection> {
  final SettingsManager _settings = SettingsManager();
  late bool _enabled = _settings.getSetting('dailyDigest.enabled') == true;
  late int _hour =
      ((_settings.getSetting('dailyDigest.hour') as num?)?.toInt() ?? 21).clamp(0, 23);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SettingsCard(
      title: l10n.ddTitle,
      icon: FluentIcons.mail,
      children: [
        SettingRow(
          title: l10n.ddToggleTitle,
          description: l10n.ddToggleDescription,
          showDivider: _enabled,
          control: ToggleSwitch(
            checked: _enabled,
            onChanged: (v) {
              _settings.updateSetting('dailyDigest.enabled', v);
              setState(() => _enabled = v);
            },
          ),
        ),
        if (_enabled)
          SettingRow(
            title: l10n.ddHourLabel,
            description: '',
            showDivider: false,
            control: ComboBox<int>(
              value: _hour,
              items: [
                for (var h = 0; h < 24; h++)
                  ComboBoxItem(
                      value: h, child: Text('${h.toString().padLeft(2, '0')}:00')),
              ],
              onChanged: (v) {
                if (v == null) return;
                _settings.updateSetting('dailyDigest.hour', v);
                setState(() => _hour = v);
              },
            ),
          ),
      ],
    );
  }
}
