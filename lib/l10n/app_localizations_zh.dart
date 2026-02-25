// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appWindowTitle => 'Scolect - 屏幕时间和应用使用追踪';

  @override
  String get appName => 'Scolect';

  @override
  String get appTitle => '高效屏幕时间';

  @override
  String get sidebarTitle => '屏幕时间';

  @override
  String get sidebarSubtitle => '开源软件';

  @override
  String get trayShowWindow => '显示窗口';

  @override
  String get trayStartFocusMode => '开始专注模式';

  @override
  String get trayStopFocusMode => '停止专注模式';

  @override
  String get trayReports => '报告';

  @override
  String get trayAlertsLimits => '提醒与限制';

  @override
  String get trayApplications => '应用程序';

  @override
  String get trayDisableNotifications => '关闭通知';

  @override
  String get trayEnableNotifications => '开启通知';

  @override
  String get trayVersionPrefix => '版本：';

  @override
  String trayVersion(String version) {
    return '版本：$version';
  }

  @override
  String get trayExit => '退出';

  @override
  String get navOverview => '概览';

  @override
  String get navApplications => '应用程序';

  @override
  String get navAlertsLimits => '提醒与限制';

  @override
  String get navReports => '报告';

  @override
  String get navFocusMode => '专注模式';

  @override
  String get navSettings => '设置';

  @override
  String get navHelp => '帮助';

  @override
  String get helpTitle => '帮助';

  @override
  String get faqCategoryGeneral => '常见问题';

  @override
  String get faqCategoryApplications => '应用程序管理';

  @override
  String get faqCategoryReports => '使用分析与报告';

  @override
  String get faqCategoryAlerts => '提醒与限制';

  @override
  String get faqCategoryFocusMode => '专注模式与番茄钟';

  @override
  String get faqCategorySettings => '设置与个性化';

  @override
  String get faqCategoryTroubleshooting => '故障排除';

  @override
  String get faqGeneralQ1 => '这个应用如何追踪屏幕时间？';

  @override
  String get faqGeneralA1 => '该应用实时监控您设备的使用情况，追踪在不同应用上花费的时间。它提供关于您数字习惯的全面分析，包括总屏幕时间、高效时间和特定应用的使用情况。';

  @override
  String get faqGeneralQ2 => '什么使应用被认为是\"高效\"的？';

  @override
  String get faqGeneralA2 => '您可以在\"应用程序\"部分手动将应用标记为高效。高效应用会计入您的高效分数，该分数计算花在工作相关或有益应用上的屏幕时间百分比。';

  @override
  String get faqGeneralQ3 => '屏幕时间追踪有多准确？';

  @override
  String get faqGeneralA3 => '该应用使用系统级追踪来精确测量您的设备使用情况。它以最小的电池影响捕获每个应用的前台使用时间。';

  @override
  String get faqGeneralQ4 => '我可以自定义应用分类吗？';

  @override
  String get faqGeneralA4 => '当然可以！您可以创建自定义类别，将应用分配到特定类别，并在\"应用程序\"部分轻松修改这些分配。这有助于创建更有意义的使用分析。';

  @override
  String get faqGeneralQ5 => '我可以从这个应用获得什么洞察？';

  @override
  String get faqGeneralA5 => '该应用提供全面的洞察，包括高效分数、按时间段的使用模式、详细的应用使用情况、专注会话追踪，以及图表和饼图等可视化分析，帮助您了解和改善您的数字习惯。';

  @override
  String get faqAppsQ1 => '如何隐藏特定应用的追踪？';

  @override
  String get faqAppsA1 => '在\"应用程序\"部分，您可以切换应用的可见性。';

  @override
  String get faqAppsQ2 => '我可以搜索和筛选我的应用吗？';

  @override
  String get faqAppsA2 => '是的，应用程序部分包含搜索功能和筛选选项。您可以按类别、高效状态、追踪状态和可见性筛选应用。';

  @override
  String get faqAppsQ3 => '应用有哪些编辑选项？';

  @override
  String get faqAppsA3 => '对于每个应用，您可以编辑：类别分配、高效状态、使用追踪、报告可见性，以及设置单独的每日时间限制。';

  @override
  String get faqAppsQ4 => '应用类别是如何确定的？';

  @override
  String get faqAppsA4 => '初始类别由系统建议，但您可以完全控制根据您的工作流程和偏好创建、修改和分配自定义类别。';

  @override
  String get faqReportsQ1 => '有哪些类型的报告？';

  @override
  String get faqReportsA1 => '报告包括：总屏幕时间、高效时间、最常用应用、专注会话、每日屏幕时间图表、类别分布饼图、详细应用使用情况、每周使用趋势，以及按时间段的使用模式分析。';

  @override
  String get faqReportsQ2 => '应用使用报告有多详细？';

  @override
  String get faqReportsA2 => '详细的应用使用报告显示：应用名称、类别、总使用时间、高效状态，并提供\"操作\"部分，包含更深入的洞察，如使用摘要、每日限制、使用趋势和高效指标。';

  @override
  String get faqReportsQ3 => '我可以分析我的长期使用趋势吗？';

  @override
  String get faqReportsA3 => '可以！该应用提供周对周比较，显示过去几周的使用图表、平均每日使用量、最长会话和每周总量，帮助您追踪您的数字习惯。';

  @override
  String get faqReportsQ4 => '什么是\"使用模式\"分析？';

  @override
  String get faqReportsA4 => '使用模式将您的屏幕时间分为早晨、下午、傍晚和夜间几个时段。这有助于您了解何时在设备上最活跃，并识别潜在的改进领域。';

  @override
  String get faqAlertsQ1 => '屏幕时间限制有多精细？';

  @override
  String get faqAlertsA1 => '您可以设置整体每日屏幕时间限制和单个应用限制。限制可以按小时和分钟配置，并可根据需要重置或调整。';

  @override
  String get faqAlertsQ2 => '有哪些通知选项？';

  @override
  String get faqAlertsA2 => '该应用提供多种通知类型：超出屏幕时间时的系统提醒、可自定义间隔（1、5、15、30或60分钟）的频繁提醒，以及专注模式、屏幕时间和特定应用通知的开关。';

  @override
  String get faqAlertsQ3 => '我可以自定义限制提醒吗？';

  @override
  String get faqAlertsA3 => '是的，您可以自定义提醒频率、启用/禁用特定类型的提醒，并为整体屏幕时间和单个应用设置不同的限制。';

  @override
  String get faqFocusQ1 => '有哪些类型的专注模式？';

  @override
  String get faqFocusA1 => '可用模式包括深度工作（较长的专注会话）、快速任务（短时间工作）和阅读模式。每种模式都有助于您有效地安排工作和休息时间。';

  @override
  String get faqFocusQ2 => '番茄钟有多灵活？';

  @override
  String get faqFocusA2 => '计时器高度可定制。您可以调整工作时长、短休息时长和长休息时长。其他选项包括自动开始下一个会话和通知设置。';

  @override
  String get faqFocusQ3 => '专注模式历史记录显示什么？';

  @override
  String get faqFocusA3 => '专注模式历史记录追踪每日专注会话，显示每天的会话数量、趋势图表、平均会话时长、总专注时间，以及分解工作会话、短休息和长休息的时间分布饼图。';

  @override
  String get faqFocusQ4 => '我可以追踪专注会话的进度吗？';

  @override
  String get faqFocusA4 => '该应用具有圆形计时器界面，带有播放/暂停、重置和设置按钮。您可以通过直观的控件轻松追踪和管理您的专注会话。';

  @override
  String get faqSettingsQ1 => '有哪些自定义选项？';

  @override
  String get faqSettingsA1 => '自定义选项包括主题选择（系统、浅色、深色）、语言设置、启动行为、全面的通知控制，以及清除数据或重置设置等数据管理选项。';

  @override
  String get faqSettingsQ2 => '如何提供反馈或报告问题？';

  @override
  String get faqSettingsA2 => '在设置部分底部，您会找到报告错误、提交反馈或联系支持的按钮。这些将引导您到相应的支持渠道。';

  @override
  String get faqSettingsQ3 => '清除数据会发生什么？';

  @override
  String get faqSettingsA3 => '清除数据将重置所有使用统计、专注会话历史和自定义设置。这对于重新开始或故障排除很有用。';

  @override
  String get faqTroubleQ1 => '数据不显示，hive无法打开错误';

  @override
  String get faqTroubleA1 => '这是一个已知问题，临时解决方案是通过设置清除数据，如果不起作用，请转到\"文档\"并删除以下文件（如果存在）- harman_screentime_app_usage_box.hive 和 harman_screentime_app_usage.lock，同时建议您将应用更新到最新版本。';

  @override
  String get faqTroubleQ2 => '应用在每次启动时都会打开，该怎么办？';

  @override
  String get faqTroubleA2 => '这是Windows 10上的一个已知问题，临时解决方案是在设置中启用\"启动时最小化\"，这样它将以最小化方式启动。';

  @override
  String get usageAnalytics => '使用分析';

  @override
  String get last7Days => '最近7天';

  @override
  String get lastMonth => '最近一个月';

  @override
  String get last3Months => '最近3个月';

  @override
  String get lifetime => '全部时间';

  @override
  String get custom => '自定义';

  @override
  String get loadingAnalyticsData => '正在加载分析数据...';

  @override
  String get tryAgain => '重试';

  @override
  String get failedToInitialize => '初始化分析失败。请重新启动应用程序。';

  @override
  String unexpectedError(String error) {
    return '发生意外错误：$error。请稍后再试。';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return '加载分析数据时出错：$error。请检查您的连接并重试。';
  }

  @override
  String get customDialogTitle => '自定义';

  @override
  String get dateRange => '日期范围：';

  @override
  String get specificDate => '特定日期';

  @override
  String get startDate => '开始日期：';

  @override
  String get endDate => '结束日期：';

  @override
  String get date => '日期';

  @override
  String get cancel => '取消';

  @override
  String get apply => '应用';

  @override
  String get ok => '确定';

  @override
  String get invalidDateRange => '无效的日期范围';

  @override
  String get startDateBeforeEndDate => '开始日期必须早于或等于结束日期。';

  @override
  String get totalScreenTime => '总屏幕使用时间';

  @override
  String get productiveTime => '高效时间';

  @override
  String get mostUsedApp => '最常用应用';

  @override
  String get focusSessions => '专注会话';

  @override
  String positiveComparison(String percent) {
    return '+$percent% 相比上一周期';
  }

  @override
  String negativeComparison(String percent) {
    return '$percent% 相比上一周期';
  }

  @override
  String iconLabel(String title) {
    return '$title图标';
  }

  @override
  String get dailyScreenTime => '每日屏幕使用时间';

  @override
  String get categoryBreakdown => '类别分布';

  @override
  String get noDataAvailable => '暂无数据';

  @override
  String sectionLabel(String title) {
    return '$title部分';
  }

  @override
  String get detailedApplicationUsage => '详细应用使用情况';

  @override
  String get searchApplications => '搜索应用';

  @override
  String get nameHeader => '名称';

  @override
  String get categoryHeader => '类别';

  @override
  String get totalTimeHeader => '总时间';

  @override
  String get productivityHeader => '高效性';

  @override
  String get actionsHeader => '操作';

  @override
  String sortByOption(String option) {
    return '排序方式：$option';
  }

  @override
  String get sortByName => '名称';

  @override
  String get sortByCategory => '类别';

  @override
  String get sortByUsage => '使用量';

  @override
  String get productive => '高效';

  @override
  String get nonProductive => '非高效';

  @override
  String get noApplicationsMatch => '没有应用符合您的搜索条件';

  @override
  String get viewDetails => '查看详情';

  @override
  String get usageSummary => '使用摘要';

  @override
  String get usageOverPastWeek => '过去一周的使用情况';

  @override
  String get usagePatternByTimeOfDay => '按时段的使用模式';

  @override
  String get patternAnalysis => '模式分析';

  @override
  String get today => '今天';

  @override
  String get dailyLimit => '每日限制';

  @override
  String get noLimit => '无限制';

  @override
  String get usageTrend => '使用趋势';

  @override
  String get productivity => '高效性';

  @override
  String get increasing => '增加';

  @override
  String get decreasing => '减少';

  @override
  String get stable => '稳定';

  @override
  String get avgDailyUsage => '日均使用';

  @override
  String get longestSession => '最长时段';

  @override
  String get weeklyTotal => '每周总计';

  @override
  String get noHistoricalData => '暂无历史数据';

  @override
  String get morning => '早晨 (6-12)';

  @override
  String get afternoon => '下午 (12-5)';

  @override
  String get evening => '傍晚 (5-9)';

  @override
  String get night => '夜间 (9-6)';

  @override
  String get usageInsights => '使用洞察';

  @override
  String get limitStatus => '限制状态';

  @override
  String get close => '关闭';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return '您主要在$timeOfDay使用$appName。';
  }

  @override
  String significantIncrease(String percentage) {
    return '与上一周期相比，您的使用量显著增加了（$percentage%）。';
  }

  @override
  String get trendingUpward => '与上一周期相比，您的使用量呈上升趋势。';

  @override
  String significantDecrease(String percentage) {
    return '与上一周期相比，您的使用量显著减少了（$percentage%）。';
  }

  @override
  String get trendingDownward => '与上一周期相比，您的使用量呈下降趋势。';

  @override
  String get consistentUsage => '与上一周期相比，您的使用量保持一致。';

  @override
  String get markedAsProductive => '这在您的设置中被标记为高效应用。';

  @override
  String get markedAsNonProductive => '这在您的设置中被标记为非高效应用。';

  @override
  String mostActiveTime(String time) {
    return '您最活跃的时间是$time左右。';
  }

  @override
  String get noLimitSet => '此应用未设置使用限制。';

  @override
  String get limitReached => '您已达到此应用的每日限制。';

  @override
  String aboutToReachLimit(String remainingTime) {
    return '您即将达到每日限制，仅剩$remainingTime。';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return '您已使用每日限制的$percent%，剩余$remainingTime。';
  }

  @override
  String remainingTime(String time) {
    return '您的每日限制还剩$time。';
  }

  @override
  String get todayChart => '今天';

  @override
  String hourPeriodAM(int hour) {
    return '上午$hour点';
  }

  @override
  String hourPeriodPM(int hour) {
    return '下午$hour点';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours小时$minutes分钟';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '$minutes分钟';
  }

  @override
  String get alertsLimitsTitle => '提醒与限制';

  @override
  String get notificationsSettings => '通知设置';

  @override
  String get overallScreenTimeLimit => '总屏幕时间限制';

  @override
  String get applicationLimits => '应用限制';

  @override
  String get popupAlerts => '弹出提醒';

  @override
  String get frequentAlerts => '频繁提醒';

  @override
  String get soundAlerts => '声音提醒';

  @override
  String get systemAlerts => '系统提醒';

  @override
  String get dailyTotalLimit => '每日总限制：';

  @override
  String get hours => '小时';

  @override
  String get minutes => '分钟';

  @override
  String get currentUsage => '当前使用：';

  @override
  String get tableName => '名称';

  @override
  String get tableCategory => '类别';

  @override
  String get tableDailyLimit => '每日限制';

  @override
  String get tableCurrentUsage => '当前使用';

  @override
  String get tableStatus => '状态';

  @override
  String get tableActions => '操作';

  @override
  String get addLimit => '添加限制';

  @override
  String get noApplicationsToDisplay => '没有可显示的应用';

  @override
  String get statusActive => '活跃';

  @override
  String get statusOff => '关闭';

  @override
  String get durationNone => '无';

  @override
  String get addApplicationLimit => '添加应用限制';

  @override
  String get selectApplication => '选择应用';

  @override
  String get selectApplicationPlaceholder => '选择一个应用';

  @override
  String get enableLimit => '启用限制：';

  @override
  String editLimitTitle(String appName) {
    return '编辑限制：$appName';
  }

  @override
  String failedToLoadData(String error) {
    return '加载数据失败：$error';
  }

  @override
  String get resetSettingsTitle => '重置设置？';

  @override
  String get resetSettingsContent => '如果重置设置，您将无法恢复。确定要重置吗？';

  @override
  String get resetAll => '全部重置';

  @override
  String get refresh => '刷新';

  @override
  String get save => '保存';

  @override
  String get add => '添加';

  @override
  String get error => '错误';

  @override
  String get retry => '重试';

  @override
  String get applicationsTitle => '应用程序';

  @override
  String get searchApplication => '搜索应用';

  @override
  String get tracking => '已跟踪';

  @override
  String get hiddenVisible => '隐藏/可见';

  @override
  String get selectCategory => '选择类别';

  @override
  String get allCategories => '全部';

  @override
  String get tableScreenTime => '屏幕时间';

  @override
  String get tableTracking => '追踪';

  @override
  String get tableHidden => '隐藏';

  @override
  String get tableEdit => '编辑';

  @override
  String editAppTitle(String appName) {
    return '编辑 $appName';
  }

  @override
  String get categorySection => '类别';

  @override
  String get customCategory => '自定义';

  @override
  String get customCategoryPlaceholder => '输入自定义类别名称';

  @override
  String get uncategorized => '未分类';

  @override
  String get isProductive => '是否高效';

  @override
  String get trackUsage => '追踪使用';

  @override
  String get visibleInReports => '在报告中可见';

  @override
  String get timeLimitsSection => '时间限制';

  @override
  String get enableDailyLimit => '启用每日限制';

  @override
  String get setDailyTimeLimit => '设置每日时间限制：';

  @override
  String get saveChanges => '保存更改';

  @override
  String errorLoadingData(String error) {
    return '加载概览数据时出错：$error';
  }

  @override
  String get focusModeTitle => '专注模式';

  @override
  String get historySection => '历史记录';

  @override
  String get trendsSection => '趋势';

  @override
  String get timeDistributionSection => '时间分布';

  @override
  String get sessionHistorySection => '会话历史';

  @override
  String get workSession => '工作会话';

  @override
  String get shortBreak => '短休息';

  @override
  String get longBreak => '长休息';

  @override
  String get dateHeader => '日期';

  @override
  String get durationHeader => '时长';

  @override
  String get monday => '星期一';

  @override
  String get tuesday => '星期二';

  @override
  String get wednesday => '星期三';

  @override
  String get thursday => '星期四';

  @override
  String get friday => '星期五';

  @override
  String get saturday => '星期六';

  @override
  String get sunday => '星期日';

  @override
  String get focusModeSettingsTitle => '专注模式设置';

  @override
  String get modeCustom => '自定义';

  @override
  String get modeDeepWork => '深度工作 (60分钟)';

  @override
  String get modeQuickTasks => '快速任务 (25分钟)';

  @override
  String get modeReading => '阅读 (45分钟)';

  @override
  String workDurationLabel(int minutes) {
    return '工作时长：$minutes分钟';
  }

  @override
  String shortBreakLabel(int minutes) {
    return '短休息';
  }

  @override
  String longBreakLabel(int minutes) {
    return '长休息';
  }

  @override
  String get autoStartNextSession => '自动开始下一个会话';

  @override
  String get blockDistractions => '专注模式期间屏蔽干扰';

  @override
  String get enableNotifications => '启用通知';

  @override
  String get saved => '已保存';

  @override
  String errorLoadingFocusModeData(String error) {
    return '加载专注模式数据时出错：$error';
  }

  @override
  String get overviewTitle => '今日概览';

  @override
  String get startFocusMode => '开始专注模式';

  @override
  String get loadingProductivityData => '正在加载您的生产力数据...';

  @override
  String get noActivityDataAvailable => '暂无活动数据';

  @override
  String get startUsingApplications => '开始使用您的应用程序来追踪屏幕时间和生产力。';

  @override
  String get refreshData => '刷新数据';

  @override
  String get topApplications => '常用应用';

  @override
  String get noAppUsageDataAvailable => '暂无应用使用数据';

  @override
  String get noApplicationDataAvailable => '暂无应用数据';

  @override
  String get noCategoryDataAvailable => '暂无类别数据';

  @override
  String get noApplicationLimitsSet => '未设置应用限制';

  @override
  String get screenLabel => '屏幕';

  @override
  String get timeLabel => '时间';

  @override
  String get productiveLabel => '高效';

  @override
  String get scoreLabel => '分数';

  @override
  String get defaultNone => '无';

  @override
  String get defaultTime => '0小时0分钟';

  @override
  String get defaultCount => '0';

  @override
  String get unknownApp => '未知';

  @override
  String get settingsTitle => '设置';

  @override
  String get generalSection => '通用';

  @override
  String get notificationsSection => '通知';

  @override
  String get dataSection => '数据';

  @override
  String get versionSection => '版本';

  @override
  String get languageTitle => '语言';

  @override
  String get languageDescription => '应用程序的语言';

  @override
  String get startupBehaviourTitle => '启动行为';

  @override
  String get startupBehaviourDescription => '随系统启动';

  @override
  String get launchMinimizedTitle => '启动时最小化';

  @override
  String get launchMinimizedDescription => '在系统托盘中启动应用程序（推荐Windows 10用户使用）';

  @override
  String get notificationsTitle => '通知';

  @override
  String get notificationsAllDescription => '应用程序的所有通知';

  @override
  String get focusModeNotificationsTitle => '专注模式';

  @override
  String get focusModeNotificationsDescription => '专注模式的所有通知';

  @override
  String get screenTimeNotificationsTitle => '屏幕时间';

  @override
  String get screenTimeNotificationsDescription => '屏幕时间限制的所有通知';

  @override
  String get appScreenTimeNotificationsTitle => '应用屏幕时间';

  @override
  String get appScreenTimeNotificationsDescription => '应用屏幕时间限制的所有通知';

  @override
  String get frequentAlertsTitle => '频繁提醒间隔';

  @override
  String get frequentAlertsDescription => '设置频繁通知的间隔（分钟）';

  @override
  String get clearDataTitle => '清除数据';

  @override
  String get clearDataDescription => '清除所有历史记录和相关数据';

  @override
  String get resetSettingsTitle2 => '重置设置';

  @override
  String get resetSettingsDescription => '重置所有设置';

  @override
  String get versionTitle => '版本';

  @override
  String get versionDescription => '应用程序的当前版本';

  @override
  String get contactButton => '联系我们';

  @override
  String get reportBugButton => '报告错误';

  @override
  String get submitFeedbackButton => '提交反馈';

  @override
  String get githubButton => 'Github';

  @override
  String get clearDataDialogTitle => '清除数据？';

  @override
  String get clearDataDialogContent => '这将清除所有历史记录和相关数据。您将无法恢复。确定要继续吗？';

  @override
  String get clearDataButtonLabel => '清除数据';

  @override
  String get resetSettingsDialogTitle => '重置设置？';

  @override
  String get resetSettingsDialogContent => '这将把所有设置重置为默认值。确定要继续吗？';

  @override
  String get resetButtonLabel => '重置';

  @override
  String get cancelButton => '取消';

  @override
  String couldNotLaunchUrl(String url) {
    return '无法打开 $url';
  }

  @override
  String errorMessage(String message) {
    return '错误：$message';
  }

  @override
  String get chart_focusTrends => '专注趋势';

  @override
  String get chart_sessionCount => '会话数量';

  @override
  String get chart_avgDuration => '平均时长';

  @override
  String get chart_totalFocus => '总专注时间';

  @override
  String get chart_yAxis_sessions => '会话';

  @override
  String get chart_yAxis_minutes => '分钟';

  @override
  String get chart_yAxis_value => '数值';

  @override
  String get chart_monthOverMonthChange => '月环比变化：';

  @override
  String get chart_customRange => '自定义范围';

  @override
  String get day_monday => '星期一';

  @override
  String get day_mondayShort => '周一';

  @override
  String get day_mondayAbbr => '一';

  @override
  String get day_tuesday => '星期二';

  @override
  String get day_tuesdayShort => '周二';

  @override
  String get day_tuesdayAbbr => '二';

  @override
  String get day_wednesday => '星期三';

  @override
  String get day_wednesdayShort => '周三';

  @override
  String get day_wednesdayAbbr => '三';

  @override
  String get day_thursday => '星期四';

  @override
  String get day_thursdayShort => '周四';

  @override
  String get day_thursdayAbbr => '四';

  @override
  String get day_friday => '星期五';

  @override
  String get day_fridayShort => '周五';

  @override
  String get day_fridayAbbr => '五';

  @override
  String get day_saturday => '星期六';

  @override
  String get day_saturdayShort => '周六';

  @override
  String get day_saturdayAbbr => '六';

  @override
  String get day_sunday => '星期日';

  @override
  String get day_sundayShort => '周日';

  @override
  String get day_sundayAbbr => '日';

  @override
  String time_hours(int count) {
    return '$count小时';
  }

  @override
  String time_hoursMinutes(int hours, int minutes) {
    return '$hours小时$minutes分钟';
  }

  @override
  String time_minutesFormat(String count) {
    return '$count分钟';
  }

  @override
  String tooltip_dateScreenTime(String date, int hours, int minutes) {
    return '$date：$hours小时$minutes分钟';
  }

  @override
  String tooltip_hoursFormat(String count) {
    return '$count小时';
  }

  @override
  String get month_january => '一月';

  @override
  String get month_januaryShort => '1月';

  @override
  String get month_february => '二月';

  @override
  String get month_februaryShort => '2月';

  @override
  String get month_march => '三月';

  @override
  String get month_marchShort => '3月';

  @override
  String get month_april => '四月';

  @override
  String get month_aprilShort => '4月';

  @override
  String get month_may => '五月';

  @override
  String get month_mayShort => '5月';

  @override
  String get month_june => '六月';

  @override
  String get month_juneShort => '6月';

  @override
  String get month_july => '七月';

  @override
  String get month_julyShort => '7月';

  @override
  String get month_august => '八月';

  @override
  String get month_augustShort => '8月';

  @override
  String get month_september => '九月';

  @override
  String get month_septemberShort => '9月';

  @override
  String get month_october => '十月';

  @override
  String get month_octoberShort => '10月';

  @override
  String get month_november => '十一月';

  @override
  String get month_novemberShort => '11月';

  @override
  String get month_december => '十二月';

  @override
  String get month_decemberShort => '12月';

  @override
  String get categoryAll => '全部';

  @override
  String get categoryProductivity => '生产力';

  @override
  String get categoryDevelopment => '开发';

  @override
  String get categorySocialMedia => '社交媒体';

  @override
  String get categoryEntertainment => '娱乐';

  @override
  String get categoryGaming => '游戏';

  @override
  String get categoryCommunication => '通讯';

  @override
  String get categoryWebBrowsing => '网页浏览';

  @override
  String get categoryCreative => '创意';

  @override
  String get categoryEducation => '教育';

  @override
  String get categoryUtility => '实用工具';

  @override
  String get categoryUncategorized => '未分类';

  @override
  String get appMicrosoftWord => 'Microsoft Word';

  @override
  String get appExcel => 'Excel';

  @override
  String get appPowerPoint => 'PowerPoint';

  @override
  String get appGoogleDocs => 'Google 文档';

  @override
  String get appNotion => 'Notion';

  @override
  String get appEvernote => '印象笔记';

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
  String get appGoogleCalendar => 'Google 日历';

  @override
  String get appAppleCalendar => '日历';

  @override
  String get appVisualStudioCode => 'Visual Studio Code';

  @override
  String get appTerminal => '终端';

  @override
  String get appCommandPrompt => '命令提示符';

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
  String get appCalculator => '计算器';

  @override
  String get appNotes => '备忘录';

  @override
  String get appSystemPreferences => '系统偏好设置';

  @override
  String get appTaskManager => '任务管理器';

  @override
  String get appFileExplorer => '文件资源管理器';

  @override
  String get appDropbox => 'Dropbox';

  @override
  String get appGoogleDrive => 'Google 云端硬盘';

  @override
  String get loadingApplication => '正在加载应用...';

  @override
  String get loadingData => '正在加载数据...';

  @override
  String get reportsError => '错误';

  @override
  String get reportsRetry => '重试';

  @override
  String get backupRestoreSection => '备份与恢复';

  @override
  String get backupRestoreTitle => '备份与恢复';

  @override
  String get exportDataTitle => '导出数据';

  @override
  String get exportDataDescription => '创建所有数据的备份';

  @override
  String get importDataTitle => '导入数据';

  @override
  String get importDataDescription => '从备份文件恢复';

  @override
  String get exportButton => '导出';

  @override
  String get importButton => '导入';

  @override
  String get closeButton => '关闭';

  @override
  String get noButton => '否';

  @override
  String get shareButton => '分享';

  @override
  String get exportStarting => '正在开始导出...';

  @override
  String get exportSuccessful => '导出成功';

  @override
  String get exportFailed => '导出失败';

  @override
  String get exportComplete => '导出完成';

  @override
  String get shareBackupQuestion => '您想分享备份文件吗？';

  @override
  String get importStarting => '正在开始导入...';

  @override
  String get importSuccessful => '导入成功！';

  @override
  String get importFailed => '导入失败';

  @override
  String get importOptionsTitle => '导入选项';

  @override
  String get importOptionsQuestion => '您想如何导入数据？';

  @override
  String get replaceModeTitle => '替换';

  @override
  String get replaceModeDescription => '替换所有现有数据';

  @override
  String get mergeModeTitle => '合并';

  @override
  String get mergeModeDescription => '与现有数据合并';

  @override
  String get appendModeTitle => '追加';

  @override
  String get appendModeDescription => '仅添加新记录';

  @override
  String get warningTitle => '⚠️ 警告';

  @override
  String get replaceWarningMessage => '这将替换您所有的现有数据。您确定要继续吗？';

  @override
  String get replaceAllButton => '全部替换';

  @override
  String get fileLabel => '文件';

  @override
  String get sizeLabel => '大小';

  @override
  String get recordsLabel => '记录';

  @override
  String get usageRecordsLabel => '使用记录';

  @override
  String get focusSessionsLabel => '专注时段';

  @override
  String get appMetadataLabel => '应用元数据';

  @override
  String get updatedLabel => '已更新';

  @override
  String get skippedLabel => '已跳过';

  @override
  String get faqSettingsQ4 => '我如何恢复或导出我的数据？';

  @override
  String get faqSettingsA4 => '您可以进入设置，在那里您会找到备份与恢复部分。您可以在这里导出或导入数据。请注意，导出的数据文件存储在文档的 Scolect-Backups 文件夹中，只有这个文件可以用于恢复数据，其他文件不可以。';

  @override
  String get faqGeneralQ6 => '我如何更改语言？有哪些可用的语言？如果我发现翻译有误怎么办？';

  @override
  String get faqGeneralA6 => '语言可以在设置的通用部分进行更改，所有可用的语言都列在那里。您可以点击联系并发送您的请求和所需语言来请求翻译。请注意，翻译可能存在错误，因为它是由人工智能从英语生成的。如果您想报告问题，可以通过报告错误、联系我们，或者如果您是开发者，可以在 Github 上提交问题。我们也欢迎关于语言的贡献！';

  @override
  String get faqGeneralQ7 => '如果我发现翻译有误怎么办？';

  @override
  String get faqGeneralA7 => '翻译可能存在错误，因为它是由人工智能从英语生成的。如果您想报告问题，可以通过报告错误、联系我们，或者如果您是开发者，可以在 Github 上提交问题。我们也欢迎关于语言的贡献！';

  @override
  String get activityTrackingSection => '活动追踪';

  @override
  String get idleDetectionTitle => '空闲检测';

  @override
  String get idleDetectionDescription => '在不活动时停止追踪';

  @override
  String get idleTimeoutTitle => '空闲超时';

  @override
  String idleTimeoutDescription(String timeout) {
    return '视为空闲前的等待时间（$timeout）';
  }

  @override
  String get advancedWarning => '高级功能可能会增加资源使用量。仅在需要时启用。';

  @override
  String get monitorAudioTitle => '监控系统音频';

  @override
  String get monitorAudioDescription => '通过音频播放检测活动';

  @override
  String get audioSensitivityTitle => '音频灵敏度';

  @override
  String audioSensitivityDescription(String value) {
    return '检测阈值（$value）';
  }

  @override
  String get monitorControllersTitle => '监控游戏控制器';

  @override
  String get monitorControllersDescription => '检测Xbox/XInput控制器';

  @override
  String get monitorHIDTitle => '监控HID设备';

  @override
  String get monitorHIDDescription => '检测方向盘、数位板、自定义设备';

  @override
  String get setIdleTimeoutTitle => '设置空闲超时';

  @override
  String get idleTimeoutDialogDescription => '选择在将您视为空闲之前等待多长时间：';

  @override
  String get seconds30 => '30秒';

  @override
  String get minute1 => '1分钟';

  @override
  String get minutes2 => '2分钟';

  @override
  String get minutes5 => '5分钟';

  @override
  String get minutes10 => '10分钟';

  @override
  String get customOption => '自定义';

  @override
  String get customDurationTitle => '自定义时长';

  @override
  String get minutesLabel => '分钟';

  @override
  String get secondsLabel => '秒';

  @override
  String get minAbbreviation => '分';

  @override
  String get secAbbreviation => '秒';

  @override
  String totalLabel(String duration) {
    return '总计：$duration';
  }

  @override
  String minimumError(String value) {
    return '最小值为$value';
  }

  @override
  String maximumError(String value) {
    return '最大值为$value';
  }

  @override
  String rangeInfo(String min, String max) {
    return '范围：$min - $max';
  }

  @override
  String get saveButton => '保存';

  @override
  String timeFormatSeconds(int seconds) {
    return '$seconds秒';
  }

  @override
  String get timeFormatMinute => '1分钟';

  @override
  String timeFormatMinutes(int minutes) {
    return '$minutes分钟';
  }

  @override
  String timeFormatMinutesSeconds(int minutes, int seconds) {
    return '$minutes分$seconds秒';
  }

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystem => '系统';

  @override
  String get themeTitle => '主题';

  @override
  String get themeDescription => '应用程序的颜色主题';

  @override
  String get voiceGenderTitle => '语音性别';

  @override
  String get voiceGenderDescription => '选择计时器通知的语音性别';

  @override
  String get voiceGenderMale => '男性';

  @override
  String get voiceGenderFemale => '女性';

  @override
  String get alertsLimitsSubtitle => '管理您的屏幕时间限制和通知';

  @override
  String get applicationsSubtitle => '管理您跟踪的应用程序';

  @override
  String applicationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个应用程序',
    );
    return '$_temp0';
  }

  @override
  String get noApplicationsFound => '未找到应用程序';

  @override
  String get tryAdjustingFilters => '尝试调整您的筛选条件';

  @override
  String get configureAppSettings => '配置应用程序设置';

  @override
  String get behaviorSection => '行为';

  @override
  String helpSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '跨 7 个类别的 $count 个问题',
    );
    return '$_temp0';
  }

  @override
  String get searchForHelp => '搜索帮助...';

  @override
  String get quickNavGeneral => '常规';

  @override
  String get quickNavApps => '应用';

  @override
  String get quickNavReports => '报告';

  @override
  String get quickNavFocus => '专注';

  @override
  String get noResultsFound => '未找到结果';

  @override
  String get tryDifferentKeywords => '尝试使用不同的关键词搜索';

  @override
  String get clearSearch => '清除搜索';

  @override
  String get greetingMorning => '早上好！这是您的活动摘要。';

  @override
  String get greetingAfternoon => '下午好！这是您的活动摘要。';

  @override
  String get greetingEvening => '晚上好！这是您的活动摘要。';

  @override
  String get screenTimeProgress => '屏幕\n时间';

  @override
  String get productiveScoreProgress => '生产力\n分数';

  @override
  String get focusModeSubtitle => '保持专注，提高效率';

  @override
  String get thisWeek => '本周';

  @override
  String get sessions => '使用时段';

  @override
  String get totalTime => '总时间';

  @override
  String get avgLength => '平均时长';

  @override
  String get focusTime => '专注时间';

  @override
  String get paused => '已暂停';

  @override
  String get shortBreakStatus => '短休息';

  @override
  String get longBreakStatus => '长休息';

  @override
  String get readyToFocus => '准备专注';

  @override
  String get focus => '专注';

  @override
  String get restartSession => '重新开始会话';

  @override
  String get skipToNext => '跳到下一个';

  @override
  String get settings => '设置';

  @override
  String sessionsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已完成 $count 个会话',
    );
    return '$_temp0';
  }

  @override
  String get focusModePreset => '专注模式预设';

  @override
  String get focusDuration => '专注时长';

  @override
  String minutesFormat(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String get shortBreakDuration => '短休息';

  @override
  String get longBreakDuration => '长休息';

  @override
  String get enableSounds => '启用声音';

  @override
  String get focus_mode_this_week => '本周';

  @override
  String get focus_mode_best_day => '最佳日';

  @override
  String focus_mode_sessions_count(int count) {
    return '$count 个会话';
  }

  @override
  String get focus_mode_no_data_yet => '暂无数据';

  @override
  String get chart_current => '当前';

  @override
  String get chart_previous => '之前';

  @override
  String get permission_error => '权限错误';

  @override
  String get notification_permission_denied => '通知权限被拒绝';

  @override
  String get notification_permission_denied_message => 'ScreenTime 需要通知权限来向您发送提醒和警报。\n\n您想打开系统设置以启用通知吗？';

  @override
  String get notification_permission_denied_hint => '打开系统设置以启用 ScreenTime 的通知。';

  @override
  String get notification_permission_required => '需要通知权限';

  @override
  String get notification_permission_required_message => 'ScreenTime 需要权限才能向您发送通知。';

  @override
  String get open_settings => '打开设置';

  @override
  String get allow_notifications => '允许通知';

  @override
  String get permission_allowed => '已允许';

  @override
  String get permission_denied => '已拒绝';

  @override
  String get permission_not_set => '未设置';

  @override
  String get on => '开';

  @override
  String get off => '关';

  @override
  String get enable_notification_permission_hint => '启用通知权限以接收提醒';

  @override
  String minutes_format(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String get chart_average => '平均';

  @override
  String get chart_peak => '峰值';

  @override
  String get chart_lowest => '最低';

  @override
  String get active => '活跃';

  @override
  String get disabled => '已禁用';

  @override
  String get advanced_options => '高级选项';

  @override
  String get sync_ready => '同步就绪';

  @override
  String get success => '成功';

  @override
  String get destructive_badge => '破坏性';

  @override
  String get recommended_badge => '推荐';

  @override
  String get safe_badge => '安全';

  @override
  String get overview => '概览';

  @override
  String get patterns => '模式';

  @override
  String get apps => '应用';

  @override
  String get sortAscending => '升序排序';

  @override
  String get sortDescending => '降序排序';

  @override
  String applicationsShowing(int count) {
    return '显示 $count 个应用程序';
  }

  @override
  String valueLabel(String value) {
    return '值：$value';
  }

  @override
  String appsCount(int count) {
    return '$count 个应用';
  }

  @override
  String categoriesCount(int count) {
    return '$count 个类别';
  }

  @override
  String get systemNotificationsDisabled => '系统通知已禁用。在系统设置中启用它们以接收专注提醒。';

  @override
  String get openSystemSettings => '打开系统设置';

  @override
  String get appNotificationsDisabled => '应用设置中已禁用通知。启用它们以接收专注提醒。';

  @override
  String get goToSettings => '前往设置';

  @override
  String get focusModeNotificationsDisabled => '专注模式通知已禁用。启用它们以接收会话提醒。';

  @override
  String get notificationsDisabled => '通知已禁用';

  @override
  String get dontShowAgain => '不再显示';

  @override
  String get systemSettingsRequired => '需要系统设置';

  @override
  String get notificationsDisabledSystemLevel => '系统级别已禁用通知。要启用：';

  @override
  String get step1OpenSystemSettings => '1. 打开系统设置（系统偏好设置）';

  @override
  String get step2GoToNotifications => '2. 前往通知';

  @override
  String get step3FindApp => '3. 查找并选择 Scolect';

  @override
  String get step4EnableNotifications => '4. 启用\"允许通知\"';

  @override
  String get returnToAppMessage => '然后返回此应用，通知将正常工作。';

  @override
  String get gotIt => '知道了';

  @override
  String get noSessionsYet => '暂无会话';

  @override
  String applicationsTracked(int count) {
    return '已跟踪 $count 个应用程序';
  }

  @override
  String get applicationHeader => '应用程序';

  @override
  String get currentUsageHeader => '当前使用';

  @override
  String get dailyLimitHeader => '每日限制';

  @override
  String get edit => '编辑';

  @override
  String get showPopupNotifications => '显示弹出通知';

  @override
  String get moreFrequentReminders => '更频繁的提醒';

  @override
  String get playSoundWithAlerts => '播放提醒声音';

  @override
  String get systemTrayNotifications => '系统托盘通知';

  @override
  String screenTimeUsed(String current, String limit) {
    return '已使用 $current / $limit';
  }

  @override
  String get todaysScreenTime => '今日屏幕时间';

  @override
  String get activeLimits => '活跃限制';

  @override
  String get nearLimit => '接近限制';

  @override
  String get colorPickerSpectrum => '色谱';

  @override
  String get colorPickerPresets => '预设';

  @override
  String get colorPickerSliders => '滑块';

  @override
  String get colorPickerBasicColors => '基本颜色';

  @override
  String get colorPickerExtendedPalette => '扩展调色板';

  @override
  String get colorPickerRed => '红色';

  @override
  String get colorPickerGreen => '绿色';

  @override
  String get colorPickerBlue => '蓝色';

  @override
  String get colorPickerHue => '色调';

  @override
  String get colorPickerSaturation => '饱和度';

  @override
  String get colorPickerBrightness => '亮度';

  @override
  String get colorPickerHexColor => '十六进制颜色';

  @override
  String get colorPickerHexPlaceholder => 'RRGGBB';

  @override
  String get colorPickerRGB => 'RGB';

  @override
  String get select => '选择';

  @override
  String get themeCustomization => '主题自定义';

  @override
  String get chooseThemePreset => '选择主题预设';

  @override
  String get yourCustomThemes => '您的自定义主题';

  @override
  String get createCustomTheme => '创建自定义主题';

  @override
  String get designOwnColorScheme => '设计您自己的配色方案';

  @override
  String get newTheme => '新主题';

  @override
  String get editCurrentTheme => '编辑当前主题';

  @override
  String customizeColorsFor(String themeName) {
    return '自定义 $themeName 的颜色';
  }

  @override
  String customThemeNumber(int number) {
    return '自定义主题 $number';
  }

  @override
  String get deleteCustomTheme => '删除自定义主题';

  @override
  String confirmDeleteTheme(String themeName) {
    return '您确定要删除 \"$themeName\" 吗？';
  }

  @override
  String get delete => '删除';

  @override
  String get customizeTheme => '自定义主题';

  @override
  String get preview => '预览';

  @override
  String get themeName => '主题名称';

  @override
  String get brandColors => '品牌颜色';

  @override
  String get lightTheme => '浅色主题';

  @override
  String get darkTheme => '深色主题';

  @override
  String get reset => '重置';

  @override
  String get saveTheme => '保存主题';

  @override
  String get customTheme => '自定义主题';

  @override
  String get primaryColors => '主要颜色';

  @override
  String get primaryColorsDesc => '整个应用中使用的主要强调色';

  @override
  String get primaryAccent => '主要强调色';

  @override
  String get primaryAccentDesc => '主要品牌颜色、按钮、链接';

  @override
  String get secondaryAccent => '次要强调色';

  @override
  String get secondaryAccentDesc => '渐变的补充强调色';

  @override
  String get semanticColors => '语义颜色';

  @override
  String get semanticColorsDesc => '传达含义和状态的颜色';

  @override
  String get successColor => '成功颜色';

  @override
  String get successColorDesc => '积极操作、确认';

  @override
  String get warningColor => '警告颜色';

  @override
  String get warningColorDesc => '注意、待处理状态';

  @override
  String get errorColor => '错误颜色';

  @override
  String get errorColorDesc => '错误、破坏性操作';

  @override
  String get backgroundColors => '背景颜色';

  @override
  String get backgroundColorsLightDesc => '浅色模式的主要背景表面';

  @override
  String get backgroundColorsDarkDesc => '深色模式的主要背景表面';

  @override
  String get background => '背景';

  @override
  String get backgroundDesc => '主应用背景';

  @override
  String get surface => '表面';

  @override
  String get surfaceDesc => '卡片、对话框、升高的表面';

  @override
  String get surfaceSecondary => '次要表面';

  @override
  String get surfaceSecondaryDesc => '次要卡片、侧边栏';

  @override
  String get border => '边框';

  @override
  String get borderDesc => '分隔线、卡片边框';

  @override
  String get textColors => '文本颜色';

  @override
  String get textColorsLightDesc => '浅色模式的排版颜色';

  @override
  String get textColorsDarkDesc => '深色模式的排版颜色';

  @override
  String get textPrimary => '主要文本';

  @override
  String get textPrimaryDesc => '标题、重要文本';

  @override
  String get textSecondary => '次要文本';

  @override
  String get textSecondaryDesc => '描述、说明';

  @override
  String previewMode(String mode) {
    return '预览：$mode模式';
  }

  @override
  String get dark => '深色';

  @override
  String get light => '浅色';

  @override
  String get sampleCardTitle => '示例卡片标题';

  @override
  String get sampleSecondaryText => '这是下方显示的次要文本。';

  @override
  String get primary => '主要';

  @override
  String get secondary => '次要';

  @override
  String get warning => '警告';

  @override
  String get launchAtStartupTitle => '开机启动';

  @override
  String get launchAtStartupDescription => '登录计算机时自动启动 Scolect';

  @override
  String get inputMonitoringPermissionTitle => '键盘监控不可用';

  @override
  String get inputMonitoringPermissionDescription => '请启用“输入监控”权限以跟踪键盘活动。目前仅监控鼠标输入。';

  @override
  String get openSettings => '打开设置';

  @override
  String get permissionGrantedTitle => '权限已授予';

  @override
  String get permissionGrantedDescription => '应用需要重新启动才能使输入监控生效。';

  @override
  String get continueButton => '继续';

  @override
  String get restartRequiredTitle => '需要重新启动';

  @override
  String get restartRequiredDescription => '要启用键盘监控，应用需要重新启动。这是 macOS 的要求。';

  @override
  String get restartNote => '重新启动后，应用将自动重新打开。';

  @override
  String get restartNow => '立即重新启动';

  @override
  String get restartLater => '稍后重新启动';

  @override
  String get restartFailedTitle => '重新启动失败';

  @override
  String get restartFailedMessage => '无法自动重新启动应用。请退出（Cmd+Q）并手动重新打开。';

  @override
  String get exportAnalyticsReport => '导出分析报告';

  @override
  String get chooseExportFormat => '选择导出格式：';

  @override
  String get beautifulExcelReport => '精美Excel报告';

  @override
  String get beautifulExcelReportDescription => '精美多彩的电子表格，包含图表、表情符号和见解 ✨';

  @override
  String get excelReportIncludes => 'Excel报告包含：';

  @override
  String get summarySheetDescription => '📊 摘要表 - 关键指标和趋势';

  @override
  String get dailyBreakdownDescription => '📅 每日明细 - 可视化使用模式';

  @override
  String get appsSheetDescription => '📱 应用表 - 详细应用排名';

  @override
  String get insightsDescription => '💡 洞察 - 智能建议';

  @override
  String get beautifulExcelExportSuccess => '精美Excel报告导出成功！🎉';

  @override
  String failedToExportReport(String error) {
    return '导出报告失败：$error';
  }

  @override
  String get exporting => '导出中...';

  @override
  String get exportExcel => '导出Excel';

  @override
  String get saveAnalyticsReport => '保存分析报告';

  @override
  String analyticsReportFileName(String timestamp) {
    return '分析报告_$timestamp.xlsx';
  }

  @override
  String get usageAnalyticsReportTitle => '使用分析报告';

  @override
  String get generated => '生成时间：';

  @override
  String get period => '周期：';

  @override
  String dateRangeValue(String startDate, String endDate) {
    return '$startDate 至 $endDate';
  }

  @override
  String get keyMetrics => '关键指标';

  @override
  String get metric => '指标';

  @override
  String get value => '数值';

  @override
  String get change => '变化';

  @override
  String get trend => '趋势';

  @override
  String get productivityRate => '生产力比率';

  @override
  String get trendUp => '上升';

  @override
  String get trendDown => '下降';

  @override
  String get trendExcellent => '优秀';

  @override
  String get trendGood => '良好';

  @override
  String get trendNeedsImprovement => '需改进';

  @override
  String get trendActive => '活跃';

  @override
  String get trendNone => '无';

  @override
  String get trendTop => '最高';

  @override
  String get category => '类别';

  @override
  String get percentage => '百分比';

  @override
  String get visual => '可视化';

  @override
  String get statistics => '统计数据';

  @override
  String get averageDaily => '日均';

  @override
  String get highestDay => '最高日';

  @override
  String get lowestDay => '最低日';

  @override
  String get day => '星期';

  @override
  String get applicationUsageDetails => '应用使用详情';

  @override
  String get totalApps => '应用总数：';

  @override
  String get productiveApps => '高效应用：';

  @override
  String get rank => '排名';

  @override
  String get application => '应用程序';

  @override
  String get time => '时间';

  @override
  String get percentOfTotal => '占比';

  @override
  String get type => '类型';

  @override
  String get usageLevel => '使用级别';

  @override
  String get leisure => '休闲';

  @override
  String get usageLevelVeryHigh => '非常高 ||||||||';

  @override
  String get usageLevelHigh => '高 ||||||';

  @override
  String get usageLevelMedium => '中等 ||||';

  @override
  String get usageLevelLow => '低 ||';

  @override
  String get keyInsightsTitle => '关键洞察与建议';

  @override
  String get personalizedRecommendations => '个性化建议';

  @override
  String insightHighDailyUsage(String hours) {
    return '高日使用量：您平均每天屏幕使用时间为$hours小时';
  }

  @override
  String insightLowDailyUsage(String hours) {
    return '低日使用量：您平均每天仅$hours小时 - 保持得很好！';
  }

  @override
  String insightModerateUsage(String hours) {
    return '适度使用：平均每天屏幕使用时间为$hours小时';
  }

  @override
  String insightExcellentProductivity(String percentage) {
    return '出色的生产力：$percentage%的屏幕时间用于高效工作！';
  }

  @override
  String insightGoodProductivity(String percentage) {
    return '良好的生产力：$percentage%的屏幕时间用于高效工作';
  }

  @override
  String insightLowProductivity(String percentage) {
    return '低生产力警告：仅$percentage%的屏幕时间是高效的';
  }

  @override
  String insightFocusSessions(int count, String avgPerDay) {
    return '专注会话：完成$count次会话（平均每天$avgPerDay次）';
  }

  @override
  String insightGreatFocusHabit(int count) {
    return '出色的专注习惯：您已完成$count次专注会话，建立了出色的专注习惯！';
  }

  @override
  String get insightNoFocusSessions => '无专注会话：考虑使用专注模式来提高生产力';

  @override
  String insightScreenTimeTrend(String direction, String percentage) {
    return '屏幕时间趋势：与上一周期相比，您的使用量$direction了$percentage%';
  }

  @override
  String insightProductiveTimeTrend(String direction, String percentage) {
    return '高效时间趋势：与上一周期相比，您的高效时间$direction了$percentage%';
  }

  @override
  String get directionIncreased => '增加';

  @override
  String get directionDecreased => '减少';

  @override
  String insightTopCategory(String category, String percentage) {
    return '热门类别：$category占据了$percentage%的总时间';
  }

  @override
  String insightMostUsedApp(String appName, String percentage, String duration) {
    return '最常用应用：$appName占用了$percentage%的时间（$duration）';
  }

  @override
  String insightUsageVaries(String highDay, String multiplier, String lowDay) {
    return '使用量波动显著：$highDay的使用量是$lowDay的$multiplier倍';
  }

  @override
  String get insightNoInsights => '暂无重要洞察';

  @override
  String get recScheduleFocusSessions => '尝试在一天中安排更多专注会话以提高生产力';

  @override
  String get recSetAppLimits => '考虑为休闲应用设置使用限制';

  @override
  String get recAimForFocusSessions => '争取每天至少1-2次专注会话以建立持续的习惯';

  @override
  String get recTakeBreaks => '您的每日屏幕时间较高。尝试使用20-20-20法则定期休息';

  @override
  String get recSetDailyGoals => '考虑设置每日屏幕时间目标以逐渐减少使用';

  @override
  String get recBalanceEntertainment => '娱乐应用占用了大量时间。考虑平衡更多高效活动';

  @override
  String get recReviewUsagePatterns => '您的屏幕时间显著增加。审查您的使用模式并设定界限';

  @override
  String get recScheduleFocusedWork => '您的高效时间有所减少。尝试在日历中安排专注工作时段';

  @override
  String get recKeepUpGreatWork => '继续保持！您的屏幕时间习惯看起来很健康';

  @override
  String get recContinueFocusSessions => '继续使用专注会话以保持生产力';

  @override
  String get sheetSummary => '摘要';

  @override
  String get sheetDailyBreakdown => '每日明细';

  @override
  String get sheetApps => '应用';

  @override
  String get sheetInsights => '洞察';

  @override
  String get statusHeader => '状态';

  @override
  String workSessions(int count) {
    return '$count个工作时段';
  }

  @override
  String get complete => '已完成';

  @override
  String get inProgress => '进行中';

  @override
  String get workTime => '工作时间';

  @override
  String get breakTime => '休息时间';

  @override
  String get phasesCompleted => '已完成阶段';

  @override
  String hourMinuteFormat(String hours, String minutes) {
    return '$hours小时$minutes分钟';
  }

  @override
  String hourOnlyFormat(String hours) {
    return '$hours小时';
  }

  @override
  String minuteFormat(String minutes) {
    return '$minutes分钟';
  }

  @override
  String sessionsCount(int count) {
    return '$count个时段';
  }

  @override
  String get workPhases => '工作阶段';

  @override
  String get averageLength => '平均时长';

  @override
  String get mostProductive => '最高效';

  @override
  String get work => '工作';

  @override
  String get breaks => '休息';

  @override
  String get none => '无';

  @override
  String minuteShortFormat(String minutes) {
    return '$minutes分钟';
  }

  @override
  String get importTheme => '导入主题';

  @override
  String get exportTheme => '导出主题';

  @override
  String get import => '导入';

  @override
  String get export => '导出';

  @override
  String get chooseExportMethod => '选择导出主题的方式：';

  @override
  String get saveAsFile => '保存为文件';

  @override
  String get saveThemeAsJSONFile => '将主题保存为 JSON 文件到您的设备';

  @override
  String get copyToClipboard => '复制到剪贴板';

  @override
  String get copyThemeJSONToClipboard => '将主题数据复制到剪贴板';

  @override
  String get share => '分享';

  @override
  String get shareThemeViaSystemSheet => '使用系统分享功能分享主题';

  @override
  String get chooseImportMethod => '选择导入主题的方式：';

  @override
  String get loadFromFile => '从文件加载';

  @override
  String get selectJSONFileFromDevice => '从您的设备选择 JSON 主题文件';

  @override
  String get pasteFromClipboard => '从剪贴板粘贴';

  @override
  String get importFromClipboardJSON => '从剪贴板 JSON 数据导入主题';

  @override
  String get importFromFile => '从文件导入主题';

  @override
  String get themeCreatedSuccessfully => '主题创建成功！';

  @override
  String get themeUpdatedSuccessfully => '主题更新成功！';

  @override
  String get themeDeletedSuccessfully => '主题删除成功！';

  @override
  String get themeExportedSuccessfully => '主题导出成功！';

  @override
  String get themeCopiedToClipboard => '主题已复制到剪贴板！';

  @override
  String themeImportedSuccessfully(String themeName) {
    return '主题“$themeName”导入成功！';
  }

  @override
  String get noThemeDataFound => '未找到主题数据';

  @override
  String get invalidThemeFormat => '主题格式无效。请检查 JSON 数据。';

  @override
  String get trackingModeTitle => '追踪模式';

  @override
  String get trackingModeDescription => '选择应用使用情况的追踪方式';

  @override
  String get trackingModePolling => '标准（低资源占用）';

  @override
  String get trackingModePrecise => '精确（高准确度）';

  @override
  String get trackingModePollingHint => '每分钟检查一次 - 较低资源占用';

  @override
  String get trackingModePreciseHint => '实时追踪 - 更高准确度，更多资源占用';

  @override
  String get trackingModeChangeError => '更改追踪模式失败，请重试。';

  @override
  String get errorTitle => '错误';

  @override
  String get monitorKeyboardTitle => '监控键盘';

  @override
  String get monitorKeyboardDescription => '跟踪键盘活动以检测用户存在';

  @override
  String get changelogWhatsNew => '更新内容';

  @override
  String changelogReleasedOn(String date) {
    return '发布于 $date';
  }

  @override
  String get changelogNoContent => '此版本暂无更新日志。';

  @override
  String get changelogUnableToLoad => '无法加载更新日志';

  @override
  String get changelogErrorDescription => '无法检索此版本的更新日志。请检查您的网络连接或访问 GitHub 发布页面。';

  @override
  String get allTracking => '所有应用';

  @override
  String get notTracking => '未跟踪';

  @override
  String get allVisibility => '全部';

  @override
  String get visible => '可见';

  @override
  String get hidden => '隐藏';

  @override
  String get todaysLimitUsage => '今日限额使用情况';

  @override
  String get thisWeekAtAGlance => '本周概览';

  @override
  String get hourlyActivityHeatmap => '每小时活动热力图';

  @override
  String get productivityScore => '效率评分';

  @override
  String get streaks => '连续记录';

  @override
  String get weekOverWeek => '周环比';

  @override
  String get sameAsLastWeek => '与上周相同';

  @override
  String moreUsageThanLastWeek(String percent) {
    return '比上周多 $percent%';
  }

  @override
  String lessUsageThanLastWeek(String percent) {
    return '比上周少 $percent%';
  }

  @override
  String limitExceededBy(String duration) {
    return '超出限额 $duration';
  }

  @override
  String timeRemaining(String duration) {
    return '剩余 $duration';
  }

  @override
  String get totalSessions => '总使用次数';

  @override
  String get avgSession => '平均时长';

  @override
  String get mostActive => '最活跃时段';

  @override
  String get peakUsage => '峰值使用';

  @override
  String get dailyAverage => '每日平均';

  @override
  String get daysUsedInARow => '连续使用天数';

  @override
  String get daysSingular => '天';

  @override
  String get daysPlural => '天';

  @override
  String get daysOverLimitInARow => '连续超出限额天数';

  @override
  String get withinLimitAllWeek => '整周均未超出限额';

  @override
  String get productivityScoreGreat => '优秀';

  @override
  String get productivityScoreModerate => '一般';

  @override
  String get productivityScoreNeedsAttention => '需要关注';

  @override
  String get productiveAppMotivation => '高效应用——继续保持';

  @override
  String get nonProductiveAppSuggestion => '低效应用——建议减少使用';

  @override
  String get legendUsage => '使用量';

  @override
  String get legendAverage => '平均值';

  @override
  String get legendLimit => '限额';

  @override
  String get chartPeak => '峰值';

  @override
  String overLimitBy(String duration) {
    return '超出限额 +$duration';
  }

  @override
  String get noData => '暂无数据';

  @override
  String get yesterday => '昨天';

  @override
  String get changelog => '更新日志';
}
