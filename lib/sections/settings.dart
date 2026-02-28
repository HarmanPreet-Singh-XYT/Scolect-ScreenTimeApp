import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:screentime/main.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/sections/controller/application_controller.dart';
import 'UI sections/import_export_dialog.dart' as ied;
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:screentime/sections/UI%20sections/Settings/reusables.dart';
import 'package:screentime/sections/UI sections/Settings/general.dart';
import 'package:screentime/sections/UI sections/Settings/tracking.dart';
import 'package:screentime/sections/UI sections/Settings/notification.dart';
import 'package:screentime/sections/UI sections/Settings/footer.dart';
import 'package:screentime/sections/UI sections/Settings/data.dart';
import 'package:screentime/sections/UI sections/Settings/about.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screentime/sections/UI sections/Settings/theme_customization_section.dart';

// ============== CONSTANTS ==============

const _kAnimDuration = Duration(milliseconds: 150);
const _kAnimDurationMedium = Duration(milliseconds: 200);
const _kHighlightDuration = Duration(seconds: 3);
const _kSectionSpacing = SizedBox(height: 20);

// ============== SETTINGS PROVIDER ==============

/// Maps setting keys to their storage paths for simple (non-side-effect) settings.
const _simpleSettingPaths = <String, String>{
  'theme': 'theme.selected',
  'language': 'language.selected',
  'launchAtStartup': 'launchAtStartup',
  'launchAsMinimized': 'launchAsMinimized',
  'notificationsEnabled': 'notifications.enabled',
  'notificationsFocusMode': 'notifications.focusMode',
  'notificationsScreenTime': 'notifications.screenTime',
  'notificationsAppScreenTime': 'notifications.appScreenTime',
  'reminderFrequency': 'notificationController.reminderFrequency',
  'voiceGender': 'focusModeSettings.voiceGender',
  'trackingMode': 'tracking.mode',
  'idleDetectionEnabled': 'tracking.idleDetection',
  'idleTimeout': 'tracking.idleTimeout',
  'monitorAudio': 'tracking.monitorAudio',
  'monitorControllers': 'tracking.monitorControllers',
  'monitorHIDDevices': 'tracking.monitorHIDDevices',
  'monitorKeyboard': 'tracking.monitorKeyboard',
  'audioThreshold': 'tracking.audioThreshold',
};

/// Field setters keyed by setting name, used to assign in-memory values.
typedef _FieldSetter = void Function(SettingsProvider provider, dynamic value);

final Map<String, _FieldSetter> _fieldSetters = {
  'theme': (p, v) => p._theme = v,
  'language': (p, v) => p._language = v,
  'launchAtStartup': (p, v) => p._launchAtStartupVar = v,
  'launchAsMinimized': (p, v) => p._launchAsMinimized = v,
  'notificationsEnabled': (p, v) => p._notificationsEnabled = v,
  'notificationsFocusMode': (p, v) => p._notificationsFocusMode = v,
  'notificationsScreenTime': (p, v) => p._notificationsScreenTime = v,
  'notificationsAppScreenTime': (p, v) => p._notificationsAppScreenTime = v,
  'reminderFrequency': (p, v) => p._reminderFrequency = v,
  'voiceGender': (p, v) => p._voiceGender = v,
  'trackingMode': (p, v) => p._trackingMode = v,
  'idleDetectionEnabled': (p, v) => p._idleDetectionEnabled = v,
  'idleTimeout': (p, v) => p._idleTimeout = v,
  'monitorAudio': (p, v) => p._monitorAudio = v,
  'monitorControllers': (p, v) => p._monitorControllers = v,
  'monitorHIDDevices': (p, v) => p._monitorHIDDevices = v,
  'monitorKeyboard': (p, v) => p._monitorKeyboard = v,
  'audioThreshold': (p, v) => p._audioThreshold = v,
};

class SettingsProvider extends ChangeNotifier {
  final SettingsManager _settingsManager = SettingsManager();
  final BackgroundAppTracker _tracker = BackgroundAppTracker();
  final Map<String, String> version = SettingsManager().versionInfo;

  String _theme = '';
  String _language = 'en';
  bool _launchAtStartupVar = false;
  bool _launchAsMinimized = false;
  bool _notificationsEnabled = false;
  bool _notificationsFocusMode = false;
  bool _notificationsScreenTime = false;
  bool _notificationsAppScreenTime = false;

  String _trackingMode = TrackingModeOptions.defaultMode;
  bool _idleDetectionEnabled = true;
  int _idleTimeout = IdleTimeoutOptions.defaultTimeout;
  bool _monitorAudio = true;
  bool _monitorControllers = true;
  bool _monitorHIDDevices = true;
  bool _monitorKeyboard = !Platform.isMacOS;
  double _audioThreshold = 0.001;

  String _voiceGender = VoiceGenderOptions.defaultGender;
  int _reminderFrequency = 60;

  // Getters
  String get theme => _theme;
  String get language => _language;
  bool get launchAtStartupVar => _launchAtStartupVar;
  bool get launchAsMinimized => _launchAsMinimized;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get notificationsFocusMode => _notificationsFocusMode;
  bool get notificationsScreenTime => _notificationsScreenTime;
  bool get notificationsAppScreenTime => _notificationsAppScreenTime;
  Map<String, String> get appVersion => version;

  String get trackingMode => _trackingMode;
  bool get idleDetectionEnabled => _idleDetectionEnabled;
  int get idleTimeout => _idleTimeout;
  bool get monitorAudio => _monitorAudio;
  bool get monitorControllers => _monitorControllers;
  bool get monitorHIDDevices => _monitorHIDDevices;
  bool get monitorKeyboard => _monitorKeyboard;
  double get audioThreshold => _audioThreshold;

  String get voiceGender => _voiceGender;
  int get reminderFrequency => _reminderFrequency;

  List<dynamic> get themeOptions => _settingsManager.getAvailableThemes();
  List<Map<String, String>> get languageOptions =>
      _settingsManager.getAvailableLanguages();
  List<Map<String, dynamic>> get idleTimeoutPresets =>
      _settingsManager.getIdleTimeoutPresets();
  List<Map<String, String>> get voiceGenderOptions =>
      _settingsManager.getAvailableVoiceGenders();
  List<String> get trackingModeOptions =>
      _settingsManager.getAvailableTrackingModes();

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() {
    _theme = _settingsManager.getSetting('theme.selected');
    _language = _settingsManager.getSetting('language.selected') ?? 'en';
    _launchAtStartupVar = _settingsManager.getSetting('launchAtStartup');
    _launchAsMinimized =
        _settingsManager.getSetting('launchAsMinimized') ?? false;
    _notificationsEnabled =
        _settingsManager.getSetting('notifications.enabled');
    _notificationsFocusMode =
        _settingsManager.getSetting('notifications.focusMode');
    _notificationsScreenTime =
        _settingsManager.getSetting('notifications.screenTime');
    _notificationsAppScreenTime =
        _settingsManager.getSetting('notifications.appScreenTime');
    _reminderFrequency = _settingsManager
            .getSetting('notificationController.reminderFrequency') ??
        60;

    _trackingMode = _settingsManager.getSetting('tracking.mode') ??
        TrackingModeOptions.defaultMode;
    _idleDetectionEnabled =
        _settingsManager.getSetting('tracking.idleDetection') ?? true;
    _idleTimeout = _settingsManager.getSetting('tracking.idleTimeout') ??
        IdleTimeoutOptions.defaultTimeout;
    _monitorAudio =
        _settingsManager.getSetting('tracking.monitorAudio') ?? true;
    _monitorControllers =
        _settingsManager.getSetting('tracking.monitorControllers') ?? true;
    _monitorHIDDevices =
        _settingsManager.getSetting('tracking.monitorHIDDevices') ?? true;
    _monitorKeyboard =
        _settingsManager.getSetting('tracking.monitorKeyboard') ??
            !Platform.isMacOS;
    _audioThreshold =
        _settingsManager.getSetting('tracking.audioThreshold') ?? 0.001;
    _voiceGender =
        _settingsManager.getSetting('focusModeSettings.voiceGender') ??
            VoiceGenderOptions.defaultGender;
  }

  Future<void> updateSetting(String key, dynamic value,
      [BuildContext? context]) async {
    // Set the in-memory field
    _fieldSetters[key]?.call(this, value);

    // Persist to storage
    final path = _simpleSettingPaths[key];
    if (path != null) {
      if (key == 'theme') {
        _settingsManager.updateSetting(path, value, context);
      } else {
        _settingsManager.updateSetting(path, value);
      }
    }

    // Handle side effects
    await _handleSideEffects(key, value);

    notifyListeners();
  }

  Future<void> _handleSideEffects(String key, dynamic value) async {
    switch (key) {
      case 'launchAtStartup':
        if (Platform.isMacOS) {
          value
              ? await launchAtStartup.enable()
              : await launchAtStartup.disable();
        }
      case 'trackingMode':
        final mode = value == TrackingModeOptions.precise
            ? TrackingMode.precise
            : TrackingMode.polling;
        await _tracker.setTrackingMode(mode);
      case 'idleDetectionEnabled':
        await _tracker.updateIdleDetection(value);
      case 'idleTimeout':
        await _tracker.updateIdleTimeout(value);
      case 'monitorAudio':
        await _tracker.updateAudioMonitoring(value);
      case 'monitorControllers':
        await _tracker.updateControllerMonitoring(value);
      case 'monitorHIDDevices':
        await _tracker.updateHIDMonitoring(value);
      case 'monitorKeyboard':
        await _tracker.updateKeyboardMonitoring(value);
      case 'audioThreshold':
        await _tracker.updateAudioThreshold(value);
    }
  }

  Future<void> setAllNotifications(bool enabled) async {
    const keys = [
      'notificationsEnabled',
      'notificationsFocusMode',
      'notificationsScreenTime',
      'notificationsAppScreenTime',
    ];
    for (final key in keys) {
      await updateSetting(key, enabled);
    }
  }

  Future<void> enableAllNotifications() => setAllNotifications(true);
  Future<void> disableAllNotifications() => setAllNotifications(false);

  int getReminderFrequency() {
    return _settingsManager
            .getSetting('notificationController.reminderFrequency') ??
        60;
  }

  Future<void> clearData() async {
    final dataStore = AppDataStore();
    await dataStore.init();
    await dataStore.clearAllData();
    await _tracker.reanchorTracking();
  }

  Future<void> resetSettings() async {
    await _settingsManager.resetSettings();
    if (Platform.isMacOS) {
      await launchAtStartup.enable();
    }
    _loadSettings();
    notifyListeners();
  }

  String getFormattedIdleTimeout(AppLocalizations l10n) =>
      formatTimeout(_idleTimeout, l10n);

  static String formatTimeout(int seconds, AppLocalizations l10n) {
    if (seconds < 60) return l10n.timeFormatSeconds(seconds);
    if (seconds == 60) return l10n.timeFormatMinute;

    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return remaining == 0
        ? l10n.timeFormatMinutes(minutes)
        : l10n.timeFormatMinutesSeconds(minutes, remaining);
  }
}

// ============== URL UTILITIES ==============

final _currentPlatform = _detectPlatform();

String _detectPlatform() {
  if (Platform.isMacOS) return 'macos';
  if (Platform.isWindows) return 'windows';
  if (Platform.isLinux) return 'linux';
  if (Platform.isAndroid) return 'android';
  if (Platform.isIOS) return 'ios';
  return 'unknown';
}

String getPlatform() => _currentPlatform;

String buildUrl(String path, {bool isBugReport = false}) {
  final params = <String, String>{
    'source': 'app',
    'app': 'scolect',
    'platform': _currentPlatform,
    'type': isBugReport ? 'report' : path,
  };

  if (isBugReport) {
    final versionInfo = SettingsManager().versionInfo;
    params['version'] = versionInfo['version'] ?? 'unknown';
    params['build'] = versionInfo['type'] ?? 'unknown';
  }

  return Uri(
    scheme: 'https',
    host: 'scolect.com',
    path: path,
    queryParameters: params,
  ).toString();
}

Future<void> launchAppropriateUrl(String url) async {
  if (Platform.isWindows) {
    if (await UrlLauncherPlatform.instance.canLaunch(url)) {
      await UrlLauncherPlatform.instance.launch(
        url,
        useSafariVC: false,
        useWebView: false,
        enableJavaScript: false,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: <String, String>{},
      );
    } else {
      throw Exception('Could not launch $url on Windows');
    }
  } else {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }
}

// ============== MAIN SETTINGS WIDGET ==============

class Settings extends StatelessWidget {
  final Function(Locale) setLocale;

  const Settings({super.key, required this.setLocale});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: SettingsContent(setLocale: setLocale),
    );
  }
}

class SettingsContent extends StatefulWidget {
  final Function(Locale) setLocale;

  const SettingsContent({super.key, required this.setLocale});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  String? _highlightedSection;

  // Pre-compute URLs once
  static final _contactUrl = buildUrl('contact');
  static final _feedbackUrl = buildUrl('feedback');
  static final _reportUrl = buildUrl('report-bug', isBugReport: true);
  static const _githubUrl =
      'https://github.com/HarmanPreet-Singh-XYT/Scolect-ScreenTimeApp';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkNavigationParams());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: CustomScrollView(
        slivers: [
          _buildStickyHeader(theme, l10n),
          _buildContent(l10n),
        ],
      ),
    );
  }

  SliverPersistentHeader _buildStickyHeader(
      FluentThemeData theme, AppLocalizations l10n) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyHeaderDelegate(
        height: 60,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: theme.micaBackgroundColor.withValues(alpha: 0.95),
            border: Border(
              bottom: BorderSide(
                color: theme.inactiveBackgroundColor.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(FluentIcons.settings, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.settingsTitle,
                style: theme.typography.subtitle
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              QuickActionButton(
                icon: FluentIcons.refresh,
                tooltip: l10n.resetSettingsTitle2,
                onPressed: () => _showResetDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverPadding _buildContent(AppLocalizations l10n) {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          LayoutBuilder(builder: _buildResponsiveLayout),
          const SizedBox(height: 24),
          FooterSection(
            onContact: () => launchAppropriateUrl(_contactUrl),
            onReport: () => launchAppropriateUrl(_reportUrl),
            onFeedback: () => launchAppropriateUrl(_feedbackUrl),
            onGithub: () => launchAppropriateUrl(_githubUrl),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _buildResponsiveLayout(
      BuildContext context, BoxConstraints constraints) {
    final isWide = constraints.maxWidth > 900;
    final notificationSection = NotificationSection(
      isHighlighted: _highlightedSection == 'notifications',
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                GeneralSection(setLocale: widget.setLocale),
                _kSectionSpacing,
                notificationSection,
                _kSectionSpacing,
                const DataSection(),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: const [
                TrackingSection(),
                _kSectionSpacing,
                ied.BackupRestoreSection(),
                _kSectionSpacing,
                ThemeCustomizationSection(),
                _kSectionSpacing,
                AboutSection(),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        GeneralSection(setLocale: widget.setLocale),
        _kSectionSpacing,
        const TrackingSection(),
        _kSectionSpacing,
        notificationSection,
        _kSectionSpacing,
        const DataSection(),
        _kSectionSpacing,
        const ied.BackupRestoreSection(),
        _kSectionSpacing,
        const ThemeCustomizationSection(),
        _kSectionSpacing,
        const AboutSection(),
      ],
    );
  }

  Future<void> _showResetDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.read<SettingsProvider>();

    await showDialog<String>(
      context: context,
      builder: (_) => ContentDialog(
        title: Row(
          children: [
            Icon(FluentIcons.warning, color: Colors.orange, size: 20),
            const SizedBox(width: 10),
            Text(l10n.resetSettingsDialogTitle),
          ],
        ),
        content: Text(l10n.resetSettingsDialogContent),
        actions: [
          Button(
            child: Text(l10n.cancelButton),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.orange),
            ),
            child: Text(l10n.resetButtonLabel),
            onPressed: () {
              settings.resetSettings();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _checkNavigationParams() {
    final navState = context.read<NavigationState>();
    final params = navState.navigationParams;

    if (params?['highlightSection'] != 'notifications') return;

    setState(() => _highlightedSection = 'notifications');

    Future.delayed(_kHighlightDuration, () {
      if (mounted) setState(() => _highlightedSection = null);
    });

    navState.clearParams();
  }
}

// ============== IDLE TIMEOUT DIALOG ==============

class IdleTimeoutDialog extends StatefulWidget {
  final int currentValue;
  final List<Map<String, dynamic>> presets;
  final AppLocalizations l10n;

  const IdleTimeoutDialog({
    super.key,
    required this.currentValue,
    required this.presets,
    required this.l10n,
  });

  @override
  State<IdleTimeoutDialog> createState() => _IdleTimeoutDialogState();
}

class _IdleTimeoutDialogState extends State<IdleTimeoutDialog> {
  late int _selectedValue;
  bool _isCustom = false;
  late final TextEditingController _minutesController;
  late final TextEditingController _secondsController;
  String? _errorMessage;

  // Cache preset label map to avoid repeated switch evaluation
  static const _presetLabelKeys = <int, String Function(AppLocalizations)>{};

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.currentValue;

    final matchesPreset = widget.presets.any(
      (p) => p['value'] == widget.currentValue && p['value'] != -1,
    );

    _isCustom = !matchesPreset;
    _minutesController = TextEditingController(
      text: _isCustom ? (widget.currentValue ~/ 60).toString() : '',
    );
    _secondsController = TextEditingController(
      text: _isCustom ? (widget.currentValue % 60).toString() : '',
    );
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  String _formatTimeout(int seconds) =>
      SettingsProvider.formatTimeout(seconds, widget.l10n);

  String _getPresetLabel(Map<String, dynamic> preset) {
    return switch (preset['value']) {
      30 => widget.l10n.seconds30,
      60 => widget.l10n.minute1,
      120 => widget.l10n.minutes2,
      300 => widget.l10n.minutes5,
      600 => widget.l10n.minutes10,
      -1 => widget.l10n.customOption,
      _ => preset['label'],
    };
  }

  void _selectPreset(int value) {
    setState(() {
      if (value == -1) {
        _isCustom = true;
        _minutesController.text = (_selectedValue ~/ 60).toString();
        _secondsController.text = (_selectedValue % 60).toString();
      } else {
        _isCustom = false;
        _selectedValue = value;
        _errorMessage = null;
      }
    });
  }

  void _validateCustomInput() {
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    final totalSeconds = (minutes * 60) + seconds;

    setState(() {
      if (totalSeconds < IdleTimeoutOptions.minTimeout) {
        _errorMessage = widget.l10n
            .minimumError(_formatTimeout(IdleTimeoutOptions.minTimeout));
      } else if (totalSeconds > IdleTimeoutOptions.maxTimeout) {
        _errorMessage = widget.l10n
            .maximumError(_formatTimeout(IdleTimeoutOptions.maxTimeout));
      } else {
        _selectedValue = totalSeconds;
        _errorMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 420),
      title: _buildTitle(theme),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.l10n.idleTimeoutDialogDescription,
            style: TextStyle(fontSize: 12, color: Colors.grey[100]),
          ),
          const SizedBox(height: 20),
          _buildPresetGrid(),
          _buildCustomInput(theme),
          const SizedBox(height: 16),
          WarningBanner(
            message: widget.l10n.rangeInfo(
              _formatTimeout(IdleTimeoutOptions.minTimeout),
              _formatTimeout(IdleTimeoutOptions.maxTimeout),
            ),
            icon: FluentIcons.info,
            color: Colors.blue,
          ),
        ],
      ),
      actions: [
        Button(
          child: Text(widget.l10n.cancelButton),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          onPressed: _errorMessage != null
              ? null
              : () => Navigator.pop(context, _selectedValue),
          child: Text(widget.l10n.saveButton),
        ),
      ],
    );
  }

  Widget _buildTitle(FluentThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(FluentIcons.timer, size: 18, color: theme.accentColor),
        ),
        const SizedBox(width: 12),
        Text(widget.l10n.setIdleTimeoutTitle),
      ],
    );
  }

  Widget _buildPresetGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.5,
      physics: const NeverScrollableScrollPhysics(),
      children: widget.presets.map((preset) {
        final presetValue = preset['value'] as int;
        final isSelected = !_isCustom && _selectedValue == presetValue;
        final isCustomSelected = _isCustom && presetValue == -1;

        return _PresetButton(
          label: _getPresetLabel(preset),
          isSelected: isSelected || isCustomSelected,
          onPressed: () => _selectPreset(presetValue),
        );
      }).toList(),
    );
  }

  Widget _buildCustomInput(FluentThemeData theme) {
    return AnimatedCrossFade(
      firstChild: _CustomTimeInput(
        minutesController: _minutesController,
        secondsController: _secondsController,
        errorMessage: _errorMessage,
        selectedValue: _selectedValue,
        l10n: widget.l10n,
        onChanged: _validateCustomInput,
        formatTimeout: _formatTimeout,
      ),
      secondChild: const SizedBox.shrink(),
      crossFadeState:
          _isCustom ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: _kAnimDurationMedium,
    );
  }
}

// ============== CUSTOM TIME INPUT (Extracted) ==============

class _CustomTimeInput extends StatelessWidget {
  final TextEditingController minutesController;
  final TextEditingController secondsController;
  final String? errorMessage;
  final int selectedValue;
  final AppLocalizations l10n;
  final VoidCallback onChanged;
  final String Function(int) formatTimeout;

  const _CustomTimeInput({
    required this.minutesController,
    required this.secondsController,
    required this.errorMessage,
    required this.selectedValue,
    required this.l10n,
    required this.onChanged,
    required this.formatTimeout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.inactiveBackgroundColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.customDurationTitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextBox(
                      controller: minutesController,
                      placeholder: '0',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                  _TimeUnitLabel(text: l10n.minAbbreviation),
                  Expanded(
                    child: TextBox(
                      controller: secondsController,
                      placeholder: '0',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                  _TimeUnitLabel(text: l10n.secAbbreviation, isLast: true),
                ],
              ),
              const SizedBox(height: 8),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: TextStyle(fontSize: 11, color: Colors.red),
                )
              else
                Text(
                  l10n.totalLabel(formatTimeout(selectedValue)),
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeUnitLabel extends StatelessWidget {
  final String text;
  final bool isLast;

  const _TimeUnitLabel({required this.text, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8, right: isLast ? 0 : 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: Colors.grey[100]),
      ),
    );
  }
}

// ============== PRESET BUTTON ==============

class _PresetButton extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _PresetButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  State<_PresetButton> createState() => _PresetButtonState();
}

class _PresetButtonState extends State<_PresetButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final inactive = theme.inactiveBackgroundColor;

    final Color bgColor;
    final Color borderColor;
    final double borderWidth;

    if (widget.isSelected) {
      bgColor = theme.accentColor.withValues(alpha: 0.15);
      borderColor = theme.accentColor;
      borderWidth = 2;
    } else if (_isHovered) {
      bgColor = inactive.withValues(alpha: 0.5);
      borderColor = inactive;
      borderWidth = 1;
    } else {
      bgColor = inactive.withValues(alpha: 0.2);
      borderColor = Colors.transparent;
      borderWidth = 1;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: _kAnimDuration,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                color: widget.isSelected ? theme.accentColor : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
