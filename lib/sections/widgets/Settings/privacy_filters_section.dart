import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/sections/widgets/Settings/reusables.dart';
import 'package:screentime/utils/privacy_filters.dart';

// ============== PRIVACY FILTERS ==============
//
// Desktop-only editor for the regex rules applied by PrivacyFilters.

class PrivacyFiltersSection extends StatefulWidget {
  const PrivacyFiltersSection({super.key});

  @override
  State<PrivacyFiltersSection> createState() => _PrivacyFiltersSectionState();
}

class _PrivacyFiltersSectionState extends State<PrivacyFiltersSection> {
  final PrivacyFilters _filters = PrivacyFilters.instance;

  void _save(List<PrivacyFilterRule> rules) {
    SettingsManager().updateSetting(
        PrivacyFilters.settingKey, rules.map((r) => r.toJson()).toList());
    _filters.refresh();
  }

  Future<void> _edit([PrivacyFilterRule? existing]) async {
    final result = await showDialog<PrivacyFilterRule>(
      context: context,
      builder: (_) => _RuleDialog(existing: existing),
    );
    if (result == null) return;
    final rules = [..._filters.rules];
    final i = rules.indexWhere((r) => r.id == result.id);
    if (i >= 0) {
      rules[i] = result;
    } else {
      rules.add(result);
    }
    _save(rules);
  }

  void _toggle(PrivacyFilterRule rule, bool enabled) => _save([
        for (final r in _filters.rules)
          r.id == rule.id ? r.copyWith(enabled: enabled) : r
      ]);

  void _delete(PrivacyFilterRule rule) =>
      _save(_filters.rules.where((r) => r.id != rule.id).toList());

  String _targetLabel(AppLocalizations l10n, FilterTarget t) => switch (t) {
        FilterTarget.app => l10n.pfTargetApps,
        FilterTarget.website => l10n.pfTargetWebsites,
        FilterTarget.both => l10n.pfTargetBoth,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return ListenableBuilder(
      listenable: _filters,
      builder: (context, _) {
        final rules = _filters.rules;
        return SettingsCard(
          title: l10n.pfTitle,
          icon: FluentIcons.hide3,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(l10n.pfDescription, style: theme.typography.caption),
            ),
            if (rules.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(l10n.pfNoRules, style: theme.typography.caption),
              ),
            for (final r in rules)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    ToggleSwitch(
                      checked: r.enabled,
                      onChanged: (v) => _toggle(r, v),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.pattern,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.bodyStrong
                                  ?.copyWith(fontFamily: 'monospace')),
                          Text(
                            '${_targetLabel(l10n, r.target)} · ${r.action == FilterAction.exclude ? l10n.pfRuleSummaryExclude : l10n.pfRuleSummaryRedact(r.replacement.trim().isEmpty ? PrivacyFilters.defaultReplacement : r.replacement.trim())}',
                            style: theme.typography.caption,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(FluentIcons.edit, size: 14),
                      onPressed: () => _edit(r),
                    ),
                    IconButton(
                      icon: const Icon(FluentIcons.delete, size: 14),
                      onPressed: () => _delete(r),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Button(
                  onPressed: _edit,
                  child: Text(l10n.pfAddRule),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RuleDialog extends StatefulWidget {
  final PrivacyFilterRule? existing;
  const _RuleDialog({this.existing});

  @override
  State<_RuleDialog> createState() => _RuleDialogState();
}

class _RuleDialogState extends State<_RuleDialog> {
  late final TextEditingController _pattern =
      TextEditingController(text: widget.existing?.pattern ?? '');
  late final TextEditingController _replacement =
      TextEditingController(text: widget.existing?.replacement ?? '');
  late FilterTarget _target = widget.existing?.target ?? FilterTarget.both;
  late FilterAction _action = widget.existing?.action ?? FilterAction.exclude;
  String? _error;

  @override
  void dispose() {
    _pattern.dispose();
    _replacement.dispose();
    super.dispose();
  }

  String? _errorFor(AppLocalizations l10n, String pattern) =>
      switch (PrivacyFilters.validate(pattern)) {
        null => null,
        'empty' => l10n.pfErrorEmpty,
        'too_long' => l10n.pfErrorTooLong,
        _ => l10n.pfErrorInvalid,
      };

  void _submit(AppLocalizations l10n) {
    final pattern = _pattern.text.trim();
    final error = _errorFor(l10n, pattern);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(PrivacyFilterRule(
      id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      enabled: widget.existing?.enabled ?? true,
      pattern: pattern,
      target: _target,
      action: _action,
      replacement: _replacement.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ContentDialog(
      title: Text(widget.existing == null ? l10n.pfAddRule : l10n.pfEditRule),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLabel(
            label: l10n.pfPatternLabel,
            child: TextBox(
              controller: _pattern,
              placeholder: l10n.pfPatternHint,
              autofocus: true,
              maxLength: PrivacyFilters.maxPatternLength,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_error!, style: TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 12),
          InfoLabel(
            label: l10n.pfAppliesTo,
            child: ComboBox<FilterTarget>(
              value: _target,
              isExpanded: true,
              items: [
                for (final t in FilterTarget.values)
                  ComboBoxItem(
                    value: t,
                    child: Text(switch (t) {
                      FilterTarget.app => l10n.pfTargetApps,
                      FilterTarget.website => l10n.pfTargetWebsites,
                      FilterTarget.both => l10n.pfTargetBoth,
                    }),
                  ),
              ],
              onChanged: (v) => setState(() => _target = v ?? _target),
            ),
          ),
          const SizedBox(height: 12),
          InfoLabel(
            label: l10n.pfActionLabel,
            child: ComboBox<FilterAction>(
              value: _action,
              isExpanded: true,
              items: [
                ComboBoxItem(
                    value: FilterAction.exclude,
                    child: Text(l10n.pfActionExclude)),
                ComboBoxItem(
                    value: FilterAction.redact,
                    child: Text(l10n.pfActionRedact)),
              ],
              onChanged: (v) => setState(() => _action = v ?? _action),
            ),
          ),
          if (_action == FilterAction.redact) ...[
            const SizedBox(height: 12),
            InfoLabel(
              label: l10n.pfReplacementLabel,
              child: TextBox(
                controller: _replacement,
                placeholder: l10n.pfReplacementHint,
              ),
            ),
          ],
        ],
      ),
      actions: [
        Button(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => _submit(l10n),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
