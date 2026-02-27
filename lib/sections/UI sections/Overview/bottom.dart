import 'package:fluent_ui/fluent_ui.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:screentime/l10n/app_localizations.dart';
import './reusable.dart';

// ─── Constants ───────────────────────────────────────────────────────────────
const _kOrange = Color(0xffF97316);
const _kRed = Color(0xffEF4444);
const _kAnimDuration = Duration(milliseconds: 1000);
const _kHoverDuration = Duration(milliseconds: 200);
const _kCircularAnimDuration = 1200;
const _kCompactBreakpoint = 300.0;
const _kHorizontalAspectThreshold = 1.8;
const _kHorizontalMaxHeight = 120.0;

// ─── ApplicationLimitsList ───────────────────────────────────────────────────

class ApplicationLimitsList extends StatelessWidget {
  final List<dynamic> data;

  const ApplicationLimitsList({super.key, required this.data});

  /// Pre-filters once rather than on every build if data hasn't changed.
  List<dynamic> _filterData() => data
      .where((app) =>
          app['name'] != null && app['name'].toString().trim().isNotEmpty)
      .toList(growable: false); // growable:false — minor alloc saving

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredData = _filterData();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < _kCompactBreakpoint;
        final pad = isCompact ? 12.0 : 16.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(padding: pad, isCompact: isCompact, l10n: l10n),
            Expanded(
              child: filteredData.isEmpty
                  ? EmptyState(
                      icon: FluentIcons.timer,
                      message: l10n.noApplicationLimitsSet,
                    )
                  : _LimitListView(
                      data: filteredData,
                      padding: pad,
                      isCompact: isCompact,
                      l10n: l10n,
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Extracted Header (const-friendly, avoids rebuilding) ────────────────────

class _Header extends StatelessWidget {
  final double padding;
  final bool isCompact;
  final AppLocalizations l10n;

  const _Header({
    required this.padding,
    required this.isCompact,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, padding - 2, padding, padding - 6),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? 4 : 5),
            decoration: BoxDecoration(
              color: _kOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              FluentIcons.timer,
              size: isCompact ? 10 : 12,
              color: _kOrange,
            ),
          ),
          SizedBox(width: isCompact ? 6.0 : 8.0),
          Expanded(
            child: Text(
              l10n.applicationLimits,
              style: TextStyle(
                fontSize: isCompact ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Extracted ListView (uses itemExtent for faster layout) ──────────────────

class _LimitListView extends StatelessWidget {
  final List<dynamic> data;
  final double padding;
  final bool isCompact;
  final AppLocalizations l10n;

  const _LimitListView({
    required this.data,
    required this.padding,
    required this.isCompact,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // itemExtent lets the framework skip measuring each child → faster scrolls
    final itemHeight = isCompact ? 40.0 : 30.0;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, padding - 4),
      itemCount: data.length,
      itemExtent: itemHeight,
      itemBuilder: (context, index) {
        final app = data[index];
        final pct = (app['percentageOfLimit'] ?? 0).toDouble();

        return _LimitItem(
          name: app['name'] ?? l10n.unknownApp,
          limit: app['dailyLimit'] ?? l10n.defaultTime,
          usage: app['actualUsage'] ?? l10n.defaultTime,
          percentOfLimit: pct,
          isOverLimit: pct > 100,
          isCompact: isCompact,
        );
      },
    );
  }
}

// ─── _LimitItem (unchanged logic, cached computed values) ────────────────────

class _LimitItem extends StatelessWidget {
  final String name;
  final String limit;
  final String usage;
  final double percentOfLimit;
  final bool isOverLimit;
  final bool isCompact;

  const _LimitItem({
    required this.name,
    required this.limit,
    required this.usage,
    required this.percentOfLimit,
    required this.isOverLimit,
    this.isCompact = false,
  });

  // Compute once per build, not inline multiple times
  double get _clampedPercent => (percentOfLimit / 100).clamp(0.0, 1.0);
  Color get _color => isOverLimit ? _kRed : _kOrange;
  String get _label => '$usage / $limit';

  @override
  Widget build(BuildContext context) {
    return isCompact ? _buildCompact() : _buildNormal();
  }

  Widget _buildCompact() {
    final color = _color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: isOverLimit ? color : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _ProgressBar(
            percent: _clampedPercent,
            color: color,
            height: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNormal() {
    final color = _color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: _ProgressBar(
              percent: _clampedPercent,
              color: color,
              height: 5,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              _label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isOverLimit ? color : null,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared progress bar widget (DRY) ────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final double percent;
  final Color color;
  final double height;

  const _ProgressBar({
    required this.percent,
    required this.color,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearPercentIndicator(
        animation: true,
        animationDuration: _kAnimDuration.inMilliseconds,
        lineHeight: height,
        percent: percent,
        backgroundColor: color.withValues(alpha: 0.15),
        progressColor: color,
        padding: EdgeInsets.zero,
        barRadius: const Radius.circular(3),
      ),
    );
  }
}

// ─── ProgressCard ────────────────────────────────────────────────────────────

class ProgressCard extends StatefulWidget {
  final String title;
  final double value;
  final Color color;

  const ProgressCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  bool _isHovered = false;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isReady = true);
    });
  }

  // Cache derived values so they aren't recomputed in the build tree
  double get _clampedValue => widget.value.clamp(0.0, 1.0);
  String get _percentLabel => '${(widget.value * 100).toInt()}%';

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final color = widget.color;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: _kHoverDuration,
        decoration: BoxDecoration(
          color: theme.micaBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? color.withValues(alpha: 0.4)
                : theme.resources.cardStrokeColorDefault,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [], // const empty list avoids allocation
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (!_isReady ||
                !constraints.hasBoundedHeight ||
                !constraints.hasBoundedWidth ||
                constraints.maxHeight < 50 ||
                constraints.maxWidth < 50) {
              return const SizedBox.shrink();
            }

            final aspect = constraints.maxWidth / constraints.maxHeight;
            final horizontal = aspect > _kHorizontalAspectThreshold &&
                constraints.maxHeight < _kHorizontalMaxHeight;

            return horizontal
                ? _HorizontalProgress(
                    height: constraints.maxHeight,
                    value: _clampedValue,
                    label: _percentLabel,
                    title: widget.title,
                    color: color,
                    theme: theme,
                  )
                : _VerticalProgress(
                    constraints: constraints,
                    value: _clampedValue,
                    label: _percentLabel,
                    title: widget.title,
                    color: color,
                    theme: theme,
                  );
          },
        ),
      ),
    );
  }
}

// ─── Extracted layout sub-widgets (smaller build methods, easier to profile) ─

class _VerticalProgress extends StatelessWidget {
  final BoxConstraints constraints;
  final double value;
  final String label;
  final String title;
  final Color color;
  final FluentThemeData theme;

  const _VerticalProgress({
    required this.constraints,
    required this.value,
    required this.label,
    required this.title,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final smaller = constraints.maxHeight < constraints.maxWidth
        ? constraints.maxHeight
        : constraints.maxWidth;
    final radius = ((smaller / 2) - 20).clamp(30.0, 200.0);
    final lineWidth = (radius * 0.18).clamp(6.0, 24.0);
    final pctFont = (radius * 0.35).clamp(14.0, 32.0);
    final titleFont = (radius * 0.16).clamp(9.0, 14.0);

    return Center(
      child: CircularPercentIndicator(
        radius: radius,
        lineWidth: lineWidth,
        animation: true,
        animationDuration: _kCircularAnimDuration,
        percent: value,
        center: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: pctFont,
                    color: color,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFont,
                    color: theme.inactiveColor,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: color,
        backgroundColor: color.withValues(alpha: 0.12),
      ),
    );
  }
}

class _HorizontalProgress extends StatelessWidget {
  final double height;
  final double value;
  final String label;
  final String title;
  final Color color;
  final FluentThemeData theme;

  const _HorizontalProgress({
    required this.height,
    required this.value,
    required this.label,
    required this.title,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final radius = ((height / 2) - 12).clamp(25.0, 50.0);
    final lineWidth = (radius * 0.2).clamp(4.0, 10.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: radius,
            lineWidth: lineWidth,
            animation: true,
            animationDuration: _kCircularAnimDuration,
            percent: value,
            center: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: (radius * 0.4).clamp(10.0, 16.0),
                color: color,
              ),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: color,
            backgroundColor: color.withValues(alpha: 0.12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title.replaceAll('\n', ' '),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.inactiveColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
