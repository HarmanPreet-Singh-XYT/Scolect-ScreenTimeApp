// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appWindowTitle => 'Scolect - Track Screen Time & App Usage';

  @override
  String get appName => 'Scolect';

  @override
  String get appTitle => 'Productive ScreenTime';

  @override
  String get sidebarTitle => 'ScreenTime';

  @override
  String get sidebarSubtitle => 'Open Source';

  @override
  String get trayShowWindow => 'Show Window';

  @override
  String get trayStartFocusMode => 'Start Focus Mode';

  @override
  String get trayStopFocusMode => 'Stop Focus Mode';

  @override
  String get trayReports => 'Reports';

  @override
  String get trayAlertsLimits => 'Alerts & Limits';

  @override
  String get trayApplications => 'Applications';

  @override
  String get trayDisableNotifications => 'Disable Notifications';

  @override
  String get trayEnableNotifications => 'Enable Notifications';

  @override
  String get trayVersionPrefix => 'Version: ';

  @override
  String trayVersion(String version) {
    return 'Version: $version';
  }

  @override
  String get trayExit => 'Exit';

  @override
  String get navOverview => 'Overview';

  @override
  String get navApplications => 'Applications';

  @override
  String get navAlertsLimits => 'Alerts & Limits';

  @override
  String get navReports => 'Reports';

  @override
  String get navFocusMode => 'Focus Mode';

  @override
  String get navBrowser => 'Browser';

  @override
  String get navSettings => 'Settings';

  @override
  String get navHelp => 'Help';

  @override
  String get navPrivate => 'Private';

  @override
  String get helpTitle => 'Help';

  @override
  String get faqCategoryGeneral => 'General Questions';

  @override
  String get faqCategoryApplications => 'Applications Management';

  @override
  String get faqCategoryReports => 'Usage Analytics & Reports';

  @override
  String get faqCategoryAlerts => 'Alerts & Limits';

  @override
  String get faqCategoryFocusMode => 'Focus Mode & Pomodoro Timer';

  @override
  String get faqCategorySettings => 'Settings & Customization';

  @override
  String get faqCategoryBrowser => 'Browser Extension';

  @override
  String get faqCategoryTroubleshooting => 'Troubleshooting';

  @override
  String get faqGeneralQ1 => 'How does Scolect track screen time?';

  @override
  String get faqGeneralA1 =>
      'Scolect has two tracking surfaces. The desktop app monitors which native application is in the foreground on macOS or Windows and measures how long you spend in it. The browser extension tracks time spent on each website domain you visit in Chrome. Both surfaces store data locally on your device — nothing is sent to any server.';

  @override
  String get faqGeneralQ2 => 'What makes an app or website \'Productive\'?';

  @override
  String get faqGeneralA2 =>
      'You decide. In the Applications section you can toggle any app as productive. Productive apps count toward your Productive Time metric in Reports, which shows you the share of your screen time spent on work-related or beneficial apps.';

  @override
  String get faqGeneralQ3 => 'How accurate is the tracking?';

  @override
  String get faqGeneralA3 =>
      'The desktop app uses OS-level foreground window detection, so it only counts time while an app is the active window — idle time or locked screens are not counted. The browser extension starts a timer when you switch to a tab and pauses it when you switch away or close the tab, so visit time reflects actual attention, not just open tabs.';

  @override
  String get faqGeneralQ4 => 'Can I customize how apps are categorized?';

  @override
  String get faqGeneralA4 =>
      'Yes. In the Applications section you can create custom categories, rename existing ones, and reassign any app to a different category. Categories flow through to your reports and charts, so organizing apps into meaningful groups makes analytics more useful.';

  @override
  String get faqGeneralQ5 => 'What insights does Scolect give me?';

  @override
  String get faqGeneralA5 =>
      'You get: total and productive screen time, most-used apps and websites, daily and weekly usage graphs, time-of-day usage patterns (morning / afternoon / evening / night), focus session history, and per-app breakdown with trends. Reports also support Excel export for offline analysis.';

  @override
  String get faqGeneralQ6 =>
      'Which languages are supported and how do I change language?';

  @override
  String get faqGeneralA6 =>
      'Language can be changed in Settings under the General section — all available languages are listed there. Translations are AI-generated from English, so some may be imperfect. If you spot an error you can report it via the Report Bug button in Settings, or open an issue on GitHub. Translation contributions are welcome!';

  @override
  String get faqAppsQ1 => 'How do I stop tracking a specific app?';

  @override
  String get faqAppsA1 =>
      'Open the Applications section, find the app, and click the edit (pencil) icon. You can toggle \'Track Usage\' off — the app will no longer accumulate screen time. You can also toggle \'Visible in Reports\' to hide it from charts without stopping tracking.';

  @override
  String get faqAppsQ2 => 'Can I search and filter my applications?';

  @override
  String get faqAppsA2 =>
      'Yes. The Applications section has a search bar and filter options. You can filter by category, productivity status, tracking status, and visibility to quickly find what you are looking for.';

  @override
  String get faqAppsQ3 => 'What can I edit per application?';

  @override
  String get faqAppsA3 =>
      'For each application you can set: category, productive or non-productive status, whether tracking is active, whether it appears in reports, and an individual daily time limit. Limits trigger a notification when the app hits the threshold.';

  @override
  String get faqAppsQ4 => 'How are initial categories assigned?';

  @override
  String get faqAppsA4 =>
      'Scolect makes a best-guess category based on the app name when it is first seen. You have full control to change this — create new categories, rename them, and reassign apps at any time.';

  @override
  String get faqAppsQ5 => 'Why is an app showing a very short or zero time?';

  @override
  String get faqAppsA5 =>
      'Tracking starts from the moment the app is first detected in the foreground. If you just installed Scolect, historical usage is not available — only time going forward is recorded. Very short times usually mean you briefly switched to that app and away again.';

  @override
  String get faqReportsQ1 => 'What types of reports are available?';

  @override
  String get faqReportsA1 =>
      'Reports include: summary cards (total screen time, productive time, most used app, focus sessions), a daily usage bar chart, weekly usage trends with comparisons, detailed per-app usage table, and a time-of-day usage pattern breakdown. You can also export all data to an Excel file.';

  @override
  String get faqReportsQ2 => 'How do I export my data?';

  @override
  String get faqReportsA2 =>
      'In the Reports section, look for the Export button in the top-right area. This generates an Excel (.xlsx) file with your usage data. The file is saved to your Downloads folder. The browser extension dashboard also has an export option for website usage.';

  @override
  String get faqReportsQ3 =>
      'Can I compare usage across different time periods?';

  @override
  String get faqReportsA3 =>
      'Yes. The Reports section lets you switch between Last 7 Days, Last 30 Days, and custom date ranges. The weekly trend graph shows week-over-week changes, and the summary cards display a percentage change compared to the previous period.';

  @override
  String get faqReportsQ4 => 'What is the \'Usage Pattern\' analysis?';

  @override
  String get faqReportsA4 =>
      'Usage Pattern splits your screen time into four day segments: morning (6 AM–12 PM), afternoon (12 PM–6 PM), evening (6 PM–10 PM), and night (10 PM–6 AM). This helps you see when you are most active on your device.';

  @override
  String get faqAlertsQ1 => 'How do screen time limits work?';

  @override
  String get faqAlertsA1 =>
      'You can set a daily overall screen time limit and individual limits per app. When you hit a limit, Scolect sends a desktop notification. Optionally, apps can be blocked when their limit is reached — the app will be prevented from taking focus. Limits reset each day at midnight.';

  @override
  String get faqAlertsQ2 =>
      'What happens when an app is blocked after hitting its limit?';

  @override
  String get faqAlertsA2 =>
      'When blocking is enabled and an app reaches its daily limit, Scolect will attempt to bring focus away from it and notify you. On macOS this redirects you back to the previous app. You can always go to Alerts & Limits and temporarily disable blocking or raise the limit if needed.';

  @override
  String get faqAlertsQ3 => 'What notification options are available?';

  @override
  String get faqAlertsA3 =>
      'You can enable or disable notifications for: screen time limit reached, individual app limits, focus session start/end, and frequent reminder alerts. Reminder alerts fire at a configurable interval (1, 5, 15, 30, or 60 minutes) to keep you aware of ongoing usage.';

  @override
  String get faqAlertsQ4 => 'Can I set different limits for different apps?';

  @override
  String get faqAlertsA4 =>
      'Yes. In the Applications section, open any app\'s edit panel and set a per-app daily limit. You can also set limits directly from the Alerts & Limits section. Each app has its own independent limit and reset cycle.';

  @override
  String get faqFocusQ1 => 'What Focus Modes are available?';

  @override
  String get faqFocusA1 =>
      'Three preset modes are available: Deep Work (longer focused sessions for complex tasks), Quick Tasks (shorter bursts for lightweight work), and Reading Mode (relaxed timing for reading or research). Each mode pre-fills the Pomodoro timer with sensible defaults, and you can customize all durations manually.';

  @override
  String get faqFocusQ2 => 'How do I customize the Pomodoro timer?';

  @override
  String get faqFocusA2 =>
      'In the Focus Mode section, open the settings icon on the timer card. You can set work duration, short break length, long break duration, the number of sessions before a long break, and whether the next session auto-starts. Changes apply immediately to the current timer.';

  @override
  String get faqFocusQ3 => 'What does the Focus Mode history show?';

  @override
  String get faqFocusA3 =>
      'The history tab shows daily session counts, a trend graph over the past weeks, average session duration, total accumulated focus time, and a breakdown of how your time was split between work, short breaks, and long breaks.';

  @override
  String get faqFocusQ4 => 'Does Focus Mode block distracting apps?';

  @override
  String get faqFocusA4 =>
      'Not automatically by default, but you can combine Focus Mode with app limits. Set a very short limit on distracting apps and enable blocking — they will be prevented from taking focus while your session is running. A future update may add direct integration between Focus Mode and app blocking.';

  @override
  String get faqSettingsQ1 => 'What can I customize in Settings?';

  @override
  String get faqSettingsA1 =>
      'Settings covers: appearance (theme — system, light, or dark; accent color), language, startup behavior (launch on login, start minimized), notification toggles, idle detection timeout, browser extension server port, and data management (clear data, backup and restore).';

  @override
  String get faqSettingsQ2 => 'How do I back up or restore my data?';

  @override
  String get faqSettingsA2 =>
      'Go to Settings and find the Backup & Restore section. Tap Export to save a backup file to your Documents folder inside a Scolect-Backups subfolder. To restore, tap Import and select that same file. Only files exported by Scolect can be restored — no other format is supported.';

  @override
  String get faqSettingsQ3 => 'What does \'Clear Data\' delete?';

  @override
  String get faqSettingsA3 =>
      'Clear Data removes all recorded usage statistics and focus session history. Your settings and preferences (theme, language, limits, categories) are not affected. This is useful for starting fresh or if you are troubleshooting a data issue.';

  @override
  String get faqSettingsQ4 => 'How do I report a bug or send feedback?';

  @override
  String get faqSettingsA4 =>
      'Scroll to the bottom of the Settings section — you will find buttons to Report a Bug, Submit Feedback, and Contact Support. These open the relevant links in your browser. You can also open an issue directly on the Scolect GitHub repository.';

  @override
  String get faqBrowserQ1 => 'What does the browser extension track?';

  @override
  String get faqBrowserA1 =>
      'The extension tracks the domain of every website you visit and how long you spend on it, including a visit count per domain per day. All data is stored locally in your browser\'s storage — nothing leaves your device.';

  @override
  String get faqBrowserQ2 =>
      'What are the extension modes (Standalone, Tracker Only, Hybrid)?';

  @override
  String get faqBrowserA2 =>
      'Standalone mode runs the extension independently with its own dashboard and no connection to the desktop app. Tracker Only mode sends your browser usage data to the Scolect desktop app to merge with native app tracking, but the extension dashboard is not used. Hybrid mode does both — the extension has its own dashboard and also syncs data to the desktop app.';

  @override
  String get faqBrowserQ3 =>
      'How does the extension connect to the desktop app?';

  @override
  String get faqBrowserA3 =>
      'The desktop app runs a local HTTP server on port 46000 (configurable in Settings). When the extension is in Tracker Only or Hybrid mode it periodically POSTs your browsing data to that address. Both apps must be running on the same machine. If the desktop app is not open, the extension still tracks locally and will sync the next time a connection is established.';

  @override
  String get faqBrowserQ4 => 'Why is a website being blocked?';

  @override
  String get faqBrowserA4 =>
      'A site is blocked when it has reached its daily time limit and blocking is enabled for that limit. You will see a blocked page with a countdown to midnight when the limit resets. To unblock immediately, go to Alerts & Limits in the desktop app and raise or remove the limit for that site, or disable blocking.';

  @override
  String get faqBrowserQ5 =>
      'Does the extension track in incognito / private mode?';

  @override
  String get faqBrowserA5 =>
      'No. By default Chrome extensions do not have access to incognito tabs. If you explicitly grant the extension access to incognito in Chrome\'s extension settings, it will track those tabs too — but this is off by default to respect your privacy.';

  @override
  String get faqBrowserQ6 => 'Where can I see my website usage data?';

  @override
  String get faqBrowserA6 =>
      'Open the extension dashboard by clicking the Scolect icon in your browser toolbar and selecting \'Open Dashboard\', or by navigating to the extension\'s index page. The Websites tab shows all tracked domains with time spent, visit counts, and a 7-day history chart for each site. You can also export this data to Excel.';

  @override
  String get faqTroubleQ1 => 'No data is showing in the desktop app';

  @override
  String get faqTroubleA1 =>
      'First try closing and reopening the app. If data still does not appear, go to Settings and use Clear Data to reset the database, then restart. If you see a \'hive not opening\' error, navigate to your Documents folder and delete harman_screentime_app_usage_box.hive and harman_screentime_app_usage_box.lock if they exist, then relaunch. Updating to the latest version also resolves most database issues.';

  @override
  String get faqTroubleQ2 => 'The app opens automatically on every startup';

  @override
  String get faqTroubleA2 =>
      'This is a known issue on Windows 10. As a workaround, enable \'Launch as Minimized\' in Settings so the app starts in the background without an intrusive window. On macOS you can control this from the Login Items section in System Settings.';

  @override
  String get faqTroubleQ3 =>
      'The browser extension is not showing any website data';

  @override
  String get faqTroubleA3 =>
      'Make sure you have visited at least one website since installing the extension — there is no historical data before installation. Check that the extension has the required permissions (it needs access to all URLs to track time). If the dashboard is open but empty, try closing and reopening the dashboard tab. If the issue persists, try removing and reinstalling the extension.';

  @override
  String get faqTroubleQ4 => 'Extension and desktop app are not syncing';

  @override
  String get faqTroubleA4 =>
      'Ensure the desktop app is running and that the extension mode is set to Tracker Only or Hybrid (not Standalone). Check the port number in both places — the desktop app\'s Settings and the extension\'s Settings should both show the same port (default 46000). Firewall or antivirus software can block local connections; try temporarily disabling them to test. The extension will show a connection indicator when sync is active.';

  @override
  String get usageAnalytics => 'Usage Analytics';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get last3Months => 'Last 3 Months';

  @override
  String get lifetime => 'Lifetime';

  @override
  String get custom => 'Custom';

  @override
  String get loadingAnalyticsData => 'Loading analytics data...';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get failedToInitialize =>
      'Failed to initialize analytics. Please restart the application.';

  @override
  String unexpectedError(String error) {
    return 'An unexpected error occurred: $error. Please try again later.';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return 'Error loading analytics data: $error. Please check your connection and try again.';
  }

  @override
  String get customDialogTitle => 'Custom';

  @override
  String get dateRange => 'Date Range:';

  @override
  String get specificDate => 'Specific Date';

  @override
  String get startDate => 'Start Date: ';

  @override
  String get endDate => 'End Date: ';

  @override
  String get date => 'Date';

  @override
  String get cancel => 'Cancel';

  @override
  String get apply => 'Apply';

  @override
  String get ok => 'OK';

  @override
  String get invalidDateRange => 'Invalid Date Range';

  @override
  String get startDateBeforeEndDate =>
      'Start date must be before or equal to end date.';

  @override
  String get totalScreenTime => 'Total Screen Time';

  @override
  String get productiveTime => 'Productive Time';

  @override
  String get mostUsedApp => 'Most Used App';

  @override
  String get focusSessions => 'Focus Sessions';

  @override
  String positiveComparison(String percent) {
    return '+$percent% vs previous period';
  }

  @override
  String negativeComparison(String percent) {
    return '$percent% vs previous period';
  }

  @override
  String iconLabel(String title) {
    return '$title icon';
  }

  @override
  String get dailyScreenTime => 'DAILY SCREEN TIME';

  @override
  String get categoryBreakdown => 'CATEGORY BREAKDOWN';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String sectionLabel(String title) {
    return '$title section';
  }

  @override
  String get detailedApplicationUsage => 'Detailed Application Usage';

  @override
  String get searchApplications => 'Search applications';

  @override
  String get nameHeader => 'Name';

  @override
  String get categoryHeader => 'Category';

  @override
  String get totalTimeHeader => 'Total Time';

  @override
  String get productivityHeader => 'Productivity';

  @override
  String get actionsHeader => 'Actions';

  @override
  String sortByOption(String option) {
    return 'Sort by: $option';
  }

  @override
  String get sortByName => 'Name';

  @override
  String get sortByCategory => 'Category';

  @override
  String get sortByUsage => 'Usage';

  @override
  String get productive => 'Productive';

  @override
  String get nonProductive => 'Non-Productive';

  @override
  String get noApplicationsMatch =>
      'No applications match your search criteria';

  @override
  String get viewDetails => 'View details';

  @override
  String get usageSummary => 'Usage Summary';

  @override
  String get usageOverPastWeek => 'Usage Over Past Week';

  @override
  String get usagePatternByTimeOfDay => 'Usage Pattern by Time of Day';

  @override
  String get patternAnalysis => 'Pattern Analysis';

  @override
  String get today => 'Today';

  @override
  String get dailyLimit => 'Daily Limit';

  @override
  String get noLimit => 'No limit';

  @override
  String get usageTrend => 'Usage Trend';

  @override
  String get productivity => 'Productivity';

  @override
  String get increasing => 'Increasing';

  @override
  String get decreasing => 'Decreasing';

  @override
  String get stable => 'Stable';

  @override
  String get avgDailyUsage => 'Avg. Daily Usage';

  @override
  String get longestSession => 'Longest session';

  @override
  String get weeklyTotal => 'Weekly Total';

  @override
  String get noHistoricalData => 'No historical data available';

  @override
  String get morning => 'Morning (6-12)';

  @override
  String get afternoon => 'Afternoon (12-5)';

  @override
  String get evening => 'Evening (5-9)';

  @override
  String get night => 'Night (9-6)';

  @override
  String get usageInsights => 'Usage Insights';

  @override
  String get limitStatus => 'Limit Status';

  @override
  String get close => 'Close';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return 'You primarily use $appName during $timeOfDay.';
  }

  @override
  String significantIncrease(String percentage) {
    return 'Your usage has increased significantly ($percentage%) compared to the previous period.';
  }

  @override
  String get trendingUpward =>
      'Your usage is trending upward compared to the previous period.';

  @override
  String significantDecrease(String percentage) {
    return 'Your usage has decreased significantly ($percentage%) compared to the previous period.';
  }

  @override
  String get trendingDownward =>
      'Your usage is trending downward compared to the previous period.';

  @override
  String get consistentUsage =>
      'Your usage has been consistent compared to the previous period.';

  @override
  String get markedAsProductive =>
      'This is marked as a productive app in your settings.';

  @override
  String get markedAsNonProductive =>
      'This is marked as a non-productive app in your settings.';

  @override
  String mostActiveTime(String time) {
    return 'Your most active time is around $time.';
  }

  @override
  String get noLimitSet => 'No usage limit has been set for this application.';

  @override
  String get limitReached =>
      'You\'ve reached your daily limit for this application.';

  @override
  String aboutToReachLimit(String remainingTime) {
    return 'You\'re about to reach your daily limit with only $remainingTime remaining.';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return 'You\'ve used $percent% of your daily limit with $remainingTime remaining.';
  }

  @override
  String remainingTime(String time) {
    return 'You have $time remaining out of your daily limit.';
  }

  @override
  String get todayChart => 'Today';

  @override
  String hourPeriodAM(int hour) {
    return '$hour AM';
  }

  @override
  String hourPeriodPM(int hour) {
    return '$hour PM';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '${minutes}m';
  }

  @override
  String get alertsLimitsTitle => 'Alerts & Limits';

  @override
  String get notificationsSettings => 'Notifications Settings';

  @override
  String get overallScreenTimeLimit => 'Overall Screen Time Limit';

  @override
  String get applicationLimits => 'Application Limits';

  @override
  String get popupAlerts => 'Pop-up Alerts';

  @override
  String get frequentAlerts => 'Frequent Alerts';

  @override
  String get soundAlerts => 'Sound Alerts';

  @override
  String get systemAlerts => 'System Alerts';

  @override
  String get dailyTotalLimit => 'Daily Total Limit: ';

  @override
  String get hours => 'Hours';

  @override
  String get minutes => 'Minutes';

  @override
  String get currentUsage => 'Current Usage: ';

  @override
  String get tableName => 'Name';

  @override
  String get tableCategory => 'Category';

  @override
  String get tableDailyLimit => 'Daily Limit';

  @override
  String get tableCurrentUsage => 'Current Usage';

  @override
  String get tableStatus => 'Status';

  @override
  String get tableActions => 'Actions';

  @override
  String get addLimit => 'Add Limit';

  @override
  String get noApplicationsToDisplay => 'No applications to display';

  @override
  String get statusActive => 'Active';

  @override
  String get statusOff => 'Off';

  @override
  String get durationNone => 'None';

  @override
  String get addApplicationLimit => 'Add Application Limit';

  @override
  String get selectApplication => 'Select Application';

  @override
  String get selectApplicationPlaceholder => 'Select an application';

  @override
  String get enableLimit => 'Enable Limit: ';

  @override
  String editLimitTitle(String appName) {
    return 'Edit Limit: $appName';
  }

  @override
  String failedToLoadData(String error) {
    return 'Failed to load data: $error';
  }

  @override
  String get resetSettingsTitle => 'Reset Settings?';

  @override
  String get resetSettingsContent =>
      'If you reset settings, you won\'t be able to recover it. Do you want to reset it?';

  @override
  String get resetAll => 'Reset All';

  @override
  String get refresh => 'Refresh';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get applicationsTitle => 'Applications';

  @override
  String get searchApplication => 'Search Application';

  @override
  String get tracking => 'Tracked';

  @override
  String get hiddenVisible => 'Hidden/Visible';

  @override
  String get selectCategory => 'Select a Category';

  @override
  String get allCategories => 'All';

  @override
  String get tableScreenTime => 'Screen Time';

  @override
  String get tableTracking => 'Tracking';

  @override
  String get tableHidden => 'Hidden';

  @override
  String get tableEdit => 'Edit';

  @override
  String editAppTitle(String appName) {
    return 'Edit $appName';
  }

  @override
  String get categorySection => 'Category';

  @override
  String get customCategory => 'Custom';

  @override
  String get customCategoryPlaceholder => 'Enter custom category name';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get isProductive => 'Is Productive';

  @override
  String get trackUsage => 'Track Usage';

  @override
  String get visibleInReports => 'Visible in Reports';

  @override
  String get timeLimitsSection => 'Time Limits';

  @override
  String get enableDailyLimit => 'Enable Daily Limit';

  @override
  String get setDailyTimeLimit => 'Set daily time limit:';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String errorLoadingData(String error) {
    return 'Error loading overview data: $error';
  }

  @override
  String get focusModeTitle => 'Focus Mode';

  @override
  String get historySection => 'History';

  @override
  String get trendsSection => 'Trends';

  @override
  String get timeDistributionSection => 'Time Distribution';

  @override
  String get sessionHistorySection => 'Session History';

  @override
  String get workSession => 'Work Session';

  @override
  String get shortBreak => 'Short Break';

  @override
  String get longBreak => 'Long Break';

  @override
  String get dateHeader => 'Date';

  @override
  String get durationHeader => 'Duration';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get focusModeSettingsTitle => 'Focus Mode Settings';

  @override
  String get modeCustom => 'Custom';

  @override
  String get modeDeepWork => 'Deep Work (60 min)';

  @override
  String get modeQuickTasks => 'Quick Tasks (25 min)';

  @override
  String get modeReading => 'Reading (45 min)';

  @override
  String workDurationLabel(int minutes) {
    return 'Work Duration: $minutes min';
  }

  @override
  String shortBreakLabel(int minutes) {
    return 'Short Break';
  }

  @override
  String longBreakLabel(int minutes) {
    return 'Long Break';
  }

  @override
  String get autoStartNextSession => 'Auto-start next session';

  @override
  String get blockDistractions => 'Block distractions during focus mode';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get saved => 'Saved';

  @override
  String errorLoadingFocusModeData(String error) {
    return 'Error loading focus mode data: $error';
  }

  @override
  String get overviewTitle => 'Today\'s Overview';

  @override
  String get startFocusMode => 'Start Focus Mode';

  @override
  String get loadingProductivityData => 'Loading your productivity data...';

  @override
  String get noActivityDataAvailable => 'No activity data available yet';

  @override
  String get startUsingApplications =>
      'Start using your applications to track screen time and productivity.';

  @override
  String get refreshData => 'Refresh Data';

  @override
  String get topApplications => 'Top Applications';

  @override
  String get noAppUsageDataAvailable =>
      'No application usage data available yet';

  @override
  String get noApplicationDataAvailable => 'No application data available';

  @override
  String get noCategoryDataAvailable => 'No category data available';

  @override
  String get noApplicationLimitsSet => 'No application limits set';

  @override
  String get screenLabel => 'Screen';

  @override
  String get timeLabel => 'Time';

  @override
  String get productiveLabel => 'Productive';

  @override
  String get scoreLabel => 'Score';

  @override
  String get defaultNone => 'None';

  @override
  String get defaultTime => '0h 0m';

  @override
  String get defaultCount => '0';

  @override
  String get unknownApp => 'Unknown';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get generalSection => 'General';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get dataSection => 'Data';

  @override
  String get versionSection => 'Version';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageDescription => 'Language of the application';

  @override
  String get startupBehaviourTitle => 'Startup Behaviour';

  @override
  String get startupBehaviourDescription => 'Launch at OS startup';

  @override
  String get launchMinimizedTitle => 'Launch as Minimized';

  @override
  String get launchMinimizedDescription =>
      'Start the application in System Tray (Recommended for Windows 10)';

  @override
  String get browserExtensionTitle => 'Browser Extension';

  @override
  String get browserExtensionDescription =>
      'Allow the Scolect browser extension to connect and sync website usage data';

  @override
  String get crashReportingTitle => 'Crash Reporting';

  @override
  String get crashReportingDescription =>
      'Send anonymous crash reports to help improve Scolect. No personal data or usage history is included.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsAllDescription =>
      'All notifications of the application';

  @override
  String get focusModeNotificationsTitle => 'Focus Mode';

  @override
  String get focusModeNotificationsDescription =>
      'All Notifications for focus mode';

  @override
  String get screenTimeNotificationsTitle => 'Screen Time';

  @override
  String get screenTimeNotificationsDescription =>
      'All Notifications for screen time restriction';

  @override
  String get appScreenTimeNotificationsTitle => 'Application Screen Time';

  @override
  String get appScreenTimeNotificationsDescription =>
      'All Notifications for application screen time restriction';

  @override
  String get frequentAlertsTitle => 'Frequent Alerts Interval';

  @override
  String get frequentAlertsDescription =>
      'Set interval for frequent notifications (minutes)';

  @override
  String get clearDataTitle => 'Clear Data';

  @override
  String get clearDataDescription =>
      'Clear all the history and other related data';

  @override
  String get resetSettingsTitle2 => 'Reset Settings';

  @override
  String get resetSettingsDescription => 'Reset all the settings';

  @override
  String get versionTitle => 'Version';

  @override
  String get versionDescription => 'Current version of the app';

  @override
  String get contactButton => 'Contact';

  @override
  String get reportBugButton => 'Report Bug';

  @override
  String get submitFeedbackButton => 'Submit Feedback';

  @override
  String get githubButton => 'Github';

  @override
  String get clearDataDialogTitle => 'Clear Data?';

  @override
  String get clearDataDialogContent =>
      'This will clear all history and related data. You won\'t be able to recover it. Do you want to proceed?';

  @override
  String get clearDataButtonLabel => 'Clear Data';

  @override
  String get resetSettingsDialogTitle => 'Reset Settings?';

  @override
  String get resetSettingsDialogContent =>
      'This will reset all settings to their default values. Do you want to proceed?';

  @override
  String get resetButtonLabel => 'Reset';

  @override
  String get cancelButton => 'Cancel';

  @override
  String couldNotLaunchUrl(String url) {
    return 'Could not launch $url';
  }

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get chart_focusTrends => 'Focus Trends';

  @override
  String get chart_sessionCount => 'Session Count';

  @override
  String get chart_avgDuration => 'Avg Duration';

  @override
  String get chart_totalFocus => 'Total Focus';

  @override
  String get chart_yAxis_sessions => 'Sessions';

  @override
  String get chart_yAxis_minutes => 'Minutes';

  @override
  String get chart_yAxis_value => 'Value';

  @override
  String get chart_monthOverMonthChange => 'Month-over-month change: ';

  @override
  String get chart_customRange => 'Custom Range';

  @override
  String get day_monday => 'Monday';

  @override
  String get day_mondayShort => 'Mon';

  @override
  String get day_mondayAbbr => 'Mn';

  @override
  String get day_tuesday => 'Tuesday';

  @override
  String get day_tuesdayShort => 'Tue';

  @override
  String get day_tuesdayAbbr => 'Tu';

  @override
  String get day_wednesday => 'Wednesday';

  @override
  String get day_wednesdayShort => 'Wed';

  @override
  String get day_wednesdayAbbr => 'Wd';

  @override
  String get day_thursday => 'Thursday';

  @override
  String get day_thursdayShort => 'Thu';

  @override
  String get day_thursdayAbbr => 'Th';

  @override
  String get day_friday => 'Friday';

  @override
  String get day_fridayShort => 'Fri';

  @override
  String get day_fridayAbbr => 'Fr';

  @override
  String get day_saturday => 'Saturday';

  @override
  String get day_saturdayShort => 'Sat';

  @override
  String get day_saturdayAbbr => 'St';

  @override
  String get day_sunday => 'Sunday';

  @override
  String get day_sundayShort => 'Sun';

  @override
  String get day_sundayAbbr => 'Sn';

  @override
  String time_hours(int count) {
    return '${count}h';
  }

  @override
  String time_hoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String time_minutesFormat(String count) {
    return '$count min';
  }

  @override
  String tooltip_dateScreenTime(String date, int hours, int minutes) {
    return '$date: ${hours}h ${minutes}m';
  }

  @override
  String tooltip_hoursFormat(String count) {
    return '$count hours';
  }

  @override
  String get month_january => 'January';

  @override
  String get month_januaryShort => 'Jan';

  @override
  String get month_february => 'February';

  @override
  String get month_februaryShort => 'Feb';

  @override
  String get month_march => 'March';

  @override
  String get month_marchShort => 'Mar';

  @override
  String get month_april => 'April';

  @override
  String get month_aprilShort => 'Apr';

  @override
  String get month_may => 'May';

  @override
  String get month_mayShort => 'May';

  @override
  String get month_june => 'June';

  @override
  String get month_juneShort => 'Jun';

  @override
  String get month_july => 'July';

  @override
  String get month_julyShort => 'Jul';

  @override
  String get month_august => 'August';

  @override
  String get month_augustShort => 'Aug';

  @override
  String get month_september => 'September';

  @override
  String get month_septemberShort => 'Sep';

  @override
  String get month_october => 'October';

  @override
  String get month_octoberShort => 'Oct';

  @override
  String get month_november => 'November';

  @override
  String get month_novemberShort => 'Nov';

  @override
  String get month_december => 'December';

  @override
  String get month_decemberShort => 'Dec';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryProductivity => 'Productivity';

  @override
  String get categoryDevelopment => 'Development';

  @override
  String get categorySocialMedia => 'Social Media';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryGaming => 'Gaming';

  @override
  String get categoryCommunication => 'Communication';

  @override
  String get categoryWebBrowsing => 'Web Browsing';

  @override
  String get categoryCreative => 'Creative';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryUtility => 'Utility';

  @override
  String get categoryUncategorized => 'Uncategorized';

  @override
  String get appMicrosoftWord => 'Microsoft Word';

  @override
  String get appExcel => 'Excel';

  @override
  String get appPowerPoint => 'PowerPoint';

  @override
  String get appGoogleDocs => 'Google Docs';

  @override
  String get appNotion => 'Notion';

  @override
  String get appEvernote => 'Evernote';

  @override
  String get appTrello => 'Trello';

  @override
  String get appAsana => 'Asana';

  @override
  String get appSlack => 'Slack';

  @override
  String get appMicrosoftTeams => 'Microsoft Teams';

  @override
  String get appZoom => 'Zoom';

  @override
  String get appGoogleCalendar => 'Google Calendar';

  @override
  String get appAppleCalendar => 'Calendar';

  @override
  String get appVisualStudioCode => 'Visual Studio Code';

  @override
  String get appTerminal => 'Terminal';

  @override
  String get appCommandPrompt => 'Command Prompt';

  @override
  String get appChrome => 'Chrome';

  @override
  String get appFirefox => 'Firefox';

  @override
  String get appSafari => 'Safari';

  @override
  String get appEdge => 'Edge';

  @override
  String get appOpera => 'Opera';

  @override
  String get appBrave => 'Brave';

  @override
  String get appNetflix => 'Netflix';

  @override
  String get appYouTube => 'YouTube';

  @override
  String get appSpotify => 'Spotify';

  @override
  String get appAppleMusic => 'Apple Music';

  @override
  String get appCalculator => 'Calculator';

  @override
  String get appNotes => 'Notes';

  @override
  String get appSystemPreferences => 'System Preferences';

  @override
  String get appTaskManager => 'Task Manager';

  @override
  String get appFileExplorer => 'File Explorer';

  @override
  String get appDropbox => 'Dropbox';

  @override
  String get appGoogleDrive => 'Google Drive';

  @override
  String get loadingApplication => 'Loading application...';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get reportsError => 'Error';

  @override
  String get reportsRetry => 'Retry';

  @override
  String get backupRestoreSection => 'Backup & Restore';

  @override
  String get backupRestoreTitle => 'Backup & Restore';

  @override
  String get exportDataTitle => 'Export Data';

  @override
  String get exportDataDescription => 'Create a backup of all your data';

  @override
  String get importDataTitle => 'Import Data';

  @override
  String get importDataDescription => 'Restore from a backup file';

  @override
  String get exportButton => 'Export';

  @override
  String get importButton => 'Import';

  @override
  String get closeButton => 'Close';

  @override
  String get noButton => 'No';

  @override
  String get shareButton => 'Share';

  @override
  String get exportStarting => 'Starting export...';

  @override
  String get exportSuccessful => 'Export Successful';

  @override
  String get exportFailed => 'Export Failed';

  @override
  String get exportComplete => 'Export Complete';

  @override
  String get shareFailed => 'Failed to share file';

  @override
  String get shareBackupQuestion => 'Would you like to share the backup file?';

  @override
  String get importStarting => 'Starting import...';

  @override
  String get importSuccessful => 'Import successful!';

  @override
  String get importFailed => 'Import failed';

  @override
  String get importOptionsTitle => 'Import Options';

  @override
  String get importOptionsQuestion => 'How would you like to import the data?';

  @override
  String get replaceModeTitle => 'Replace';

  @override
  String get replaceModeDescription => 'Replace all existing data';

  @override
  String get mergeModeTitle => 'Merge';

  @override
  String get mergeModeDescription => 'Combine with existing data';

  @override
  String get appendModeTitle => 'Append';

  @override
  String get appendModeDescription => 'Only add new records';

  @override
  String get warningTitle => '⚠️ Warning';

  @override
  String get replaceWarningMessage =>
      'This will replace ALL your existing data. Are you sure you want to continue?';

  @override
  String get replaceAllButton => 'Replace All';

  @override
  String get fileLabel => 'File';

  @override
  String get sizeLabel => 'Size';

  @override
  String get recordsLabel => 'Records';

  @override
  String get usageRecordsLabel => 'Usage records';

  @override
  String get focusSessionsLabel => 'Focus sessions';

  @override
  String get appMetadataLabel => 'App metadata';

  @override
  String get updatedLabel => 'Updated';

  @override
  String get skippedLabel => 'Skipped';

  @override
  String get activityTrackingSection => 'Activity Tracking';

  @override
  String get idleDetectionTitle => 'Idle Detection';

  @override
  String get idleDetectionDescription => 'Stop tracking when inactive';

  @override
  String get keepActiveDuringMediaTitle => 'Keep Active During Media';

  @override
  String get keepActiveDuringMediaDescription =>
      'Ignore idle pause while video or audio is playing (e.g. YouTube, Netflix)';

  @override
  String get pauseOnWindowBlurTitle => 'Pause on Window Blur';

  @override
  String get pauseOnWindowBlurDescription =>
      'Pause tracking when the browser window loses focus';

  @override
  String get ignoreWindowBlurOnMediaTitle => 'Ignore Window Blur During Media';

  @override
  String get ignoreWindowBlurOnMediaDescription =>
      'Keep tracking active when switching screens while video or audio is playing';

  @override
  String get pauseOnTabUnfocusTitle => 'Pause on Tab Switch / Unfocus';

  @override
  String get pauseOnTabUnfocusDescription =>
      'Pause tracking when tab is inactive or backgrounded';

  @override
  String get idleTimeoutTitle => 'Idle Timeout';

  @override
  String idleTimeoutDescription(String timeout) {
    return 'Time before considering idle ($timeout)';
  }

  @override
  String get advancedWarning =>
      'Advanced features may increase resource usage. Enable only if needed.';

  @override
  String get monitorAudioTitle => 'Monitor System Audio';

  @override
  String get monitorAudioDescription => 'Detect activity from audio playback';

  @override
  String get audioSensitivityTitle => 'Audio Sensitivity';

  @override
  String audioSensitivityDescription(String value) {
    return 'Detection threshold ($value)';
  }

  @override
  String get monitorControllersTitle => 'Monitor Game Controllers';

  @override
  String get monitorControllersDescription => 'Detect Xbox/XInput controllers';

  @override
  String get monitorHIDTitle => 'Monitor HID Devices';

  @override
  String get monitorHIDDescription => 'Detect wheels, tablets, custom devices';

  @override
  String get setIdleTimeoutTitle => 'Set Idle Timeout';

  @override
  String get idleTimeoutDialogDescription =>
      'Choose how long to wait before considering you idle:';

  @override
  String get seconds30 => '30 seconds';

  @override
  String get minute1 => '1 minute';

  @override
  String get minutes2 => '2 minutes';

  @override
  String get minutes5 => '5 minutes';

  @override
  String get minutes10 => '10 minutes';

  @override
  String get customOption => 'Custom';

  @override
  String get customDurationTitle => 'Custom Duration';

  @override
  String get minutesLabel => 'Minutes';

  @override
  String get secondsLabel => 'Seconds';

  @override
  String get minAbbreviation => 'min';

  @override
  String get secAbbreviation => 'sec';

  @override
  String totalLabel(String duration) {
    return 'Total: $duration';
  }

  @override
  String minimumError(String value) {
    return 'Minimum is $value';
  }

  @override
  String maximumError(String value) {
    return 'Maximum is $value';
  }

  @override
  String rangeInfo(String min, String max) {
    return 'Range: $min - $max';
  }

  @override
  String get saveButton => 'Save';

  @override
  String timeFormatSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get timeFormatMinute => '1 min';

  @override
  String timeFormatMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String timeFormatMinutesSeconds(int minutes, int seconds) {
    return '$minutes min ${seconds}s';
  }

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeDescription => 'Color theme of the application';

  @override
  String get voiceGenderTitle => 'Voice Gender';

  @override
  String get voiceGenderDescription =>
      'Choose the voice gender for timer notifications';

  @override
  String get voiceGenderMale => 'Male';

  @override
  String get voiceGenderFemale => 'Female';

  @override
  String get alertsLimitsSubtitle =>
      'Manage your screen time limits and notifications';

  @override
  String get applicationsSubtitle => 'Manage your tracked applications';

  @override
  String applicationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count applications',
      one: '1 application',
    );
    return '$_temp0';
  }

  @override
  String get noApplicationsFound => 'No applications found';

  @override
  String get tryAdjustingFilters => 'Try adjusting your filters';

  @override
  String get configureAppSettings => 'Configure application settings';

  @override
  String get behaviorSection => 'Behavior';

  @override
  String helpSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions across 7 categories',
      one: '1 question across 7 categories',
    );
    return '$_temp0';
  }

  @override
  String get searchForHelp => 'Search for help...';

  @override
  String get quickNavGeneral => 'General';

  @override
  String get quickNavApps => 'Apps';

  @override
  String get quickNavReports => 'Reports';

  @override
  String get quickNavFocus => 'Focus';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryDifferentKeywords => 'Try searching with different keywords';

  @override
  String get clearSearch => 'Clear Search';

  @override
  String get greetingMorning => 'Good morning! Here\'s your activity summary.';

  @override
  String get greetingAfternoon =>
      'Good afternoon! Here\'s your activity summary.';

  @override
  String get greetingEvening => 'Good evening! Here\'s your activity summary.';

  @override
  String get screenTimeProgress => 'Screen\nTime';

  @override
  String get productiveScoreProgress => 'Productive\nScore';

  @override
  String get focusModeSubtitle => 'Stay focused, be productive';

  @override
  String get thisWeek => 'This Week';

  @override
  String get sessions => 'Sessions';

  @override
  String get totalTime => 'Total Time';

  @override
  String get avgLength => 'Avg Length';

  @override
  String get focusTime => 'Focus Time';

  @override
  String get paused => 'Paused';

  @override
  String get shortBreakStatus => 'Short Break';

  @override
  String get longBreakStatus => 'Long Break';

  @override
  String get readyToFocus => 'Ready to Focus';

  @override
  String get focus => 'Focus';

  @override
  String get restartSession => 'Restart Session';

  @override
  String get skipToNext => 'Skip to Next';

  @override
  String get settings => 'Settings';

  @override
  String sessionsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions completed',
      one: '1 session completed',
    );
    return '$_temp0';
  }

  @override
  String get focusModePreset => 'Focus Mode Preset';

  @override
  String get focusDuration => 'Focus Duration';

  @override
  String minutesFormat(int minutes) {
    return '$minutes min';
  }

  @override
  String get shortBreakDuration => 'Short Break';

  @override
  String get longBreakDuration => 'Long Break';

  @override
  String get enableSounds => 'Enable Sounds';

  @override
  String get focus_mode_this_week => 'This Week';

  @override
  String get focus_mode_best_day => 'Best Day';

  @override
  String focus_mode_sessions_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
      zero: '0 sessions',
    );
    return '$_temp0';
  }

  @override
  String get focus_mode_no_data_yet => 'No data yet';

  @override
  String get chart_current => 'Current';

  @override
  String get chart_previous => 'Previous';

  @override
  String get permission_error => 'Permission Error';

  @override
  String get notification_permission_denied => 'Notification Permission Denied';

  @override
  String get notification_permission_denied_message =>
      'ScreenTime needs notification permission to send you alerts and reminders.\n\nWould you like to open System Settings to enable notifications?';

  @override
  String get notification_permission_denied_hint =>
      'Open System Settings to enable notifications for ScreenTime.';

  @override
  String get notification_permission_required =>
      'Notification Permission Required';

  @override
  String get notification_permission_required_message =>
      'ScreenTime needs permission to send you notifications.';

  @override
  String get open_settings => 'Open Settings';

  @override
  String get allow_notifications => 'Allow Notifications';

  @override
  String get permission_allowed => 'Allowed';

  @override
  String get permission_denied => 'Denied';

  @override
  String get permission_not_set => 'Not Set';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get enable_notification_permission_hint =>
      'Enable notification permission to receive alerts';

  @override
  String minutes_format(int minutes) {
    return '$minutes min';
  }

  @override
  String get chart_average => 'Average';

  @override
  String get chart_peak => 'Peak';

  @override
  String get chart_lowest => 'Lowest';

  @override
  String get active => 'Active';

  @override
  String get disabled => 'Disabled';

  @override
  String get advanced_options => 'Advanced Options';

  @override
  String get sync_ready => 'Sync Ready';

  @override
  String get success => 'Success';

  @override
  String get destructive_badge => 'Destructive';

  @override
  String get recommended_badge => 'Recommended';

  @override
  String get safe_badge => 'Safe';

  @override
  String get overview => 'Overview';

  @override
  String get patterns => 'Patterns';

  @override
  String get apps => 'Apps';

  @override
  String get sortAscending => 'Sort Ascending';

  @override
  String get sortDescending => 'Sort Descending';

  @override
  String applicationsShowing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count applications showing',
      one: '1 application showing',
      zero: '0 applications showing',
    );
    return '$_temp0';
  }

  @override
  String valueLabel(String value) {
    return 'Value: $value';
  }

  @override
  String appsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count apps',
      one: '1 app',
      zero: '0 apps',
    );
    return '$_temp0';
  }

  @override
  String categoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categories',
      one: '1 category',
      zero: '0 categories',
    );
    return '$_temp0';
  }

  @override
  String get systemNotificationsDisabled =>
      'System notifications are disabled. Enable them in System Settings for focus alerts.';

  @override
  String get openSystemSettings => 'Open System Settings';

  @override
  String get appNotificationsDisabled =>
      'Notifications are disabled in app settings. Enable them to receive focus alerts.';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get focusModeNotificationsDisabled =>
      'Focus mode notifications are disabled. Enable them to receive session alerts.';

  @override
  String get notificationsDisabled => 'Notifications Disabled';

  @override
  String get dontShowAgain => 'Don\'t show again';

  @override
  String get systemSettingsRequired => 'System Settings Required';

  @override
  String get notificationsDisabledSystemLevel =>
      'Notifications are disabled at the system level. To enable:';

  @override
  String get step1OpenSystemSettings =>
      '1. Open System Settings (System Preferences)';

  @override
  String get step2GoToNotifications => '2. Go to Notifications';

  @override
  String get step3FindApp => '3. Find and select Scolect';

  @override
  String get step4EnableNotifications => '4. Enable \"Allow notifications\"';

  @override
  String get returnToAppMessage =>
      'Then return to this app and notifications will work.';

  @override
  String get gotIt => 'Got it';

  @override
  String get noSessionsYet => 'No sessions yet';

  @override
  String applicationsTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count applications tracked',
      one: '1 application tracked',
      zero: '0 applications tracked',
    );
    return '$_temp0';
  }

  @override
  String get applicationHeader => 'Application';

  @override
  String get currentUsageHeader => 'Current Usage';

  @override
  String get dailyLimitHeader => 'Daily Limit';

  @override
  String get edit => 'Edit';

  @override
  String get showPopupNotifications => 'Show popup notifications';

  @override
  String get moreFrequentReminders => 'More frequent reminders';

  @override
  String get playSoundWithAlerts => 'Play sound with alerts';

  @override
  String get systemTrayNotifications => 'System tray notifications';

  @override
  String screenTimeUsed(String current, String limit) {
    return '$current / $limit used';
  }

  @override
  String get todaysScreenTime => 'Today\'s Screen Time';

  @override
  String get activeLimits => 'Active Limits';

  @override
  String get nearLimit => 'Near Limit';

  @override
  String get colorPickerSpectrum => 'Spectrum';

  @override
  String get colorPickerPresets => 'Presets';

  @override
  String get colorPickerSliders => 'Sliders';

  @override
  String get colorPickerBasicColors => 'Basic Colors';

  @override
  String get colorPickerExtendedPalette => 'Extended Palette';

  @override
  String get colorPickerRed => 'Red';

  @override
  String get colorPickerGreen => 'Green';

  @override
  String get colorPickerBlue => 'Blue';

  @override
  String get colorPickerHue => 'Hue';

  @override
  String get colorPickerSaturation => 'Saturation';

  @override
  String get colorPickerBrightness => 'Brightness';

  @override
  String get colorPickerHexColor => 'Hex Color';

  @override
  String get colorPickerHexPlaceholder => 'RRGGBB';

  @override
  String get colorPickerRGB => 'RGB';

  @override
  String get select => 'Select';

  @override
  String get themeCustomization => 'Theme Customization';

  @override
  String get chooseThemePreset => 'Choose a Theme Preset';

  @override
  String get yourCustomThemes => 'Your Custom Themes';

  @override
  String get createCustomTheme => 'Create Custom Theme';

  @override
  String get designOwnColorScheme => 'Design your own color scheme';

  @override
  String get newTheme => 'New Theme';

  @override
  String get editCurrentTheme => 'Edit Current Theme';

  @override
  String customizeColorsFor(String themeName) {
    return 'Customize colors for $themeName';
  }

  @override
  String customThemeNumber(int number) {
    return 'Custom Theme $number';
  }

  @override
  String get deleteCustomTheme => 'Delete Custom Theme';

  @override
  String confirmDeleteTheme(String themeName) {
    return 'Are you sure you want to delete \"$themeName\"?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get customizeTheme => 'Customize Theme';

  @override
  String get preview => 'Preview';

  @override
  String get themeName => 'Theme Name';

  @override
  String get brandColors => 'Brand Colors';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get reset => 'Reset';

  @override
  String get saveTheme => 'Save Theme';

  @override
  String get customTheme => 'Custom Theme';

  @override
  String get primaryColors => 'Primary Colors';

  @override
  String get primaryColorsDesc => 'Main accent colors used throughout the app';

  @override
  String get primaryAccent => 'Primary Accent';

  @override
  String get primaryAccentDesc => 'Main brand color, buttons, links';

  @override
  String get secondaryAccent => 'Secondary Accent';

  @override
  String get secondaryAccentDesc => 'Complementary accent for gradients';

  @override
  String get semanticColors => 'Semantic Colors';

  @override
  String get semanticColorsDesc => 'Colors that convey meaning and status';

  @override
  String get successColor => 'Success Color';

  @override
  String get successColorDesc => 'Positive actions, confirmations';

  @override
  String get warningColor => 'Warning Color';

  @override
  String get warningColorDesc => 'Caution, pending states';

  @override
  String get errorColor => 'Error Color';

  @override
  String get errorColorDesc => 'Errors, destructive actions';

  @override
  String get backgroundColors => 'Background Colors';

  @override
  String get backgroundColorsLightDesc =>
      'Main background surfaces for light mode';

  @override
  String get backgroundColorsDarkDesc =>
      'Main background surfaces for dark mode';

  @override
  String get background => 'Background';

  @override
  String get backgroundDesc => 'Main app background';

  @override
  String get surface => 'Surface';

  @override
  String get surfaceDesc => 'Cards, dialogs, elevated surfaces';

  @override
  String get surfaceSecondary => 'Surface Secondary';

  @override
  String get surfaceSecondaryDesc => 'Secondary cards, sidebars';

  @override
  String get border => 'Border';

  @override
  String get borderDesc => 'Dividers, card borders';

  @override
  String get textColors => 'Text Colors';

  @override
  String get textColorsLightDesc => 'Typography colors for light mode';

  @override
  String get textColorsDarkDesc => 'Typography colors for dark mode';

  @override
  String get textPrimary => 'Text Primary';

  @override
  String get textPrimaryDesc => 'Headings, important text';

  @override
  String get textSecondary => 'Text Secondary';

  @override
  String get textSecondaryDesc => 'Descriptions, captions';

  @override
  String previewMode(String mode) {
    return 'Preview: $mode Mode';
  }

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get sampleCardTitle => 'Sample Card Title';

  @override
  String get sampleSecondaryText =>
      'This is secondary text that appears below.';

  @override
  String get primary => 'Primary';

  @override
  String get secondary => 'Secondary';

  @override
  String get warning => 'Warning';

  @override
  String get launchAtStartupTitle => 'Launch at startup';

  @override
  String get launchAtStartupDescription =>
      'Automatically start Scolect when you log in to your computer';

  @override
  String get inputMonitoringPermissionTitle =>
      'Keyboard Monitoring Unavailable';

  @override
  String get inputMonitoringPermissionDescription =>
      'Enable Input Monitoring permission to track keyboard activity. Currently only mouse input is monitored.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get permissionGrantedTitle => 'Permission Granted';

  @override
  String get permissionGrantedDescription =>
      'The app needs to restart for Input Monitoring to take effect.';

  @override
  String get continueButton => 'Continue';

  @override
  String get restartRequiredTitle => 'Restart Required';

  @override
  String get restartRequiredDescription =>
      'To enable keyboard monitoring, the app needs to restart. This is required by macOS.';

  @override
  String get restartNote =>
      'The app will automatically relaunch after restarting.';

  @override
  String get restartNow => 'Restart Now';

  @override
  String get restartLater => 'Restart Later';

  @override
  String get restartFailedTitle => 'Restart Failed';

  @override
  String get restartFailedMessage =>
      'Could not restart the app automatically. Please quit (Cmd+Q) and relaunch manually.';

  @override
  String get exportAnalyticsReport => 'Export Analytics Report';

  @override
  String get chooseExportFormat => 'Choose export format:';

  @override
  String get beautifulExcelReport => 'Beautiful Excel Report';

  @override
  String get beautifulExcelReportDescription =>
      'Gorgeous, colorful spreadsheet with charts, emojis, and insights ✨';

  @override
  String get excelReportIncludes => 'The Excel report includes:';

  @override
  String get summarySheetDescription =>
      '📊 Summary Sheet - Key metrics with trends';

  @override
  String get dailyBreakdownDescription =>
      '📅 Daily Breakdown - Visual usage patterns';

  @override
  String get appsSheetDescription => '📱 Apps Sheet - Detailed app rankings';

  @override
  String get insightsDescription => '💡 Insights - Smart recommendations';

  @override
  String get beautifulExcelExportSuccess =>
      'Beautiful Excel report exported successfully! 🎉';

  @override
  String failedToExportReport(String error) {
    return 'Failed to export report: $error';
  }

  @override
  String get exporting => 'Exporting...';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get saveAnalyticsReport => 'Save Analytics Report';

  @override
  String analyticsReportFileName(String timestamp) {
    return 'analytics_report_$timestamp.xlsx';
  }

  @override
  String get usageAnalyticsReportTitle => 'USAGE ANALYTICS REPORT';

  @override
  String get generated => 'Generated:';

  @override
  String get period => 'Period:';

  @override
  String dateRangeValue(String startDate, String endDate) {
    return '$startDate to $endDate';
  }

  @override
  String get keyMetrics => 'KEY METRICS';

  @override
  String get metric => 'Metric';

  @override
  String get value => 'Value';

  @override
  String get change => 'Change';

  @override
  String get trend => 'Trend';

  @override
  String get productivityRate => 'Productivity Rate';

  @override
  String get trendUp => 'Up';

  @override
  String get trendDown => 'Down';

  @override
  String get trendExcellent => 'Excellent';

  @override
  String get trendGood => 'Good';

  @override
  String get trendNeedsImprovement => 'Needs Improvement';

  @override
  String get trendActive => 'Active';

  @override
  String get trendNone => 'None';

  @override
  String get trendTop => 'Top';

  @override
  String get category => 'Category';

  @override
  String get percentage => 'Percentage';

  @override
  String get visual => 'Visual';

  @override
  String get statistics => 'STATISTICS';

  @override
  String get averageDaily => 'Average Daily';

  @override
  String get highestDay => 'Highest Day';

  @override
  String get lowestDay => 'Lowest Day';

  @override
  String get day => 'Day';

  @override
  String get applicationUsageDetails => 'APPLICATION USAGE DETAILS';

  @override
  String get totalApps => 'Total Apps:';

  @override
  String get productiveApps => 'Productive Apps:';

  @override
  String get rank => 'Rank';

  @override
  String get application => 'Application';

  @override
  String get time => 'Time';

  @override
  String get percentOfTotal => '% of Total';

  @override
  String get type => 'Type';

  @override
  String get usageLevel => 'Usage Level';

  @override
  String get leisure => 'Leisure';

  @override
  String get usageLevelVeryHigh => 'Very High ||||||||';

  @override
  String get usageLevelHigh => 'High ||||||';

  @override
  String get usageLevelMedium => 'Medium ||||';

  @override
  String get usageLevelLow => 'Low ||';

  @override
  String get keyInsightsTitle => 'KEY INSIGHTS & RECOMMENDATIONS';

  @override
  String get personalizedRecommendations => 'PERSONALIZED RECOMMENDATIONS';

  @override
  String insightHighDailyUsage(String hours) {
    return 'High Daily Usage: You\'re averaging $hours hours per day of screen time';
  }

  @override
  String insightLowDailyUsage(String hours) {
    return 'Low Daily Usage: You\'re averaging $hours hours per day - great balance!';
  }

  @override
  String insightModerateUsage(String hours) {
    return 'Moderate Usage: Averaging $hours hours per day of screen time';
  }

  @override
  String insightExcellentProductivity(String percentage) {
    return 'Excellent Productivity: $percentage% of your screen time is productive work!';
  }

  @override
  String insightGoodProductivity(String percentage) {
    return 'Good Productivity: $percentage% of your screen time is productive';
  }

  @override
  String insightLowProductivity(String percentage) {
    return 'Low Productivity Alert: Only $percentage% of screen time is productive';
  }

  @override
  String insightFocusSessions(int count, String avgPerDay) {
    return 'Focus Sessions: Completed $count sessions ($avgPerDay per day on average)';
  }

  @override
  String insightGreatFocusHabit(int count) {
    return 'Great Focus Habit: You\'ve built an amazing focus routine with $count completed sessions!';
  }

  @override
  String get insightNoFocusSessions =>
      'No Focus Sessions: Consider using focus mode to boost your productivity';

  @override
  String insightScreenTimeTrend(String direction, String percentage) {
    return 'Screen Time Trend: Your usage has $direction by $percentage% compared to the previous period';
  }

  @override
  String insightProductiveTimeTrend(String direction, String percentage) {
    return 'Productive Time Trend: Your productive time has $direction by $percentage% compared to previous period';
  }

  @override
  String get directionIncreased => 'increased';

  @override
  String get directionDecreased => 'decreased';

  @override
  String insightTopCategory(String category, String percentage) {
    return 'Top Category: $category dominates with $percentage% of your total time';
  }

  @override
  String insightMostUsedApp(
      String appName, String percentage, String duration) {
    return 'Most Used App: $appName accounts for $percentage% of your time ($duration)';
  }

  @override
  String insightUsageVaries(String highDay, String multiplier, String lowDay) {
    return 'Usage Varies Significantly: $highDay had ${multiplier}x more usage than $lowDay';
  }

  @override
  String get insightNoInsights => 'No significant insights available';

  @override
  String get recScheduleFocusSessions =>
      'Try scheduling more focus sessions throughout your day to boost productivity';

  @override
  String get recSetAppLimits =>
      'Consider setting app limits on leisure applications';

  @override
  String get recAimForFocusSessions =>
      'Aim for at least 1-2 focus sessions per day to build a consistent habit';

  @override
  String get recTakeBreaks =>
      'Your daily screen time is quite high. Try taking regular breaks using the 20-20-20 rule';

  @override
  String get recSetDailyGoals =>
      'Consider setting daily screen time goals to gradually reduce usage';

  @override
  String get recBalanceEntertainment =>
      'Entertainment apps account for a large portion of your time. Consider balancing with more productive activities';

  @override
  String get recReviewUsagePatterns =>
      'Your screen time has increased significantly. Review your usage patterns and set boundaries';

  @override
  String get recScheduleFocusedWork =>
      'Your productive time has decreased. Try scheduling focused work blocks in your calendar';

  @override
  String get recKeepUpGreatWork =>
      'Keep up the great work! Your screen time habits look healthy';

  @override
  String get recContinueFocusSessions =>
      'Continue using focus sessions to maintain productivity';

  @override
  String get sheetSummary => 'Summary';

  @override
  String get sheetDailyBreakdown => 'Daily Breakdown';

  @override
  String get sheetApps => 'Apps';

  @override
  String get sheetInsights => 'Insights';

  @override
  String get statusHeader => 'Status';

  @override
  String workSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count work sessions',
      one: '$count work session',
    );
    return '$_temp0';
  }

  @override
  String get complete => 'Complete';

  @override
  String get inProgress => 'In Progress';

  @override
  String get workTime => 'Work Time';

  @override
  String get breakTime => 'Break Time';

  @override
  String get phasesCompleted => 'Phases Completed';

  @override
  String hourMinuteFormat(String hours, String minutes) {
    return '$hours hr $minutes min';
  }

  @override
  String hourOnlyFormat(String hours) {
    return '$hours hr';
  }

  @override
  String minuteFormat(String minutes) {
    return '$minutes min';
  }

  @override
  String sessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '$count session',
    );
    return '$_temp0';
  }

  @override
  String get workPhases => 'Work Phases';

  @override
  String get averageLength => 'Average Length';

  @override
  String get mostProductive => 'Most Productive';

  @override
  String get work => 'Work';

  @override
  String get breaks => 'Breaks';

  @override
  String get none => 'None';

  @override
  String minuteShortFormat(String minutes) {
    return '${minutes}m';
  }

  @override
  String get importTheme => 'Import Theme';

  @override
  String get exportTheme => 'Export Theme';

  @override
  String get import => 'Import';

  @override
  String get export => 'Export';

  @override
  String get chooseExportMethod => 'Choose how to export your theme:';

  @override
  String get saveAsFile => 'Save as File';

  @override
  String get saveThemeAsJSONFile => 'Save theme as a JSON file to your device';

  @override
  String get copyToClipboard => 'Copy to Clipboard';

  @override
  String get copyThemeJSONToClipboard => 'Copy theme data to clipboard';

  @override
  String get share => 'Share';

  @override
  String get shareThemeViaSystemSheet => 'Share theme using system share sheet';

  @override
  String get chooseImportMethod => 'Choose how to import a theme:';

  @override
  String get loadFromFile => 'Load from File';

  @override
  String get selectJSONFileFromDevice =>
      'Select a JSON theme file from your device';

  @override
  String get pasteFromClipboard => 'Paste from Clipboard';

  @override
  String get importFromClipboardJSON => 'Import theme from clipboard JSON data';

  @override
  String get importFromFile => 'Import theme from a file';

  @override
  String get clipboardImportTitle => 'Import from Clipboard';

  @override
  String get clipboardImportDescription =>
      'Paste or edit the theme JSON data below:';

  @override
  String get clipboardImportPlaceholder => 'Paste theme JSON here...';

  @override
  String clipboardImportErrorLoadFailed(String error) {
    return 'Failed to load clipboard: $error';
  }

  @override
  String get clipboardImportErrorNotJsonObject => 'Expected a JSON object';

  @override
  String clipboardImportErrorMissingField(String field) {
    return 'Missing required field: $field';
  }

  @override
  String get clipboardImportErrorInvalidJson => 'Invalid JSON format';

  @override
  String get clipboardImportValidData => 'Valid theme data';

  @override
  String get themeCreatedSuccessfully => 'Theme created successfully!';

  @override
  String get themeUpdatedSuccessfully => 'Theme updated successfully!';

  @override
  String get themeDeletedSuccessfully => 'Theme deleted successfully!';

  @override
  String get themeExportedSuccessfully => 'Theme exported successfully!';

  @override
  String get themeCopiedToClipboard => 'Theme copied to clipboard!';

  @override
  String themeImportedSuccessfully(String themeName) {
    return 'Theme \"$themeName\" imported successfully!';
  }

  @override
  String get noThemeDataFound => 'No theme data found';

  @override
  String get invalidThemeFormat =>
      'Invalid theme format. Please check the JSON data.';

  @override
  String get trackingModeTitle => 'Tracking Mode';

  @override
  String get trackingModeDescription => 'Choose how app usage is tracked';

  @override
  String get trackingModePolling => 'Standard (Low Resource)';

  @override
  String get trackingModePrecise => 'Precise (High Accuracy)';

  @override
  String get trackingModePollingHint =>
      'Checks every minute - lower resource usage';

  @override
  String get trackingModePreciseHint =>
      'Real-time tracking - higher accuracy, more resources';

  @override
  String get trackingModeChangeError =>
      'Failed to change tracking mode. Please try again.';

  @override
  String get errorTitle => 'Error';

  @override
  String get monitorKeyboardTitle => 'Monitor Keyboard';

  @override
  String get monitorKeyboardDescription =>
      'Track keyboard activity to detect user presence';

  @override
  String get changelogWhatsNew => 'What\'s New';

  @override
  String changelogReleasedOn(String date) {
    return 'Released on $date';
  }

  @override
  String get changelogNoContent => 'No changelog available for this version.';

  @override
  String get changelogUnableToLoad => 'Unable to Load Changelog';

  @override
  String get changelogErrorDescription =>
      'Could not retrieve the changelog for this version. Please check your internet connection or visit the GitHub releases page.';

  @override
  String get allTracking => 'All Apps';

  @override
  String get notTracking => 'Not Tracked';

  @override
  String get allVisibility => 'All';

  @override
  String get visible => 'Visible';

  @override
  String get hidden => 'Hidden';

  @override
  String get todaysLimitUsage => 'Today\'s Limit Usage';

  @override
  String get thisWeekAtAGlance => 'This Week at a Glance';

  @override
  String get hourlyActivityHeatmap => 'Hourly Activity Heatmap';

  @override
  String get productivityScore => 'Productivity Score';

  @override
  String get streaks => 'Streaks';

  @override
  String get weekOverWeek => 'Week over Week';

  @override
  String get sameAsLastWeek => 'Same as last week';

  @override
  String moreUsageThanLastWeek(String percent) {
    return '$percent% more than last week';
  }

  @override
  String lessUsageThanLastWeek(String percent) {
    return '$percent% less than last week';
  }

  @override
  String limitExceededBy(String duration) {
    return 'Limit exceeded by $duration';
  }

  @override
  String timeRemaining(String duration) {
    return '$duration remaining';
  }

  @override
  String get totalSessions => 'Total sessions';

  @override
  String get avgSession => 'Avg session';

  @override
  String get mostActive => 'Most active';

  @override
  String get peakUsage => 'Peak usage';

  @override
  String get dailyAverage => 'Daily average';

  @override
  String get daysUsedInARow => 'Days used in a row';

  @override
  String get daysSingular => 'day';

  @override
  String get daysPlural => 'days';

  @override
  String get daysOverLimitInARow => 'Days over limit in a row';

  @override
  String get withinLimitAllWeek => 'Within limit all week';

  @override
  String get productivityScoreGreat => 'Great';

  @override
  String get productivityScoreModerate => 'Moderate';

  @override
  String get productivityScoreNeedsAttention => 'Needs Attention';

  @override
  String get productiveAppMotivation => 'Productive app — keep it up';

  @override
  String get nonProductiveAppSuggestion => 'Non-productive — consider reducing';

  @override
  String get legendUsage => 'Usage';

  @override
  String get legendAverage => 'Average';

  @override
  String get legendLimit => 'Limit';

  @override
  String get chartPeak => 'Peak';

  @override
  String overLimitBy(String duration) {
    return '+$duration over limit';
  }

  @override
  String get noData => 'No data';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get changelog => 'Changelog';

  @override
  String get exportingLabel => 'Exporting...';

  @override
  String get exportExcelLabel => 'Export Excel';

  @override
  String get dailyResetTimeTitle => 'Daily Reset Time';

  @override
  String get dailyResetTimeDescription =>
      'Set the time when your screen time counter resets for a new day.';

  @override
  String narrativeTodaySpent(String timeStr) {
    return 'Today you spent $timeStr at your computer.';
  }

  @override
  String narrativeMostFocused(String start, String end) {
    return 'Your most focused stretch was $start – $end.';
  }

  @override
  String narrativeFocusSessions(
      int focusSessions, int focusSessionsCount, int fsMinutes) {
    String _temp0 = intl.Intl.pluralLogic(
      focusSessionsCount,
      locale: localeName,
      other: 'sessions',
      one: 'session',
    );
    return 'You completed $focusSessions focus $_temp0 totalling ${fsMinutes}m.';
  }

  @override
  String narrativeCheckedAppShort(String topAppName, int topAppOpenCount) {
    return 'You checked $topAppName $topAppOpenCount times but kept each visit short.';
  }

  @override
  String narrativeCheckedAppLong(
      String topAppName, int topAppOpenCount, int topAppOpenCountPlural) {
    String _temp0 = intl.Intl.pluralLogic(
      topAppOpenCountPlural,
      locale: localeName,
      other: 'sessions',
      one: 'session',
    );
    return 'Most of your time went to $topAppName in just $topAppOpenCount $_temp0.';
  }

  @override
  String get narrativeToneSolid => 'Solid day.';

  @override
  String get narrativeToneDecent => 'Decent progress.';

  @override
  String get narrativeToneLight => 'Light day — nothing wrong with that.';

  @override
  String get narrativeToneImprove => 'Room to improve tomorrow.';

  @override
  String get habitDnaTitle => 'Your Habit DNA';

  @override
  String habitDnaAnalyzed(int daysAnalyzed) {
    return '${daysAnalyzed}d analyzed';
  }

  @override
  String get habitDnaChronotype => 'Chronotype';

  @override
  String get habitDnaWorkStyle => 'Work Style';

  @override
  String get habitDnaPeakFocus => 'Peak Focus';

  @override
  String get habitDnaAvgSession => 'Avg Session';

  @override
  String get habitDnaBestDay => 'Best Day';

  @override
  String get habitDnaRoughDay => 'Rough Day';

  @override
  String habitDnaKryptonite(String appName) {
    return 'Top distraction: $appName';
  }

  @override
  String get chronotypeMorning => 'Morning Person';

  @override
  String get chronotypeAfternoon => 'Afternoon Peak';

  @override
  String get chronotypeNight => 'Night Owl';

  @override
  String get chronotypeMixed => 'Mixed';

  @override
  String get workStyleDeep => 'Deep Focus';

  @override
  String get workStyleSwitcher => 'Task Switcher';

  @override
  String get workStyleBalanced => 'Balanced';

  @override
  String timeFormatAm(int hour) {
    return '$hour AM';
  }

  @override
  String timeFormatPm(int hour) {
    return '$hour PM';
  }

  @override
  String get timeFormatMidnight => 'Midnight';

  @override
  String get timeFormatNoon => 'Noon';

  @override
  String get weeklyStoryTitle => 'This Week';

  @override
  String weeklyStoryWeekNumber(int weekNumber) {
    return 'Week $weekNumber';
  }

  @override
  String weeklyStoryHeadline(int weekNumber, String timeStr) {
    return 'Week $weekNumber — $timeStr on screen so far.';
  }

  @override
  String weeklyStoryReclaimed(String diff) {
    return 'You\'ve reclaimed $diff compared to Week 1.';
  }

  @override
  String weeklyStoryUp(String diff) {
    return 'Screen time is up $diff from Week 1.';
  }

  @override
  String weeklyStoryImprovementArea(String timeLabel, String worstCat) {
    return 'Still working on: $timeLabel in $worstCat.';
  }

  @override
  String get weekdayNameMonday => 'Monday';

  @override
  String get weekdayNameTuesday => 'Tuesday';

  @override
  String get weekdayNameWednesday => 'Wednesday';

  @override
  String get weekdayNameThursday => 'Thursday';

  @override
  String get weekdayNameFriday => 'Friday';

  @override
  String get weekdayNameSaturday => 'Saturday';

  @override
  String get weekdayNameSunday => 'Sunday';

  @override
  String get weekdayNameUnknown => 'that day';

  @override
  String get browserTitle => 'Browser';

  @override
  String get browserWebsiteTracking => 'Website tracking';

  @override
  String get browserSubtitle => 'Track and manage your website usage';

  @override
  String get browserToday => 'Today';

  @override
  String get browserSites => 'Sites';

  @override
  String get browserSevenDayActivity => '7-Day Activity';

  @override
  String get browserExtensionSettings => 'Extension Settings';

  @override
  String get browserSyncing => 'Syncing';

  @override
  String get browserTabOverview => 'Overview';

  @override
  String get browserTabWebsites => 'Websites';

  @override
  String get browserTabCategories => 'Categories';

  @override
  String get browserTabLimits => 'Limits';

  @override
  String get browserTabHistory => 'History';

  @override
  String get browserHistoryTitle => 'Weekly Overview';

  @override
  String get browserHistorySubtitle =>
      'Your browsing time over the last 7 days';

  @override
  String get browserHistoryNoData => 'No browsing data yet';

  @override
  String get browserHistoryAvgPerDay => 'Avg / day';

  @override
  String get browserHistoryPeakDay => 'Peak day';

  @override
  String get browserHistoryTotalWeek => 'Total this week';

  @override
  String get browserHistoryTopSites => 'Top sites this week';

  @override
  String get browserTodayWebTime => 'Today\'s Web Time';

  @override
  String get browserSitesVisited => 'Sites Visited';

  @override
  String get browserPageVisits => 'Page Visits';

  @override
  String get browserTopSitesToday => 'Top Sites Today';

  @override
  String get browserViewAll => 'View all →';

  @override
  String get browserNoWebActivityTitle => 'No web activity yet today';

  @override
  String get browserNoActivityWebSubtitle =>
      'Browse the web to start tracking your time';

  @override
  String get browserNoActivityDesktopSubtitle =>
      'Install the browser extension to start tracking';

  @override
  String get browserNoCategoriesTitle => 'No categories yet';

  @override
  String get browserNoCategoriesSubtitle =>
      'Categories appear once websites are tracked';

  @override
  String get browserByCategory => 'By Category';

  @override
  String browserVisitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visits',
      one: '1 visit',
    );
    return '$_temp0';
  }

  @override
  String get browserSearchPlaceholder => 'Search website or domain…';

  @override
  String get browserFilterAllTracking => 'All Tracking';

  @override
  String get browserFilterTracked => 'Tracked';

  @override
  String get browserFilterUntracked => 'Untracked';

  @override
  String get browserFilterAllTypes => 'All Types';

  @override
  String get browserFilterUnproductive => 'Unproductive';

  @override
  String browserWebsiteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count websites',
      one: '1 website',
    );
    return '$_temp0';
  }

  @override
  String get browserColumnDomain => 'Domain';

  @override
  String get browserColumnTimeToday => 'Time Today';

  @override
  String get browserColumnVisits => 'Visits';

  @override
  String get browserColumnTracking => 'Tracking';

  @override
  String get browserNoWebsitesTitle => 'No websites found';

  @override
  String get browserNoWebsitesWebSubtitle =>
      'Browse the web — your sites will appear here.';

  @override
  String get browserNoWebsitesDesktopSubtitle =>
      'Try adjusting your filters or wait for the\nextension to sync some data.';

  @override
  String get browserTimeDistribution => 'Time Distribution';

  @override
  String browserSiteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sites',
      one: '1 site',
    );
    return '$_temp0';
  }

  @override
  String get browserActiveLimits => 'Active Limits';

  @override
  String browserActiveLimitsSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count websites with daily limits',
      one: '1 website with daily limits',
    );
    return '$_temp0';
  }

  @override
  String get browserNoLimitsTitle => 'No limits set';

  @override
  String get browserNoLimitsSubtitle => 'Set daily time limits below';

  @override
  String get browserAllWebsites => 'All Websites';

  @override
  String get browserAllWebsitesSubtitle =>
      'Tap a site to set or change its daily limit';

  @override
  String get browserAllSitesHaveLimits => 'All sites have limits';

  @override
  String get browserNoWebsitesTrackedTitle => 'No websites tracked yet';

  @override
  String get browserNoWebsitesTrackedWebSubtitle =>
      'Browse the web to see your sites here';

  @override
  String get browserNoWebsitesTrackedDesktopSubtitle =>
      'Install the extension and browse to get started';

  @override
  String browserDailyLimitDialog(String domain) {
    return 'Daily Limit – $domain';
  }

  @override
  String get browserDailyLimitDialogDesc =>
      'Set how long you can visit this site per day.';

  @override
  String get browserHours => 'Hours';

  @override
  String get browserRemoveLimit => 'Remove Limit';

  @override
  String browserTimeUsed(String time) {
    return '$time used';
  }

  @override
  String get browserSetLimit => 'Set limit';

  @override
  String get browserExtensionMode => 'Extension Mode';

  @override
  String get browserDesktopAppUrl => 'Desktop App URL';

  @override
  String get browserDesktopAppUrlDesc =>
      'The URL where the Scolect desktop app is running its local server.';

  @override
  String get browserAbout => 'About';

  @override
  String get browserAboutExtension => 'Extension';

  @override
  String get browserAboutExtensionValue => 'Scolect – Web Time Tracker';

  @override
  String get browserAboutVersion => 'Version';

  @override
  String get browserAboutStorage => 'Storage';

  @override
  String get browserAboutStorageValue => 'chrome.storage.local';

  @override
  String get browserAboutHistory => 'History';

  @override
  String get browserAboutHistoryValue => 'Last 30 days retained';

  @override
  String get browserConnectedBrowsers => 'Connected Browsers';

  @override
  String get browserConnectedBrowsersDesc =>
      'Browsers that have synced website data to this desktop app. Rename them for reference, or remove ones you no longer use.';

  @override
  String get browserConnectedBrowsersEmpty => 'No browsers have connected yet.';

  @override
  String get browserSourceAllBrowsers => 'All Browsers';

  @override
  String browserSourceDefaultName(int index) {
    return 'Browser $index';
  }

  @override
  String get browserSourceLastSeen => 'Last seen';

  @override
  String browserSourceLastSeenDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get browserRenameDialogTitle => 'Rename Browser';

  @override
  String get browserSourcePingTooltip => 'Locate / Ping Browser';

  @override
  String browserSourcePingSent(String name) {
    return 'Ping sent to $name';
  }

  @override
  String get browserSourceRemoveTitle => 'Remove Browser?';

  @override
  String browserSourceRemoveConfirm(String name) {
    return 'Remove \"$name\" from your connected browsers? Its usage history is kept, but it will need to reconnect to sync again.';
  }

  @override
  String get browserLimitsScopeTitle => 'Website Limits Scope';

  @override
  String get browserLimitsScopeSubtitle =>
      'Choose whether website limits and tracking apply per browser profile or globally across all browsers.';

  @override
  String get browserLimitsScopeScoped => 'Per Browser Profile (Scoped)';

  @override
  String get browserLimitsScopeScopedDesc =>
      'Limits apply only to the specific browser profile where configured.';

  @override
  String get browserLimitsScopeGlobal => 'Global (Cross-Browser)';

  @override
  String get browserLimitsScopeGlobalDesc =>
      'Limits apply across all connected browsers combined.';

  @override
  String get browserSourceRemoveAction => 'Remove';

  @override
  String get browserDangerZone => 'Danger Zone';

  @override
  String get browserClearDataTitle => 'Clear All Website Data';

  @override
  String get browserClearDataDesc =>
      'Permanently deletes all tracked website history. This cannot be undone.';

  @override
  String get browserClearDataButton => 'Clear Data';

  @override
  String get browserAreYouSure => 'Are you sure?';

  @override
  String get browserYesDelete => 'Yes, Delete';

  @override
  String get browserDesktopUrlSaved => 'Desktop URL saved';

  @override
  String get browserDataCleared => 'All website data cleared';

  @override
  String get browserTrackingActive => 'Tracking Active';

  @override
  String get browserTrackingActiveDesc =>
      'Your browser activity is being tracked and\nsynced to the Scolect desktop app.';

  @override
  String get browserConnectedToDesktop => 'Connected to Scolect Desktop';

  @override
  String get browserDesktopNotReachable => 'Scolect Desktop not reachable';

  @override
  String get browserRefreshSyncStatus => 'Refresh sync status';

  @override
  String get browserSwitchToStandalone => 'Switch to Standalone mode →';

  @override
  String get browserSetupTitle => 'Connect Browser Extension';

  @override
  String get browserSetupSubtitle =>
      'Enable the local server so the Scolect browser extension can sync your web activity to the desktop application.';

  @override
  String get browserSetupEnableServer => 'Enable Extension Server';

  @override
  String browserSetupServerRunning(int port) {
    return 'Server running · port $port';
  }

  @override
  String get browserSetupServerOff => 'Server disabled';

  @override
  String get browserSetupStep1 => 'Enable the server using the toggle above';

  @override
  String get browserSetupStep2 =>
      'Install the Scolect extension in your browser';

  @override
  String get browserSetupStep3 => 'Open your browser and visit any site';

  @override
  String get browserSetupStep4 => 'Web activity will appear here automatically';

  @override
  String get browserSetupHowTo => 'How to get started';

  @override
  String get browserSetupServerActive => 'Server Active';

  @override
  String get browserSetupServerActiveDesc =>
      'Your browser extension can now connect and sync data.';

  @override
  String get browserSyncedJustNow => 'Synced just now';

  @override
  String browserSyncedMinutesAgo(int minutes) {
    return 'Synced ${minutes}m ago';
  }

  @override
  String browserSyncedHoursAgo(int hours) {
    return 'Synced ${hours}h ago';
  }

  @override
  String get browserNeverSynced => 'Not synced yet';

  @override
  String get browserSyncStalled => 'Sync stalled — check the extension';

  @override
  String get browserServerPort => 'Server Port';

  @override
  String get browserServerPortDesc =>
      'Port the local server listens on. Change this if port 46000 is already in use.';

  @override
  String get browserServerPortSaved => 'Port updated — extension reconnecting';

  @override
  String get browserServerPortInvalid => 'Enter a port between 1024 and 65535';

  @override
  String get browserServerBindFailed =>
      'Couldn\'t start the server — this port may already be in use';

  @override
  String get browserDisableServer => 'Disable Extension Server';

  @override
  String get browserDesktopClearDataTitle => 'Delete Browser Data';

  @override
  String get browserDesktopClearDataDescription =>
      'Delete all website usage history and settings synced from the browser extension. Your native app tracking data is not affected.';

  @override
  String get browserDesktopClearDataButtonLabel => 'Delete Browser Data';

  @override
  String get browserDesktopClearDataDialogTitle => 'Delete Browser Data?';

  @override
  String get browserDesktopClearDataDialogContent =>
      'This will permanently delete all website usage history and site settings synced from the browser extension. Your native app tracking data will not be affected. You won\'t be able to recover this data. Do you want to proceed?';

  @override
  String get browserEditSiteName => 'Edit display name';

  @override
  String get browserSiteNameHint => 'Display name (e.g. YouTube)';

  @override
  String get browserNoDataYet => 'No data yet';

  @override
  String get browserNoProductiveSites => 'No productive sites logged';

  @override
  String get browserDays => 'days';

  @override
  String browserProductivePercent(int percent) {
    return '$percent% Productive';
  }

  @override
  String browserLimitsBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Limits',
      one: '1 Limit',
    );
    return '$_temp0';
  }

  @override
  String get browserTopFocus => 'Top Focus';

  @override
  String get browserLimitsHealth => 'Limits Health';

  @override
  String get browserAllRespected => 'All Respected';

  @override
  String browserLimitsExceeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Exceeded',
      one: '1 Exceeded',
    );
    return '$_temp0';
  }

  @override
  String browserLimitsActiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count limits active',
      one: '1 limit active',
    );
    return '$_temp0';
  }

  @override
  String get browserCategoryShare => 'Category Share';

  @override
  String get browserProductiveTime => 'Productive Time';

  @override
  String get browserColumnDailyLimit => 'Daily Limit';

  @override
  String get browserDistracting => 'Distracting';

  @override
  String get browserClassification => 'Classification';

  @override
  String get browserPageSessions => 'Page sessions';

  @override
  String get browserTotalTimeToday => 'Total time today';

  @override
  String get browserOpenInBrowser => 'Open in Browser';

  @override
  String get browserEditDailyLimit => 'Edit Limit';

  @override
  String get browserSetDailyLimit => 'Set Daily Limit';

  @override
  String get browserRecommendedLimits => 'Recommended Limits';

  @override
  String get browserRecommendedLimitsDesc =>
      'High usage detected today on these unconstrained sites';

  @override
  String get browserSetOneHourLimit => 'Set 1h Limit';

  @override
  String get browserCustom => 'Custom';

  @override
  String get browserPeriodTotal => 'Period Total';

  @override
  String get browserActiveDays => 'Active Days';

  @override
  String get browserDayInspector => 'Day Inspector';

  @override
  String get browserDayInspectorPrompt =>
      'Click any bar in the chart to inspect top visited websites on that day.';

  @override
  String browserVsAverage(String percent) {
    return '$percent% vs avg';
  }

  @override
  String browserTopSitesOnDate(String date) {
    return 'Top sites on $date';
  }

  @override
  String get browserLast7Days => '7 Days';

  @override
  String get browserLast14Days => '14 Days';

  @override
  String get browserLast30Days => '30 Days';

  @override
  String get browserLimitsExtensionInfo =>
      'Browser limits are enforced by the Chrome Extension';

  @override
  String get browserLimitsExtensionInfoDesc =>
      'When a daily limit is reached, the extension automatically blocks access to that domain in the browser.';

  @override
  String browserSevenDayTotalSummary(String time, int visits) {
    return '7d Total: $time · $visits visits';
  }

  @override
  String get browserAllSitesHaveLimitsSubtitle =>
      'All tracked websites currently have active limits configured.';

  @override
  String get browserActiveLimitsHealthSafe =>
      'All limits are currently within safe daily thresholds.';

  @override
  String browserActiveLimitsHealthWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count websites have exceeded their daily limits!',
      one: '1 website has exceeded its daily limit!',
    );
    return '$_temp0';
  }

  @override
  String browserShareOfWeb(int percent) {
    return '$percent% of web';
  }

  @override
  String get browserLimitEnforced => 'Limit enforced';

  @override
  String get browserClickToSetLimitPrompt => 'Click to set limit';

  @override
  String get webExportDataDescription =>
      'Download all extension data as a JSON backup file';

  @override
  String get webImportDataDescription =>
      'Restore extension data from a previously exported JSON file';

  @override
  String get webExportSuccessTitle => 'Export Successful';

  @override
  String get webExportSuccessMessage =>
      'Your data has been downloaded as a JSON file.';

  @override
  String get webImportSuccessTitle => 'Import Successful';

  @override
  String webImportSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'keys',
      one: 'key',
    );
    return '$count storage $_temp0 restored.';
  }

  @override
  String get webImportConfirmTitle => 'Restore from Backup?';

  @override
  String get webImportConfirmMessage =>
      'This will overwrite your current extension data with the contents of the backup file. Existing data for restored keys will be replaced.';

  @override
  String get webImportConfirmButton => 'Restore';

  @override
  String get blockOverlayBadge => 'Scolect Screen Time';

  @override
  String get blockOverlayTitle => 'Daily Limit Reached';

  @override
  String get blockOverlayTimeSpent => 'Time spent';

  @override
  String get blockOverlayDailyLimit => 'Daily limit';

  @override
  String get blockOverlayVisitsToday => 'Visits today';

  @override
  String get blockOverlayResetsIn => 'Resets in';

  @override
  String get blockOverlayGoBack => 'Go Back';

  @override
  String get blockOverlayOpenDashboard => 'Open Dashboard';

  @override
  String get blockOverlayUnblockToday => 'Unblock for today';

  @override
  String blockOverlayUnblockConfirmLabel(String siteName) {
    return 'Type $siteName to unblock for the rest of today:';
  }

  @override
  String get blockOverlayUnblockButton => 'Unblock';

  @override
  String get blockOverlayFooter => 'Scolect · screen time tracker';

  @override
  String get markAsPrivate => 'Private';

  @override
  String get privateModeUnlockTitle => 'Unlock Private Mode';

  @override
  String get privateModePasswordPlaceholder => 'Password';

  @override
  String get privateModeConfirmPasswordPlaceholder => 'Confirm password';

  @override
  String get privateModeIncorrectPassword => 'Incorrect password';

  @override
  String get privateModeUnlockAction => 'Unlock';

  @override
  String get privateModeShowAction => 'Show private';

  @override
  String get privateModeHideAction => 'Hide private';

  @override
  String get privateModeLockHint => 'Right-click to lock now';

  @override
  String get privateModeShowOnlyDescription =>
      'Show only apps and websites marked private, in place of your everyday view. Also available from the titlebar.';

  @override
  String get privateModeSectionTitle => 'Private Mode';

  @override
  String get privateModeSetPasswordTitle => 'Set Password';

  @override
  String get privateModeChangePasswordTitle => 'Change Password';

  @override
  String get privateModePasswordDescription =>
      'Set a password to hide apps and websites marked private until unlocked.';

  @override
  String get privateModeSetPasswordAction => 'Set Password';

  @override
  String get privateModeChangePasswordAction => 'Change Password';

  @override
  String get privateModePasswordEmpty => 'Password cannot be empty';

  @override
  String get privateModePasswordMismatch => 'Passwords do not match';

  @override
  String get privateModeIncludeInTotalsTitle =>
      'Include Private Items in Totals';

  @override
  String get privateModeIncludeInTotalsDescription =>
      'When on, private apps and websites still count toward your daily totals even while hidden.';

  @override
  String get privateModeSessionTimeoutTitle => 'Auto-Lock After';

  @override
  String get privateModeSessionTimeoutDescription =>
      'Private Mode automatically re-locks after this many minutes.';

  @override
  String get privateModeResetPasswordTitle => 'Reset Password';

  @override
  String get privateModeResetPasswordDescription =>
      'Clears your Private Mode password. Items already marked private stay private until you set a new password — there is no password recovery.';

  @override
  String get privateModeResetPasswordAction => 'Reset Password';

  @override
  String get privateModeForgotPassword => 'Forgot password?';

  @override
  String get privateModeRecoveryTitle => 'Recover Private Mode';

  @override
  String get privateModeRecoveryTabBackupCode => 'Backup code';

  @override
  String get privateModeRecoveryTabSecurityQuestion => 'Security question';

  @override
  String get privateModeBackupCodePlaceholder => 'XXXX-XXXX-XXXX-XXXX';

  @override
  String get privateModeSecurityAnswerPlaceholder => 'Your answer';

  @override
  String get privateModeRecoveryIncorrect =>
      'That didn\'t match. Please try again.';

  @override
  String get privateModeRecoverySuccessTitle => 'Identity verified';

  @override
  String get privateModeRecoverySuccessDescription =>
      'Your old password has been cleared. Set a new password to continue — you\'ll also get a new backup code and security question.';

  @override
  String get privateModeSetupRecoveryTitle => 'Set Up Recovery';

  @override
  String get privateModeBackupCodeGeneratedTitle => 'Your backup code';

  @override
  String get privateModeBackupCodeWarning =>
      'Save this code somewhere safe. It will only be shown once, and you\'ll need it if you forget your password.';

  @override
  String get privateModeCopyBackupCode => 'Copy';

  @override
  String get privateModeBackupCodeCopied => 'Backup code copied';

  @override
  String get privateModeDownloadBackupCode => 'Download';

  @override
  String get privateModeSecurityQuestionLabel => 'Security question';

  @override
  String get privateModeSecurityAnswerLabel => 'Your answer';

  @override
  String get privateModeSecurityQuestionCustomOption =>
      'Write my own question…';

  @override
  String get privateModeChooseSecurityQuestion => 'Choose a security question';

  @override
  String get privateModeSecurityAnswerEmpty => 'Answer cannot be empty';

  @override
  String get privateModeIveSavedThis => 'I\'ve saved this backup code';

  @override
  String get privateModeRecoveryOptionsTitle => 'Recovery Options';

  @override
  String get privateModeRecoveryOptionsDescription =>
      'Regenerate your backup code and security question without changing your password.';

  @override
  String get privateModeRegenerateRecoveryAction => 'Regenerate';

  @override
  String get privateModeQuestionPetName =>
      'What was the name of your first pet?';

  @override
  String get privateModeQuestionBirthCity => 'In what city were you born?';

  @override
  String get privateModeQuestionFirstSchool =>
      'What was the name of your first school?';

  @override
  String get privateModeQuestionMotherMaidenName =>
      'What is your mother\'s maiden name?';

  @override
  String get privateModeQuestionFavoriteBook => 'What is your favorite book?';

  @override
  String get privateModeNotSetUpDescription =>
      'Set up Private Mode in Settings to keep sensitive apps and websites out of your everyday view.';

  @override
  String get privateModeGoToSettingsAction => 'Go to Settings';

  @override
  String get privateModeLockedDescription =>
      'Unlock to view your private apps and websites.';

  @override
  String get privateModeUnlockedDescription =>
      'Apps and websites you\'ve marked private.';

  @override
  String get privateModeNoItemsDescription =>
      'No private apps or websites tracked yet. Mark an item as private from its details to see it here.';

  @override
  String get privateModeItemsCount => 'Private Items';

  @override
  String get permissionBannerNotificationsDisabled => 'Notifications disabled';

  @override
  String get permissionBannerSystemDesc =>
      'Enable notifications in System Settings to receive focus session alerts.';

  @override
  String get permissionBannerOpenSystemSettings => 'Open System Settings';

  @override
  String get permissionBannerAppDesc =>
      'Enable notifications in app settings to receive focus session alerts.';

  @override
  String get permissionBannerFocusDisabled => 'Focus notifications disabled';

  @override
  String get permissionBannerFocusDesc =>
      'Enable focus mode notifications in settings to receive session alerts.';

  @override
  String get topWebsites => 'Top Websites';

  @override
  String get noWebsitesTrackedYet => 'No websites tracked yet';

  @override
  String get browserDetailBlockedTooltip =>
      'Daily limit reached – site is blocked';

  @override
  String get browserDetailTimeToday => 'Time today';

  @override
  String get browserDetailVisitsToday => 'Visits today';

  @override
  String get browserDetailDailyLimit => 'Daily limit';

  @override
  String get browserChartLegendTime => 'Time';

  @override
  String get browserChartLegendVisits => 'Visits';

  @override
  String get blockingBehaviorTitle => 'Blocking Behavior';

  @override
  String get blockingBehaviorNotificationOnlyTitle => 'Notification only';

  @override
  String get blockingBehaviorNotificationOnlySubtitle =>
      'Alert you when a limit is reached, no other action.';

  @override
  String get blockingBehaviorSoftBlockTitle => 'Soft block';

  @override
  String get blockingBehaviorSoftBlockSubtitle =>
      'Bring Scolect to the front with options to minimize, quit, snooze, or unblock the app.';

  @override
  String get blockingBehaviorHardBlockTitle => 'Hard block';

  @override
  String get blockingBehaviorHardBlockSubtitle =>
      'Same as soft block, and also immediately hides the app from your screen.';

  @override
  String get blockingBehaviorNudgeNote =>
      'Note: Blocking is a nudge, not a lock. You can still reopen the app from the Dock or taskbar.';

  @override
  String get aboutUpdateChecking => 'Checking...';

  @override
  String get aboutUpdateCheckButton => 'Check Updates';

  @override
  String get aboutUpdateCheckingProgress => 'Checking for updates...';

  @override
  String get aboutUpdateUpToDate => 'You\'re up to date';

  @override
  String get aboutUpdateFailed => 'Could not check for updates';

  @override
  String get aboutUpdateRetryPrompt => 'Tap \"Check Updates\" to retry';

  @override
  String get aboutUpdateScheduled => 'Update check scheduled';

  @override
  String get aboutOpenSettingsFailed => 'Failed to open System Settings';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Scolect';

  @override
  String get onboardingWelcomeDesc =>
      'Take control of your time. Scolect runs silently in the background — tracking every app, every session, every minute.';

  @override
  String get onboardingEveryAppTitle => 'Every App, Automatically';

  @override
  String get onboardingEveryAppDesc =>
      'Scolect watches the foreground app and quietly logs how long you spend in each one — no timers to start, nothing to remember.';

  @override
  String get onboardingSeeTimeTitle => 'See Where Your Time Goes';

  @override
  String get onboardingSeeTimeDesc =>
      'Beautiful daily and weekly reports show your most-used apps, total screen time, and usage trends at a glance.';

  @override
  String get onboardingSmartLimitsTitle => 'Smart Limits & Alerts';

  @override
  String get onboardingSmartLimitsDesc =>
      'Set daily time limits per app or for your total screen time. Get notified before you hit your limits — not after.';

  @override
  String get onboardingDeepFocusTitle => 'Deep Focus Mode';

  @override
  String get onboardingDeepFocusDesc =>
      'Block distracting apps during Pomodoro sessions. Custom work and break intervals with optional ambient sounds keep you in the zone.';

  @override
  String get onboardingTrackBrowserTitle => 'Track Browser Time Too';

  @override
  String get onboardingTrackBrowserDesc =>
      'Install the free browser extension to capture time spent on websites — not just native apps. Full picture, one dashboard.';

  @override
  String get onboardingAllSetTitle => 'You\'re All Set';

  @override
  String get onboardingAllSetDesc =>
      'Scolect is ready to track. Your data stays entirely on-device — completely private, never uploaded anywhere.';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGoToDashboard => 'Go to Dashboard';

  @override
  String get onboardingWorksInBrowserTitle => 'Works Right in Your Browser';

  @override
  String get onboardingWorksInBrowserDesc =>
      'Track web activity automatically as you browse. No desktop app required to get started.';

  @override
  String get onboardingUsageRightHereTitle => 'Your Usage, Right Here';

  @override
  String get onboardingUsageRightHereDesc =>
      'View detailed daily and weekly reports of your time spent on every website in clean, intuitive charts.';

  @override
  String get onboardingSyncWithDesktopTitle => 'Sync with the Desktop App';

  @override
  String get onboardingSyncWithDesktopDesc =>
      'Connect seamlessly with the Scolect desktop app for combined native app and website analytics.';

  @override
  String get onboarding100PrivateTitle => '100% Private';

  @override
  String get onboarding100PrivateDesc =>
      'All tracking data is stored locally in your browser and on your machine. Nothing is ever sent to the cloud.';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingSkip => 'Skip';
}
