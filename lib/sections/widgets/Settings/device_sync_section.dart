import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/widgets/Settings/reusables.dart';
import 'package:screentime/utils/date_formats.dart';
import 'package:screentime/utils/device_sync.dart';

// ============== DEVICE SYNC ==============

class DeviceSyncSection extends StatefulWidget {
  /// Overridable for tests.
  final DeviceSync? sync;
  final Future<String?> Function()? pickFolder;
  const DeviceSyncSection({super.key, this.sync, this.pickFolder});

  @override
  State<DeviceSyncSection> createState() => _DeviceSyncSectionState();
}

class _DeviceSyncSectionState extends State<DeviceSyncSection> {
  late final DeviceSync _sync = widget.sync ?? DeviceSync.instance;
  late final TextEditingController _name =
      TextEditingController(text: _sync.deviceName);
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _toggle(bool on) async {
    setState(() => _busy = true);
    if (on) {
      await _sync.setEnabled(true);
    } else {
      await _sync.removeOwnFile();
      await _sync.setEnabled(false);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _chooseFolder() async {
    final picked = await (widget.pickFolder ?? FilePicker.getDirectoryPath)();
    if (picked == null || picked.isEmpty) return;
    setState(() => _busy = true);
    await _sync.setFolder(picked);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _syncNow() async {
    setState(() => _busy = true);
    await _sync.syncOnce();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return ListenableBuilder(
      listenable: _sync,
      builder: (context, _) {
        final enabled = _sync.enabled;
        final folder = _sync.folder;
        final last = _sync.lastSyncedAt;

        return SettingsCard(
          title: l10n.dsTitle,
          icon: FluentIcons.sync,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(l10n.dsDescription, style: theme.typography.caption),
            ),
            SettingRow(
              title: l10n.dsToggle,
              description: '',
              showDivider: enabled,
              control: ToggleSwitch(
                checked: enabled,
                onChanged: _busy ? null : _toggle,
              ),
            ),
            if (enabled) ...[
              SettingRow(
                title: l10n.dsFolder,
                description: folder.isEmpty ? l10n.dsNoFolder : folder,
                control: Button(
                  onPressed: _busy ? null : _chooseFolder,
                  child: Text(l10n.dsChooseFolder),
                ),
              ),
              SettingRow(
                title: l10n.dsDeviceName,
                description: '',
                control: SizedBox(
                  width: 220,
                  child: TextBox(
                    controller: _name,
                    maxLength: 60,
                    onChanged: _sync.setDeviceName,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        last == null
                            ? l10n.dsNeverSynced
                            : l10n.dsLastSynced(AppDateFormat.sessionTimestamp(last)),
                        style: theme.typography.caption,
                      ),
                    ),
                    Button(
                      onPressed: _busy || folder.isEmpty ? null : _syncNow,
                      child: _busy
                          ? const SizedBox(
                              width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                          : Text(l10n.dsSyncNow),
                    ),
                  ],
                ),
              ),
              if (_sync.lastError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Text(l10n.dsError(_sync.lastError!),
                      style: TextStyle(color: Colors.red)),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dsOtherDevices, style: theme.typography.bodyStrong),
                    const SizedBox(height: 6),
                    if (_sync.peers.isEmpty)
                      Text(l10n.dsNoOthers, style: theme.typography.caption),
                    for (final p in _sync.peers)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(FluentIcons.pc1, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.dsPeerUpdated(p.deviceName.isEmpty ? p.deviceId.substring(0, 8) : p.deviceName,
                                    AppDateFormat.sessionTimestamp(p.updatedAt)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
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
