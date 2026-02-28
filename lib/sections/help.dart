import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

// --- Data Models ---

@immutable
class FaqEntry {
  final String question;
  final String answer;

  const FaqEntry({required this.question, required this.answer});

  bool matches(String query) {
    final lowerQuery = query.toLowerCase();
    return question.toLowerCase().contains(lowerQuery) ||
        answer.toLowerCase().contains(lowerQuery);
  }
}

@immutable
class FaqCategory {
  final String name;
  final IconData icon;
  final List<FaqEntry> faqs;

  const FaqCategory({
    required this.name,
    required this.icon,
    required this.faqs,
  });

  FaqCategory? filtered(String query) {
    if (query.isEmpty) return this;
    final filtered = faqs.where((faq) => faq.matches(query)).toList();
    return filtered.isEmpty
        ? null
        : FaqCategory(name: name, icon: icon, faqs: filtered);
  }
}

// --- Quick Nav Data ---

@immutable
class _QuickNavItem {
  final IconData icon;
  final String label;
  final int categoryIndex;

  const _QuickNavItem(this.icon, this.label, this.categoryIndex);
}

// --- Main Widget ---

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  String _searchQuery = '';
  int? _expandedCategoryIndex;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Cache to avoid rebuilding FAQ data every frame
  List<FaqCategory>? _cachedFaqData;
  AppLocalizations? _cachedL10n;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<FaqCategory> _buildFaqData(AppLocalizations l10n) {
    // Return cached if localizations haven't changed
    if (_cachedL10n == l10n && _cachedFaqData != null) return _cachedFaqData!;
    _cachedL10n = l10n;

    _cachedFaqData = [
      FaqCategory(name: l10n.faqCategoryGeneral, icon: FluentIcons.info, faqs: [
        FaqEntry(question: l10n.faqGeneralQ1, answer: l10n.faqGeneralA1),
        FaqEntry(question: l10n.faqGeneralQ2, answer: l10n.faqGeneralA2),
        FaqEntry(question: l10n.faqGeneralQ3, answer: l10n.faqGeneralA3),
        FaqEntry(question: l10n.faqGeneralQ4, answer: l10n.faqGeneralA4),
        FaqEntry(question: l10n.faqGeneralQ5, answer: l10n.faqGeneralA5),
        FaqEntry(question: l10n.faqGeneralQ6, answer: l10n.faqGeneralA6),
        FaqEntry(question: l10n.faqGeneralQ7, answer: l10n.faqGeneralA7),
      ]),
      FaqCategory(
          name: l10n.faqCategoryApplications,
          icon: FluentIcons.app_icon_default,
          faqs: [
            FaqEntry(question: l10n.faqAppsQ1, answer: l10n.faqAppsA1),
            FaqEntry(question: l10n.faqAppsQ2, answer: l10n.faqAppsA2),
            FaqEntry(question: l10n.faqAppsQ3, answer: l10n.faqAppsA3),
            FaqEntry(question: l10n.faqAppsQ4, answer: l10n.faqAppsA4),
          ]),
      FaqCategory(
          name: l10n.faqCategoryReports,
          icon: FluentIcons.chart,
          faqs: [
            FaqEntry(question: l10n.faqReportsQ1, answer: l10n.faqReportsA1),
            FaqEntry(question: l10n.faqReportsQ2, answer: l10n.faqReportsA2),
            FaqEntry(question: l10n.faqReportsQ3, answer: l10n.faqReportsA3),
            FaqEntry(question: l10n.faqReportsQ4, answer: l10n.faqReportsA4),
          ]),
      FaqCategory(
          name: l10n.faqCategoryAlerts,
          icon: FluentIcons.ringer,
          faqs: [
            FaqEntry(question: l10n.faqAlertsQ1, answer: l10n.faqAlertsA1),
            FaqEntry(question: l10n.faqAlertsQ2, answer: l10n.faqAlertsA2),
            FaqEntry(question: l10n.faqAlertsQ3, answer: l10n.faqAlertsA3),
          ]),
      FaqCategory(
          name: l10n.faqCategoryFocusMode,
          icon: FluentIcons.focus,
          faqs: [
            FaqEntry(question: l10n.faqFocusQ1, answer: l10n.faqFocusA1),
            FaqEntry(question: l10n.faqFocusQ2, answer: l10n.faqFocusA2),
            FaqEntry(question: l10n.faqFocusQ3, answer: l10n.faqFocusA3),
            FaqEntry(question: l10n.faqFocusQ4, answer: l10n.faqFocusA4),
          ]),
      FaqCategory(
          name: l10n.faqCategorySettings,
          icon: FluentIcons.settings,
          faqs: [
            FaqEntry(question: l10n.faqSettingsQ1, answer: l10n.faqSettingsA1),
            FaqEntry(question: l10n.faqSettingsQ2, answer: l10n.faqSettingsA2),
            FaqEntry(question: l10n.faqSettingsQ3, answer: l10n.faqSettingsA3),
            FaqEntry(question: l10n.faqSettingsQ4, answer: l10n.faqSettingsA4),
          ]),
      FaqCategory(
          name: l10n.faqCategoryTroubleshooting,
          icon: FluentIcons.repair,
          faqs: [
            FaqEntry(question: l10n.faqTroubleQ1, answer: l10n.faqTroubleA1),
            FaqEntry(question: l10n.faqTroubleQ2, answer: l10n.faqTroubleA2),
          ]),
    ];
    return _cachedFaqData!;
  }

  List<FaqCategory> _getFilteredData(List<FaqCategory> data) {
    if (_searchQuery.isEmpty) return data;
    return data
        .map((c) => c.filtered(_searchQuery))
        .whereType<FaqCategory>()
        .toList();
  }

  void _updateSearch(String value) {
    if (value == _searchQuery) return;
    setState(() => _searchQuery = value);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _toggleCategory(int index, bool isCurrentlyExpanded) {
    setState(() {
      _expandedCategoryIndex = isCurrentlyExpanded ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final faqData = _buildFaqData(l10n);
    final filteredData = _getFilteredData(faqData);
    final totalQuestions =
        faqData.fold<int>(0, (sum, cat) => sum + cat.faqs.length);

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Column(
        children: [
          _HelpHeader(
            l10n: l10n,
            theme: theme,
            totalQuestions: totalQuestions,
            searchQuery: _searchQuery,
            searchController: _searchController,
            expandedCategoryIndex: _expandedCategoryIndex,
            onSearchChanged: _updateSearch,
            onClearSearch: _clearSearch,
            onCategoryTap: _toggleCategory,
          ),
          Expanded(
            child: filteredData.isEmpty
                ? _EmptyState(l10n: l10n, theme: theme, onClear: _clearSearch)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final isExpanded = _expandedCategoryIndex == index ||
                          _searchQuery.isNotEmpty;
                      return _CategorySection(
                        category: filteredData[index],
                        isExpanded: isExpanded,
                        searchQuery: _searchQuery,
                        theme: theme,
                        onToggle: () => _toggleCategory(index, isExpanded),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// --- Header Widget ---

class _HelpHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final FluentThemeData theme;
  final int totalQuestions;
  final String searchQuery;
  final TextEditingController searchController;
  final int? expandedCategoryIndex;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final void Function(int index, bool isExpanded) onCategoryTap;

  const _HelpHeader({
    required this.l10n,
    required this.theme,
    required this.totalQuestions,
    required this.searchQuery,
    required this.searchController,
    required this.expandedCategoryIndex,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: theme.resources.dividerStrokeColorDefault,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(icon: FluentIcons.help, theme: theme),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.helpTitle,
                      style: theme.typography.subtitle
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.helpSubtitle(totalQuestions),
                      style: theme.typography.caption?.copyWith(
                        color: theme.resources.textFillColorSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: TextBox(
              controller: searchController,
              placeholder: l10n.searchForHelp,
              prefix: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(FluentIcons.search,
                    size: 14, color: theme.resources.textFillColorSecondary),
              ),
              suffix: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(FluentIcons.clear, size: 12),
                      onPressed: onClearSearch,
                    )
                  : null,
              onChanged: onSearchChanged,
            ),
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 12),
            _QuickNavigation(
              l10n: l10n,
              theme: theme,
              expandedCategoryIndex: expandedCategoryIndex,
              onCategoryTap: onCategoryTap,
            ),
          ],
        ],
      ),
    );
  }
}

// --- Reusable Icon Box ---

class _IconBox extends StatelessWidget {
  final IconData icon;
  final FluentThemeData theme;
  final double size;
  final double iconSize;
  final double borderRadius;

  const _IconBox({
    required this.icon,
    required this.theme,
    this.size = 10,
    this.iconSize = 20,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(icon, size: iconSize, color: theme.accentColor),
    );
  }
}

// --- Quick Navigation ---

class _QuickNavigation extends StatelessWidget {
  final AppLocalizations l10n;
  final FluentThemeData theme;
  final int? expandedCategoryIndex;
  final void Function(int index, bool isExpanded) onCategoryTap;

  const _QuickNavigation({
    required this.l10n,
    required this.theme,
    required this.expandedCategoryIndex,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickNavItem(FluentIcons.info, l10n.quickNavGeneral, 0),
      _QuickNavItem(FluentIcons.app_icon_default, l10n.quickNavApps, 1),
      _QuickNavItem(FluentIcons.chart, l10n.quickNavReports, 2),
      _QuickNavItem(FluentIcons.focus, l10n.quickNavFocus, 4),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _QuickNavChip(
                item: item,
                isSelected: expandedCategoryIndex == item.categoryIndex,
                theme: theme,
                onPressed: () => onCategoryTap(
                  item.categoryIndex,
                  expandedCategoryIndex == item.categoryIndex,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickNavChip extends StatelessWidget {
  final _QuickNavItem item;
  final bool isSelected;
  final FluentThemeData theme;
  final VoidCallback onPressed;

  const _QuickNavChip({
    required this.item,
    required this.isSelected,
    required this.theme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onPressed: onPressed,
      builder: (context, states) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.accentColor.withValues(alpha: 0.15)
                : states.isHovered
                    ? theme.resources.subtleFillColorSecondary
                    : theme.resources.subtleFillColorTransparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.accentColor.withValues(alpha: 0.5)
                  : theme.resources.dividerStrokeColorDefault,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 12,
                color: isSelected
                    ? theme.accentColor
                    : theme.resources.textFillColorSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: theme.typography.caption?.copyWith(
                  color: isSelected
                      ? theme.accentColor
                      : theme.resources.textFillColorPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Category Section ---

class _CategorySection extends StatelessWidget {
  final FaqCategory category;
  final bool isExpanded;
  final String searchQuery;
  final FluentThemeData theme;
  final VoidCallback onToggle;

  const _CategorySection({
    required this.category,
    required this.isExpanded,
    required this.searchQuery,
    required this.theme,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategoryHeader(
            category: category,
            isExpanded: isExpanded,
            theme: theme,
            onToggle: onToggle,
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Column(
                children: [
                  for (final faq in category.faqs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: FAQItem(
                        question: faq.question,
                        answer: faq.answer,
                        searchQuery: searchQuery,
                      ),
                    ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final FaqCategory category;
  final bool isExpanded;
  final FluentThemeData theme;
  final VoidCallback onToggle;

  const _CategoryHeader({
    required this.category,
    required this.isExpanded,
    required this.theme,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      onPressed: onToggle,
      builder: (context, states) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: states.isHovered
                ? theme.resources.subtleFillColorSecondary
                : theme.resources.subtleFillColorTransparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              _IconBox(
                  icon: category.icon,
                  theme: theme,
                  size: 6,
                  iconSize: 14,
                  borderRadius: 6),
              const SizedBox(width: 10),
              Expanded(
                child: Text(category.name, style: theme.typography.bodyStrong),
              ),
              _CountBadge(count: category.faqs.length, theme: theme),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(FluentIcons.chevron_down,
                    size: 12, color: theme.resources.textFillColorSecondary),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final FluentThemeData theme;

  const _CountBadge({required this.count, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.resources.subtleFillColorSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: theme.typography.caption
            ?.copyWith(color: theme.resources.textFillColorSecondary),
      ),
    );
  }
}

// --- FAQ Item ---

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  final String searchQuery;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
    this.searchQuery = '',
  });

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return HoverButton(
      onPressed: () => setState(() => _isExpanded = !_isExpanded),
      builder: (context, states) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isExpanded
                ? theme.resources.subtleFillColorSecondary
                : states.isHovered
                    ? theme.resources.subtleFillColorSecondary
                        .withValues(alpha: 0.5)
                    : theme.resources.subtleFillColorTransparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _isExpanded
                  ? theme.resources.dividerStrokeColorDefault
                  : Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      FluentIcons.status_circle_question_mark,
                      size: 14,
                      color: theme.accentColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HighlightedText(
                        text: widget.question,
                        query: widget.searchQuery,
                        baseStyle: theme.typography.body
                            ?.copyWith(fontWeight: FontWeight.w500),
                        highlightColor:
                            theme.accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(FluentIcons.chevron_down,
                          size: 10,
                          color: theme.resources.textFillColorSecondary),
                    ),
                  ],
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(36, 0, 12, 12),
                  child: _HighlightedText(
                    text: widget.answer,
                    query: widget.searchQuery,
                    baseStyle: theme.typography.body?.copyWith(
                      color: theme.resources.textFillColorSecondary,
                      height: 1.5,
                    ),
                    highlightColor: theme.accentColor.withValues(alpha: 0.3),
                  ),
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Highlighted Text (extracted as standalone widget for reuse & clarity) ---

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? baseStyle;
  final Color highlightColor;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text, style: baseStyle);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (start < text.length) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
            backgroundColor: highlightColor, fontWeight: FontWeight.w600),
      ));
      start = index + query.length;
    }

    return RichText(text: TextSpan(style: baseStyle, children: spans));
  }
}

// --- Empty State ---

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final FluentThemeData theme;
  final VoidCallback onClear;

  const _EmptyState(
      {required this.l10n, required this.theme, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FluentIcons.search,
              size: 48, color: theme.resources.textFillColorDisabled),
          const SizedBox(height: 16),
          Text(
            l10n.noResultsFound,
            style: theme.typography.bodyLarge
                ?.copyWith(color: theme.resources.textFillColorSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.tryDifferentKeywords,
            style: theme.typography.caption
                ?.copyWith(color: theme.resources.textFillColorDisabled),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onClear, child: Text(l10n.clearSearch)),
        ],
      ),
    );
  }
}
