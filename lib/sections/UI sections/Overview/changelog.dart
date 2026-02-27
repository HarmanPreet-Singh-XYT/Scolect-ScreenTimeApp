import 'dart:convert';
import 'dart:math';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const _kPrefsKey = 'last_shown_changelog_version';
const _kFetchTimeout = Duration(seconds: 10);
const _kEntranceDuration = Duration(milliseconds: 400);
const _kContentDuration = Duration(milliseconds: 600);
const _kShimmerDuration = Duration(milliseconds: 2000);
const _kScrollThreshold = 150.0;
const _kDialogConstraints = BoxConstraints(maxWidth: 620, maxHeight: 720);
const _kLoadingConstraints = BoxConstraints(maxWidth: 300);
const _kRepoUrl =
    'https://api.github.com/repos/HarmanPreet-Singh-XYT/Scolect-ScreenTimeApp/releases/tags/';

// Pre-compiled regex — avoids recompilation per call
final _kBoldRegex = RegExp(r'\*\*(.*?)\*\*');

// ─── Parsed line types ──────────────────────────────────────────────────────

enum _LineType { header, subheader, bullet, text }

class _ParsedLine {
  final _LineType type;
  final String text;
  const _ParsedLine(this.type, this.text);
}

// ─── Release data — typed instead of Map<String, dynamic> ───────────────────

class _ReleaseData {
  final String tagName;
  final String name;
  final String body;
  final String? publishedAt;

  const _ReleaseData({
    required this.tagName,
    required this.name,
    required this.body,
    this.publishedAt,
  });

  factory _ReleaseData.fromJson(Map<String, dynamic> json) => _ReleaseData(
        tagName: json['tag_name'] ?? '',
        name: json['name'] ?? '',
        body: json['body'] ?? '',
        publishedAt: json['published_at'],
      );
}

// ─── ChangelogModal (public API) ────────────────────────────────────────────

class ChangelogModal {
  ChangelogModal._(); // prevent instantiation

  static Future<void> showIfNeeded(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentVersion =
          SettingsManager().versionInfo['version'] ?? 'unknown';
      final lastShown = prefs.getString(_kPrefsKey);

      if (lastShown == currentVersion) return;

      final release = await _fetchRelease(currentVersion);
      if (release != null && context.mounted) {
        await _showChangelogDialog(context, release);
        await prefs.setString(_kPrefsKey, currentVersion);
      }
    } catch (e) {
      debugPrint('❌ Changelog Error: $e');
    }
  }

  static Future<void> showManually(BuildContext context) async {
    try {
      final currentVersion =
          SettingsManager().versionInfo['version'] ?? 'unknown';

      if (context.mounted) _showLoadingDialog(context);

      final release = await _fetchRelease(currentVersion);

      if (context.mounted) Navigator.of(context).pop();

      if (release != null && context.mounted) {
        await _showChangelogDialog(context, release);
      } else if (context.mounted) {
        await _showErrorDialog(context);
      }
    } catch (e) {
      debugPrint('Error showing changelog manually: $e');
      if (context.mounted) {
        Navigator.of(context).pop();
        await _showErrorDialog(context);
      }
    }
  }

  static Future<void> resetShownVersion() async {
    (await SharedPreferences.getInstance()).remove(_kPrefsKey);
  }

  static Future<String?> getLastShownVersion() async {
    return (await SharedPreferences.getInstance()).getString(_kPrefsKey);
  }

  // ─── Private helpers ────────────────────────────────────────────────────

  static Future<_ReleaseData?> _fetchRelease(String version) async {
    try {
      final tag = version.startsWith('v') ? version : 'v$version';
      final response =
          await http.get(Uri.parse('$_kRepoUrl$tag')).timeout(_kFetchTimeout);

      if (response.statusCode == 200) {
        return _ReleaseData.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching release data: $e');
      return null;
    }
  }

  static void _showLoadingDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ContentDialog(
        constraints: _kLoadingConstraints,
        content: Row(
          children: [
            const ProgressRing(),
            const SizedBox(width: 16),
            Text(l10n.changelogUnableToLoad),
          ],
        ),
      ),
    );
  }

  static Future<void> _showChangelogDialog(
    BuildContext context,
    _ReleaseData release,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ChangelogDialog(release: release),
    );
  }

  static Future<void> _showErrorDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      builder: (_) => ContentDialog(
        title: Row(
          children: [
            const Icon(
              FluentIcons.error_badge,
              color: Colors.warningPrimaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(l10n.changelogUnableToLoad),
          ],
        ),
        content: Text(l10n.changelogErrorDescription),
        actions: [
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(l10n.ok),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Changelog Dialog ───────────────────────────────────────────────────────

class _ChangelogDialog extends StatefulWidget {
  final _ReleaseData release;
  const _ChangelogDialog({required this.release});

  @override
  State<_ChangelogDialog> createState() => _ChangelogDialogState();
}

class _ChangelogDialogState extends State<_ChangelogDialog>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _contentCtrl;
  late final AnimationController _shimmerCtrl;

  late final Animation<double> _scaleTween;
  late final Animation<double> _fadeTween;
  late final Animation<Offset> _slideTween;
  late final Animation<double> _contentFade;

  final _scrollCtrl = ScrollController();
  bool _showScrollTop = false;

  // Parse lines once, not on every build
  late final List<_ParsedLine> _parsedLines;

  @override
  void initState() {
    super.initState();

    _parsedLines = _parseBody(widget.release.body);

    _entranceCtrl =
        AnimationController(vsync: this, duration: _kEntranceDuration);
    _contentCtrl =
        AnimationController(vsync: this, duration: _kContentDuration);
    _shimmerCtrl =
        AnimationController(vsync: this, duration: _kShimmerDuration);

    _scaleTween = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutBack),
    );
    _fadeTween = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideTween = Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic),
    );
    _contentFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut),
    );

    _entranceCtrl.forward().then((_) {
      _contentCtrl.forward();
      _shimmerCtrl.repeat();
    });

    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final show = _scrollCtrl.offset > _kScrollThreshold;
    if (show != _showScrollTop) setState(() => _showScrollTop = show);
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _contentCtrl.dispose();
    _shimmerCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _entranceCtrl.reverse();
    if (mounted) Navigator.of(context).pop();
  }

  // ─── Parse markdown body once ───────────────────────────────────────────

  static List<_ParsedLine> _parseBody(String body) {
    if (body.isEmpty) return const [];

    final lines = body.split('\n');
    final result = <_ParsedLine>[];
    result.length; // hint capacity not needed — list is small

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('##')) {
        result.add(
            _ParsedLine(_LineType.subheader, line.replaceAll('#', '').trim()));
      } else if (line.startsWith('#')) {
        result.add(
            _ParsedLine(_LineType.header, line.replaceAll('#', '').trim()));
      } else if (line.startsWith('-') ||
          line.startsWith('•') ||
          line.startsWith('*')) {
        result.add(_ParsedLine(_LineType.bullet, line.substring(1).trim()));
      } else {
        result.add(_ParsedLine(_LineType.text, line));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return AnimatedBuilder(
      animation: _entranceCtrl,
      builder: (context, child) => FadeTransition(
        opacity: _fadeTween,
        child: SlideTransition(
          position: _slideTween,
          child: ScaleTransition(scale: _scaleTween, child: child),
        ),
      ),
      child: ContentDialog(
        constraints: _kDialogConstraints,
        title: _ShimmerHeader(
          release: widget.release,
          shimmerCtrl: _shimmerCtrl,
        ),
        content: Stack(
          children: [
            FadeTransition(
              opacity: _contentFade,
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.release.publishedAt != null)
                      _ReleaseDateBadge(
                        publishedAt: widget.release.publishedAt!,
                        contentCtrl: _contentCtrl,
                      ),
                    const SizedBox(height: 16),
                    if (_parsedLines.isEmpty)
                      Text(l10n.changelogNoContent)
                    else
                      _StaggeredContent(
                        lines: _parsedLines,
                        contentCtrl: _contentCtrl,
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _ScrollTopButton(
              visible: _showScrollTop,
              scrollCtrl: _scrollCtrl,
              accentColor: theme.accentColor,
            ),
          ],
        ),
        actions: [
          _FadeScaleButton(
            contentCtrl: _contentCtrl,
            onPressed: _dismiss,
            label: l10n.continueButton,
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer Header ─────────────────────────────────────────────────────────

class _ShimmerHeader extends StatelessWidget {
  final _ReleaseData release;
  final AnimationController shimmerCtrl;

  const _ShimmerHeader({required this.release, required this.shimmerCtrl});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final accent = theme.accentColor;

    return Row(
      children: [
        AnimatedBuilder(
          animation: shimmerCtrl,
          builder: (_, __) => Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: SweepGradient(
                transform: GradientRotation(shimmerCtrl.value * 2 * pi),
                colors: [
                  accent.withValues(alpha: 0.08),
                  accent.withValues(alpha: 0.2),
                  accent.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accent.withValues(alpha: 0.15),
              ),
            ),
            child: Icon(FluentIcons.rocket, color: accent, size: 24),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.changelogWhatsNew,
                style: theme.typography.subtitle?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      release.tagName,
                      style: TextStyle(
                        fontSize: 11,
                        color: accent,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      release.name,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.inactiveColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Release Date Badge ─────────────────────────────────────────────────────

class _ReleaseDateBadge extends StatelessWidget {
  final String publishedAt;
  final AnimationController contentCtrl;

  const _ReleaseDateBadge(
      {required this.publishedAt, required this.contentCtrl});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final accent = theme.accentColor;

    final date = DateTime.parse(publishedAt);
    final formatted = '${date.day}/${date.month}/${date.year}';

    final curve = CurvedAnimation(
      parent: contentCtrl,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    return SlideTransition(
      position:
          Tween(begin: const Offset(-0.1, 0), end: Offset.zero).animate(curve),
      child: FadeTransition(
        opacity: Tween(begin: 0.0, end: 1.0).animate(curve),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accent.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.calendar, size: 14, color: accent),
              const SizedBox(width: 8),
              Text(
                l10n.changelogReleasedOn(formatted),
                style: TextStyle(
                  fontSize: 12,
                  color: accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Staggered Content Lines ────────────────────────────────────────────────

class _StaggeredContent extends StatelessWidget {
  final List<_ParsedLine> lines;
  final AnimationController contentCtrl;

  const _StaggeredContent({required this.lines, required this.contentCtrl});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final count = lines.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(count, (i) {
        final start = (0.15 + (i / count) * 0.7).clamp(0.0, 1.0);
        final end = (start + 0.3).clamp(0.0, 1.0);
        final interval = Interval(start, end, curve: Curves.easeOut);
        final slideInterval = Interval(start, end, curve: Curves.easeOutCubic);

        return SlideTransition(
          position: Tween(begin: const Offset(0, 0.15), end: Offset.zero)
              .animate(
                  CurvedAnimation(parent: contentCtrl, curve: slideInterval)),
          child: FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(parent: contentCtrl, curve: interval)),
            child: _buildLine(theme, lines[i]),
          ),
        );
      }),
    );
  }

  static String _stripBold(String text) => text.replaceAll(_kBoldRegex, r'\$1');

  static Widget _buildLine(FluentThemeData theme, _ParsedLine line) {
    return switch (line.type) {
      _LineType.header => Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.text,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: theme.accentColor,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: 40,
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      _LineType.subheader => Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            line.text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.typography.body?.color?.withValues(alpha: 0.85),
            ),
          ),
        ),
      _LineType.bullet => Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, right: 10),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.accentColor,
                      theme.accentColor.withValues(alpha: 0.6),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  _stripBold(line.text),
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
            ],
          ),
        ),
      _LineType.text => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            _stripBold(line.text),
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
        ),
    };
  }
}

// ─── Scroll-to-Top Button ───────────────────────────────────────────────────

class _ScrollTopButton extends StatelessWidget {
  final bool visible;
  final ScrollController scrollCtrl;
  final Color accentColor;

  const _ScrollTopButton({
    required this.visible,
    required this.scrollCtrl,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 8,
      right: 8,
      child: AnimatedScale(
        scale: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                FluentIcons.chevron_up,
                color: Colors.white,
                size: 14,
              ),
            ),
            onPressed: () => scrollCtrl.animateTo(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Fade + Scale Button ────────────────────────────────────────────────────

class _FadeScaleButton extends StatelessWidget {
  final AnimationController contentCtrl;
  final VoidCallback onPressed;
  final String label;

  const _FadeScaleButton({
    required this.contentCtrl,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final fade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: contentCtrl,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
    final scale = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: contentCtrl,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
      ),
    );

    return AnimatedBuilder(
      animation: contentCtrl,
      builder: (_, child) => Opacity(
        opacity: fade.value,
        child: Transform.scale(scale: scale.value, child: child),
      ),
      child: FilledButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Text(label),
        ),
      ),
    );
  }
}
