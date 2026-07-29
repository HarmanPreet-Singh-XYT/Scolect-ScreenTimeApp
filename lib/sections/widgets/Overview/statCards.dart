import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const _kHoverDuration = Duration(milliseconds: 200);
const _kCompactBreakpoint = 600.0;
const _kVeryCompactBreakpoint = 400.0;

const _kWhite80 = Color.fromRGBO(255, 255, 255, 0.8);
const _kWhite90 = Color.fromRGBO(255, 255, 255, 0.9);

const _kGradientBlue = LinearGradient(
  colors: [Color(0xff1E3A8A), Color(0xff3B82F6)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const _kGradientGreen = LinearGradient(
  colors: [Color(0xff14532D), Color(0xff22C55E)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const _kGradientPurple = LinearGradient(
  colors: [Color(0xff581C87), Color(0xffA855F7)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const _kGradientOrange = LinearGradient(
  colors: [Color(0xff7C2D12), Color(0xffF97316)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Pre-built transforms to avoid allocating Matrix4 every build
final _kTransformIdle = Matrix4.identity();
final _kTransformHovered = Matrix4.identity()..setTranslationRaw(0, -2, 0);

// ─── Card Config (data object, no widget overhead) ──────────────────────────

class _CardConfig {
  final IconData icon;
  final String title;
  final String value;
  final LinearGradient gradient;
  final bool isText;

  const _CardConfig({
    required this.icon,
    required this.title,
    required this.value,
    required this.gradient,
    this.isText = false,
  });
}

// ─── StatsCards ─────────────────────────────────────────────────────────────

class StatsCards extends StatelessWidget {
  final String totalScreenTime;
  final String totalProductiveTime;
  final String mostUsedApp;
  final String focusSessions;

  const StatsCards({
    super.key,
    required this.totalScreenTime,
    required this.totalProductiveTime,
    required this.mostUsedApp,
    required this.focusSessions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Config list built once per build — lightweight data objects, not widgets
    final configs = [
      _CardConfig(
        icon: FluentIcons.timer,
        title: l10n.totalScreenTime,
        value: totalScreenTime,
        gradient: _kGradientBlue,
      ),
      _CardConfig(
        icon: FluentIcons.check_mark,
        title: l10n.productiveTime,
        value: totalProductiveTime,
        gradient: _kGradientGreen,
      ),
      _CardConfig(
        icon: FluentIcons.app_icon_default_list,
        title: l10n.mostUsedApp,
        value: mostUsedApp,
        gradient: _kGradientPurple,
        isText: true,
      ),
      _CardConfig(
        icon: FluentIcons.focus,
        title: l10n.focusSessions,
        value: focusSessions,
        gradient: _kGradientOrange,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isVeryCompact = width < _kVeryCompactBreakpoint;
        final isCompact = width < _kCompactBreakpoint;
        final cardHeight = isVeryCompact ? 85.0 : (isCompact ? 95.0 : 110.0);

        if (isCompact) {
          return _CompactGrid(
            configs: configs,
            cardHeight: cardHeight,
            isVeryCompact: isVeryCompact,
          );
        }

        return _ExpandedRow(
          configs: configs,
          cardHeight: cardHeight,
        );
      },
    );
  }
}

// ─── Layout Widgets (extracted to limit rebuild scope) ──────────────────────

class _CompactGrid extends StatelessWidget {
  final List<_CardConfig> configs;
  final double cardHeight;
  final bool isVeryCompact;

  const _CompactGrid({
    required this.configs,
    required this.cardHeight,
    required this.isVeryCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Expanded(
              child: _StatCard(
                  config: configs[0],
                  height: cardHeight,
                  isCompact: isVeryCompact)),
          const SizedBox(width: 10),
          Expanded(
              child: _StatCard(
                  config: configs[1],
                  height: cardHeight,
                  isCompact: isVeryCompact)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _StatCard(
                  config: configs[2],
                  height: cardHeight,
                  isCompact: isVeryCompact)),
          const SizedBox(width: 10),
          Expanded(
              child: _StatCard(
                  config: configs[3],
                  height: cardHeight,
                  isCompact: isVeryCompact)),
        ]),
      ],
    );
  }
}

class _ExpandedRow extends StatelessWidget {
  final List<_CardConfig> configs;
  final double cardHeight;

  const _ExpandedRow({
    required this.configs,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < configs.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              config: configs[i],
              height: cardHeight,
              isCompact: false,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── StatCard (single widget, config-driven) ────────────────────────────────

class _StatCard extends StatefulWidget {
  final _CardConfig config;
  final double height;
  final bool isCompact;

  const _StatCard({
    required this.config,
    required this.height,
    required this.isCompact,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    final compact = widget.isCompact;

    final padding = compact ? 12.0 : 16.0;
    final iconSize = compact ? 12.0 : 14.0;
    final titleSize = compact ? 10.0 : 12.0;
    final valueSize = c.isText
        ? (c.value.length > 12 ? 14.0 : 18.0)
        : (compact ? 22.0 : 26.0);

    final shadowColor = c.gradient.colors.first;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: _kHoverDuration,
        height: widget.height,
        transformAlignment: Alignment.center,
        transform: _isHovered ? _kTransformHovered : _kTransformIdle,
        decoration: BoxDecoration(
          gradient: c.gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: _isHovered ? 0.4 : 0.2),
              blurRadius: _isHovered ? 16 : 8,
              offset: _isHovered ? const Offset(0, 6) : const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(c.icon, size: iconSize, color: _kWhite80),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      c.title,
                      style: TextStyle(
                        color: _kWhite90,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  c.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: valueSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: c.isText ? 0 : -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: c.isText ? 2 : 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
