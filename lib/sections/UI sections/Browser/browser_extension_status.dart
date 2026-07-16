// ─── Tracker-Only Status Screen ───────────────────────────────────────────────
//
// Shown when extension mode is 'trackerOnly'. Displays a live tracking
// indicator, sync status, and a link to switch mode.

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'browser_shared.dart';

// Conditionally import ExtensionSettings only on web
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
    // In a real implementation, read from chrome.storage.local
    // For now show the last-sync from AppState
    setState(() {
      _connected = false;
      _lastSyncText = null;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

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
              'Tracking Active',
              style: theme.typography.subtitle?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your browser activity is being tracked and\nsynced to the Scolect desktop app.',
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
                          _connected ? 'Connected to Scolect Desktop' : 'Desktop app not reachable',
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
                    tooltip: 'Refresh sync status',
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
                  'Switch to Standalone mode →',
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
