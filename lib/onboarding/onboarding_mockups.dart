import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/app_design.dart';

// ============================================================================
// Shared "product preview" visuals for onboarding.
//
// These are static mockups styled to match the real app widgets (app rows,
// charts, limit cards, focus ring, browser rows) using sample data — not the
// live stateful widgets, which need real controllers/providers wired in.
// ============================================================================

class _MockCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final double width;
  final Color accentColor;
  final EdgeInsets padding;

  const _MockCard({
    required this.child,
    required this.isDark,
    required this.accentColor,
    this.width = 300,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppDesignLegacy.darkSurface : AppDesignLegacy.lightSurface;
    final border = isDark ? AppDesignLegacy.darkBorder : AppDesignLegacy.lightBorder;

    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppDesignLegacy.radiusLg),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.18 : 0.12),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

Color _textPrimary(bool isDark) =>
    isDark ? AppDesignLegacy.darkTextPrimary : AppDesignLegacy.lightTextPrimary;
Color _textSecondary(bool isDark) =>
    isDark ? AppDesignLegacy.darkTextSecondary : AppDesignLegacy.lightTextSecondary;
Color _surfaceSecondary(bool isDark) => isDark
    ? AppDesignLegacy.darkSurfaceSecondary
    : AppDesignLegacy.lightSurfaceSecondary;

Widget _glow(Color accentColor, {double alpha = 0.22}) {
  return Positioned.fill(
    child: IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.3),
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              accentColor.withValues(alpha: alpha),
              Colors.transparent,
            ]),
          ),
        ),
      ),
    ),
  );
}

// ----------------------------------------------------------------------------
// 1. App tracking preview — a mini "Applications" list, like the real tab.
// ----------------------------------------------------------------------------

class AppTrackingMockup extends StatelessWidget {
  final Color accentColor;
  final bool isDark;

  const AppTrackingMockup({super.key, required this.accentColor, required this.isDark});

  static const _rows = [
    (name: 'Xcode', time: '2h 14m', pct: 0.9, color: Color(0xFF60A5FA)),
    (name: 'Slack', time: '58m', pct: 0.4, color: Color(0xFFF472B6)),
    (name: 'Figma', time: '1h 32m', pct: 0.62, color: Color(0xFFA78BFA)),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _glow(accentColor),
        _MockCard(
          isDark: isDark,
          accentColor: accentColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(FluentIcons.app_icon_default, size: 14, color: accentColor),
                  const SizedBox(width: 6),
                  Text('Today',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary(isDark),
                      )),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('4h 44m',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (final row in _rows) ...[
                _AppRow(
                  name: row.name,
                  time: row.time,
                  pct: row.pct,
                  color: row.color,
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AppRow extends StatelessWidget {
  final String name;
  final String time;
  final double pct;
  final Color color;
  final bool isDark;

  const _AppRow({
    required this.name,
    required this.time,
    required this.pct,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(FluentIcons.app_icon_default, size: 13, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary(isDark),
                  )),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 4,
                  child: Stack(
                    children: [
                      Container(color: color.withValues(alpha: 0.15)),
                      FractionallySizedBox(
                        widthFactor: pct,
                        child: Container(color: color),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(time,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textSecondary(isDark),
            )),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// 2. Reports preview — mini line chart + weekly bars, like Reports tab.
// ----------------------------------------------------------------------------

class ReportsMockup extends StatelessWidget {
  final Color accentColor;
  final bool isDark;

  const ReportsMockup({super.key, required this.accentColor, required this.isDark});

  static const _bars = [0.45, 0.7, 0.55, 0.9, 0.65, 0.8, 0.5];
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _glow(accentColor),
        _MockCard(
          isDark: isDark,
          accentColor: accentColor,
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('5h 12m',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary(isDark),
                        letterSpacing: -0.5,
                      )),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        Icon(FluentIcons.up, size: 10, color: const Color(0xFF10B981)),
                        Text(' 12% vs last week',
                            style: TextStyle(
                              fontSize: 10,
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Weekly average',
                  style: TextStyle(fontSize: 11, color: _textSecondary(isDark))),
              const SizedBox(height: 16),
              SizedBox(
                height: 90,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_bars.length, (i) {
                    final isMax = _bars[i] == _bars.reduce(math.max);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: _bars[i] * 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isMax
                                  ? [accentColor, accentColor.withValues(alpha: 0.7)]
                                  : [
                                      accentColor.withValues(alpha: 0.45),
                                      accentColor.withValues(alpha: 0.25),
                                    ],
                            ),
                            boxShadow: isMax
                                ? [
                                    BoxShadow(
                                      color: accentColor.withValues(alpha: 0.45),
                                      blurRadius: 10,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(_days[i],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isMax ? FontWeight.w700 : FontWeight.w500,
                              color: isMax ? accentColor : _textSecondary(isDark),
                            )),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// 3. Alerts & limits preview — app limit row with progress ring, like the
//    real Alerts & Limits tab.
// ----------------------------------------------------------------------------

class LimitsMockup extends StatelessWidget {
  final Color accentColor;
  final bool isDark;

  const LimitsMockup({super.key, required this.accentColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _glow(accentColor),
        _MockCard(
          isDark: isDark,
          accentColor: accentColor,
          width: 290,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(FluentIcons.ringer, size: 13, color: accentColor),
                  const SizedBox(width: 6),
                  Text('Daily limits',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary(isDark),
                      )),
                ],
              ),
              const SizedBox(height: 14),
              _LimitRow(
                name: 'Social Media',
                used: '1h 42m',
                limit: '2h 00m',
                pct: 0.85,
                color: const Color(0xFFF59E0B),
                isDark: isDark,
                warning: true,
              ),
              const SizedBox(height: 12),
              _LimitRow(
                name: 'Games',
                used: '38m',
                limit: '1h 30m',
                pct: 0.42,
                color: const Color(0xFF10B981),
                isDark: isDark,
                warning: false,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(FluentIcons.warning, size: 13, color: accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Social Media reaches its limit in 18 min',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: _textPrimary(isDark),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LimitRow extends StatelessWidget {
  final String name;
  final String used;
  final String limit;
  final double pct;
  final Color color;
  final bool isDark;
  final bool warning;

  const _LimitRow({
    required this.name,
    required this.used,
    required this.limit,
    required this.pct,
    required this.color,
    required this.isDark,
    required this.warning,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: ProgressRing(
                  value: pct * 100,
                  strokeWidth: 3.5,
                  backgroundColor: color.withValues(alpha: 0.15),
                  activeColor: color,
                ),
              ),
              Text('${(pct * 100).round()}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary(isDark),
                  )),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary(isDark),
                  )),
              Text('$used of $limit',
                  style: TextStyle(fontSize: 10.5, color: _textSecondary(isDark))),
            ],
          ),
        ),
        if (warning) Icon(FluentIcons.warning, size: 14, color: color),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// 4. Focus mode preview — Pomodoro ring with session label.
// ----------------------------------------------------------------------------

class FocusModeMockup extends StatelessWidget {
  final Color accentColor;
  final bool isDark;

  const FocusModeMockup({super.key, required this.accentColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _glow(accentColor, alpha: 0.28),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: ProgressRing(
                      value: 68,
                      strokeWidth: 10,
                      backgroundColor: accentColor.withValues(alpha: 0.12),
                      activeColor: accentColor,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('18:24',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary(isDark),
                            letterSpacing: -0.5,
                          )),
                      const SizedBox(height: 4),
                      Text('FOCUS SESSION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: accentColor,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FocusPill(icon: FluentIcons.blocked, label: '6 apps blocked', accentColor: accentColor, isDark: isDark),
                const SizedBox(width: 8),
                _FocusPill(icon: FluentIcons.music_in_collection, label: 'Rain sounds', accentColor: accentColor, isDark: isDark),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _FocusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final bool isDark;

  const _FocusPill({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _surfaceSecondary(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppDesignLegacy.darkBorder : AppDesignLegacy.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: accentColor),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: _textPrimary(isDark),
              )),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// 5. Browser preview — website rows inside a browser chrome frame.
// ----------------------------------------------------------------------------

class BrowserMockup extends StatelessWidget {
  final Color accentColor;
  final bool isDark;

  const BrowserMockup({super.key, required this.accentColor, required this.isDark});

  static const _sites = [
    (name: 'github.com', time: '1h 20m', pct: 0.8, color: Color(0xFF60A5FA)),
    (name: 'youtube.com', time: '42m', pct: 0.42, color: Color(0xFFEF4444)),
    (name: 'docs.google.com', time: '31m', pct: 0.3, color: Color(0xFFF59E0B)),
  ];

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppDesignLegacy.darkBorder : AppDesignLegacy.lightBorder;

    return Stack(
      alignment: Alignment.center,
      children: [
        _glow(accentColor),
        _MockCard(
          isDark: isDark,
          accentColor: accentColor,
          width: 300,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Browser chrome bar
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: _surfaceSecondary(isDark),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                  border: Border(bottom: BorderSide(color: border)),
                ),
                child: Row(
                  children: [
                    for (final c in const [Color(0xFFFF5F57), Color(0xFFFFBD2E), Color(0xFF28CA42)])
                      Container(
                        margin: const EdgeInsets.only(right: 5),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: c.withValues(alpha: 0.85)),
                      ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: border.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FluentIcons.globe, size: 9, color: _textSecondary(isDark)),
                            const SizedBox(width: 4),
                            Text('scolect.app/dashboard',
                                style: TextStyle(fontSize: 9, color: _textSecondary(isDark))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Top sites today',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary(isDark),
                        )),
                    const SizedBox(height: 10),
                    for (final s in _sites) ...[
                      _AppRow(name: s.name, time: s.time, pct: s.pct, color: s.color, isDark: isDark),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// 6. Welcome / stat summary preview — big number + mini spark for slide one.
// ----------------------------------------------------------------------------

class WelcomeMockup extends StatelessWidget {
  final Color accentColor;
  final bool isDark;

  const WelcomeMockup({super.key, required this.accentColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _glow(accentColor, alpha: 0.28),
        _MockCard(
          isDark: isDark,
          accentColor: accentColor,
          width: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withValues(alpha: 0.65)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(FluentIcons.clock, size: 15, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scolect',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary(isDark),
                          )),
                      Text('Screen time, understood',
                          style: TextStyle(fontSize: 10, color: _textSecondary(isDark))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('3h 47m',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary(isDark),
                    letterSpacing: -0.5,
                  )),
              Text('tracked so far today',
                  style: TextStyle(fontSize: 11, color: _textSecondary(isDark))),
              const SizedBox(height: 14),
              SizedBox(
                height: 36,
                child: CustomPaint(
                  size: const Size(double.infinity, 36),
                  painter: _SparklinePainter(color: accentColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final Color color;
  const _SparklinePainter({required this.color});

  static const _values = [0.3, 0.45, 0.35, 0.6, 0.5, 0.75, 0.65, 0.9, 0.8];

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final stepX = size.width / (_values.length - 1);
    for (var i = 0; i < _values.length; i++) {
      final x = i * stepX;
      final y = size.height - (_values[i] * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [color.withValues(alpha: 0.25), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) => oldDelegate.color != color;
}

// ----------------------------------------------------------------------------
// 7. Sync preview — desktop + browser nodes joined by an animated-looking arc.
// ----------------------------------------------------------------------------

class SyncMockup extends StatelessWidget {
  final Color accentColor;
  final bool isDark;

  const SyncMockup({super.key, required this.accentColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _glow(accentColor),
        SizedBox(
          width: 260,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(child: CustomPaint(painter: _ArcPainter(color: accentColor))),
              Positioned(left: 6, child: _SyncNode(icon: FluentIcons.devices2, label: 'Desktop', accentColor: accentColor, isDark: isDark)),
              Positioned(right: 6, child: _SyncNode(icon: FluentIcons.globe, label: 'Browser', accentColor: accentColor, isDark: isDark)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SyncNode extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final bool isDark;

  const _SyncNode({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [accentColor, accentColor.withValues(alpha: 0.65)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: accentColor.withValues(alpha: 0.45), blurRadius: 22, spreadRadius: 2),
            ],
          ),
          child: Icon(icon, size: 26, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  const _ArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final midX = size.width / 2;
    final midY = size.height / 2 - 10;
    path.moveTo(72, midY + 4);
    path.cubicTo(
      midX - 24, midY - 26,
      midX + 24, midY - 26,
      size.width - 72, midY + 4,
    );
    canvas.drawPath(path, paint);

    final arrowPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rx = size.width - 72.0;
    canvas.drawLine(Offset(rx - 8, midY + 4 - 5), Offset(rx, midY + 4), arrowPaint);
    canvas.drawLine(Offset(rx - 8, midY + 4 + 5), Offset(rx, midY + 4), arrowPaint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.color != color;
}

// ----------------------------------------------------------------------------
// 8. Privacy preview — shield with a "100% local" badge.
// ----------------------------------------------------------------------------

class PrivacyMockup extends StatelessWidget {
  final Color accentColor;
  final bool isDark;

  const PrivacyMockup({super.key, required this.accentColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _glow(accentColor, alpha: 0.3),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 130,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(110, 128),
                    painter: _ShieldPainter(color: accentColor),
                  ),
                  const Positioned(
                    top: 36,
                    child: Icon(FluentIcons.lock, size: 34, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _surfaceSecondary(isDark),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppDesignLegacy.darkBorder : AppDesignLegacy.lightBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FluentIcons.completed_solid, size: 12, color: const Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  Text('100% stored on-device',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary(isDark),
                      )),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ShieldPainter extends CustomPainter {
  final Color color;
  const _ShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      colors: [color, color.withValues(alpha: 0.6)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.55);
    path.cubicTo(
      size.width, size.height * 0.8,
      size.width / 2, size.height,
      size.width / 2, size.height,
    );
    path.cubicTo(
      size.width / 2, size.height,
      0, size.height * 0.8,
      0, size.height * 0.55,
    );
    path.lineTo(0, size.height * 0.2);
    path.close();

    canvas.drawShadow(path, color.withValues(alpha: 0.5), 14, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ShieldPainter old) => old.color != color;
}

// ----------------------------------------------------------------------------
// 9. Ready / rocket preview — checklist card confirming setup is complete.
// ----------------------------------------------------------------------------

class ReadyMockup extends StatelessWidget {
  final Color accentColor;
  final bool isDark;
  final List<String> items;

  const ReadyMockup({
    super.key,
    required this.accentColor,
    required this.isDark,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _glow(accentColor, alpha: 0.3),
        _MockCard(
          isDark: isDark,
          accentColor: accentColor,
          width: 270,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withValues(alpha: 0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(color: accentColor.withValues(alpha: 0.5), blurRadius: 16),
                      ],
                    ),
                    child: const Icon(FluentIcons.rocket, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text("You're ready",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary(isDark),
                      )),
                ],
              ),
              const SizedBox(height: 14),
              for (final item in items) ...[
                Row(
                  children: [
                    Icon(FluentIcons.completed_solid, size: 14, color: const Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _textPrimary(isDark),
                          )),
                    ),
                  ],
                ),
                if (item != items.last) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
