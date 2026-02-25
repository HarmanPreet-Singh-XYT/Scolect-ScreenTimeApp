import 'dart:async';
import 'dart:io';
import 'package:auto_updater/auto_updater.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/notification_controller.dart';
import 'package:screentime/utils/mac_launch.dart';
import 'package:screentime/utils/macos_window.dart';
import 'package:screentime/utils/update_service.dart';
import './sections/overview.dart';
import './sections/applications.dart';
import './sections/alerts_limits.dart';
import './sections/focus_mode.dart';
import './sections/reports.dart';
import './sections/settings.dart';
import './sections/help.dart';
import 'sections/controller/settings_data_controller.dart';
import './adaptive_fluent/adaptive_theme_fluent_ui.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:tray_manager/tray_manager.dart';
import './sections/controller/application_controller.dart';
import 'utils/single_instance_ipc.dart';
import 'dart:ui' show lerpDouble;
import 'package:provider/provider.dart';
import 'package:screentime/sections/UI sections/Settings/theme_provider.dart';
import 'package:screentime/sections/UI sections/Settings/theme_customization_model.dart';
import 'package:screentime/app_design.dart';
import 'package:screentime/sections/UI sections/FocusMode/audio.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:window_manager/window_manager.dart';

// ============================================================================
// ⚙️  BUILD FLAG
//    true  → direct distribution, Sparkle/WinSparkle active, update banner shown
//    false → store build, no update logic at all
// ============================================================================
const bool autoUpdates = true;

const String _macFeedURL = 'https://api.scolect.com/update/macos';
const String _winFeedURL = 'https://api.scolect.com/update/windows';

// Tray icon paths
String _trayIconNormal = Platform.isWindows
    ? 'assets/icons/tray_icon_windows.ico'
    : 'assets/icons/tray_icon_mac.png';

// Badge icon shown when an update is available — create these assets:
//   assets/icons/tray_icon_windows_update.ico  (same icon with a small dot)
//   assets/icons/tray_icon_mac_update.png      (same icon with a small dot)
String _trayIconUpdate = Platform.isWindows
    ? 'assets/icons/tray_icon_windows_update.ico'
    : 'assets/icons/tray_icon_mac_update.png';

// ============================================================================
// NAVIGATION STATE
// ============================================================================

class NavigationState extends ChangeNotifier {
  int _selectedIndex = 0;
  Map<String, dynamic>? _navigationParams;
  VoidCallback? _currentScreenRefresh;
  Timer? _periodicRefreshTimer;
  bool _isAppVisible = false;

  int get selectedIndex => _selectedIndex;
  Map<String, dynamic>? get navigationParams => _navigationParams;
  bool get isAppVisible => _isAppVisible;

  void changeIndex(int value, {Map<String, dynamic>? params}) {
    if (_selectedIndex != value || params != null) {
      _selectedIndex = value;
      _navigationParams = params;
      _currentScreenRefresh = null;
      notifyListeners();

      if (params != null) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _navigationParams = null;
          notifyListeners();
        });
      }
    }
  }

  void registerRefreshCallback(VoidCallback callback) {
    _currentScreenRefresh = callback;
  }

  void refreshCurrentScreen() => _currentScreenRefresh?.call();

  void clearParams() {
    _navigationParams = null;
    notifyListeners();
  }

  void startPeriodicRefresh({bool refreshImmediately = true}) {
    if (_isAppVisible) return;
    _isAppVisible = true;
    debugPrint('🔄 Starting periodic UI refresh (every 1 minute)');
    if (refreshImmediately) {
      debugPrint('⚡ Immediate refresh on focus');
      refreshCurrentScreen();
    }
    _periodicRefreshTimer?.cancel();
    _periodicRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_isAppVisible) refreshCurrentScreen();
    });
  }

  void stopPeriodicRefresh() {
    if (!_isAppVisible) return;
    _isAppVisible = false;
    debugPrint('⏸️ Stopping periodic UI refresh');
    _periodicRefreshTimer?.cancel();
    _periodicRefreshTimer = null;
  }

  @override
  void dispose() {
    _periodicRefreshTimer?.cancel();
    super.dispose();
  }
}

final navigationState = NavigationState();

// ============================================================================
// MAIN
// ============================================================================

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isMacOS) {
    launchAtStartup.setup(
      appName: "Scolect",
      appPath: Platform.resolvedExecutable,
    );
  }

  final bool wasSystemLaunchedWindows = args.contains('--auto-launched');
  bool wasSystemLaunchedMacOS = false;

  bool existingInstanceFound = false;
  try {
    final socket = await Socket.connect(
      InternetAddress.loopbackIPv4,
      45999,
      timeout: const Duration(milliseconds: 500),
    );
    socket.write('SHOW');
    await socket.flush();
    await socket.close();
    debugPrint('✅ Sent SHOW to existing instance, exiting');
    existingInstanceFound = true;
  } catch (e) {
    debugPrint('✅ No existing instance found, starting as primary');
  }
  if (existingInstanceFound) exit(0);

  await SingleInstanceIPC.startServer();
  await SettingsManager().init();

  if (Platform.isMacOS) {
    final bool shouldLaunchAtStartup =
        await SettingsManager().getSetting("launchAtStartup") ?? false;
    if (shouldLaunchAtStartup) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
  }

  final bool isMinimizeAtLaunch =
      await SettingsManager().getSetting("launchAsMinimized") ?? false;
  await NotificationController().initialize();
  await windowManager.ensureInitialized();

  final String savedTheme =
      SettingsManager().getSetting("theme.selected") ?? "System";
  String? savedLocale = SettingsManager().getSetting("language.selected");

  if (savedLocale == null) {
    savedLocale = _detectSystemLocale();
    if (savedLocale != null) {
      SettingsManager().updateSetting("language.selected", savedLocale);
    } else {
      savedLocale = LanguageOptions.defaultLanguage;
    }
  }

  final AdaptiveThemeMode initialTheme;
  switch (savedTheme) {
    case "Dark":
      initialTheme = AdaptiveThemeMode.dark;
      break;
    case "Light":
      initialTheme = AdaptiveThemeMode.light;
      break;
    default:
      initialTheme = AdaptiveThemeMode.system;
  }

  final tracker = BackgroundAppTracker();
  await tracker.initializeTracking(locale: savedLocale);

  if (autoUpdates) {
    final version = SettingsManager().versionInfo['version'] ?? '0.0.0';
    unawaited(UpdateService().initialize(version));

    final feedURL = Platform.isMacOS ? _macFeedURL : _winFeedURL;
    await autoUpdater.setFeedURL(feedURL);
    await autoUpdater.setScheduledCheckInterval(0);
    debugPrint('✅ auto_updater initialized: $feedURL');
  } else {
    debugPrint('ℹ️  Store build — update logic disabled');
  }

  runApp(MyApp(
    initialTheme: initialTheme,
    savedLocale: savedLocale,
  ));

  doWhenWindowReady(() async {
    final win = appWindow;
    const initialSize = Size(1280, 800);
    win.minSize = const Size(900, 600);
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = 'Scolect - Track Screen Time & App Usage';

    if (Platform.isMacOS) {
      wasSystemLaunchedMacOS = await MacOSLaunchService.wasLaunchedAtLogin();
    }

    final bool wasSystemLaunched =
        wasSystemLaunchedWindows || wasSystemLaunchedMacOS;

    if (wasSystemLaunched || isMinimizeAtLaunch) {
      debugPrint('🔽 Starting hidden');
      Platform.isMacOS ? await MacOSWindow.hide() : win.hide();
      navigationState.stopPeriodicRefresh();
    } else {
      debugPrint('🔼 Starting visible');
      Platform.isMacOS ? await MacOSWindow.show() : win.show();
      navigationState.startPeriodicRefresh(refreshImmediately: true);
    }
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

String? _detectSystemLocale() {
  try {
    final String systemLocale = Platform.localeName;
    final String languageCode = systemLocale.split('_').first.toLowerCase();
    final bool isSupported =
        LanguageOptions.available.any((lang) => lang['code'] == languageCode);
    return isSupported ? languageCode : null;
  } catch (e) {
    return null;
  }
}

// ============================================================================
// THEME DATA
// ============================================================================

FluentThemeData buildLightTheme(CustomThemeData themeData) {
  return FluentThemeData(
    brightness: Brightness.light,
    accentColor: AccentColor.swatch({
      'normal': themeData.primaryAccent,
      'dark': themeData.secondaryAccent,
      'darker': themeData.primaryAccent.withValues(alpha: 0.8),
      'darkest': themeData.primaryAccent.withValues(alpha: 0.6),
    }),
    scaffoldBackgroundColor: themeData.lightBackground,
    cardColor: themeData.lightSurface,
    micaBackgroundColor: themeData.lightSurface,
    inactiveBackgroundColor: themeData.lightBorder,
    typography: Typography.raw(
      caption: TextStyle(
          fontSize: 12,
          color: themeData.lightTextSecondary,
          fontWeight: FontWeight.normal),
      body: TextStyle(
          fontSize: 14,
          color: themeData.lightTextPrimary,
          fontWeight: FontWeight.normal),
      bodyLarge: TextStyle(
          fontSize: 16,
          color: themeData.lightTextPrimary,
          fontWeight: FontWeight.normal),
      bodyStrong: TextStyle(
          fontSize: 14,
          color: themeData.lightTextPrimary,
          fontWeight: FontWeight.w600),
      subtitle: TextStyle(
          fontSize: 20,
          color: themeData.lightTextPrimary,
          fontWeight: FontWeight.w600),
      title: TextStyle(
          fontSize: 28,
          color: themeData.lightTextPrimary,
          fontWeight: FontWeight.w600),
      titleLarge: TextStyle(
          fontSize: 40,
          color: themeData.lightTextPrimary,
          fontWeight: FontWeight.w600),
      display: TextStyle(
          fontSize: 68,
          color: themeData.lightTextPrimary,
          fontWeight: FontWeight.w600),
    ),
  );
}

FluentThemeData buildDarkTheme(CustomThemeData themeData) {
  return FluentThemeData(
    brightness: Brightness.dark,
    accentColor: AccentColor.swatch({
      'normal': themeData.primaryAccent,
      'dark': themeData.secondaryAccent,
      'darker': themeData.primaryAccent.withValues(alpha: 0.8),
      'darkest': themeData.primaryAccent.withValues(alpha: 0.6),
    }),
    scaffoldBackgroundColor: themeData.darkBackground,
    cardColor: themeData.darkSurface,
    micaBackgroundColor: themeData.darkSurfaceSecondary,
    inactiveBackgroundColor: themeData.darkBorder,
    typography: Typography.raw(
      caption: TextStyle(
          fontSize: 12,
          color: themeData.darkTextSecondary,
          fontWeight: FontWeight.normal),
      body: TextStyle(
          fontSize: 14,
          color: themeData.darkTextPrimary,
          fontWeight: FontWeight.normal),
      bodyLarge: TextStyle(
          fontSize: 16,
          color: themeData.darkTextPrimary,
          fontWeight: FontWeight.normal),
      bodyStrong: TextStyle(
          fontSize: 14,
          color: themeData.darkTextPrimary,
          fontWeight: FontWeight.w600),
      subtitle: TextStyle(
          fontSize: 20,
          color: themeData.darkTextPrimary,
          fontWeight: FontWeight.w600),
      title: TextStyle(
          fontSize: 28,
          color: themeData.darkTextPrimary,
          fontWeight: FontWeight.w600),
      titleLarge: TextStyle(
          fontSize: 40,
          color: themeData.darkTextPrimary,
          fontWeight: FontWeight.w600),
      display: TextStyle(
          fontSize: 68,
          color: themeData.darkTextPrimary,
          fontWeight: FontWeight.w600),
    ),
  );
}

// ============================================================================
// MY APP
// ============================================================================

class MyApp extends StatefulWidget {
  final AdaptiveThemeMode initialTheme;
  final String? savedLocale;

  const MyApp({
    super.key,
    this.initialTheme = AdaptiveThemeMode.system,
    this.savedLocale,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    with TrayListener, WidgetsBindingObserver {
  final String appVersion = "v${SettingsManager().versionInfo["version"]}";
  final AppDataStore _dataStore = AppDataStore();
  Locale? _locale;

  // Tracks whether we've already switched to the update icon
  // so we don't call setIcon on every notifyListeners
  bool _trayShowingUpdateIcon = false;

  void changeIndex(int value) => navigationState.changeIndex(value);

  void setLocale(Locale locale) async {
    setState(() => _locale = locale);
    SettingsManager().updateSetting("language.selected", locale.languageCode);
    await BackgroundAppTracker().updateLocale(locale.languageCode);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateTrayMenu());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDataStore();
    _initTray();
    trayManager.addListener(this);
    if (widget.savedLocale != null) _locale = Locale(widget.savedLocale!);

    // Listen to UpdateService and react to status changes
    if (autoUpdates) {
      UpdateService().addListener(_onUpdateStatusChanged);
    }
  }

  /// Called every time UpdateService notifies — swap tray icon + menu
  void _onUpdateStatusChanged() {
    final hasUpdate = UpdateService().hasUpdate;

    if (hasUpdate && !_trayShowingUpdateIcon) {
      _trayShowingUpdateIcon = true;
      _setTrayIcon(update: true);
      _updateTrayMenu(); // rebuilds menu with "Update Available" item
      debugPrint('🔔 Tray icon switched to update badge');
    } else if (!hasUpdate && _trayShowingUpdateIcon) {
      _trayShowingUpdateIcon = false;
      _setTrayIcon(update: false);
      _updateTrayMenu();
      debugPrint('✅ Tray icon restored to normal');
    }
  }

  Future<void> _setTrayIcon({required bool update}) async {
    try {
      await trayManager.setIcon(update ? _trayIconUpdate : _trayIconNormal);
    } catch (e) {
      // If the update icon asset doesn't exist yet, silently fall back
      debugPrint('⚠️  Could not set tray icon: $e');
    }
  }

  Future<void> _initDataStore() async => await _dataStore.init();

  Future<void> _initTray() async {
    await trayManager.setIcon(_trayIconNormal);
    await trayManager.setToolTip("Scolect");
    await _updateTrayMenu();
  }

  Future<void> _updateTrayMenu() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    final l10n = AppLocalizations.of(context)!;
    final hasUpdate = autoUpdates && UpdateService().hasUpdate;
    final updateInfo = autoUpdates ? UpdateService().availableUpdate : null;

    await trayManager.setContextMenu(
      Menu(items: [
        MenuItem(label: l10n.trayShowWindow, onClick: (_) => _showApp()),
        MenuItem.separator(),

        // Show update item at the top when available so it's hard to miss
        if (hasUpdate) ...[
          MenuItem(
            label: '🆕 Update to ${updateInfo?.tagName ?? 'latest'}',
            onClick: (_) async {
              _showApp();
              await autoUpdater.checkForUpdates();
            },
          ),
          MenuItem.separator(),
        ],

        MenuItem(label: l10n.navReports, onClick: (_) => _openSection(3)),
        MenuItem(label: l10n.navAlertsLimits, onClick: (_) => _openSection(2)),
        MenuItem(label: l10n.navApplications, onClick: (_) => _openSection(1)),
        MenuItem.separator(),
        MenuItem(
          disabled: true,
          label: l10n.trayVersion(appVersion),
          checked: false,
        ),
        MenuItem.separator(),
        MenuItem(label: l10n.trayExit, onClick: (_) => _exitApp()),
      ]),
    );
  }

  void _showApp() {
    Platform.isMacOS ? MacOSWindow.show() : appWindow.show();
    navigationState.startPeriodicRefresh(refreshImmediately: true);
  }

  void _exitApp() {
    navigationState.stopPeriodicRefresh();
    Platform.isMacOS ? MacOSWindow.exit() : appWindow.close();
  }

  void _openSection(int index) {
    changeIndex(index);
    _showApp();
  }

  @override
  void onTrayIconMouseDown() => _showApp();

  @override
  void onTrayIconRightMouseDown() => trayManager.popUpContextMenu();

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    final l10n = AppLocalizations.of(context)!;

    if (menuItem.label == l10n.trayShowWindow)
      _showApp();
    else if (menuItem.label == l10n.trayExit)
      _exitApp();
    else if (menuItem.label == l10n.navReports)
      _openSection(3);
    else if (menuItem.label == l10n.navAlertsLimits)
      _openSection(2);
    else if (menuItem.label == l10n.navApplications) _openSection(1);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _dataStore.handleAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        navigationState.startPeriodicRefresh(refreshImmediately: true);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        navigationState.stopPeriodicRefresh();
        break;
    }
  }

  @override
  void dispose() {
    if (autoUpdates) UpdateService().removeListener(_onUpdateStatusChanged);
    WidgetsBinding.instance.removeObserver(this);
    BackgroundAppTracker().dispose();
    SingleInstanceIPC.dispose();
    _dataStore.dispose().then((_) => Hive.close());
    trayManager.removeListener(this);
    SoundManager.dispose();
    navigationState.stopPeriodicRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeCustomizationProvider()),
        ChangeNotifierProvider.value(value: navigationState),
        if (autoUpdates) ChangeNotifierProvider.value(value: UpdateService()),
      ],
      child: _AppWithTheme(
        initialTheme: widget.initialTheme,
        locale: _locale,
        setLocale: setLocale,
      ),
    );
  }
}

void _hideApp() {
  Platform.isMacOS ? MacOSWindow.hide() : appWindow.hide();
  navigationState.stopPeriodicRefresh();
}

// ============================================================================
// APP WITH THEME
// ============================================================================

class _AppWithTheme extends StatelessWidget {
  final AdaptiveThemeMode initialTheme;
  final Locale? locale;
  final Function(Locale) setLocale;

  const _AppWithTheme({
    required this.initialTheme,
    required this.locale,
    required this.setLocale,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeCustomizationProvider>();
    final customTheme = themeProvider.currentTheme;
    final themeMode = themeProvider.adaptiveThemeMode;
    final themeKey = '${customTheme.id}_${themeProvider.themeMode}';

    return FluentAdaptiveTheme(
      key: ValueKey(themeKey),
      light: buildLightTheme(customTheme),
      dark: buildDarkTheme(customTheme),
      initial: themeMode,
      builder: (theme, darkTheme) => FluentApp(
        title: 'Scolect',
        theme: theme,
        darkTheme: darkTheme,
        navigatorKey: navigatorKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        debugShowCheckedModeBanner: false,
        home: HomePage(setLocale: setLocale),
      ),
    );
  }
}
// ============================================================================
// HOME PAGE WITH CUSTOM COLLAPSIBLE SIDEBAR
// ============================================================================

class HomePage extends StatefulWidget {
  final Function(Locale) setLocale;

  const HomePage({
    super.key,
    required this.setLocale,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _isSidebarExpanded = true;
  late AnimationController _sidebarAnimController;
  late Animation<double> _sidebarAnimation;

  @override
  void initState() {
    super.initState();
    _sidebarAnimController = AnimationController(
      vsync: this,
      duration: AppDesign.animMedium,
    );
    _sidebarAnimation = CurvedAnimation(
      parent: _sidebarAnimController,
      curve: Curves.easeInOutCubic,
    );
    _sidebarAnimController.value = 1.0;
  }

  @override
  void dispose() {
    _sidebarAnimController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
      if (_isSidebarExpanded) {
        _sidebarAnimController.forward();
      } else {
        _sidebarAnimController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // WATCH the navigation state
    final navState = context.watch<NavigationState>();

    final themeProvider = context.watch<ThemeCustomizationProvider>();
    final customTheme = themeProvider.currentTheme;
    return Column(
      children: [
        EnhancedTitleBar(
          onToggleSidebar: _toggleSidebar,
          isSidebarExpanded: _isSidebarExpanded,
          customTheme: customTheme,
        ),
        Expanded(
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _sidebarAnimation,
                builder: (context, child) {
                  final expandProgress = _sidebarAnimation.value;
                  final width = lerpDouble(
                    AppDesign.sidebarCollapsedWidth,
                    AppDesign.sidebarExpandedWidth,
                    expandProgress,
                  )!;

                  return SizedBox(
                    width: width,
                    child: CustomSidebar(
                      width: width,
                      isExpanded: _isSidebarExpanded,
                      expandProgress: expandProgress,
                      selectedIndex: navState.selectedIndex, // FROM PROVIDER
                      onItemSelected: navState.changeIndex, // FROM PROVIDER
                      isDark: isDark,
                      l10n: l10n,
                      customTheme: customTheme,
                    ),
                  );
                },
              ),
              Expanded(
                child: _ContentArea(
                  selectedIndex: navState.selectedIndex, // FROM PROVIDER
                  setLocale: widget.setLocale,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
// ============================================================================
// ANIMATED BUILDER HELPER (Since AnimatedBuilder doesn't exist)
// ============================================================================

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

class AnimatedBuilder2 extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder2({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

// ============================================================================
// CUSTOM SIDEBAR - FIXED
// ============================================================================

class CustomSidebar extends StatelessWidget {
  final double width;
  final bool isExpanded;
  final double expandProgress;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isDark;
  final AppLocalizations l10n;
  final CustomThemeData customTheme;

  const CustomSidebar({
    super.key,
    required this.width,
    required this.isExpanded,
    required this.expandProgress,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.isDark,
    required this.l10n,
    required this.customTheme,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = _getNavItems();
    final isCompact = expandProgress < 0.5;

    return ClipRect(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: isDark
              ? customTheme.darkSurfaceSecondary
              : customTheme.lightSurface,
          border: Border(
            right: BorderSide(
              color: isDark ? customTheme.darkBorder : customTheme.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            // Header
            _SidebarHeader(
              expandProgress: expandProgress,
              isDark: isDark,
              l10n: l10n,
              isCompact: isCompact,
            ),

            SizedBox(
                height: isCompact ? AppDesign.spacingXs : AppDesign.spacingSm),

            // Navigation Items
            Expanded(
              child: ClipRect(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        isCompact ? AppDesign.spacingXs : AppDesign.spacingMd,
                    vertical: AppDesign.spacingSm,
                  ),
                  itemCount: navItems.length,
                  itemBuilder: (context, index) {
                    final item = navItems[index];

                    // Handle separator
                    if (item.isSeparator) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: isCompact
                              ? AppDesign.spacingSm
                              : AppDesign.spacingMd,
                          horizontal: isCompact ? AppDesign.spacingSm : 0,
                        ),
                        child: Divider(
                          style: DividerThemeData(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppDesign.darkBorder
                                  : AppDesign.lightBorder,
                            ),
                          ),
                        ),
                      );
                    }

                    // Handle regular nav item
                    return _SidebarItem(
                      icon: item.icon!,
                      label: item.label!,
                      isSelected: selectedIndex == item.index,
                      expandProgress: expandProgress,
                      isDark: isDark,
                      isCompact: isCompact,
                      onTap: () => onItemSelected(item.index!),
                    );
                  },
                ),
              ),
            ),

            // Footer - Version
            _SidebarFooter(
              expandProgress: expandProgress,
              isDark: isDark,
              isCompact: isCompact,
            ),
          ],
        ),
      ),
    );
  }

  List<_NavItemData> _getNavItems() {
    return [
      _NavItemData(icon: FluentIcons.home, label: l10n.navOverview, index: 0),
      _NavItemData(
          icon: FluentIcons.app_icon_default_list,
          label: l10n.navApplications,
          index: 1),
      _NavItemData(
          icon: FluentIcons.alert_settings,
          label: l10n.navAlertsLimits,
          index: 2),
      _NavItemData(
          icon: FluentIcons.analytics_report, label: l10n.navReports, index: 3),
      _NavItemData(
          icon: FluentIcons.red_eye, label: l10n.navFocusMode, index: 4),
      _NavItemData.separator(),
      _NavItemData(
          icon: FluentIcons.settings, label: l10n.navSettings, index: 5),
      _NavItemData(icon: FluentIcons.chat_bot, label: l10n.navHelp, index: 6),
    ];
  }
}

// ============================================================================
// NAV ITEM DATA - FIXED with named parameters
// ============================================================================

class _NavItemData {
  final IconData? icon;
  final String? label;
  final int? index;
  final bool isSeparator;

  const _NavItemData({
    required this.icon,
    required this.label,
    required this.index,
  }) : isSeparator = false;

  const _NavItemData.separator()
      : icon = null,
        label = null,
        index = null,
        isSeparator = true;
}

// ============================================================================
// SIDEBAR HEADER
// ============================================================================

class _SidebarHeader extends StatelessWidget {
  final double expandProgress;
  final bool isDark;
  final AppLocalizations l10n;
  final bool isCompact;

  const _SidebarHeader({
    required this.expandProgress,
    required this.isDark,
    required this.l10n,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final design = AppDesign.of(context);
    final padding = isCompact ? AppDesign.spacingSm : AppDesign.spacingLg;
    final margin = isCompact ? AppDesign.spacingXs : AppDesign.spacingMd;
    return ClipRect(
      child: Container(
        margin: EdgeInsets.all(margin),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: design.subtleGradient(isDark),
          borderRadius: BorderRadius.circular(AppDesign.radiusLg),
          border: Border.all(
            color: design.primaryAccent.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // App Icon - Always visible
            Container(
              padding: const EdgeInsets.all(AppDesign.spacingSm),
              decoration: BoxDecoration(
                gradient: design.primaryGradient,
                borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: design.primaryAccent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icons/tray_icon_mac.png',
                width: 20,
                height: 20,
              ),
            ),

            // Title & Subtitle (only when expanded enough)
            if (expandProgress > 0.6) ...[
              const SizedBox(width: AppDesign.spacingMd),
              Flexible(
                child: Opacity(
                  opacity: ((expandProgress - 0.6) / 0.4).clamp(0.0, 1.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.appName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? design.darkTextPrimary
                              : design.lightTextPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.sidebarSubtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? design.darkTextSecondary
                              : design.lightTextSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SIDEBAR ITEM
// ============================================================================

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final double expandProgress;
  final bool isDark;
  final bool isCompact;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.expandProgress,
    required this.isDark,
    required this.isCompact,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final design = AppDesign.of(context);
    // Colors
    Color bgColor = Colors.transparent;
    Color iconColor =
        widget.isDark ? design.darkTextSecondary : design.lightTextSecondary;
    Color textColor = iconColor;

    if (widget.isSelected) {
      bgColor =
          design.primaryAccent.withValues(alpha: widget.isDark ? 0.2 : 0.1);
      iconColor = design.primaryAccent;
      textColor = design.primaryAccent;
    } else if (_isHovering) {
      bgColor = widget.isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.03);
      iconColor =
          widget.isDark ? design.darkTextPrimary : design.lightTextPrimary;
      textColor = iconColor;
    }

    Widget itemContent;

    if (widget.isCompact) {
      // Compact mode - icon only, centered
      itemContent = Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppDesign.spacingMd,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDesign.radiusMd),
          border: widget.isSelected
              ? Border.all(
                  color: design.primaryAccent.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selection indicator bar at top
            if (widget.isSelected)
              Container(
                width: 20,
                height: 3,
                margin: const EdgeInsets.only(bottom: AppDesign.spacingXs),
                decoration: BoxDecoration(
                  color: design.primaryAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            // Icon
            Container(
              padding: const EdgeInsets.all(AppDesign.spacingSm),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? design.primaryAccent.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDesign.radiusSm),
              ),
              child: Icon(
                widget.icon,
                size: 20,
                color: iconColor,
              ),
            ),
          ],
        ),
      );
    } else {
      // Expanded mode - icon with label
      itemContent = Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesign.spacingMd,
          vertical: AppDesign.spacingMd,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDesign.radiusMd),
          border: widget.isSelected
              ? Border.all(
                  color: design.primaryAccent.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            // Selection Indicator
            AnimatedContainer(
              duration: AppDesign.animFast,
              width: 3,
              height: widget.isSelected ? 20 : 0,
              margin: const EdgeInsets.only(right: AppDesign.spacingSm),
              decoration: BoxDecoration(
                color: design.primaryAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Icon
            Container(
              padding: const EdgeInsets.all(AppDesign.spacingXs),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? design.primaryAccent.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDesign.radiusSm),
              ),
              child: Icon(
                widget.icon,
                size: 18,
                color: iconColor,
              ),
            ),

            const SizedBox(width: AppDesign.spacingMd),

            // Label
            Expanded(
              child: Opacity(
                opacity: widget.expandProgress.clamp(0.0, 1.0),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),

            // Selected indicator arrow
            if (widget.isSelected)
              Opacity(
                opacity: widget.expandProgress.clamp(0.0, 1.0),
                child: Icon(
                  FluentIcons.chevron_right,
                  size: 12,
                  color: design.primaryAccent,
                ),
              ),
          ],
        ),
      );
    }

    return Tooltip(
      message: widget.isCompact ? widget.label : '',
      style: TooltipThemeData(
        decoration: BoxDecoration(
          color: widget.isDark ? AppDesign.darkSurface : AppDesign.lightSurface,
          borderRadius: BorderRadius.circular(AppDesign.radiusSm),
          border: Border.all(
            color: widget.isDark ? AppDesign.darkBorder : AppDesign.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        textStyle: TextStyle(
          color:
              widget.isDark ? design.darkTextPrimary : design.lightTextPrimary,
          fontSize: 12,
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: itemContent,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SIDEBAR FOOTER
// ============================================================================

class _SidebarFooter extends StatelessWidget {
  final double expandProgress;
  final bool isDark;
  final bool isCompact;

  const _SidebarFooter({
    required this.expandProgress,
    required this.isDark,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final version = "v${SettingsManager().versionInfo["version"]}";
    final design = AppDesign.of(context);
    return ClipRect(
      child: Container(
        padding: EdgeInsets.all(
            isCompact ? AppDesign.spacingSm : AppDesign.spacingMd),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppDesign.darkBorder : AppDesign.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FluentIcons.info,
              size: 14,
              color:
                  isDark ? design.darkTextSecondary : design.lightTextSecondary,
            ),
            if (!isCompact && expandProgress > 0.6) ...[
              const SizedBox(width: AppDesign.spacingSm),
              Flexible(
                child: Opacity(
                  opacity: ((expandProgress - 0.6) / 0.4).clamp(0.0, 1.0),
                  child: Text(
                    version,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? design.darkTextSecondary
                          : design.lightTextSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CONTENT AREA
// ============================================================================

class _ContentArea extends StatelessWidget {
  final int selectedIndex;
  final Function(Locale) setLocale;
  final bool isDark;

  const _ContentArea({
    required this.selectedIndex,
    required this.setLocale,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppDesign.darkBackground : AppDesign.lightBackground,
      child: AnimatedSwitcher(
        duration: AppDesign.animMedium,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: _getPage(selectedIndex),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const Overview(key: ValueKey('overview'));
      case 1:
        return const Applications(key: ValueKey('applications'));
      case 2:
        return const AlertsLimits(key: ValueKey('alerts'));
      case 3:
        return const Reports(key: ValueKey('reports'));
      case 4:
        return const FocusMode(key: ValueKey('focus'));
      case 5:
        return Settings(key: const ValueKey('settings'), setLocale: setLocale);
      case 6:
        return const Help(key: ValueKey('help'));
      default:
        return const Overview(key: ValueKey('overview'));
    }
  }
}

// ============================================================================
// ENHANCED TITLE BAR
// ============================================================================

class EnhancedTitleBar extends StatelessWidget {
  final VoidCallback onToggleSidebar;
  final bool isSidebarExpanded;
  final CustomThemeData customTheme; // ✅ ADD THIS

  const EnhancedTitleBar({
    super.key,
    required this.onToggleSidebar,
    required this.isSidebarExpanded,
    required this.customTheme, // ✅ ADD THIS
  });

  @override
  Widget build(BuildContext context) {
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isMacOS = Platform.isMacOS;

    return WindowTitleBarBox(
      child: Container(
        decoration: BoxDecoration(
          // ✅ USE customTheme
          color: isDark
              ? customTheme.darkSurfaceSecondary
              : customTheme.lightSurface,
          border: Border(
            bottom: BorderSide(
              // ✅ USE customTheme
              color: isDark ? customTheme.darkBorder : customTheme.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // macOS traffic light buttons
            if (isMacOS) const EnhancedMacOSButtons(),

            // Sidebar Toggle Button
            if (!isMacOS) const SizedBox(width: AppDesign.spacingSm),
            _SidebarToggleButton(
              onPressed: onToggleSidebar,
              isExpanded: isSidebarExpanded,
              isDark: isDark,
            ),

            // Draggable area with title
            Expanded(
              child: MoveWindow(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.appWindowTitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          // ✅ USE customTheme
                          color: isDark
                              ? customTheme.darkTextPrimary
                              : customTheme.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Window buttons for Windows
            if (!isMacOS)
              EnhancedWindowButtons(
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }
}
// ============================================================================
// SIDEBAR TOGGLE BUTTON
// ============================================================================

class _SidebarToggleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isExpanded;
  final bool isDark;

  const _SidebarToggleButton({
    required this.onPressed,
    required this.isExpanded,
    required this.isDark,
  });

  @override
  State<_SidebarToggleButton> createState() => _SidebarToggleButtonState();
}

class _SidebarToggleButtonState extends State<_SidebarToggleButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final design = AppDesign.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: AppDesign.animFast,
          margin: const EdgeInsets.symmetric(horizontal: AppDesign.spacingSm),
          padding: const EdgeInsets.all(AppDesign.spacingSm),
          decoration: BoxDecoration(
            color: _isHovering
                ? (widget.isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDesign.radiusSm),
          ),
          child: AnimatedRotation(
            turns: widget.isExpanded ? 0 : 0.5,
            duration: AppDesign.animMedium,
            child: Icon(
              FluentIcons.collapse_menu,
              size: 14,
              color: widget.isDark
                  ? design.darkTextSecondary
                  : design.lightTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WINDOW BUTTONS (Windows)
// ============================================================================

class EnhancedWindowButtons extends StatelessWidget {
  final bool isDark;

  const EnhancedWindowButtons({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _WindowButton(
          icon: FluentIcons.chrome_minimize,
          onPressed: () => appWindow.minimize(),
          isDark: isDark,
        ),
        _WindowButton(
          icon: FluentIcons.square_shape,
          onPressed: () => appWindow.maximizeOrRestore(),
          isDark: isDark,
        ),
        _WindowButton(
          icon: FluentIcons.chrome_close,
          onPressed: () => _hideApp(),
          isDark: isDark,
          isClose: true,
        ),
      ],
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDark;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    required this.isDark,
    this.isClose = false,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final design = AppDesign.of(context);
    Color bgColor = Colors.transparent;
    Color iconColor =
        widget.isDark ? design.darkTextSecondary : design.lightTextSecondary;

    if (_isHovering) {
      if (widget.isClose) {
        bgColor = design.errorColor;
        iconColor = Colors.white;
      } else {
        bgColor = widget.isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05);
      }
    }

    if (_isPressed) {
      bgColor = widget.isClose
          ? design.errorColor.withValues(alpha: 0.8)
          : (widget.isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.1));
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() {
        _isHovering = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: AppDesign.animFast,
          width: 46,
          height: double.infinity,
          color: bgColor,
          child: Center(
            child: Icon(
              widget.icon,
              size: 10,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MACOS BUTTONS
// ============================================================================

class EnhancedMacOSButtons extends StatefulWidget {
  const EnhancedMacOSButtons({super.key});

  @override
  State<EnhancedMacOSButtons> createState() => _EnhancedMacOSButtonsState();
}

class _EnhancedMacOSButtonsState extends State<EnhancedMacOSButtons> {
  bool _isHoveringGroup = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHoveringGroup = true),
      onExit: (_) => setState(() => _isHoveringGroup = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MacOSButton(
              color: const Color(0xFFFF5F57),
              icon: FluentIcons.chrome_close,
              showIcon: _isHoveringGroup,
              onPressed: () => _hideApp(),
            ),
            const SizedBox(width: 8),
            _MacOSButton(
              color: const Color(0xFFFFBD2E),
              icon: FluentIcons.chrome_minimize,
              showIcon: _isHoveringGroup,
              onPressed: () => MacOSWindow.minimize(),
            ),
            const SizedBox(width: 8),
            _MacOSButton(
              color: const Color(0xFF28CA41),
              icon: FluentIcons.full_screen,
              showIcon: _isHoveringGroup,
              onPressed: () => MacOSWindow.maximize(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacOSButton extends StatefulWidget {
  final Color color;
  final IconData icon;
  final bool showIcon;
  final VoidCallback onPressed;

  const _MacOSButton({
    required this.color,
    required this.icon,
    required this.showIcon,
    required this.onPressed,
  });

  @override
  State<_MacOSButton> createState() => _MacOSButtonState();
}

class _MacOSButtonState extends State<_MacOSButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() {
        _isHovering = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: AppDesign.animFast,
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _isPressed
                ? widget.color.withValues(alpha: 0.7)
                : (_isHovering
                    ? widget.color.withValues(alpha: 0.9)
                    : widget.color),
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withValues(alpha: 0.3),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4),
                blurRadius: _isHovering ? 4 : 2,
                offset: const Offset(0, 0.5),
              ),
            ],
          ),
          child: AnimatedOpacity(
            duration: AppDesign.animFast,
            opacity: widget.showIcon ? 1.0 : 0.0,
            child: Center(
              child: Icon(
                widget.icon,
                size: 7,
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
