import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/categories_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/sections/widgets/Settings/reusables.dart';
import 'package:screentime/utils/category_rules.dart';

// ============== CATEGORY RULES ==============
//
// Desktop-only editor for CategoryRules, plus the "lots of uncategorized time"
// hint shown on the Applications page.

void _saveRules(List<CategoryRule> rules) {
  SettingsManager().updateSetting(
      CategoryRules.settingKey, rules.map((r) => r.toJson()).toList());
  CategoryRules.instance.refresh();
}

/// Opens the rule dialog and appends the result. Returns true if a rule was
/// added. [pattern] pre-fills the pattern field.
Future<bool> showAddCategoryRuleDialog(BuildContext context,
    {String? pattern}) async {
  final result = await showDialog<CategoryRule>(
    context: context,
    builder: (_) => _CategoryRuleDialog(prefillPattern: pattern),
  );
  if (result == null) return false;
  _saveRules([...CategoryRules.instance.rules, result]);
  return true;
}

class CategoryRulesSection extends StatefulWidget {
  const CategoryRulesSection({super.key});

  @override
  State<CategoryRulesSection> createState() => _CategoryRulesSectionState();
}

class _CategoryRulesSectionState extends State<CategoryRulesSection> {
  final CategoryRules _rules = CategoryRules.instance;

  Future<void> _edit(CategoryRule rule) async {
    final result = await showDialog<CategoryRule>(
      context: context,
      builder: (_) => _CategoryRuleDialog(existing: rule),
    );
    if (result == null) return;
    _saveRules([for (final r in _rules.rules) r.id == rule.id ? result : r]);
  }

  void _move(CategoryRule rule, int delta) {
    final list = [..._rules.rules];
    final i = list.indexWhere((r) => r.id == rule.id);
    final j = i + delta;
    if (i < 0 || j < 0 || j >= list.length) return;
    list.insert(j, list.removeAt(i));
    _saveRules(list);
  }

  Future<void> _apply() async {
    final l10n = AppLocalizations.of(context)!;
    final changed = await _rules.applyToExistingApps(AppDataStore());
    if (!mounted) return;
    await displayInfoBar(context, builder: (context, close) {
      return InfoBar(
        title: Text(l10n.crApplyResult(changed)),
        severity: InfoBarSeverity.success,
        onClose: close,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return ListenableBuilder(
      listenable: _rules,
      builder: (context, _) {
        final rules = _rules.rules;
        return SettingsCard(
          title: l10n.crTitle,
          icon: FluentIcons.tag,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(l10n.crDescription, style: theme.typography.caption),
            ),
            if (rules.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(l10n.pfNoRules, style: theme.typography.caption),
              ),
            for (var i = 0; i < rules.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    ToggleSwitch(
                      checked: rules[i].enabled,
                      onChanged: (v) => _saveRules([
                        for (final r in _rules.rules)
                          r.id == rules[i].id ? r.copyWith(enabled: v) : r
                      ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rules[i].pattern,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.bodyStrong
                                  ?.copyWith(fontFamily: 'monospace')),
                          Text('→ ${rules[i].category}',
                              style: theme.typography.caption),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: l10n.crMoveUp,
                      child: IconButton(
                        icon: const Icon(FluentIcons.chevron_up, size: 12),
                        onPressed: i == 0 ? null : () => _move(rules[i], -1),
                      ),
                    ),
                    Tooltip(
                      message: l10n.crMoveDown,
                      child: IconButton(
                        icon: const Icon(FluentIcons.chevron_down, size: 12),
                        onPressed: i == rules.length - 1
                            ? null
                            : () => _move(rules[i], 1),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(FluentIcons.edit, size: 14),
                      onPressed: () => _edit(rules[i]),
                    ),
                    IconButton(
                      icon: const Icon(FluentIcons.delete, size: 14),
                      onPressed: () => _saveRules(
                          _rules.rules.where((r) => r.id != rules[i].id).toList()),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Button(
                    onPressed: () => showAddCategoryRuleDialog(context),
                    child: Text(l10n.pfAddRule),
                  ),
                  const SizedBox(width: 8),
                  if (rules.isNotEmpty)
                    Button(
                      onPressed: _apply,
                      child: Text(l10n.crApplyExisting),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryRuleDialog extends StatefulWidget {
  final CategoryRule? existing;
  final String? prefillPattern;
  const _CategoryRuleDialog({this.existing, this.prefillPattern});

  @override
  State<_CategoryRuleDialog> createState() => _CategoryRuleDialogState();
}

class _CategoryRuleDialogState extends State<_CategoryRuleDialog> {
  static const String _otherValue = '__other__';

  late final TextEditingController _pattern = TextEditingController(
      text: widget.existing?.pattern ?? widget.prefillPattern ?? '');
  late final List<String> _categories;
  String? _selectedCategory;
  late final TextEditingController _customCategoryController;
  String? _error;

  @override
  void initState() {
    super.initState();
    final customFromApps = AppDataStore().allCustomCategories;
    final customFromRules =
        CategoryRules.instance.rules.map((r) => r.category);
    _categories = AppCategories.getAllCategories(
      additionalCategories: [...customFromApps, ...customFromRules],
      currentCategory: widget.existing?.category,
    );

    final existing = widget.existing?.category.trim();
    if (existing == null || existing.isEmpty) {
      _selectedCategory = null;
      _customCategoryController = TextEditingController();
    } else if (_categories.any((c) => c.toLowerCase() == existing.toLowerCase())) {
      _selectedCategory = _categories
          .firstWhere((c) => c.toLowerCase() == existing.toLowerCase());
      _customCategoryController = TextEditingController();
    } else {
      _selectedCategory = _otherValue;
      _customCategoryController = TextEditingController(text: existing);
    }
  }

  @override
  void dispose() {
    _pattern.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _submit(AppLocalizations l10n) {
    final pattern = _pattern.text.trim();
    final code = CategoryRules.validate(pattern);
    final category = (_selectedCategory == _otherValue)
        ? _customCategoryController.text.trim()
        : (_selectedCategory ?? '').trim();
    final error = switch (code) {
      null => category.isEmpty ? l10n.crErrorCategory : null,
      'empty' => l10n.pfErrorEmpty,
      'too_long' => l10n.pfErrorTooLong,
      _ => l10n.pfErrorInvalid,
    };
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    AppCategories.addCustomCategory(category);
    Navigator.of(context).pop(CategoryRule(
      id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      enabled: widget.existing?.enabled ?? true,
      pattern: pattern,
      category: category,
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
              maxLength: CategoryRules.maxPatternLength,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
          ),
          const SizedBox(height: 12),
          InfoLabel(
            label: l10n.crCategoryLabel,
            child: ComboBox<String>(
              value: _selectedCategory,
              isExpanded: true,
              placeholder: Text(l10n.crCategoryHint),
              items: [
                for (final name in _categories)
                  ComboBoxItem<String>(value: name, child: Text(name)),
                ComboBoxItem<String>(
                  value: _otherValue,
                  child: Text(l10n.customCategory),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  _selectedCategory = v;
                  if (_error != null) _error = null;
                });
              },
            ),
          ),
          if (_selectedCategory == _otherValue) ...[
            const SizedBox(height: 8),
            TextBox(
              controller: _customCategoryController,
              placeholder: l10n.customCategoryPlaceholder,
              autofocus: true,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
          ],
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: TextStyle(color: Colors.red)),
            ),
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

/// Banner for the Applications page when a large share of recent time is in
/// apps that have no category.
class UncategorizedHint extends StatefulWidget {
  /// Called after a rule is added so the page can reload its data.
  final VoidCallback? onRuleAdded;
  const UncategorizedHint({super.key, this.onRuleAdded});

  @override
  State<UncategorizedHint> createState() => _UncategorizedHintState();
}

class _UncategorizedHintState extends State<UncategorizedHint> {
  UncategorizedSummary? _summary;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _summary = _compute();
  }

  UncategorizedSummary? _compute() {
    try {
      return CategoryRules.summarize(AppDataStore());
    } catch (_) {
      return null;
    }
  }

  String _name(String appId) {
    final meta = AppDataStore().getAppMetadata(appId);
    final name = (meta?.displayName.isNotEmpty ?? false) ? meta!.displayName : appId;
    return name.split(RegExp(r'[\\/]')).last;
  }

  @override
  Widget build(BuildContext context) {
    final s = _summary;
    if (_dismissed || s == null || !CategoryRules.shouldShowHint(s)) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context)!;
    final topIds = s.topApps.map((e) => e.key).toList();
    final names = topIds.take(3).map(_name).join(', ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InfoBar(
        title: Text(l10n.crHintTitle),
        content: Text(l10n.crHintBody((s.share * 100).round(), names)),
        severity: InfoBarSeverity.info,
        isLong: true,
        action: Button(
          onPressed: () async {
            final first = topIds.isEmpty ? null : RegExp.escape(_name(topIds.first));
            final added = await showAddCategoryRuleDialog(context, pattern: first);
            if (added) {
              await CategoryRules.instance.applyToExistingApps(AppDataStore());
              if (!mounted) return;
              setState(() => _summary = _compute());
              widget.onRuleAdded?.call();
            }
          },
          child: Text(l10n.crHintAction),
        ),
        onClose: () => setState(() => _dismissed = true),
      ),
    );
  }
}
