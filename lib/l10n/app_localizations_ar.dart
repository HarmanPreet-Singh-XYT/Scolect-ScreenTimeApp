// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appWindowTitle => 'Scolect - تتبع وقت الشاشة واستخدام التطبيقات';

  @override
  String get appName => 'Scolect';

  @override
  String get appTitle => 'وقت شاشة منتج';

  @override
  String get sidebarTitle => 'وقت الشاشة';

  @override
  String get sidebarSubtitle => 'مفتوح المصدر';

  @override
  String get trayShowWindow => 'إظهار النافذة';

  @override
  String get trayStartFocusMode => 'بدء وضع التركيز';

  @override
  String get trayStopFocusMode => 'إيقاف وضع التركيز';

  @override
  String get trayReports => 'التقارير';

  @override
  String get trayAlertsLimits => 'التنبيهات والحدود';

  @override
  String get trayApplications => 'التطبيقات';

  @override
  String get trayDisableNotifications => 'تعطيل الإشعارات';

  @override
  String get trayEnableNotifications => 'تفعيل الإشعارات';

  @override
  String get trayVersionPrefix => 'الإصدار: ';

  @override
  String trayVersion(String version) {
    return 'الإصدار: $version';
  }

  @override
  String get trayExit => 'خروج';

  @override
  String get navOverview => 'نظرة عامة';

  @override
  String get navApplications => 'التطبيقات';

  @override
  String get navAlertsLimits => 'التنبيهات والحدود';

  @override
  String get navReports => 'التقارير';

  @override
  String get navFocusMode => 'وضع التركيز';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navHelp => 'المساعدة';

  @override
  String get helpTitle => 'المساعدة';

  @override
  String get faqCategoryGeneral => 'أسئلة عامة';

  @override
  String get faqCategoryApplications => 'إدارة التطبيقات';

  @override
  String get faqCategoryReports => 'تحليلات الاستخدام والتقارير';

  @override
  String get faqCategoryAlerts => 'التنبيهات والحدود';

  @override
  String get faqCategoryFocusMode => 'وضع التركيز ومؤقت بومودورو';

  @override
  String get faqCategorySettings => 'الإعدادات والتخصيص';

  @override
  String get faqCategoryTroubleshooting => 'استكشاف الأخطاء وإصلاحها';

  @override
  String get faqGeneralQ1 => 'كيف يتتبع هذا التطبيق وقت الشاشة؟';

  @override
  String get faqGeneralA1 =>
      'يراقب التطبيق استخدام جهازك في الوقت الفعلي، ويتتبع الوقت المستغرق في التطبيقات المختلفة. يوفر رؤى شاملة حول عاداتك الرقمية، بما في ذلك إجمالي وقت الشاشة والوقت المنتج واستخدام كل تطبيق.';

  @override
  String get faqGeneralQ2 => 'ما الذي يجعل التطبيق \'منتجاً\'؟';

  @override
  String get faqGeneralA2 =>
      'يمكنك تحديد التطبيقات كمنتجة يدوياً في قسم \'التطبيقات\'. تساهم التطبيقات المنتجة في نقاط الإنتاجية الخاصة بك، والتي تحسب نسبة وقت الشاشة المستغرق في التطبيقات المتعلقة بالعمل أو المفيدة.';

  @override
  String get faqGeneralQ3 => 'ما مدى دقة تتبع وقت الشاشة؟';

  @override
  String get faqGeneralA3 =>
      'يستخدم التطبيق التتبع على مستوى النظام لتوفير قياس دقيق لاستخدام جهازك. يلتقط وقت المقدمة لكل تطبيق مع تأثير ضئيل على البطارية.';

  @override
  String get faqGeneralQ4 => 'هل يمكنني تخصيص تصنيف التطبيقات؟';

  @override
  String get faqGeneralA4 =>
      'بالتأكيد! يمكنك إنشاء فئات مخصصة وتعيين التطبيقات لفئات محددة وتعديل هذه التعيينات بسهولة في قسم \'التطبيقات\'. يساعد هذا في إنشاء تحليلات استخدام أكثر فائدة.';

  @override
  String get faqGeneralQ5 =>
      'ما الرؤى التي يمكنني الحصول عليها من هذا التطبيق؟';

  @override
  String get faqGeneralA5 =>
      'يقدم التطبيق رؤى شاملة تشمل نقاط الإنتاجية وأنماط الاستخدام حسب الوقت من اليوم واستخدام التطبيقات التفصيلي وتتبع جلسات التركيز والتحليلات المرئية مثل الرسوم البيانية والمخططات الدائرية لمساعدتك على فهم وتحسين عاداتك الرقمية.';

  @override
  String get faqAppsQ1 => 'كيف أخفي تطبيقات معينة من التتبع؟';

  @override
  String get faqAppsA1 => 'في قسم \'التطبيقات\'، يمكنك تبديل رؤية التطبيقات.';

  @override
  String get faqAppsQ2 => 'هل يمكنني البحث وتصفية التطبيقات؟';

  @override
  String get faqAppsA2 =>
      'نعم، يتضمن قسم التطبيقات وظيفة البحث وخيارات التصفية. يمكنك تصفية التطبيقات حسب الفئة وحالة الإنتاجية وحالة التتبع والرؤية.';

  @override
  String get faqAppsQ3 => 'ما خيارات التحرير المتاحة للتطبيقات؟';

  @override
  String get faqAppsA3 =>
      'لكل تطبيق، يمكنك تحرير: تعيين الفئة وحالة الإنتاجية وتتبع الاستخدام والرؤية في التقارير وتعيين حدود زمنية يومية فردية.';

  @override
  String get faqAppsQ4 => 'كيف يتم تحديد فئات التطبيقات؟';

  @override
  String get faqAppsA4 =>
      'الفئات الأولية مقترحة من النظام، لكن لديك السيطرة الكاملة لإنشاء وتعديل وتعيين فئات مخصصة بناءً على سير عملك وتفضيلاتك.';

  @override
  String get faqReportsQ1 => 'ما أنواع التقارير المتاحة؟';

  @override
  String get faqReportsA1 =>
      'تشمل التقارير: إجمالي وقت الشاشة، الوقت المنتج، التطبيقات الأكثر استخداماً، جلسات التركيز، رسم بياني لوقت الشاشة اليومي، مخطط دائري لتوزيع الفئات، استخدام التطبيقات التفصيلي، اتجاهات الاستخدام الأسبوعية، وتحليل أنماط الاستخدام حسب الوقت من اليوم.';

  @override
  String get faqReportsQ2 => 'ما مدى تفصيل تقارير استخدام التطبيقات؟';

  @override
  String get faqReportsA2 =>
      'تعرض تقارير استخدام التطبيقات التفصيلية: اسم التطبيق والفئة وإجمالي الوقت المستغرق وحالة الإنتاجية، وتوفر قسم \'الإجراءات\' مع رؤى أعمق مثل ملخص الاستخدام والحدود اليومية واتجاهات الاستخدام ومقاييس الإنتاجية.';

  @override
  String get faqReportsQ3 => 'هل يمكنني تحليل اتجاهات الاستخدام بمرور الوقت؟';

  @override
  String get faqReportsA3 =>
      'نعم! يوفر التطبيق مقارنات أسبوعية، تعرض رسوماً بيانية للاستخدام على مدى الأسابيع الماضية ومتوسط الاستخدام اليومي وأطول الجلسات والإجماليات الأسبوعية لمساعدتك على تتبع عاداتك الرقمية.';

  @override
  String get faqReportsQ4 => 'ما هو تحليل \'نمط الاستخدام\'؟';

  @override
  String get faqReportsA4 =>
      'يقسم نمط الاستخدام وقت الشاشة إلى فترات الصباح والظهر والمساء والليل. يساعدك هذا على فهم متى تكون أكثر نشاطاً على جهازك وتحديد المجالات المحتملة للتحسين.';

  @override
  String get faqAlertsQ1 => 'ما مدى دقة حدود وقت الشاشة؟';

  @override
  String get faqAlertsA1 =>
      'يمكنك تعيين حدود يومية إجمالية لوقت الشاشة وحدود فردية للتطبيقات. يمكن تكوين الحدود بالساعات والدقائق، مع خيارات لإعادة التعيين أو التعديل حسب الحاجة.';

  @override
  String get faqAlertsQ2 => 'ما خيارات الإشعارات المتاحة؟';

  @override
  String get faqAlertsA2 =>
      'يقدم التطبيق أنواعاً متعددة من الإشعارات: تنبيهات النظام عند تجاوز وقت الشاشة، تنبيهات متكررة بفترات قابلة للتخصيص (1 أو 5 أو 15 أو 30 أو 60 دقيقة)، ومفاتيح تبديل لوضع التركيز ووقت الشاشة والإشعارات الخاصة بالتطبيقات.';

  @override
  String get faqAlertsQ3 => 'هل يمكنني تخصيص تنبيهات الحدود؟';

  @override
  String get faqAlertsA3 =>
      'نعم، يمكنك تخصيص تردد التنبيهات وتمكين/تعطيل أنواع محددة من التنبيهات وتعيين حدود مختلفة لوقت الشاشة الإجمالي والتطبيقات الفردية.';

  @override
  String get faqFocusQ1 => 'ما أنواع أوضاع التركيز المتاحة؟';

  @override
  String get faqFocusA1 =>
      'تشمل الأوضاع المتاحة العمل العميق (جلسات تركيز أطول) والمهام السريعة (فترات عمل قصيرة) ووضع القراءة. يساعدك كل وضع على هيكلة عملك وأوقات الراحة بفعالية.';

  @override
  String get faqFocusQ2 => 'ما مدى مرونة مؤقت بومودورو؟';

  @override
  String get faqFocusA2 =>
      'المؤقت قابل للتخصيص بدرجة عالية. يمكنك ضبط مدة العمل وطول الاستراحة القصيرة ومدة الاستراحة الطويلة. تشمل الخيارات الإضافية البدء التلقائي للجلسات التالية وإعدادات الإشعارات.';

  @override
  String get faqFocusQ3 => 'ماذا يظهر سجل وضع التركيز؟';

  @override
  String get faqFocusA3 =>
      'يتتبع سجل وضع التركيز جلسات التركيز اليومية، ويعرض عدد الجلسات في اليوم ورسم بياني للاتجاهات ومتوسط مدة الجلسة وإجمالي وقت التركيز ومخطط دائري لتوزيع الوقت يقسم جلسات العمل والاستراحات القصيرة والاستراحات الطويلة.';

  @override
  String get faqFocusQ4 => 'هل يمكنني تتبع تقدم جلسة التركيز؟';

  @override
  String get faqFocusA4 =>
      'يتميز التطبيق بواجهة مؤقت دائرية مع أزرار التشغيل/الإيقاف وإعادة التحميل والإعدادات. يمكنك بسهولة تتبع وإدارة جلسات التركيز بعناصر تحكم بديهية.';

  @override
  String get faqSettingsQ1 => 'ما خيارات التخصيص المتاحة؟';

  @override
  String get faqSettingsA1 =>
      'يشمل التخصيص اختيار السمة (النظام، فاتح، داكن) وإعدادات اللغة وسلوك بدء التشغيل وعناصر تحكم شاملة في الإشعارات وخيارات إدارة البيانات مثل مسح البيانات أو إعادة تعيين الإعدادات.';

  @override
  String get faqSettingsQ2 => 'كيف أقدم ملاحظات أو أبلغ عن مشاكل؟';

  @override
  String get faqSettingsA2 =>
      'في أسفل قسم الإعدادات، ستجد أزراراً للإبلاغ عن خطأ أو إرسال ملاحظات أو الاتصال بالدعم. ستوجهك هذه إلى قنوات الدعم المناسبة.';

  @override
  String get faqSettingsQ3 => 'ماذا يحدث عند مسح البيانات؟';

  @override
  String get faqSettingsA3 =>
      'سيؤدي مسح البيانات إلى إعادة تعيين جميع إحصائيات الاستخدام وسجل جلسات التركيز والإعدادات المخصصة. هذا مفيد للبدء من جديد أو استكشاف الأخطاء وإصلاحها.';

  @override
  String get faqTroubleQ1 => 'البيانات لا تظهر، خطأ عدم فتح hive';

  @override
  String get faqTroubleA1 =>
      'المشكلة معروفة، الحل المؤقت هو مسح البيانات من خلال الإعدادات وإذا لم ينجح ذلك فانتقل إلى المستندات واحذف الملفات التالية إذا كانت موجودة - harman_screentime_app_usage_box.hive و harman_screentime_app_usage.lock، يُنصح أيضاً بتحديث التطبيق إلى أحدث إصدار.';

  @override
  String get faqTroubleQ2 => 'التطبيق يفتح عند كل بدء تشغيل، ماذا أفعل؟';

  @override
  String get faqTroubleA2 =>
      'هذه مشكلة معروفة تحدث في ويندوز 10، الحل المؤقت هو تمكين التشغيل كمصغر في الإعدادات حتى يتم تشغيله كمصغر.';

  @override
  String get usageAnalytics => 'تحليلات الاستخدام';

  @override
  String get last7Days => 'آخر 7 أيام';

  @override
  String get lastMonth => 'الشهر الماضي';

  @override
  String get last3Months => 'آخر 3 أشهر';

  @override
  String get lifetime => 'كل الوقت';

  @override
  String get custom => 'مخصص';

  @override
  String get loadingAnalyticsData => 'جارٍ تحميل بيانات التحليلات...';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get failedToInitialize =>
      'فشل في تهيئة التحليلات. يرجى إعادة تشغيل التطبيق.';

  @override
  String unexpectedError(String error) {
    return 'حدث خطأ غير متوقع: $error. يرجى المحاولة لاحقاً.';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return 'خطأ في تحميل بيانات التحليلات: $error. يرجى التحقق من اتصالك والمحاولة مرة أخرى.';
  }

  @override
  String get customDialogTitle => 'مخصص';

  @override
  String get dateRange => 'نطاق التاريخ:';

  @override
  String get specificDate => 'تاريخ محدد';

  @override
  String get startDate => 'تاريخ البداية: ';

  @override
  String get endDate => 'تاريخ النهاية: ';

  @override
  String get date => 'التاريخ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get apply => 'تطبيق';

  @override
  String get ok => 'حسناً';

  @override
  String get invalidDateRange => 'نطاق تاريخ غير صالح';

  @override
  String get startDateBeforeEndDate =>
      'يجب أن يكون تاريخ البداية قبل أو يساوي تاريخ النهاية.';

  @override
  String get totalScreenTime => 'إجمالي وقت الشاشة';

  @override
  String get productiveTime => 'الوقت المنتج';

  @override
  String get mostUsedApp => 'التطبيق الأكثر استخداماً';

  @override
  String get focusSessions => 'جلسات التركيز';

  @override
  String positiveComparison(String percent) {
    return '+$percent% مقارنة بالفترة السابقة';
  }

  @override
  String negativeComparison(String percent) {
    return '$percent% مقارنة بالفترة السابقة';
  }

  @override
  String iconLabel(String title) {
    return 'أيقونة $title';
  }

  @override
  String get dailyScreenTime => 'وقت الشاشة اليومي';

  @override
  String get categoryBreakdown => 'توزيع الفئات';

  @override
  String get noDataAvailable => 'لا توجد بيانات متاحة';

  @override
  String sectionLabel(String title) {
    return 'قسم $title';
  }

  @override
  String get detailedApplicationUsage => 'استخدام التطبيقات التفصيلي';

  @override
  String get searchApplications => 'البحث عن تطبيقات';

  @override
  String get nameHeader => 'الاسم';

  @override
  String get categoryHeader => 'الفئة';

  @override
  String get totalTimeHeader => 'إجمالي الوقت';

  @override
  String get productivityHeader => 'الإنتاجية';

  @override
  String get actionsHeader => 'الإجراءات';

  @override
  String sortByOption(String option) {
    return 'ترتيب حسب: $option';
  }

  @override
  String get sortByName => 'الاسم';

  @override
  String get sortByCategory => 'الفئة';

  @override
  String get sortByUsage => 'الاستخدام';

  @override
  String get productive => 'منتج';

  @override
  String get nonProductive => 'غير منتج';

  @override
  String get noApplicationsMatch => 'لا توجد تطبيقات تطابق معايير البحث';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get usageSummary => 'ملخص الاستخدام';

  @override
  String get usageOverPastWeek => 'الاستخدام خلال الأسبوع الماضي';

  @override
  String get usagePatternByTimeOfDay => 'نمط الاستخدام حسب الوقت من اليوم';

  @override
  String get patternAnalysis => 'تحليل الأنماط';

  @override
  String get today => 'اليوم';

  @override
  String get dailyLimit => 'الحد اليومي';

  @override
  String get noLimit => 'بدون حد';

  @override
  String get usageTrend => 'اتجاه الاستخدام';

  @override
  String get productivity => 'الإنتاجية';

  @override
  String get increasing => 'متزايد';

  @override
  String get decreasing => 'متناقص';

  @override
  String get stable => 'مستقر';

  @override
  String get avgDailyUsage => 'متوسط الاستخدام اليومي';

  @override
  String get longestSession => 'أطول جلسة';

  @override
  String get weeklyTotal => 'الإجمالي الأسبوعي';

  @override
  String get noHistoricalData => 'لا توجد بيانات تاريخية متاحة';

  @override
  String get morning => 'الصباح (6-12)';

  @override
  String get afternoon => 'الظهر (12-5)';

  @override
  String get evening => 'المساء (5-9)';

  @override
  String get night => 'الليل (9-6)';

  @override
  String get usageInsights => 'رؤى الاستخدام';

  @override
  String get limitStatus => 'حالة الحد';

  @override
  String get close => 'إغلاق';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return 'تستخدم $appName بشكل أساسي خلال $timeOfDay.';
  }

  @override
  String significantIncrease(String percentage) {
    return 'زاد استخدامك بشكل ملحوظ ($percentage%) مقارنة بالفترة السابقة.';
  }

  @override
  String get trendingUpward =>
      'استخدامك يتجه نحو الارتفاع مقارنة بالفترة السابقة.';

  @override
  String significantDecrease(String percentage) {
    return 'انخفض استخدامك بشكل ملحوظ ($percentage%) مقارنة بالفترة السابقة.';
  }

  @override
  String get trendingDownward =>
      'استخدامك يتجه نحو الانخفاض مقارنة بالفترة السابقة.';

  @override
  String get consistentUsage => 'كان استخدامك متسقاً مقارنة بالفترة السابقة.';

  @override
  String get markedAsProductive => 'هذا مُعلَّم كتطبيق منتج في إعداداتك.';

  @override
  String get markedAsNonProductive =>
      'هذا مُعلَّم كتطبيق غير منتج في إعداداتك.';

  @override
  String mostActiveTime(String time) {
    return 'وقتك الأكثر نشاطاً هو حوالي الساعة $time.';
  }

  @override
  String get noLimitSet => 'لم يتم تعيين حد استخدام لهذا التطبيق.';

  @override
  String get limitReached => 'لقد وصلت إلى الحد اليومي لهذا التطبيق.';

  @override
  String aboutToReachLimit(String remainingTime) {
    return 'أنت على وشك الوصول إلى الحد اليومي مع بقاء $remainingTime فقط.';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return 'لقد استخدمت $percent% من الحد اليومي مع بقاء $remainingTime.';
  }

  @override
  String remainingTime(String time) {
    return 'لديك $time متبقٍ من الحد اليومي.';
  }

  @override
  String get todayChart => 'اليوم';

  @override
  String hourPeriodAM(int hour) {
    return '$hour صباحاً';
  }

  @override
  String hourPeriodPM(int hour) {
    return '$hour مساءً';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hoursس $minutesد';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '$minutesد';
  }

  @override
  String get alertsLimitsTitle => 'التنبيهات والحدود';

  @override
  String get notificationsSettings => 'إعدادات الإشعارات';

  @override
  String get overallScreenTimeLimit => 'الحد الإجمالي لوقت الشاشة';

  @override
  String get applicationLimits => 'حدود التطبيقات';

  @override
  String get popupAlerts => 'التنبيهات المنبثقة';

  @override
  String get frequentAlerts => 'التنبيهات المتكررة';

  @override
  String get soundAlerts => 'التنبيهات الصوتية';

  @override
  String get systemAlerts => 'تنبيهات النظام';

  @override
  String get dailyTotalLimit => 'الحد اليومي الإجمالي: ';

  @override
  String get hours => 'ساعات';

  @override
  String get minutes => 'دقائق';

  @override
  String get currentUsage => 'الاستخدام الحالي: ';

  @override
  String get tableName => 'الاسم';

  @override
  String get tableCategory => 'الفئة';

  @override
  String get tableDailyLimit => 'الحد اليومي';

  @override
  String get tableCurrentUsage => 'الاستخدام الحالي';

  @override
  String get tableStatus => 'الحالة';

  @override
  String get tableActions => 'الإجراءات';

  @override
  String get addLimit => 'إضافة حد';

  @override
  String get noApplicationsToDisplay => 'لا توجد تطبيقات للعرض';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusOff => 'متوقف';

  @override
  String get durationNone => 'لا يوجد';

  @override
  String get addApplicationLimit => 'إضافة حد للتطبيق';

  @override
  String get selectApplication => 'اختر تطبيقاً';

  @override
  String get selectApplicationPlaceholder => 'اختر تطبيقاً';

  @override
  String get enableLimit => 'تفعيل الحد: ';

  @override
  String editLimitTitle(String appName) {
    return 'تعديل الحد: $appName';
  }

  @override
  String failedToLoadData(String error) {
    return 'فشل في تحميل البيانات: $error';
  }

  @override
  String get resetSettingsTitle => 'إعادة تعيين الإعدادات؟';

  @override
  String get resetSettingsContent =>
      'إذا قمت بإعادة تعيين الإعدادات، لن تتمكن من استعادتها. هل تريد إعادة التعيين؟';

  @override
  String get resetAll => 'إعادة تعيين الكل';

  @override
  String get refresh => 'تحديث';

  @override
  String get save => 'حفظ';

  @override
  String get add => 'إضافة';

  @override
  String get error => 'خطأ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get applicationsTitle => 'التطبيقات';

  @override
  String get searchApplication => 'البحث عن تطبيق';

  @override
  String get tracking => 'قيد التتبع';

  @override
  String get hiddenVisible => 'مخفي/مرئي';

  @override
  String get selectCategory => 'اختر فئة';

  @override
  String get allCategories => 'الكل';

  @override
  String get tableScreenTime => 'وقت الشاشة';

  @override
  String get tableTracking => 'التتبع';

  @override
  String get tableHidden => 'مخفي';

  @override
  String get tableEdit => 'تعديل';

  @override
  String editAppTitle(String appName) {
    return 'تعديل $appName';
  }

  @override
  String get categorySection => 'الفئة';

  @override
  String get customCategory => 'مخصص';

  @override
  String get customCategoryPlaceholder => 'أدخل اسم الفئة المخصصة';

  @override
  String get uncategorized => 'غير مصنف';

  @override
  String get isProductive => 'منتج';

  @override
  String get trackUsage => 'تتبع الاستخدام';

  @override
  String get visibleInReports => 'مرئي في التقارير';

  @override
  String get timeLimitsSection => 'حدود الوقت';

  @override
  String get enableDailyLimit => 'تفعيل الحد اليومي';

  @override
  String get setDailyTimeLimit => 'تعيين الحد الزمني اليومي:';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String errorLoadingData(String error) {
    return 'خطأ في تحميل بيانات النظرة العامة: $error';
  }

  @override
  String get focusModeTitle => 'وضع التركيز';

  @override
  String get historySection => 'السجل';

  @override
  String get trendsSection => 'الاتجاهات';

  @override
  String get timeDistributionSection => 'توزيع الوقت';

  @override
  String get sessionHistorySection => 'سجل الجلسات';

  @override
  String get workSession => 'جلسة عمل';

  @override
  String get shortBreak => 'استراحة قصيرة';

  @override
  String get longBreak => 'استراحة طويلة';

  @override
  String get dateHeader => 'التاريخ';

  @override
  String get durationHeader => 'المدة';

  @override
  String get monday => 'الإثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get saturday => 'السبت';

  @override
  String get sunday => 'الأحد';

  @override
  String get focusModeSettingsTitle => 'إعدادات وضع التركيز';

  @override
  String get modeCustom => 'مخصص';

  @override
  String get modeDeepWork => 'عمل عميق (60 دقيقة)';

  @override
  String get modeQuickTasks => 'مهام سريعة (25 دقيقة)';

  @override
  String get modeReading => 'قراءة (45 دقيقة)';

  @override
  String workDurationLabel(int minutes) {
    return 'مدة العمل: $minutes دقيقة';
  }

  @override
  String shortBreakLabel(int minutes) {
    return 'استراحة قصيرة';
  }

  @override
  String longBreakLabel(int minutes) {
    return 'استراحة طويلة';
  }

  @override
  String get autoStartNextSession => 'البدء التلقائي للجلسة التالية';

  @override
  String get blockDistractions => 'حظر المشتتات أثناء وضع التركيز';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get saved => 'تم الحفظ';

  @override
  String errorLoadingFocusModeData(String error) {
    return 'خطأ في تحميل بيانات وضع التركيز: $error';
  }

  @override
  String get overviewTitle => 'نظرة عامة على اليوم';

  @override
  String get startFocusMode => 'بدء وضع التركيز';

  @override
  String get loadingProductivityData => 'جارٍ تحميل بيانات الإنتاجية...';

  @override
  String get noActivityDataAvailable => 'لا توجد بيانات نشاط متاحة بعد';

  @override
  String get startUsingApplications =>
      'ابدأ باستخدام تطبيقاتك لتتبع وقت الشاشة والإنتاجية.';

  @override
  String get refreshData => 'تحديث البيانات';

  @override
  String get topApplications => 'أكثر التطبيقات استخداماً';

  @override
  String get noAppUsageDataAvailable =>
      'لا توجد بيانات استخدام التطبيقات متاحة بعد';

  @override
  String get noApplicationDataAvailable => 'لا توجد بيانات تطبيقات متاحة';

  @override
  String get noCategoryDataAvailable => 'لا توجد بيانات فئات متاحة';

  @override
  String get noApplicationLimitsSet => 'لم يتم تعيين حدود للتطبيقات';

  @override
  String get screenLabel => 'الشاشة';

  @override
  String get timeLabel => 'الوقت';

  @override
  String get productiveLabel => 'منتج';

  @override
  String get scoreLabel => 'النتيجة';

  @override
  String get defaultNone => 'لا يوجد';

  @override
  String get defaultTime => '0س 0د';

  @override
  String get defaultCount => '0';

  @override
  String get unknownApp => 'غير معروف';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get generalSection => 'عام';

  @override
  String get notificationsSection => 'الإشعارات';

  @override
  String get dataSection => 'البيانات';

  @override
  String get versionSection => 'الإصدار';

  @override
  String get languageTitle => 'اللغة';

  @override
  String get languageDescription => 'لغة التطبيق';

  @override
  String get startupBehaviourTitle => 'سلوك بدء التشغيل';

  @override
  String get startupBehaviourDescription => 'التشغيل عند بدء نظام التشغيل';

  @override
  String get launchMinimizedTitle => 'التشغيل كمصغر';

  @override
  String get launchMinimizedDescription =>
      'بدء التطبيق في شريط النظام (موصى به لويندوز 10)';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsAllDescription => 'جميع إشعارات التطبيق';

  @override
  String get focusModeNotificationsTitle => 'وضع التركيز';

  @override
  String get focusModeNotificationsDescription => 'جميع إشعارات وضع التركيز';

  @override
  String get screenTimeNotificationsTitle => 'وقت الشاشة';

  @override
  String get screenTimeNotificationsDescription =>
      'جميع إشعارات تقييد وقت الشاشة';

  @override
  String get appScreenTimeNotificationsTitle => 'وقت شاشة التطبيق';

  @override
  String get appScreenTimeNotificationsDescription =>
      'جميع إشعارات تقييد وقت شاشة التطبيق';

  @override
  String get frequentAlertsTitle => 'فترة التنبيهات المتكررة';

  @override
  String get frequentAlertsDescription =>
      'تعيين فترة الإشعارات المتكررة (بالدقائق)';

  @override
  String get clearDataTitle => 'مسح البيانات';

  @override
  String get clearDataDescription => 'مسح جميع السجلات والبيانات ذات الصلة';

  @override
  String get resetSettingsTitle2 => 'إعادة تعيين الإعدادات';

  @override
  String get resetSettingsDescription => 'إعادة تعيين جميع الإعدادات';

  @override
  String get versionTitle => 'الإصدار';

  @override
  String get versionDescription => 'الإصدار الحالي للتطبيق';

  @override
  String get contactButton => 'اتصل بنا';

  @override
  String get reportBugButton => 'الإبلاغ عن خطأ';

  @override
  String get submitFeedbackButton => 'إرسال ملاحظات';

  @override
  String get githubButton => 'جيت هب';

  @override
  String get clearDataDialogTitle => 'مسح البيانات؟';

  @override
  String get clearDataDialogContent =>
      'سيؤدي هذا إلى مسح جميع السجلات والبيانات ذات الصلة. لن تتمكن من استعادتها. هل تريد المتابعة؟';

  @override
  String get clearDataButtonLabel => 'مسح البيانات';

  @override
  String get resetSettingsDialogTitle => 'إعادة تعيين الإعدادات؟';

  @override
  String get resetSettingsDialogContent =>
      'سيؤدي هذا إلى إعادة تعيين جميع الإعدادات إلى قيمها الافتراضية. هل تريد المتابعة؟';

  @override
  String get resetButtonLabel => 'إعادة تعيين';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String couldNotLaunchUrl(String url) {
    return 'تعذر فتح $url';
  }

  @override
  String errorMessage(String message) {
    return 'خطأ: $message';
  }

  @override
  String get chart_focusTrends => 'اتجاهات التركيز';

  @override
  String get chart_sessionCount => 'عدد الجلسات';

  @override
  String get chart_avgDuration => 'متوسط المدة';

  @override
  String get chart_totalFocus => 'إجمالي التركيز';

  @override
  String get chart_yAxis_sessions => 'الجلسات';

  @override
  String get chart_yAxis_minutes => 'الدقائق';

  @override
  String get chart_yAxis_value => 'القيمة';

  @override
  String get chart_monthOverMonthChange => 'التغيير من شهر لآخر: ';

  @override
  String get chart_customRange => 'نطاق مخصص';

  @override
  String get day_monday => 'الإثنين';

  @override
  String get day_mondayShort => 'إثن';

  @override
  String get day_mondayAbbr => 'ن';

  @override
  String get day_tuesday => 'الثلاثاء';

  @override
  String get day_tuesdayShort => 'ثلا';

  @override
  String get day_tuesdayAbbr => 'ث';

  @override
  String get day_wednesday => 'الأربعاء';

  @override
  String get day_wednesdayShort => 'أرب';

  @override
  String get day_wednesdayAbbr => 'ر';

  @override
  String get day_thursday => 'الخميس';

  @override
  String get day_thursdayShort => 'خمي';

  @override
  String get day_thursdayAbbr => 'خ';

  @override
  String get day_friday => 'الجمعة';

  @override
  String get day_fridayShort => 'جمع';

  @override
  String get day_fridayAbbr => 'ج';

  @override
  String get day_saturday => 'السبت';

  @override
  String get day_saturdayShort => 'سبت';

  @override
  String get day_saturdayAbbr => 'س';

  @override
  String get day_sunday => 'الأحد';

  @override
  String get day_sundayShort => 'أحد';

  @override
  String get day_sundayAbbr => 'ح';

  @override
  String time_hours(int count) {
    return '$countس';
  }

  @override
  String time_hoursMinutes(int hours, int minutes) {
    return '$hoursس $minutesد';
  }

  @override
  String time_minutesFormat(String count) {
    return '$count دقيقة';
  }

  @override
  String tooltip_dateScreenTime(String date, int hours, int minutes) {
    return '$date: $hoursس $minutesد';
  }

  @override
  String tooltip_hoursFormat(String count) {
    return '$count ساعة';
  }

  @override
  String get month_january => 'يناير';

  @override
  String get month_januaryShort => 'ينا';

  @override
  String get month_february => 'فبراير';

  @override
  String get month_februaryShort => 'فبر';

  @override
  String get month_march => 'مارس';

  @override
  String get month_marchShort => 'مار';

  @override
  String get month_april => 'أبريل';

  @override
  String get month_aprilShort => 'أبر';

  @override
  String get month_may => 'مايو';

  @override
  String get month_mayShort => 'ماي';

  @override
  String get month_june => 'يونيو';

  @override
  String get month_juneShort => 'يون';

  @override
  String get month_july => 'يوليو';

  @override
  String get month_julyShort => 'يول';

  @override
  String get month_august => 'أغسطس';

  @override
  String get month_augustShort => 'أغس';

  @override
  String get month_september => 'سبتمبر';

  @override
  String get month_septemberShort => 'سبت';

  @override
  String get month_october => 'أكتوبر';

  @override
  String get month_octoberShort => 'أكت';

  @override
  String get month_november => 'نوفمبر';

  @override
  String get month_novemberShort => 'نوف';

  @override
  String get month_december => 'ديسمبر';

  @override
  String get month_decemberShort => 'ديس';

  @override
  String get categoryAll => 'الكل';

  @override
  String get categoryProductivity => 'الإنتاجية';

  @override
  String get categoryDevelopment => 'التطوير';

  @override
  String get categorySocialMedia => 'وسائل التواصل الاجتماعي';

  @override
  String get categoryEntertainment => 'الترفيه';

  @override
  String get categoryGaming => 'الألعاب';

  @override
  String get categoryCommunication => 'التواصل';

  @override
  String get categoryWebBrowsing => 'تصفح الويب';

  @override
  String get categoryCreative => 'الإبداع';

  @override
  String get categoryEducation => 'التعليم';

  @override
  String get categoryUtility => 'الأدوات المساعدة';

  @override
  String get categoryUncategorized => 'غير مصنف';

  @override
  String get appMicrosoftWord => 'مايكروسوفت وورد';

  @override
  String get appExcel => 'إكسل';

  @override
  String get appPowerPoint => 'باوربوينت';

  @override
  String get appGoogleDocs => 'مستندات جوجل';

  @override
  String get appNotion => 'نوشن';

  @override
  String get appEvernote => 'إيفرنوت';

  @override
  String get appTrello => 'تريلو';

  @override
  String get appAsana => 'أسانا';

  @override
  String get appSlack => 'سلاك';

  @override
  String get appMicrosoftTeams => 'مايكروسوفت تيمز';

  @override
  String get appZoom => 'زووم';

  @override
  String get appGoogleCalendar => 'تقويم جوجل';

  @override
  String get appAppleCalendar => 'التقويم';

  @override
  String get appVisualStudioCode => 'فيجوال ستوديو كود';

  @override
  String get appTerminal => 'الطرفية';

  @override
  String get appCommandPrompt => 'موجه الأوامر';

  @override
  String get appChrome => 'كروم';

  @override
  String get appFirefox => 'فايرفوكس';

  @override
  String get appSafari => 'سفاري';

  @override
  String get appEdge => 'إيدج';

  @override
  String get appOpera => 'أوبرا';

  @override
  String get appBrave => 'بريف';

  @override
  String get appNetflix => 'نتفليكس';

  @override
  String get appYouTube => 'يوتيوب';

  @override
  String get appSpotify => 'سبوتيفاي';

  @override
  String get appAppleMusic => 'آبل ميوزك';

  @override
  String get appCalculator => 'الآلة الحاسبة';

  @override
  String get appNotes => 'الملاحظات';

  @override
  String get appSystemPreferences => 'تفضيلات النظام';

  @override
  String get appTaskManager => 'إدارة المهام';

  @override
  String get appFileExplorer => 'مستكشف الملفات';

  @override
  String get appDropbox => 'دروب بوكس';

  @override
  String get appGoogleDrive => 'جوجل درايف';

  @override
  String get loadingApplication => 'جارٍ تحميل التطبيق...';

  @override
  String get loadingData => 'جارٍ تحميل البيانات...';

  @override
  String get reportsError => 'خطأ';

  @override
  String get reportsRetry => 'إعادة المحاولة';

  @override
  String get backupRestoreSection => 'النسخ الاحتياطي والاستعادة';

  @override
  String get backupRestoreTitle => 'النسخ الاحتياطي والاستعادة';

  @override
  String get exportDataTitle => 'تصدير البيانات';

  @override
  String get exportDataDescription => 'إنشاء نسخة احتياطية من جميع بياناتك';

  @override
  String get importDataTitle => 'استيراد البيانات';

  @override
  String get importDataDescription => 'الاستعادة من ملف النسخ الاحتياطي';

  @override
  String get exportButton => 'تصدير';

  @override
  String get importButton => 'استيراد';

  @override
  String get closeButton => 'إغلاق';

  @override
  String get noButton => 'لا';

  @override
  String get shareButton => 'مشاركة';

  @override
  String get exportStarting => 'جارٍ بدء التصدير...';

  @override
  String get exportSuccessful => 'تم التصدير بنجاح';

  @override
  String get exportFailed => 'فشل التصدير';

  @override
  String get exportComplete => 'اكتمل التصدير';

  @override
  String get shareBackupQuestion => 'هل تريد مشاركة ملف النسخ الاحتياطي؟';

  @override
  String get importStarting => 'جارٍ بدء الاستيراد...';

  @override
  String get importSuccessful => 'تم الاستيراد بنجاح!';

  @override
  String get importFailed => 'فشل الاستيراد';

  @override
  String get importOptionsTitle => 'خيارات الاستيراد';

  @override
  String get importOptionsQuestion => 'كيف تريد استيراد البيانات؟';

  @override
  String get replaceModeTitle => 'استبدال';

  @override
  String get replaceModeDescription => 'استبدال جميع البيانات الموجودة';

  @override
  String get mergeModeTitle => 'دمج';

  @override
  String get mergeModeDescription => 'الدمج مع البيانات الموجودة';

  @override
  String get appendModeTitle => 'إلحاق';

  @override
  String get appendModeDescription => 'إضافة السجلات الجديدة فقط';

  @override
  String get warningTitle => '⚠️ تحذير';

  @override
  String get replaceWarningMessage =>
      'سيؤدي هذا إلى استبدال جميع بياناتك الموجودة. هل أنت متأكد أنك تريد المتابعة؟';

  @override
  String get replaceAllButton => 'استبدال الكل';

  @override
  String get fileLabel => 'الملف';

  @override
  String get sizeLabel => 'الحجم';

  @override
  String get recordsLabel => 'السجلات';

  @override
  String get usageRecordsLabel => 'سجلات الاستخدام';

  @override
  String get focusSessionsLabel => 'جلسات التركيز';

  @override
  String get appMetadataLabel => 'بيانات التطبيق الوصفية';

  @override
  String get updatedLabel => 'تم التحديث';

  @override
  String get skippedLabel => 'تم التخطي';

  @override
  String get faqSettingsQ4 => 'كيف يمكنني استعادة أو تصدير بياناتي؟';

  @override
  String get faqSettingsA4 =>
      'يمكنك الذهاب إلى الإعدادات، وهناك ستجد قسم النسخ الاحتياطي والاستعادة. يمكنك تصدير أو استيراد البيانات من هنا، لاحظ أن ملف البيانات المصدّر يتم تخزينه في المستندات في مجلد Scolect-Backups ويمكن استخدام هذا الملف فقط لاستعادة البيانات، ولا يمكن استخدام أي ملف آخر.';

  @override
  String get faqGeneralQ6 =>
      'كيف يمكنني تغيير اللغة وما اللغات المتاحة، وماذا لو وجدت أن الترجمة خاطئة؟';

  @override
  String get faqGeneralA6 =>
      'يمكن تغيير اللغة من خلال قسم الإعدادات العامة، جميع اللغات المتاحة مدرجة هناك، يمكنك طلب ترجمة بالنقر على اتصل بنا وإرسال طلبك مع اللغة المحددة. اعلم أن الترجمة قد تكون خاطئة لأنها مُولّدة بالذكاء الاصطناعي من الإنجليزية وإذا كنت تريد الإبلاغ فيمكنك الإبلاغ من خلال الإبلاغ عن خطأ أو اتصل بنا، أو إذا كنت مطوراً يمكنك فتح مشكلة على جيت هب. المساهمات المتعلقة باللغة مرحب بها أيضاً!';

  @override
  String get faqGeneralQ7 => 'ماذا لو وجدت أن الترجمة خاطئة؟';

  @override
  String get faqGeneralA7 =>
      'قد تكون الترجمة خاطئة لأنها مُولّدة بالذكاء الاصطناعي من الإنجليزية وإذا كنت تريد الإبلاغ فيمكنك الإبلاغ من خلال الإبلاغ عن خطأ أو اتصل بنا، أو إذا كنت مطوراً يمكنك فتح مشكلة على جيت هب. المساهمات المتعلقة باللغة مرحب بها أيضاً!';

  @override
  String get activityTrackingSection => 'تتبع النشاط';

  @override
  String get idleDetectionTitle => 'اكتشاف الخمول';

  @override
  String get idleDetectionDescription => 'إيقاف التتبع عند عدم النشاط';

  @override
  String get idleTimeoutTitle => 'مهلة الخمول';

  @override
  String idleTimeoutDescription(String timeout) {
    return 'الوقت قبل اعتبارك خاملاً ($timeout)';
  }

  @override
  String get advancedWarning =>
      'قد تزيد الميزات المتقدمة من استخدام الموارد. قم بالتمكين فقط إذا لزم الأمر.';

  @override
  String get monitorAudioTitle => 'مراقبة صوت النظام';

  @override
  String get monitorAudioDescription => 'اكتشاف النشاط من تشغيل الصوت';

  @override
  String get audioSensitivityTitle => 'حساسية الصوت';

  @override
  String audioSensitivityDescription(String value) {
    return 'عتبة الاكتشاف ($value)';
  }

  @override
  String get monitorControllersTitle => 'مراقبة أذرع التحكم';

  @override
  String get monitorControllersDescription => 'اكتشاف أذرع تحكم Xbox/XInput';

  @override
  String get monitorHIDTitle => 'مراقبة أجهزة HID';

  @override
  String get monitorHIDDescription =>
      'اكتشاف عجلات القيادة والأجهزة اللوحية والأجهزة المخصصة';

  @override
  String get setIdleTimeoutTitle => 'تعيين مهلة الخمول';

  @override
  String get idleTimeoutDialogDescription =>
      'اختر المدة التي يجب الانتظار قبل اعتبارك خاملاً:';

  @override
  String get seconds30 => '30 ثانية';

  @override
  String get minute1 => 'دقيقة واحدة';

  @override
  String get minutes2 => 'دقيقتان';

  @override
  String get minutes5 => '5 دقائق';

  @override
  String get minutes10 => '10 دقائق';

  @override
  String get customOption => 'مخصص';

  @override
  String get customDurationTitle => 'مدة مخصصة';

  @override
  String get minutesLabel => 'الدقائق';

  @override
  String get secondsLabel => 'الثواني';

  @override
  String get minAbbreviation => 'د';

  @override
  String get secAbbreviation => 'ث';

  @override
  String totalLabel(String duration) {
    return 'الإجمالي: $duration';
  }

  @override
  String minimumError(String value) {
    return 'الحد الأدنى هو $value';
  }

  @override
  String maximumError(String value) {
    return 'الحد الأقصى هو $value';
  }

  @override
  String rangeInfo(String min, String max) {
    return 'النطاق: $min - $max';
  }

  @override
  String get saveButton => 'حفظ';

  @override
  String timeFormatSeconds(int seconds) {
    return '$secondsث';
  }

  @override
  String get timeFormatMinute => '1 د';

  @override
  String timeFormatMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String timeFormatMinutesSeconds(int minutes, int seconds) {
    return '$minutes د $secondsث';
  }

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeTitle => 'المظهر';

  @override
  String get themeDescription => 'نمط ألوان التطبيق';

  @override
  String get voiceGenderTitle => 'جنس الصوت';

  @override
  String get voiceGenderDescription => 'اختر جنس الصوت لإشعارات المؤقت';

  @override
  String get voiceGenderMale => 'ذكر';

  @override
  String get voiceGenderFemale => 'أنثى';

  @override
  String get alertsLimitsSubtitle =>
      'إدارة حدود وقت الشاشة والإشعارات الخاصة بك';

  @override
  String get applicationsSubtitle => 'إدارة التطبيقات المتتبعة الخاصة بك';

  @override
  String applicationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تطبيق',
    );
    return '$_temp0';
  }

  @override
  String get noApplicationsFound => 'لم يتم العثور على تطبيقات';

  @override
  String get tryAdjustingFilters => 'حاول ضبط المرشحات الخاصة بك';

  @override
  String get configureAppSettings => 'تكوين إعدادات التطبيق';

  @override
  String get behaviorSection => 'السلوك';

  @override
  String helpSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سؤال عبر 7 فئات',
    );
    return '$_temp0';
  }

  @override
  String get searchForHelp => 'البحث عن المساعدة...';

  @override
  String get quickNavGeneral => 'عام';

  @override
  String get quickNavApps => 'التطبيقات';

  @override
  String get quickNavReports => 'التقارير';

  @override
  String get quickNavFocus => 'التركيز';

  @override
  String get noResultsFound => 'لم يتم العثور على نتائج';

  @override
  String get tryDifferentKeywords => 'حاول البحث بكلمات مفتاحية مختلفة';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get greetingMorning => 'صباح الخير! هذا ملخص نشاطك.';

  @override
  String get greetingAfternoon => 'مساء الخير! هذا ملخص نشاطك.';

  @override
  String get greetingEvening => 'مساء الخير! هذا ملخص نشاطك.';

  @override
  String get screenTimeProgress => 'وقت\nالشاشة';

  @override
  String get productiveScoreProgress => 'نقاط\nالإنتاجية';

  @override
  String get focusModeSubtitle => 'ابق مركزًا، كن منتجًا';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get sessions => 'الجلسات';

  @override
  String get totalTime => 'الوقت الإجمالي';

  @override
  String get avgLength => 'متوسط المدة';

  @override
  String get focusTime => 'وقت التركيز';

  @override
  String get paused => 'متوقف مؤقتًا';

  @override
  String get shortBreakStatus => 'استراحة قصيرة';

  @override
  String get longBreakStatus => 'استراحة طويلة';

  @override
  String get readyToFocus => 'جاهز للتركيز';

  @override
  String get focus => 'تركيز';

  @override
  String get restartSession => 'إعادة تشغيل الجلسة';

  @override
  String get skipToNext => 'الانتقال إلى التالي';

  @override
  String get settings => 'الإعدادات';

  @override
  String sessionsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جلسة مكتملة',
    );
    return '$_temp0';
  }

  @override
  String get focusModePreset => 'إعداد مسبق لوضع التركيز';

  @override
  String get focusDuration => 'مدة التركيز';

  @override
  String minutesFormat(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get shortBreakDuration => 'استراحة قصيرة';

  @override
  String get longBreakDuration => 'استراحة طويلة';

  @override
  String get enableSounds => 'تفعيل الأصوات';

  @override
  String get focus_mode_this_week => 'هذا الأسبوع';

  @override
  String get focus_mode_best_day => 'أفضل يوم';

  @override
  String focus_mode_sessions_count(int count) {
    return '$count جلسة';
  }

  @override
  String get focus_mode_no_data_yet => 'لا توجد بيانات حتى الآن';

  @override
  String get chart_current => 'الحالي';

  @override
  String get chart_previous => 'السابق';

  @override
  String get permission_error => 'خطأ في الإذن';

  @override
  String get notification_permission_denied => 'تم رفض إذن الإشعار';

  @override
  String get notification_permission_denied_message =>
      'يحتاج ScreenTime إلى إذن الإشعار لإرسال التنبيهات والتذكيرات.\n\nهل تريد فتح إعدادات النظام لتمكين الإشعارات؟';

  @override
  String get notification_permission_denied_hint =>
      'افتح إعدادات النظام لتمكين إشعارات ScreenTime.';

  @override
  String get notification_permission_required => 'مطلوب إذن الإشعار';

  @override
  String get notification_permission_required_message =>
      'يحتاج ScreenTime إلى إذن لإرسال الإشعارات إليك.';

  @override
  String get open_settings => 'فتح الإعدادات';

  @override
  String get allow_notifications => 'السماح بالإشعارات';

  @override
  String get permission_allowed => 'مسموح';

  @override
  String get permission_denied => 'مرفوض';

  @override
  String get permission_not_set => 'غير محدد';

  @override
  String get on => 'تشغيل';

  @override
  String get off => 'إيقاف';

  @override
  String get enable_notification_permission_hint =>
      'قم بتمكين إذن الإشعار لتلقي التنبيهات';

  @override
  String minutes_format(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get chart_average => 'المتوسط';

  @override
  String get chart_peak => 'الذروة';

  @override
  String get chart_lowest => 'الأدنى';

  @override
  String get active => 'نشط';

  @override
  String get disabled => 'معطل';

  @override
  String get advanced_options => 'خيارات متقدمة';

  @override
  String get sync_ready => 'المزامنة جاهزة';

  @override
  String get success => 'نجاح';

  @override
  String get destructive_badge => 'مدمر';

  @override
  String get recommended_badge => 'موصى به';

  @override
  String get safe_badge => 'آمن';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get patterns => 'الأنماط';

  @override
  String get apps => 'التطبيقات';

  @override
  String get sortAscending => 'ترتيب تصاعدي';

  @override
  String get sortDescending => 'ترتيب تنازلي';

  @override
  String applicationsShowing(int count) {
    return 'عرض $count تطبيق';
  }

  @override
  String valueLabel(String value) {
    return 'القيمة: $value';
  }

  @override
  String appsCount(int count) {
    return '$count تطبيق';
  }

  @override
  String categoriesCount(int count) {
    return '$count فئة';
  }

  @override
  String get systemNotificationsDisabled =>
      'تم تعطيل إشعارات النظام. قم بتمكينها في إعدادات النظام لتنبيهات التركيز.';

  @override
  String get openSystemSettings => 'فتح إعدادات النظام';

  @override
  String get appNotificationsDisabled =>
      'تم تعطيل الإشعارات في إعدادات التطبيق. قم بتمكينها لتلقي تنبيهات التركيز.';

  @override
  String get goToSettings => 'الانتقال إلى الإعدادات';

  @override
  String get focusModeNotificationsDisabled =>
      'تم تعطيل إشعارات وضع التركيز. قم بتمكينها لتلقي تنبيهات الجلسة.';

  @override
  String get notificationsDisabled => 'الإشعارات معطلة';

  @override
  String get dontShowAgain => 'لا تظهر مرة أخرى';

  @override
  String get systemSettingsRequired => 'مطلوب إعدادات النظام';

  @override
  String get notificationsDisabledSystemLevel =>
      'تم تعطيل الإشعارات على مستوى النظام. للتمكين:';

  @override
  String get step1OpenSystemSettings =>
      '1. افتح إعدادات النظام (تفضيلات النظام)';

  @override
  String get step2GoToNotifications => '2. انتقل إلى الإشعارات';

  @override
  String get step3FindApp => '3. ابحث عن Scolect وحدده';

  @override
  String get step4EnableNotifications => '4. قم بتمكين \"السماح بالإشعارات\"';

  @override
  String get returnToAppMessage => 'ثم عد إلى هذا التطبيق وستعمل الإشعارات.';

  @override
  String get gotIt => 'فهمت';

  @override
  String get noSessionsYet => 'لا توجد جلسات حتى الآن';

  @override
  String applicationsTracked(int count) {
    return 'تم تتبع $count تطبيق';
  }

  @override
  String get applicationHeader => 'التطبيق';

  @override
  String get currentUsageHeader => 'الاستخدام الحالي';

  @override
  String get dailyLimitHeader => 'الحد اليومي';

  @override
  String get edit => 'تحرير';

  @override
  String get showPopupNotifications => 'عرض الإشعارات المنبثقة';

  @override
  String get moreFrequentReminders => 'تذكيرات أكثر تكرارًا';

  @override
  String get playSoundWithAlerts => 'تشغيل الصوت مع التنبيهات';

  @override
  String get systemTrayNotifications => 'إشعارات علبة النظام';

  @override
  String screenTimeUsed(String current, String limit) {
    return 'تم استخدام $current / $limit';
  }

  @override
  String get todaysScreenTime => 'وقت الشاشة اليوم';

  @override
  String get activeLimits => 'الحدود النشطة';

  @override
  String get nearLimit => 'قريب من الحد';

  @override
  String get colorPickerSpectrum => 'الطيف';

  @override
  String get colorPickerPresets => 'الإعدادات المسبقة';

  @override
  String get colorPickerSliders => 'أشرطة التمرير';

  @override
  String get colorPickerBasicColors => 'الألوان الأساسية';

  @override
  String get colorPickerExtendedPalette => 'لوحة الألوان الموسعة';

  @override
  String get colorPickerRed => 'أحمر';

  @override
  String get colorPickerGreen => 'أخضر';

  @override
  String get colorPickerBlue => 'أزرق';

  @override
  String get colorPickerHue => 'درجة اللون';

  @override
  String get colorPickerSaturation => 'التشبع';

  @override
  String get colorPickerBrightness => 'السطوع';

  @override
  String get colorPickerHexColor => 'اللون السداسي عشري';

  @override
  String get colorPickerHexPlaceholder => 'RRGGBB';

  @override
  String get colorPickerRGB => 'RGB';

  @override
  String get select => 'تحديد';

  @override
  String get themeCustomization => 'تخصيص السمة';

  @override
  String get chooseThemePreset => 'اختر إعداداً مسبقاً للسمة';

  @override
  String get yourCustomThemes => 'السمات المخصصة الخاصة بك';

  @override
  String get createCustomTheme => 'إنشاء سمة مخصصة';

  @override
  String get designOwnColorScheme => 'صمم نظام الألوان الخاص بك';

  @override
  String get newTheme => 'سمة جديدة';

  @override
  String get editCurrentTheme => 'تحرير السمة الحالية';

  @override
  String customizeColorsFor(String themeName) {
    return 'تخصيص الألوان لـ $themeName';
  }

  @override
  String customThemeNumber(int number) {
    return 'السمة المخصصة $number';
  }

  @override
  String get deleteCustomTheme => 'حذف السمة المخصصة';

  @override
  String confirmDeleteTheme(String themeName) {
    return 'هل أنت متأكد من أنك تريد حذف \"$themeName\"؟';
  }

  @override
  String get delete => 'حذف';

  @override
  String get customizeTheme => 'تخصيص السمة';

  @override
  String get preview => 'معاينة';

  @override
  String get themeName => 'اسم السمة';

  @override
  String get brandColors => 'ألوان العلامة التجارية';

  @override
  String get lightTheme => 'السمة الفاتحة';

  @override
  String get darkTheme => 'السمة الداكنة';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get saveTheme => 'حفظ السمة';

  @override
  String get customTheme => 'سمة مخصصة';

  @override
  String get primaryColors => 'الألوان الأساسية';

  @override
  String get primaryColorsDesc =>
      'ألوان التمييز الرئيسية المستخدمة في جميع أنحاء التطبيق';

  @override
  String get primaryAccent => 'التمييز الأساسي';

  @override
  String get primaryAccentDesc =>
      'لون العلامة التجارية الرئيسي، الأزرار، الروابط';

  @override
  String get secondaryAccent => 'التمييز الثانوي';

  @override
  String get secondaryAccentDesc => 'تمييز تكميلي للتدرجات';

  @override
  String get semanticColors => 'الألوان الدلالية';

  @override
  String get semanticColorsDesc => 'الألوان التي تنقل المعنى والحالة';

  @override
  String get successColor => 'لون النجاح';

  @override
  String get successColorDesc => 'الإجراءات الإيجابية، التأكيدات';

  @override
  String get warningColor => 'لون التحذير';

  @override
  String get warningColorDesc => 'التحذير، الحالات المعلقة';

  @override
  String get errorColor => 'لون الخطأ';

  @override
  String get errorColorDesc => 'الأخطاء، الإجراءات المدمرة';

  @override
  String get backgroundColors => 'ألوان الخلفية';

  @override
  String get backgroundColorsLightDesc => 'أسطح الخلفية الرئيسية للوضع الفاتح';

  @override
  String get backgroundColorsDarkDesc => 'أسطح الخلفية الرئيسية للوضع الداكن';

  @override
  String get background => 'الخلفية';

  @override
  String get backgroundDesc => 'خلفية التطبيق الرئيسية';

  @override
  String get surface => 'السطح';

  @override
  String get surfaceDesc => 'البطاقات، مربعات الحوار، الأسطح المرتفعة';

  @override
  String get surfaceSecondary => 'السطح الثانوي';

  @override
  String get surfaceSecondaryDesc => 'البطاقات الثانوية، الأشرطة الجانبية';

  @override
  String get border => 'الحدود';

  @override
  String get borderDesc => 'الفواصل، حدود البطاقات';

  @override
  String get textColors => 'ألوان النص';

  @override
  String get textColorsLightDesc => 'ألوان الطباعة للوضع الفاتح';

  @override
  String get textColorsDarkDesc => 'ألوان الطباعة للوضع الداكن';

  @override
  String get textPrimary => 'النص الأساسي';

  @override
  String get textPrimaryDesc => 'العناوين، النص المهم';

  @override
  String get textSecondary => 'النص الثانوي';

  @override
  String get textSecondaryDesc => 'الأوصاف، التسميات التوضيحية';

  @override
  String previewMode(String mode) {
    return 'المعاينة: وضع $mode';
  }

  @override
  String get dark => 'داكن';

  @override
  String get light => 'فاتح';

  @override
  String get sampleCardTitle => 'عنوان البطاقة النموذجية';

  @override
  String get sampleSecondaryText => 'هذا نص ثانوي يظهر أدناه.';

  @override
  String get primary => 'أساسي';

  @override
  String get secondary => 'ثانوي';

  @override
  String get warning => 'تحذير';

  @override
  String get launchAtStartupTitle => 'التشغيل عند بدء التشغيل';

  @override
  String get launchAtStartupDescription =>
      'بدء Scolect تلقائيًا عند تسجيل الدخول إلى جهاز الكمبيوتر الخاص بك';

  @override
  String get inputMonitoringPermissionTitle => 'مراقبة لوحة المفاتيح غير متاحة';

  @override
  String get inputMonitoringPermissionDescription =>
      'يرجى تمكين إذن مراقبة الإدخال لتتبع نشاط لوحة المفاتيح. يتم حاليًا مراقبة إدخال الماوس فقط.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get permissionGrantedTitle => 'تم منح الإذن';

  @override
  String get permissionGrantedDescription =>
      'يجب إعادة تشغيل التطبيق لتفعيل مراقبة الإدخال.';

  @override
  String get continueButton => 'متابعة';

  @override
  String get restartRequiredTitle => 'إعادة التشغيل مطلوبة';

  @override
  String get restartRequiredDescription =>
      'لتفعيل مراقبة لوحة المفاتيح، يجب إعادة تشغيل التطبيق. هذا مطلوب من قبل macOS.';

  @override
  String get restartNote =>
      'سيتم إعادة تشغيل التطبيق تلقائيًا بعد إعادة التشغيل.';

  @override
  String get restartNow => 'إعادة التشغيل الآن';

  @override
  String get restartLater => 'إعادة التشغيل لاحقًا';

  @override
  String get restartFailedTitle => 'فشل إعادة التشغيل';

  @override
  String get restartFailedMessage =>
      'تعذر إعادة تشغيل التطبيق تلقائيًا. يرجى الخروج (Cmd+Q) وإعادة تشغيله يدويًا.';

  @override
  String get exportAnalyticsReport => 'تصدير تقرير التحليلات';

  @override
  String get chooseExportFormat => 'اختر صيغة التصدير:';

  @override
  String get beautifulExcelReport => 'تقرير إكسل جميل';

  @override
  String get beautifulExcelReportDescription =>
      'جدول بيانات ملون وجميل مع رسوم بيانية ورموز تعبيرية ورؤى ✨';

  @override
  String get excelReportIncludes => 'يتضمن تقرير الإكسل:';

  @override
  String get summarySheetDescription =>
      '📊 ورقة الملخص - المقاييس الرئيسية مع الاتجاهات';

  @override
  String get dailyBreakdownDescription =>
      '📅 التفصيل اليومي - أنماط الاستخدام المرئية';

  @override
  String get appsSheetDescription =>
      '📱 ورقة التطبيقات - تصنيفات التطبيقات التفصيلية';

  @override
  String get insightsDescription => '💡 رؤى - توصيات ذكية';

  @override
  String get beautifulExcelExportSuccess =>
      'تم تصدير تقرير الإكسل الجميل بنجاح! 🎉';

  @override
  String failedToExportReport(String error) {
    return 'فشل في تصدير التقرير: $error';
  }

  @override
  String get exporting => 'جاري التصدير...';

  @override
  String get exportExcel => 'تصدير إكسل';

  @override
  String get saveAnalyticsReport => 'حفظ تقرير التحليلات';

  @override
  String analyticsReportFileName(String timestamp) {
    return 'تقرير_التحليلات_$timestamp.xlsx';
  }

  @override
  String get usageAnalyticsReportTitle => 'تقرير تحليل الاستخدام';

  @override
  String get generated => 'تم الإنشاء:';

  @override
  String get period => 'الفترة:';

  @override
  String dateRangeValue(String startDate, String endDate) {
    return '$startDate إلى $endDate';
  }

  @override
  String get keyMetrics => 'المقاييس الرئيسية';

  @override
  String get metric => 'المقياس';

  @override
  String get value => 'القيمة';

  @override
  String get change => 'التغيير';

  @override
  String get trend => 'الاتجاه';

  @override
  String get productivityRate => 'معدل الإنتاجية';

  @override
  String get trendUp => 'ارتفاع';

  @override
  String get trendDown => 'انخفاض';

  @override
  String get trendExcellent => 'ممتاز';

  @override
  String get trendGood => 'جيد';

  @override
  String get trendNeedsImprovement => 'يحتاج تحسين';

  @override
  String get trendActive => 'نشط';

  @override
  String get trendNone => 'لا يوجد';

  @override
  String get trendTop => 'الأعلى';

  @override
  String get category => 'الفئة';

  @override
  String get percentage => 'النسبة المئوية';

  @override
  String get visual => 'مرئي';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get averageDaily => 'المعدل اليومي';

  @override
  String get highestDay => 'أعلى يوم';

  @override
  String get lowestDay => 'أدنى يوم';

  @override
  String get day => 'اليوم';

  @override
  String get applicationUsageDetails => 'تفاصيل استخدام التطبيقات';

  @override
  String get totalApps => 'إجمالي التطبيقات:';

  @override
  String get productiveApps => 'التطبيقات المنتجة:';

  @override
  String get rank => 'الترتيب';

  @override
  String get application => 'التطبيق';

  @override
  String get time => 'الوقت';

  @override
  String get percentOfTotal => '% من الإجمالي';

  @override
  String get type => 'النوع';

  @override
  String get usageLevel => 'مستوى الاستخدام';

  @override
  String get leisure => 'ترفيه';

  @override
  String get usageLevelVeryHigh => 'عالي جداً ||||||||';

  @override
  String get usageLevelHigh => 'عالي ||||||';

  @override
  String get usageLevelMedium => 'متوسط ||||';

  @override
  String get usageLevelLow => 'منخفض ||';

  @override
  String get keyInsightsTitle => 'الرؤى والتوصيات الرئيسية';

  @override
  String get personalizedRecommendations => 'توصيات مخصصة';

  @override
  String insightHighDailyUsage(String hours) {
    return 'استخدام يومي مرتفع: أنت تستخدم في المتوسط $hours ساعات يومياً من وقت الشاشة';
  }

  @override
  String insightLowDailyUsage(String hours) {
    return 'استخدام يومي منخفض: أنت تستخدم في المتوسط $hours ساعات يومياً - توازن رائع!';
  }

  @override
  String insightModerateUsage(String hours) {
    return 'استخدام معتدل: في المتوسط $hours ساعات يومياً من وقت الشاشة';
  }

  @override
  String insightExcellentProductivity(String percentage) {
    return 'إنتاجية ممتازة: $percentage% من وقت شاشتك هو عمل منتج!';
  }

  @override
  String insightGoodProductivity(String percentage) {
    return 'إنتاجية جيدة: $percentage% من وقت شاشتك منتج';
  }

  @override
  String insightLowProductivity(String percentage) {
    return 'تنبيه إنتاجية منخفضة: فقط $percentage% من وقت الشاشة منتج';
  }

  @override
  String insightFocusSessions(int count, String avgPerDay) {
    return 'جلسات التركيز: أكملت $count جلسة ($avgPerDay في اليوم في المتوسط)';
  }

  @override
  String insightGreatFocusHabit(int count) {
    return 'عادة تركيز رائعة: لقد بنيت روتين تركيز مذهل مع $count جلسة مكتملة!';
  }

  @override
  String get insightNoFocusSessions =>
      'لا توجد جلسات تركيز: فكر في استخدام وضع التركيز لتعزيز إنتاجيتك';

  @override
  String insightScreenTimeTrend(String direction, String percentage) {
    return 'اتجاه وقت الشاشة: استخدامك $direction بنسبة $percentage% مقارنة بالفترة السابقة';
  }

  @override
  String insightProductiveTimeTrend(String direction, String percentage) {
    return 'اتجاه الوقت المنتج: وقتك المنتج $direction بنسبة $percentage% مقارنة بالفترة السابقة';
  }

  @override
  String get directionIncreased => 'زاد';

  @override
  String get directionDecreased => 'انخفض';

  @override
  String insightTopCategory(String category, String percentage) {
    return 'الفئة الأعلى: $category تهيمن بنسبة $percentage% من إجمالي وقتك';
  }

  @override
  String insightMostUsedApp(
      String appName, String percentage, String duration) {
    return 'التطبيق الأكثر استخداماً: $appName يمثل $percentage% من وقتك ($duration)';
  }

  @override
  String insightUsageVaries(String highDay, String multiplier, String lowDay) {
    return 'الاستخدام يختلف بشكل كبير: $highDay كان لديه استخدام أكثر بـ$multiplier مرة من $lowDay';
  }

  @override
  String get insightNoInsights => 'لا تتوفر رؤى مهمة';

  @override
  String get recScheduleFocusSessions =>
      'حاول جدولة المزيد من جلسات التركيز طوال يومك لتعزيز الإنتاجية';

  @override
  String get recSetAppLimits => 'فكر في وضع حدود على تطبيقات الترفيه';

  @override
  String get recAimForFocusSessions =>
      'اهدف إلى 1-2 جلسة تركيز على الأقل يومياً لبناء عادة ثابتة';

  @override
  String get recTakeBreaks =>
      'وقت شاشتك اليومي مرتفع جداً. حاول أخذ فترات راحة منتظمة باستخدام قاعدة 20-20-20';

  @override
  String get recSetDailyGoals =>
      'فكر في تحديد أهداف يومية لوقت الشاشة لتقليل الاستخدام تدريجياً';

  @override
  String get recBalanceEntertainment =>
      'تطبيقات الترفيه تستهلك جزءاً كبيراً من وقتك. فكر في التوازن مع أنشطة أكثر إنتاجية';

  @override
  String get recReviewUsagePatterns =>
      'زاد وقت شاشتك بشكل كبير. راجع أنماط استخدامك وضع حدوداً';

  @override
  String get recScheduleFocusedWork =>
      'انخفض وقتك المنتج. حاول جدولة فترات عمل مركزة في تقويمك';

  @override
  String get recKeepUpGreatWork =>
      'واصل العمل الرائع! عادات وقت الشاشة لديك تبدو صحية';

  @override
  String get recContinueFocusSessions =>
      'استمر في استخدام جلسات التركيز للحفاظ على الإنتاجية';

  @override
  String get sheetSummary => 'الملخص';

  @override
  String get sheetDailyBreakdown => 'التفصيل اليومي';

  @override
  String get sheetApps => 'التطبيقات';

  @override
  String get sheetInsights => 'الرؤى';

  @override
  String get statusHeader => 'الحالة';

  @override
  String workSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جلسات عمل',
      one: 'جلسة عمل واحدة',
    );
    return '$_temp0';
  }

  @override
  String get complete => 'مكتمل';

  @override
  String get inProgress => 'قيد التقدم';

  @override
  String get workTime => 'وقت العمل';

  @override
  String get breakTime => 'وقت الاستراحة';

  @override
  String get phasesCompleted => 'المراحل المكتملة';

  @override
  String hourMinuteFormat(String hours, String minutes) {
    return '$hours ساعة $minutes دقيقة';
  }

  @override
  String hourOnlyFormat(String hours) {
    return '$hours ساعة';
  }

  @override
  String minuteFormat(String minutes) {
    return '$minutes دقيقة';
  }

  @override
  String sessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جلسات',
      one: 'جلسة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get workPhases => 'مراحل العمل';

  @override
  String get averageLength => 'متوسط المدة';

  @override
  String get mostProductive => 'الأكثر إنتاجية';

  @override
  String get work => 'عمل';

  @override
  String get breaks => 'استراحات';

  @override
  String get none => 'لا يوجد';

  @override
  String minuteShortFormat(String minutes) {
    return '$minutesد';
  }

  @override
  String get importTheme => 'استيراد السمة';

  @override
  String get exportTheme => 'تصدير السمة';

  @override
  String get import => 'استيراد';

  @override
  String get export => 'تصدير';

  @override
  String get chooseExportMethod => 'اختر طريقة تصدير السمة:';

  @override
  String get saveAsFile => 'حفظ كملف';

  @override
  String get saveThemeAsJSONFile => 'حفظ السمة كملف JSON على جهازك';

  @override
  String get copyToClipboard => 'نسخ إلى الحافظة';

  @override
  String get copyThemeJSONToClipboard => 'نسخ بيانات السمة إلى الحافظة';

  @override
  String get share => 'مشاركة';

  @override
  String get shareThemeViaSystemSheet =>
      'مشاركة السمة باستخدام ورقة المشاركة للنظام';

  @override
  String get chooseImportMethod => 'اختر طريقة استيراد السمة:';

  @override
  String get loadFromFile => 'تحميل من ملف';

  @override
  String get selectJSONFileFromDevice => 'اختر ملف JSON للسمة من جهازك';

  @override
  String get pasteFromClipboard => 'لصق من الحافظة';

  @override
  String get importFromClipboardJSON =>
      'استيراد السمة من بيانات JSON في الحافظة';

  @override
  String get importFromFile => 'استيراد السمة من ملف';

  @override
  String get themeCreatedSuccessfully => 'تم إنشاء السمة بنجاح!';

  @override
  String get themeUpdatedSuccessfully => 'تم تحديث السمة بنجاح!';

  @override
  String get themeDeletedSuccessfully => 'تم حذف السمة بنجاح!';

  @override
  String get themeExportedSuccessfully => 'تم تصدير السمة بنجاح!';

  @override
  String get themeCopiedToClipboard => 'تم نسخ السمة إلى الحافظة!';

  @override
  String themeImportedSuccessfully(String themeName) {
    return 'تم استيراد السمة \"$themeName\" بنجاح!';
  }

  @override
  String get noThemeDataFound => 'لم يتم العثور على بيانات السمة';

  @override
  String get invalidThemeFormat =>
      'تنسيق السمة غير صالح. يرجى التحقق من بيانات JSON.';

  @override
  String get trackingModeTitle => 'وضع التتبع';

  @override
  String get trackingModeDescription => 'اختر كيفية تتبع استخدام التطبيق';

  @override
  String get trackingModePolling => 'قياسي (موارد منخفضة)';

  @override
  String get trackingModePrecise => 'دقيق (دقة عالية)';

  @override
  String get trackingModePollingHint => 'يتحقق كل دقيقة - استخدام أقل للموارد';

  @override
  String get trackingModePreciseHint =>
      'تتبع في الوقت الفعلي - دقة أعلى، موارد أكثر';

  @override
  String get trackingModeChangeError =>
      'فشل في تغيير وضع التتبع. يرجى المحاولة مرة أخرى.';

  @override
  String get errorTitle => 'خطأ';

  @override
  String get monitorKeyboardTitle => 'مراقبة لوحة المفاتيح';

  @override
  String get monitorKeyboardDescription =>
      'تتبع نشاط لوحة المفاتيح لاكتشاف وجود المستخدم';

  @override
  String get changelogWhatsNew => 'ما الجديد';

  @override
  String changelogReleasedOn(String date) {
    return 'صدر في $date';
  }

  @override
  String get changelogNoContent => 'لا يتوفر سجل تغييرات لهذا الإصدار.';

  @override
  String get changelogUnableToLoad => 'تعذر تحميل سجل التغييرات';

  @override
  String get changelogErrorDescription =>
      'تعذر استرداد سجل التغييرات لهذا الإصدار. يرجى التحقق من اتصالك بالإنترنت أو زيارة صفحة الإصدارات على GitHub.';

  @override
  String get allTracking => 'كل التطبيقات';

  @override
  String get notTracking => 'غير متتبعة';

  @override
  String get allVisibility => 'الكل';

  @override
  String get visible => 'مرئية';

  @override
  String get hidden => 'مخفية';

  @override
  String get todaysLimitUsage => 'استخدام الحد اليومي';

  @override
  String get thisWeekAtAGlance => 'نظرة على هذا الأسبوع';

  @override
  String get hourlyActivityHeatmap => 'خريطة النشاط بالساعة';

  @override
  String get productivityScore => 'درجة الإنتاجية';

  @override
  String get streaks => 'الأيام المتتالية';

  @override
  String get weekOverWeek => 'مقارنة أسبوعية';

  @override
  String get sameAsLastWeek => 'مثل الأسبوع الماضي';

  @override
  String moreUsageThanLastWeek(String percent) {
    return 'أكثر بنسبة $percent% من الأسبوع الماضي';
  }

  @override
  String lessUsageThanLastWeek(String percent) {
    return 'أقل بنسبة $percent% من الأسبوع الماضي';
  }

  @override
  String limitExceededBy(String duration) {
    return 'تم تجاوز الحد بمقدار $duration';
  }

  @override
  String timeRemaining(String duration) {
    return 'متبقي $duration';
  }

  @override
  String get totalSessions => 'إجمالي الجلسات';

  @override
  String get avgSession => 'متوسط الجلسة';

  @override
  String get mostActive => 'الأكثر نشاطًا';

  @override
  String get peakUsage => 'ذروة الاستخدام';

  @override
  String get dailyAverage => 'المتوسط اليومي';

  @override
  String get daysUsedInARow => 'أيام استخدام متتالية';

  @override
  String get daysSingular => 'يوم';

  @override
  String get daysPlural => 'أيام';

  @override
  String get daysOverLimitInARow => 'أيام متتالية فوق الحد';

  @override
  String get withinLimitAllWeek => 'ضمن الحد طوال الأسبوع';

  @override
  String get productivityScoreGreat => 'ممتاز';

  @override
  String get productivityScoreModerate => 'متوسط';

  @override
  String get productivityScoreNeedsAttention => 'يحتاج انتباه';

  @override
  String get productiveAppMotivation => 'تطبيق منتج — استمر';

  @override
  String get nonProductiveAppSuggestion => 'غير منتج — فكّر في تقليل الاستخدام';

  @override
  String get legendUsage => 'الاستخدام';

  @override
  String get legendAverage => 'المتوسط';

  @override
  String get legendLimit => 'الحد';

  @override
  String get chartPeak => 'الذروة';

  @override
  String overLimitBy(String duration) {
    return '+$duration فوق الحد';
  }

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get yesterday => 'أمس';

  @override
  String get changelog => 'Changelog';
}
