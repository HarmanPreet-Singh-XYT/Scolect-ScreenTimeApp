import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/categories_controller.dart';
import 'package:screentime/sections/widgets/Settings/reusables.dart';

class CustomCategoriesSection extends StatefulWidget {
  const CustomCategoriesSection({super.key});

  @override
  State<CustomCategoriesSection> createState() => _CustomCategoriesSectionState();
}

class _CustomCategoriesSectionState extends State<CustomCategoriesSection> {
  Future<void> _addCategory(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    String? error;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void submit() {
              final text = controller.text.trim();
              if (text.isEmpty) {
                setDialogState(() => error = l10n.clErrorCategory);
                return;
              }
              final lower = text.toLowerCase();
              if (lower == 'all' || lower == 'uncategorized') {
                setDialogState(() => error = l10n.clErrorCategory);
                return;
              }
              if (AppCategories.getAllCategories().any((c) => c.toLowerCase() == lower)) {
                setDialogState(() => error = 'Category already exists.');
                return;
              }
              Navigator.of(dialogContext).pop(text);
            }

            return ContentDialog(
              title: Text(l10n.customCategory),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoLabel(
                    label: l10n.crCategoryLabel,
                    child: TextBox(
                      controller: controller,
                      placeholder: l10n.customCategoryPlaceholder,
                      autofocus: true,
                      onSubmitted: (_) => submit(),
                      onChanged: (_) {
                        if (error != null) setDialogState(() => error = null);
                      },
                    ),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(error!, style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
              actions: [
                Button(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: submit,
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    if (result != null && result.isNotEmpty) {
      AppCategories.addCustomCategory(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return ListenableBuilder(
      listenable: AppCategories.changeNotifier,
      builder: (context, _) {
        final customCategories = AppCategories.userCustomCategories;

        return SettingsCard(
          title: '${l10n.customCategory} Categories',
          icon: FluentIcons.tag,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'Permanently saved categories available across all apps, limits, and rules.',
                style: theme.typography.caption,
              ),
            ),
            if (customCategories.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  'No custom categories created yet. Click "Add category" or choose "${l10n.customCategory}" when editing an app or setting a limit.',
                  style: theme.typography.caption,
                ),
              )
            else
              for (final cat in customCategories)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppCategories.getCategoryColor(cat).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          FluentIcons.tag,
                          size: 14,
                          color: AppCategories.getCategoryColor(cat),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat,
                          style: theme.typography.bodyStrong,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(FluentIcons.delete, size: 14),
                        onPressed: () => AppCategories.removeCustomCategory(cat),
                      ),
                    ],
                  ),
                ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Button(
                  onPressed: () => _addCategory(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.add, size: 12),
                      const SizedBox(width: 6),
                      Text('Add category'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
