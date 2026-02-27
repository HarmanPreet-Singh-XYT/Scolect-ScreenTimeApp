import 'package:fluent_ui/fluent_ui.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:screentime/l10n/app_localizations.dart';
import './reusable.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const _kBlue = Color(0xff3B82F6);
const _kGreen = Color(0xff22C55E);
const _kHoverDuration = Duration(milliseconds: 150);
const _kBaseAnimDuration = 800;

const _kHeaderPadding = EdgeInsets.fromLTRB(16, 16, 16, 12);
const _kListPadding = EdgeInsets.fromLTRB(16, 8, 16, 16);
const _kDividerMargin = EdgeInsets.symmetric(horizontal: 16);

const _kCategoryColors = [
  Color(0xff22C55E),
  Color(0xff3B82F6),
  Color(0xffA855F7),
  Color(0xffF97316),
  Color(0xffEF4444),
  Color(0xff06B6D4),
];

// ─── Shared Header Widget (DRY) ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String countLabel;
  final FluentThemeData theme;

  const _SectionHeader({
    required this.color,
    required this.icon,
    required this.title,
    required this.countLabel,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _kHeaderPadding,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            countLabel,
            style: TextStyle(fontSize: 12, color: theme.inactiveColor),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Hoverable Container ─────────────────────────────────────────────

class _HoverableListItem extends StatefulWidget {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Widget child;

  const _HoverableListItem({
    required this.margin,
    required this.padding,
    required this.child,
  });

  @override
  State<_HoverableListItem> createState() => _HoverableListItemState();
}

class _HoverableListItemState extends State<_HoverableListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: _kHoverDuration,
        margin: widget.margin,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: _isHovered
              ? theme.resources.subtleFillColorSecondary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: widget.child,
      ),
    );
  }
}

// ─── Shared Progress Bar (DRY) ──────────────────────────────────────────────

class _AnimatedProgressBar extends StatelessWidget {
  final double percent;
  final Color color;
  final double height;
  final int animationDuration;

  const _AnimatedProgressBar({
    required this.percent,
    required this.color,
    required this.height,
    required this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearPercentIndicator(
        animation: true,
        animationDuration: animationDuration,
        lineHeight: height,
        percent: percent,
        backgroundColor: color.withValues(alpha: 0.12),
        progressColor: color,
        padding: EdgeInsets.zero,
        barRadius: const Radius.circular(4),
      ),
    );
  }
}

// ─── TopApplicationsList ────────────────────────────────────────────────────

class TopApplicationsList extends StatelessWidget {
  final List<dynamic> data;

  const TopApplicationsList({super.key, required this.data});

  List<dynamic> _filteredSorted() {
    final list = data
        .where((app) =>
            app['name'] != null &&
            app['name'].toString().trim().isNotEmpty &&
            app['isVisible'] == true)
        .take(20) // limit early rather than building full list then .take(20)
        .toList(growable: false);
    list.sort((a, b) => (b['percentageOfTotalTime'] ?? 0)
        .compareTo(a['percentageOfTotalTime'] ?? 0));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final filteredData = _filteredSorted();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          color: _kBlue,
          icon: FluentIcons.app_icon_default_list,
          title: l10n.topApplications,
          countLabel: l10n.appsCount(filteredData.length),
          theme: theme,
        ),
        Divider(
          style: DividerThemeData(
            horizontalMargin: _kDividerMargin,
            thickness: 1,
          ),
        ),
        Expanded(
          child: filteredData.isEmpty
              ? EmptyState(
                  icon: FluentIcons.app_icon_default,
                  message: l10n.noApplicationDataAvailable,
                )
              : ListView.builder(
                  padding: _kListPadding,
                  itemCount: filteredData.length,
                  itemExtent: 68, // fixed height → O(1) scroll calculations
                  itemBuilder: (context, index) {
                    final app = filteredData[index];
                    return _ApplicationItemContent(
                      name: app['name'] ?? l10n.unknownApp,
                      category: app['category'] ?? l10n.uncategorized,
                      screenTime: app['screenTime'] ?? l10n.defaultTime,
                      clampedPercent:
                          ((app['percentageOfTotalTime'] ?? 0).toDouble() / 100)
                              .clamp(0.0, 1.0),
                      color: _kBlue,
                      animDuration: _kBaseAnimDuration + (index * 100),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─── Application Item (stateless content, hover handled by wrapper) ─────────

class _ApplicationItemContent extends StatelessWidget {
  final String name;
  final String category;
  final String screenTime;
  final double clampedPercent;
  final Color color;
  final int animDuration;

  const _ApplicationItemContent({
    required this.name,
    required this.category,
    required this.screenTime,
    required this.clampedPercent,
    required this.color,
    required this.animDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return _HoverableListItem(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.inactiveColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AnimatedProgressBar(
                  percent: clampedPercent,
                  color: color,
                  height: 6,
                  animationDuration: animDuration,
                ),
                const SizedBox(height: 4),
                Text(
                  screenTime,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: theme.typography.body?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CategoryBreakdownList ──────────────────────────────────────────────────

class CategoryBreakdownList extends StatelessWidget {
  final List<dynamic> data;

  const CategoryBreakdownList({super.key, required this.data});

  List<dynamic> _filtered() => data
      .where((cat) =>
          cat['name'] != null && cat['name'].toString().trim().isNotEmpty)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final filteredData = _filtered();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          color: _kGreen,
          icon: FluentIcons.category_classification,
          title: l10n.categoryBreakdown,
          countLabel: l10n.categoriesCount(filteredData.length),
          theme: theme,
        ),
        Divider(
          style: DividerThemeData(
            horizontalMargin: _kDividerMargin,
            thickness: 1,
          ),
        ),
        Expanded(
          child: filteredData.isEmpty
              ? EmptyState(
                  icon: FluentIcons.category_classification,
                  message: l10n.noCategoryDataAvailable,
                )
              : ListView.builder(
                  padding: _kListPadding,
                  itemCount: filteredData.length,
                  // REMOVED itemExtent — let each item size itself naturally
                  itemBuilder: (context, index) {
                    final category = filteredData[index];
                    final pct =
                        (category['percentageOfTotalTime'] ?? 0).toDouble();

                    return _CategoryItemContent(
                      name: category['name'] ?? l10n.uncategorized,
                      screenTime:
                          category['totalScreenTime'] ?? l10n.defaultTime,
                      percentage: pct,
                      clampedPercent: (pct / 100).clamp(0.0, 1.0),
                      color: _kCategoryColors[index % _kCategoryColors.length],
                      animDuration: _kBaseAnimDuration + (index * 150),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─── Category Item — tightened spacing to eliminate overflow ─────────────────

class _CategoryItemContent extends StatelessWidget {
  final String name;
  final String screenTime;
  final double percentage;
  final double clampedPercent;
  final Color color;
  final int animDuration;

  const _CategoryItemContent({
    required this.name,
    required this.screenTime,
    required this.percentage,
    required this.clampedPercent,
    required this.color,
    required this.animDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return _HoverableListItem(
      margin: const EdgeInsets.only(bottom: 8), // was 12 → 8
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // was 12 → 8
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36, // was 40 → 36
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // shrink-wrap the column
              children: [
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.inactiveColor,
                  ),
                ),
                const SizedBox(height: 4), // was 6 → 4
                _AnimatedProgressBar(
                  percent: clampedPercent,
                  color: color,
                  height: 6, // was 8 → 6
                  animationDuration: animDuration,
                ),
                const SizedBox(height: 3), // was 4 → 3
                Text(
                  screenTime,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11, // was 12 → 11
                    color: theme.typography.body?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
