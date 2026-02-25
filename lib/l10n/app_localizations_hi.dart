// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appWindowTitle => 'Scolect - स्क्रीन टाइम और ऐप उपयोग ट्रैक करें';

  @override
  String get appName => 'Scolect';

  @override
  String get appTitle => 'उत्पादक स्क्रीनटाइम';

  @override
  String get sidebarTitle => 'स्क्रीनटाइम';

  @override
  String get sidebarSubtitle => 'ओपन सोर्स';

  @override
  String get trayShowWindow => 'विंडो दिखाएं';

  @override
  String get trayStartFocusMode => 'फोकस मोड शुरू करें';

  @override
  String get trayStopFocusMode => 'फोकस मोड बंद करें';

  @override
  String get trayReports => 'रिपोर्ट';

  @override
  String get trayAlertsLimits => 'अलर्ट और सीमाएं';

  @override
  String get trayApplications => 'एप्लिकेशन';

  @override
  String get trayDisableNotifications => 'नोटिफिकेशन बंद करें';

  @override
  String get trayEnableNotifications => 'नोटिफिकेशन चालू करें';

  @override
  String get trayVersionPrefix => 'संस्करण: ';

  @override
  String trayVersion(String version) {
    return 'संस्करण: $version';
  }

  @override
  String get trayExit => 'बाहर निकलें';

  @override
  String get navOverview => 'अवलोकन';

  @override
  String get navApplications => 'एप्लिकेशन';

  @override
  String get navAlertsLimits => 'अलर्ट और सीमाएं';

  @override
  String get navReports => 'रिपोर्ट';

  @override
  String get navFocusMode => 'फोकस मोड';

  @override
  String get navSettings => 'सेटिंग्स';

  @override
  String get navHelp => 'मदद';

  @override
  String get helpTitle => 'मदद';

  @override
  String get faqCategoryGeneral => 'सामान्य प्रश्न';

  @override
  String get faqCategoryApplications => 'एप्लिकेशन प्रबंधन';

  @override
  String get faqCategoryReports => 'उपयोग विश्लेषण और रिपोर्ट';

  @override
  String get faqCategoryAlerts => 'अलर्ट और सीमाएं';

  @override
  String get faqCategoryFocusMode => 'फोकस मोड और पोमोडोरो टाइमर';

  @override
  String get faqCategorySettings => 'सेटिंग्स और अनुकूलन';

  @override
  String get faqCategoryTroubleshooting => 'समस्या निवारण';

  @override
  String get faqGeneralQ1 => 'यह ऐप स्क्रीन टाइम कैसे ट्रैक करता है?';

  @override
  String get faqGeneralA1 =>
      'ऐप आपके डिवाइस के उपयोग को रियल-टाइम में मॉनिटर करता है, विभिन्न एप्लिकेशन पर बिताए गए समय को ट्रैक करता है। यह आपकी डिजिटल आदतों के बारे में व्यापक जानकारी प्रदान करता है, जिसमें कुल स्क्रीन टाइम, उत्पादक समय और एप्लिकेशन-विशिष्ट उपयोग शामिल है।';

  @override
  String get faqGeneralQ2 => 'किसी ऐप को \'उत्पादक\' क्या बनाता है?';

  @override
  String get faqGeneralA2 =>
      'आप \'एप्लिकेशन\' सेक्शन में ऐप्स को मैन्युअल रूप से उत्पादक के रूप में चिह्नित कर सकते हैं। उत्पादक ऐप्स आपके उत्पादकता स्कोर में योगदान करते हैं, जो काम से संबंधित या लाभदायक एप्लिकेशन पर बिताए गए स्क्रीन टाइम का प्रतिशत गणना करता है।';

  @override
  String get faqGeneralQ3 => 'स्क्रीन टाइम ट्रैकिंग कितनी सटीक है?';

  @override
  String get faqGeneralA3 =>
      'ऐप आपके डिवाइस उपयोग का सटीक माप प्रदान करने के लिए सिस्टम-लेवल ट्रैकिंग का उपयोग करता है। यह न्यूनतम बैटरी प्रभाव के साथ प्रत्येक एप्लिकेशन के फोरग्राउंड समय को कैप्चर करता है।';

  @override
  String get faqGeneralQ4 =>
      'क्या मैं अपनी ऐप श्रेणीकरण को अनुकूलित कर सकता हूं?';

  @override
  String get faqGeneralA4 =>
      'बिल्कुल! आप कस्टम श्रेणियां बना सकते हैं, ऐप्स को विशिष्ट श्रेणियों में असाइन कर सकते हैं, और \'एप्लिकेशन\' सेक्शन में इन असाइनमेंट को आसानी से संशोधित कर सकते हैं। यह अधिक सार्थक उपयोग विश्लेषण बनाने में मदद करता है।';

  @override
  String get faqGeneralQ5 => 'मुझे इस ऐप से कौन सी जानकारी मिल सकती है?';

  @override
  String get faqGeneralA5 =>
      'ऐप व्यापक जानकारी प्रदान करता है जिसमें उत्पादकता स्कोर, दिन के समय के अनुसार उपयोग पैटर्न, विस्तृत एप्लिकेशन उपयोग, फोकस सेशन ट्रैकिंग, और आपकी डिजिटल आदतों को समझने और सुधारने में मदद करने के लिए ग्राफ और पाई चार्ट जैसे विजुअल एनालिटिक्स शामिल हैं।';

  @override
  String get faqAppsQ1 => 'मैं विशिष्ट ऐप्स को ट्रैकिंग से कैसे छिपाऊं?';

  @override
  String get faqAppsA1 =>
      '\'एप्लिकेशन\' सेक्शन में, आप ऐप्स की दृश्यता को टॉगल कर सकते हैं।';

  @override
  String get faqAppsQ2 => 'क्या मैं अपने एप्लिकेशन खोज और फिल्टर कर सकता हूं?';

  @override
  String get faqAppsA2 =>
      'हां, एप्लिकेशन सेक्शन में सर्च फंक्शनालिटी और फिल्टरिंग ऑप्शन शामिल हैं। आप श्रेणी, उत्पादकता स्थिति, ट्रैकिंग स्थिति और दृश्यता के आधार पर ऐप्स फिल्टर कर सकते हैं।';

  @override
  String get faqAppsQ3 => 'एप्लिकेशन के लिए कौन से एडिटिंग विकल्प उपलब्ध हैं?';

  @override
  String get faqAppsA3 =>
      'प्रत्येक एप्लिकेशन के लिए, आप एडिट कर सकते हैं: श्रेणी असाइनमेंट, उत्पादकता स्थिति, उपयोग ट्रैकिंग, रिपोर्ट में दृश्यता, और व्यक्तिगत दैनिक समय सीमा सेट करें।';

  @override
  String get faqAppsQ4 => 'एप्लिकेशन श्रेणियां कैसे निर्धारित होती हैं?';

  @override
  String get faqAppsA4 =>
      'प्रारंभिक श्रेणियां सिस्टम-सुझाई गई हैं, लेकिन आपके पास अपने वर्कफ्लो और प्राथमिकताओं के आधार पर कस्टम श्रेणियां बनाने, संशोधित करने और असाइन करने का पूर्ण नियंत्रण है।';

  @override
  String get faqReportsQ1 => 'किस प्रकार की रिपोर्ट उपलब्ध हैं?';

  @override
  String get faqReportsA1 =>
      'रिपोर्ट में शामिल हैं: कुल स्क्रीन टाइम, उत्पादक समय, सबसे अधिक उपयोग किए गए ऐप्स, फोकस सेशन, दैनिक स्क्रीन टाइम ग्राफ, श्रेणी ब्रेकडाउन पाई चार्ट, विस्तृत एप्लिकेशन उपयोग, साप्ताहिक उपयोग ट्रेंड, और दिन के समय के अनुसार उपयोग पैटर्न विश्लेषण।';

  @override
  String get faqReportsQ2 => 'एप्लिकेशन उपयोग रिपोर्ट कितनी विस्तृत हैं?';

  @override
  String get faqReportsA2 =>
      'विस्तृत एप्लिकेशन उपयोग रिपोर्ट दिखाती हैं: ऐप नाम, श्रेणी, बिताया गया कुल समय, उत्पादकता स्थिति, और उपयोग सारांश, दैनिक सीमाएं, उपयोग ट्रेंड, और उत्पादकता मेट्रिक्स जैसी गहरी जानकारी के साथ \'एक्शन\' सेक्शन प्रदान करती हैं।';

  @override
  String get faqReportsQ3 =>
      'क्या मैं समय के साथ अपने उपयोग ट्रेंड का विश्लेषण कर सकता हूं?';

  @override
  String get faqReportsA3 =>
      'हां! ऐप सप्ताह-दर-सप्ताह तुलना प्रदान करता है, पिछले हफ्तों के उपयोग के ग्राफ, औसत दैनिक उपयोग, सबसे लंबे सेशन, और साप्ताहिक कुल दिखाता है ताकि आप अपनी डिजिटल आदतों को ट्रैक कर सकें।';

  @override
  String get faqReportsQ4 => '\'उपयोग पैटर्न\' विश्लेषण क्या है?';

  @override
  String get faqReportsA4 =>
      'उपयोग पैटर्न आपके स्क्रीन टाइम को सुबह, दोपहर, शाम और रात के खंडों में विभाजित करता है। यह आपको समझने में मदद करता है कि आप अपने डिवाइस पर कब सबसे अधिक सक्रिय हैं और सुधार के संभावित क्षेत्रों की पहचान करता है।';

  @override
  String get faqAlertsQ1 => 'स्क्रीन टाइम सीमाएं कितनी विस्तृत हैं?';

  @override
  String get faqAlertsA1 =>
      'आप समग्र दैनिक स्क्रीन टाइम सीमाएं और व्यक्तिगत ऐप सीमाएं सेट कर सकते हैं। सीमाएं घंटों और मिनटों में कॉन्फ़िगर की जा सकती हैं, आवश्यकतानुसार रीसेट या समायोजित करने के विकल्पों के साथ।';

  @override
  String get faqAlertsQ2 => 'कौन से नोटिफिकेशन विकल्प उपलब्ध हैं?';

  @override
  String get faqAlertsA2 =>
      'ऐप कई प्रकार के नोटिफिकेशन प्रदान करता है: स्क्रीन टाइम पार करने पर सिस्टम अलर्ट, अनुकूलन योग्य अंतराल (1, 5, 15, 30, या 60 मिनट) पर बार-बार अलर्ट, और फोकस मोड, स्क्रीन टाइम, और एप्लिकेशन-विशिष्ट नोटिफिकेशन के लिए टॉगल।';

  @override
  String get faqAlertsQ3 => 'क्या मैं सीमा अलर्ट को अनुकूलित कर सकता हूं?';

  @override
  String get faqAlertsA3 =>
      'हां, आप अलर्ट की आवृत्ति को अनुकूलित कर सकते हैं, विशिष्ट प्रकार के अलर्ट को सक्षम/अक्षम कर सकते हैं, और समग्र स्क्रीन टाइम और व्यक्तिगत एप्लिकेशन के लिए अलग-अलग सीमाएं सेट कर सकते हैं।';

  @override
  String get faqFocusQ1 => 'किस प्रकार के फोकस मोड उपलब्ध हैं?';

  @override
  String get faqFocusA1 =>
      'उपलब्ध मोड में डीप वर्क (लंबे फोकस्ड सेशन), क्विक टास्क (काम के छोटे बर्स्ट), और रीडिंग मोड शामिल हैं। प्रत्येक मोड आपके काम और ब्रेक टाइम को प्रभावी ढंग से संरचित करने में मदद करता है।';

  @override
  String get faqFocusQ2 => 'पोमोडोरो टाइमर कितना लचीला है?';

  @override
  String get faqFocusA2 =>
      'टाइमर अत्यधिक अनुकूलन योग्य है। आप काम की अवधि, छोटे ब्रेक की लंबाई, और लंबे ब्रेक की अवधि समायोजित कर सकते हैं। अतिरिक्त विकल्पों में अगले सेशन के लिए ऑटो-स्टार्ट और नोटिफिकेशन सेटिंग्स शामिल हैं।';

  @override
  String get faqFocusQ3 => 'फोकस मोड हिस्ट्री क्या दिखाती है?';

  @override
  String get faqFocusA3 =>
      'फोकस मोड हिस्ट्री दैनिक फोकस सेशन को ट्रैक करती है, प्रति दिन सेशन की संख्या, ट्रेंड ग्राफ, औसत सेशन अवधि, कुल फोकस समय, और वर्क सेशन, शॉर्ट ब्रेक, और लॉन्ग ब्रेक को विभाजित करने वाला टाइम डिस्ट्रीब्यूशन पाई चार्ट दिखाती है।';

  @override
  String get faqFocusQ4 =>
      'क्या मैं अपने फोकस सेशन प्रोग्रेस को ट्रैक कर सकता हूं?';

  @override
  String get faqFocusA4 =>
      'ऐप में प्ले/पॉज़, रीलोड, और सेटिंग्स बटन के साथ एक सर्कुलर टाइमर UI है। आप सहज नियंत्रणों के साथ अपने फोकस सेशन को आसानी से ट्रैक और प्रबंधित कर सकते हैं।';

  @override
  String get faqSettingsQ1 => 'कौन से अनुकूलन विकल्प उपलब्ध हैं?';

  @override
  String get faqSettingsA1 =>
      'अनुकूलन में थीम चयन (सिस्टम, लाइट, डार्क), भाषा सेटिंग्स, स्टार्टअप व्यवहार, व्यापक नोटिफिकेशन नियंत्रण, और डेटा क्लियर करने या सेटिंग्स रीसेट करने जैसे डेटा प्रबंधन विकल्प शामिल हैं।';

  @override
  String get faqSettingsQ2 =>
      'मैं फीडबैक कैसे दूं या समस्याएं कैसे रिपोर्ट करूं?';

  @override
  String get faqSettingsA2 =>
      'सेटिंग्स सेक्शन के नीचे, आपको बग रिपोर्ट करने, फीडबैक सबमिट करने, या सपोर्ट से संपर्क करने के बटन मिलेंगे। ये आपको उचित सपोर्ट चैनलों पर रीडायरेक्ट करेंगे।';

  @override
  String get faqSettingsQ3 =>
      'जब मैं अपना डेटा क्लियर करता हूं तो क्या होता है?';

  @override
  String get faqSettingsA3 =>
      'डेटा क्लियर करने से आपके सभी उपयोग आंकड़े, फोकस सेशन हिस्ट्री, और कस्टम सेटिंग्स रीसेट हो जाएंगी। यह फ्रेश स्टार्ट या समस्या निवारण के लिए उपयोगी है।';

  @override
  String get faqTroubleQ1 => 'डेटा नहीं दिख रहा, hive नहीं खुल रहा एरर';

  @override
  String get faqTroubleA1 =>
      'यह समस्या ज्ञात है, अस्थायी समाधान है सेटिंग्स के माध्यम से डेटा क्लियर करना और अगर यह काम नहीं करता है तो Documents में जाएं और यदि वे मौजूद हैं तो निम्नलिखित फाइलें हटाएं - harman_screentime_app_usage_box.hive और harman_screentime_app_usage.lock, आपको ऐप को नवीनतम संस्करण में अपडेट करने का भी सुझाव दिया जाता है।';

  @override
  String get faqTroubleQ2 => 'ऐप हर स्टार्टअप पर खुलता है, क्या करें?';

  @override
  String get faqTroubleA2 =>
      'यह एक ज्ञात समस्या है जो Windows 10 पर होती है, अस्थायी समाधान है सेटिंग्स में Launch as Minimized को सक्षम करना ताकि यह Minimized के रूप में लॉन्च हो।';

  @override
  String get usageAnalytics => 'उपयोग विश्लेषण';

  @override
  String get last7Days => 'पिछले 7 दिन';

  @override
  String get lastMonth => 'पिछला महीना';

  @override
  String get last3Months => 'पिछले 3 महीने';

  @override
  String get lifetime => 'लाइफटाइम';

  @override
  String get custom => 'कस्टम';

  @override
  String get loadingAnalyticsData => 'विश्लेषण डेटा लोड हो रहा है...';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get failedToInitialize =>
      'विश्लेषण प्रारंभ करने में विफल। कृपया एप्लिकेशन को पुनरारंभ करें।';

  @override
  String unexpectedError(String error) {
    return 'एक अप्रत्याशित त्रुटि हुई: $error। कृपया बाद में पुनः प्रयास करें।';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return 'विश्लेषण डेटा लोड करने में त्रुटि: $error। कृपया अपना कनेक्शन जांचें और पुनः प्रयास करें।';
  }

  @override
  String get customDialogTitle => 'कस्टम';

  @override
  String get dateRange => 'तारीख सीमा:';

  @override
  String get specificDate => 'विशिष्ट तिथि';

  @override
  String get startDate => 'प्रारंभ तिथि: ';

  @override
  String get endDate => 'समाप्ति तिथि: ';

  @override
  String get date => 'तारीख';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get apply => 'लागू करें';

  @override
  String get ok => 'ठीक है';

  @override
  String get invalidDateRange => 'अमान्य तिथि सीमा';

  @override
  String get startDateBeforeEndDate =>
      'प्रारंभ तिथि समाप्ति तिथि से पहले या बराबर होनी चाहिए।';

  @override
  String get totalScreenTime => 'कुल स्क्रीन समय';

  @override
  String get productiveTime => 'उत्पादक समय';

  @override
  String get mostUsedApp => 'सबसे अधिक उपयोग किया गया ऐप';

  @override
  String get focusSessions => 'फोकस सत्र';

  @override
  String positiveComparison(String percent) {
    return '+$percent% पिछली अवधि की तुलना में';
  }

  @override
  String negativeComparison(String percent) {
    return '$percent% पिछली अवधि की तुलना में';
  }

  @override
  String iconLabel(String title) {
    return '$title आइकन';
  }

  @override
  String get dailyScreenTime => 'दैनिक स्क्रीन समय';

  @override
  String get categoryBreakdown => 'श्रेणी विवरण';

  @override
  String get noDataAvailable => 'कोई डेटा उपलब्ध नहीं';

  @override
  String sectionLabel(String title) {
    return '$title अनुभाग';
  }

  @override
  String get detailedApplicationUsage => 'विस्तृत एप्लिकेशन उपयोग';

  @override
  String get searchApplications => 'एप्लिकेशन खोजें';

  @override
  String get nameHeader => 'नाम';

  @override
  String get categoryHeader => 'श्रेणी';

  @override
  String get totalTimeHeader => 'कुल समय';

  @override
  String get productivityHeader => 'उत्पादकता';

  @override
  String get actionsHeader => 'क्रियाएं';

  @override
  String sortByOption(String option) {
    return 'क्रमबद्ध करें: $option';
  }

  @override
  String get sortByName => 'नाम';

  @override
  String get sortByCategory => 'श्रेणी';

  @override
  String get sortByUsage => 'उपयोग';

  @override
  String get productive => 'उत्पादक';

  @override
  String get nonProductive => 'गैर-उत्पादक';

  @override
  String get noApplicationsMatch =>
      'आपके खोज मानदंडों से कोई एप्लिकेशन मेल नहीं खाता';

  @override
  String get viewDetails => 'विवरण देखें';

  @override
  String get usageSummary => 'उपयोग सारांश';

  @override
  String get usageOverPastWeek => 'पिछले सप्ताह का उपयोग';

  @override
  String get usagePatternByTimeOfDay => 'दिन के समय के अनुसार उपयोग पैटर्न';

  @override
  String get patternAnalysis => 'पैटर्न विश्लेषण';

  @override
  String get today => 'आज';

  @override
  String get dailyLimit => 'दैनिक सीमा';

  @override
  String get noLimit => 'कोई सीमा नहीं';

  @override
  String get usageTrend => 'उपयोग ट्रेंड';

  @override
  String get productivity => 'उत्पादकता';

  @override
  String get increasing => 'बढ़ रहा है';

  @override
  String get decreasing => 'घट रहा है';

  @override
  String get stable => 'स्थिर';

  @override
  String get avgDailyUsage => 'औसत दैनिक उपयोग';

  @override
  String get longestSession => 'सबसे लंबा सत्र';

  @override
  String get weeklyTotal => 'साप्ताहिक कुल';

  @override
  String get noHistoricalData => 'कोई ऐतिहासिक डेटा उपलब्ध नहीं';

  @override
  String get morning => 'सुबह (6-12)';

  @override
  String get afternoon => 'दोपहर (12-5)';

  @override
  String get evening => 'शाम (5-9)';

  @override
  String get night => 'रात (9-6)';

  @override
  String get usageInsights => 'उपयोग अंतर्दृष्टि';

  @override
  String get limitStatus => 'सीमा स्थिति';

  @override
  String get close => 'बंद करें';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return 'आप मुख्य रूप से $appName का उपयोग $timeOfDay के दौरान करते हैं।';
  }

  @override
  String significantIncrease(String percentage) {
    return 'आपका उपयोग पिछली अवधि की तुलना में काफी बढ़ा है ($percentage%)।';
  }

  @override
  String get trendingUpward =>
      'आपका उपयोग पिछली अवधि की तुलना में ऊपर की ओर ट्रेंड कर रहा है।';

  @override
  String significantDecrease(String percentage) {
    return 'आपका उपयोग पिछली अवधि की तुलना में काफी घटा है ($percentage%)।';
  }

  @override
  String get trendingDownward =>
      'आपका उपयोग पिछली अवधि की तुलना में नीचे की ओर ट्रेंड कर रहा है।';

  @override
  String get consistentUsage =>
      'आपका उपयोग पिछली अवधि की तुलना में सुसंगत रहा है।';

  @override
  String get markedAsProductive =>
      'यह आपकी सेटिंग्स में एक उत्पादक ऐप के रूप में चिह्नित है।';

  @override
  String get markedAsNonProductive =>
      'यह आपकी सेटिंग्स में एक गैर-उत्पादक ऐप के रूप में चिह्नित है।';

  @override
  String mostActiveTime(String time) {
    return 'आपका सबसे सक्रिय समय लगभग $time है।';
  }

  @override
  String get noLimitSet =>
      'इस एप्लिकेशन के लिए कोई उपयोग सीमा सेट नहीं की गई है।';

  @override
  String get limitReached =>
      'आपने इस एप्लिकेशन के लिए अपनी दैनिक सीमा तक पहुंच गई है।';

  @override
  String aboutToReachLimit(String remainingTime) {
    return 'आप अपनी दैनिक सीमा तक पहुंचने वाले हैं, केवल $remainingTime शेष है।';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return 'आपने अपनी दैनिक सीमा का $percent% उपयोग किया है, $remainingTime शेष है।';
  }

  @override
  String remainingTime(String time) {
    return 'आपके पास अपनी दैनिक सीमा में से $time शेष है।';
  }

  @override
  String get todayChart => 'आज';

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
    return '$hoursघं $minutesमि';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '$minutesमि';
  }

  @override
  String get alertsLimitsTitle => 'अलर्ट और सीमाएं';

  @override
  String get notificationsSettings => 'नोटिफिकेशन सेटिंग्स';

  @override
  String get overallScreenTimeLimit => 'समग्र स्क्रीन टाइम सीमा';

  @override
  String get applicationLimits => 'एप्लिकेशन सीमाएं';

  @override
  String get popupAlerts => 'पॉप-अप अलर्ट';

  @override
  String get frequentAlerts => 'बार-बार अलर्ट';

  @override
  String get soundAlerts => 'ध्वनि अलर्ट';

  @override
  String get systemAlerts => 'सिस्टम अलर्ट';

  @override
  String get dailyTotalLimit => 'दैनिक कुल सीमा: ';

  @override
  String get hours => 'घंटे';

  @override
  String get minutes => 'मिनट';

  @override
  String get currentUsage => 'वर्तमान उपयोग: ';

  @override
  String get tableName => 'नाम';

  @override
  String get tableCategory => 'श्रेणी';

  @override
  String get tableDailyLimit => 'दैनिक सीमा';

  @override
  String get tableCurrentUsage => 'वर्तमान उपयोग';

  @override
  String get tableStatus => 'स्थिति';

  @override
  String get tableActions => 'क्रियाएं';

  @override
  String get addLimit => 'सीमा जोड़ें';

  @override
  String get noApplicationsToDisplay =>
      'प्रदर्शित करने के लिए कोई एप्लिकेशन नहीं';

  @override
  String get statusActive => 'सक्रिय';

  @override
  String get statusOff => 'बंद';

  @override
  String get durationNone => 'कोई नहीं';

  @override
  String get addApplicationLimit => 'एप्लिकेशन सीमा जोड़ें';

  @override
  String get selectApplication => 'एप्लिकेशन चुनें';

  @override
  String get selectApplicationPlaceholder => 'एक एप्लिकेशन चुनें';

  @override
  String get enableLimit => 'सीमा सक्षम करें: ';

  @override
  String editLimitTitle(String appName) {
    return 'सीमा संपादित करें: $appName';
  }

  @override
  String failedToLoadData(String error) {
    return 'डेटा लोड करने में विफल: $error';
  }

  @override
  String get resetSettingsTitle => 'सेटिंग्स रीसेट करें?';

  @override
  String get resetSettingsContent =>
      'यदि आप सेटिंग्स रीसेट करते हैं, तो आप इसे पुनर्प्राप्त नहीं कर पाएंगे। क्या आप इसे रीसेट करना चाहते हैं?';

  @override
  String get resetAll => 'सब रीसेट करें';

  @override
  String get refresh => 'रीफ्रेश करें';

  @override
  String get save => 'सहेजें';

  @override
  String get add => 'जोड़ें';

  @override
  String get error => 'त्रुटि';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get applicationsTitle => 'एप्लिकेशन';

  @override
  String get searchApplication => 'एप्लिकेशन खोजें';

  @override
  String get tracking => 'ट्रैक किए गए';

  @override
  String get hiddenVisible => 'छिपा/दृश्यमान';

  @override
  String get selectCategory => 'एक श्रेणी चुनें';

  @override
  String get allCategories => 'सभी';

  @override
  String get tableScreenTime => 'स्क्रीन टाइम';

  @override
  String get tableTracking => 'ट्रैकिंग';

  @override
  String get tableHidden => 'छिपा';

  @override
  String get tableEdit => 'संपादित करें';

  @override
  String editAppTitle(String appName) {
    return '$appName संपादित करें';
  }

  @override
  String get categorySection => 'श्रेणी';

  @override
  String get customCategory => 'कस्टम';

  @override
  String get customCategoryPlaceholder => 'कस्टम श्रेणी नाम दर्ज करें';

  @override
  String get uncategorized => 'अवर्गीकृत';

  @override
  String get isProductive => 'उत्पादक है';

  @override
  String get trackUsage => 'उपयोग ट्रैक करें';

  @override
  String get visibleInReports => 'रिपोर्ट में दृश्यमान';

  @override
  String get timeLimitsSection => 'समय सीमाएं';

  @override
  String get enableDailyLimit => 'दैनिक सीमा सक्षम करें';

  @override
  String get setDailyTimeLimit => 'दैनिक समय सीमा सेट करें:';

  @override
  String get saveChanges => 'परिवर्तन सहेजें';

  @override
  String errorLoadingData(String error) {
    return 'अवलोकन डेटा लोड करने में त्रुटि: $error';
  }

  @override
  String get focusModeTitle => 'फोकस मोड';

  @override
  String get historySection => 'इतिहास';

  @override
  String get trendsSection => 'ट्रेंड';

  @override
  String get timeDistributionSection => 'समय वितरण';

  @override
  String get sessionHistorySection => 'सेशन इतिहास';

  @override
  String get workSession => 'कार्य सेशन';

  @override
  String get shortBreak => 'छोटा ब्रेक';

  @override
  String get longBreak => 'लंबा ब्रेक';

  @override
  String get dateHeader => 'तिथि';

  @override
  String get durationHeader => 'अवधि';

  @override
  String get monday => 'सोमवार';

  @override
  String get tuesday => 'मंगलवार';

  @override
  String get wednesday => 'बुधवार';

  @override
  String get thursday => 'गुरुवार';

  @override
  String get friday => 'शुक्रवार';

  @override
  String get saturday => 'शनिवार';

  @override
  String get sunday => 'रविवार';

  @override
  String get focusModeSettingsTitle => 'फोकस मोड सेटिंग्स';

  @override
  String get modeCustom => 'कस्टम';

  @override
  String get modeDeepWork => 'डीप वर्क (60 मिनट)';

  @override
  String get modeQuickTasks => 'क्विक टास्क (25 मिनट)';

  @override
  String get modeReading => 'रीडिंग (45 मिनट)';

  @override
  String workDurationLabel(int minutes) {
    return 'कार्य अवधि: $minutes मिनट';
  }

  @override
  String shortBreakLabel(int minutes) {
    return 'छोटा ब्रेक';
  }

  @override
  String longBreakLabel(int minutes) {
    return 'लंबा ब्रेक';
  }

  @override
  String get autoStartNextSession => 'अगला सेशन ऑटो-स्टार्ट करें';

  @override
  String get blockDistractions => 'फोकस मोड के दौरान विचलन को ब्लॉक करें';

  @override
  String get enableNotifications => 'नोटिफिकेशन सक्षम करें';

  @override
  String get saved => 'सहेजा गया';

  @override
  String errorLoadingFocusModeData(String error) {
    return 'फोकस मोड डेटा लोड करने में त्रुटि: $error';
  }

  @override
  String get overviewTitle => 'आज का अवलोकन';

  @override
  String get startFocusMode => 'फोकस मोड शुरू करें';

  @override
  String get loadingProductivityData => 'आपका उत्पादकता डेटा लोड हो रहा है...';

  @override
  String get noActivityDataAvailable =>
      'अभी तक कोई गतिविधि डेटा उपलब्ध नहीं है';

  @override
  String get startUsingApplications =>
      'स्क्रीन टाइम और उत्पादकता ट्रैक करने के लिए अपने एप्लिकेशन का उपयोग शुरू करें।';

  @override
  String get refreshData => 'डेटा रीफ्रेश करें';

  @override
  String get topApplications => 'शीर्ष एप्लिकेशन';

  @override
  String get noAppUsageDataAvailable =>
      'अभी तक कोई एप्लिकेशन उपयोग डेटा उपलब्ध नहीं है';

  @override
  String get noApplicationDataAvailable => 'कोई एप्लिकेशन डेटा उपलब्ध नहीं है';

  @override
  String get noCategoryDataAvailable => 'कोई श्रेणी डेटा उपलब्ध नहीं है';

  @override
  String get noApplicationLimitsSet =>
      'कोई एप्लिकेशन सीमाएं सेट नहीं की गई हैं';

  @override
  String get screenLabel => 'स्क्रीन';

  @override
  String get timeLabel => 'समय';

  @override
  String get productiveLabel => 'उत्पादक';

  @override
  String get scoreLabel => 'स्कोर';

  @override
  String get defaultNone => 'कोई नहीं';

  @override
  String get defaultTime => '0घं 0मि';

  @override
  String get defaultCount => '0';

  @override
  String get unknownApp => 'अज्ञात';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get generalSection => 'सामान्य';

  @override
  String get notificationsSection => 'नोटिफिकेशन';

  @override
  String get dataSection => 'डेटा';

  @override
  String get versionSection => 'संस्करण';

  @override
  String get languageTitle => 'भाषा';

  @override
  String get languageDescription => 'एप्लिकेशन की भाषा';

  @override
  String get startupBehaviourTitle => 'स्टार्टअप व्यवहार';

  @override
  String get startupBehaviourDescription => 'OS स्टार्टअप पर लॉन्च करें';

  @override
  String get launchMinimizedTitle => 'मिनिमाइज़ के रूप में लॉन्च करें';

  @override
  String get launchMinimizedDescription =>
      'एप्लिकेशन को सिस्टम ट्रे में शुरू करें (Windows 10 के लिए अनुशंसित)';

  @override
  String get notificationsTitle => 'नोटिफिकेशन';

  @override
  String get notificationsAllDescription => 'एप्लिकेशन की सभी नोटिफिकेशन';

  @override
  String get focusModeNotificationsTitle => 'फोकस मोड';

  @override
  String get focusModeNotificationsDescription =>
      'फोकस मोड के लिए सभी नोटिफिकेशन';

  @override
  String get screenTimeNotificationsTitle => 'स्क्रीन टाइम';

  @override
  String get screenTimeNotificationsDescription =>
      'स्क्रीन टाइम प्रतिबंध के लिए सभी नोटिफिकेशन';

  @override
  String get appScreenTimeNotificationsTitle => 'एप्लिकेशन स्क्रीन टाइम';

  @override
  String get appScreenTimeNotificationsDescription =>
      'एप्लिकेशन स्क्रीन टाइम प्रतिबंध के लिए सभी नोटिफिकेशन';

  @override
  String get frequentAlertsTitle => 'बार-बार अलर्ट अंतराल';

  @override
  String get frequentAlertsDescription =>
      'बार-बार नोटिफिकेशन के लिए अंतराल सेट करें (मिनट)';

  @override
  String get clearDataTitle => 'डेटा साफ़ करें';

  @override
  String get clearDataDescription =>
      'सभी इतिहास और अन्य संबंधित डेटा साफ़ करें';

  @override
  String get resetSettingsTitle2 => 'सेटिंग्स रीसेट करें';

  @override
  String get resetSettingsDescription => 'सभी सेटिंग्स रीसेट करें';

  @override
  String get versionTitle => 'संस्करण';

  @override
  String get versionDescription => 'ऐप का वर्तमान संस्करण';

  @override
  String get contactButton => 'संपर्क';

  @override
  String get reportBugButton => 'बग रिपोर्ट करें';

  @override
  String get submitFeedbackButton => 'प्रतिक्रिया सबमिट करें';

  @override
  String get githubButton => 'Github';

  @override
  String get clearDataDialogTitle => 'डेटा साफ़ करें?';

  @override
  String get clearDataDialogContent =>
      'यह सभी इतिहास और संबंधित डेटा साफ़ कर देगा। आप इसे पुनर्प्राप्त नहीं कर पाएंगे। क्या आप आगे बढ़ना चाहते हैं?';

  @override
  String get clearDataButtonLabel => 'डेटा साफ़ करें';

  @override
  String get resetSettingsDialogTitle => 'सेटिंग्स रीसेट करें?';

  @override
  String get resetSettingsDialogContent =>
      'यह सभी सेटिंग्स को उनके डिफ़ॉल्ट मानों पर रीसेट कर देगा। क्या आप आगे बढ़ना चाहते हैं?';

  @override
  String get resetButtonLabel => 'रीसेट';

  @override
  String get cancelButton => 'रद्द करें';

  @override
  String couldNotLaunchUrl(String url) {
    return '$url लॉन्च नहीं किया जा सका';
  }

  @override
  String errorMessage(String message) {
    return 'त्रुटि: $message';
  }

  @override
  String get chart_focusTrends => 'फोकस ट्रेंड';

  @override
  String get chart_sessionCount => 'सेशन गिनती';

  @override
  String get chart_avgDuration => 'औसत अवधि';

  @override
  String get chart_totalFocus => 'कुल फोकस';

  @override
  String get chart_yAxis_sessions => 'सेशन';

  @override
  String get chart_yAxis_minutes => 'मिनट';

  @override
  String get chart_yAxis_value => 'मान';

  @override
  String get chart_monthOverMonthChange => 'महीने-दर-महीने परिवर्तन: ';

  @override
  String get chart_customRange => 'कस्टम रेंज';

  @override
  String get day_monday => 'सोमवार';

  @override
  String get day_mondayShort => 'सोम';

  @override
  String get day_mondayAbbr => 'सो';

  @override
  String get day_tuesday => 'मंगलवार';

  @override
  String get day_tuesdayShort => 'मंग';

  @override
  String get day_tuesdayAbbr => 'मं';

  @override
  String get day_wednesday => 'बुधवार';

  @override
  String get day_wednesdayShort => 'बुध';

  @override
  String get day_wednesdayAbbr => 'बु';

  @override
  String get day_thursday => 'गुरुवार';

  @override
  String get day_thursdayShort => 'गुरु';

  @override
  String get day_thursdayAbbr => 'गु';

  @override
  String get day_friday => 'शुक्रवार';

  @override
  String get day_fridayShort => 'शुक्र';

  @override
  String get day_fridayAbbr => 'शु';

  @override
  String get day_saturday => 'शनिवार';

  @override
  String get day_saturdayShort => 'शनि';

  @override
  String get day_saturdayAbbr => 'श';

  @override
  String get day_sunday => 'रविवार';

  @override
  String get day_sundayShort => 'रवि';

  @override
  String get day_sundayAbbr => 'र';

  @override
  String time_hours(int count) {
    return '$countघं';
  }

  @override
  String time_hoursMinutes(int hours, int minutes) {
    return '$hoursघं $minutesमि';
  }

  @override
  String time_minutesFormat(String count) {
    return '$count मिनट';
  }

  @override
  String tooltip_dateScreenTime(String date, int hours, int minutes) {
    return '$date: $hoursघं $minutesमि';
  }

  @override
  String tooltip_hoursFormat(String count) {
    return '$count घंटे';
  }

  @override
  String get month_january => 'जनवरी';

  @override
  String get month_januaryShort => 'जन';

  @override
  String get month_february => 'फरवरी';

  @override
  String get month_februaryShort => 'फर';

  @override
  String get month_march => 'मार्च';

  @override
  String get month_marchShort => 'मार्च';

  @override
  String get month_april => 'अप्रैल';

  @override
  String get month_aprilShort => 'अप्रै';

  @override
  String get month_may => 'मई';

  @override
  String get month_mayShort => 'मई';

  @override
  String get month_june => 'जून';

  @override
  String get month_juneShort => 'जून';

  @override
  String get month_july => 'जुलाई';

  @override
  String get month_julyShort => 'जुला';

  @override
  String get month_august => 'अगस्त';

  @override
  String get month_augustShort => 'अग';

  @override
  String get month_september => 'सितंबर';

  @override
  String get month_septemberShort => 'सित';

  @override
  String get month_october => 'अक्टूबर';

  @override
  String get month_octoberShort => 'अक्टू';

  @override
  String get month_november => 'नवंबर';

  @override
  String get month_novemberShort => 'नव';

  @override
  String get month_december => 'दिसंबर';

  @override
  String get month_decemberShort => 'दिस';

  @override
  String get categoryAll => 'सभी';

  @override
  String get categoryProductivity => 'उत्पादकता';

  @override
  String get categoryDevelopment => 'विकास';

  @override
  String get categorySocialMedia => 'सोशल मीडिया';

  @override
  String get categoryEntertainment => 'मनोरंजन';

  @override
  String get categoryGaming => 'गेमिंग';

  @override
  String get categoryCommunication => 'संचार';

  @override
  String get categoryWebBrowsing => 'वेब ब्राउज़िंग';

  @override
  String get categoryCreative => 'क्रिएटिव';

  @override
  String get categoryEducation => 'शिक्षा';

  @override
  String get categoryUtility => 'उपयोगिता';

  @override
  String get categoryUncategorized => 'अवर्गीकृत';

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
  String get appCalculator => 'कैलकुलेटर';

  @override
  String get appNotes => 'नोट्स';

  @override
  String get appSystemPreferences => 'सिस्टम प्राथमिकताएं';

  @override
  String get appTaskManager => 'टास्क मैनेजर';

  @override
  String get appFileExplorer => 'फाइल एक्सप्लोरर';

  @override
  String get appDropbox => 'Dropbox';

  @override
  String get appGoogleDrive => 'Google Drive';

  @override
  String get loadingApplication => 'एप्लिकेशन लोड हो रहा है...';

  @override
  String get loadingData => 'डेटा लोड हो रहा है...';

  @override
  String get reportsError => 'त्रुटि';

  @override
  String get reportsRetry => 'पुनः प्रयास करें';

  @override
  String get backupRestoreSection => 'बैकअप और पुनर्स्थापना';

  @override
  String get backupRestoreTitle => 'बैकअप और पुनर्स्थापना';

  @override
  String get exportDataTitle => 'डेटा निर्यात करें';

  @override
  String get exportDataDescription => 'अपने सभी डेटा का बैकअप बनाएं';

  @override
  String get importDataTitle => 'डेटा आयात करें';

  @override
  String get importDataDescription => 'बैकअप फाइल से पुनर्स्थापित करें';

  @override
  String get exportButton => 'निर्यात';

  @override
  String get importButton => 'आयात';

  @override
  String get closeButton => 'बंद करें';

  @override
  String get noButton => 'नहीं';

  @override
  String get shareButton => 'शेयर करें';

  @override
  String get exportStarting => 'निर्यात शुरू हो रहा है...';

  @override
  String get exportSuccessful => 'निर्यात सफल';

  @override
  String get exportFailed => 'निर्यात विफल';

  @override
  String get exportComplete => 'निर्यात पूर्ण';

  @override
  String get shareBackupQuestion => 'क्या आप बैकअप फाइल शेयर करना चाहेंगे?';

  @override
  String get importStarting => 'आयात शुरू हो रहा है...';

  @override
  String get importSuccessful => 'आयात सफल!';

  @override
  String get importFailed => 'आयात विफल';

  @override
  String get importOptionsTitle => 'आयात विकल्प';

  @override
  String get importOptionsQuestion => 'आप डेटा कैसे आयात करना चाहेंगे?';

  @override
  String get replaceModeTitle => 'प्रतिस्थापित करें';

  @override
  String get replaceModeDescription => 'सभी मौजूदा डेटा प्रतिस्थापित करें';

  @override
  String get mergeModeTitle => 'मर्ज करें';

  @override
  String get mergeModeDescription => 'मौजूदा डेटा के साथ जोड़ें';

  @override
  String get appendModeTitle => 'जोड़ें';

  @override
  String get appendModeDescription => 'केवल नए रिकॉर्ड जोड़ें';

  @override
  String get warningTitle => '⚠️ चेतावनी';

  @override
  String get replaceWarningMessage =>
      'यह आपके सभी मौजूदा डेटा को प्रतिस्थापित कर देगा। क्या आप वाकई जारी रखना चाहते हैं?';

  @override
  String get replaceAllButton => 'सभी प्रतिस्थापित करें';

  @override
  String get fileLabel => 'फाइल';

  @override
  String get sizeLabel => 'आकार';

  @override
  String get recordsLabel => 'रिकॉर्ड';

  @override
  String get usageRecordsLabel => 'उपयोग रिकॉर्ड';

  @override
  String get focusSessionsLabel => 'फोकस सेशन';

  @override
  String get appMetadataLabel => 'ऐप मेटाडेटा';

  @override
  String get updatedLabel => 'अपडेट किया गया';

  @override
  String get skippedLabel => 'छोड़ा गया';

  @override
  String get faqSettingsQ4 =>
      'मैं अपना डेटा कैसे पुनर्स्थापित या निर्यात कर सकता हूं?';

  @override
  String get faqSettingsA4 =>
      'आप सेटिंग्स में जा सकते हैं, और वहां आपको बैकअप और पुनर्स्थापना सेक्शन मिलेगा। आप यहां से डेटा निर्यात या आयात कर सकते हैं, ध्यान दें कि निर्यात की गई डेटा फाइल Documents में Scolect-Backups फोल्डर में संग्रहीत है और केवल इस फाइल का उपयोग डेटा पुनर्स्थापित करने के लिए किया जा सकता है, कोई अन्य फाइल नहीं।';

  @override
  String get faqGeneralQ6 =>
      'मैं भाषा कैसे बदल सकता हूं और कौन सी भाषाएं उपलब्ध हैं, अगर मुझे लगे कि अनुवाद गलत है तो क्या करूं?';

  @override
  String get faqGeneralA6 =>
      'भाषा को सेटिंग्स सामान्य सेक्शन के माध्यम से बदला जा सकता है, सभी उपलब्ध भाषाएं वहां सूचीबद्ध हैं, आप संपर्क पर क्लिक करके और दी गई भाषा के साथ अपना अनुरोध भेजकर अनुवाद का अनुरोध कर सकते हैं। बस जान लें कि अनुवाद गलत हो सकता है क्योंकि यह AI द्वारा अंग्रेजी से उत्पन्न किया गया है और यदि आप रिपोर्ट करना चाहते हैं तो आप बग रिपोर्ट करें, या संपर्क के माध्यम से रिपोर्ट कर सकते हैं, या यदि आप डेवलपर हैं तो Github पर इश्यू खोलें। भाषा के संबंध में योगदान का भी स्वागत है!';

  @override
  String get faqGeneralQ7 => 'अगर मुझे लगे कि अनुवाद गलत है तो क्या करूं?';

  @override
  String get faqGeneralA7 =>
      'अनुवाद गलत हो सकता है क्योंकि यह AI द्वारा अंग्रेजी से उत्पन्न किया गया है और यदि आप रिपोर्ट करना चाहते हैं तो आप बग रिपोर्ट करें, या संपर्क के माध्यम से रिपोर्ट कर सकते हैं, या यदि आप डेवलपर हैं तो Github पर इश्यू खोलें। भाषा के संबंध में योगदान का भी स्वागत है!';

  @override
  String get activityTrackingSection => 'गतिविधि ट्रैकिंग';

  @override
  String get idleDetectionTitle => 'निष्क्रिय पहचान';

  @override
  String get idleDetectionDescription => 'निष्क्रिय होने पर ट्रैकिंग बंद करें';

  @override
  String get idleTimeoutTitle => 'निष्क्रिय समय सीमा';

  @override
  String idleTimeoutDescription(String timeout) {
    return 'निष्क्रिय मानने से पहले का समय ($timeout)';
  }

  @override
  String get advancedWarning =>
      'उन्नत सुविधाएं संसाधन उपयोग बढ़ा सकती हैं। केवल आवश्यकता होने पर सक्षम करें।';

  @override
  String get monitorAudioTitle => 'सिस्टम ऑडियो मॉनिटर करें';

  @override
  String get monitorAudioDescription => 'ऑडियो प्लेबैक से गतिविधि का पता लगाएं';

  @override
  String get audioSensitivityTitle => 'ऑडियो संवेदनशीलता';

  @override
  String audioSensitivityDescription(String value) {
    return 'पता लगाने की सीमा ($value)';
  }

  @override
  String get monitorControllersTitle => 'गेम कंट्रोलर मॉनिटर करें';

  @override
  String get monitorControllersDescription =>
      'Xbox/XInput कंट्रोलर का पता लगाएं';

  @override
  String get monitorHIDTitle => 'HID उपकरण मॉनिटर करें';

  @override
  String get monitorHIDDescription =>
      'व्हील, टैबलेट, कस्टम उपकरणों का पता लगाएं';

  @override
  String get setIdleTimeoutTitle => 'निष्क्रिय समय सीमा सेट करें';

  @override
  String get idleTimeoutDialogDescription =>
      'आपको निष्क्रिय मानने से पहले कितनी देर प्रतीक्षा करनी है चुनें:';

  @override
  String get seconds30 => '30 सेकंड';

  @override
  String get minute1 => '1 मिनट';

  @override
  String get minutes2 => '2 मिनट';

  @override
  String get minutes5 => '5 मिनट';

  @override
  String get minutes10 => '10 मिनट';

  @override
  String get customOption => 'कस्टम';

  @override
  String get customDurationTitle => 'कस्टम अवधि';

  @override
  String get minutesLabel => 'मिनट';

  @override
  String get secondsLabel => 'सेकंड';

  @override
  String get minAbbreviation => 'मि';

  @override
  String get secAbbreviation => 'से';

  @override
  String totalLabel(String duration) {
    return 'कुल: $duration';
  }

  @override
  String minimumError(String value) {
    return 'न्यूनतम $value है';
  }

  @override
  String maximumError(String value) {
    return 'अधिकतम $value है';
  }

  @override
  String rangeInfo(String min, String max) {
    return 'सीमा: $min - $max';
  }

  @override
  String get saveButton => 'सहेजें';

  @override
  String timeFormatSeconds(int seconds) {
    return '$secondsसे';
  }

  @override
  String get timeFormatMinute => '1 मिनट';

  @override
  String timeFormatMinutes(int minutes) {
    return '$minutes मिनट';
  }

  @override
  String timeFormatMinutesSeconds(int minutes, int seconds) {
    return '$minutes मि $secondsसे';
  }

  @override
  String get themeLight => 'हल्का';

  @override
  String get themeDark => 'गहरा';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeTitle => 'थीम';

  @override
  String get themeDescription => 'एप्लिकेशन की रंग थीम';

  @override
  String get voiceGenderTitle => 'आवाज़ का लिंग';

  @override
  String get voiceGenderDescription =>
      'टाइमर सूचनाओं के लिए आवाज़ का लिंग चुनें';

  @override
  String get voiceGenderMale => 'पुरुष';

  @override
  String get voiceGenderFemale => 'महिला';

  @override
  String get alertsLimitsSubtitle =>
      'अपने स्क्रीन टाइम की सीमा और सूचनाओं को प्रबंधित करें';

  @override
  String get applicationsSubtitle =>
      'अपने ट्रैक किए गए एप्लिकेशन प्रबंधित करें';

  @override
  String applicationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count एप्लिकेशन',
      one: '1 एप्लिकेशन',
    );
    return '$_temp0';
  }

  @override
  String get noApplicationsFound => 'कोई एप्लिकेशन नहीं मिला';

  @override
  String get tryAdjustingFilters => 'अपने फ़िल्टर समायोजित करने का प्रयास करें';

  @override
  String get configureAppSettings => 'एप्लिकेशन सेटिंग्स कॉन्फ़िगर करें';

  @override
  String get behaviorSection => 'व्यवहार';

  @override
  String helpSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '7 श्रेणियों में $count प्रश्न',
      one: '7 श्रेणियों में 1 प्रश्न',
    );
    return '$_temp0';
  }

  @override
  String get searchForHelp => 'सहायता खोजें...';

  @override
  String get quickNavGeneral => 'सामान्य';

  @override
  String get quickNavApps => 'ऐप्स';

  @override
  String get quickNavReports => 'रिपोर्ट';

  @override
  String get quickNavFocus => 'फोकस';

  @override
  String get noResultsFound => 'कोई परिणाम नहीं मिला';

  @override
  String get tryDifferentKeywords =>
      'विभिन्न कीवर्ड के साथ खोजने का प्रयास करें';

  @override
  String get clearSearch => 'खोज साफ़ करें';

  @override
  String get greetingMorning => 'सुप्रभात! यह आपकी गतिविधि का सारांश है।';

  @override
  String get greetingAfternoon => 'शुभ दोपहर! यह आपकी गतिविधि का सारांश है।';

  @override
  String get greetingEvening => 'शुभ संध्या! यह आपकी गतिविधि का सारांश है।';

  @override
  String get screenTimeProgress => 'स्क्रीन\nटाइम';

  @override
  String get productiveScoreProgress => 'उत्पादक\nस्कोर';

  @override
  String get focusModeSubtitle => 'केंद्रित रहें, उत्पादक बनें';

  @override
  String get thisWeek => 'इस सप्ताह';

  @override
  String get sessions => 'सत्र';

  @override
  String get totalTime => 'कुल समय';

  @override
  String get avgLength => 'औसत अवधि';

  @override
  String get focusTime => 'फोकस समय';

  @override
  String get paused => 'रोका गया';

  @override
  String get shortBreakStatus => 'छोटा ब्रेक';

  @override
  String get longBreakStatus => 'लंबा ब्रेक';

  @override
  String get readyToFocus => 'फोकस के लिए तैयार';

  @override
  String get focus => 'फोकस';

  @override
  String get restartSession => 'सत्र पुनः प्रारंभ करें';

  @override
  String get skipToNext => 'अगले पर जाएं';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String sessionsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सत्र पूर्ण',
      one: '1 सत्र पूर्ण',
    );
    return '$_temp0';
  }

  @override
  String get focusModePreset => 'फोकस मोड प्रीसेट';

  @override
  String get focusDuration => 'फोकस अवधि';

  @override
  String minutesFormat(int minutes) {
    return '$minutes मिनट';
  }

  @override
  String get shortBreakDuration => 'छोटा ब्रेक';

  @override
  String get longBreakDuration => 'लंबा ब्रेक';

  @override
  String get enableSounds => 'ध्वनि सक्षम करें';

  @override
  String get focus_mode_this_week => 'इस सप्ताह';

  @override
  String get focus_mode_best_day => 'सर्वश्रेष्ठ दिन';

  @override
  String focus_mode_sessions_count(int count) {
    return '$count सत्र';
  }

  @override
  String get focus_mode_no_data_yet => 'अभी तक कोई डेटा नहीं';

  @override
  String get chart_current => 'वर्तमान';

  @override
  String get chart_previous => 'पिछला';

  @override
  String get permission_error => 'अनुमति त्रुटि';

  @override
  String get notification_permission_denied => 'सूचना अनुमति अस्वीकृत';

  @override
  String get notification_permission_denied_message =>
      'ScreenTime को आपको अलर्ट और रिमाइंडर भेजने के लिए सूचना अनुमति की आवश्यकता है।\n\nक्या आप सूचनाओं को सक्षम करने के लिए सिस्टम सेटिंग्स खोलना चाहेंगे?';

  @override
  String get notification_permission_denied_hint =>
      'ScreenTime के लिए सूचनाओं को सक्षम करने के लिए सिस्टम सेटिंग्स खोलें।';

  @override
  String get notification_permission_required => 'सूचना अनुमति आवश्यक';

  @override
  String get notification_permission_required_message =>
      'ScreenTime को आपको सूचनाएं भेजने के लिए अनुमति की आवश्यकता है।';

  @override
  String get open_settings => 'सेटिंग्स खोलें';

  @override
  String get allow_notifications => 'सूचनाओं की अनुमति दें';

  @override
  String get permission_allowed => 'अनुमत';

  @override
  String get permission_denied => 'अस्वीकृत';

  @override
  String get permission_not_set => 'सेट नहीं';

  @override
  String get on => 'चालू';

  @override
  String get off => 'बंद';

  @override
  String get enable_notification_permission_hint =>
      'अलर्ट प्राप्त करने के लिए सूचना अनुमति सक्षम करें';

  @override
  String minutes_format(int minutes) {
    return '$minutes मिनट';
  }

  @override
  String get chart_average => 'औसत';

  @override
  String get chart_peak => 'चरम';

  @override
  String get chart_lowest => 'सबसे कम';

  @override
  String get active => 'सक्रिय';

  @override
  String get disabled => 'अक्षम';

  @override
  String get advanced_options => 'उन्नत विकल्प';

  @override
  String get sync_ready => 'सिंक तैयार';

  @override
  String get success => 'सफलता';

  @override
  String get destructive_badge => 'विनाशकारी';

  @override
  String get recommended_badge => 'अनुशंसित';

  @override
  String get safe_badge => 'सुरक्षित';

  @override
  String get overview => 'अवलोकन';

  @override
  String get patterns => 'पैटर्न';

  @override
  String get apps => 'ऐप्स';

  @override
  String get sortAscending => 'आरोही क्रम में क्रमबद्ध करें';

  @override
  String get sortDescending => 'अवरोही क्रम में क्रमबद्ध करें';

  @override
  String applicationsShowing(int count) {
    return '$count एप्लिकेशन दिखाई जा रही हैं';
  }

  @override
  String valueLabel(String value) {
    return 'मान: $value';
  }

  @override
  String appsCount(int count) {
    return '$count ऐप्स';
  }

  @override
  String categoriesCount(int count) {
    return '$count श्रेणियाँ';
  }

  @override
  String get systemNotificationsDisabled =>
      'सिस्टम सूचनाएं अक्षम हैं। फोकस अलर्ट के लिए उन्हें सिस्टम सेटिंग्स में सक्षम करें।';

  @override
  String get openSystemSettings => 'सिस्टम सेटिंग्स खोलें';

  @override
  String get appNotificationsDisabled =>
      'ऐप सेटिंग्स में सूचनाएं अक्षम हैं। फोकस अलर्ट प्राप्त करने के लिए उन्हें सक्षम करें।';

  @override
  String get goToSettings => 'सेटिंग्स पर जाएं';

  @override
  String get focusModeNotificationsDisabled =>
      'फोकस मोड सूचनाएं अक्षम हैं। सत्र अलर्ट प्राप्त करने के लिए उन्हें सक्षम करें।';

  @override
  String get notificationsDisabled => 'सूचनाएं अक्षम';

  @override
  String get dontShowAgain => 'फिर से न दिखाएं';

  @override
  String get systemSettingsRequired => 'सिस्टम सेटिंग्स आवश्यक';

  @override
  String get notificationsDisabledSystemLevel =>
      'सिस्टम स्तर पर सूचनाएं अक्षम हैं। सक्षम करने के लिए:';

  @override
  String get step1OpenSystemSettings =>
      '1. सिस्टम सेटिंग्स खोलें (सिस्टम प्रेफरेंस)';

  @override
  String get step2GoToNotifications => '2. सूचनाओं पर जाएं';

  @override
  String get step3FindApp => '3. Scolect ढूंढें और चुनें';

  @override
  String get step4EnableNotifications =>
      '4. \"सूचनाओं की अनुमति दें\" सक्षम करें';

  @override
  String get returnToAppMessage => 'फिर इस ऐप पर लौटें और सूचनाएं काम करेंगी।';

  @override
  String get gotIt => 'समझ गया';

  @override
  String get noSessionsYet => 'अभी तक कोई सत्र नहीं';

  @override
  String applicationsTracked(int count) {
    return '$count एप्लिकेशन ट्रैक किए गए';
  }

  @override
  String get applicationHeader => 'एप्लिकेशन';

  @override
  String get currentUsageHeader => 'वर्तमान उपयोग';

  @override
  String get dailyLimitHeader => 'दैनिक सीमा';

  @override
  String get edit => 'संपादित करें';

  @override
  String get showPopupNotifications => 'पॉपअप सूचनाएं दिखाएं';

  @override
  String get moreFrequentReminders => 'अधिक बार अनुस्मारक';

  @override
  String get playSoundWithAlerts => 'अलर्ट के साथ ध्वनि बजाएं';

  @override
  String get systemTrayNotifications => 'सिस्टम ट्रे सूचनाएं';

  @override
  String screenTimeUsed(String current, String limit) {
    return '$current / $limit उपयोग किया गया';
  }

  @override
  String get todaysScreenTime => 'आज का स्क्रीन समय';

  @override
  String get activeLimits => 'सक्रिय सीमाएं';

  @override
  String get nearLimit => 'सीमा के पास';

  @override
  String get colorPickerSpectrum => 'स्पेक्ट्रम';

  @override
  String get colorPickerPresets => 'प्रीसेट';

  @override
  String get colorPickerSliders => 'स्लाइडर';

  @override
  String get colorPickerBasicColors => 'बुनियादी रंग';

  @override
  String get colorPickerExtendedPalette => 'विस्तारित पैलेट';

  @override
  String get colorPickerRed => 'लाल';

  @override
  String get colorPickerGreen => 'हरा';

  @override
  String get colorPickerBlue => 'नीला';

  @override
  String get colorPickerHue => 'रंगत';

  @override
  String get colorPickerSaturation => 'संतृप्ति';

  @override
  String get colorPickerBrightness => 'चमक';

  @override
  String get colorPickerHexColor => 'हेक्स रंग';

  @override
  String get colorPickerHexPlaceholder => 'RRGGBB';

  @override
  String get colorPickerRGB => 'RGB';

  @override
  String get select => 'चुनें';

  @override
  String get themeCustomization => 'थीम अनुकूलन';

  @override
  String get chooseThemePreset => 'थीम प्रीसेट चुनें';

  @override
  String get yourCustomThemes => 'आपकी कस्टम थीम';

  @override
  String get createCustomTheme => 'कस्टम थीम बनाएं';

  @override
  String get designOwnColorScheme => 'अपनी खुद की रंग योजना डिज़ाइन करें';

  @override
  String get newTheme => 'नई थीम';

  @override
  String get editCurrentTheme => 'वर्तमान थीम संपादित करें';

  @override
  String customizeColorsFor(String themeName) {
    return '$themeName के लिए रंग अनुकूलित करें';
  }

  @override
  String customThemeNumber(int number) {
    return 'कस्टम थीम $number';
  }

  @override
  String get deleteCustomTheme => 'कस्टम थीम हटाएं';

  @override
  String confirmDeleteTheme(String themeName) {
    return 'क्या आप वाकई \"$themeName\" को हटाना चाहते हैं?';
  }

  @override
  String get delete => 'हटाएं';

  @override
  String get customizeTheme => 'थीम अनुकूलित करें';

  @override
  String get preview => 'पूर्वावलोकन';

  @override
  String get themeName => 'थीम का नाम';

  @override
  String get brandColors => 'ब्रांड रंग';

  @override
  String get lightTheme => 'हल्की थीम';

  @override
  String get darkTheme => 'गहरी थीम';

  @override
  String get reset => 'रीसेट करें';

  @override
  String get saveTheme => 'थीम सहेजें';

  @override
  String get customTheme => 'कस्टम थीम';

  @override
  String get primaryColors => 'प्राथमिक रंग';

  @override
  String get primaryColorsDesc =>
      'पूरे ऐप में उपयोग किए जाने वाले मुख्य उच्चारण रंग';

  @override
  String get primaryAccent => 'प्राथमिक उच्चारण';

  @override
  String get primaryAccentDesc => 'मुख्य ब्रांड रंग, बटन, लिंक';

  @override
  String get secondaryAccent => 'द्वितीयक उच्चारण';

  @override
  String get secondaryAccentDesc => 'ग्रेडिएंट के लिए पूरक उच्चारण';

  @override
  String get semanticColors => 'अर्थ संबंधी रंग';

  @override
  String get semanticColorsDesc => 'अर्थ और स्थिति व्यक्त करने वाले रंग';

  @override
  String get successColor => 'सफलता का रंग';

  @override
  String get successColorDesc => 'सकारात्मक क्रियाएं, पुष्टिकरण';

  @override
  String get warningColor => 'चेतावनी का रंग';

  @override
  String get warningColorDesc => 'सावधानी, लंबित स्थिति';

  @override
  String get errorColor => 'त्रुटि का रंग';

  @override
  String get errorColorDesc => 'त्रुटियां, विनाशकारी क्रियाएं';

  @override
  String get backgroundColors => 'पृष्ठभूमि रंग';

  @override
  String get backgroundColorsLightDesc =>
      'हल्के मोड के लिए मुख्य पृष्ठभूमि सतह';

  @override
  String get backgroundColorsDarkDesc => 'गहरे मोड के लिए मुख्य पृष्ठभूमि सतह';

  @override
  String get background => 'पृष्ठभूमि';

  @override
  String get backgroundDesc => 'मुख्य ऐप पृष्ठभूमि';

  @override
  String get surface => 'सतह';

  @override
  String get surfaceDesc => 'कार्ड, डायलॉग, उभरी हुई सतहें';

  @override
  String get surfaceSecondary => 'द्वितीयक सतह';

  @override
  String get surfaceSecondaryDesc => 'द्वितीयक कार्ड, साइडबार';

  @override
  String get border => 'सीमा';

  @override
  String get borderDesc => 'विभाजक, कार्ड सीमाएं';

  @override
  String get textColors => 'पाठ रंग';

  @override
  String get textColorsLightDesc => 'हल्के मोड के लिए टाइपोग्राफी रंग';

  @override
  String get textColorsDarkDesc => 'गहरे मोड के लिए टाइपोग्राफी रंग';

  @override
  String get textPrimary => 'प्राथमिक पाठ';

  @override
  String get textPrimaryDesc => 'शीर्षक, महत्वपूर्ण पाठ';

  @override
  String get textSecondary => 'द्वितीयक पाठ';

  @override
  String get textSecondaryDesc => 'विवरण, कैप्शन';

  @override
  String previewMode(String mode) {
    return 'पूर्वावलोकन: $mode मोड';
  }

  @override
  String get dark => 'गहरा';

  @override
  String get light => 'हल्का';

  @override
  String get sampleCardTitle => 'नमूना कार्ड शीर्षक';

  @override
  String get sampleSecondaryText => 'यह नीचे दिखाई देने वाला द्वितीयक पाठ है।';

  @override
  String get primary => 'प्राथमिक';

  @override
  String get secondary => 'द्वितीयक';

  @override
  String get warning => 'चेतावनी';

  @override
  String get launchAtStartupTitle => 'स्टार्टअप पर लॉन्च करें';

  @override
  String get launchAtStartupDescription =>
      'जब आप अपने कंप्यूटर में लॉग इन करें तो स्वचालित रूप से Scolect प्रारंभ करें';

  @override
  String get inputMonitoringPermissionTitle =>
      'कीबोर्ड मॉनिटरिंग उपलब्ध नहीं है';

  @override
  String get inputMonitoringPermissionDescription =>
      'कीबोर्ड गतिविधि ट्रैक करने के लिए इनपुट मॉनिटरिंग अनुमति सक्षम करें। फिलहाल केवल माउस इनपुट मॉनिटर किया जा रहा है।';

  @override
  String get openSettings => 'सेटिंग्स खोलें';

  @override
  String get permissionGrantedTitle => 'अनुमति प्रदान की गई';

  @override
  String get permissionGrantedDescription =>
      'इनपुट मॉनिटरिंग लागू करने के लिए ऐप को पुनः प्रारंभ करना होगा।';

  @override
  String get continueButton => 'जारी रखें';

  @override
  String get restartRequiredTitle => 'पुनः प्रारंभ आवश्यक';

  @override
  String get restartRequiredDescription =>
      'कीबोर्ड मॉनिटरिंग सक्षम करने के लिए ऐप को पुनः प्रारंभ करना आवश्यक है। यह macOS द्वारा आवश्यक है।';

  @override
  String get restartNote => 'पुनः प्रारंभ के बाद ऐप स्वतः फिर से खुलेगा।';

  @override
  String get restartNow => 'अभी पुनः प्रारंभ करें';

  @override
  String get restartLater => 'बाद में पुनः प्रारंभ करें';

  @override
  String get restartFailedTitle => 'पुनः प्रारंभ विफल';

  @override
  String get restartFailedMessage =>
      'ऐप स्वतः पुनः प्रारंभ नहीं हो सका। कृपया बाहर निकलें (Cmd+Q) और मैन्युअल रूप से फिर से खोलें।';

  @override
  String get exportAnalyticsReport => 'एनालिटिक्स रिपोर्ट निर्यात करें';

  @override
  String get chooseExportFormat => 'निर्यात प्रारूप चुनें:';

  @override
  String get beautifulExcelReport => 'सुंदर एक्सेल रिपोर्ट';

  @override
  String get beautifulExcelReportDescription =>
      'चार्ट, इमोजी और अंतर्दृष्टि के साथ शानदार, रंगीन स्प्रेडशीट ✨';

  @override
  String get excelReportIncludes => 'एक्सेल रिपोर्ट में शामिल है:';

  @override
  String get summarySheetDescription =>
      '📊 सारांश शीट - प्रमुख मेट्रिक्स और रुझान';

  @override
  String get dailyBreakdownDescription => '📅 दैनिक विवरण - दृश्य उपयोग पैटर्न';

  @override
  String get appsSheetDescription => '📱 ऐप्स शीट - विस्तृत ऐप रैंकिंग';

  @override
  String get insightsDescription => '💡 अंतर्दृष्टि - स्मार्ट सिफारिशें';

  @override
  String get beautifulExcelExportSuccess =>
      'सुंदर एक्सेल रिपोर्ट सफलतापूर्वक निर्यात हुई! 🎉';

  @override
  String failedToExportReport(String error) {
    return 'रिपोर्ट निर्यात करने में विफल: $error';
  }

  @override
  String get exporting => 'निर्यात हो रहा है...';

  @override
  String get exportExcel => 'एक्सेल निर्यात करें';

  @override
  String get saveAnalyticsReport => 'एनालिटिक्स रिपोर्ट सहेजें';

  @override
  String analyticsReportFileName(String timestamp) {
    return 'एनालिटिक्स_रिपोर्ट_$timestamp.xlsx';
  }

  @override
  String get usageAnalyticsReportTitle => 'उपयोग विश्लेषण रिपोर्ट';

  @override
  String get generated => 'जेनरेट किया गया:';

  @override
  String get period => 'अवधि:';

  @override
  String dateRangeValue(String startDate, String endDate) {
    return '$startDate से $endDate';
  }

  @override
  String get keyMetrics => 'मुख्य मेट्रिक्स';

  @override
  String get metric => 'मेट्रिक';

  @override
  String get value => 'मूल्य';

  @override
  String get change => 'परिवर्तन';

  @override
  String get trend => 'रुझान';

  @override
  String get productivityRate => 'उत्पादकता दर';

  @override
  String get trendUp => 'ऊपर';

  @override
  String get trendDown => 'नीचे';

  @override
  String get trendExcellent => 'उत्कृष्ट';

  @override
  String get trendGood => 'अच्छा';

  @override
  String get trendNeedsImprovement => 'सुधार की आवश्यकता';

  @override
  String get trendActive => 'सक्रिय';

  @override
  String get trendNone => 'कोई नहीं';

  @override
  String get trendTop => 'शीर्ष';

  @override
  String get category => 'श्रेणी';

  @override
  String get percentage => 'प्रतिशत';

  @override
  String get visual => 'दृश्य';

  @override
  String get statistics => 'आंकड़े';

  @override
  String get averageDaily => 'दैनिक औसत';

  @override
  String get highestDay => 'सबसे अधिक दिन';

  @override
  String get lowestDay => 'सबसे कम दिन';

  @override
  String get day => 'दिन';

  @override
  String get applicationUsageDetails => 'एप्लिकेशन उपयोग विवरण';

  @override
  String get totalApps => 'कुल ऐप्स:';

  @override
  String get productiveApps => 'उत्पादक ऐप्स:';

  @override
  String get rank => 'रैंक';

  @override
  String get application => 'एप्लिकेशन';

  @override
  String get time => 'समय';

  @override
  String get percentOfTotal => 'कुल का %';

  @override
  String get type => 'प्रकार';

  @override
  String get usageLevel => 'उपयोग स्तर';

  @override
  String get leisure => 'मनोरंजन';

  @override
  String get usageLevelVeryHigh => 'बहुत अधिक ||||||||';

  @override
  String get usageLevelHigh => 'अधिक ||||||';

  @override
  String get usageLevelMedium => 'मध्यम ||||';

  @override
  String get usageLevelLow => 'कम ||';

  @override
  String get keyInsightsTitle => 'मुख्य अंतर्दृष्टि और सिफारिशें';

  @override
  String get personalizedRecommendations => 'व्यक्तिगत सिफारिशें';

  @override
  String insightHighDailyUsage(String hours) {
    return 'उच्च दैनिक उपयोग: आप प्रतिदिन औसतन $hours घंटे स्क्रीन उपयोग कर रहे हैं';
  }

  @override
  String insightLowDailyUsage(String hours) {
    return 'कम दैनिक उपयोग: आप प्रतिदिन औसतन $hours घंटे - बढ़िया संतुलन!';
  }

  @override
  String insightModerateUsage(String hours) {
    return 'मध्यम उपयोग: प्रतिदिन औसतन $hours घंटे स्क्रीन समय';
  }

  @override
  String insightExcellentProductivity(String percentage) {
    return 'उत्कृष्ट उत्पादकता: आपके स्क्रीन समय का $percentage% उत्पादक कार्य है!';
  }

  @override
  String insightGoodProductivity(String percentage) {
    return 'अच्छी उत्पादकता: आपके स्क्रीन समय का $percentage% उत्पादक है';
  }

  @override
  String insightLowProductivity(String percentage) {
    return 'कम उत्पादकता चेतावनी: केवल $percentage% स्क्रीन समय उत्पादक है';
  }

  @override
  String insightFocusSessions(int count, String avgPerDay) {
    return 'फोकस सत्र: $count सत्र पूरे किए (औसतन प्रतिदिन $avgPerDay)';
  }

  @override
  String insightGreatFocusHabit(int count) {
    return 'बढ़िया फोकस आदत: आपने $count पूर्ण सत्रों के साथ एक शानदार फोकस दिनचर्या बनाई है!';
  }

  @override
  String get insightNoFocusSessions =>
      'कोई फोकस सत्र नहीं: उत्पादकता बढ़ाने के लिए फोकस मोड का उपयोग करने पर विचार करें';

  @override
  String insightScreenTimeTrend(String direction, String percentage) {
    return 'स्क्रीन समय रुझान: पिछली अवधि की तुलना में आपका उपयोग $percentage% $direction';
  }

  @override
  String insightProductiveTimeTrend(String direction, String percentage) {
    return 'उत्पादक समय रुझान: पिछली अवधि की तुलना में आपका उत्पादक समय $percentage% $direction';
  }

  @override
  String get directionIncreased => 'बढ़ा';

  @override
  String get directionDecreased => 'घटा';

  @override
  String insightTopCategory(String category, String percentage) {
    return 'शीर्ष श्रेणी: $category आपके कुल समय का $percentage% है';
  }

  @override
  String insightMostUsedApp(
      String appName, String percentage, String duration) {
    return 'सबसे अधिक उपयोग किया गया ऐप: $appName आपके समय का $percentage% ($duration) है';
  }

  @override
  String insightUsageVaries(String highDay, String multiplier, String lowDay) {
    return 'उपयोग में महत्वपूर्ण अंतर: $highDay का उपयोग $lowDay से ${multiplier}x अधिक था';
  }

  @override
  String get insightNoInsights => 'कोई महत्वपूर्ण अंतर्दृष्टि उपलब्ध नहीं';

  @override
  String get recScheduleFocusSessions =>
      'उत्पादकता बढ़ाने के लिए पूरे दिन में अधिक फोकस सत्र शेड्यूल करने का प्रयास करें';

  @override
  String get recSetAppLimits => 'मनोरंजन ऐप्स पर सीमाएं लगाने पर विचार करें';

  @override
  String get recAimForFocusSessions =>
      'निरंतर आदत बनाने के लिए प्रतिदिन कम से कम 1-2 फोकस सत्र का लक्ष्य रखें';

  @override
  String get recTakeBreaks =>
      'आपका दैनिक स्क्रीन समय काफी अधिक है। 20-20-20 नियम का उपयोग करके नियमित ब्रेक लें';

  @override
  String get recSetDailyGoals =>
      'धीरे-धीरे उपयोग कम करने के लिए दैनिक स्क्रीन समय लक्ष्य निर्धारित करने पर विचार करें';

  @override
  String get recBalanceEntertainment =>
      'मनोरंजन ऐप्स आपके समय का बड़ा हिस्सा लेते हैं। अधिक उत्पादक गतिविधियों के साथ संतुलन बनाने पर विचार करें';

  @override
  String get recReviewUsagePatterns =>
      'आपका स्क्रीन समय काफी बढ़ गया है। अपने उपयोग पैटर्न की समीक्षा करें और सीमाएं निर्धारित करें';

  @override
  String get recScheduleFocusedWork =>
      'आपका उत्पादक समय कम हो गया है। अपने कैलेंडर में फोकस कार्य ब्लॉक शेड्यूल करने का प्रयास करें';

  @override
  String get recKeepUpGreatWork =>
      'बढ़िया काम जारी रखें! आपकी स्क्रीन समय आदतें स्वस्थ दिखती हैं';

  @override
  String get recContinueFocusSessions =>
      'उत्पादकता बनाए रखने के लिए फोकस सत्र का उपयोग जारी रखें';

  @override
  String get sheetSummary => 'सारांश';

  @override
  String get sheetDailyBreakdown => 'दैनिक विवरण';

  @override
  String get sheetApps => 'ऐप्स';

  @override
  String get sheetInsights => 'अंतर्दृष्टि';

  @override
  String get statusHeader => 'स्थिति';

  @override
  String workSessions(int count) {
    return '$count कार्य सत्र';
  }

  @override
  String get complete => 'पूर्ण';

  @override
  String get inProgress => 'प्रगति में';

  @override
  String get workTime => 'कार्य समय';

  @override
  String get breakTime => 'विराम समय';

  @override
  String get phasesCompleted => 'पूर्ण चरण';

  @override
  String hourMinuteFormat(String hours, String minutes) {
    return '$hours घंटा $minutes मिनट';
  }

  @override
  String hourOnlyFormat(String hours) {
    return '$hours घंटा';
  }

  @override
  String minuteFormat(String minutes) {
    return '$minutes मिनट';
  }

  @override
  String sessionsCount(int count) {
    return '$count सत्र';
  }

  @override
  String get workPhases => 'कार्य चरण';

  @override
  String get averageLength => 'औसत अवधि';

  @override
  String get mostProductive => 'सबसे उत्पादक';

  @override
  String get work => 'कार्य';

  @override
  String get breaks => 'विराम';

  @override
  String get none => 'कोई नहीं';

  @override
  String minuteShortFormat(String minutes) {
    return '$minutesमि';
  }

  @override
  String get importTheme => 'थीम आयात करें';

  @override
  String get exportTheme => 'थीम निर्यात करें';

  @override
  String get import => 'आयात करें';

  @override
  String get export => 'निर्यात करें';

  @override
  String get chooseExportMethod => 'अपनी थीम निर्यात करने का तरीका चुनें:';

  @override
  String get saveAsFile => 'फ़ाइल के रूप में सहेजें';

  @override
  String get saveThemeAsJSONFile =>
      'थीम को अपने डिवाइस पर JSON फ़ाइल के रूप में सहेजें';

  @override
  String get copyToClipboard => 'क्लिपबोर्ड पर कॉपी करें';

  @override
  String get copyThemeJSONToClipboard => 'थीम डेटा को क्लिपबोर्ड पर कॉपी करें';

  @override
  String get share => 'साझा करें';

  @override
  String get shareThemeViaSystemSheet =>
      'सिस्टम शेयर शीट का उपयोग करके थीम साझा करें';

  @override
  String get chooseImportMethod => 'थीम आयात करने का तरीका चुनें:';

  @override
  String get loadFromFile => 'फ़ाइल से लोड करें';

  @override
  String get selectJSONFileFromDevice => 'अपने डिवाइस से JSON थीम फ़ाइल चुनें';

  @override
  String get pasteFromClipboard => 'क्लिपबोर्ड से पेस्ट करें';

  @override
  String get importFromClipboardJSON => 'क्लिपबोर्ड JSON डेटा से थीम आयात करें';

  @override
  String get importFromFile => 'फ़ाइल से थीम आयात करें';

  @override
  String get themeCreatedSuccessfully => 'थीम सफलतापूर्वक बनाई गई!';

  @override
  String get themeUpdatedSuccessfully => 'थीम सफलतापूर्वक अपडेट की गई!';

  @override
  String get themeDeletedSuccessfully => 'थीम सफलतापूर्वक हटाई गई!';

  @override
  String get themeExportedSuccessfully => 'थीम सफलतापूर्वक निर्यात की गई!';

  @override
  String get themeCopiedToClipboard => 'थीम क्लिपबोर्ड पर कॉपी की गई!';

  @override
  String themeImportedSuccessfully(String themeName) {
    return 'थीम \"$themeName\" सफलतापूर्वक आयात की गई!';
  }

  @override
  String get noThemeDataFound => 'कोई थीम डेटा नहीं मिला';

  @override
  String get invalidThemeFormat =>
      'अमान्य थीम प्रारूप। कृपया JSON डेटा जांचें।';

  @override
  String get trackingModeTitle => 'ट्रैकिंग मोड';

  @override
  String get trackingModeDescription =>
      'चुनें कि ऐप उपयोग को कैसे ट्रैक किया जाए';

  @override
  String get trackingModePolling => 'मानक (कम संसाधन)';

  @override
  String get trackingModePrecise => 'सटीक (उच्च सटीकता)';

  @override
  String get trackingModePollingHint =>
      'हर मिनट जाँच करता है - कम संसाधन उपयोग';

  @override
  String get trackingModePreciseHint =>
      'रीयल-टाइम ट्रैकिंग - उच्च सटीकता, अधिक संसाधन';

  @override
  String get trackingModeChangeError =>
      'ट्रैकिंग मोड बदलने में विफल। कृपया पुनः प्रयास करें।';

  @override
  String get errorTitle => 'त्रुटि';

  @override
  String get monitorKeyboardTitle => 'कीबोर्ड की निगरानी करें';

  @override
  String get monitorKeyboardDescription =>
      'उपयोगकर्ता की उपस्थिति का पता लगाने के लिए कीबोर्ड गतिविधि ट्रैक करें';

  @override
  String get changelogWhatsNew => 'नया क्या है';

  @override
  String changelogReleasedOn(String date) {
    return '$date को जारी किया गया';
  }

  @override
  String get changelogNoContent =>
      'इस संस्करण के लिए कोई चेंजलॉग उपलब्ध नहीं है।';

  @override
  String get changelogUnableToLoad => 'चेंजलॉग लोड नहीं किया जा सका';

  @override
  String get changelogErrorDescription =>
      'इस संस्करण का चेंजलॉग प्राप्त नहीं किया जा सका। कृपया अपना इंटरनेट कनेक्शन जांचें या GitHub रिलीज़ पेज पर जाएं।';

  @override
  String get allTracking => 'सभी ऐप्स';

  @override
  String get notTracking => 'ट्रैक नहीं किए गए';

  @override
  String get allVisibility => 'सभी';

  @override
  String get visible => 'दृश्यमान';

  @override
  String get hidden => 'छिपे हुए';

  @override
  String get todaysLimitUsage => 'आज की सीमा उपयोग';

  @override
  String get thisWeekAtAGlance => 'इस सप्ताह की एक झलक';

  @override
  String get hourlyActivityHeatmap => 'प्रति घंटा गतिविधि हीटमैप';

  @override
  String get productivityScore => 'उत्पादकता स्कोर';

  @override
  String get streaks => 'लगातार दिन';

  @override
  String get weekOverWeek => 'सप्ताह दर सप्ताह';

  @override
  String get sameAsLastWeek => 'पिछले सप्ताह जैसा ही';

  @override
  String moreUsageThanLastWeek(String percent) {
    return 'पिछले सप्ताह से $percent% अधिक';
  }

  @override
  String lessUsageThanLastWeek(String percent) {
    return 'पिछले सप्ताह से $percent% कम';
  }

  @override
  String limitExceededBy(String duration) {
    return 'सीमा $duration से अधिक';
  }

  @override
  String timeRemaining(String duration) {
    return '$duration शेष';
  }

  @override
  String get totalSessions => 'कुल सत्र';

  @override
  String get avgSession => 'औसत सत्र';

  @override
  String get mostActive => 'सबसे सक्रिय';

  @override
  String get peakUsage => 'अधिकतम उपयोग';

  @override
  String get dailyAverage => 'दैनिक औसत';

  @override
  String get daysUsedInARow => 'लगातार उपयोग के दिन';

  @override
  String get daysSingular => 'दिन';

  @override
  String get daysPlural => 'दिन';

  @override
  String get daysOverLimitInARow => 'लगातार सीमा से अधिक दिन';

  @override
  String get withinLimitAllWeek => 'पूरे सप्ताह सीमा के भीतर';

  @override
  String get productivityScoreGreat => 'बढ़िया';

  @override
  String get productivityScoreModerate => 'मध्यम';

  @override
  String get productivityScoreNeedsAttention => 'ध्यान देने की आवश्यकता';

  @override
  String get productiveAppMotivation => 'उत्पादक ऐप — ऐसे ही जारी रखें';

  @override
  String get nonProductiveAppSuggestion => 'अनुत्पादक — कम करने पर विचार करें';

  @override
  String get legendUsage => 'उपयोग';

  @override
  String get legendAverage => 'औसत';

  @override
  String get legendLimit => 'सीमा';

  @override
  String get chartPeak => 'शीर्ष';

  @override
  String overLimitBy(String duration) {
    return '+$duration सीमा से अधिक';
  }

  @override
  String get noData => 'कोई डेटा नहीं';

  @override
  String get yesterday => 'कल';

  @override
  String get changelog => 'परिवर्तन लॉग';
}
