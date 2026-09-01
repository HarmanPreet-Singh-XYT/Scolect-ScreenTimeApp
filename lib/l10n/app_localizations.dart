import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart' deferred as app_localizations_ar;
import 'app_localizations_bn.dart' deferred as app_localizations_bn;
import 'app_localizations_en.dart' deferred as app_localizations_en;
import 'app_localizations_es.dart' deferred as app_localizations_es;
import 'app_localizations_fr.dart' deferred as app_localizations_fr;
import 'app_localizations_hi.dart' deferred as app_localizations_hi;
import 'app_localizations_id.dart' deferred as app_localizations_id;
import 'app_localizations_ja.dart' deferred as app_localizations_ja;
import 'app_localizations_pt.dart' deferred as app_localizations_pt;
import 'app_localizations_ru.dart' deferred as app_localizations_ru;
import 'app_localizations_ur.dart' deferred as app_localizations_ur;
import 'app_localizations_zh.dart' deferred as app_localizations_zh;

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('ur'),
    Locale('zh')
  ];

  /// The title shown in the window title bar
  ///
  /// In en, this message translates to:
  /// **'Scolect - Track Screen Time & App Usage'**
  String get appWindowTitle;

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Scolect'**
  String get appName;

  /// The app title/tagline
  ///
  /// In en, this message translates to:
  /// **'Productive ScreenTime'**
  String get appTitle;

  /// Title shown in the sidebar
  ///
  /// In en, this message translates to:
  /// **'ScreenTime'**
  String get sidebarTitle;

  /// Subtitle shown in the sidebar
  ///
  /// In en, this message translates to:
  /// **'Open Source'**
  String get sidebarSubtitle;

  /// Tray menu item to show the main window
  ///
  /// In en, this message translates to:
  /// **'Show Window'**
  String get trayShowWindow;

  /// Tray menu item to start focus mode
  ///
  /// In en, this message translates to:
  /// **'Start Focus Mode'**
  String get trayStartFocusMode;

  /// Tray menu item to stop focus mode
  ///
  /// In en, this message translates to:
  /// **'Stop Focus Mode'**
  String get trayStopFocusMode;

  /// Tray menu item for reports
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get trayReports;

  /// Tray menu item for alerts and limits
  ///
  /// In en, this message translates to:
  /// **'Alerts & Limits'**
  String get trayAlertsLimits;

  /// Tray menu item for applications
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get trayApplications;

  /// Tray menu item to disable notifications
  ///
  /// In en, this message translates to:
  /// **'Disable Notifications'**
  String get trayDisableNotifications;

  /// Tray menu item to enable notifications
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get trayEnableNotifications;

  /// Prefix text for version display in tray
  ///
  /// In en, this message translates to:
  /// **'Version: '**
  String get trayVersionPrefix;

  /// Version display with placeholder
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String trayVersion(String version);

  /// Tray menu item to exit the application
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get trayExit;

  /// Navigation item for overview page
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get navOverview;

  /// Navigation item for applications page
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get navApplications;

  /// Navigation item for alerts and limits page
  ///
  /// In en, this message translates to:
  /// **'Alerts & Limits'**
  String get navAlertsLimits;

  /// Navigation item for reports page
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// Navigation item for focus mode page
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get navFocusMode;

  /// Navigation item for browser / website tracking page
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get navBrowser;

  /// Navigation item for settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Navigation item for help page
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get navHelp;

  /// Navigation item for the isolated Private Mode page
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get navPrivate;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// No description provided for @faqCategoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Questions'**
  String get faqCategoryGeneral;

  /// No description provided for @faqCategoryApplications.
  ///
  /// In en, this message translates to:
  /// **'Applications Management'**
  String get faqCategoryApplications;

  /// No description provided for @faqCategoryReports.
  ///
  /// In en, this message translates to:
  /// **'Usage Analytics & Reports'**
  String get faqCategoryReports;

  /// No description provided for @faqCategoryAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts & Limits'**
  String get faqCategoryAlerts;

  /// No description provided for @faqCategoryFocusMode.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode & Pomodoro Timer'**
  String get faqCategoryFocusMode;

  /// No description provided for @faqCategorySettings.
  ///
  /// In en, this message translates to:
  /// **'Settings & Customization'**
  String get faqCategorySettings;

  /// No description provided for @faqCategoryBrowser.
  ///
  /// In en, this message translates to:
  /// **'Browser Extension'**
  String get faqCategoryBrowser;

  /// No description provided for @faqCategoryTroubleshooting.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting'**
  String get faqCategoryTroubleshooting;

  /// No description provided for @faqGeneralQ1.
  ///
  /// In en, this message translates to:
  /// **'How does Scolect track screen time?'**
  String get faqGeneralQ1;

  /// No description provided for @faqGeneralA1.
  ///
  /// In en, this message translates to:
  /// **'Scolect has two tracking surfaces. The desktop app monitors which native application is in the foreground on macOS or Windows and measures how long you spend in it. The browser extension tracks time spent on each website domain you visit in Chrome. Both surfaces store data locally on your device — nothing is sent to any server.'**
  String get faqGeneralA1;

  /// No description provided for @faqGeneralQ2.
  ///
  /// In en, this message translates to:
  /// **'What makes an app or website \'Productive\'?'**
  String get faqGeneralQ2;

  /// No description provided for @faqGeneralA2.
  ///
  /// In en, this message translates to:
  /// **'You decide. In the Applications section you can toggle any app as productive. Productive apps count toward your Productive Time metric in Reports, which shows you the share of your screen time spent on work-related or beneficial apps.'**
  String get faqGeneralA2;

  /// No description provided for @faqGeneralQ3.
  ///
  /// In en, this message translates to:
  /// **'How accurate is the tracking?'**
  String get faqGeneralQ3;

  /// No description provided for @faqGeneralA3.
  ///
  /// In en, this message translates to:
  /// **'The desktop app uses OS-level foreground window detection, so it only counts time while an app is the active window — idle time or locked screens are not counted. The browser extension starts a timer when you switch to a tab and pauses it when you switch away or close the tab, so visit time reflects actual attention, not just open tabs.'**
  String get faqGeneralA3;

  /// No description provided for @faqGeneralQ4.
  ///
  /// In en, this message translates to:
  /// **'Can I customize how apps are categorized?'**
  String get faqGeneralQ4;

  /// No description provided for @faqGeneralA4.
  ///
  /// In en, this message translates to:
  /// **'Yes. In the Applications section you can create custom categories, rename existing ones, and reassign any app to a different category. Categories flow through to your reports and charts, so organizing apps into meaningful groups makes analytics more useful.'**
  String get faqGeneralA4;

  /// No description provided for @faqGeneralQ5.
  ///
  /// In en, this message translates to:
  /// **'What insights does Scolect give me?'**
  String get faqGeneralQ5;

  /// No description provided for @faqGeneralA5.
  ///
  /// In en, this message translates to:
  /// **'You get: total and productive screen time, most-used apps and websites, daily and weekly usage graphs, time-of-day usage patterns (morning / afternoon / evening / night), focus session history, and per-app breakdown with trends. Reports also support Excel export for offline analysis.'**
  String get faqGeneralA5;

  /// No description provided for @faqGeneralQ6.
  ///
  /// In en, this message translates to:
  /// **'Which languages are supported and how do I change language?'**
  String get faqGeneralQ6;

  /// No description provided for @faqGeneralA6.
  ///
  /// In en, this message translates to:
  /// **'Language can be changed in Settings under the General section — all available languages are listed there. Translations are AI-generated from English, so some may be imperfect. If you spot an error you can report it via the Report Bug button in Settings, or open an issue on GitHub. Translation contributions are welcome!'**
  String get faqGeneralA6;

  /// No description provided for @faqAppsQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I stop tracking a specific app?'**
  String get faqAppsQ1;

  /// No description provided for @faqAppsA1.
  ///
  /// In en, this message translates to:
  /// **'Open the Applications section, find the app, and click the edit (pencil) icon. You can toggle \'Track Usage\' off — the app will no longer accumulate screen time. You can also toggle \'Visible in Reports\' to hide it from charts without stopping tracking.'**
  String get faqAppsA1;

  /// No description provided for @faqAppsQ2.
  ///
  /// In en, this message translates to:
  /// **'Can I search and filter my applications?'**
  String get faqAppsQ2;

  /// No description provided for @faqAppsA2.
  ///
  /// In en, this message translates to:
  /// **'Yes. The Applications section has a search bar and filter options. You can filter by category, productivity status, tracking status, and visibility to quickly find what you are looking for.'**
  String get faqAppsA2;

  /// No description provided for @faqAppsQ3.
  ///
  /// In en, this message translates to:
  /// **'What can I edit per application?'**
  String get faqAppsQ3;

  /// No description provided for @faqAppsA3.
  ///
  /// In en, this message translates to:
  /// **'For each application you can set: category, productive or non-productive status, whether tracking is active, whether it appears in reports, and an individual daily time limit. Limits trigger a notification when the app hits the threshold.'**
  String get faqAppsA3;

  /// No description provided for @faqAppsQ4.
  ///
  /// In en, this message translates to:
  /// **'How are initial categories assigned?'**
  String get faqAppsQ4;

  /// No description provided for @faqAppsA4.
  ///
  /// In en, this message translates to:
  /// **'Scolect makes a best-guess category based on the app name when it is first seen. You have full control to change this — create new categories, rename them, and reassign apps at any time.'**
  String get faqAppsA4;

  /// No description provided for @faqAppsQ5.
  ///
  /// In en, this message translates to:
  /// **'Why is an app showing a very short or zero time?'**
  String get faqAppsQ5;

  /// No description provided for @faqAppsA5.
  ///
  /// In en, this message translates to:
  /// **'Tracking starts from the moment the app is first detected in the foreground. If you just installed Scolect, historical usage is not available — only time going forward is recorded. Very short times usually mean you briefly switched to that app and away again.'**
  String get faqAppsA5;

  /// No description provided for @faqReportsQ1.
  ///
  /// In en, this message translates to:
  /// **'What types of reports are available?'**
  String get faqReportsQ1;

  /// No description provided for @faqReportsA1.
  ///
  /// In en, this message translates to:
  /// **'Reports include: summary cards (total screen time, productive time, most used app, focus sessions), a daily usage bar chart, weekly usage trends with comparisons, detailed per-app usage table, and a time-of-day usage pattern breakdown. You can also export all data to an Excel file.'**
  String get faqReportsA1;

  /// No description provided for @faqReportsQ2.
  ///
  /// In en, this message translates to:
  /// **'How do I export my data?'**
  String get faqReportsQ2;

  /// No description provided for @faqReportsA2.
  ///
  /// In en, this message translates to:
  /// **'In the Reports section, look for the Export button in the top-right area. This generates an Excel (.xlsx) file with your usage data. The file is saved to your Downloads folder. The browser extension dashboard also has an export option for website usage.'**
  String get faqReportsA2;

  /// No description provided for @faqReportsQ3.
  ///
  /// In en, this message translates to:
  /// **'Can I compare usage across different time periods?'**
  String get faqReportsQ3;

  /// No description provided for @faqReportsA3.
  ///
  /// In en, this message translates to:
  /// **'Yes. The Reports section lets you switch between Last 7 Days, Last 30 Days, and custom date ranges. The weekly trend graph shows week-over-week changes, and the summary cards display a percentage change compared to the previous period.'**
  String get faqReportsA3;

  /// No description provided for @faqReportsQ4.
  ///
  /// In en, this message translates to:
  /// **'What is the \'Usage Pattern\' analysis?'**
  String get faqReportsQ4;

  /// No description provided for @faqReportsA4.
  ///
  /// In en, this message translates to:
  /// **'Usage Pattern splits your screen time into four day segments: morning (6 AM–12 PM), afternoon (12 PM–6 PM), evening (6 PM–10 PM), and night (10 PM–6 AM). This helps you see when you are most active on your device.'**
  String get faqReportsA4;

  /// No description provided for @faqAlertsQ1.
  ///
  /// In en, this message translates to:
  /// **'How do screen time limits work?'**
  String get faqAlertsQ1;

  /// No description provided for @faqAlertsA1.
  ///
  /// In en, this message translates to:
  /// **'You can set a daily overall screen time limit and individual limits per app. When you hit a limit, Scolect sends a desktop notification. Optionally, apps can be blocked when their limit is reached — the app will be prevented from taking focus. Limits reset each day at midnight.'**
  String get faqAlertsA1;

  /// No description provided for @faqAlertsQ2.
  ///
  /// In en, this message translates to:
  /// **'What happens when an app is blocked after hitting its limit?'**
  String get faqAlertsQ2;

  /// No description provided for @faqAlertsA2.
  ///
  /// In en, this message translates to:
  /// **'When blocking is enabled and an app reaches its daily limit, Scolect will attempt to bring focus away from it and notify you. On macOS this redirects you back to the previous app. You can always go to Alerts & Limits and temporarily disable blocking or raise the limit if needed.'**
  String get faqAlertsA2;

  /// No description provided for @faqAlertsQ3.
  ///
  /// In en, this message translates to:
  /// **'What notification options are available?'**
  String get faqAlertsQ3;

  /// No description provided for @faqAlertsA3.
  ///
  /// In en, this message translates to:
  /// **'You can enable or disable notifications for: screen time limit reached, individual app limits, focus session start/end, and frequent reminder alerts. Reminder alerts fire at a configurable interval (1, 5, 15, 30, or 60 minutes) to keep you aware of ongoing usage.'**
  String get faqAlertsA3;

  /// No description provided for @faqAlertsQ4.
  ///
  /// In en, this message translates to:
  /// **'Can I set different limits for different apps?'**
  String get faqAlertsQ4;

  /// No description provided for @faqAlertsA4.
  ///
  /// In en, this message translates to:
  /// **'Yes. In the Applications section, open any app\'s edit panel and set a per-app daily limit. You can also set limits directly from the Alerts & Limits section. Each app has its own independent limit and reset cycle.'**
  String get faqAlertsA4;

  /// No description provided for @faqFocusQ1.
  ///
  /// In en, this message translates to:
  /// **'What Focus Modes are available?'**
  String get faqFocusQ1;

  /// No description provided for @faqFocusA1.
  ///
  /// In en, this message translates to:
  /// **'Three preset modes are available: Deep Work (longer focused sessions for complex tasks), Quick Tasks (shorter bursts for lightweight work), and Reading Mode (relaxed timing for reading or research). Each mode pre-fills the Pomodoro timer with sensible defaults, and you can customize all durations manually.'**
  String get faqFocusA1;

  /// No description provided for @faqFocusQ2.
  ///
  /// In en, this message translates to:
  /// **'How do I customize the Pomodoro timer?'**
  String get faqFocusQ2;

  /// No description provided for @faqFocusA2.
  ///
  /// In en, this message translates to:
  /// **'In the Focus Mode section, open the settings icon on the timer card. You can set work duration, short break length, long break duration, the number of sessions before a long break, and whether the next session auto-starts. Changes apply immediately to the current timer.'**
  String get faqFocusA2;

  /// No description provided for @faqFocusQ3.
  ///
  /// In en, this message translates to:
  /// **'What does the Focus Mode history show?'**
  String get faqFocusQ3;

  /// No description provided for @faqFocusA3.
  ///
  /// In en, this message translates to:
  /// **'The history tab shows daily session counts, a trend graph over the past weeks, average session duration, total accumulated focus time, and a breakdown of how your time was split between work, short breaks, and long breaks.'**
  String get faqFocusA3;

  /// No description provided for @faqFocusQ4.
  ///
  /// In en, this message translates to:
  /// **'Does Focus Mode block distracting apps?'**
  String get faqFocusQ4;

  /// No description provided for @faqFocusA4.
  ///
  /// In en, this message translates to:
  /// **'Not automatically by default, but you can combine Focus Mode with app limits. Set a very short limit on distracting apps and enable blocking — they will be prevented from taking focus while your session is running. A future update may add direct integration between Focus Mode and app blocking.'**
  String get faqFocusA4;

  /// No description provided for @faqSettingsQ1.
  ///
  /// In en, this message translates to:
  /// **'What can I customize in Settings?'**
  String get faqSettingsQ1;

  /// No description provided for @faqSettingsA1.
  ///
  /// In en, this message translates to:
  /// **'Settings covers: appearance (theme — system, light, or dark; accent color), language, startup behavior (launch on login, start minimized), notification toggles, idle detection timeout, browser extension server port, and data management (clear data, backup and restore).'**
  String get faqSettingsA1;

  /// No description provided for @faqSettingsQ2.
  ///
  /// In en, this message translates to:
  /// **'How do I back up or restore my data?'**
  String get faqSettingsQ2;

  /// No description provided for @faqSettingsA2.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings and find the Backup & Restore section. Tap Export to save a backup file to your Documents folder inside a Scolect-Backups subfolder. To restore, tap Import and select that same file. Only files exported by Scolect can be restored — no other format is supported.'**
  String get faqSettingsA2;

  /// No description provided for @faqSettingsQ3.
  ///
  /// In en, this message translates to:
  /// **'What does \'Clear Data\' delete?'**
  String get faqSettingsQ3;

  /// No description provided for @faqSettingsA3.
  ///
  /// In en, this message translates to:
  /// **'Clear Data removes all recorded usage statistics and focus session history. Your settings and preferences (theme, language, limits, categories) are not affected. This is useful for starting fresh or if you are troubleshooting a data issue.'**
  String get faqSettingsA3;

  /// No description provided for @faqSettingsQ4.
  ///
  /// In en, this message translates to:
  /// **'How do I report a bug or send feedback?'**
  String get faqSettingsQ4;

  /// No description provided for @faqSettingsA4.
  ///
  /// In en, this message translates to:
  /// **'Scroll to the bottom of the Settings section — you will find buttons to Report a Bug, Submit Feedback, and Contact Support. These open the relevant links in your browser. You can also open an issue directly on the Scolect GitHub repository.'**
  String get faqSettingsA4;

  /// No description provided for @faqBrowserQ1.
  ///
  /// In en, this message translates to:
  /// **'What does the browser extension track?'**
  String get faqBrowserQ1;

  /// No description provided for @faqBrowserA1.
  ///
  /// In en, this message translates to:
  /// **'The extension tracks the domain of every website you visit and how long you spend on it, including a visit count per domain per day. All data is stored locally in your browser\'s storage — nothing leaves your device.'**
  String get faqBrowserA1;

  /// No description provided for @faqBrowserQ2.
  ///
  /// In en, this message translates to:
  /// **'What are the extension modes (Standalone, Tracker Only, Hybrid)?'**
  String get faqBrowserQ2;

  /// No description provided for @faqBrowserA2.
  ///
  /// In en, this message translates to:
  /// **'Standalone mode runs the extension independently with its own dashboard and no connection to the desktop app. Tracker Only mode sends your browser usage data to the Scolect desktop app to merge with native app tracking, but the extension dashboard is not used. Hybrid mode does both — the extension has its own dashboard and also syncs data to the desktop app.'**
  String get faqBrowserA2;

  /// No description provided for @faqBrowserQ3.
  ///
  /// In en, this message translates to:
  /// **'How does the extension connect to the desktop app?'**
  String get faqBrowserQ3;

  /// No description provided for @faqBrowserA3.
  ///
  /// In en, this message translates to:
  /// **'The desktop app runs a local HTTP server on port 46000 (configurable in Settings). When the extension is in Tracker Only or Hybrid mode it periodically POSTs your browsing data to that address. Both apps must be running on the same machine. If the desktop app is not open, the extension still tracks locally and will sync the next time a connection is established.'**
  String get faqBrowserA3;

  /// No description provided for @faqBrowserQ4.
  ///
  /// In en, this message translates to:
  /// **'Why is a website being blocked?'**
  String get faqBrowserQ4;

  /// No description provided for @faqBrowserA4.
  ///
  /// In en, this message translates to:
  /// **'A site is blocked when it has reached its daily time limit and blocking is enabled for that limit. You will see a blocked page with a countdown to midnight when the limit resets. To unblock immediately, go to Alerts & Limits in the desktop app and raise or remove the limit for that site, or disable blocking.'**
  String get faqBrowserA4;

  /// No description provided for @faqBrowserQ5.
  ///
  /// In en, this message translates to:
  /// **'Does the extension track in incognito / private mode?'**
  String get faqBrowserQ5;

  /// No description provided for @faqBrowserA5.
  ///
  /// In en, this message translates to:
  /// **'No. By default Chrome extensions do not have access to incognito tabs. If you explicitly grant the extension access to incognito in Chrome\'s extension settings, it will track those tabs too — but this is off by default to respect your privacy.'**
  String get faqBrowserA5;

  /// No description provided for @faqBrowserQ6.
  ///
  /// In en, this message translates to:
  /// **'Where can I see my website usage data?'**
  String get faqBrowserQ6;

  /// No description provided for @faqBrowserA6.
  ///
  /// In en, this message translates to:
  /// **'Open the extension dashboard by clicking the Scolect icon in your browser toolbar and selecting \'Open Dashboard\', or by navigating to the extension\'s index page. The Websites tab shows all tracked domains with time spent, visit counts, and a 7-day history chart for each site. You can also export this data to Excel.'**
  String get faqBrowserA6;

  /// No description provided for @faqTroubleQ1.
  ///
  /// In en, this message translates to:
  /// **'No data is showing in the desktop app'**
  String get faqTroubleQ1;

  /// No description provided for @faqTroubleA1.
  ///
  /// In en, this message translates to:
  /// **'First try closing and reopening the app. If data still does not appear, go to Settings and use Clear Data to reset the database, then restart. If you see a \'hive not opening\' error, navigate to your Documents folder and delete harman_screentime_app_usage_box.hive and harman_screentime_app_usage_box.lock if they exist, then relaunch. Updating to the latest version also resolves most database issues.'**
  String get faqTroubleA1;

  /// No description provided for @faqTroubleQ2.
  ///
  /// In en, this message translates to:
  /// **'The app opens automatically on every startup'**
  String get faqTroubleQ2;

  /// No description provided for @faqTroubleA2.
  ///
  /// In en, this message translates to:
  /// **'This is a known issue on Windows 10. As a workaround, enable \'Launch as Minimized\' in Settings so the app starts in the background without an intrusive window. On macOS you can control this from the Login Items section in System Settings.'**
  String get faqTroubleA2;

  /// No description provided for @faqTroubleQ3.
  ///
  /// In en, this message translates to:
  /// **'The browser extension is not showing any website data'**
  String get faqTroubleQ3;

  /// No description provided for @faqTroubleA3.
  ///
  /// In en, this message translates to:
  /// **'Make sure you have visited at least one website since installing the extension — there is no historical data before installation. Check that the extension has the required permissions (it needs access to all URLs to track time). If the dashboard is open but empty, try closing and reopening the dashboard tab. If the issue persists, try removing and reinstalling the extension.'**
  String get faqTroubleA3;

  /// No description provided for @faqTroubleQ4.
  ///
  /// In en, this message translates to:
  /// **'Extension and desktop app are not syncing'**
  String get faqTroubleQ4;

  /// No description provided for @faqTroubleA4.
  ///
  /// In en, this message translates to:
  /// **'Ensure the desktop app is running and that the extension mode is set to Tracker Only or Hybrid (not Standalone). Check the port number in both places — the desktop app\'s Settings and the extension\'s Settings should both show the same port (default 46000). Firewall or antivirus software can block local connections; try temporarily disabling them to test. The extension will show a connection indicator when sync is active.'**
  String get faqTroubleA4;

  /// Main page title for the analytics/reports section
  ///
  /// In en, this message translates to:
  /// **'Usage Analytics'**
  String get usageAnalytics;

  /// Time period option - last 7 days
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// Time period option - last month
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// Time period option - last 3 months
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get last3Months;

  /// Time period option - all available data
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// Time period option - custom date range
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// Loading message while fetching analytics
  ///
  /// In en, this message translates to:
  /// **'Loading analytics data...'**
  String get loadingAnalyticsData;

  /// Button to retry after an error
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Error message when analytics system fails to start
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize analytics. Please restart the application.'**
  String get failedToInitialize;

  /// Generic error message with error details
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}. Please try again later.'**
  String unexpectedError(String error);

  /// Error message when loading analytics data fails
  ///
  /// In en, this message translates to:
  /// **'Error loading analytics data: {error}. Please check your connection and try again.'**
  String errorLoadingAnalytics(String error);

  /// Title for custom date selection dialog
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customDialogTitle;

  /// Label for date range selection mode
  ///
  /// In en, this message translates to:
  /// **'Date Range:'**
  String get dateRange;

  /// Label for single date selection mode
  ///
  /// In en, this message translates to:
  /// **'Specific Date'**
  String get specificDate;

  /// Label for start date picker
  ///
  /// In en, this message translates to:
  /// **'Start Date: '**
  String get startDate;

  /// Label for end date picker
  ///
  /// In en, this message translates to:
  /// **'End Date: '**
  String get endDate;

  /// Label for single date picker
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Apply/Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Generic OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Error dialog title for invalid date selection
  ///
  /// In en, this message translates to:
  /// **'Invalid Date Range'**
  String get invalidDateRange;

  /// Validation message for date range
  ///
  /// In en, this message translates to:
  /// **'Start date must be before or equal to end date.'**
  String get startDateBeforeEndDate;

  /// Analytics box title for total screen time
  ///
  /// In en, this message translates to:
  /// **'Total Screen Time'**
  String get totalScreenTime;

  /// Analytics box title for productive time
  ///
  /// In en, this message translates to:
  /// **'Productive Time'**
  String get productiveTime;

  /// Analytics box title for most used application
  ///
  /// In en, this message translates to:
  /// **'Most Used App'**
  String get mostUsedApp;

  /// Analytics box title for focus sessions count
  ///
  /// In en, this message translates to:
  /// **'Focus Sessions'**
  String get focusSessions;

  /// Comparison text for positive change
  ///
  /// In en, this message translates to:
  /// **'+{percent}% vs previous period'**
  String positiveComparison(String percent);

  /// Comparison text for negative change
  ///
  /// In en, this message translates to:
  /// **'{percent}% vs previous period'**
  String negativeComparison(String percent);

  /// Accessibility label for icons
  ///
  /// In en, this message translates to:
  /// **'{title} icon'**
  String iconLabel(String title);

  /// Title for daily screen time chart
  ///
  /// In en, this message translates to:
  /// **'DAILY SCREEN TIME'**
  String get dailyScreenTime;

  /// Title for category breakdown pie chart
  ///
  /// In en, this message translates to:
  /// **'CATEGORY BREAKDOWN'**
  String get categoryBreakdown;

  /// Empty state message when no data exists
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @sectionLabel.
  ///
  /// In en, this message translates to:
  /// **'{title} section'**
  String sectionLabel(String title);

  /// Title for detailed application usage table
  ///
  /// In en, this message translates to:
  /// **'Detailed Application Usage'**
  String get detailedApplicationUsage;

  /// Placeholder text for search box
  ///
  /// In en, this message translates to:
  /// **'Search applications'**
  String get searchApplications;

  /// Table column header for app name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameHeader;

  /// Table column header for category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryHeader;

  /// Table column header for total time
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTimeHeader;

  /// Table column header for productivity status
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get productivityHeader;

  /// Table column header for action buttons
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actionsHeader;

  /// Sort dropdown option text
  ///
  /// In en, this message translates to:
  /// **'Sort by: {option}'**
  String sortByOption(String option);

  /// Sort option - by name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortByName;

  /// Sort option - by category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get sortByCategory;

  /// Sort option - by usage time
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get sortByUsage;

  /// Label for productive apps
  ///
  /// In en, this message translates to:
  /// **'Productive'**
  String get productive;

  /// Label for non-productive apps
  ///
  /// In en, this message translates to:
  /// **'Non-Productive'**
  String get nonProductive;

  /// Empty state when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No applications match your search criteria'**
  String get noApplicationsMatch;

  /// Tooltip for view details button
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// Section title in app details dialog
  ///
  /// In en, this message translates to:
  /// **'Usage Summary'**
  String get usageSummary;

  /// Section title for weekly usage chart
  ///
  /// In en, this message translates to:
  /// **'Usage Over Past Week'**
  String get usageOverPastWeek;

  /// Section title for time of day breakdown
  ///
  /// In en, this message translates to:
  /// **'Usage Pattern by Time of Day'**
  String get usagePatternByTimeOfDay;

  /// Section title for usage pattern insights
  ///
  /// In en, this message translates to:
  /// **'Pattern Analysis'**
  String get patternAnalysis;

  /// Label for today's usage
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Label for daily usage limit
  ///
  /// In en, this message translates to:
  /// **'Daily Limit'**
  String get dailyLimit;

  /// Text shown when no limit is set
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// Label for usage trend indicator
  ///
  /// In en, this message translates to:
  /// **'Usage Trend'**
  String get usageTrend;

  /// Label for productivity status
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get productivity;

  /// Trend label - usage increasing
  ///
  /// In en, this message translates to:
  /// **'Increasing'**
  String get increasing;

  /// Trend label - usage decreasing
  ///
  /// In en, this message translates to:
  /// **'Decreasing'**
  String get decreasing;

  /// Trend label - usage stable
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// Stat card label for average daily usage
  ///
  /// In en, this message translates to:
  /// **'Avg. Daily Usage'**
  String get avgDailyUsage;

  /// Stat card label for longest session
  ///
  /// In en, this message translates to:
  /// **'Longest session'**
  String get longestSession;

  /// Stat card label for weekly total
  ///
  /// In en, this message translates to:
  /// **'Weekly Total'**
  String get weeklyTotal;

  /// Empty state for chart with no data
  ///
  /// In en, this message translates to:
  /// **'No historical data available'**
  String get noHistoricalData;

  /// Time of day label - morning hours
  ///
  /// In en, this message translates to:
  /// **'Morning (6-12)'**
  String get morning;

  /// Time of day label - afternoon hours
  ///
  /// In en, this message translates to:
  /// **'Afternoon (12-5)'**
  String get afternoon;

  /// Time of day label - evening hours
  ///
  /// In en, this message translates to:
  /// **'Evening (5-9)'**
  String get evening;

  /// Time of day label - night hours
  ///
  /// In en, this message translates to:
  /// **'Night (9-6)'**
  String get night;

  /// Section title for usage insights
  ///
  /// In en, this message translates to:
  /// **'Usage Insights'**
  String get usageInsights;

  /// Section title for limit status
  ///
  /// In en, this message translates to:
  /// **'Limit Status'**
  String get limitStatus;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Insight about primary usage time
  ///
  /// In en, this message translates to:
  /// **'You primarily use {appName} during {timeOfDay}.'**
  String primaryUsageTime(String appName, String timeOfDay);

  /// Insight about significant usage increase
  ///
  /// In en, this message translates to:
  /// **'Your usage has increased significantly ({percentage}%) compared to the previous period.'**
  String significantIncrease(String percentage);

  /// Insight about upward usage trend
  ///
  /// In en, this message translates to:
  /// **'Your usage is trending upward compared to the previous period.'**
  String get trendingUpward;

  /// Insight about significant usage decrease
  ///
  /// In en, this message translates to:
  /// **'Your usage has decreased significantly ({percentage}%) compared to the previous period.'**
  String significantDecrease(String percentage);

  /// Insight about downward usage trend
  ///
  /// In en, this message translates to:
  /// **'Your usage is trending downward compared to the previous period.'**
  String get trendingDownward;

  /// Insight about consistent usage
  ///
  /// In en, this message translates to:
  /// **'Your usage has been consistent compared to the previous period.'**
  String get consistentUsage;

  /// Insight about productive app status
  ///
  /// In en, this message translates to:
  /// **'This is marked as a productive app in your settings.'**
  String get markedAsProductive;

  /// Insight about non-productive app status
  ///
  /// In en, this message translates to:
  /// **'This is marked as a non-productive app in your settings.'**
  String get markedAsNonProductive;

  /// Insight about most active hour
  ///
  /// In en, this message translates to:
  /// **'Your most active time is around {time}.'**
  String mostActiveTime(String time);

  /// Message when no limit is configured
  ///
  /// In en, this message translates to:
  /// **'No usage limit has been set for this application.'**
  String get noLimitSet;

  /// Message when limit is reached
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your daily limit for this application.'**
  String get limitReached;

  /// Warning message when approaching limit
  ///
  /// In en, this message translates to:
  /// **'You\'re about to reach your daily limit with only {remainingTime} remaining.'**
  String aboutToReachLimit(String remainingTime);

  /// Message showing percentage used
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {percent}% of your daily limit with {remainingTime} remaining.'**
  String percentOfLimitUsed(int percent, String remainingTime);

  /// Message showing remaining time
  ///
  /// In en, this message translates to:
  /// **'You have {time} remaining out of your daily limit.'**
  String remainingTime(String time);

  /// Label for today on charts
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayChart;

  /// Time format - AM hours
  ///
  /// In en, this message translates to:
  /// **'{hour} AM'**
  String hourPeriodAM(int hour);

  /// Time format - PM hours
  ///
  /// In en, this message translates to:
  /// **'{hour} PM'**
  String hourPeriodPM(int hour);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutesOnly.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutesOnly(int minutes);

  /// No description provided for @alertsLimitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts & Limits'**
  String get alertsLimitsTitle;

  /// No description provided for @notificationsSettings.
  ///
  /// In en, this message translates to:
  /// **'Notifications Settings'**
  String get notificationsSettings;

  /// No description provided for @overallScreenTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'Overall Screen Time Limit'**
  String get overallScreenTimeLimit;

  /// No description provided for @applicationLimits.
  ///
  /// In en, this message translates to:
  /// **'Application Limits'**
  String get applicationLimits;

  /// No description provided for @popupAlerts.
  ///
  /// In en, this message translates to:
  /// **'Pop-up Alerts'**
  String get popupAlerts;

  /// No description provided for @frequentAlerts.
  ///
  /// In en, this message translates to:
  /// **'Frequent Alerts'**
  String get frequentAlerts;

  /// No description provided for @soundAlerts.
  ///
  /// In en, this message translates to:
  /// **'Sound Alerts'**
  String get soundAlerts;

  /// No description provided for @systemAlerts.
  ///
  /// In en, this message translates to:
  /// **'System Alerts'**
  String get systemAlerts;

  /// No description provided for @dailyTotalLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily Total Limit: '**
  String get dailyTotalLimit;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @currentUsage.
  ///
  /// In en, this message translates to:
  /// **'Current Usage: '**
  String get currentUsage;

  /// No description provided for @tableName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get tableName;

  /// No description provided for @tableCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get tableCategory;

  /// No description provided for @tableDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily Limit'**
  String get tableDailyLimit;

  /// No description provided for @tableCurrentUsage.
  ///
  /// In en, this message translates to:
  /// **'Current Usage'**
  String get tableCurrentUsage;

  /// No description provided for @tableStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get tableStatus;

  /// No description provided for @tableActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get tableActions;

  /// No description provided for @addLimit.
  ///
  /// In en, this message translates to:
  /// **'Add Limit'**
  String get addLimit;

  /// No description provided for @noApplicationsToDisplay.
  ///
  /// In en, this message translates to:
  /// **'No applications to display'**
  String get noApplicationsToDisplay;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get statusOff;

  /// No description provided for @durationNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get durationNone;

  /// No description provided for @addApplicationLimit.
  ///
  /// In en, this message translates to:
  /// **'Add Application Limit'**
  String get addApplicationLimit;

  /// No description provided for @selectApplication.
  ///
  /// In en, this message translates to:
  /// **'Select Application'**
  String get selectApplication;

  /// No description provided for @selectApplicationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select an application'**
  String get selectApplicationPlaceholder;

  /// No description provided for @enableLimit.
  ///
  /// In en, this message translates to:
  /// **'Enable Limit: '**
  String get enableLimit;

  /// No description provided for @editLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Limit: {appName}'**
  String editLimitTitle(String appName);

  /// No description provided for @failedToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data: {error}'**
  String failedToLoadData(String error);

  /// No description provided for @resetSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings?'**
  String get resetSettingsTitle;

  /// No description provided for @resetSettingsContent.
  ///
  /// In en, this message translates to:
  /// **'If you reset settings, you won\'t be able to recover it. Do you want to reset it?'**
  String get resetSettingsContent;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @applicationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get applicationsTitle;

  /// No description provided for @searchApplication.
  ///
  /// In en, this message translates to:
  /// **'Search Application'**
  String get searchApplication;

  /// No description provided for @tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracked'**
  String get tracking;

  /// No description provided for @hiddenVisible.
  ///
  /// In en, this message translates to:
  /// **'Hidden/Visible'**
  String get hiddenVisible;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a Category'**
  String get selectCategory;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @tableScreenTime.
  ///
  /// In en, this message translates to:
  /// **'Screen Time'**
  String get tableScreenTime;

  /// No description provided for @tableTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tableTracking;

  /// No description provided for @tableHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get tableHidden;

  /// No description provided for @tableEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get tableEdit;

  /// No description provided for @editAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {appName}'**
  String editAppTitle(String appName);

  /// No description provided for @categorySection.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categorySection;

  /// No description provided for @customCategory.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customCategory;

  /// No description provided for @customCategoryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter custom category name'**
  String get customCategoryPlaceholder;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @isProductive.
  ///
  /// In en, this message translates to:
  /// **'Is Productive'**
  String get isProductive;

  /// No description provided for @trackUsage.
  ///
  /// In en, this message translates to:
  /// **'Track Usage'**
  String get trackUsage;

  /// No description provided for @visibleInReports.
  ///
  /// In en, this message translates to:
  /// **'Visible in Reports'**
  String get visibleInReports;

  /// No description provided for @timeLimitsSection.
  ///
  /// In en, this message translates to:
  /// **'Time Limits'**
  String get timeLimitsSection;

  /// No description provided for @enableDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Enable Daily Limit'**
  String get enableDailyLimit;

  /// No description provided for @setDailyTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'Set daily time limit:'**
  String get setDailyTimeLimit;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading overview data: {error}'**
  String errorLoadingData(String error);

  /// No description provided for @focusModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get focusModeTitle;

  /// No description provided for @historySection.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historySection;

  /// No description provided for @trendsSection.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trendsSection;

  /// No description provided for @timeDistributionSection.
  ///
  /// In en, this message translates to:
  /// **'Time Distribution'**
  String get timeDistributionSection;

  /// No description provided for @sessionHistorySection.
  ///
  /// In en, this message translates to:
  /// **'Session History'**
  String get sessionHistorySection;

  /// No description provided for @workSession.
  ///
  /// In en, this message translates to:
  /// **'Work Session'**
  String get workSession;

  /// No description provided for @shortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short Break'**
  String get shortBreak;

  /// No description provided for @longBreak.
  ///
  /// In en, this message translates to:
  /// **'Long Break'**
  String get longBreak;

  /// No description provided for @dateHeader.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateHeader;

  /// No description provided for @durationHeader.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationHeader;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @focusModeSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode Settings'**
  String get focusModeSettingsTitle;

  /// No description provided for @modeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get modeCustom;

  /// No description provided for @modeDeepWork.
  ///
  /// In en, this message translates to:
  /// **'Deep Work (60 min)'**
  String get modeDeepWork;

  /// No description provided for @modeQuickTasks.
  ///
  /// In en, this message translates to:
  /// **'Quick Tasks (25 min)'**
  String get modeQuickTasks;

  /// No description provided for @modeReading.
  ///
  /// In en, this message translates to:
  /// **'Reading (45 min)'**
  String get modeReading;

  /// No description provided for @workDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Work Duration: {minutes} min'**
  String workDurationLabel(int minutes);

  /// No description provided for @shortBreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Short Break'**
  String shortBreakLabel(int minutes);

  /// No description provided for @longBreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Long Break'**
  String longBreakLabel(int minutes);

  /// No description provided for @autoStartNextSession.
  ///
  /// In en, this message translates to:
  /// **'Auto-start next session'**
  String get autoStartNextSession;

  /// No description provided for @blockDistractions.
  ///
  /// In en, this message translates to:
  /// **'Block distractions during focus mode'**
  String get blockDistractions;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @errorLoadingFocusModeData.
  ///
  /// In en, this message translates to:
  /// **'Error loading focus mode data: {error}'**
  String errorLoadingFocusModeData(String error);

  /// No description provided for @overviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Overview'**
  String get overviewTitle;

  /// No description provided for @startFocusMode.
  ///
  /// In en, this message translates to:
  /// **'Start Focus Mode'**
  String get startFocusMode;

  /// No description provided for @loadingProductivityData.
  ///
  /// In en, this message translates to:
  /// **'Loading your productivity data...'**
  String get loadingProductivityData;

  /// No description provided for @noActivityDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No activity data available yet'**
  String get noActivityDataAvailable;

  /// No description provided for @startUsingApplications.
  ///
  /// In en, this message translates to:
  /// **'Start using your applications to track screen time and productivity.'**
  String get startUsingApplications;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshData;

  /// No description provided for @topApplications.
  ///
  /// In en, this message translates to:
  /// **'Top Applications'**
  String get topApplications;

  /// No description provided for @noAppUsageDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No application usage data available yet'**
  String get noAppUsageDataAvailable;

  /// No description provided for @noApplicationDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No application data available'**
  String get noApplicationDataAvailable;

  /// No description provided for @noCategoryDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No category data available'**
  String get noCategoryDataAvailable;

  /// No description provided for @noApplicationLimitsSet.
  ///
  /// In en, this message translates to:
  /// **'No application limits set'**
  String get noApplicationLimitsSet;

  /// No description provided for @screenLabel.
  ///
  /// In en, this message translates to:
  /// **'Screen'**
  String get screenLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @productiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Productive'**
  String get productiveLabel;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreLabel;

  /// No description provided for @defaultNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get defaultNone;

  /// No description provided for @defaultTime.
  ///
  /// In en, this message translates to:
  /// **'0h 0m'**
  String get defaultTime;

  /// No description provided for @defaultCount.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get defaultCount;

  /// No description provided for @unknownApp.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownApp;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @generalSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSection;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataSection;

  /// No description provided for @versionSection.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionSection;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Language of the application'**
  String get languageDescription;

  /// No description provided for @startupBehaviourTitle.
  ///
  /// In en, this message translates to:
  /// **'Startup Behaviour'**
  String get startupBehaviourTitle;

  /// No description provided for @startupBehaviourDescription.
  ///
  /// In en, this message translates to:
  /// **'Launch at OS startup'**
  String get startupBehaviourDescription;

  /// No description provided for @launchMinimizedTitle.
  ///
  /// In en, this message translates to:
  /// **'Launch as Minimized'**
  String get launchMinimizedTitle;

  /// No description provided for @launchMinimizedDescription.
  ///
  /// In en, this message translates to:
  /// **'Start the application in System Tray (Recommended for Windows 10)'**
  String get launchMinimizedDescription;

  /// No description provided for @browserExtensionTitle.
  ///
  /// In en, this message translates to:
  /// **'Browser Extension'**
  String get browserExtensionTitle;

  /// No description provided for @browserExtensionDescription.
  ///
  /// In en, this message translates to:
  /// **'Allow the Scolect browser extension to connect and sync website usage data'**
  String get browserExtensionDescription;

  /// No description provided for @crashReportingTitle.
  ///
  /// In en, this message translates to:
  /// **'Crash Reporting'**
  String get crashReportingTitle;

  /// No description provided for @crashReportingDescription.
  ///
  /// In en, this message translates to:
  /// **'Send anonymous crash reports to help improve Scolect. No personal data or usage history is included.'**
  String get crashReportingDescription;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsAllDescription.
  ///
  /// In en, this message translates to:
  /// **'All notifications of the application'**
  String get notificationsAllDescription;

  /// No description provided for @focusModeNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get focusModeNotificationsTitle;

  /// No description provided for @focusModeNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'All Notifications for focus mode'**
  String get focusModeNotificationsDescription;

  /// No description provided for @screenTimeNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Screen Time'**
  String get screenTimeNotificationsTitle;

  /// No description provided for @screenTimeNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'All Notifications for screen time restriction'**
  String get screenTimeNotificationsDescription;

  /// No description provided for @appScreenTimeNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Screen Time'**
  String get appScreenTimeNotificationsTitle;

  /// No description provided for @appScreenTimeNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'All Notifications for application screen time restriction'**
  String get appScreenTimeNotificationsDescription;

  /// No description provided for @frequentAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequent Alerts Interval'**
  String get frequentAlertsTitle;

  /// No description provided for @frequentAlertsDescription.
  ///
  /// In en, this message translates to:
  /// **'Set interval for frequent notifications (minutes)'**
  String get frequentAlertsDescription;

  /// No description provided for @clearDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearDataTitle;

  /// No description provided for @clearDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Clear all the history and other related data'**
  String get clearDataDescription;

  /// No description provided for @resetSettingsTitle2.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettingsTitle2;

  /// No description provided for @resetSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Reset all the settings'**
  String get resetSettingsDescription;

  /// No description provided for @versionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionTitle;

  /// No description provided for @versionDescription.
  ///
  /// In en, this message translates to:
  /// **'Current version of the app'**
  String get versionDescription;

  /// No description provided for @contactButton.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactButton;

  /// No description provided for @reportBugButton.
  ///
  /// In en, this message translates to:
  /// **'Report Bug'**
  String get reportBugButton;

  /// No description provided for @submitFeedbackButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedbackButton;

  /// No description provided for @githubButton.
  ///
  /// In en, this message translates to:
  /// **'Github'**
  String get githubButton;

  /// No description provided for @clearDataDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Data?'**
  String get clearDataDialogTitle;

  /// No description provided for @clearDataDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This will clear all history and related data. You won\'t be able to recover it. Do you want to proceed?'**
  String get clearDataDialogContent;

  /// No description provided for @clearDataButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearDataButtonLabel;

  /// No description provided for @resetSettingsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings?'**
  String get resetSettingsDialogTitle;

  /// No description provided for @resetSettingsDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This will reset all settings to their default values. Do you want to proceed?'**
  String get resetSettingsDialogContent;

  /// No description provided for @resetButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButtonLabel;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @couldNotLaunchUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not launch {url}'**
  String couldNotLaunchUrl(String url);

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMessage(String message);

  /// Title for focus trends chart
  ///
  /// In en, this message translates to:
  /// **'Focus Trends'**
  String get chart_focusTrends;

  /// Label for session count metric
  ///
  /// In en, this message translates to:
  /// **'Session Count'**
  String get chart_sessionCount;

  /// Label for average duration metric
  ///
  /// In en, this message translates to:
  /// **'Avg Duration'**
  String get chart_avgDuration;

  /// Label for total focus time metric
  ///
  /// In en, this message translates to:
  /// **'Total Focus'**
  String get chart_totalFocus;

  /// Y-axis label for session count
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get chart_yAxis_sessions;

  /// Y-axis label for time in minutes
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get chart_yAxis_minutes;

  /// Generic y-axis label
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get chart_yAxis_value;

  /// Label for percentage change display
  ///
  /// In en, this message translates to:
  /// **'Month-over-month change: '**
  String get chart_monthOverMonthChange;

  /// Label for custom date range
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get chart_customRange;

  /// No description provided for @day_monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get day_monday;

  /// No description provided for @day_mondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get day_mondayShort;

  /// No description provided for @day_mondayAbbr.
  ///
  /// In en, this message translates to:
  /// **'Mn'**
  String get day_mondayAbbr;

  /// No description provided for @day_tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get day_tuesday;

  /// No description provided for @day_tuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get day_tuesdayShort;

  /// No description provided for @day_tuesdayAbbr.
  ///
  /// In en, this message translates to:
  /// **'Tu'**
  String get day_tuesdayAbbr;

  /// No description provided for @day_wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get day_wednesday;

  /// No description provided for @day_wednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get day_wednesdayShort;

  /// No description provided for @day_wednesdayAbbr.
  ///
  /// In en, this message translates to:
  /// **'Wd'**
  String get day_wednesdayAbbr;

  /// No description provided for @day_thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get day_thursday;

  /// No description provided for @day_thursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get day_thursdayShort;

  /// No description provided for @day_thursdayAbbr.
  ///
  /// In en, this message translates to:
  /// **'Th'**
  String get day_thursdayAbbr;

  /// No description provided for @day_friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get day_friday;

  /// No description provided for @day_fridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get day_fridayShort;

  /// No description provided for @day_fridayAbbr.
  ///
  /// In en, this message translates to:
  /// **'Fr'**
  String get day_fridayAbbr;

  /// No description provided for @day_saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get day_saturday;

  /// No description provided for @day_saturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get day_saturdayShort;

  /// No description provided for @day_saturdayAbbr.
  ///
  /// In en, this message translates to:
  /// **'St'**
  String get day_saturdayAbbr;

  /// No description provided for @day_sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get day_sunday;

  /// No description provided for @day_sundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get day_sundayShort;

  /// No description provided for @day_sundayAbbr.
  ///
  /// In en, this message translates to:
  /// **'Sn'**
  String get day_sundayAbbr;

  /// Hours format
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String time_hours(int count);

  /// Hours and minutes format
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String time_hoursMinutes(int hours, int minutes);

  /// Minutes format for tooltips
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String time_minutesFormat(String count);

  /// Tooltip showing date and screen time
  ///
  /// In en, this message translates to:
  /// **'{date}: {hours}h {minutes}m'**
  String tooltip_dateScreenTime(String date, int hours, int minutes);

  /// Hours format for tooltip fallback
  ///
  /// In en, this message translates to:
  /// **'{count} hours'**
  String tooltip_hoursFormat(String count);

  /// No description provided for @month_january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get month_january;

  /// No description provided for @month_januaryShort.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get month_januaryShort;

  /// No description provided for @month_february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get month_february;

  /// No description provided for @month_februaryShort.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get month_februaryShort;

  /// No description provided for @month_march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get month_march;

  /// No description provided for @month_marchShort.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get month_marchShort;

  /// No description provided for @month_april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get month_april;

  /// No description provided for @month_aprilShort.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get month_aprilShort;

  /// No description provided for @month_may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get month_may;

  /// No description provided for @month_mayShort.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get month_mayShort;

  /// No description provided for @month_june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get month_june;

  /// No description provided for @month_juneShort.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get month_juneShort;

  /// No description provided for @month_july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get month_july;

  /// No description provided for @month_julyShort.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get month_julyShort;

  /// No description provided for @month_august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get month_august;

  /// No description provided for @month_augustShort.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get month_augustShort;

  /// No description provided for @month_september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get month_september;

  /// No description provided for @month_septemberShort.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get month_septemberShort;

  /// No description provided for @month_october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get month_october;

  /// No description provided for @month_octoberShort.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get month_octoberShort;

  /// No description provided for @month_november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get month_november;

  /// No description provided for @month_novemberShort.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get month_novemberShort;

  /// No description provided for @month_december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get month_december;

  /// No description provided for @month_decemberShort.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get month_decemberShort;

  /// Category filter for all applications
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryProductivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get categoryProductivity;

  /// No description provided for @categoryDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get categoryDevelopment;

  /// No description provided for @categorySocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get categorySocialMedia;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get categoryGaming;

  /// No description provided for @categoryCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get categoryCommunication;

  /// No description provided for @categoryWebBrowsing.
  ///
  /// In en, this message translates to:
  /// **'Web Browsing'**
  String get categoryWebBrowsing;

  /// No description provided for @categoryCreative.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get categoryCreative;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryUtility.
  ///
  /// In en, this message translates to:
  /// **'Utility'**
  String get categoryUtility;

  /// No description provided for @categoryUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get categoryUncategorized;

  /// No description provided for @appMicrosoftWord.
  ///
  /// In en, this message translates to:
  /// **'Microsoft Word'**
  String get appMicrosoftWord;

  /// No description provided for @appExcel.
  ///
  /// In en, this message translates to:
  /// **'Excel'**
  String get appExcel;

  /// No description provided for @appPowerPoint.
  ///
  /// In en, this message translates to:
  /// **'PowerPoint'**
  String get appPowerPoint;

  /// No description provided for @appGoogleDocs.
  ///
  /// In en, this message translates to:
  /// **'Google Docs'**
  String get appGoogleDocs;

  /// No description provided for @appNotion.
  ///
  /// In en, this message translates to:
  /// **'Notion'**
  String get appNotion;

  /// No description provided for @appEvernote.
  ///
  /// In en, this message translates to:
  /// **'Evernote'**
  String get appEvernote;

  /// No description provided for @appTrello.
  ///
  /// In en, this message translates to:
  /// **'Trello'**
  String get appTrello;

  /// No description provided for @appAsana.
  ///
  /// In en, this message translates to:
  /// **'Asana'**
  String get appAsana;

  /// No description provided for @appSlack.
  ///
  /// In en, this message translates to:
  /// **'Slack'**
  String get appSlack;

  /// No description provided for @appMicrosoftTeams.
  ///
  /// In en, this message translates to:
  /// **'Microsoft Teams'**
  String get appMicrosoftTeams;

  /// No description provided for @appZoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get appZoom;

  /// No description provided for @appGoogleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar'**
  String get appGoogleCalendar;

  /// No description provided for @appAppleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get appAppleCalendar;

  /// No description provided for @appVisualStudioCode.
  ///
  /// In en, this message translates to:
  /// **'Visual Studio Code'**
  String get appVisualStudioCode;

  /// No description provided for @appTerminal.
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get appTerminal;

  /// No description provided for @appCommandPrompt.
  ///
  /// In en, this message translates to:
  /// **'Command Prompt'**
  String get appCommandPrompt;

  /// No description provided for @appChrome.
  ///
  /// In en, this message translates to:
  /// **'Chrome'**
  String get appChrome;

  /// No description provided for @appFirefox.
  ///
  /// In en, this message translates to:
  /// **'Firefox'**
  String get appFirefox;

  /// No description provided for @appSafari.
  ///
  /// In en, this message translates to:
  /// **'Safari'**
  String get appSafari;

  /// No description provided for @appEdge.
  ///
  /// In en, this message translates to:
  /// **'Edge'**
  String get appEdge;

  /// No description provided for @appOpera.
  ///
  /// In en, this message translates to:
  /// **'Opera'**
  String get appOpera;

  /// No description provided for @appBrave.
  ///
  /// In en, this message translates to:
  /// **'Brave'**
  String get appBrave;

  /// No description provided for @appNetflix.
  ///
  /// In en, this message translates to:
  /// **'Netflix'**
  String get appNetflix;

  /// No description provided for @appYouTube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get appYouTube;

  /// No description provided for @appSpotify.
  ///
  /// In en, this message translates to:
  /// **'Spotify'**
  String get appSpotify;

  /// No description provided for @appAppleMusic.
  ///
  /// In en, this message translates to:
  /// **'Apple Music'**
  String get appAppleMusic;

  /// No description provided for @appCalculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get appCalculator;

  /// No description provided for @appNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get appNotes;

  /// No description provided for @appSystemPreferences.
  ///
  /// In en, this message translates to:
  /// **'System Preferences'**
  String get appSystemPreferences;

  /// No description provided for @appTaskManager.
  ///
  /// In en, this message translates to:
  /// **'Task Manager'**
  String get appTaskManager;

  /// No description provided for @appFileExplorer.
  ///
  /// In en, this message translates to:
  /// **'File Explorer'**
  String get appFileExplorer;

  /// No description provided for @appDropbox.
  ///
  /// In en, this message translates to:
  /// **'Dropbox'**
  String get appDropbox;

  /// No description provided for @appGoogleDrive.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get appGoogleDrive;

  /// Message shown when the application is loading
  ///
  /// In en, this message translates to:
  /// **'Loading application...'**
  String get loadingApplication;

  /// Message shown when data is being loaded
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// Label for error messages
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get reportsError;

  /// Button text to retry an operation
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get reportsRetry;

  /// No description provided for @backupRestoreSection.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestoreSection;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestoreTitle;

  /// No description provided for @exportDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportDataTitle;

  /// No description provided for @exportDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a backup of all your data'**
  String get exportDataDescription;

  /// No description provided for @importDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importDataTitle;

  /// No description provided for @importDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup file'**
  String get importDataDescription;

  /// No description provided for @exportButton.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportButton;

  /// No description provided for @importButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importButton;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @noButton.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noButton;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// No description provided for @exportStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting export...'**
  String get exportStarting;

  /// No description provided for @exportSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Export Successful'**
  String get exportSuccessful;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export Failed'**
  String get exportFailed;

  /// No description provided for @exportComplete.
  ///
  /// In en, this message translates to:
  /// **'Export Complete'**
  String get exportComplete;

  /// No description provided for @shareBackupQuestion.
  ///
  /// In en, this message translates to:
  /// **'Would you like to share the backup file?'**
  String get shareBackupQuestion;

  /// No description provided for @importStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting import...'**
  String get importStarting;

  /// No description provided for @importSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Import successful!'**
  String get importSuccessful;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importFailed;

  /// No description provided for @importOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Options'**
  String get importOptionsTitle;

  /// No description provided for @importOptionsQuestion.
  ///
  /// In en, this message translates to:
  /// **'How would you like to import the data?'**
  String get importOptionsQuestion;

  /// No description provided for @replaceModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replaceModeTitle;

  /// No description provided for @replaceModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Replace all existing data'**
  String get replaceModeDescription;

  /// No description provided for @mergeModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get mergeModeTitle;

  /// No description provided for @mergeModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Combine with existing data'**
  String get mergeModeDescription;

  /// No description provided for @appendModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Append'**
  String get appendModeTitle;

  /// No description provided for @appendModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Only add new records'**
  String get appendModeDescription;

  /// No description provided for @warningTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Warning'**
  String get warningTitle;

  /// No description provided for @replaceWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'This will replace ALL your existing data. Are you sure you want to continue?'**
  String get replaceWarningMessage;

  /// No description provided for @replaceAllButton.
  ///
  /// In en, this message translates to:
  /// **'Replace All'**
  String get replaceAllButton;

  /// No description provided for @fileLabel.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get fileLabel;

  /// No description provided for @sizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get sizeLabel;

  /// No description provided for @recordsLabel.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get recordsLabel;

  /// No description provided for @usageRecordsLabel.
  ///
  /// In en, this message translates to:
  /// **'Usage records'**
  String get usageRecordsLabel;

  /// No description provided for @focusSessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Focus sessions'**
  String get focusSessionsLabel;

  /// No description provided for @appMetadataLabel.
  ///
  /// In en, this message translates to:
  /// **'App metadata'**
  String get appMetadataLabel;

  /// No description provided for @updatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updatedLabel;

  /// No description provided for @skippedLabel.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skippedLabel;

  /// No description provided for @activityTrackingSection.
  ///
  /// In en, this message translates to:
  /// **'Activity Tracking'**
  String get activityTrackingSection;

  /// No description provided for @idleDetectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Idle Detection'**
  String get idleDetectionTitle;

  /// No description provided for @idleDetectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Stop tracking when inactive'**
  String get idleDetectionDescription;

  /// No description provided for @keepActiveDuringMediaTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep Active During Media'**
  String get keepActiveDuringMediaTitle;

  /// No description provided for @keepActiveDuringMediaDescription.
  ///
  /// In en, this message translates to:
  /// **'Ignore idle pause while video or audio is playing (e.g. YouTube, Netflix)'**
  String get keepActiveDuringMediaDescription;

  /// No description provided for @pauseOnWindowBlurTitle.
  ///
  /// In en, this message translates to:
  /// **'Pause on Window Blur'**
  String get pauseOnWindowBlurTitle;

  /// No description provided for @pauseOnWindowBlurDescription.
  ///
  /// In en, this message translates to:
  /// **'Pause tracking when the browser window loses focus'**
  String get pauseOnWindowBlurDescription;

  /// No description provided for @ignoreWindowBlurOnMediaTitle.
  ///
  /// In en, this message translates to:
  /// **'Ignore Window Blur During Media'**
  String get ignoreWindowBlurOnMediaTitle;

  /// No description provided for @ignoreWindowBlurOnMediaDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep tracking active when switching screens while video or audio is playing'**
  String get ignoreWindowBlurOnMediaDescription;

  /// No description provided for @pauseOnTabUnfocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Pause on Tab Switch / Unfocus'**
  String get pauseOnTabUnfocusTitle;

  /// No description provided for @pauseOnTabUnfocusDescription.
  ///
  /// In en, this message translates to:
  /// **'Pause tracking when tab is inactive or backgrounded'**
  String get pauseOnTabUnfocusDescription;

  /// No description provided for @idleTimeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Idle Timeout'**
  String get idleTimeoutTitle;

  /// No description provided for @idleTimeoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Time before considering idle ({timeout})'**
  String idleTimeoutDescription(String timeout);

  /// No description provided for @advancedWarning.
  ///
  /// In en, this message translates to:
  /// **'Advanced features may increase resource usage. Enable only if needed.'**
  String get advancedWarning;

  /// No description provided for @monitorAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor System Audio'**
  String get monitorAudioTitle;

  /// No description provided for @monitorAudioDescription.
  ///
  /// In en, this message translates to:
  /// **'Detect activity from audio playback'**
  String get monitorAudioDescription;

  /// No description provided for @audioSensitivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio Sensitivity'**
  String get audioSensitivityTitle;

  /// No description provided for @audioSensitivityDescription.
  ///
  /// In en, this message translates to:
  /// **'Detection threshold ({value})'**
  String audioSensitivityDescription(String value);

  /// No description provided for @monitorControllersTitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor Game Controllers'**
  String get monitorControllersTitle;

  /// No description provided for @monitorControllersDescription.
  ///
  /// In en, this message translates to:
  /// **'Detect Xbox/XInput controllers'**
  String get monitorControllersDescription;

  /// No description provided for @monitorHIDTitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor HID Devices'**
  String get monitorHIDTitle;

  /// No description provided for @monitorHIDDescription.
  ///
  /// In en, this message translates to:
  /// **'Detect wheels, tablets, custom devices'**
  String get monitorHIDDescription;

  /// No description provided for @setIdleTimeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Idle Timeout'**
  String get setIdleTimeoutTitle;

  /// No description provided for @idleTimeoutDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how long to wait before considering you idle:'**
  String get idleTimeoutDialogDescription;

  /// No description provided for @seconds30.
  ///
  /// In en, this message translates to:
  /// **'30 seconds'**
  String get seconds30;

  /// No description provided for @minute1.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get minute1;

  /// No description provided for @minutes2.
  ///
  /// In en, this message translates to:
  /// **'2 minutes'**
  String get minutes2;

  /// No description provided for @minutes5.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get minutes5;

  /// No description provided for @minutes10.
  ///
  /// In en, this message translates to:
  /// **'10 minutes'**
  String get minutes10;

  /// No description provided for @customOption.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customOption;

  /// No description provided for @customDurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Duration'**
  String get customDurationTitle;

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutesLabel;

  /// No description provided for @secondsLabel.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get secondsLabel;

  /// No description provided for @minAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minAbbreviation;

  /// No description provided for @secAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get secAbbreviation;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {duration}'**
  String totalLabel(String duration);

  /// No description provided for @minimumError.
  ///
  /// In en, this message translates to:
  /// **'Minimum is {value}'**
  String minimumError(String value);

  /// No description provided for @maximumError.
  ///
  /// In en, this message translates to:
  /// **'Maximum is {value}'**
  String maximumError(String value);

  /// No description provided for @rangeInfo.
  ///
  /// In en, this message translates to:
  /// **'Range: {min} - {max}'**
  String rangeInfo(String min, String max);

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @timeFormatSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String timeFormatSeconds(int seconds);

  /// No description provided for @timeFormatMinute.
  ///
  /// In en, this message translates to:
  /// **'1 min'**
  String get timeFormatMinute;

  /// No description provided for @timeFormatMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String timeFormatMinutes(int minutes);

  /// No description provided for @timeFormatMinutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min {seconds}s'**
  String timeFormatMinutesSeconds(int minutes, int seconds);

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeDescription.
  ///
  /// In en, this message translates to:
  /// **'Color theme of the application'**
  String get themeDescription;

  /// No description provided for @voiceGenderTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Gender'**
  String get voiceGenderTitle;

  /// No description provided for @voiceGenderDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the voice gender for timer notifications'**
  String get voiceGenderDescription;

  /// No description provided for @voiceGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get voiceGenderMale;

  /// No description provided for @voiceGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get voiceGenderFemale;

  /// No description provided for @alertsLimitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your screen time limits and notifications'**
  String get alertsLimitsSubtitle;

  /// No description provided for @applicationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your tracked applications'**
  String get applicationsSubtitle;

  /// No description provided for @applicationCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 application} other{{count} applications}}'**
  String applicationCount(int count);

  /// No description provided for @noApplicationsFound.
  ///
  /// In en, this message translates to:
  /// **'No applications found'**
  String get noApplicationsFound;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters'**
  String get tryAdjustingFilters;

  /// No description provided for @configureAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Configure application settings'**
  String get configureAppSettings;

  /// No description provided for @behaviorSection.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get behaviorSection;

  /// No description provided for @helpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question across 7 categories} other{{count} questions across 7 categories}}'**
  String helpSubtitle(int count);

  /// No description provided for @searchForHelp.
  ///
  /// In en, this message translates to:
  /// **'Search for help...'**
  String get searchForHelp;

  /// No description provided for @quickNavGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get quickNavGeneral;

  /// No description provided for @quickNavApps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get quickNavApps;

  /// No description provided for @quickNavReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get quickNavReports;

  /// No description provided for @quickNavFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get quickNavFocus;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try searching with different keywords'**
  String get tryDifferentKeywords;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearch;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning! Here\'s your activity summary.'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon! Here\'s your activity summary.'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening! Here\'s your activity summary.'**
  String get greetingEvening;

  /// No description provided for @screenTimeProgress.
  ///
  /// In en, this message translates to:
  /// **'Screen\nTime'**
  String get screenTimeProgress;

  /// No description provided for @productiveScoreProgress.
  ///
  /// In en, this message translates to:
  /// **'Productive\nScore'**
  String get productiveScoreProgress;

  /// No description provided for @focusModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay focused, be productive'**
  String get focusModeSubtitle;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// No description provided for @avgLength.
  ///
  /// In en, this message translates to:
  /// **'Avg Length'**
  String get avgLength;

  /// No description provided for @focusTime.
  ///
  /// In en, this message translates to:
  /// **'Focus Time'**
  String get focusTime;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @shortBreakStatus.
  ///
  /// In en, this message translates to:
  /// **'Short Break'**
  String get shortBreakStatus;

  /// No description provided for @longBreakStatus.
  ///
  /// In en, this message translates to:
  /// **'Long Break'**
  String get longBreakStatus;

  /// No description provided for @readyToFocus.
  ///
  /// In en, this message translates to:
  /// **'Ready to Focus'**
  String get readyToFocus;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus;

  /// No description provided for @restartSession.
  ///
  /// In en, this message translates to:
  /// **'Restart Session'**
  String get restartSession;

  /// No description provided for @skipToNext.
  ///
  /// In en, this message translates to:
  /// **'Skip to Next'**
  String get skipToNext;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @sessionsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session completed} other{{count} sessions completed}}'**
  String sessionsCompleted(int count);

  /// No description provided for @focusModePreset.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode Preset'**
  String get focusModePreset;

  /// No description provided for @focusDuration.
  ///
  /// In en, this message translates to:
  /// **'Focus Duration'**
  String get focusDuration;

  /// No description provided for @minutesFormat.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesFormat(int minutes);

  /// No description provided for @shortBreakDuration.
  ///
  /// In en, this message translates to:
  /// **'Short Break'**
  String get shortBreakDuration;

  /// No description provided for @longBreakDuration.
  ///
  /// In en, this message translates to:
  /// **'Long Break'**
  String get longBreakDuration;

  /// No description provided for @enableSounds.
  ///
  /// In en, this message translates to:
  /// **'Enable Sounds'**
  String get enableSounds;

  /// No description provided for @focus_mode_this_week.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get focus_mode_this_week;

  /// No description provided for @focus_mode_best_day.
  ///
  /// In en, this message translates to:
  /// **'Best Day'**
  String get focus_mode_best_day;

  /// No description provided for @focus_mode_sessions_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 sessions} =1{1 session} other{{count} sessions}}'**
  String focus_mode_sessions_count(int count);

  /// No description provided for @focus_mode_no_data_yet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get focus_mode_no_data_yet;

  /// No description provided for @chart_current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get chart_current;

  /// No description provided for @chart_previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get chart_previous;

  /// No description provided for @permission_error.
  ///
  /// In en, this message translates to:
  /// **'Permission Error'**
  String get permission_error;

  /// No description provided for @notification_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission Denied'**
  String get notification_permission_denied;

  /// No description provided for @notification_permission_denied_message.
  ///
  /// In en, this message translates to:
  /// **'ScreenTime needs notification permission to send you alerts and reminders.\n\nWould you like to open System Settings to enable notifications?'**
  String get notification_permission_denied_message;

  /// No description provided for @notification_permission_denied_hint.
  ///
  /// In en, this message translates to:
  /// **'Open System Settings to enable notifications for ScreenTime.'**
  String get notification_permission_denied_hint;

  /// No description provided for @notification_permission_required.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission Required'**
  String get notification_permission_required;

  /// No description provided for @notification_permission_required_message.
  ///
  /// In en, this message translates to:
  /// **'ScreenTime needs permission to send you notifications.'**
  String get notification_permission_required_message;

  /// No description provided for @open_settings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get open_settings;

  /// No description provided for @allow_notifications.
  ///
  /// In en, this message translates to:
  /// **'Allow Notifications'**
  String get allow_notifications;

  /// No description provided for @permission_allowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get permission_allowed;

  /// No description provided for @permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get permission_denied;

  /// No description provided for @permission_not_set.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get permission_not_set;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @enable_notification_permission_hint.
  ///
  /// In en, this message translates to:
  /// **'Enable notification permission to receive alerts'**
  String get enable_notification_permission_hint;

  /// No description provided for @minutes_format.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutes_format(int minutes);

  /// No description provided for @chart_average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get chart_average;

  /// No description provided for @chart_peak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get chart_peak;

  /// No description provided for @chart_lowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest'**
  String get chart_lowest;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @advanced_options.
  ///
  /// In en, this message translates to:
  /// **'Advanced Options'**
  String get advanced_options;

  /// No description provided for @sync_ready.
  ///
  /// In en, this message translates to:
  /// **'Sync Ready'**
  String get sync_ready;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @destructive_badge.
  ///
  /// In en, this message translates to:
  /// **'Destructive'**
  String get destructive_badge;

  /// No description provided for @recommended_badge.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended_badge;

  /// No description provided for @safe_badge.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get safe_badge;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @patterns.
  ///
  /// In en, this message translates to:
  /// **'Patterns'**
  String get patterns;

  /// No description provided for @apps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get apps;

  /// No description provided for @sortAscending.
  ///
  /// In en, this message translates to:
  /// **'Sort Ascending'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In en, this message translates to:
  /// **'Sort Descending'**
  String get sortDescending;

  /// No description provided for @applicationsShowing.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 applications showing} =1{1 application showing} other{{count} applications showing}}'**
  String applicationsShowing(int count);

  /// No description provided for @valueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value: {value}'**
  String valueLabel(String value);

  /// No description provided for @appsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 apps} =1{1 app} other{{count} apps}}'**
  String appsCount(int count);

  /// No description provided for @categoriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 categories} =1{1 category} other{{count} categories}}'**
  String categoriesCount(int count);

  /// No description provided for @systemNotificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'System notifications are disabled. Enable them in System Settings for focus alerts.'**
  String get systemNotificationsDisabled;

  /// No description provided for @openSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Open System Settings'**
  String get openSystemSettings;

  /// No description provided for @appNotificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled in app settings. Enable them to receive focus alerts.'**
  String get appNotificationsDisabled;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @focusModeNotificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Focus mode notifications are disabled. Enable them to receive session alerts.'**
  String get focusModeNotificationsDisabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications Disabled'**
  String get notificationsDisabled;

  /// No description provided for @dontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get dontShowAgain;

  /// No description provided for @systemSettingsRequired.
  ///
  /// In en, this message translates to:
  /// **'System Settings Required'**
  String get systemSettingsRequired;

  /// No description provided for @notificationsDisabledSystemLevel.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled at the system level. To enable:'**
  String get notificationsDisabledSystemLevel;

  /// No description provided for @step1OpenSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'1. Open System Settings (System Preferences)'**
  String get step1OpenSystemSettings;

  /// No description provided for @step2GoToNotifications.
  ///
  /// In en, this message translates to:
  /// **'2. Go to Notifications'**
  String get step2GoToNotifications;

  /// No description provided for @step3FindApp.
  ///
  /// In en, this message translates to:
  /// **'3. Find and select Scolect'**
  String get step3FindApp;

  /// No description provided for @step4EnableNotifications.
  ///
  /// In en, this message translates to:
  /// **'4. Enable \"Allow notifications\"'**
  String get step4EnableNotifications;

  /// No description provided for @returnToAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Then return to this app and notifications will work.'**
  String get returnToAppMessage;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @noSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get noSessionsYet;

  /// No description provided for @applicationsTracked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 applications tracked} =1{1 application tracked} other{{count} applications tracked}}'**
  String applicationsTracked(int count);

  /// No description provided for @applicationHeader.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get applicationHeader;

  /// No description provided for @currentUsageHeader.
  ///
  /// In en, this message translates to:
  /// **'Current Usage'**
  String get currentUsageHeader;

  /// No description provided for @dailyLimitHeader.
  ///
  /// In en, this message translates to:
  /// **'Daily Limit'**
  String get dailyLimitHeader;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @showPopupNotifications.
  ///
  /// In en, this message translates to:
  /// **'Show popup notifications'**
  String get showPopupNotifications;

  /// No description provided for @moreFrequentReminders.
  ///
  /// In en, this message translates to:
  /// **'More frequent reminders'**
  String get moreFrequentReminders;

  /// No description provided for @playSoundWithAlerts.
  ///
  /// In en, this message translates to:
  /// **'Play sound with alerts'**
  String get playSoundWithAlerts;

  /// No description provided for @systemTrayNotifications.
  ///
  /// In en, this message translates to:
  /// **'System tray notifications'**
  String get systemTrayNotifications;

  /// No description provided for @screenTimeUsed.
  ///
  /// In en, this message translates to:
  /// **'{current} / {limit} used'**
  String screenTimeUsed(String current, String limit);

  /// No description provided for @todaysScreenTime.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Screen Time'**
  String get todaysScreenTime;

  /// No description provided for @activeLimits.
  ///
  /// In en, this message translates to:
  /// **'Active Limits'**
  String get activeLimits;

  /// No description provided for @nearLimit.
  ///
  /// In en, this message translates to:
  /// **'Near Limit'**
  String get nearLimit;

  /// No description provided for @colorPickerSpectrum.
  ///
  /// In en, this message translates to:
  /// **'Spectrum'**
  String get colorPickerSpectrum;

  /// No description provided for @colorPickerPresets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get colorPickerPresets;

  /// No description provided for @colorPickerSliders.
  ///
  /// In en, this message translates to:
  /// **'Sliders'**
  String get colorPickerSliders;

  /// No description provided for @colorPickerBasicColors.
  ///
  /// In en, this message translates to:
  /// **'Basic Colors'**
  String get colorPickerBasicColors;

  /// No description provided for @colorPickerExtendedPalette.
  ///
  /// In en, this message translates to:
  /// **'Extended Palette'**
  String get colorPickerExtendedPalette;

  /// No description provided for @colorPickerRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorPickerRed;

  /// No description provided for @colorPickerGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorPickerGreen;

  /// No description provided for @colorPickerBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorPickerBlue;

  /// No description provided for @colorPickerHue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get colorPickerHue;

  /// No description provided for @colorPickerSaturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get colorPickerSaturation;

  /// No description provided for @colorPickerBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get colorPickerBrightness;

  /// No description provided for @colorPickerHexColor.
  ///
  /// In en, this message translates to:
  /// **'Hex Color'**
  String get colorPickerHexColor;

  /// No description provided for @colorPickerHexPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'RRGGBB'**
  String get colorPickerHexPlaceholder;

  /// No description provided for @colorPickerRGB.
  ///
  /// In en, this message translates to:
  /// **'RGB'**
  String get colorPickerRGB;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @themeCustomization.
  ///
  /// In en, this message translates to:
  /// **'Theme Customization'**
  String get themeCustomization;

  /// No description provided for @chooseThemePreset.
  ///
  /// In en, this message translates to:
  /// **'Choose a Theme Preset'**
  String get chooseThemePreset;

  /// No description provided for @yourCustomThemes.
  ///
  /// In en, this message translates to:
  /// **'Your Custom Themes'**
  String get yourCustomThemes;

  /// No description provided for @createCustomTheme.
  ///
  /// In en, this message translates to:
  /// **'Create Custom Theme'**
  String get createCustomTheme;

  /// No description provided for @designOwnColorScheme.
  ///
  /// In en, this message translates to:
  /// **'Design your own color scheme'**
  String get designOwnColorScheme;

  /// No description provided for @newTheme.
  ///
  /// In en, this message translates to:
  /// **'New Theme'**
  String get newTheme;

  /// No description provided for @editCurrentTheme.
  ///
  /// In en, this message translates to:
  /// **'Edit Current Theme'**
  String get editCurrentTheme;

  /// No description provided for @customizeColorsFor.
  ///
  /// In en, this message translates to:
  /// **'Customize colors for {themeName}'**
  String customizeColorsFor(String themeName);

  /// No description provided for @customThemeNumber.
  ///
  /// In en, this message translates to:
  /// **'Custom Theme {number}'**
  String customThemeNumber(int number);

  /// No description provided for @deleteCustomTheme.
  ///
  /// In en, this message translates to:
  /// **'Delete Custom Theme'**
  String get deleteCustomTheme;

  /// No description provided for @confirmDeleteTheme.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{themeName}\"?'**
  String confirmDeleteTheme(String themeName);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @customizeTheme.
  ///
  /// In en, this message translates to:
  /// **'Customize Theme'**
  String get customizeTheme;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @themeName.
  ///
  /// In en, this message translates to:
  /// **'Theme Name'**
  String get themeName;

  /// No description provided for @brandColors.
  ///
  /// In en, this message translates to:
  /// **'Brand Colors'**
  String get brandColors;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @saveTheme.
  ///
  /// In en, this message translates to:
  /// **'Save Theme'**
  String get saveTheme;

  /// No description provided for @customTheme.
  ///
  /// In en, this message translates to:
  /// **'Custom Theme'**
  String get customTheme;

  /// No description provided for @primaryColors.
  ///
  /// In en, this message translates to:
  /// **'Primary Colors'**
  String get primaryColors;

  /// No description provided for @primaryColorsDesc.
  ///
  /// In en, this message translates to:
  /// **'Main accent colors used throughout the app'**
  String get primaryColorsDesc;

  /// No description provided for @primaryAccent.
  ///
  /// In en, this message translates to:
  /// **'Primary Accent'**
  String get primaryAccent;

  /// No description provided for @primaryAccentDesc.
  ///
  /// In en, this message translates to:
  /// **'Main brand color, buttons, links'**
  String get primaryAccentDesc;

  /// No description provided for @secondaryAccent.
  ///
  /// In en, this message translates to:
  /// **'Secondary Accent'**
  String get secondaryAccent;

  /// No description provided for @secondaryAccentDesc.
  ///
  /// In en, this message translates to:
  /// **'Complementary accent for gradients'**
  String get secondaryAccentDesc;

  /// No description provided for @semanticColors.
  ///
  /// In en, this message translates to:
  /// **'Semantic Colors'**
  String get semanticColors;

  /// No description provided for @semanticColorsDesc.
  ///
  /// In en, this message translates to:
  /// **'Colors that convey meaning and status'**
  String get semanticColorsDesc;

  /// No description provided for @successColor.
  ///
  /// In en, this message translates to:
  /// **'Success Color'**
  String get successColor;

  /// No description provided for @successColorDesc.
  ///
  /// In en, this message translates to:
  /// **'Positive actions, confirmations'**
  String get successColorDesc;

  /// No description provided for @warningColor.
  ///
  /// In en, this message translates to:
  /// **'Warning Color'**
  String get warningColor;

  /// No description provided for @warningColorDesc.
  ///
  /// In en, this message translates to:
  /// **'Caution, pending states'**
  String get warningColorDesc;

  /// No description provided for @errorColor.
  ///
  /// In en, this message translates to:
  /// **'Error Color'**
  String get errorColor;

  /// No description provided for @errorColorDesc.
  ///
  /// In en, this message translates to:
  /// **'Errors, destructive actions'**
  String get errorColorDesc;

  /// No description provided for @backgroundColors.
  ///
  /// In en, this message translates to:
  /// **'Background Colors'**
  String get backgroundColors;

  /// No description provided for @backgroundColorsLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Main background surfaces for light mode'**
  String get backgroundColorsLightDesc;

  /// No description provided for @backgroundColorsDarkDesc.
  ///
  /// In en, this message translates to:
  /// **'Main background surfaces for dark mode'**
  String get backgroundColorsDarkDesc;

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @backgroundDesc.
  ///
  /// In en, this message translates to:
  /// **'Main app background'**
  String get backgroundDesc;

  /// No description provided for @surface.
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get surface;

  /// No description provided for @surfaceDesc.
  ///
  /// In en, this message translates to:
  /// **'Cards, dialogs, elevated surfaces'**
  String get surfaceDesc;

  /// No description provided for @surfaceSecondary.
  ///
  /// In en, this message translates to:
  /// **'Surface Secondary'**
  String get surfaceSecondary;

  /// No description provided for @surfaceSecondaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Secondary cards, sidebars'**
  String get surfaceSecondaryDesc;

  /// No description provided for @border.
  ///
  /// In en, this message translates to:
  /// **'Border'**
  String get border;

  /// No description provided for @borderDesc.
  ///
  /// In en, this message translates to:
  /// **'Dividers, card borders'**
  String get borderDesc;

  /// No description provided for @textColors.
  ///
  /// In en, this message translates to:
  /// **'Text Colors'**
  String get textColors;

  /// No description provided for @textColorsLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Typography colors for light mode'**
  String get textColorsLightDesc;

  /// No description provided for @textColorsDarkDesc.
  ///
  /// In en, this message translates to:
  /// **'Typography colors for dark mode'**
  String get textColorsDarkDesc;

  /// No description provided for @textPrimary.
  ///
  /// In en, this message translates to:
  /// **'Text Primary'**
  String get textPrimary;

  /// No description provided for @textPrimaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Headings, important text'**
  String get textPrimaryDesc;

  /// No description provided for @textSecondary.
  ///
  /// In en, this message translates to:
  /// **'Text Secondary'**
  String get textSecondary;

  /// No description provided for @textSecondaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Descriptions, captions'**
  String get textSecondaryDesc;

  /// No description provided for @previewMode.
  ///
  /// In en, this message translates to:
  /// **'Preview: {mode} Mode'**
  String previewMode(String mode);

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @sampleCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Sample Card Title'**
  String get sampleCardTitle;

  /// No description provided for @sampleSecondaryText.
  ///
  /// In en, this message translates to:
  /// **'This is secondary text that appears below.'**
  String get sampleSecondaryText;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// No description provided for @secondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get secondary;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @launchAtStartupTitle.
  ///
  /// In en, this message translates to:
  /// **'Launch at startup'**
  String get launchAtStartupTitle;

  /// No description provided for @launchAtStartupDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically start Scolect when you log in to your computer'**
  String get launchAtStartupDescription;

  /// No description provided for @inputMonitoringPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Keyboard Monitoring Unavailable'**
  String get inputMonitoringPermissionTitle;

  /// No description provided for @inputMonitoringPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable Input Monitoring permission to track keyboard activity. Currently only mouse input is monitored.'**
  String get inputMonitoringPermissionDescription;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @permissionGrantedTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission Granted'**
  String get permissionGrantedTitle;

  /// No description provided for @permissionGrantedDescription.
  ///
  /// In en, this message translates to:
  /// **'The app needs to restart for Input Monitoring to take effect.'**
  String get permissionGrantedDescription;

  /// Continue button label
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @restartRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart Required'**
  String get restartRequiredTitle;

  /// No description provided for @restartRequiredDescription.
  ///
  /// In en, this message translates to:
  /// **'To enable keyboard monitoring, the app needs to restart. This is required by macOS.'**
  String get restartRequiredDescription;

  /// No description provided for @restartNote.
  ///
  /// In en, this message translates to:
  /// **'The app will automatically relaunch after restarting.'**
  String get restartNote;

  /// No description provided for @restartNow.
  ///
  /// In en, this message translates to:
  /// **'Restart Now'**
  String get restartNow;

  /// No description provided for @restartLater.
  ///
  /// In en, this message translates to:
  /// **'Restart Later'**
  String get restartLater;

  /// No description provided for @restartFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart Failed'**
  String get restartFailedTitle;

  /// No description provided for @restartFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not restart the app automatically. Please quit (Cmd+Q) and relaunch manually.'**
  String get restartFailedMessage;

  /// No description provided for @exportAnalyticsReport.
  ///
  /// In en, this message translates to:
  /// **'Export Analytics Report'**
  String get exportAnalyticsReport;

  /// No description provided for @chooseExportFormat.
  ///
  /// In en, this message translates to:
  /// **'Choose export format:'**
  String get chooseExportFormat;

  /// No description provided for @beautifulExcelReport.
  ///
  /// In en, this message translates to:
  /// **'Beautiful Excel Report'**
  String get beautifulExcelReport;

  /// No description provided for @beautifulExcelReportDescription.
  ///
  /// In en, this message translates to:
  /// **'Gorgeous, colorful spreadsheet with charts, emojis, and insights ✨'**
  String get beautifulExcelReportDescription;

  /// No description provided for @excelReportIncludes.
  ///
  /// In en, this message translates to:
  /// **'The Excel report includes:'**
  String get excelReportIncludes;

  /// No description provided for @summarySheetDescription.
  ///
  /// In en, this message translates to:
  /// **'📊 Summary Sheet - Key metrics with trends'**
  String get summarySheetDescription;

  /// No description provided for @dailyBreakdownDescription.
  ///
  /// In en, this message translates to:
  /// **'📅 Daily Breakdown - Visual usage patterns'**
  String get dailyBreakdownDescription;

  /// No description provided for @appsSheetDescription.
  ///
  /// In en, this message translates to:
  /// **'📱 Apps Sheet - Detailed app rankings'**
  String get appsSheetDescription;

  /// No description provided for @insightsDescription.
  ///
  /// In en, this message translates to:
  /// **'💡 Insights - Smart recommendations'**
  String get insightsDescription;

  /// No description provided for @beautifulExcelExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Beautiful Excel report exported successfully! 🎉'**
  String get beautifulExcelExportSuccess;

  /// No description provided for @failedToExportReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to export report: {error}'**
  String failedToExportReport(String error);

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exporting;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get exportExcel;

  /// No description provided for @saveAnalyticsReport.
  ///
  /// In en, this message translates to:
  /// **'Save Analytics Report'**
  String get saveAnalyticsReport;

  /// No description provided for @analyticsReportFileName.
  ///
  /// In en, this message translates to:
  /// **'analytics_report_{timestamp}.xlsx'**
  String analyticsReportFileName(String timestamp);

  /// No description provided for @usageAnalyticsReportTitle.
  ///
  /// In en, this message translates to:
  /// **'USAGE ANALYTICS REPORT'**
  String get usageAnalyticsReportTitle;

  /// No description provided for @generated.
  ///
  /// In en, this message translates to:
  /// **'Generated:'**
  String get generated;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period:'**
  String get period;

  /// No description provided for @dateRangeValue.
  ///
  /// In en, this message translates to:
  /// **'{startDate} to {endDate}'**
  String dateRangeValue(String startDate, String endDate);

  /// No description provided for @keyMetrics.
  ///
  /// In en, this message translates to:
  /// **'KEY METRICS'**
  String get keyMetrics;

  /// No description provided for @metric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metric;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @trend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trend;

  /// No description provided for @productivityRate.
  ///
  /// In en, this message translates to:
  /// **'Productivity Rate'**
  String get productivityRate;

  /// No description provided for @trendUp.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get trendUp;

  /// No description provided for @trendDown.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get trendDown;

  /// No description provided for @trendExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get trendExcellent;

  /// No description provided for @trendGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get trendGood;

  /// No description provided for @trendNeedsImprovement.
  ///
  /// In en, this message translates to:
  /// **'Needs Improvement'**
  String get trendNeedsImprovement;

  /// No description provided for @trendActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get trendActive;

  /// No description provided for @trendNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get trendNone;

  /// No description provided for @trendTop.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get trendTop;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @visual.
  ///
  /// In en, this message translates to:
  /// **'Visual'**
  String get visual;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'STATISTICS'**
  String get statistics;

  /// No description provided for @averageDaily.
  ///
  /// In en, this message translates to:
  /// **'Average Daily'**
  String get averageDaily;

  /// No description provided for @highestDay.
  ///
  /// In en, this message translates to:
  /// **'Highest Day'**
  String get highestDay;

  /// No description provided for @lowestDay.
  ///
  /// In en, this message translates to:
  /// **'Lowest Day'**
  String get lowestDay;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @applicationUsageDetails.
  ///
  /// In en, this message translates to:
  /// **'APPLICATION USAGE DETAILS'**
  String get applicationUsageDetails;

  /// No description provided for @totalApps.
  ///
  /// In en, this message translates to:
  /// **'Total Apps:'**
  String get totalApps;

  /// No description provided for @productiveApps.
  ///
  /// In en, this message translates to:
  /// **'Productive Apps:'**
  String get productiveApps;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @application.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get application;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @percentOfTotal.
  ///
  /// In en, this message translates to:
  /// **'% of Total'**
  String get percentOfTotal;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @usageLevel.
  ///
  /// In en, this message translates to:
  /// **'Usage Level'**
  String get usageLevel;

  /// No description provided for @leisure.
  ///
  /// In en, this message translates to:
  /// **'Leisure'**
  String get leisure;

  /// No description provided for @usageLevelVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very High ||||||||'**
  String get usageLevelVeryHigh;

  /// No description provided for @usageLevelHigh.
  ///
  /// In en, this message translates to:
  /// **'High ||||||'**
  String get usageLevelHigh;

  /// No description provided for @usageLevelMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium ||||'**
  String get usageLevelMedium;

  /// No description provided for @usageLevelLow.
  ///
  /// In en, this message translates to:
  /// **'Low ||'**
  String get usageLevelLow;

  /// No description provided for @keyInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'KEY INSIGHTS & RECOMMENDATIONS'**
  String get keyInsightsTitle;

  /// No description provided for @personalizedRecommendations.
  ///
  /// In en, this message translates to:
  /// **'PERSONALIZED RECOMMENDATIONS'**
  String get personalizedRecommendations;

  /// No description provided for @insightHighDailyUsage.
  ///
  /// In en, this message translates to:
  /// **'High Daily Usage: You\'re averaging {hours} hours per day of screen time'**
  String insightHighDailyUsage(String hours);

  /// No description provided for @insightLowDailyUsage.
  ///
  /// In en, this message translates to:
  /// **'Low Daily Usage: You\'re averaging {hours} hours per day - great balance!'**
  String insightLowDailyUsage(String hours);

  /// No description provided for @insightModerateUsage.
  ///
  /// In en, this message translates to:
  /// **'Moderate Usage: Averaging {hours} hours per day of screen time'**
  String insightModerateUsage(String hours);

  /// No description provided for @insightExcellentProductivity.
  ///
  /// In en, this message translates to:
  /// **'Excellent Productivity: {percentage}% of your screen time is productive work!'**
  String insightExcellentProductivity(String percentage);

  /// No description provided for @insightGoodProductivity.
  ///
  /// In en, this message translates to:
  /// **'Good Productivity: {percentage}% of your screen time is productive'**
  String insightGoodProductivity(String percentage);

  /// No description provided for @insightLowProductivity.
  ///
  /// In en, this message translates to:
  /// **'Low Productivity Alert: Only {percentage}% of screen time is productive'**
  String insightLowProductivity(String percentage);

  /// No description provided for @insightFocusSessions.
  ///
  /// In en, this message translates to:
  /// **'Focus Sessions: Completed {count} sessions ({avgPerDay} per day on average)'**
  String insightFocusSessions(int count, String avgPerDay);

  /// No description provided for @insightGreatFocusHabit.
  ///
  /// In en, this message translates to:
  /// **'Great Focus Habit: You\'ve built an amazing focus routine with {count} completed sessions!'**
  String insightGreatFocusHabit(int count);

  /// No description provided for @insightNoFocusSessions.
  ///
  /// In en, this message translates to:
  /// **'No Focus Sessions: Consider using focus mode to boost your productivity'**
  String get insightNoFocusSessions;

  /// No description provided for @insightScreenTimeTrend.
  ///
  /// In en, this message translates to:
  /// **'Screen Time Trend: Your usage has {direction} by {percentage}% compared to the previous period'**
  String insightScreenTimeTrend(String direction, String percentage);

  /// No description provided for @insightProductiveTimeTrend.
  ///
  /// In en, this message translates to:
  /// **'Productive Time Trend: Your productive time has {direction} by {percentage}% compared to previous period'**
  String insightProductiveTimeTrend(String direction, String percentage);

  /// No description provided for @directionIncreased.
  ///
  /// In en, this message translates to:
  /// **'increased'**
  String get directionIncreased;

  /// No description provided for @directionDecreased.
  ///
  /// In en, this message translates to:
  /// **'decreased'**
  String get directionDecreased;

  /// No description provided for @insightTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Top Category: {category} dominates with {percentage}% of your total time'**
  String insightTopCategory(String category, String percentage);

  /// No description provided for @insightMostUsedApp.
  ///
  /// In en, this message translates to:
  /// **'Most Used App: {appName} accounts for {percentage}% of your time ({duration})'**
  String insightMostUsedApp(String appName, String percentage, String duration);

  /// No description provided for @insightUsageVaries.
  ///
  /// In en, this message translates to:
  /// **'Usage Varies Significantly: {highDay} had {multiplier}x more usage than {lowDay}'**
  String insightUsageVaries(String highDay, String multiplier, String lowDay);

  /// No description provided for @insightNoInsights.
  ///
  /// In en, this message translates to:
  /// **'No significant insights available'**
  String get insightNoInsights;

  /// No description provided for @recScheduleFocusSessions.
  ///
  /// In en, this message translates to:
  /// **'Try scheduling more focus sessions throughout your day to boost productivity'**
  String get recScheduleFocusSessions;

  /// No description provided for @recSetAppLimits.
  ///
  /// In en, this message translates to:
  /// **'Consider setting app limits on leisure applications'**
  String get recSetAppLimits;

  /// No description provided for @recAimForFocusSessions.
  ///
  /// In en, this message translates to:
  /// **'Aim for at least 1-2 focus sessions per day to build a consistent habit'**
  String get recAimForFocusSessions;

  /// No description provided for @recTakeBreaks.
  ///
  /// In en, this message translates to:
  /// **'Your daily screen time is quite high. Try taking regular breaks using the 20-20-20 rule'**
  String get recTakeBreaks;

  /// No description provided for @recSetDailyGoals.
  ///
  /// In en, this message translates to:
  /// **'Consider setting daily screen time goals to gradually reduce usage'**
  String get recSetDailyGoals;

  /// No description provided for @recBalanceEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment apps account for a large portion of your time. Consider balancing with more productive activities'**
  String get recBalanceEntertainment;

  /// No description provided for @recReviewUsagePatterns.
  ///
  /// In en, this message translates to:
  /// **'Your screen time has increased significantly. Review your usage patterns and set boundaries'**
  String get recReviewUsagePatterns;

  /// No description provided for @recScheduleFocusedWork.
  ///
  /// In en, this message translates to:
  /// **'Your productive time has decreased. Try scheduling focused work blocks in your calendar'**
  String get recScheduleFocusedWork;

  /// No description provided for @recKeepUpGreatWork.
  ///
  /// In en, this message translates to:
  /// **'Keep up the great work! Your screen time habits look healthy'**
  String get recKeepUpGreatWork;

  /// No description provided for @recContinueFocusSessions.
  ///
  /// In en, this message translates to:
  /// **'Continue using focus sessions to maintain productivity'**
  String get recContinueFocusSessions;

  /// No description provided for @sheetSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get sheetSummary;

  /// No description provided for @sheetDailyBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Daily Breakdown'**
  String get sheetDailyBreakdown;

  /// No description provided for @sheetApps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get sheetApps;

  /// No description provided for @sheetInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get sheetInsights;

  /// No description provided for @statusHeader.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusHeader;

  /// No description provided for @workSessions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} work session} other{{count} work sessions}}'**
  String workSessions(int count);

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @workTime.
  ///
  /// In en, this message translates to:
  /// **'Work Time'**
  String get workTime;

  /// No description provided for @breakTime.
  ///
  /// In en, this message translates to:
  /// **'Break Time'**
  String get breakTime;

  /// No description provided for @phasesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Phases Completed'**
  String get phasesCompleted;

  /// No description provided for @hourMinuteFormat.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr {minutes} min'**
  String hourMinuteFormat(String hours, String minutes);

  /// No description provided for @hourOnlyFormat.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr'**
  String hourOnlyFormat(String hours);

  /// No description provided for @minuteFormat.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minuteFormat(String minutes);

  /// No description provided for @sessionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} session} other{{count} sessions}}'**
  String sessionsCount(int count);

  /// No description provided for @workPhases.
  ///
  /// In en, this message translates to:
  /// **'Work Phases'**
  String get workPhases;

  /// No description provided for @averageLength.
  ///
  /// In en, this message translates to:
  /// **'Average Length'**
  String get averageLength;

  /// No description provided for @mostProductive.
  ///
  /// In en, this message translates to:
  /// **'Most Productive'**
  String get mostProductive;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @breaks.
  ///
  /// In en, this message translates to:
  /// **'Breaks'**
  String get breaks;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @minuteShortFormat.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String minuteShortFormat(String minutes);

  /// No description provided for @importTheme.
  ///
  /// In en, this message translates to:
  /// **'Import Theme'**
  String get importTheme;

  /// No description provided for @exportTheme.
  ///
  /// In en, this message translates to:
  /// **'Export Theme'**
  String get exportTheme;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @chooseExportMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose how to export your theme:'**
  String get chooseExportMethod;

  /// No description provided for @saveAsFile.
  ///
  /// In en, this message translates to:
  /// **'Save as File'**
  String get saveAsFile;

  /// No description provided for @saveThemeAsJSONFile.
  ///
  /// In en, this message translates to:
  /// **'Save theme as a JSON file to your device'**
  String get saveThemeAsJSONFile;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyToClipboard;

  /// No description provided for @copyThemeJSONToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy theme data to clipboard'**
  String get copyThemeJSONToClipboard;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareThemeViaSystemSheet.
  ///
  /// In en, this message translates to:
  /// **'Share theme using system share sheet'**
  String get shareThemeViaSystemSheet;

  /// No description provided for @chooseImportMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose how to import a theme:'**
  String get chooseImportMethod;

  /// No description provided for @loadFromFile.
  ///
  /// In en, this message translates to:
  /// **'Load from File'**
  String get loadFromFile;

  /// No description provided for @selectJSONFileFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Select a JSON theme file from your device'**
  String get selectJSONFileFromDevice;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste from Clipboard'**
  String get pasteFromClipboard;

  /// No description provided for @importFromClipboardJSON.
  ///
  /// In en, this message translates to:
  /// **'Import theme from clipboard JSON data'**
  String get importFromClipboardJSON;

  /// No description provided for @importFromFile.
  ///
  /// In en, this message translates to:
  /// **'Import theme from a file'**
  String get importFromFile;

  /// No description provided for @clipboardImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from Clipboard'**
  String get clipboardImportTitle;

  /// No description provided for @clipboardImportDescription.
  ///
  /// In en, this message translates to:
  /// **'Paste or edit the theme JSON data below:'**
  String get clipboardImportDescription;

  /// No description provided for @clipboardImportPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Paste theme JSON here...'**
  String get clipboardImportPlaceholder;

  /// No description provided for @clipboardImportErrorLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load clipboard: {error}'**
  String clipboardImportErrorLoadFailed(String error);

  /// No description provided for @clipboardImportErrorNotJsonObject.
  ///
  /// In en, this message translates to:
  /// **'Expected a JSON object'**
  String get clipboardImportErrorNotJsonObject;

  /// No description provided for @clipboardImportErrorMissingField.
  ///
  /// In en, this message translates to:
  /// **'Missing required field: {field}'**
  String clipboardImportErrorMissingField(String field);

  /// No description provided for @clipboardImportErrorInvalidJson.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON format'**
  String get clipboardImportErrorInvalidJson;

  /// No description provided for @clipboardImportValidData.
  ///
  /// In en, this message translates to:
  /// **'Valid theme data'**
  String get clipboardImportValidData;

  /// No description provided for @themeCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Theme created successfully!'**
  String get themeCreatedSuccessfully;

  /// No description provided for @themeUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Theme updated successfully!'**
  String get themeUpdatedSuccessfully;

  /// No description provided for @themeDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Theme deleted successfully!'**
  String get themeDeletedSuccessfully;

  /// No description provided for @themeExportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Theme exported successfully!'**
  String get themeExportedSuccessfully;

  /// No description provided for @themeCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Theme copied to clipboard!'**
  String get themeCopiedToClipboard;

  /// No description provided for @themeImportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Theme \"{themeName}\" imported successfully!'**
  String themeImportedSuccessfully(String themeName);

  /// No description provided for @noThemeDataFound.
  ///
  /// In en, this message translates to:
  /// **'No theme data found'**
  String get noThemeDataFound;

  /// No description provided for @invalidThemeFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid theme format. Please check the JSON data.'**
  String get invalidThemeFormat;

  /// No description provided for @trackingModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracking Mode'**
  String get trackingModeTitle;

  /// No description provided for @trackingModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how app usage is tracked'**
  String get trackingModeDescription;

  /// No description provided for @trackingModePolling.
  ///
  /// In en, this message translates to:
  /// **'Standard (Low Resource)'**
  String get trackingModePolling;

  /// No description provided for @trackingModePrecise.
  ///
  /// In en, this message translates to:
  /// **'Precise (High Accuracy)'**
  String get trackingModePrecise;

  /// No description provided for @trackingModePollingHint.
  ///
  /// In en, this message translates to:
  /// **'Checks every minute - lower resource usage'**
  String get trackingModePollingHint;

  /// No description provided for @trackingModePreciseHint.
  ///
  /// In en, this message translates to:
  /// **'Real-time tracking - higher accuracy, more resources'**
  String get trackingModePreciseHint;

  /// No description provided for @trackingModeChangeError.
  ///
  /// In en, this message translates to:
  /// **'Failed to change tracking mode. Please try again.'**
  String get trackingModeChangeError;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @monitorKeyboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor Keyboard'**
  String get monitorKeyboardTitle;

  /// No description provided for @monitorKeyboardDescription.
  ///
  /// In en, this message translates to:
  /// **'Track keyboard activity to detect user presence'**
  String get monitorKeyboardDescription;

  /// Title for the changelog dialog
  ///
  /// In en, this message translates to:
  /// **'What\'s New'**
  String get changelogWhatsNew;

  /// Release date label in changelog
  ///
  /// In en, this message translates to:
  /// **'Released on {date}'**
  String changelogReleasedOn(String date);

  /// Shown when the changelog body is empty
  ///
  /// In en, this message translates to:
  /// **'No changelog available for this version.'**
  String get changelogNoContent;

  /// Error dialog title when changelog fetch fails
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Changelog'**
  String get changelogUnableToLoad;

  /// Error dialog body when changelog fetch fails
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve the changelog for this version. Please check your internet connection or visit the GitHub releases page.'**
  String get changelogErrorDescription;

  /// No description provided for @allTracking.
  ///
  /// In en, this message translates to:
  /// **'All Apps'**
  String get allTracking;

  /// No description provided for @notTracking.
  ///
  /// In en, this message translates to:
  /// **'Not Tracked'**
  String get notTracking;

  /// No description provided for @allVisibility.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allVisibility;

  /// No description provided for @visible.
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get visible;

  /// No description provided for @hidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hidden;

  /// No description provided for @todaysLimitUsage.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Limit Usage'**
  String get todaysLimitUsage;

  /// No description provided for @thisWeekAtAGlance.
  ///
  /// In en, this message translates to:
  /// **'This Week at a Glance'**
  String get thisWeekAtAGlance;

  /// No description provided for @hourlyActivityHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Hourly Activity Heatmap'**
  String get hourlyActivityHeatmap;

  /// No description provided for @productivityScore.
  ///
  /// In en, this message translates to:
  /// **'Productivity Score'**
  String get productivityScore;

  /// No description provided for @streaks.
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get streaks;

  /// No description provided for @weekOverWeek.
  ///
  /// In en, this message translates to:
  /// **'Week over Week'**
  String get weekOverWeek;

  /// No description provided for @sameAsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Same as last week'**
  String get sameAsLastWeek;

  /// No description provided for @moreUsageThanLastWeek.
  ///
  /// In en, this message translates to:
  /// **'{percent}% more than last week'**
  String moreUsageThanLastWeek(String percent);

  /// No description provided for @lessUsageThanLastWeek.
  ///
  /// In en, this message translates to:
  /// **'{percent}% less than last week'**
  String lessUsageThanLastWeek(String percent);

  /// No description provided for @limitExceededBy.
  ///
  /// In en, this message translates to:
  /// **'Limit exceeded by {duration}'**
  String limitExceededBy(String duration);

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'{duration} remaining'**
  String timeRemaining(String duration);

  /// No description provided for @totalSessions.
  ///
  /// In en, this message translates to:
  /// **'Total sessions'**
  String get totalSessions;

  /// No description provided for @avgSession.
  ///
  /// In en, this message translates to:
  /// **'Avg session'**
  String get avgSession;

  /// No description provided for @mostActive.
  ///
  /// In en, this message translates to:
  /// **'Most active'**
  String get mostActive;

  /// No description provided for @peakUsage.
  ///
  /// In en, this message translates to:
  /// **'Peak usage'**
  String get peakUsage;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get dailyAverage;

  /// No description provided for @daysUsedInARow.
  ///
  /// In en, this message translates to:
  /// **'Days used in a row'**
  String get daysUsedInARow;

  /// No description provided for @daysSingular.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get daysSingular;

  /// No description provided for @daysPlural.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysPlural;

  /// No description provided for @daysOverLimitInARow.
  ///
  /// In en, this message translates to:
  /// **'Days over limit in a row'**
  String get daysOverLimitInARow;

  /// No description provided for @withinLimitAllWeek.
  ///
  /// In en, this message translates to:
  /// **'Within limit all week'**
  String get withinLimitAllWeek;

  /// No description provided for @productivityScoreGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get productivityScoreGreat;

  /// No description provided for @productivityScoreModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get productivityScoreModerate;

  /// No description provided for @productivityScoreNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get productivityScoreNeedsAttention;

  /// No description provided for @productiveAppMotivation.
  ///
  /// In en, this message translates to:
  /// **'Productive app — keep it up'**
  String get productiveAppMotivation;

  /// No description provided for @nonProductiveAppSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Non-productive — consider reducing'**
  String get nonProductiveAppSuggestion;

  /// No description provided for @legendUsage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get legendUsage;

  /// No description provided for @legendAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get legendAverage;

  /// No description provided for @legendLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get legendLimit;

  /// No description provided for @chartPeak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get chartPeak;

  /// No description provided for @overLimitBy.
  ///
  /// In en, this message translates to:
  /// **'+{duration} over limit'**
  String overLimitBy(String duration);

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @changelog.
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get changelog;

  /// Label shown on export button while export is in progress
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exportingLabel;

  /// Label shown on export button
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get exportExcelLabel;

  /// No description provided for @dailyResetTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Reset Time'**
  String get dailyResetTimeTitle;

  /// No description provided for @dailyResetTimeDescription.
  ///
  /// In en, this message translates to:
  /// **'Set the time when your screen time counter resets for a new day.'**
  String get dailyResetTimeDescription;

  /// No description provided for @narrativeTodaySpent.
  ///
  /// In en, this message translates to:
  /// **'Today you spent {timeStr} at your computer.'**
  String narrativeTodaySpent(String timeStr);

  /// No description provided for @narrativeMostFocused.
  ///
  /// In en, this message translates to:
  /// **'Your most focused stretch was {start} – {end}.'**
  String narrativeMostFocused(String start, String end);

  /// No description provided for @narrativeFocusSessions.
  ///
  /// In en, this message translates to:
  /// **'You completed {focusSessions} focus {focusSessionsCount, plural, =1{session} other{sessions}} totalling {fsMinutes}m.'**
  String narrativeFocusSessions(
      int focusSessions, int focusSessionsCount, int fsMinutes);

  /// No description provided for @narrativeCheckedAppShort.
  ///
  /// In en, this message translates to:
  /// **'You checked {topAppName} {topAppOpenCount} times but kept each visit short.'**
  String narrativeCheckedAppShort(String topAppName, int topAppOpenCount);

  /// No description provided for @narrativeCheckedAppLong.
  ///
  /// In en, this message translates to:
  /// **'Most of your time went to {topAppName} in just {topAppOpenCount} {topAppOpenCountPlural, plural, =1{session} other{sessions}}.'**
  String narrativeCheckedAppLong(
      String topAppName, int topAppOpenCount, int topAppOpenCountPlural);

  /// No description provided for @narrativeToneSolid.
  ///
  /// In en, this message translates to:
  /// **'Solid day.'**
  String get narrativeToneSolid;

  /// No description provided for @narrativeToneDecent.
  ///
  /// In en, this message translates to:
  /// **'Decent progress.'**
  String get narrativeToneDecent;

  /// No description provided for @narrativeToneLight.
  ///
  /// In en, this message translates to:
  /// **'Light day — nothing wrong with that.'**
  String get narrativeToneLight;

  /// No description provided for @narrativeToneImprove.
  ///
  /// In en, this message translates to:
  /// **'Room to improve tomorrow.'**
  String get narrativeToneImprove;

  /// No description provided for @habitDnaTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Habit DNA'**
  String get habitDnaTitle;

  /// No description provided for @habitDnaAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'{daysAnalyzed}d analyzed'**
  String habitDnaAnalyzed(int daysAnalyzed);

  /// No description provided for @habitDnaChronotype.
  ///
  /// In en, this message translates to:
  /// **'Chronotype'**
  String get habitDnaChronotype;

  /// No description provided for @habitDnaWorkStyle.
  ///
  /// In en, this message translates to:
  /// **'Work Style'**
  String get habitDnaWorkStyle;

  /// No description provided for @habitDnaPeakFocus.
  ///
  /// In en, this message translates to:
  /// **'Peak Focus'**
  String get habitDnaPeakFocus;

  /// No description provided for @habitDnaAvgSession.
  ///
  /// In en, this message translates to:
  /// **'Avg Session'**
  String get habitDnaAvgSession;

  /// No description provided for @habitDnaBestDay.
  ///
  /// In en, this message translates to:
  /// **'Best Day'**
  String get habitDnaBestDay;

  /// No description provided for @habitDnaRoughDay.
  ///
  /// In en, this message translates to:
  /// **'Rough Day'**
  String get habitDnaRoughDay;

  /// No description provided for @habitDnaKryptonite.
  ///
  /// In en, this message translates to:
  /// **'Top distraction: {appName}'**
  String habitDnaKryptonite(String appName);

  /// No description provided for @chronotypeMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning Person'**
  String get chronotypeMorning;

  /// No description provided for @chronotypeAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon Peak'**
  String get chronotypeAfternoon;

  /// No description provided for @chronotypeNight.
  ///
  /// In en, this message translates to:
  /// **'Night Owl'**
  String get chronotypeNight;

  /// No description provided for @chronotypeMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get chronotypeMixed;

  /// No description provided for @workStyleDeep.
  ///
  /// In en, this message translates to:
  /// **'Deep Focus'**
  String get workStyleDeep;

  /// No description provided for @workStyleSwitcher.
  ///
  /// In en, this message translates to:
  /// **'Task Switcher'**
  String get workStyleSwitcher;

  /// No description provided for @workStyleBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get workStyleBalanced;

  /// No description provided for @timeFormatAm.
  ///
  /// In en, this message translates to:
  /// **'{hour} AM'**
  String timeFormatAm(int hour);

  /// No description provided for @timeFormatPm.
  ///
  /// In en, this message translates to:
  /// **'{hour} PM'**
  String timeFormatPm(int hour);

  /// No description provided for @timeFormatMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get timeFormatMidnight;

  /// No description provided for @timeFormatNoon.
  ///
  /// In en, this message translates to:
  /// **'Noon'**
  String get timeFormatNoon;

  /// No description provided for @weeklyStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get weeklyStoryTitle;

  /// No description provided for @weeklyStoryWeekNumber.
  ///
  /// In en, this message translates to:
  /// **'Week {weekNumber}'**
  String weeklyStoryWeekNumber(int weekNumber);

  /// No description provided for @weeklyStoryHeadline.
  ///
  /// In en, this message translates to:
  /// **'Week {weekNumber} — {timeStr} on screen so far.'**
  String weeklyStoryHeadline(int weekNumber, String timeStr);

  /// No description provided for @weeklyStoryReclaimed.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reclaimed {diff} compared to Week 1.'**
  String weeklyStoryReclaimed(String diff);

  /// No description provided for @weeklyStoryUp.
  ///
  /// In en, this message translates to:
  /// **'Screen time is up {diff} from Week 1.'**
  String weeklyStoryUp(String diff);

  /// No description provided for @weeklyStoryImprovementArea.
  ///
  /// In en, this message translates to:
  /// **'Still working on: {timeLabel} in {worstCat}.'**
  String weeklyStoryImprovementArea(String timeLabel, String worstCat);

  /// No description provided for @weekdayNameMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayNameMonday;

  /// No description provided for @weekdayNameTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayNameTuesday;

  /// No description provided for @weekdayNameWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayNameWednesday;

  /// No description provided for @weekdayNameThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayNameThursday;

  /// No description provided for @weekdayNameFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayNameFriday;

  /// No description provided for @weekdayNameSaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdayNameSaturday;

  /// No description provided for @weekdayNameSunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdayNameSunday;

  /// No description provided for @weekdayNameUnknown.
  ///
  /// In en, this message translates to:
  /// **'that day'**
  String get weekdayNameUnknown;

  /// No description provided for @browserTitle.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get browserTitle;

  /// No description provided for @browserWebsiteTracking.
  ///
  /// In en, this message translates to:
  /// **'Website tracking'**
  String get browserWebsiteTracking;

  /// No description provided for @browserSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track and manage your website usage'**
  String get browserSubtitle;

  /// No description provided for @browserToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get browserToday;

  /// No description provided for @browserSites.
  ///
  /// In en, this message translates to:
  /// **'Sites'**
  String get browserSites;

  /// No description provided for @browserSevenDayActivity.
  ///
  /// In en, this message translates to:
  /// **'7-Day Activity'**
  String get browserSevenDayActivity;

  /// No description provided for @browserExtensionSettings.
  ///
  /// In en, this message translates to:
  /// **'Extension Settings'**
  String get browserExtensionSettings;

  /// No description provided for @browserSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get browserSyncing;

  /// No description provided for @browserTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get browserTabOverview;

  /// No description provided for @browserTabWebsites.
  ///
  /// In en, this message translates to:
  /// **'Websites'**
  String get browserTabWebsites;

  /// No description provided for @browserTabCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get browserTabCategories;

  /// No description provided for @browserTabLimits.
  ///
  /// In en, this message translates to:
  /// **'Limits'**
  String get browserTabLimits;

  /// No description provided for @browserTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get browserTabHistory;

  /// No description provided for @browserHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Overview'**
  String get browserHistoryTitle;

  /// No description provided for @browserHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your browsing time over the last 7 days'**
  String get browserHistorySubtitle;

  /// No description provided for @browserHistoryNoData.
  ///
  /// In en, this message translates to:
  /// **'No browsing data yet'**
  String get browserHistoryNoData;

  /// No description provided for @browserHistoryAvgPerDay.
  ///
  /// In en, this message translates to:
  /// **'Avg / day'**
  String get browserHistoryAvgPerDay;

  /// No description provided for @browserHistoryPeakDay.
  ///
  /// In en, this message translates to:
  /// **'Peak day'**
  String get browserHistoryPeakDay;

  /// No description provided for @browserHistoryTotalWeek.
  ///
  /// In en, this message translates to:
  /// **'Total this week'**
  String get browserHistoryTotalWeek;

  /// No description provided for @browserHistoryTopSites.
  ///
  /// In en, this message translates to:
  /// **'Top sites this week'**
  String get browserHistoryTopSites;

  /// No description provided for @browserTodayWebTime.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Web Time'**
  String get browserTodayWebTime;

  /// No description provided for @browserSitesVisited.
  ///
  /// In en, this message translates to:
  /// **'Sites Visited'**
  String get browserSitesVisited;

  /// No description provided for @browserPageVisits.
  ///
  /// In en, this message translates to:
  /// **'Page Visits'**
  String get browserPageVisits;

  /// No description provided for @browserTopSitesToday.
  ///
  /// In en, this message translates to:
  /// **'Top Sites Today'**
  String get browserTopSitesToday;

  /// No description provided for @browserViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all →'**
  String get browserViewAll;

  /// No description provided for @browserNoWebActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'No web activity yet today'**
  String get browserNoWebActivityTitle;

  /// No description provided for @browserNoActivityWebSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse the web to start tracking your time'**
  String get browserNoActivityWebSubtitle;

  /// No description provided for @browserNoActivityDesktopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Install the browser extension to start tracking'**
  String get browserNoActivityDesktopSubtitle;

  /// No description provided for @browserNoCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get browserNoCategoriesTitle;

  /// No description provided for @browserNoCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Categories appear once websites are tracked'**
  String get browserNoCategoriesSubtitle;

  /// No description provided for @browserByCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get browserByCategory;

  /// No description provided for @browserVisitCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 visit} other{{count} visits}}'**
  String browserVisitCount(int count);

  /// No description provided for @browserSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search website or domain…'**
  String get browserSearchPlaceholder;

  /// No description provided for @browserFilterAllTracking.
  ///
  /// In en, this message translates to:
  /// **'All Tracking'**
  String get browserFilterAllTracking;

  /// No description provided for @browserFilterTracked.
  ///
  /// In en, this message translates to:
  /// **'Tracked'**
  String get browserFilterTracked;

  /// No description provided for @browserFilterUntracked.
  ///
  /// In en, this message translates to:
  /// **'Untracked'**
  String get browserFilterUntracked;

  /// No description provided for @browserFilterAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get browserFilterAllTypes;

  /// No description provided for @browserFilterUnproductive.
  ///
  /// In en, this message translates to:
  /// **'Unproductive'**
  String get browserFilterUnproductive;

  /// No description provided for @browserWebsiteCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 website} other{{count} websites}}'**
  String browserWebsiteCount(int count);

  /// No description provided for @browserColumnDomain.
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get browserColumnDomain;

  /// No description provided for @browserColumnTimeToday.
  ///
  /// In en, this message translates to:
  /// **'Time Today'**
  String get browserColumnTimeToday;

  /// No description provided for @browserColumnVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get browserColumnVisits;

  /// No description provided for @browserColumnTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get browserColumnTracking;

  /// No description provided for @browserNoWebsitesTitle.
  ///
  /// In en, this message translates to:
  /// **'No websites found'**
  String get browserNoWebsitesTitle;

  /// No description provided for @browserNoWebsitesWebSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse the web — your sites will appear here.'**
  String get browserNoWebsitesWebSubtitle;

  /// No description provided for @browserNoWebsitesDesktopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or wait for the\nextension to sync some data.'**
  String get browserNoWebsitesDesktopSubtitle;

  /// No description provided for @browserTimeDistribution.
  ///
  /// In en, this message translates to:
  /// **'Time Distribution'**
  String get browserTimeDistribution;

  /// No description provided for @browserSiteCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 site} other{{count} sites}}'**
  String browserSiteCount(int count);

  /// No description provided for @browserActiveLimits.
  ///
  /// In en, this message translates to:
  /// **'Active Limits'**
  String get browserActiveLimits;

  /// No description provided for @browserActiveLimitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 website with daily limits} other{{count} websites with daily limits}}'**
  String browserActiveLimitsSubtitle(int count);

  /// No description provided for @browserNoLimitsTitle.
  ///
  /// In en, this message translates to:
  /// **'No limits set'**
  String get browserNoLimitsTitle;

  /// No description provided for @browserNoLimitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set daily time limits below'**
  String get browserNoLimitsSubtitle;

  /// No description provided for @browserAllWebsites.
  ///
  /// In en, this message translates to:
  /// **'All Websites'**
  String get browserAllWebsites;

  /// No description provided for @browserAllWebsitesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap a site to set or change its daily limit'**
  String get browserAllWebsitesSubtitle;

  /// No description provided for @browserAllSitesHaveLimits.
  ///
  /// In en, this message translates to:
  /// **'All sites have limits'**
  String get browserAllSitesHaveLimits;

  /// No description provided for @browserNoWebsitesTrackedTitle.
  ///
  /// In en, this message translates to:
  /// **'No websites tracked yet'**
  String get browserNoWebsitesTrackedTitle;

  /// No description provided for @browserNoWebsitesTrackedWebSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse the web to see your sites here'**
  String get browserNoWebsitesTrackedWebSubtitle;

  /// No description provided for @browserNoWebsitesTrackedDesktopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Install the extension and browse to get started'**
  String get browserNoWebsitesTrackedDesktopSubtitle;

  /// No description provided for @browserDailyLimitDialog.
  ///
  /// In en, this message translates to:
  /// **'Daily Limit – {domain}'**
  String browserDailyLimitDialog(String domain);

  /// No description provided for @browserDailyLimitDialogDesc.
  ///
  /// In en, this message translates to:
  /// **'Set how long you can visit this site per day.'**
  String get browserDailyLimitDialogDesc;

  /// No description provided for @browserHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get browserHours;

  /// No description provided for @browserRemoveLimit.
  ///
  /// In en, this message translates to:
  /// **'Remove Limit'**
  String get browserRemoveLimit;

  /// No description provided for @browserTimeUsed.
  ///
  /// In en, this message translates to:
  /// **'{time} used'**
  String browserTimeUsed(String time);

  /// No description provided for @browserSetLimit.
  ///
  /// In en, this message translates to:
  /// **'Set limit'**
  String get browserSetLimit;

  /// No description provided for @browserExtensionMode.
  ///
  /// In en, this message translates to:
  /// **'Extension Mode'**
  String get browserExtensionMode;

  /// No description provided for @browserDesktopAppUrl.
  ///
  /// In en, this message translates to:
  /// **'Desktop App URL'**
  String get browserDesktopAppUrl;

  /// No description provided for @browserDesktopAppUrlDesc.
  ///
  /// In en, this message translates to:
  /// **'The URL where the Scolect desktop app is running its local server.'**
  String get browserDesktopAppUrlDesc;

  /// No description provided for @browserAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get browserAbout;

  /// No description provided for @browserAboutExtension.
  ///
  /// In en, this message translates to:
  /// **'Extension'**
  String get browserAboutExtension;

  /// No description provided for @browserAboutExtensionValue.
  ///
  /// In en, this message translates to:
  /// **'Scolect – Web Time Tracker'**
  String get browserAboutExtensionValue;

  /// No description provided for @browserAboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get browserAboutVersion;

  /// No description provided for @browserAboutStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get browserAboutStorage;

  /// No description provided for @browserAboutStorageValue.
  ///
  /// In en, this message translates to:
  /// **'chrome.storage.local'**
  String get browserAboutStorageValue;

  /// No description provided for @browserAboutHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get browserAboutHistory;

  /// No description provided for @browserAboutHistoryValue.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days retained'**
  String get browserAboutHistoryValue;

  /// No description provided for @browserConnectedBrowsers.
  ///
  /// In en, this message translates to:
  /// **'Connected Browsers'**
  String get browserConnectedBrowsers;

  /// No description provided for @browserConnectedBrowsersDesc.
  ///
  /// In en, this message translates to:
  /// **'Browsers that have synced website data to this desktop app. Rename them for reference, or remove ones you no longer use.'**
  String get browserConnectedBrowsersDesc;

  /// No description provided for @browserConnectedBrowsersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No browsers have connected yet.'**
  String get browserConnectedBrowsersEmpty;

  /// No description provided for @browserSourceAllBrowsers.
  ///
  /// In en, this message translates to:
  /// **'All Browsers'**
  String get browserSourceAllBrowsers;

  /// No description provided for @browserSourceDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Browser {index}'**
  String browserSourceDefaultName(int index);

  /// No description provided for @browserSourceLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get browserSourceLastSeen;

  /// No description provided for @browserSourceLastSeenDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String browserSourceLastSeenDaysAgo(int days);

  /// No description provided for @browserRenameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Browser'**
  String get browserRenameDialogTitle;

  /// No description provided for @browserSourcePingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Locate / Ping Browser'**
  String get browserSourcePingTooltip;

  /// No description provided for @browserSourcePingSent.
  ///
  /// In en, this message translates to:
  /// **'Ping sent to {name}'**
  String browserSourcePingSent(String name);

  /// No description provided for @browserSourceRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Browser?'**
  String get browserSourceRemoveTitle;

  /// No description provided for @browserSourceRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from your connected browsers? Its usage history is kept, but it will need to reconnect to sync again.'**
  String browserSourceRemoveConfirm(String name);

  /// No description provided for @browserLimitsScopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Website Limits Scope'**
  String get browserLimitsScopeTitle;

  /// No description provided for @browserLimitsScopeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose whether website limits and tracking apply per browser profile or globally across all browsers.'**
  String get browserLimitsScopeSubtitle;

  /// No description provided for @browserLimitsScopeScoped.
  ///
  /// In en, this message translates to:
  /// **'Per Browser Profile (Scoped)'**
  String get browserLimitsScopeScoped;

  /// No description provided for @browserLimitsScopeScopedDesc.
  ///
  /// In en, this message translates to:
  /// **'Limits apply only to the specific browser profile where configured.'**
  String get browserLimitsScopeScopedDesc;

  /// No description provided for @browserLimitsScopeGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global (Cross-Browser)'**
  String get browserLimitsScopeGlobal;

  /// No description provided for @browserLimitsScopeGlobalDesc.
  ///
  /// In en, this message translates to:
  /// **'Limits apply across all connected browsers combined.'**
  String get browserLimitsScopeGlobalDesc;

  /// No description provided for @browserSourceRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get browserSourceRemoveAction;

  /// No description provided for @browserDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get browserDangerZone;

  /// No description provided for @browserClearDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All Website Data'**
  String get browserClearDataTitle;

  /// No description provided for @browserClearDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently deletes all tracked website history. This cannot be undone.'**
  String get browserClearDataDesc;

  /// No description provided for @browserClearDataButton.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get browserClearDataButton;

  /// No description provided for @browserAreYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get browserAreYouSure;

  /// No description provided for @browserYesDelete.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete'**
  String get browserYesDelete;

  /// No description provided for @browserDesktopUrlSaved.
  ///
  /// In en, this message translates to:
  /// **'Desktop URL saved'**
  String get browserDesktopUrlSaved;

  /// No description provided for @browserDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All website data cleared'**
  String get browserDataCleared;

  /// No description provided for @browserTrackingActive.
  ///
  /// In en, this message translates to:
  /// **'Tracking Active'**
  String get browserTrackingActive;

  /// No description provided for @browserTrackingActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Your browser activity is being tracked and\nsynced to the Scolect desktop app.'**
  String get browserTrackingActiveDesc;

  /// No description provided for @browserConnectedToDesktop.
  ///
  /// In en, this message translates to:
  /// **'Connected to Scolect Desktop'**
  String get browserConnectedToDesktop;

  /// No description provided for @browserDesktopNotReachable.
  ///
  /// In en, this message translates to:
  /// **'Scolect Desktop not reachable'**
  String get browserDesktopNotReachable;

  /// No description provided for @browserRefreshSyncStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh sync status'**
  String get browserRefreshSyncStatus;

  /// No description provided for @browserSwitchToStandalone.
  ///
  /// In en, this message translates to:
  /// **'Switch to Standalone mode →'**
  String get browserSwitchToStandalone;

  /// No description provided for @browserSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Browser Extension'**
  String get browserSetupTitle;

  /// No description provided for @browserSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable the local server so the Scolect browser extension can sync your web activity to the desktop application.'**
  String get browserSetupSubtitle;

  /// No description provided for @browserSetupEnableServer.
  ///
  /// In en, this message translates to:
  /// **'Enable Extension Server'**
  String get browserSetupEnableServer;

  /// No description provided for @browserSetupServerRunning.
  ///
  /// In en, this message translates to:
  /// **'Server running · port {port}'**
  String browserSetupServerRunning(int port);

  /// No description provided for @browserSetupServerOff.
  ///
  /// In en, this message translates to:
  /// **'Server disabled'**
  String get browserSetupServerOff;

  /// No description provided for @browserSetupStep1.
  ///
  /// In en, this message translates to:
  /// **'Enable the server using the toggle above'**
  String get browserSetupStep1;

  /// No description provided for @browserSetupStep2.
  ///
  /// In en, this message translates to:
  /// **'Install the Scolect extension in your browser'**
  String get browserSetupStep2;

  /// No description provided for @browserSetupStep3.
  ///
  /// In en, this message translates to:
  /// **'Open your browser and visit any site'**
  String get browserSetupStep3;

  /// No description provided for @browserSetupStep4.
  ///
  /// In en, this message translates to:
  /// **'Web activity will appear here automatically'**
  String get browserSetupStep4;

  /// No description provided for @browserSetupHowTo.
  ///
  /// In en, this message translates to:
  /// **'How to get started'**
  String get browserSetupHowTo;

  /// No description provided for @browserSetupServerActive.
  ///
  /// In en, this message translates to:
  /// **'Server Active'**
  String get browserSetupServerActive;

  /// No description provided for @browserSetupServerActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Your browser extension can now connect and sync data.'**
  String get browserSetupServerActiveDesc;

  /// No description provided for @browserSyncedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Synced just now'**
  String get browserSyncedJustNow;

  /// No description provided for @browserSyncedMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'Synced {minutes}m ago'**
  String browserSyncedMinutesAgo(int minutes);

  /// No description provided for @browserSyncedHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Synced {hours}h ago'**
  String browserSyncedHoursAgo(int hours);

  /// No description provided for @browserNeverSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get browserNeverSynced;

  /// No description provided for @browserSyncStalled.
  ///
  /// In en, this message translates to:
  /// **'Sync stalled — check the extension'**
  String get browserSyncStalled;

  /// No description provided for @browserServerPort.
  ///
  /// In en, this message translates to:
  /// **'Server Port'**
  String get browserServerPort;

  /// No description provided for @browserServerPortDesc.
  ///
  /// In en, this message translates to:
  /// **'Port the local server listens on. Change this if port 46000 is already in use.'**
  String get browserServerPortDesc;

  /// No description provided for @browserServerPortSaved.
  ///
  /// In en, this message translates to:
  /// **'Port updated — extension reconnecting'**
  String get browserServerPortSaved;

  /// No description provided for @browserServerPortInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a port between 1024 and 65535'**
  String get browserServerPortInvalid;

  /// No description provided for @browserDisableServer.
  ///
  /// In en, this message translates to:
  /// **'Disable Extension Server'**
  String get browserDisableServer;

  /// No description provided for @browserDesktopClearDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Browser Data'**
  String get browserDesktopClearDataTitle;

  /// No description provided for @browserDesktopClearDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Delete all website usage history and settings synced from the browser extension. Your native app tracking data is not affected.'**
  String get browserDesktopClearDataDescription;

  /// No description provided for @browserDesktopClearDataButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete Browser Data'**
  String get browserDesktopClearDataButtonLabel;

  /// No description provided for @browserDesktopClearDataDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Browser Data?'**
  String get browserDesktopClearDataDialogTitle;

  /// No description provided for @browserDesktopClearDataDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all website usage history and site settings synced from the browser extension. Your native app tracking data will not be affected. You won\'t be able to recover this data. Do you want to proceed?'**
  String get browserDesktopClearDataDialogContent;

  /// No description provided for @browserEditSiteName.
  ///
  /// In en, this message translates to:
  /// **'Edit display name'**
  String get browserEditSiteName;

  /// No description provided for @browserSiteNameHint.
  ///
  /// In en, this message translates to:
  /// **'Display name (e.g. YouTube)'**
  String get browserSiteNameHint;

  /// No description provided for @browserNoDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get browserNoDataYet;

  /// No description provided for @browserNoProductiveSites.
  ///
  /// In en, this message translates to:
  /// **'No productive sites logged'**
  String get browserNoProductiveSites;

  /// No description provided for @browserDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get browserDays;

  /// No description provided for @browserProductivePercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Productive'**
  String browserProductivePercent(int percent);

  /// No description provided for @browserLimitsBadge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Limit} other{{count} Limits}}'**
  String browserLimitsBadge(int count);

  /// No description provided for @browserTopFocus.
  ///
  /// In en, this message translates to:
  /// **'Top Focus'**
  String get browserTopFocus;

  /// No description provided for @browserLimitsHealth.
  ///
  /// In en, this message translates to:
  /// **'Limits Health'**
  String get browserLimitsHealth;

  /// No description provided for @browserAllRespected.
  ///
  /// In en, this message translates to:
  /// **'All Respected'**
  String get browserAllRespected;

  /// No description provided for @browserLimitsExceeded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Exceeded} other{{count} Exceeded}}'**
  String browserLimitsExceeded(int count);

  /// No description provided for @browserLimitsActiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 limit active} other{{count} limits active}}'**
  String browserLimitsActiveCount(int count);

  /// No description provided for @browserCategoryShare.
  ///
  /// In en, this message translates to:
  /// **'Category Share'**
  String get browserCategoryShare;

  /// No description provided for @browserProductiveTime.
  ///
  /// In en, this message translates to:
  /// **'Productive Time'**
  String get browserProductiveTime;

  /// No description provided for @browserColumnDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily Limit'**
  String get browserColumnDailyLimit;

  /// No description provided for @browserDistracting.
  ///
  /// In en, this message translates to:
  /// **'Distracting'**
  String get browserDistracting;

  /// No description provided for @browserClassification.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get browserClassification;

  /// No description provided for @browserPageSessions.
  ///
  /// In en, this message translates to:
  /// **'Page sessions'**
  String get browserPageSessions;

  /// No description provided for @browserTotalTimeToday.
  ///
  /// In en, this message translates to:
  /// **'Total time today'**
  String get browserTotalTimeToday;

  /// No description provided for @browserOpenInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in Browser'**
  String get browserOpenInBrowser;

  /// No description provided for @browserEditDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Edit Limit'**
  String get browserEditDailyLimit;

  /// No description provided for @browserSetDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Set Daily Limit'**
  String get browserSetDailyLimit;

  /// No description provided for @browserRecommendedLimits.
  ///
  /// In en, this message translates to:
  /// **'Recommended Limits'**
  String get browserRecommendedLimits;

  /// No description provided for @browserRecommendedLimitsDesc.
  ///
  /// In en, this message translates to:
  /// **'High usage detected today on these unconstrained sites'**
  String get browserRecommendedLimitsDesc;

  /// No description provided for @browserSetOneHourLimit.
  ///
  /// In en, this message translates to:
  /// **'Set 1h Limit'**
  String get browserSetOneHourLimit;

  /// No description provided for @browserCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get browserCustom;

  /// No description provided for @browserPeriodTotal.
  ///
  /// In en, this message translates to:
  /// **'Period Total'**
  String get browserPeriodTotal;

  /// No description provided for @browserActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Active Days'**
  String get browserActiveDays;

  /// No description provided for @browserDayInspector.
  ///
  /// In en, this message translates to:
  /// **'Day Inspector'**
  String get browserDayInspector;

  /// No description provided for @browserDayInspectorPrompt.
  ///
  /// In en, this message translates to:
  /// **'Click any bar in the chart to inspect top visited websites on that day.'**
  String get browserDayInspectorPrompt;

  /// No description provided for @browserVsAverage.
  ///
  /// In en, this message translates to:
  /// **'{percent}% vs avg'**
  String browserVsAverage(String percent);

  /// No description provided for @browserTopSitesOnDate.
  ///
  /// In en, this message translates to:
  /// **'Top sites on {date}'**
  String browserTopSitesOnDate(String date);

  /// No description provided for @browserLast7Days.
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get browserLast7Days;

  /// No description provided for @browserLast14Days.
  ///
  /// In en, this message translates to:
  /// **'14 Days'**
  String get browserLast14Days;

  /// No description provided for @browserLast30Days.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get browserLast30Days;

  /// No description provided for @browserLimitsExtensionInfo.
  ///
  /// In en, this message translates to:
  /// **'Browser limits are enforced by the Chrome Extension'**
  String get browserLimitsExtensionInfo;

  /// No description provided for @browserLimitsExtensionInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'When a daily limit is reached, the extension automatically blocks access to that domain in the browser.'**
  String get browserLimitsExtensionInfoDesc;

  /// No description provided for @browserSevenDayTotalSummary.
  ///
  /// In en, this message translates to:
  /// **'7d Total: {time} · {visits} visits'**
  String browserSevenDayTotalSummary(String time, int visits);

  /// No description provided for @browserAllSitesHaveLimitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All tracked websites currently have active limits configured.'**
  String get browserAllSitesHaveLimitsSubtitle;

  /// No description provided for @browserActiveLimitsHealthSafe.
  ///
  /// In en, this message translates to:
  /// **'All limits are currently within safe daily thresholds.'**
  String get browserActiveLimitsHealthSafe;

  /// No description provided for @browserActiveLimitsHealthWarning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 website has exceeded its daily limit!} other{{count} websites have exceeded their daily limits!}}'**
  String browserActiveLimitsHealthWarning(int count);

  /// No description provided for @browserShareOfWeb.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of web'**
  String browserShareOfWeb(int percent);

  /// No description provided for @browserLimitEnforced.
  ///
  /// In en, this message translates to:
  /// **'Limit enforced'**
  String get browserLimitEnforced;

  /// No description provided for @browserClickToSetLimitPrompt.
  ///
  /// In en, this message translates to:
  /// **'Click to set limit'**
  String get browserClickToSetLimitPrompt;

  /// No description provided for @webExportDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Download all extension data as a JSON backup file'**
  String get webExportDataDescription;

  /// No description provided for @webImportDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore extension data from a previously exported JSON file'**
  String get webImportDataDescription;

  /// No description provided for @webExportSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Successful'**
  String get webExportSuccessTitle;

  /// No description provided for @webExportSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your data has been downloaded as a JSON file.'**
  String get webExportSuccessMessage;

  /// No description provided for @webImportSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Successful'**
  String get webImportSuccessTitle;

  /// No description provided for @webImportSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} storage {count, plural, =1{key} other{keys}} restored.'**
  String webImportSuccessMessage(int count);

  /// No description provided for @webImportConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup?'**
  String get webImportConfirmTitle;

  /// No description provided for @webImportConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite your current extension data with the contents of the backup file. Existing data for restored keys will be replaced.'**
  String get webImportConfirmMessage;

  /// No description provided for @webImportConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get webImportConfirmButton;

  /// No description provided for @blockOverlayBadge.
  ///
  /// In en, this message translates to:
  /// **'Scolect Screen Time'**
  String get blockOverlayBadge;

  /// No description provided for @blockOverlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Limit Reached'**
  String get blockOverlayTitle;

  /// No description provided for @blockOverlayTimeSpent.
  ///
  /// In en, this message translates to:
  /// **'Time spent'**
  String get blockOverlayTimeSpent;

  /// No description provided for @blockOverlayDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily limit'**
  String get blockOverlayDailyLimit;

  /// No description provided for @blockOverlayVisitsToday.
  ///
  /// In en, this message translates to:
  /// **'Visits today'**
  String get blockOverlayVisitsToday;

  /// No description provided for @blockOverlayResetsIn.
  ///
  /// In en, this message translates to:
  /// **'Resets in'**
  String get blockOverlayResetsIn;

  /// No description provided for @blockOverlayGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get blockOverlayGoBack;

  /// No description provided for @blockOverlayOpenDashboard.
  ///
  /// In en, this message translates to:
  /// **'Open Dashboard'**
  String get blockOverlayOpenDashboard;

  /// No description provided for @blockOverlayUnblockToday.
  ///
  /// In en, this message translates to:
  /// **'Unblock for today'**
  String get blockOverlayUnblockToday;

  /// No description provided for @blockOverlayUnblockConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Type {siteName} to unblock for the rest of today:'**
  String blockOverlayUnblockConfirmLabel(String siteName);

  /// No description provided for @blockOverlayUnblockButton.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get blockOverlayUnblockButton;

  /// No description provided for @blockOverlayFooter.
  ///
  /// In en, this message translates to:
  /// **'Scolect · screen time tracker'**
  String get blockOverlayFooter;

  /// TRANSLATE: Toggle label in the app/site edit dialog to mark an item as private (password-gated)
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get markAsPrivate;

  /// TRANSLATE: Title of the password prompt dialog shown to reveal private items
  ///
  /// In en, this message translates to:
  /// **'Unlock Private Mode'**
  String get privateModeUnlockTitle;

  /// TRANSLATE: Placeholder text for the password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get privateModePasswordPlaceholder;

  /// TRANSLATE: Placeholder text for the confirm-password input field when setting a new password
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get privateModeConfirmPasswordPlaceholder;

  /// TRANSLATE: Error message shown when the entered private mode password is wrong
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get privateModeIncorrectPassword;

  /// TRANSLATE: Button label to submit the password and unlock private mode
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get privateModeUnlockAction;

  /// TRANSLATE: Button label to reveal private items (triggers the unlock prompt)
  ///
  /// In en, this message translates to:
  /// **'Show private'**
  String get privateModeShowAction;

  /// TRANSLATE: Button label to re-lock and hide private items
  ///
  /// In en, this message translates to:
  /// **'Hide private'**
  String get privateModeHideAction;

  /// TRANSLATE: Secondary hint appended to the titlebar toggle's tooltip, telling the user right-click/long-press ends the session immediately
  ///
  /// In en, this message translates to:
  /// **'Right-click to lock now'**
  String get privateModeLockHint;

  /// TRANSLATE: Description under the Settings toggle that switches every page to private-only data
  ///
  /// In en, this message translates to:
  /// **'Show only apps and websites marked private, in place of your everyday view. Also available from the titlebar.'**
  String get privateModeShowOnlyDescription;

  /// TRANSLATE: Title of the Private Mode settings card
  ///
  /// In en, this message translates to:
  /// **'Private Mode'**
  String get privateModeSectionTitle;

  /// TRANSLATE: Title/row label shown when no private mode password has been set yet
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get privateModeSetPasswordTitle;

  /// TRANSLATE: Title/row label shown when a private mode password already exists and can be changed
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get privateModeChangePasswordTitle;

  /// TRANSLATE: Description under the set/change password setting row
  ///
  /// In en, this message translates to:
  /// **'Set a password to hide apps and websites marked private until unlocked.'**
  String get privateModePasswordDescription;

  /// TRANSLATE: Button label to open the set-password dialog
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get privateModeSetPasswordAction;

  /// TRANSLATE: Button label to open the change-password dialog
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get privateModeChangePasswordAction;

  /// TRANSLATE: Validation error when submitting an empty password
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get privateModePasswordEmpty;

  /// TRANSLATE: Validation error when password and confirm-password fields differ
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get privateModePasswordMismatch;

  /// TRANSLATE: Setting row title for the toggle controlling whether private items count toward daily totals
  ///
  /// In en, this message translates to:
  /// **'Include Private Items in Totals'**
  String get privateModeIncludeInTotalsTitle;

  /// TRANSLATE: Description under the include-in-totals toggle
  ///
  /// In en, this message translates to:
  /// **'When on, private apps and websites still count toward your daily totals even while hidden.'**
  String get privateModeIncludeInTotalsDescription;

  /// TRANSLATE: Setting row title for the private mode session auto-relock timeout picker
  ///
  /// In en, this message translates to:
  /// **'Auto-Lock After'**
  String get privateModeSessionTimeoutTitle;

  /// TRANSLATE: Description under the auto-lock timeout setting
  ///
  /// In en, this message translates to:
  /// **'Private Mode automatically re-locks after this many minutes.'**
  String get privateModeSessionTimeoutDescription;

  /// TRANSLATE: Setting row title and confirmation dialog title for resetting/clearing the private mode password
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get privateModeResetPasswordTitle;

  /// TRANSLATE: Description/warning text explaining what resetting the password does, shown both under the setting row and in the confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Clears your Private Mode password. Items already marked private stay private until you set a new password — there is no password recovery.'**
  String get privateModeResetPasswordDescription;

  /// TRANSLATE: Button label to confirm resetting the private mode password
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get privateModeResetPasswordAction;

  /// TRANSLATE: Hyperlink button on the unlock dialog that opens the recovery flow
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get privateModeForgotPassword;

  /// TRANSLATE: Title of the recovery dialog offering backup code or security question recovery
  ///
  /// In en, this message translates to:
  /// **'Recover Private Mode'**
  String get privateModeRecoveryTitle;

  /// TRANSLATE: Tab/toggle label for recovering via backup code
  ///
  /// In en, this message translates to:
  /// **'Backup code'**
  String get privateModeRecoveryTabBackupCode;

  /// TRANSLATE: Tab/toggle label for recovering via security question
  ///
  /// In en, this message translates to:
  /// **'Security question'**
  String get privateModeRecoveryTabSecurityQuestion;

  /// TRANSLATE: Placeholder text for the backup code input field during recovery
  ///
  /// In en, this message translates to:
  /// **'XXXX-XXXX-XXXX-XXXX'**
  String get privateModeBackupCodePlaceholder;

  /// TRANSLATE: Placeholder text for the security answer input field during recovery
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get privateModeSecurityAnswerPlaceholder;

  /// TRANSLATE: Error message shown when the backup code or security answer entered during recovery is incorrect
  ///
  /// In en, this message translates to:
  /// **'That didn\'t match. Please try again.'**
  String get privateModeRecoveryIncorrect;

  /// TRANSLATE: Title shown after a successful recovery, before prompting to set a new password
  ///
  /// In en, this message translates to:
  /// **'Identity verified'**
  String get privateModeRecoverySuccessTitle;

  /// TRANSLATE: Description shown after a successful recovery, explaining next steps
  ///
  /// In en, this message translates to:
  /// **'Your old password has been cleared. Set a new password to continue — you\'ll also get a new backup code and security question.'**
  String get privateModeRecoverySuccessDescription;

  /// TRANSLATE: Title of the recovery setup dialog shown after setting/changing a password
  ///
  /// In en, this message translates to:
  /// **'Set Up Recovery'**
  String get privateModeSetupRecoveryTitle;

  /// TRANSLATE: Title of the step showing the newly generated backup code
  ///
  /// In en, this message translates to:
  /// **'Your backup code'**
  String get privateModeBackupCodeGeneratedTitle;

  /// TRANSLATE: Warning text explaining the backup code is shown only once
  ///
  /// In en, this message translates to:
  /// **'Save this code somewhere safe. It will only be shown once, and you\'ll need it if you forget your password.'**
  String get privateModeBackupCodeWarning;

  /// TRANSLATE: Button label to copy the backup code to the clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get privateModeCopyBackupCode;

  /// TRANSLATE: Confirmation message shown after copying the backup code to the clipboard
  ///
  /// In en, this message translates to:
  /// **'Backup code copied'**
  String get privateModeBackupCodeCopied;

  /// TRANSLATE: Button label to download the backup code as a text file
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get privateModeDownloadBackupCode;

  /// TRANSLATE: Label above the security question picker in the recovery setup dialog
  ///
  /// In en, this message translates to:
  /// **'Security question'**
  String get privateModeSecurityQuestionLabel;

  /// TRANSLATE: Label above the security answer input in the recovery setup dialog
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get privateModeSecurityAnswerLabel;

  /// TRANSLATE: Option in the security question picker letting the user write a custom question
  ///
  /// In en, this message translates to:
  /// **'Write my own question…'**
  String get privateModeSecurityQuestionCustomOption;

  /// TRANSLATE: Placeholder/prompt text for the security question picker
  ///
  /// In en, this message translates to:
  /// **'Choose a security question'**
  String get privateModeChooseSecurityQuestion;

  /// TRANSLATE: Validation error when submitting an empty security answer during recovery setup
  ///
  /// In en, this message translates to:
  /// **'Answer cannot be empty'**
  String get privateModeSecurityAnswerEmpty;

  /// TRANSLATE: Confirmation checkbox label required before the backup-code setup dialog can be dismissed
  ///
  /// In en, this message translates to:
  /// **'I\'ve saved this backup code'**
  String get privateModeIveSavedThis;

  /// TRANSLATE: Setting row title for viewing/regenerating recovery options (backup code + security question)
  ///
  /// In en, this message translates to:
  /// **'Recovery Options'**
  String get privateModeRecoveryOptionsTitle;

  /// TRANSLATE: Description under the Recovery Options setting row
  ///
  /// In en, this message translates to:
  /// **'Regenerate your backup code and security question without changing your password.'**
  String get privateModeRecoveryOptionsDescription;

  /// TRANSLATE: Button label to regenerate recovery options (backup code + security question)
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get privateModeRegenerateRecoveryAction;

  /// TRANSLATE: Preset security question option
  ///
  /// In en, this message translates to:
  /// **'What was the name of your first pet?'**
  String get privateModeQuestionPetName;

  /// TRANSLATE: Preset security question option
  ///
  /// In en, this message translates to:
  /// **'In what city were you born?'**
  String get privateModeQuestionBirthCity;

  /// TRANSLATE: Preset security question option
  ///
  /// In en, this message translates to:
  /// **'What was the name of your first school?'**
  String get privateModeQuestionFirstSchool;

  /// TRANSLATE: Preset security question option
  ///
  /// In en, this message translates to:
  /// **'What is your mother\'s maiden name?'**
  String get privateModeQuestionMotherMaidenName;

  /// TRANSLATE: Preset security question option
  ///
  /// In en, this message translates to:
  /// **'What is your favorite book?'**
  String get privateModeQuestionFavoriteBook;

  /// TRANSLATE: Shown on the Private section when Private Mode hasn't been set up yet
  ///
  /// In en, this message translates to:
  /// **'Set up Private Mode in Settings to keep sensitive apps and websites out of your everyday view.'**
  String get privateModeNotSetUpDescription;

  /// TRANSLATE: Button that navigates to Settings to set up Private Mode
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get privateModeGoToSettingsAction;

  /// TRANSLATE: Shown on the Private section's lock screen
  ///
  /// In en, this message translates to:
  /// **'Unlock to view your private apps and websites.'**
  String get privateModeLockedDescription;

  /// TRANSLATE: Subtitle shown above the private apps/websites list once unlocked
  ///
  /// In en, this message translates to:
  /// **'Apps and websites you\'ve marked private.'**
  String get privateModeUnlockedDescription;

  /// TRANSLATE: Empty state shown when unlocked but no private-tagged items have any usage today
  ///
  /// In en, this message translates to:
  /// **'No private apps or websites tracked yet. Mark an item as private from its details to see it here.'**
  String get privateModeNoItemsDescription;

  /// TRANSLATE: Stat tile label for the count of private apps/websites
  ///
  /// In en, this message translates to:
  /// **'Private Items'**
  String get privateModeItemsCount;

  /// No description provided for @permissionBannerNotificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get permissionBannerNotificationsDisabled;

  /// No description provided for @permissionBannerSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications in System Settings to receive focus session alerts.'**
  String get permissionBannerSystemDesc;

  /// No description provided for @permissionBannerOpenSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Open System Settings'**
  String get permissionBannerOpenSystemSettings;

  /// No description provided for @permissionBannerAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications in app settings to receive focus session alerts.'**
  String get permissionBannerAppDesc;

  /// No description provided for @permissionBannerFocusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Focus notifications disabled'**
  String get permissionBannerFocusDisabled;

  /// No description provided for @permissionBannerFocusDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable focus mode notifications in settings to receive session alerts.'**
  String get permissionBannerFocusDesc;

  /// No description provided for @topWebsites.
  ///
  /// In en, this message translates to:
  /// **'Top Websites'**
  String get topWebsites;

  /// No description provided for @noWebsitesTrackedYet.
  ///
  /// In en, this message translates to:
  /// **'No websites tracked yet'**
  String get noWebsitesTrackedYet;

  /// No description provided for @browserDetailBlockedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached – site is blocked'**
  String get browserDetailBlockedTooltip;

  /// No description provided for @browserDetailTimeToday.
  ///
  /// In en, this message translates to:
  /// **'Time today'**
  String get browserDetailTimeToday;

  /// No description provided for @browserDetailVisitsToday.
  ///
  /// In en, this message translates to:
  /// **'Visits today'**
  String get browserDetailVisitsToday;

  /// No description provided for @browserDetailDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily limit'**
  String get browserDetailDailyLimit;

  /// No description provided for @browserChartLegendTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get browserChartLegendTime;

  /// No description provided for @browserChartLegendVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get browserChartLegendVisits;

  /// No description provided for @blockingBehaviorTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocking Behavior'**
  String get blockingBehaviorTitle;

  /// No description provided for @blockingBehaviorNotificationOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification only'**
  String get blockingBehaviorNotificationOnlyTitle;

  /// No description provided for @blockingBehaviorNotificationOnlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Alert you when a limit is reached, no other action.'**
  String get blockingBehaviorNotificationOnlySubtitle;

  /// No description provided for @blockingBehaviorSoftBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Soft block'**
  String get blockingBehaviorSoftBlockTitle;

  /// No description provided for @blockingBehaviorSoftBlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bring Scolect to the front with options to minimize, quit, snooze, or unblock the app.'**
  String get blockingBehaviorSoftBlockSubtitle;

  /// No description provided for @blockingBehaviorHardBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Hard block'**
  String get blockingBehaviorHardBlockTitle;

  /// No description provided for @blockingBehaviorHardBlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Same as soft block, and also immediately hides the app from your screen.'**
  String get blockingBehaviorHardBlockSubtitle;

  /// No description provided for @blockingBehaviorNudgeNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Blocking is a nudge, not a lock. You can still reopen the app from the Dock or taskbar.'**
  String get blockingBehaviorNudgeNote;

  /// No description provided for @aboutUpdateChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get aboutUpdateChecking;

  /// No description provided for @aboutUpdateCheckButton.
  ///
  /// In en, this message translates to:
  /// **'Check Updates'**
  String get aboutUpdateCheckButton;

  /// No description provided for @aboutUpdateCheckingProgress.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get aboutUpdateCheckingProgress;

  /// No description provided for @aboutUpdateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You\'re up to date'**
  String get aboutUpdateUpToDate;

  /// No description provided for @aboutUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check for updates'**
  String get aboutUpdateFailed;

  /// No description provided for @aboutUpdateRetryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Check Updates\" to retry'**
  String get aboutUpdateRetryPrompt;

  /// No description provided for @aboutUpdateScheduled.
  ///
  /// In en, this message translates to:
  /// **'Update check scheduled'**
  String get aboutUpdateScheduled;

  /// No description provided for @aboutOpenSettingsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open System Settings'**
  String get aboutOpenSettingsFailed;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Scolect'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Take control of your time. Scolect runs silently in the background — tracking every app, every session, every minute.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingEveryAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Every App, Automatically'**
  String get onboardingEveryAppTitle;

  /// No description provided for @onboardingEveryAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Scolect watches the foreground app and quietly logs how long you spend in each one — no timers to start, nothing to remember.'**
  String get onboardingEveryAppDesc;

  /// No description provided for @onboardingSeeTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'See Where Your Time Goes'**
  String get onboardingSeeTimeTitle;

  /// No description provided for @onboardingSeeTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Beautiful daily and weekly reports show your most-used apps, total screen time, and usage trends at a glance.'**
  String get onboardingSeeTimeDesc;

  /// No description provided for @onboardingSmartLimitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Limits & Alerts'**
  String get onboardingSmartLimitsTitle;

  /// No description provided for @onboardingSmartLimitsDesc.
  ///
  /// In en, this message translates to:
  /// **'Set daily time limits per app or for your total screen time. Get notified before you hit your limits — not after.'**
  String get onboardingSmartLimitsDesc;

  /// No description provided for @onboardingDeepFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Focus Mode'**
  String get onboardingDeepFocusTitle;

  /// No description provided for @onboardingDeepFocusDesc.
  ///
  /// In en, this message translates to:
  /// **'Block distracting apps during Pomodoro sessions. Custom work and break intervals with optional ambient sounds keep you in the zone.'**
  String get onboardingDeepFocusDesc;

  /// No description provided for @onboardingTrackBrowserTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Browser Time Too'**
  String get onboardingTrackBrowserTitle;

  /// No description provided for @onboardingTrackBrowserDesc.
  ///
  /// In en, this message translates to:
  /// **'Install the free browser extension to capture time spent on websites — not just native apps. Full picture, one dashboard.'**
  String get onboardingTrackBrowserDesc;

  /// No description provided for @onboardingAllSetTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re All Set'**
  String get onboardingAllSetTitle;

  /// No description provided for @onboardingAllSetDesc.
  ///
  /// In en, this message translates to:
  /// **'Scolect is ready to track. Your data stays entirely on-device — completely private, never uploaded anywhere.'**
  String get onboardingAllSetDesc;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGoToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get onboardingGoToDashboard;

  /// No description provided for @onboardingWorksInBrowserTitle.
  ///
  /// In en, this message translates to:
  /// **'Works Right in Your Browser'**
  String get onboardingWorksInBrowserTitle;

  /// No description provided for @onboardingWorksInBrowserDesc.
  ///
  /// In en, this message translates to:
  /// **'Track web activity automatically as you browse. No desktop app required to get started.'**
  String get onboardingWorksInBrowserDesc;

  /// No description provided for @onboardingUsageRightHereTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Usage, Right Here'**
  String get onboardingUsageRightHereTitle;

  /// No description provided for @onboardingUsageRightHereDesc.
  ///
  /// In en, this message translates to:
  /// **'View detailed daily and weekly reports of your time spent on every website in clean, intuitive charts.'**
  String get onboardingUsageRightHereDesc;

  /// No description provided for @onboardingSyncWithDesktopTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync with the Desktop App'**
  String get onboardingSyncWithDesktopTitle;

  /// No description provided for @onboardingSyncWithDesktopDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect seamlessly with the Scolect desktop app for combined native app and website analytics.'**
  String get onboardingSyncWithDesktopDesc;

  /// No description provided for @onboarding100PrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'100% Private'**
  String get onboarding100PrivateTitle;

  /// No description provided for @onboarding100PrivateDesc.
  ///
  /// In en, this message translates to:
  /// **'All tracking data is stored locally in your browser and on your machine. Nothing is ever sent to the cloud.'**
  String get onboarding100PrivateDesc;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return lookupAppLocalizations(locale);
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'bn',
        'en',
        'es',
        'fr',
        'hi',
        'id',
        'ja',
        'pt',
        'ru',
        'ur',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

Future<AppLocalizations> lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return app_localizations_ar
          .loadLibrary()
          .then((dynamic _) => app_localizations_ar.AppLocalizationsAr());
    case 'bn':
      return app_localizations_bn
          .loadLibrary()
          .then((dynamic _) => app_localizations_bn.AppLocalizationsBn());
    case 'en':
      return app_localizations_en
          .loadLibrary()
          .then((dynamic _) => app_localizations_en.AppLocalizationsEn());
    case 'es':
      return app_localizations_es
          .loadLibrary()
          .then((dynamic _) => app_localizations_es.AppLocalizationsEs());
    case 'fr':
      return app_localizations_fr
          .loadLibrary()
          .then((dynamic _) => app_localizations_fr.AppLocalizationsFr());
    case 'hi':
      return app_localizations_hi
          .loadLibrary()
          .then((dynamic _) => app_localizations_hi.AppLocalizationsHi());
    case 'id':
      return app_localizations_id
          .loadLibrary()
          .then((dynamic _) => app_localizations_id.AppLocalizationsId());
    case 'ja':
      return app_localizations_ja
          .loadLibrary()
          .then((dynamic _) => app_localizations_ja.AppLocalizationsJa());
    case 'pt':
      return app_localizations_pt
          .loadLibrary()
          .then((dynamic _) => app_localizations_pt.AppLocalizationsPt());
    case 'ru':
      return app_localizations_ru
          .loadLibrary()
          .then((dynamic _) => app_localizations_ru.AppLocalizationsRu());
    case 'ur':
      return app_localizations_ur
          .loadLibrary()
          .then((dynamic _) => app_localizations_ur.AppLocalizationsUr());
    case 'zh':
      return app_localizations_zh
          .loadLibrary()
          .then((dynamic _) => app_localizations_zh.AppLocalizationsZh());
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
