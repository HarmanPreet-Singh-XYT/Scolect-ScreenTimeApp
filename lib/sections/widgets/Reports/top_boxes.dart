import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import '../../controller/data_controllers/reports_controller.dart';

// ==================== TOP-LEVEL WIDGET ====================

class TopBoxes extends StatelessWidget {
  final AnalyticsSummary analyticsSummary;
  final bool isLoading;

  const TopBoxes({
    super.key,
    required this.analyticsSummary,
    this.isLoading = false,
  });

  static const _colors = (
    indigo: Color(0xFF6366F1),
    emerald: Color(0xFF10B981),
    amber: Color(0xFFF59E0B),
    pink: Color(0xFFEC4899),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = analyticsSummary;

    final items = [
      _AnalyticsItem(
        title: l10n.totalScreenTime,
        value: _formatDuration(s.totalScreenTime),
        percentChange: s.screenTimeComparisonPercent,
        icon: FluentIcons.screen_time,
        accentColor: _colors.indigo,
      ),
      _AnalyticsItem(
        title: l10n.productiveTime,
        value: _formatDuration(s.productiveTime),
        percentChange: s.productiveTimeComparisonPercent,
        icon: FluentIcons.timer,
        accentColor: _colors.emerald,
      ),
      _AnalyticsItem(
        title: l10n.mostUsedApp,
        value: s.mostUsedApp,
        subValue: _formatDuration(s.mostUsedAppTime),
        icon: FluentIcons.account_browser,
        accentColor: _colors.amber,
      ),
      _AnalyticsItem(
        title: l10n.focusSessions,
        value: s.focusSessionsCount.toString(),
        percentChange: s.focusSessionsComparisonPercent,
        icon: FluentIcons.red_eye,
        accentColor: _colors.pink,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isCompact ? 2 : 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isCompact ? 1.6 : 1.8,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _AnalyticsCard(
              item: items[index],
              isLoading: isLoading,
              index: index,
            );
          },
        );
      },
    );
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }
}

// ==================== DATA CLASS ====================

class _AnalyticsItem {
  final String title;
  final String value;
  final double? percentChange;
  final String? subValue;
  final IconData icon;
  final Color accentColor;

  const _AnalyticsItem({
    required this.title,
    required this.value,
    this.percentChange,
    this.subValue,
    required this.icon,
    required this.accentColor,
  });
}

// ==================== CARD WIDGET ====================

class _AnalyticsCard extends StatefulWidget {
  final _AnalyticsItem item;
  final bool isLoading;
  final int index;

  const _AnalyticsCard({
    required this.item,
    required this.isLoading,
    required this.index,
  });

  @override
  State<_AnalyticsCard> createState() => _AnalyticsCardState();
}

class _AnalyticsCardState extends State<_AnalyticsCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  static const _entranceDuration = Duration(milliseconds: 600);
  static const _hoverDuration = Duration(milliseconds: 200);
  static const _staggerDelay = Duration(milliseconds: 100);
  static final _identityMatrix = Matrix4.identity();
  static final _hoverMatrix = Matrix4.identity()..translate(0.0, -2.0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _entranceDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(_staggerDelay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setHovered(bool value) {
    if (_isHovered != value) setState(() => _isHovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _showDetailsFlyout(context),
          child: AnimatedContainer(
            duration: _hoverDuration,
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(16),
            decoration: _buildDecoration(theme, isDark),
            transform: _isHovered ? _hoverMatrix : _identityMatrix,
            child: widget.isLoading
                ? const _ShimmerPlaceholder()
                : _CardContent(item: widget.item, isHovered: _isHovered),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(FluentThemeData theme, bool isDark) {
    final accent = widget.item.accentColor;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withValues(alpha: isDark ? 0.08 : 0.04),
          isDark ? theme.micaBackgroundColor : Colors.white,
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: _isHovered
            ? accent.withValues(alpha: 0.5)
            : theme.inactiveBackgroundColor.withValues(alpha: 0.5),
        width: _isHovered ? 1.5 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: _isHovered
              ? accent.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.05),
          blurRadius: _isHovered ? 20 : 10,
          offset: Offset(0, _isHovered ? 8 : 4),
        ),
      ],
    );
  }

  void _showDetailsFlyout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: Text(widget.item.title),
          content: Text(l10n.valueLabel(widget.item.value)),
          severity: InfoBarSeverity.info,
          isLong: false,
        );
      },
    );
  }
}

// ==================== CARD CONTENT (STATELESS) ====================

class _CardContent extends StatelessWidget {
  final _AnalyticsItem item;
  final bool isHovered;

  const _CardContent({required this.item, required this.isHovered});

  static const _positiveColor = Color(0xFF10B981);
  static const _negativeColor = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      theme.typography.caption?.color?.withValues(alpha: 0.7),
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            _IconBadge(
              icon: item.icon,
              color: item.accentColor,
              isHovered: isHovered,
            ),
          ],
        ),

        const Spacer(),

        // Value
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: isHovered ? 26 : 24,
            fontWeight: FontWeight.w700,
            color: theme.typography.title?.color,
            letterSpacing: -0.5,
          ),
          child: Text(
            item.value,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),

        const SizedBox(height: 6),

        // Footer
        _buildFooter(theme),
      ],
    );
  }

  Widget _buildFooter(FluentThemeData theme) {
    final percent = item.percentChange;
    if (percent != null) {
      final isPositive = percent >= 0;
      final color = isPositive ? _positiveColor : _negativeColor;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPositive ? FluentIcons.trending12 : FluentIcons.stock_down,
              size: 12,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              '${isPositive ? '+' : ''}${percent.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    final sub = item.subValue;
    if (sub != null) {
      return Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: item.accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              sub,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.typography.caption?.color?.withValues(alpha: 0.6),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return const SizedBox(height: 16);
  }
}

// ==================== ICON BADGE (STATELESS) ====================

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isHovered;

  const _IconBadge({
    required this.icon,
    required this.color,
    required this.isHovered,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isHovered ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

// ==================== SHIMMER PLACEHOLDER (STATELESS) ====================

class _ShimmerPlaceholder extends StatelessWidget {
  const _ShimmerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _shimmerBox(width: 80, height: 12, radius: 4),
              _shimmerBox(width: 34, height: 34, radius: 10),
            ],
          ),
          const Spacer(),
          _shimmerBox(width: 100, height: 24, radius: 6),
          const SizedBox(height: 8),
          _shimmerBox(width: 60, height: 16, radius: 4),
        ],
      ),
    );
  }

  static Widget _shimmerBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ==================== SHIMMER ANIMATION ====================

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _duration = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _duration, vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? [Colors.grey[800], Colors.grey[700], Colors.grey[800]]
        : [Colors.grey[300], Colors.grey[100], Colors.grey[300]];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final v = _controller.value;
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: colors,
              stops: [
                (v - 0.3).clamp(0.0, 1.0),
                v.clamp(0.0, 1.0),
                (v + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
