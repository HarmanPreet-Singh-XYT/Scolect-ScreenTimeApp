import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/sections/widgets/Settings/reusables.dart';
import 'package:screentime/utils/extension_auth.dart';

// ============== BROWSER EXTENSION ACCESS ==============
//
// Desktop-only. Lets the user approve, deny and revoke browser extensions that
// sync with the local server (see ExtensionAuth).

String _browserLabel(BuildContext context, String name, String id) {
  final base =
      name.isEmpty ? AppLocalizations.of(context)!.extAccessUnknownBrowser : name;
  return '$base · ${id.substring(0, 8)}';
}

class ExtensionAccessSection extends StatefulWidget {
  const ExtensionAccessSection({super.key});

  @override
  State<ExtensionAccessSection> createState() => _ExtensionAccessSectionState();
}

class _ExtensionAccessSectionState extends State<ExtensionAccessSection> {
  final ExtensionAuth _auth = ExtensionAuth.instance;
  late bool _required = _auth.isRequired;

  void _setRequired(bool value) {
    SettingsManager().updateSetting(ExtensionAuth.settingKey, value);
    setState(() => _required = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return ListenableBuilder(
      listenable: _auth,
      builder: (context, _) {
        final pending = _auth.pending;
        final approved = _auth.approved;

        return SettingsCard(
          title: l10n.extAccessSectionTitle,
          icon: FluentIcons.shield,
          children: [
            SettingRow(
              title: l10n.extAccessRequireTitle,
              description: l10n.extAccessRequireDescription,
              showDivider: _required,
              control: ToggleSwitch(checked: _required, onChanged: _setRequired),
            ),
            if (_required) ...[
              if (pending.isNotEmpty)
                _Group(
                  title: l10n.extAccessPendingTitle,
                  description: l10n.extAccessPendingDescription,
                  children: [
                    for (final b in pending)
                      _BrowserRow(
                        label: _browserLabel(context, b.name, b.id),
                        actions: [
                          FilledButton(
                            onPressed: () => _auth.approve(b.id),
                            child: Text(l10n.extAccessApprove),
                          ),
                          Button(
                            onPressed: () => _auth.deny(b.id),
                            child: Text(l10n.extAccessDeny),
                          ),
                        ],
                      ),
                  ],
                ),
              _Group(
                title: l10n.extAccessApprovedTitle,
                children: approved.isEmpty
                    ? [
                        Text(l10n.extAccessNoneApproved,
                            style: theme.typography.caption),
                      ]
                    : [
                        for (final b in approved)
                          _BrowserRow(
                            label: _browserLabel(context, b.name, b.id),
                            actions: [
                              Button(
                                onPressed: () => _auth.revoke(b.id),
                                child: Text(l10n.extAccessRevoke),
                              ),
                            ],
                          ),
                      ],
              ),
              if (_auth.blockedCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.extAccessBlockedNotice(_auth.blockedCount),
                          style: theme.typography.caption,
                        ),
                      ),
                      HyperlinkButton(
                        onPressed: _auth.clearDenied,
                        child: Text(l10n.extAccessAllowDeniedAgain),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _Group extends StatelessWidget {
  final String title;
  final String? description;
  final List<Widget> children;

  const _Group({required this.title, this.description, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.typography.bodyStrong),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(description!, style: theme.typography.caption),
            ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _BrowserRow extends StatelessWidget {
  final String label;
  final List<Widget> actions;

  const _BrowserRow({required this.label, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(FluentIcons.globe, size: 14),
          const SizedBox(width: 8),
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
          for (final a in actions) ...[const SizedBox(width: 8), a],
        ],
      ),
    );
  }
}

/// Shown at the top of the Browser page while a browser is waiting for
/// approval, so the user doesn't have to hunt through Settings for it.
class ExtensionApprovalBanner extends StatelessWidget {
  const ExtensionApprovalBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = ExtensionAuth.instance;
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) {
        final pending = auth.pending;
        if (pending.isEmpty || !auth.isRequired) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            children: [
              for (final b in pending)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InfoBar(
                    title: Text(l10n.extAccessBannerTitle),
                    content: Text(l10n.extAccessBannerBody(
                        _browserLabel(context, b.name, b.id))),
                    severity: InfoBarSeverity.warning,
                    isLong: true,
                    action: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton(
                          onPressed: () => auth.approve(b.id),
                          child: Text(l10n.extAccessApprove),
                        ),
                        const SizedBox(width: 8),
                        Button(
                          onPressed: () => auth.deny(b.id),
                          child: Text(l10n.extAccessDeny),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
