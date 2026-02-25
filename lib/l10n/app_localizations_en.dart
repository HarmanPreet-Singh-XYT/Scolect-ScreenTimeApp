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
  String get navSettings => 'Settings';

  @override
  String get navHelp => 'Help';

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
  String get faqCategoryTroubleshooting => 'Troubleshooting';

  @override
  String get faqGeneralQ1 => 'How does this app track screen time?';

  @override
  String get faqGeneralA1 => 'The app monitors your device\'s usage in real-time, tracking the time spent on different applications. It provides comprehensive insights into your digital habits, including total screen time, productive time, and application-specific usage.';

  @override
  String get faqGeneralQ2 => 'What makes an app \'Productive\'?';

  @override
  String get faqGeneralA2 => 'You can manually mark apps as productive in the \'Applications\' section. Productive apps contribute to your Productive Score, which calculates the percentage of screen time spent on work-related or beneficial applications.';

  @override
  String get faqGeneralQ3 => 'How accurate is the screen time tracking?';

  @override
  String get faqGeneralA3 => 'The app uses system-level tracking to provide precise measurement of your device usage. It captures foreground time for each application with minimal battery impact.';

  @override
  String get faqGeneralQ4 => 'Can I customize my app categorization?';

  @override
  String get faqGeneralA4 => 'Absolutely! You can create custom categories, assign apps to specific categories, and easily modify these assignments in the \'Applications\' section. This helps in creating more meaningful usage analytics.';

  @override
  String get faqGeneralQ5 => 'What insights can I gain from this app?';

  @override
  String get faqGeneralA5 => 'The app offers comprehensive insights including Productive Score, usage patterns by time of day, detailed application usage, focus session tracking, and visual analytics like graphs and pie charts to help you understand and improve your digital habits.';

  @override
  String get faqAppsQ1 => 'How do I hide specific apps from tracking?';

  @override
  String get faqAppsA1 => 'In the \'Applications\' section, you can toggle the visibility of apps.';

  @override
  String get faqAppsQ2 => 'Can I search and filter my applications?';

  @override
  String get faqAppsA2 => 'Yes, the Applications section includes a search functionality and filtering options. You can filter apps by category, productivity status, tracking status, and visibility.';

  @override
  String get faqAppsQ3 => 'What editing options are available for applications?';

  @override
  String get faqAppsA3 => 'For each application, you can edit: category assignment, productivity status, tracking usage, visibility in reports, and set individual daily time limits.';

  @override
  String get faqAppsQ4 => 'How are application categories determined?';

  @override
  String get faqAppsA4 => 'Initial categories are system-suggested, but you have full control to create, modify, and assign custom categories based on your workflow and preferences.';

  @override
  String get faqReportsQ1 => 'What types of reports are available?';

  @override
  String get faqReportsA1 => 'Reports include: Total screen time, Productive time, Most used apps, Focus sessions, Daily screen time graph, Category breakdown pie chart, Detailed application usage, Weekly usage trends, and Usage pattern analysis by time of day.';

  @override
  String get faqReportsQ2 => 'How detailed are the application usage reports?';

  @override
  String get faqReportsA2 => 'Detailed application usage reports show: App name, Category, Total time spent, Productivity status, and offer an \'Actions\' section with deeper insights like usage summary, daily limits, usage trends, and productivity metrics.';

  @override
  String get faqReportsQ3 => 'Can I analyze my usage trends over time?';

  @override
  String get faqReportsA3 => 'Yes! The app provides week-over-week comparisons, showing graphs of usage over past weeks, average daily usage, longest sessions, and weekly totals to help you track your digital habits.';

  @override
  String get faqReportsQ4 => 'What is the \'Usage Pattern\' analysis?';

  @override
  String get faqReportsA4 => 'Usage Pattern breaks down your screen time into morning, afternoon, evening, and night segments. This helps you understand when you\'re most active on your device and identify potential areas for improvement.';

  @override
  String get faqAlertsQ1 => 'How granular are the screen time limits?';

  @override
  String get faqAlertsA1 => 'You can set overall daily screen time limits and individual app limits. Limits can be configured in hours and minutes, with options to reset or adjust as needed.';

  @override
  String get faqAlertsQ2 => 'What notification options are available?';

  @override
  String get faqAlertsA2 => 'The app offers multiple notification types: System alerts when you exceed screen time, Frequent alerts at customizable intervals (1, 5, 15, 30, or 60 minutes), and toggles for focus mode, screen time, and application-specific notifications.';

  @override
  String get faqAlertsQ3 => 'Can I customize limit alerts?';

  @override
  String get faqAlertsA3 => 'Yes, you can customize alert frequency, enable/disable specific types of alerts, and set different limits for overall screen time and individual applications.';

  @override
  String get faqFocusQ1 => 'What types of Focus Modes are available?';

  @override
  String get faqFocusA1 => 'Available modes include Deep Work (longer focused sessions), Quick Tasks (short bursts of work), and Reading Mode. Each mode helps you structure your work and break times effectively.';

  @override
  String get faqFocusQ2 => 'How flexible is the Pomodoro Timer?';

  @override
  String get faqFocusA2 => 'The timer is highly customizable. You can adjust work duration, short break length, and long break duration. Additional options include auto-start for next sessions and notification settings.';

  @override
  String get faqFocusQ3 => 'What does the Focus Mode history show?';

  @override
  String get faqFocusA3 => 'Focus Mode history tracks daily focus sessions, showing the number of sessions per day, trends graph, average session duration, total focus time, and a time distribution pie chart breaking down work sessions, short breaks, and long breaks.';

  @override
  String get faqFocusQ4 => 'Can I track my focus session progress?';

  @override
  String get faqFocusA4 => 'The app features a circular timer UI with play/pause, reload, and settings buttons. You can easily track and manage your focus sessions with intuitive controls.';

  @override
  String get faqSettingsQ1 => 'What customization options are available?';

  @override
  String get faqSettingsA1 => 'Customization includes theme selection (System, Light, Dark), language settings, startup behavior, comprehensive notification controls, and data management options like clearing data or resetting settings.';

  @override
  String get faqSettingsQ2 => 'How do I provide feedback or report issues?';

  @override
  String get faqSettingsA2 => 'At the bottom of the Settings section, you\'ll find buttons to Report a Bug, Submit Feedback, or Contact Support. These will redirect you to the appropriate support channels.';

  @override
  String get faqSettingsQ3 => 'What happens when I clear my data?';

  @override
  String get faqSettingsA3 => 'Clearing data will reset all your usage statistics, focus session history, and custom settings. This is useful for starting fresh or troubleshooting.';

  @override
  String get faqTroubleQ1 => 'Data is not showing, hive is not opening error';

  @override
  String get faqTroubleA1 => 'The issue is known, the temporary fix is to clear data through settings and if it doesn\'t work then go to Documents and delete the following files if they exist - harman_screentime_app_usage_box.hive and harman_screentime_app_usage.lock, you are also suggested to update the app to the latest version.';

  @override
  String get faqTroubleQ2 => 'App opens on every startup, what to do?';

  @override
  String get faqTroubleA2 => 'This is a known issue that occurs on Windows 10, the temporary fix is to enable Launch as Minimized in settings so it launches as Minimized.';

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
  String get failedToInitialize => 'Failed to initialize analytics. Please restart the application.';

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
  String get startDateBeforeEndDate => 'Start date must be before or equal to end date.';

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
  String get noApplicationsMatch => 'No applications match your search criteria';

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
  String get trendingUpward => 'Your usage is trending upward compared to the previous period.';

  @override
  String significantDecrease(String percentage) {
    return 'Your usage has decreased significantly ($percentage%) compared to the previous period.';
  }

  @override
  String get trendingDownward => 'Your usage is trending downward compared to the previous period.';

  @override
  String get consistentUsage => 'Your usage has been consistent compared to the previous period.';

  @override
  String get markedAsProductive => 'This is marked as a productive app in your settings.';

  @override
  String get markedAsNonProductive => 'This is marked as a non-productive app in your settings.';

  @override
  String mostActiveTime(String time) {
    return 'Your most active time is around $time.';
  }

  @override
  String get noLimitSet => 'No usage limit has been set for this application.';

  @override
  String get limitReached => 'You\'ve reached your daily limit for this application.';

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
  String get resetSettingsContent => 'If you reset settings, you won\'t be able to recover it. Do you want to reset it?';

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
  String get startUsingApplications => 'Start using your applications to track screen time and productivity.';

  @override
  String get refreshData => 'Refresh Data';

  @override
  String get topApplications => 'Top Applications';

  @override
  String get noAppUsageDataAvailable => 'No application usage data available yet';

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
  String get launchMinimizedDescription => 'Start the application in System Tray (Recommended for Windows 10)';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsAllDescription => 'All notifications of the application';

  @override
  String get focusModeNotificationsTitle => 'Focus Mode';

  @override
  String get focusModeNotificationsDescription => 'All Notifications for focus mode';

  @override
  String get screenTimeNotificationsTitle => 'Screen Time';

  @override
  String get screenTimeNotificationsDescription => 'All Notifications for screen time restriction';

  @override
  String get appScreenTimeNotificationsTitle => 'Application Screen Time';

  @override
  String get appScreenTimeNotificationsDescription => 'All Notifications for application screen time restriction';

  @override
  String get frequentAlertsTitle => 'Frequent Alerts Interval';

  @override
  String get frequentAlertsDescription => 'Set interval for frequent notifications (minutes)';

  @override
  String get clearDataTitle => 'Clear Data';

  @override
  String get clearDataDescription => 'Clear all the history and other related data';

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
  String get clearDataDialogContent => 'This will clear all history and related data. You won\'t be able to recover it. Do you want to proceed?';

  @override
  String get clearDataButtonLabel => 'Clear Data';

  @override
  String get resetSettingsDialogTitle => 'Reset Settings?';

  @override
  String get resetSettingsDialogContent => 'This will reset all settings to their default values. Do you want to proceed?';

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
  String get replaceWarningMessage => 'This will replace ALL your existing data. Are you sure you want to continue?';

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
  String get faqSettingsQ4 => 'How can i restore or export my data?';

  @override
  String get faqSettingsA4 => 'You can go to settings, and there you\'ll find Backup & Restore section. You can export or import data from here, note that Exported data file is stored in Documents at Scolect-Backups Folder and only this file can be used to restore data, no other file.';

  @override
  String get faqGeneralQ6 => 'How can I change language and which languages are available, also what if I found that translation is wrong?';

  @override
  String get faqGeneralA6 => 'Language can be changed through Settings General section, all the available languages are listed there, you can request translation by clicking on Contact and sending your request with given language. Just know that translation can be wrong as It is generated by AI from English and if you want to report then either you can report through report bug, or contact, or if you are a developer then open issue on Github. Contributions regarding language are also welcome!';

  @override
  String get faqGeneralQ7 => 'What if I found that translation is wrong?';

  @override
  String get faqGeneralA7 => 'Translation can be wrong as It is Generated by AI from English and if you want to report then either you can report through report bug, or contact, or if you are a developer then open issue on Github. Contributions regarding language are also welcome!';

  @override
  String get activityTrackingSection => 'Activity Tracking';

  @override
  String get idleDetectionTitle => 'Idle Detection';

  @override
  String get idleDetectionDescription => 'Stop tracking when inactive';

  @override
  String get idleTimeoutTitle => 'Idle Timeout';

  @override
  String idleTimeoutDescription(String timeout) {
    return 'Time before considering idle ($timeout)';
  }

  @override
  String get advancedWarning => 'Advanced features may increase resource usage. Enable only if needed.';

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
  String get idleTimeoutDialogDescription => 'Choose how long to wait before considering you idle:';

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
  String get voiceGenderDescription => 'Choose the voice gender for timer notifications';

  @override
  String get voiceGenderMale => 'Male';

  @override
  String get voiceGenderFemale => 'Female';

  @override
  String get alertsLimitsSubtitle => 'Manage your screen time limits and notifications';

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
  String get greetingAfternoon => 'Good afternoon! Here\'s your activity summary.';

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
  String get notification_permission_denied_message => 'ScreenTime needs notification permission to send you alerts and reminders.\n\nWould you like to open System Settings to enable notifications?';

  @override
  String get notification_permission_denied_hint => 'Open System Settings to enable notifications for ScreenTime.';

  @override
  String get notification_permission_required => 'Notification Permission Required';

  @override
  String get notification_permission_required_message => 'ScreenTime needs permission to send you notifications.';

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
  String get enable_notification_permission_hint => 'Enable notification permission to receive alerts';

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
  String get systemNotificationsDisabled => 'System notifications are disabled. Enable them in System Settings for focus alerts.';

  @override
  String get openSystemSettings => 'Open System Settings';

  @override
  String get appNotificationsDisabled => 'Notifications are disabled in app settings. Enable them to receive focus alerts.';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get focusModeNotificationsDisabled => 'Focus mode notifications are disabled. Enable them to receive session alerts.';

  @override
  String get notificationsDisabled => 'Notifications Disabled';

  @override
  String get dontShowAgain => 'Don\'t show again';

  @override
  String get systemSettingsRequired => 'System Settings Required';

  @override
  String get notificationsDisabledSystemLevel => 'Notifications are disabled at the system level. To enable:';

  @override
  String get step1OpenSystemSettings => '1. Open System Settings (System Preferences)';

  @override
  String get step2GoToNotifications => '2. Go to Notifications';

  @override
  String get step3FindApp => '3. Find and select Scolect';

  @override
  String get step4EnableNotifications => '4. Enable \"Allow notifications\"';

  @override
  String get returnToAppMessage => 'Then return to this app and notifications will work.';

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
  String get backgroundColorsLightDesc => 'Main background surfaces for light mode';

  @override
  String get backgroundColorsDarkDesc => 'Main background surfaces for dark mode';

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
  String get sampleSecondaryText => 'This is secondary text that appears below.';

  @override
  String get primary => 'Primary';

  @override
  String get secondary => 'Secondary';

  @override
  String get warning => 'Warning';

  @override
  String get launchAtStartupTitle => 'Launch at startup';

  @override
  String get launchAtStartupDescription => 'Automatically start Scolect when you log in to your computer';

  @override
  String get inputMonitoringPermissionTitle => 'Keyboard Monitoring Unavailable';

  @override
  String get inputMonitoringPermissionDescription => 'Enable Input Monitoring permission to track keyboard activity. Currently only mouse input is monitored.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get permissionGrantedTitle => 'Permission Granted';

  @override
  String get permissionGrantedDescription => 'The app needs to restart for Input Monitoring to take effect.';

  @override
  String get continueButton => 'Continue';

  @override
  String get restartRequiredTitle => 'Restart Required';

  @override
  String get restartRequiredDescription => 'To enable keyboard monitoring, the app needs to restart. This is required by macOS.';

  @override
  String get restartNote => 'The app will automatically relaunch after restarting.';

  @override
  String get restartNow => 'Restart Now';

  @override
  String get restartLater => 'Restart Later';

  @override
  String get restartFailedTitle => 'Restart Failed';

  @override
  String get restartFailedMessage => 'Could not restart the app automatically. Please quit (Cmd+Q) and relaunch manually.';

  @override
  String get exportAnalyticsReport => 'Export Analytics Report';

  @override
  String get chooseExportFormat => 'Choose export format:';

  @override
  String get beautifulExcelReport => 'Beautiful Excel Report';

  @override
  String get beautifulExcelReportDescription => 'Gorgeous, colorful spreadsheet with charts, emojis, and insights ✨';

  @override
  String get excelReportIncludes => 'The Excel report includes:';

  @override
  String get summarySheetDescription => '📊 Summary Sheet - Key metrics with trends';

  @override
  String get dailyBreakdownDescription => '📅 Daily Breakdown - Visual usage patterns';

  @override
  String get appsSheetDescription => '📱 Apps Sheet - Detailed app rankings';

  @override
  String get insightsDescription => '💡 Insights - Smart recommendations';

  @override
  String get beautifulExcelExportSuccess => 'Beautiful Excel report exported successfully! 🎉';

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
  String get insightNoFocusSessions => 'No Focus Sessions: Consider using focus mode to boost your productivity';

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
  String insightMostUsedApp(String appName, String percentage, String duration) {
    return 'Most Used App: $appName accounts for $percentage% of your time ($duration)';
  }

  @override
  String insightUsageVaries(String highDay, String multiplier, String lowDay) {
    return 'Usage Varies Significantly: $highDay had ${multiplier}x more usage than $lowDay';
  }

  @override
  String get insightNoInsights => 'No significant insights available';

  @override
  String get recScheduleFocusSessions => 'Try scheduling more focus sessions throughout your day to boost productivity';

  @override
  String get recSetAppLimits => 'Consider setting app limits on leisure applications';

  @override
  String get recAimForFocusSessions => 'Aim for at least 1-2 focus sessions per day to build a consistent habit';

  @override
  String get recTakeBreaks => 'Your daily screen time is quite high. Try taking regular breaks using the 20-20-20 rule';

  @override
  String get recSetDailyGoals => 'Consider setting daily screen time goals to gradually reduce usage';

  @override
  String get recBalanceEntertainment => 'Entertainment apps account for a large portion of your time. Consider balancing with more productive activities';

  @override
  String get recReviewUsagePatterns => 'Your screen time has increased significantly. Review your usage patterns and set boundaries';

  @override
  String get recScheduleFocusedWork => 'Your productive time has decreased. Try scheduling focused work blocks in your calendar';

  @override
  String get recKeepUpGreatWork => 'Keep up the great work! Your screen time habits look healthy';

  @override
  String get recContinueFocusSessions => 'Continue using focus sessions to maintain productivity';

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
  String get selectJSONFileFromDevice => 'Select a JSON theme file from your device';

  @override
  String get pasteFromClipboard => 'Paste from Clipboard';

  @override
  String get importFromClipboardJSON => 'Import theme from clipboard JSON data';

  @override
  String get importFromFile => 'Import theme from a file';

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
  String get invalidThemeFormat => 'Invalid theme format. Please check the JSON data.';

  @override
  String get trackingModeTitle => 'Tracking Mode';

  @override
  String get trackingModeDescription => 'Choose how app usage is tracked';

  @override
  String get trackingModePolling => 'Standard (Low Resource)';

  @override
  String get trackingModePrecise => 'Precise (High Accuracy)';

  @override
  String get trackingModePollingHint => 'Checks every minute - lower resource usage';

  @override
  String get trackingModePreciseHint => 'Real-time tracking - higher accuracy, more resources';

  @override
  String get trackingModeChangeError => 'Failed to change tracking mode. Please try again.';

  @override
  String get errorTitle => 'Error';

  @override
  String get monitorKeyboardTitle => 'Monitor Keyboard';

  @override
  String get monitorKeyboardDescription => 'Track keyboard activity to detect user presence';

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
  String get changelogErrorDescription => 'Could not retrieve the changelog for this version. Please check your internet connection or visit the GitHub releases page.';

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
}
