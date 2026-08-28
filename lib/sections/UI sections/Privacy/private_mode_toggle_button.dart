import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/services/private_mode_service.dart';
import 'package:screentime/web/web_private_mode_service.dart'
    if (dart.library.io) 'package:screentime/web/web_private_mode_service_stub.dart';
import 'package:screentime/sections/widgets/Settings/privacy.dart'
    show showPrivateModeRecoveryFlow, showPrivateModeSetPasswordFlow;
import 'private_mode_unlock_dialog.dart';

/// Titlebar control that switches every page (Overview, Applications,
/// Browser, Reports, Alerts & Limits) between showing public-only or
/// private-only data. Replaces the old per-page toggle buttons in
/// applications.dart / browser_websites.dart with a single control surface,
/// and the old isolated "Private Mode" sidebar section.
class PrivateModeToggleButton extends StatefulWidget {
  final bool isDark;

  const PrivateModeToggleButton({super.key, this.isDark = false});

  @override
  State<PrivateModeToggleButton> createState() =>
      _PrivateModeToggleButtonState();
}

class _PrivateModeToggleButtonState extends State<PrivateModeToggleButton> {
  bool _isSetUp = false;
  bool _showPrivateOnly = false;
  bool _isHovering = false;

  void _onPrivateModeChanged() {
    if (!mounted) return;
    setState(() {
      _showPrivateOnly = kIsWeb
          ? WebPrivateModeService().showPrivateOnly
          : PrivateModeController().showPrivateOnly;
    });
    _refreshIsSetUp();
  }

  Future<void> _refreshIsSetUp() async {
    final setUp = kIsWeb
        ? await WebPrivateModeService().isSetUp
        : PrivateModeController().isSetUp;
    if (mounted) setState(() => _isSetUp = setUp);
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WebPrivateModeService().addListener(_onPrivateModeChanged);
    } else {
      PrivateModeController().addListener(_onPrivateModeChanged);
    }
    _onPrivateModeChanged();
    _refreshIsSetUp();
  }

  @override
  void dispose() {
    if (kIsWeb) {
      WebPrivateModeService().removeListener(_onPrivateModeChanged);
    } else {
      PrivateModeController().removeListener(_onPrivateModeChanged);
    }
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!_isSetUp) {
      final created = await showPrivateModeSetPasswordFlow(context);
      if (created) {
        await _refreshIsSetUp();
        if (kIsWeb) {
          WebPrivateModeService().setShowPrivateOnly(true);
        } else {
          PrivateModeController().setShowPrivateOnly(true);
        }
      }
      return;
    }

    if (_showPrivateOnly) {
      if (kIsWeb) {
        WebPrivateModeService().setShowPrivateOnly(false);
      } else {
        PrivateModeController().setShowPrivateOnly(false);
      }
      return;
    }

    final alreadyUnlocked =
        kIsWeb ? WebPrivateModeService().isUnlocked : PrivateModeController().isUnlocked;
    if (alreadyUnlocked) {
      if (kIsWeb) {
        WebPrivateModeService().extendSession();
        WebPrivateModeService().setShowPrivateOnly(true);
      } else {
        PrivateModeController().extendSession();
        PrivateModeController().setShowPrivateOnly(true);
      }
      return;
    }

    final unlocked = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PrivateModeUnlockDialog(
        onUnlock: (password) => kIsWeb
            ? WebPrivateModeService().unlock(password)
            : Future.value(PrivateModeController().unlock(password)),
        onForgotPassword: () => showPrivateModeRecoveryFlow(context),
      ),
    );
    if (unlocked == true) {
      if (kIsWeb) {
        WebPrivateModeService().setShowPrivateOnly(true);
      } else {
        PrivateModeController().setShowPrivateOnly(true);
      }
    }
  }

  /// Explicit immediate lock, independent of the click-to-toggle action —
  /// triggered by right-click or long-press. Ends the unlock session right
  /// away (password required again next time), rather than just switching
  /// back to the public view like a normal tap does.
  void _handleLock() {
    if (!_isSetUp) return;
    if (kIsWeb) {
      if (!WebPrivateModeService().isUnlocked) return;
      WebPrivateModeService().lock();
    } else {
      if (!PrivateModeController().isUnlocked) return;
      PrivateModeController().lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String tooltip;
    if (!_isSetUp) {
      tooltip = l10n.privateModeSetPasswordTitle;
    } else {
      final baseTooltip = _showPrivateOnly
          ? l10n.privateModeHideAction
          : l10n.privateModeShowAction;
      final alreadyUnlocked = kIsWeb
          ? WebPrivateModeService().isUnlocked
          : PrivateModeController().isUnlocked;
      tooltip = alreadyUnlocked
          ? '$baseTooltip\n${l10n.privateModeLockHint}'
          : baseTooltip;
    }
    final icon = _showPrivateOnly ? FluentIcons.unlock : FluentIcons.lock;
    final accent = FluentTheme.of(context).accentColor;

    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: GestureDetector(
          onTap: _handleTap,
          onSecondaryTap: _handleLock,
          onLongPress: _handleLock,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _showPrivateOnly
                  ? accent.withValues(alpha: 0.15)
                  : _isHovering
                      ? (widget.isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05))
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 14,
              color: _showPrivateOnly
                  ? accent
                  : (widget.isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

