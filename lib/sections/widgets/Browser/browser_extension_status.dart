// ─── Tracker-Only Status Screen ───────────────────────────────────────────────
//
// Shown when extension mode is 'trackerOnly'. Displays a live tracking
// indicator, sync status, and a link to switch mode.

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screentime/l10n/app_localizations.dart';
import 'browser_shared.dart';

// Conditionally import Chrome storage interop & ExtensionSettings on web
import '../../../web/chrome_storage_interop.dart'
    if (dart.library.io) '../../../web/chrome_storage_interop_stub.dart';
import '../../../web/extension_settings.dart'
    if (dart.library.io) '../../../web/extension_settings_stub.dart';

class BrowserExtensionStatus extends StatefulWidget {
  final VoidCallback onSwitchToStandalone;
  const BrowserExtensionStatus({super.key, required this.onSwitchToStandalone});

  @override
  State<BrowserExtensionStatus> createState() => _BrowserExtensionStatusState();
}

class _BrowserExtensionStatusState extends State<BrowserExtensionStatus>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  String? _lastSyncText;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    if (!kIsWeb) return;
    try {
      final stateData = await chromeStorageGet(['scolect_app_state']);
      final state = stateData['scolect_app_state'] as Map<String, dynamic>?;
      final settings = ExtensionSettings();
      await settings.load();

      // Read last sync timestamp if available
      final lastSyncAt = state?['lastSyncAt'] as int?;
      String? syncText;
      if (lastSyncAt != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(lastSyncAt);
        final hour = dt.hour.toString().padLeft(2, '0');
        final min = dt.minute.toString().padLeft(2, '0');
        syncText = 'Last synced at $hour:$min';
      }

      // Read sync status from background.js app state or test endpoint
      bool isConnected = state?['appConnected'] as bool? ?? false;

      // Also verify via web-compatible fetch if available
      try {
        final result = await chromeStorageGet(['scolect_app_state']);
        final updatedState = result['scolect_app_state'] as Map<String, dynamic>?;
        if (updatedState != null && updatedState['appConnected'] != null) {
          isConnected = updatedState['appConnected'] as bool;
        }
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _connected = isConnected;
        _lastSyncText = syncText;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _connected = false;
        _lastSyncText = null;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SizedBox(
        width: 480,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Pulsing tracker icon ──────────────────────────────────────
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kBrowserGreen.withValues(alpha: 0.08 + _pulseAnim.value * 0.08),
                    border: Border.all(
                      color: kBrowserGreen.withValues(alpha: 0.2 + _pulseAnim.value * 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    FluentIcons.globe,
                    size: 32,
                    color: kBrowserGreen.withValues(alpha: 0.7 + _pulseAnim.value * 0.3),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Status text ───────────────────────────────────────────────
            Text(
              l10n.browserTrackingActive,
              style: theme.typography.subtitle?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.browserTrackingActiveDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.typography.caption?.color?.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // ── Connection status card ────────────────────────────────────
            BrowserCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _connected ? kBrowserGreen : kBrowserRed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _connected ? l10n.browserConnectedToDesktop : l10n.browserDesktopNotReachable,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        if (_lastSyncText != null)
                          Text(
                            _lastSyncText!,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.typography.caption?.color?.withValues(alpha: 0.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                  BrowserIconButton(
                    tooltip: l10n.browserRefreshSyncStatus,
                    icon: FluentIcons.refresh,
                    onPressed: _loadStatus,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Switch mode link ──────────────────────────────────────────
            GestureDetector(
              onTap: widget.onSwitchToStandalone,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  l10n.browserSwitchToStandalone,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
