import 'package:auto_updater/auto_updater.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/settings.dart';
import 'package:screentime/sections/UI%20sections/Settings/reusables.dart';
import 'package:screentime/utils/update_service.dart';
import 'package:screentime/sections/UI%20sections/Overview/changelog.dart';
import 'package:screentime/main.dart' show autoUpdates;

// ============== ABOUT SECTION ==============

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  String _lastCheckText = '';

  @override
  void initState() {
    super.initState();
    if (autoUpdates) _refreshLastCheck();
  }

  Future<void> _refreshLastCheck() async {
    final text = await UpdateService().getLastCheckText();
    if (mounted) setState(() => _lastCheckText = text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final version = context.select<SettingsProvider, Map<String, dynamic>>(
      (s) => s.appVersion,
    );
    final changelogLabel = l10n.changelog;

    if (!autoUpdates) {
      return SettingsCard(
        title: l10n.versionSection,
        icon: FluentIcons.info,
        iconColor: Colors.grey,
        children: [
          _AppInfoTile(version: version),
          const SizedBox(height: 12),
          _OutlineIconButton(
            icon: FluentIcons.history,
            label: changelogLabel,
            onPressed: () => ChangelogModal.showManually(context),
          ),
        ],
      );
    }

    return Consumer<UpdateService>(
      builder: (context, updater, child) {
        final isChecking = updater.status == UpdateStatus.checking;

        return SettingsCard(
          title: l10n.versionSection,
          icon: FluentIcons.info,
          iconColor: Colors.grey,
          children: [
            _AppInfoTile(version: version),
            const SizedBox(height: 12),
            _UpdateBanner(updater: updater, lastCheckText: _lastCheckText),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _OutlineIconButton(
                    icon: FluentIcons.history,
                    label: changelogLabel,
                    onPressed: () => ChangelogModal.showManually(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _OutlineIconButton(
                    icon: FluentIcons.sync,
                    label: isChecking ? 'Checking...' : 'Check Updates',
                    isLoading: isChecking,
                    onPressed: isChecking
                        ? null
                        : () async {
                            await Future.wait([
                              updater.checkForUpdates(),
                              autoUpdater.checkForUpdates(),
                            ]);
                            _refreshLastCheck();
                          },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Info Tile
// ─────────────────────────────────────────────────────────────────────────────

class _AppInfoTile extends StatelessWidget {
  final Map<String, dynamic> version;
  const _AppInfoTile({required this.version});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accent = theme.accentColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.05),
            accent.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: _kBorderRadius8,
        border: Border.all(color: accent.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: _kBorderRadius8,
            ),
            child: Image.asset(
              'assets/icons/tray_icon_windows.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scolect',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.versionDescription,
                  style: TextStyle(fontSize: 11, color: Colors.grey[100]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'v${version["version"]}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${version["type"]}',
                style: TextStyle(fontSize: 10, color: Colors.grey[100]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Update Banner
// ─────────────────────────────────────────────────────────────────────────────

class _UpdateBanner extends StatelessWidget {
  final UpdateService updater;
  final String lastCheckText;

  const _UpdateBanner({required this.updater, required this.lastCheckText});

  String? _lastCheckSublabel() =>
      lastCheckText.isEmpty ? null : 'Last checked $lastCheckText';

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _kAnimDuration300,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: _kSlideOffset.animate(animation),
          child: child,
        ),
      ),
      child: switch (updater.status) {
        UpdateStatus.updateAvailable => _UpdateAvailableBanner(
            key: const ValueKey('available'),
            update: updater.availableUpdate!,
          ),
        UpdateStatus.checking => const _StatusBanner(
            key: ValueKey('checking'),
            icon: null,
            isLoading: true,
            label: 'Checking for updates...',
            sublabel: null,
            color: Colors.grey,
          ),
        UpdateStatus.upToDate => _StatusBanner(
            key: const ValueKey('upToDate'),
            icon: FluentIcons.skype_circle_check,
            label: "You're up to date",
            sublabel: _lastCheckSublabel(),
            color: Colors.successPrimaryColor,
          ),
        UpdateStatus.error => const _StatusBanner(
            key: ValueKey('error'),
            icon: FluentIcons.error_badge,
            label: 'Could not check for updates',
            sublabel: 'Tap "Check Updates" to retry',
            color: Colors.warningPrimaryColor,
          ),
        UpdateStatus.idle => _StatusBanner(
            key: const ValueKey('idle'),
            icon: FluentIcons.clock,
            label: 'Update check scheduled',
            sublabel: _lastCheckSublabel(),
            color: Colors.grey,
          ),
      },
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? sublabel;
  final Color color;
  final bool isLoading;

  const _StatusBanner({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.sublabel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: _kBorderRadius8,
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: ProgressRing(strokeWidth: 2, activeColor: color),
            )
          else
            Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                if (sublabel != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    sublabel!,
                    style: TextStyle(
                      fontSize: 10,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Update Available Banner
// ─────────────────────────────────────────────────────────────────────────────

class _UpdateAvailableBanner extends StatefulWidget {
  final UpdateInfo update;
  const _UpdateAvailableBanner({super.key, required this.update});

  @override
  State<_UpdateAvailableBanner> createState() => _UpdateAvailableBannerState();
}

class _UpdateAvailableBannerState extends State<_UpdateAvailableBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.04, end: 0.14).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final accent = theme.accentColor;
    final update = widget.update;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: _pulseAnim.value),
          borderRadius: _kBorderRadius8,
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: child,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PulseDot(color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Available — ${update.tagName}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                    if (update.name.isNotEmpty)
                      Text(
                        update.name,
                        style: TextStyle(
                          fontSize: 10,
                          color: accent.withValues(alpha: 0.75),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(accent),
                ),
                onPressed: () => autoUpdater.checkForUpdates(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FluentIcons.install_to_drive,
                          size: 12, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Update Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (update.body.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ChangelogPreview(body: update.body),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pulse Dot
// ─────────────────────────────────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _ring = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ring,
            builder: (_, __) => Opacity(
              opacity: (1 - _ring.value).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.5 + _ring.value * 1.2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.color, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Changelog Preview
// ─────────────────────────────────────────────────────────────────────────────

class _ChangelogPreview extends StatefulWidget {
  final String body;
  const _ChangelogPreview({required this.body});

  @override
  State<_ChangelogPreview> createState() => _ChangelogPreviewState();
}

class _ChangelogPreviewState extends State<_ChangelogPreview> {
  bool _expanded = false;
  static const _maxPreviewLines = 3;
  static final _bulletPattern = RegExp(r'^[-•*]');

  late final List<String> _bullets = widget.body
      .split('\n')
      .map((l) => l.trim())
      .where((l) => _bulletPattern.hasMatch(l))
      .map((l) => l.substring(1).trim())
      .where((l) => l.isNotEmpty)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    if (_bullets.isEmpty) return const SizedBox.shrink();

    final theme = FluentTheme.of(context);
    final accent = theme.accentColor;
    final display =
        _expanded ? _bullets : _bullets.take(_maxPreviewLines).toList();
    final hasMore = _bullets.length > _maxPreviewLines;
    final bodyColor = theme.typography.body?.color?.withValues(alpha: 0.85);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's new:",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: accent.withValues(alpha: 0.8),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          for (final line in display)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5, right: 7),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      line,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: bodyColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (hasMore) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded
                    ? 'Show less'
                    : '+ ${_bullets.length - _maxPreviewLines} more changes',
                style: TextStyle(
                  fontSize: 10,
                  color: accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Outline Icon Button
// ─────────────────────────────────────────────────────────────────────────────

class _OutlineIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _OutlineIconButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = FluentTheme.of(context).accentColor;

    return Button(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            side: BorderSide(color: accent.withValues(alpha: 0.2)),
            borderRadius: _kBorderRadius8,
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: 12,
              height: 12,
              child: ProgressRing(strokeWidth: 1.5, activeColor: accent),
            )
          else
            Icon(icon, size: 13, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: onPressed == null ? Colors.grey : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kAnimDuration300 = Duration(milliseconds: 300);

final _kBorderRadius8 = BorderRadius.circular(8);

final _kSlideOffset = Tween<Offset>(
  begin: const Offset(0, 0.08),
  end: Offset.zero,
);
