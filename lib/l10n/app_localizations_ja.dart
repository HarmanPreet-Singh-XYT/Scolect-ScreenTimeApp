// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appWindowTitle => 'Scolect - スクリーンタイム＆アプリ使用状況追跡';

  @override
  String get appName => 'Scolect';

  @override
  String get appTitle => '生産的なスクリーンタイム';

  @override
  String get sidebarTitle => 'スクリーンタイム';

  @override
  String get sidebarSubtitle => 'オープンソース';

  @override
  String get trayShowWindow => 'ウィンドウを表示';

  @override
  String get trayStartFocusMode => '集中モードを開始';

  @override
  String get trayStopFocusMode => '集中モードを停止';

  @override
  String get trayReports => 'レポート';

  @override
  String get trayAlertsLimits => 'アラート＆制限';

  @override
  String get trayApplications => 'アプリケーション';

  @override
  String get trayDisableNotifications => '通知を無効化';

  @override
  String get trayEnableNotifications => '通知を有効化';

  @override
  String get trayVersionPrefix => 'バージョン: ';

  @override
  String trayVersion(String version) {
    return 'バージョン: $version';
  }

  @override
  String get trayExit => '終了';

  @override
  String get navOverview => '概要';

  @override
  String get navApplications => 'アプリケーション';

  @override
  String get navAlertsLimits => 'アラート＆制限';

  @override
  String get navReports => 'レポート';

  @override
  String get navFocusMode => '集中モード';

  @override
  String get navSettings => '設定';

  @override
  String get navHelp => 'ヘルプ';

  @override
  String get helpTitle => 'ヘルプ';

  @override
  String get faqCategoryGeneral => '一般的な質問';

  @override
  String get faqCategoryApplications => 'アプリケーション管理';

  @override
  String get faqCategoryReports => '使用状況分析＆レポート';

  @override
  String get faqCategoryAlerts => 'アラート＆制限';

  @override
  String get faqCategoryFocusMode => '集中モード＆ポモドーロタイマー';

  @override
  String get faqCategorySettings => '設定＆カスタマイズ';

  @override
  String get faqCategoryTroubleshooting => 'トラブルシューティング';

  @override
  String get faqGeneralQ1 => 'このアプリはどのようにスクリーンタイムを追跡しますか？';

  @override
  String get faqGeneralA1 =>
      'このアプリは、デバイスの使用状況をリアルタイムで監視し、さまざまなアプリケーションでの使用時間を追跡します。総スクリーンタイム、生産的な時間、アプリケーション固有の使用状況など、デジタル習慣に関する包括的な洞察を提供します。';

  @override
  String get faqGeneralQ2 => 'アプリが「生産的」とされる基準は何ですか？';

  @override
  String get faqGeneralA2 =>
      '「アプリケーション」セクションでアプリを手動で生産的としてマークできます。生産的なアプリは、仕事関連または有益なアプリケーションに費やしたスクリーンタイムの割合を計算する生産性スコアに貢献します。';

  @override
  String get faqGeneralQ3 => 'スクリーンタイム追跡はどの程度正確ですか？';

  @override
  String get faqGeneralA3 =>
      'このアプリは、システムレベルの追跡を使用して、デバイス使用量を正確に測定します。各アプリケーションのフォアグラウンド時間をバッテリーへの影響を最小限に抑えながらキャプチャします。';

  @override
  String get faqGeneralQ4 => 'アプリのカテゴリ分類をカスタマイズできますか？';

  @override
  String get faqGeneralA4 =>
      'もちろんです！「アプリケーション」セクションで、カスタムカテゴリを作成し、アプリを特定のカテゴリに割り当て、これらの割り当てを簡単に変更できます。これにより、より意味のある使用状況分析を作成できます。';

  @override
  String get faqGeneralQ5 => 'このアプリからどのような洞察を得られますか？';

  @override
  String get faqGeneralA5 =>
      'このアプリは、生産性スコア、時間帯別の使用パターン、詳細なアプリケーション使用状況、集中セッション追跡、グラフや円グラフなどの視覚的分析を含む包括的な洞察を提供し、デジタル習慣を理解し改善するのに役立ちます。';

  @override
  String get faqAppsQ1 => '特定のアプリを追跡から非表示にするにはどうすればよいですか？';

  @override
  String get faqAppsA1 => '「アプリケーション」セクションで、アプリの表示を切り替えることができます。';

  @override
  String get faqAppsQ2 => 'アプリケーションを検索およびフィルタリングできますか？';

  @override
  String get faqAppsA2 =>
      'はい、「アプリケーション」セクションには検索機能とフィルタリングオプションがあります。カテゴリ、生産性ステータス、追跡ステータス、表示状態でアプリをフィルタリングできます。';

  @override
  String get faqAppsQ3 => 'アプリケーションにはどのような編集オプションがありますか？';

  @override
  String get faqAppsA3 =>
      '各アプリケーションについて、カテゴリの割り当て、生産性ステータス、使用状況の追跡、レポートでの表示、個別の1日の時間制限を編集できます。';

  @override
  String get faqAppsQ4 => 'アプリケーションのカテゴリはどのように決定されますか？';

  @override
  String get faqAppsA4 =>
      '初期のカテゴリはシステムによって提案されますが、ワークフローと好みに基づいてカスタムカテゴリを作成、変更、割り当てることができます。';

  @override
  String get faqReportsQ1 => 'どのような種類のレポートが利用できますか？';

  @override
  String get faqReportsA1 =>
      'レポートには以下が含まれます：総スクリーンタイム、生産的な時間、最も使用されているアプリ、集中セッション、1日のスクリーンタイムグラフ、カテゴリ別円グラフ、詳細なアプリケーション使用状況、週間使用傾向、時間帯別使用パターン分析。';

  @override
  String get faqReportsQ2 => 'アプリケーション使用レポートはどの程度詳細ですか？';

  @override
  String get faqReportsA2 =>
      '詳細なアプリケーション使用レポートには、アプリ名、カテゴリ、総使用時間、生産性ステータスが表示され、使用状況サマリー、1日の制限、使用傾向、生産性指標などのより深い洞察を持つ「アクション」セクションがあります。';

  @override
  String get faqReportsQ3 => '時間の経過に伴う使用傾向を分析できますか？';

  @override
  String get faqReportsA3 =>
      'はい！このアプリは週ごとの比較を提供し、過去数週間の使用状況グラフ、1日の平均使用時間、最長セッション、週間合計を表示して、デジタル習慣を追跡するのに役立ちます。';

  @override
  String get faqReportsQ4 => '「使用パターン」分析とは何ですか？';

  @override
  String get faqReportsA4 =>
      '使用パターンは、スクリーンタイムを朝、午後、夕方、夜のセグメントに分割します。これにより、デバイスで最もアクティブな時間帯を理解し、改善すべき領域を特定できます。';

  @override
  String get faqAlertsQ1 => 'スクリーンタイム制限はどの程度細かく設定できますか？';

  @override
  String get faqAlertsA1 =>
      '全体的な1日のスクリーンタイム制限と個別のアプリ制限を設定できます。制限は時間と分で設定でき、必要に応じてリセットまたは調整するオプションがあります。';

  @override
  String get faqAlertsQ2 => 'どのような通知オプションがありますか？';

  @override
  String get faqAlertsA2 =>
      'このアプリは複数の通知タイプを提供します：スクリーンタイムを超えた場合のシステムアラート、カスタマイズ可能な間隔（1、5、15、30、または60分）での頻繁なアラート、集中モード、スクリーンタイム、およびアプリケーション固有の通知の切り替え。';

  @override
  String get faqAlertsQ3 => '制限アラートをカスタマイズできますか？';

  @override
  String get faqAlertsA3 =>
      'はい、アラートの頻度をカスタマイズし、特定のタイプのアラートを有効/無効にし、全体的なスクリーンタイムと個別のアプリケーションに異なる制限を設定できます。';

  @override
  String get faqFocusQ1 => 'どのような種類の集中モードがありますか？';

  @override
  String get faqFocusA1 =>
      '利用可能なモードには、ディープワーク（長時間の集中セッション）、クイックタスク（短時間の作業）、リーディングモードがあります。各モードは、作業と休憩時間を効果的に構造化するのに役立ちます。';

  @override
  String get faqFocusQ2 => 'ポモドーロタイマーはどの程度柔軟ですか？';

  @override
  String get faqFocusA2 =>
      'タイマーは高度にカスタマイズ可能です。作業時間、短い休憩の長さ、長い休憩の時間を調整できます。追加オプションには、次のセッションの自動開始と通知設定があります。';

  @override
  String get faqFocusQ3 => '集中モード履歴には何が表示されますか？';

  @override
  String get faqFocusA3 =>
      '集中モード履歴は、1日の集中セッションを追跡し、1日あたりのセッション数、傾向グラフ、平均セッション時間、合計集中時間、作業セッション、短い休憩、長い休憩を分類した時間分布円グラフを表示します。';

  @override
  String get faqFocusQ4 => '集中セッションの進捗を追跡できますか？';

  @override
  String get faqFocusA4 =>
      'このアプリは、再生/一時停止、リロード、設定ボタンを備えた円形タイマーUIを特徴としています。直感的なコントロールで集中セッションを簡単に追跡および管理できます。';

  @override
  String get faqSettingsQ1 => 'どのようなカスタマイズオプションがありますか？';

  @override
  String get faqSettingsA1 =>
      'カスタマイズには、テーマ選択（システム、ライト、ダーク）、言語設定、起動動作、包括的な通知コントロール、データのクリアや設定のリセットなどのデータ管理オプションが含まれます。';

  @override
  String get faqSettingsQ2 => 'フィードバックを送信したり、問題を報告するにはどうすればよいですか？';

  @override
  String get faqSettingsA2 =>
      '設定セクションの下部に、バグを報告、フィードバックを送信、またはサポートに連絡するためのボタンがあります。これらは適切なサポートチャネルにリダイレクトされます。';

  @override
  String get faqSettingsQ3 => 'データをクリアするとどうなりますか？';

  @override
  String get faqSettingsA3 =>
      'データをクリアすると、すべての使用統計、集中セッション履歴、カスタム設定がリセットされます。これは、新しく始めたり、トラブルシューティングに役立ちます。';

  @override
  String get faqTroubleQ1 => 'データが表示されない、hiveが開かないエラー';

  @override
  String get faqTroubleA1 =>
      'この問題は認識されています。一時的な修正方法は、設定からデータをクリアすることです。それでも機能しない場合は、ドキュメントに移動して、存在する場合は次のファイルを削除してください - harman_screentime_app_usage_box.hiveとharman_screentime_app_usage.lock。アプリを最新バージョンに更新することもお勧めします。';

  @override
  String get faqTroubleQ2 => 'アプリが起動するたびに開く場合、どうすればよいですか？';

  @override
  String get faqTroubleA2 =>
      'これはWindows 10で発生する既知の問題です。一時的な修正方法は、設定で「最小化で起動」を有効にして、最小化で起動するようにすることです。';

  @override
  String get usageAnalytics => '使用状況分析';

  @override
  String get last7Days => '過去7日間';

  @override
  String get lastMonth => '先月';

  @override
  String get last3Months => '過去3ヶ月';

  @override
  String get lifetime => '全期間';

  @override
  String get custom => 'カスタム';

  @override
  String get loadingAnalyticsData => '分析データを読み込み中...';

  @override
  String get tryAgain => '再試行';

  @override
  String get failedToInitialize => '分析の初期化に失敗しました。アプリケーションを再起動してください。';

  @override
  String unexpectedError(String error) {
    return '予期しないエラーが発生しました: $error。後でもう一度お試しください。';
  }

  @override
  String errorLoadingAnalytics(String error) {
    return '分析データの読み込みエラー: $error。接続を確認して再試行してください。';
  }

  @override
  String get customDialogTitle => 'カスタム';

  @override
  String get dateRange => '日付範囲：';

  @override
  String get specificDate => '特定の日付';

  @override
  String get startDate => '開始日: ';

  @override
  String get endDate => '終了日: ';

  @override
  String get date => '日付';

  @override
  String get cancel => 'キャンセル';

  @override
  String get apply => '適用';

  @override
  String get ok => 'OK';

  @override
  String get invalidDateRange => '無効な日付範囲';

  @override
  String get startDateBeforeEndDate => '開始日は終了日以前でなければなりません。';

  @override
  String get totalScreenTime => '合計スクリーン時間';

  @override
  String get productiveTime => '生産的時間';

  @override
  String get mostUsedApp => '最も使用されたアプリ';

  @override
  String get focusSessions => '集中セッション';

  @override
  String positiveComparison(String percent) {
    return '+$percent% 前期間比';
  }

  @override
  String negativeComparison(String percent) {
    return '$percent% 前期間比';
  }

  @override
  String iconLabel(String title) {
    return '$titleアイコン';
  }

  @override
  String get dailyScreenTime => '日別スクリーン時間';

  @override
  String get categoryBreakdown => 'カテゴリ内訳';

  @override
  String get noDataAvailable => 'データがありません';

  @override
  String sectionLabel(String title) {
    return '$titleセクション';
  }

  @override
  String get detailedApplicationUsage => '詳細なアプリケーション使用状況';

  @override
  String get searchApplications => 'アプリケーションを検索';

  @override
  String get nameHeader => '名前';

  @override
  String get categoryHeader => 'カテゴリ';

  @override
  String get totalTimeHeader => '合計時間';

  @override
  String get productivityHeader => '生産性';

  @override
  String get actionsHeader => 'アクション';

  @override
  String sortByOption(String option) {
    return '並べ替え: $option';
  }

  @override
  String get sortByName => '名前';

  @override
  String get sortByCategory => 'カテゴリ';

  @override
  String get sortByUsage => '使用状況';

  @override
  String get productive => '生産的';

  @override
  String get nonProductive => '非生産的';

  @override
  String get noApplicationsMatch => '検索条件に一致するアプリケーションがありません';

  @override
  String get viewDetails => '詳細を表示';

  @override
  String get usageSummary => '使用状況サマリー';

  @override
  String get usageOverPastWeek => '過去1週間の使用状況';

  @override
  String get usagePatternByTimeOfDay => '時間帯別使用パターン';

  @override
  String get patternAnalysis => 'パターン分析';

  @override
  String get today => '今日';

  @override
  String get dailyLimit => '1日の制限';

  @override
  String get noLimit => '制限なし';

  @override
  String get usageTrend => '使用傾向';

  @override
  String get productivity => '生産性';

  @override
  String get increasing => '増加中';

  @override
  String get decreasing => '減少中';

  @override
  String get stable => '安定';

  @override
  String get avgDailyUsage => '1日平均使用';

  @override
  String get longestSession => '最長セッション';

  @override
  String get weeklyTotal => '週間合計';

  @override
  String get noHistoricalData => '履歴データがありません';

  @override
  String get morning => '朝 (6-12)';

  @override
  String get afternoon => '午後 (12-5)';

  @override
  String get evening => '夕方 (5-9)';

  @override
  String get night => '夜 (9-6)';

  @override
  String get usageInsights => '使用状況の洞察';

  @override
  String get limitStatus => '制限ステータス';

  @override
  String get close => '閉じる';

  @override
  String primaryUsageTime(String appName, String timeOfDay) {
    return '$appNameを主に$timeOfDayに使用しています。';
  }

  @override
  String significantIncrease(String percentage) {
    return '使用量が前期間と比較して大幅に増加しました（$percentage%）。';
  }

  @override
  String get trendingUpward => '使用量は前期間と比較して上昇傾向にあります。';

  @override
  String significantDecrease(String percentage) {
    return '使用量が前期間と比較して大幅に減少しました（$percentage%）。';
  }

  @override
  String get trendingDownward => '使用量は前期間と比較して下降傾向にあります。';

  @override
  String get consistentUsage => '使用量は前期間と比較して一貫しています。';

  @override
  String get markedAsProductive => 'これは設定で生産的なアプリとしてマークされています。';

  @override
  String get markedAsNonProductive => 'これは設定で非生産的なアプリとしてマークされています。';

  @override
  String mostActiveTime(String time) {
    return '最もアクティブな時間は$time頃です。';
  }

  @override
  String get noLimitSet => 'このアプリケーションには使用制限が設定されていません。';

  @override
  String get limitReached => 'このアプリケーションの1日の制限に達しました。';

  @override
  String aboutToReachLimit(String remainingTime) {
    return '残り$remainingTimeで1日の制限に達しようとしています。';
  }

  @override
  String percentOfLimitUsed(int percent, String remainingTime) {
    return '1日の制限の$percent%を使用し、残り$remainingTimeです。';
  }

  @override
  String remainingTime(String time) {
    return '1日の制限のうち$time残っています。';
  }

  @override
  String get todayChart => '今日';

  @override
  String hourPeriodAM(int hour) {
    return '午前$hour時';
  }

  @override
  String hourPeriodPM(int hour) {
    return '午後$hour時';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '$minutes分';
  }

  @override
  String get alertsLimitsTitle => 'アラート＆制限';

  @override
  String get notificationsSettings => '通知設定';

  @override
  String get overallScreenTimeLimit => '全体的なスクリーンタイム制限';

  @override
  String get applicationLimits => 'アプリケーション制限';

  @override
  String get popupAlerts => 'ポップアップアラート';

  @override
  String get frequentAlerts => '頻繁なアラート';

  @override
  String get soundAlerts => 'サウンドアラート';

  @override
  String get systemAlerts => 'システムアラート';

  @override
  String get dailyTotalLimit => '1日の合計制限: ';

  @override
  String get hours => '時間';

  @override
  String get minutes => '分';

  @override
  String get currentUsage => '現在の使用量: ';

  @override
  String get tableName => '名前';

  @override
  String get tableCategory => 'カテゴリ';

  @override
  String get tableDailyLimit => '1日の制限';

  @override
  String get tableCurrentUsage => '現在の使用量';

  @override
  String get tableStatus => 'ステータス';

  @override
  String get tableActions => 'アクション';

  @override
  String get addLimit => '制限を追加';

  @override
  String get noApplicationsToDisplay => '表示するアプリケーションがありません';

  @override
  String get statusActive => 'アクティブ';

  @override
  String get statusOff => 'オフ';

  @override
  String get durationNone => 'なし';

  @override
  String get addApplicationLimit => 'アプリケーション制限を追加';

  @override
  String get selectApplication => 'アプリケーションを選択';

  @override
  String get selectApplicationPlaceholder => 'アプリケーションを選択してください';

  @override
  String get enableLimit => '制限を有効化: ';

  @override
  String editLimitTitle(String appName) {
    return '制限を編集: $appName';
  }

  @override
  String failedToLoadData(String error) {
    return 'データの読み込みに失敗しました: $error';
  }

  @override
  String get resetSettingsTitle => '設定をリセットしますか？';

  @override
  String get resetSettingsContent => '設定をリセットすると、復元できません。リセットしますか？';

  @override
  String get resetAll => 'すべてリセット';

  @override
  String get refresh => '更新';

  @override
  String get save => '保存';

  @override
  String get add => '追加';

  @override
  String get error => 'エラー';

  @override
  String get retry => '再試行';

  @override
  String get applicationsTitle => 'アプリケーション';

  @override
  String get searchApplication => 'アプリケーションを検索';

  @override
  String get tracking => '追跡中';

  @override
  String get hiddenVisible => '非表示/表示';

  @override
  String get selectCategory => 'カテゴリを選択';

  @override
  String get allCategories => 'すべて';

  @override
  String get tableScreenTime => 'スクリーンタイム';

  @override
  String get tableTracking => '追跡';

  @override
  String get tableHidden => '非表示';

  @override
  String get tableEdit => '編集';

  @override
  String editAppTitle(String appName) {
    return '$appNameを編集';
  }

  @override
  String get categorySection => 'カテゴリ';

  @override
  String get customCategory => 'カスタム';

  @override
  String get customCategoryPlaceholder => 'カスタムカテゴリ名を入力';

  @override
  String get uncategorized => '未分類';

  @override
  String get isProductive => '生産的';

  @override
  String get trackUsage => '使用状況を追跡';

  @override
  String get visibleInReports => 'レポートに表示';

  @override
  String get timeLimitsSection => '時間制限';

  @override
  String get enableDailyLimit => '1日の制限を有効化';

  @override
  String get setDailyTimeLimit => '1日の時間制限を設定:';

  @override
  String get saveChanges => '変更を保存';

  @override
  String errorLoadingData(String error) {
    return '概要データの読み込みエラー: $error';
  }

  @override
  String get focusModeTitle => '集中モード';

  @override
  String get historySection => '履歴';

  @override
  String get trendsSection => '傾向';

  @override
  String get timeDistributionSection => '時間分布';

  @override
  String get sessionHistorySection => 'セッション履歴';

  @override
  String get workSession => '作業セッション';

  @override
  String get shortBreak => '短い休憩';

  @override
  String get longBreak => '長い休憩';

  @override
  String get dateHeader => '日付';

  @override
  String get durationHeader => '時間';

  @override
  String get monday => '月曜日';

  @override
  String get tuesday => '火曜日';

  @override
  String get wednesday => '水曜日';

  @override
  String get thursday => '木曜日';

  @override
  String get friday => '金曜日';

  @override
  String get saturday => '土曜日';

  @override
  String get sunday => '日曜日';

  @override
  String get focusModeSettingsTitle => '集中モード設定';

  @override
  String get modeCustom => 'カスタム';

  @override
  String get modeDeepWork => 'ディープワーク (60分)';

  @override
  String get modeQuickTasks => 'クイックタスク (25分)';

  @override
  String get modeReading => 'リーディング (45分)';

  @override
  String workDurationLabel(int minutes) {
    return '作業時間: $minutes分';
  }

  @override
  String shortBreakLabel(int minutes) {
    return '短い休憩';
  }

  @override
  String longBreakLabel(int minutes) {
    return '長い休憩';
  }

  @override
  String get autoStartNextSession => '次のセッションを自動開始';

  @override
  String get blockDistractions => '集中モード中に気が散るものをブロック';

  @override
  String get enableNotifications => '通知を有効化';

  @override
  String get saved => '保存しました';

  @override
  String errorLoadingFocusModeData(String error) {
    return '集中モードデータの読み込みエラー: $error';
  }

  @override
  String get overviewTitle => '今日の概要';

  @override
  String get startFocusMode => '集中モードを開始';

  @override
  String get loadingProductivityData => '生産性データを読み込み中...';

  @override
  String get noActivityDataAvailable => 'アクティビティデータはまだありません';

  @override
  String get startUsingApplications =>
      'スクリーンタイムと生産性を追跡するには、アプリケーションの使用を開始してください。';

  @override
  String get refreshData => 'データを更新';

  @override
  String get topApplications => 'トップアプリケーション';

  @override
  String get noAppUsageDataAvailable => 'アプリケーション使用データはまだありません';

  @override
  String get noApplicationDataAvailable => 'アプリケーションデータはありません';

  @override
  String get noCategoryDataAvailable => 'カテゴリデータはありません';

  @override
  String get noApplicationLimitsSet => 'アプリケーション制限は設定されていません';

  @override
  String get screenLabel => 'スクリーン';

  @override
  String get timeLabel => 'タイム';

  @override
  String get productiveLabel => '生産的';

  @override
  String get scoreLabel => 'スコア';

  @override
  String get defaultNone => 'なし';

  @override
  String get defaultTime => '0時間0分';

  @override
  String get defaultCount => '0';

  @override
  String get unknownApp => '不明';

  @override
  String get settingsTitle => '設定';

  @override
  String get generalSection => '一般';

  @override
  String get notificationsSection => '通知';

  @override
  String get dataSection => 'データ';

  @override
  String get versionSection => 'バージョン';

  @override
  String get languageTitle => '言語';

  @override
  String get languageDescription => 'アプリケーションの言語';

  @override
  String get startupBehaviourTitle => '起動動作';

  @override
  String get startupBehaviourDescription => 'OS起動時に起動';

  @override
  String get launchMinimizedTitle => '最小化で起動';

  @override
  String get launchMinimizedDescription => 'システムトレイでアプリケーションを起動（Windows 10に推奨）';

  @override
  String get notificationsTitle => '通知';

  @override
  String get notificationsAllDescription => 'アプリケーションのすべての通知';

  @override
  String get focusModeNotificationsTitle => '集中モード';

  @override
  String get focusModeNotificationsDescription => '集中モードのすべての通知';

  @override
  String get screenTimeNotificationsTitle => 'スクリーンタイム';

  @override
  String get screenTimeNotificationsDescription => 'スクリーンタイム制限のすべての通知';

  @override
  String get appScreenTimeNotificationsTitle => 'アプリケーションスクリーンタイム';

  @override
  String get appScreenTimeNotificationsDescription =>
      'アプリケーションスクリーンタイム制限のすべての通知';

  @override
  String get frequentAlertsTitle => '頻繁なアラート間隔';

  @override
  String get frequentAlertsDescription => '頻繁な通知の間隔を設定（分）';

  @override
  String get clearDataTitle => 'データをクリア';

  @override
  String get clearDataDescription => 'すべての履歴および関連データをクリア';

  @override
  String get resetSettingsTitle2 => '設定をリセット';

  @override
  String get resetSettingsDescription => 'すべての設定をリセット';

  @override
  String get versionTitle => 'バージョン';

  @override
  String get versionDescription => 'アプリの現在のバージョン';

  @override
  String get contactButton => 'お問い合わせ';

  @override
  String get reportBugButton => 'バグを報告';

  @override
  String get submitFeedbackButton => 'フィードバックを送信';

  @override
  String get githubButton => 'Github';

  @override
  String get clearDataDialogTitle => 'データをクリアしますか？';

  @override
  String get clearDataDialogContent =>
      'これにより、すべての履歴と関連データがクリアされます。復元できません。続行しますか？';

  @override
  String get clearDataButtonLabel => 'データをクリア';

  @override
  String get resetSettingsDialogTitle => '設定をリセットしますか？';

  @override
  String get resetSettingsDialogContent =>
      'これにより、すべての設定がデフォルト値にリセットされます。続行しますか？';

  @override
  String get resetButtonLabel => 'リセット';

  @override
  String get cancelButton => 'キャンセル';

  @override
  String couldNotLaunchUrl(String url) {
    return '$urlを開けませんでした';
  }

  @override
  String errorMessage(String message) {
    return 'エラー: $message';
  }

  @override
  String get chart_focusTrends => '集中傾向';

  @override
  String get chart_sessionCount => 'セッション数';

  @override
  String get chart_avgDuration => '平均時間';

  @override
  String get chart_totalFocus => '合計集中';

  @override
  String get chart_yAxis_sessions => 'セッション';

  @override
  String get chart_yAxis_minutes => '分';

  @override
  String get chart_yAxis_value => '値';

  @override
  String get chart_monthOverMonthChange => '前月比変化: ';

  @override
  String get chart_customRange => 'カスタム範囲';

  @override
  String get day_monday => '月曜日';

  @override
  String get day_mondayShort => '月';

  @override
  String get day_mondayAbbr => '月';

  @override
  String get day_tuesday => '火曜日';

  @override
  String get day_tuesdayShort => '火';

  @override
  String get day_tuesdayAbbr => '火';

  @override
  String get day_wednesday => '水曜日';

  @override
  String get day_wednesdayShort => '水';

  @override
  String get day_wednesdayAbbr => '水';

  @override
  String get day_thursday => '木曜日';

  @override
  String get day_thursdayShort => '木';

  @override
  String get day_thursdayAbbr => '木';

  @override
  String get day_friday => '金曜日';

  @override
  String get day_fridayShort => '金';

  @override
  String get day_fridayAbbr => '金';

  @override
  String get day_saturday => '土曜日';

  @override
  String get day_saturdayShort => '土';

  @override
  String get day_saturdayAbbr => '土';

  @override
  String get day_sunday => '日曜日';

  @override
  String get day_sundayShort => '日';

  @override
  String get day_sundayAbbr => '日';

  @override
  String time_hours(int count) {
    return '$count時間';
  }

  @override
  String time_hoursMinutes(int hours, int minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String time_minutesFormat(String count) {
    return '$count分';
  }

  @override
  String tooltip_dateScreenTime(String date, int hours, int minutes) {
    return '$date: $hours時間$minutes分';
  }

  @override
  String tooltip_hoursFormat(String count) {
    return '$count時間';
  }

  @override
  String get month_january => '1月';

  @override
  String get month_januaryShort => '1月';

  @override
  String get month_february => '2月';

  @override
  String get month_februaryShort => '2月';

  @override
  String get month_march => '3月';

  @override
  String get month_marchShort => '3月';

  @override
  String get month_april => '4月';

  @override
  String get month_aprilShort => '4月';

  @override
  String get month_may => '5月';

  @override
  String get month_mayShort => '5月';

  @override
  String get month_june => '6月';

  @override
  String get month_juneShort => '6月';

  @override
  String get month_july => '7月';

  @override
  String get month_julyShort => '7月';

  @override
  String get month_august => '8月';

  @override
  String get month_augustShort => '8月';

  @override
  String get month_september => '9月';

  @override
  String get month_septemberShort => '9月';

  @override
  String get month_october => '10月';

  @override
  String get month_octoberShort => '10月';

  @override
  String get month_november => '11月';

  @override
  String get month_novemberShort => '11月';

  @override
  String get month_december => '12月';

  @override
  String get month_decemberShort => '12月';

  @override
  String get categoryAll => 'すべて';

  @override
  String get categoryProductivity => '生産性';

  @override
  String get categoryDevelopment => '開発';

  @override
  String get categorySocialMedia => 'ソーシャルメディア';

  @override
  String get categoryEntertainment => 'エンターテイメント';

  @override
  String get categoryGaming => 'ゲーム';

  @override
  String get categoryCommunication => 'コミュニケーション';

  @override
  String get categoryWebBrowsing => 'ウェブブラウジング';

  @override
  String get categoryCreative => 'クリエイティブ';

  @override
  String get categoryEducation => '教育';

  @override
  String get categoryUtility => 'ユーティリティ';

  @override
  String get categoryUncategorized => '未分類';

  @override
  String get appMicrosoftWord => 'Microsoft Word';

  @override
  String get appExcel => 'Excel';

  @override
  String get appPowerPoint => 'PowerPoint';

  @override
  String get appGoogleDocs => 'Google ドキュメント';

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
  String get appGoogleCalendar => 'Google カレンダー';

  @override
  String get appAppleCalendar => 'カレンダー';

  @override
  String get appVisualStudioCode => 'Visual Studio Code';

  @override
  String get appTerminal => 'ターミナル';

  @override
  String get appCommandPrompt => 'コマンドプロンプト';

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
  String get appCalculator => '電卓';

  @override
  String get appNotes => 'メモ';

  @override
  String get appSystemPreferences => 'システム環境設定';

  @override
  String get appTaskManager => 'タスクマネージャー';

  @override
  String get appFileExplorer => 'エクスプローラー';

  @override
  String get appDropbox => 'Dropbox';

  @override
  String get appGoogleDrive => 'Google ドライブ';

  @override
  String get loadingApplication => 'アプリケーションを読み込み中...';

  @override
  String get loadingData => 'データを読み込み中...';

  @override
  String get reportsError => 'エラー';

  @override
  String get reportsRetry => '再試行';

  @override
  String get backupRestoreSection => 'バックアップ＆復元';

  @override
  String get backupRestoreTitle => 'バックアップ＆復元';

  @override
  String get exportDataTitle => 'データをエクスポート';

  @override
  String get exportDataDescription => 'すべてのデータのバックアップを作成';

  @override
  String get importDataTitle => 'データをインポート';

  @override
  String get importDataDescription => 'バックアップファイルから復元';

  @override
  String get exportButton => 'エクスポート';

  @override
  String get importButton => 'インポート';

  @override
  String get closeButton => '閉じる';

  @override
  String get noButton => 'いいえ';

  @override
  String get shareButton => '共有';

  @override
  String get exportStarting => 'エクスポートを開始しています...';

  @override
  String get exportSuccessful => 'エクスポート成功';

  @override
  String get exportFailed => 'エクスポート失敗';

  @override
  String get exportComplete => 'エクスポート完了';

  @override
  String get shareBackupQuestion => 'バックアップファイルを共有しますか？';

  @override
  String get importStarting => 'インポートを開始しています...';

  @override
  String get importSuccessful => 'インポート成功！';

  @override
  String get importFailed => 'インポートに失敗しました';

  @override
  String get importOptionsTitle => 'インポートオプション';

  @override
  String get importOptionsQuestion => 'データをどのようにインポートしますか？';

  @override
  String get replaceModeTitle => '置換';

  @override
  String get replaceModeDescription => '既存のすべてのデータを置換';

  @override
  String get mergeModeTitle => 'マージ';

  @override
  String get mergeModeDescription => '既存のデータと結合';

  @override
  String get appendModeTitle => '追加';

  @override
  String get appendModeDescription => '新しいレコードのみを追加';

  @override
  String get warningTitle => '⚠️ 警告';

  @override
  String get replaceWarningMessage => 'これにより既存のすべてのデータが置換されます。続行してもよろしいですか？';

  @override
  String get replaceAllButton => 'すべて置換';

  @override
  String get fileLabel => 'ファイル';

  @override
  String get sizeLabel => 'サイズ';

  @override
  String get recordsLabel => 'レコード';

  @override
  String get usageRecordsLabel => '使用記録';

  @override
  String get focusSessionsLabel => '集中セッション';

  @override
  String get appMetadataLabel => 'アプリメタデータ';

  @override
  String get updatedLabel => '更新済み';

  @override
  String get skippedLabel => 'スキップ済み';

  @override
  String get faqSettingsQ4 => 'データを復元またはエクスポートするにはどうすればよいですか？';

  @override
  String get faqSettingsA4 =>
      '設定に移動すると、バックアップ＆復元セクションがあります。ここからデータをエクスポートまたはインポートできます。エクスポートされたデータファイルはドキュメントのScolect-Backupsフォルダに保存され、このファイルのみがデータの復元に使用できます。他のファイルは使用できません。';

  @override
  String get faqGeneralQ6 =>
      '言語を変更するにはどうすればよいですか？また、どの言語が利用可能ですか？翻訳が間違っている場合はどうすればよいですか？';

  @override
  String get faqGeneralA6 =>
      '言語は設定の一般セクションから変更できます。利用可能なすべての言語がそこにリストされています。お問い合わせをクリックして、指定された言語でリクエストを送信することで、翻訳をリクエストできます。翻訳はAIによって英語から生成されるため、間違っている可能性があることにご注意ください。報告したい場合は、バグ報告、お問い合わせ、または開発者の場合はGithubでイシューを開くことができます。言語に関する貢献も歓迎します！';

  @override
  String get faqGeneralQ7 => '翻訳が間違っている場合はどうすればよいですか？';

  @override
  String get faqGeneralA7 =>
      '翻訳はAIによって英語から生成されるため、間違っている可能性があります。報告したい場合は、バグ報告、お問い合わせ、または開発者の場合はGithubでイシューを開くことができます。言語に関する貢献も歓迎します！';

  @override
  String get activityTrackingSection => 'アクティビティ追跡';

  @override
  String get idleDetectionTitle => 'アイドル検出';

  @override
  String get idleDetectionDescription => '非アクティブ時に追跡を停止';

  @override
  String get idleTimeoutTitle => 'アイドルタイムアウト';

  @override
  String idleTimeoutDescription(String timeout) {
    return 'アイドルと見なすまでの時間（$timeout）';
  }

  @override
  String get advancedWarning => '高度な機能はリソース使用量を増加させる可能性があります。必要な場合のみ有効にしてください。';

  @override
  String get monitorAudioTitle => 'システムオーディオを監視';

  @override
  String get monitorAudioDescription => 'オーディオ再生からアクティビティを検出';

  @override
  String get audioSensitivityTitle => 'オーディオ感度';

  @override
  String audioSensitivityDescription(String value) {
    return '検出しきい値（$value）';
  }

  @override
  String get monitorControllersTitle => 'ゲームコントローラーを監視';

  @override
  String get monitorControllersDescription => 'Xbox/XInputコントローラーを検出';

  @override
  String get monitorHIDTitle => 'HIDデバイスを監視';

  @override
  String get monitorHIDDescription => 'ホイール、タブレット、カスタムデバイスを検出';

  @override
  String get setIdleTimeoutTitle => 'アイドルタイムアウトを設定';

  @override
  String get idleTimeoutDialogDescription => 'アイドルと見なすまでの待機時間を選択してください：';

  @override
  String get seconds30 => '30秒';

  @override
  String get minute1 => '1分';

  @override
  String get minutes2 => '2分';

  @override
  String get minutes5 => '5分';

  @override
  String get minutes10 => '10分';

  @override
  String get customOption => 'カスタム';

  @override
  String get customDurationTitle => 'カスタム期間';

  @override
  String get minutesLabel => '分';

  @override
  String get secondsLabel => '秒';

  @override
  String get minAbbreviation => '分';

  @override
  String get secAbbreviation => '秒';

  @override
  String totalLabel(String duration) {
    return '合計：$duration';
  }

  @override
  String minimumError(String value) {
    return '最小値は$valueです';
  }

  @override
  String maximumError(String value) {
    return '最大値は$valueです';
  }

  @override
  String rangeInfo(String min, String max) {
    return '範囲：$min - $max';
  }

  @override
  String get saveButton => '保存';

  @override
  String timeFormatSeconds(int seconds) {
    return '$seconds秒';
  }

  @override
  String get timeFormatMinute => '1分';

  @override
  String timeFormatMinutes(int minutes) {
    return '$minutes分';
  }

  @override
  String timeFormatMinutesSeconds(int minutes, int seconds) {
    return '$minutes分$seconds秒';
  }

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeTitle => 'テーマ';

  @override
  String get themeDescription => 'アプリケーションのカラーテーマ';

  @override
  String get voiceGenderTitle => '音声の性別';

  @override
  String get voiceGenderDescription => 'タイマー通知の音声の性別を選択してください';

  @override
  String get voiceGenderMale => '男性';

  @override
  String get voiceGenderFemale => '女性';

  @override
  String get alertsLimitsSubtitle => 'スクリーンタイムの制限と通知を管理する';

  @override
  String get applicationsSubtitle => '追跡されたアプリケーションを管理する';

  @override
  String applicationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個のアプリケーション',
    );
    return '$_temp0';
  }

  @override
  String get noApplicationsFound => 'アプリケーションが見つかりません';

  @override
  String get tryAdjustingFilters => 'フィルターを調整してみてください';

  @override
  String get configureAppSettings => 'アプリケーション設定を構成する';

  @override
  String get behaviorSection => '動作';

  @override
  String helpSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '7つのカテゴリに$count個の質問',
    );
    return '$_temp0';
  }

  @override
  String get searchForHelp => 'ヘルプを検索...';

  @override
  String get quickNavGeneral => '一般';

  @override
  String get quickNavApps => 'アプリ';

  @override
  String get quickNavReports => 'レポート';

  @override
  String get quickNavFocus => 'フォーカス';

  @override
  String get noResultsFound => '結果が見つかりません';

  @override
  String get tryDifferentKeywords => '別のキーワードで検索してみてください';

  @override
  String get clearSearch => '検索をクリア';

  @override
  String get greetingMorning => 'おはようございます！アクティビティの概要をご覧ください。';

  @override
  String get greetingAfternoon => 'こんにちは！アクティビティの概要をご覧ください。';

  @override
  String get greetingEvening => 'こんばんは！アクティビティの概要をご覧ください。';

  @override
  String get screenTimeProgress => 'スクリーン\nタイム';

  @override
  String get productiveScoreProgress => '生産性\nスコア';

  @override
  String get focusModeSubtitle => '集中して、生産的に';

  @override
  String get thisWeek => '今週';

  @override
  String get sessions => 'セッション';

  @override
  String get totalTime => '合計時間';

  @override
  String get avgLength => '平均時間';

  @override
  String get focusTime => '集中時間';

  @override
  String get paused => '一時停止中';

  @override
  String get shortBreakStatus => '短い休憩';

  @override
  String get longBreakStatus => '長い休憩';

  @override
  String get readyToFocus => '集中する準備完了';

  @override
  String get focus => '集中';

  @override
  String get restartSession => 'セッションを再開';

  @override
  String get skipToNext => '次へスキップ';

  @override
  String get settings => '設定';

  @override
  String sessionsCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count セッション完了',
    );
    return '$_temp0';
  }

  @override
  String get focusModePreset => '集中モードプリセット';

  @override
  String get focusDuration => '集中時間';

  @override
  String minutesFormat(int minutes) {
    return '$minutes 分';
  }

  @override
  String get shortBreakDuration => '短い休憩';

  @override
  String get longBreakDuration => '長い休憩';

  @override
  String get enableSounds => 'サウンドを有効にする';

  @override
  String get focus_mode_this_week => '今週';

  @override
  String get focus_mode_best_day => 'ベストデー';

  @override
  String focus_mode_sessions_count(int count) {
    return '$countセッション';
  }

  @override
  String get focus_mode_no_data_yet => 'データがまだありません';

  @override
  String get chart_current => '現在';

  @override
  String get chart_previous => '前回';

  @override
  String get permission_error => '許可エラー';

  @override
  String get notification_permission_denied => '通知の許可が拒否されました';

  @override
  String get notification_permission_denied_message =>
      'ScreenTimeはアラートとリマインダーを送信するために通知の許可が必要です。\n\n通知を有効にするためにシステム設定を開きますか？';

  @override
  String get notification_permission_denied_hint =>
      'ScreenTimeの通知を有効にするには、システム設定を開いてください。';

  @override
  String get notification_permission_required => '通知の許可が必要です';

  @override
  String get notification_permission_required_message =>
      'ScreenTimeは通知を送信するために許可が必要です。';

  @override
  String get open_settings => '設定を開く';

  @override
  String get allow_notifications => '通知を許可';

  @override
  String get permission_allowed => '許可済み';

  @override
  String get permission_denied => '拒否';

  @override
  String get permission_not_set => '未設定';

  @override
  String get on => 'オン';

  @override
  String get off => 'オフ';

  @override
  String get enable_notification_permission_hint =>
      'アラートを受信するには通知の許可を有効にしてください';

  @override
  String minutes_format(int minutes) {
    return '$minutes分';
  }

  @override
  String get chart_average => '平均';

  @override
  String get chart_peak => 'ピーク';

  @override
  String get chart_lowest => '最低';

  @override
  String get active => 'アクティブ';

  @override
  String get disabled => '無効';

  @override
  String get advanced_options => '詳細オプション';

  @override
  String get sync_ready => '同期準備完了';

  @override
  String get success => '成功';

  @override
  String get destructive_badge => '破壊的';

  @override
  String get recommended_badge => '推奨';

  @override
  String get safe_badge => '安全';

  @override
  String get overview => '概要';

  @override
  String get patterns => 'パターン';

  @override
  String get apps => 'アプリ';

  @override
  String get sortAscending => '昇順で並べ替え';

  @override
  String get sortDescending => '降順で並べ替え';

  @override
  String applicationsShowing(int count) {
    return '$count個のアプリケーションを表示中';
  }

  @override
  String valueLabel(String value) {
    return '値：$value';
  }

  @override
  String appsCount(int count) {
    return '$count個のアプリ';
  }

  @override
  String categoriesCount(int count) {
    return '$count個のカテゴリ';
  }

  @override
  String get systemNotificationsDisabled =>
      'システム通知が無効になっています。フォーカスアラートのためにシステム設定で有効にしてください。';

  @override
  String get openSystemSettings => 'システム設定を開く';

  @override
  String get appNotificationsDisabled =>
      'アプリ設定で通知が無効になっています。フォーカスアラートを受け取るには有効にしてください。';

  @override
  String get goToSettings => '設定に移動';

  @override
  String get focusModeNotificationsDisabled =>
      'フォーカスモード通知が無効になっています。セッションアラートを受け取るには有効にしてください。';

  @override
  String get notificationsDisabled => '通知が無効';

  @override
  String get dontShowAgain => '今後表示しない';

  @override
  String get systemSettingsRequired => 'システム設定が必要';

  @override
  String get notificationsDisabledSystemLevel =>
      'システムレベルで通知が無効になっています。有効にするには:';

  @override
  String get step1OpenSystemSettings => '1. システム設定（システム環境設定）を開く';

  @override
  String get step2GoToNotifications => '2. 通知に移動';

  @override
  String get step3FindApp => '3. Scolectを見つけて選択';

  @override
  String get step4EnableNotifications => '4. 「通知を許可」を有効にする';

  @override
  String get returnToAppMessage => 'その後、このアプリに戻ると通知が機能します。';

  @override
  String get gotIt => '了解';

  @override
  String get noSessionsYet => 'まだセッションがありません';

  @override
  String applicationsTracked(int count) {
    return '$count個のアプリケーションを追跡中';
  }

  @override
  String get applicationHeader => 'アプリケーション';

  @override
  String get currentUsageHeader => '現在の使用状況';

  @override
  String get dailyLimitHeader => '1日の制限';

  @override
  String get edit => '編集';

  @override
  String get showPopupNotifications => 'ポップアップ通知を表示';

  @override
  String get moreFrequentReminders => 'より頻繁なリマインダー';

  @override
  String get playSoundWithAlerts => 'アラートと一緒に音を再生';

  @override
  String get systemTrayNotifications => 'システムトレイ通知';

  @override
  String screenTimeUsed(String current, String limit) {
    return '$current / $limit 使用済み';
  }

  @override
  String get todaysScreenTime => '今日のスクリーンタイム';

  @override
  String get activeLimits => 'アクティブな制限';

  @override
  String get nearLimit => '制限に近い';

  @override
  String get colorPickerSpectrum => 'スペクトラム';

  @override
  String get colorPickerPresets => 'プリセット';

  @override
  String get colorPickerSliders => 'スライダー';

  @override
  String get colorPickerBasicColors => '基本色';

  @override
  String get colorPickerExtendedPalette => '拡張パレット';

  @override
  String get colorPickerRed => '赤';

  @override
  String get colorPickerGreen => '緑';

  @override
  String get colorPickerBlue => '青';

  @override
  String get colorPickerHue => '色相';

  @override
  String get colorPickerSaturation => '彩度';

  @override
  String get colorPickerBrightness => '明度';

  @override
  String get colorPickerHexColor => '16進数カラー';

  @override
  String get colorPickerHexPlaceholder => 'RRGGBB';

  @override
  String get colorPickerRGB => 'RGB';

  @override
  String get select => '選択';

  @override
  String get themeCustomization => 'テーマのカスタマイズ';

  @override
  String get chooseThemePreset => 'テーマプリセットを選択';

  @override
  String get yourCustomThemes => 'カスタムテーマ';

  @override
  String get createCustomTheme => 'カスタムテーマを作成';

  @override
  String get designOwnColorScheme => '独自のカラースキームをデザイン';

  @override
  String get newTheme => '新しいテーマ';

  @override
  String get editCurrentTheme => '現在のテーマを編集';

  @override
  String customizeColorsFor(String themeName) {
    return '$themeNameの色をカスタマイズ';
  }

  @override
  String customThemeNumber(int number) {
    return 'カスタムテーマ $number';
  }

  @override
  String get deleteCustomTheme => 'カスタムテーマを削除';

  @override
  String confirmDeleteTheme(String themeName) {
    return '本当に「$themeName」を削除しますか？';
  }

  @override
  String get delete => '削除';

  @override
  String get customizeTheme => 'テーマをカスタマイズ';

  @override
  String get preview => 'プレビュー';

  @override
  String get themeName => 'テーマ名';

  @override
  String get brandColors => 'ブランドカラー';

  @override
  String get lightTheme => 'ライトテーマ';

  @override
  String get darkTheme => 'ダークテーマ';

  @override
  String get reset => 'リセット';

  @override
  String get saveTheme => 'テーマを保存';

  @override
  String get customTheme => 'カスタムテーマ';

  @override
  String get primaryColors => 'プライマリカラー';

  @override
  String get primaryColorsDesc => 'アプリ全体で使用される主要なアクセントカラー';

  @override
  String get primaryAccent => 'プライマリアクセント';

  @override
  String get primaryAccentDesc => 'メインブランドカラー、ボタン、リンク';

  @override
  String get secondaryAccent => 'セカンダリアクセント';

  @override
  String get secondaryAccentDesc => 'グラデーション用の補完アクセント';

  @override
  String get semanticColors => 'セマンティックカラー';

  @override
  String get semanticColorsDesc => '意味とステータスを伝える色';

  @override
  String get successColor => '成功カラー';

  @override
  String get successColorDesc => 'ポジティブなアクション、確認';

  @override
  String get warningColor => '警告カラー';

  @override
  String get warningColorDesc => '注意、保留状態';

  @override
  String get errorColor => 'エラーカラー';

  @override
  String get errorColorDesc => 'エラー、破壊的なアクション';

  @override
  String get backgroundColors => '背景色';

  @override
  String get backgroundColorsLightDesc => 'ライトモード用のメイン背景サーフェス';

  @override
  String get backgroundColorsDarkDesc => 'ダークモード用のメイン背景サーフェス';

  @override
  String get background => '背景';

  @override
  String get backgroundDesc => 'メインアプリの背景';

  @override
  String get surface => 'サーフェス';

  @override
  String get surfaceDesc => 'カード、ダイアログ、高さのあるサーフェス';

  @override
  String get surfaceSecondary => 'セカンダリサーフェス';

  @override
  String get surfaceSecondaryDesc => 'セカンダリカード、サイドバー';

  @override
  String get border => 'ボーダー';

  @override
  String get borderDesc => '区切り線、カードのボーダー';

  @override
  String get textColors => 'テキストカラー';

  @override
  String get textColorsLightDesc => 'ライトモード用のタイポグラフィカラー';

  @override
  String get textColorsDarkDesc => 'ダークモード用のタイポグラフィカラー';

  @override
  String get textPrimary => 'プライマリテキスト';

  @override
  String get textPrimaryDesc => '見出し、重要なテキスト';

  @override
  String get textSecondary => 'セカンダリテキスト';

  @override
  String get textSecondaryDesc => '説明、キャプション';

  @override
  String previewMode(String mode) {
    return 'プレビュー：$modeモード';
  }

  @override
  String get dark => 'ダーク';

  @override
  String get light => 'ライト';

  @override
  String get sampleCardTitle => 'サンプルカードタイトル';

  @override
  String get sampleSecondaryText => 'これは下に表示されるセカンダリテキストです。';

  @override
  String get primary => 'プライマリ';

  @override
  String get secondary => 'セカンダリ';

  @override
  String get warning => '警告';

  @override
  String get launchAtStartupTitle => 'スタートアップ時に起動';

  @override
  String get launchAtStartupDescription => 'コンピュータにログインしたときに自動的にScolectを起動します';

  @override
  String get inputMonitoringPermissionTitle => 'キーボード監視は利用できません';

  @override
  String get inputMonitoringPermissionDescription =>
      'キーボードの操作を追跡するには、入力監視の許可を有効にしてください。現在はマウス入力のみが監視されています。';

  @override
  String get openSettings => '設定を開く';

  @override
  String get permissionGrantedTitle => '許可が付与されました';

  @override
  String get permissionGrantedDescription => '入力監視を有効にするには、アプリを再起動する必要があります。';

  @override
  String get continueButton => '続ける';

  @override
  String get restartRequiredTitle => '再起動が必要です';

  @override
  String get restartRequiredDescription =>
      'キーボード監視を有効にするには、アプリを再起動する必要があります。これは macOS の仕様です。';

  @override
  String get restartNote => '再起動後、アプリは自動的に再起動します。';

  @override
  String get restartNow => '今すぐ再起動';

  @override
  String get restartLater => '後で再起動';

  @override
  String get restartFailedTitle => '再起動に失敗しました';

  @override
  String get restartFailedMessage =>
      'アプリを自動的に再起動できませんでした。終了（Cmd+Q）して手動で再起動してください。';

  @override
  String get exportAnalyticsReport => '分析レポートをエクスポート';

  @override
  String get chooseExportFormat => 'エクスポート形式を選択：';

  @override
  String get beautifulExcelReport => '美しいExcelレポート';

  @override
  String get beautifulExcelReportDescription =>
      'チャート、絵文字、インサイト付きの華やかでカラフルなスプレッドシート ✨';

  @override
  String get excelReportIncludes => 'Excelレポートに含まれるもの：';

  @override
  String get summarySheetDescription => '📊 サマリーシート - トレンド付きの主要指標';

  @override
  String get dailyBreakdownDescription => '📅 日別内訳 - 視覚的な使用パターン';

  @override
  String get appsSheetDescription => '📱 アプリシート - 詳細なアプリランキング';

  @override
  String get insightsDescription => '💡 インサイト - スマートな推奨事項';

  @override
  String get beautifulExcelExportSuccess => '美しいExcelレポートが正常にエクスポートされました！🎉';

  @override
  String failedToExportReport(String error) {
    return 'レポートのエクスポートに失敗しました：$error';
  }

  @override
  String get exporting => 'エクスポート中...';

  @override
  String get exportExcel => 'Excelエクスポート';

  @override
  String get saveAnalyticsReport => '分析レポートを保存';

  @override
  String analyticsReportFileName(String timestamp) {
    return '分析レポート_$timestamp.xlsx';
  }

  @override
  String get usageAnalyticsReportTitle => '使用状況分析レポート';

  @override
  String get generated => '作成日時：';

  @override
  String get period => '期間：';

  @override
  String dateRangeValue(String startDate, String endDate) {
    return '$startDate ～ $endDate';
  }

  @override
  String get keyMetrics => '主要指標';

  @override
  String get metric => '指標';

  @override
  String get value => '値';

  @override
  String get change => '変化';

  @override
  String get trend => '傾向';

  @override
  String get productivityRate => '生産性率';

  @override
  String get trendUp => '上昇';

  @override
  String get trendDown => '下降';

  @override
  String get trendExcellent => '優秀';

  @override
  String get trendGood => '良好';

  @override
  String get trendNeedsImprovement => '改善が必要';

  @override
  String get trendActive => 'アクティブ';

  @override
  String get trendNone => 'なし';

  @override
  String get trendTop => 'トップ';

  @override
  String get category => 'カテゴリ';

  @override
  String get percentage => 'パーセント';

  @override
  String get visual => 'ビジュアル';

  @override
  String get statistics => '統計';

  @override
  String get averageDaily => '日平均';

  @override
  String get highestDay => '最高の日';

  @override
  String get lowestDay => '最低の日';

  @override
  String get day => '曜日';

  @override
  String get applicationUsageDetails => 'アプリケーション使用詳細';

  @override
  String get totalApps => 'アプリ合計：';

  @override
  String get productiveApps => '生産的アプリ：';

  @override
  String get rank => '順位';

  @override
  String get application => 'アプリケーション';

  @override
  String get time => '時間';

  @override
  String get percentOfTotal => '合計の%';

  @override
  String get type => 'タイプ';

  @override
  String get usageLevel => '使用レベル';

  @override
  String get leisure => '娯楽';

  @override
  String get usageLevelVeryHigh => '非常に高い ||||||||';

  @override
  String get usageLevelHigh => '高い ||||||';

  @override
  String get usageLevelMedium => '中程度 ||||';

  @override
  String get usageLevelLow => '低い ||';

  @override
  String get keyInsightsTitle => '主要なインサイトと推奨事項';

  @override
  String get personalizedRecommendations => 'パーソナライズされた推奨事項';

  @override
  String insightHighDailyUsage(String hours) {
    return '高い日次使用量：1日平均$hours時間のスクリーン時間を使用しています';
  }

  @override
  String insightLowDailyUsage(String hours) {
    return '低い日次使用量：1日平均$hours時間 - 素晴らしいバランスです！';
  }

  @override
  String insightModerateUsage(String hours) {
    return '適度な使用量：1日平均$hours時間のスクリーン時間';
  }

  @override
  String insightExcellentProductivity(String percentage) {
    return '優れた生産性：スクリーン時間の$percentage%が生産的な作業です！';
  }

  @override
  String insightGoodProductivity(String percentage) {
    return '良好な生産性：スクリーン時間の$percentage%が生産的です';
  }

  @override
  String insightLowProductivity(String percentage) {
    return '低生産性アラート：スクリーン時間のわずか$percentage%が生産的です';
  }

  @override
  String insightFocusSessions(int count, String avgPerDay) {
    return '集中セッション：$countセッション完了（1日平均$avgPerDay）';
  }

  @override
  String insightGreatFocusHabit(int count) {
    return '素晴らしい集中習慣：$count回の完了セッションで素晴らしい集中ルーティンを構築しました！';
  }

  @override
  String get insightNoFocusSessions =>
      '集中セッションなし：生産性を向上させるために集中モードの使用を検討してください';

  @override
  String insightScreenTimeTrend(String direction, String percentage) {
    return 'スクリーン時間の傾向：前期間と比較して使用量が$percentage%$direction';
  }

  @override
  String insightProductiveTimeTrend(String direction, String percentage) {
    return '生産的時間の傾向：前期間と比較して生産的時間が$percentage%$direction';
  }

  @override
  String get directionIncreased => '増加しました';

  @override
  String get directionDecreased => '減少しました';

  @override
  String insightTopCategory(String category, String percentage) {
    return 'トップカテゴリ：$categoryが合計時間の$percentage%を占めています';
  }

  @override
  String insightMostUsedApp(
      String appName, String percentage, String duration) {
    return '最も使用されたアプリ：$appNameが時間の$percentage%（$duration）を占めています';
  }

  @override
  String insightUsageVaries(String highDay, String multiplier, String lowDay) {
    return '使用量に大きな差：$highDayは$lowDayより$multiplier倍多い使用量でした';
  }

  @override
  String get insightNoInsights => '重要なインサイトはありません';

  @override
  String get recScheduleFocusSessions =>
      '生産性を向上させるために、1日を通してより多くの集中セッションをスケジュールしてみてください';

  @override
  String get recSetAppLimits => '娯楽アプリに制限を設定することを検討してください';

  @override
  String get recAimForFocusSessions =>
      '一貫した習慣を構築するために、1日あたり少なくとも1〜2回の集中セッションを目指してください';

  @override
  String get recTakeBreaks =>
      '1日のスクリーン時間がかなり長いです。20-20-20ルールを使用して定期的に休憩を取ってみてください';

  @override
  String get recSetDailyGoals => '使用量を徐々に減らすために、1日のスクリーン時間目標を設定することを検討してください';

  @override
  String get recBalanceEntertainment =>
      '娯楽アプリが時間の大部分を占めています。より生産的な活動とのバランスを検討してください';

  @override
  String get recReviewUsagePatterns =>
      'スクリーン時間が大幅に増加しました。使用パターンを確認し、境界を設定してください';

  @override
  String get recScheduleFocusedWork =>
      '生産的時間が減少しました。カレンダーに集中作業ブロックをスケジュールしてみてください';

  @override
  String get recKeepUpGreatWork => 'その調子です！スクリーン時間の習慣は健康的に見えます';

  @override
  String get recContinueFocusSessions => '生産性を維持するために集中セッションを引き続き使用してください';

  @override
  String get sheetSummary => 'サマリー';

  @override
  String get sheetDailyBreakdown => '日別内訳';

  @override
  String get sheetApps => 'アプリ';

  @override
  String get sheetInsights => 'インサイト';

  @override
  String get statusHeader => 'ステータス';

  @override
  String workSessions(int count) {
    return '$count回の作業セッション';
  }

  @override
  String get complete => '完了';

  @override
  String get inProgress => '進行中';

  @override
  String get workTime => '作業時間';

  @override
  String get breakTime => '休憩時間';

  @override
  String get phasesCompleted => '完了したフェーズ';

  @override
  String hourMinuteFormat(String hours, String minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String hourOnlyFormat(String hours) {
    return '$hours時間';
  }

  @override
  String minuteFormat(String minutes) {
    return '$minutes分';
  }

  @override
  String sessionsCount(int count) {
    return '$countセッション';
  }

  @override
  String get workPhases => '作業フェーズ';

  @override
  String get averageLength => '平均時間';

  @override
  String get mostProductive => '最も生産的';

  @override
  String get work => '作業';

  @override
  String get breaks => '休憩';

  @override
  String get none => 'なし';

  @override
  String minuteShortFormat(String minutes) {
    return '$minutes分';
  }

  @override
  String get importTheme => 'テーマをインポート';

  @override
  String get exportTheme => 'テーマをエクスポート';

  @override
  String get import => 'インポート';

  @override
  String get export => 'エクスポート';

  @override
  String get chooseExportMethod => 'テーマのエクスポート方法を選択してください：';

  @override
  String get saveAsFile => 'ファイルとして保存';

  @override
  String get saveThemeAsJSONFile => 'テーマをJSONファイルとしてデバイスに保存';

  @override
  String get copyToClipboard => 'クリップボードにコピー';

  @override
  String get copyThemeJSONToClipboard => 'テーマデータをクリップボードにコピー';

  @override
  String get share => '共有';

  @override
  String get shareThemeViaSystemSheet => 'システム共有シートを使用してテーマを共有';

  @override
  String get chooseImportMethod => 'テーマのインポート方法を選択してください：';

  @override
  String get loadFromFile => 'ファイルから読み込む';

  @override
  String get selectJSONFileFromDevice => 'デバイスからJSONテーマファイルを選択';

  @override
  String get pasteFromClipboard => 'クリップボードから貼り付け';

  @override
  String get importFromClipboardJSON => 'クリップボードのJSONデータからテーマをインポート';

  @override
  String get importFromFile => 'ファイルからテーマをインポート';

  @override
  String get themeCreatedSuccessfully => 'テーマが正常に作成されました！';

  @override
  String get themeUpdatedSuccessfully => 'テーマが正常に更新されました！';

  @override
  String get themeDeletedSuccessfully => 'テーマが正常に削除されました！';

  @override
  String get themeExportedSuccessfully => 'テーマが正常にエクスポートされました！';

  @override
  String get themeCopiedToClipboard => 'テーマがクリップボードにコピーされました！';

  @override
  String themeImportedSuccessfully(String themeName) {
    return 'テーマ「$themeName」が正常にインポートされました！';
  }

  @override
  String get noThemeDataFound => 'テーマデータが見つかりません';

  @override
  String get invalidThemeFormat => 'テーマ形式が無効です。JSONデータを確認してください。';

  @override
  String get trackingModeTitle => 'トラッキングモード';

  @override
  String get trackingModeDescription => 'アプリ使用状況の追跡方法を選択';

  @override
  String get trackingModePolling => '標準（低リソース）';

  @override
  String get trackingModePrecise => '精密（高精度）';

  @override
  String get trackingModePollingHint => '毎分チェック - リソース使用量が少ない';

  @override
  String get trackingModePreciseHint => 'リアルタイム追跡 - 高精度、リソース消費が多い';

  @override
  String get trackingModeChangeError => 'トラッキングモードの変更に失敗しました。もう一度お試しください。';

  @override
  String get errorTitle => 'エラー';

  @override
  String get monitorKeyboardTitle => 'キーボードを監視';

  @override
  String get monitorKeyboardDescription => 'ユーザーの存在を検出するためにキーボードアクティビティを追跡します';

  @override
  String get changelogWhatsNew => '新機能';

  @override
  String changelogReleasedOn(String date) {
    return '$dateにリリース';
  }

  @override
  String get changelogNoContent => 'このバージョンの変更履歴はありません。';

  @override
  String get changelogUnableToLoad => '変更履歴を読み込めません';

  @override
  String get changelogErrorDescription =>
      'このバージョンの変更履歴を取得できませんでした。インターネット接続を確認するか、GitHubのリリースページをご覧ください。';

  @override
  String get allTracking => 'すべてのアプリ';

  @override
  String get notTracking => '未追跡';

  @override
  String get allVisibility => 'すべて';

  @override
  String get visible => '表示';

  @override
  String get hidden => '非表示';

  @override
  String get todaysLimitUsage => '今日の制限使用状況';

  @override
  String get thisWeekAtAGlance => '今週の概要';

  @override
  String get hourlyActivityHeatmap => '時間別アクティビティヒートマップ';

  @override
  String get productivityScore => '生産性スコア';

  @override
  String get streaks => '連続記録';

  @override
  String get weekOverWeek => '前週比';

  @override
  String get sameAsLastWeek => '先週と同じ';

  @override
  String moreUsageThanLastWeek(String percent) {
    return '先週より$percent%多い';
  }

  @override
  String lessUsageThanLastWeek(String percent) {
    return '先週より$percent%少ない';
  }

  @override
  String limitExceededBy(String duration) {
    return '制限を$duration超過';
  }

  @override
  String timeRemaining(String duration) {
    return '残り$duration';
  }

  @override
  String get totalSessions => '合計セッション数';

  @override
  String get avgSession => '平均セッション';

  @override
  String get mostActive => '最もアクティブ';

  @override
  String get peakUsage => 'ピーク使用量';

  @override
  String get dailyAverage => '日次平均';

  @override
  String get daysUsedInARow => '連続使用日数';

  @override
  String get daysSingular => '日';

  @override
  String get daysPlural => '日';

  @override
  String get daysOverLimitInARow => '連続制限超過日数';

  @override
  String get withinLimitAllWeek => '今週はすべて制限内';

  @override
  String get productivityScoreGreat => '素晴らしい';

  @override
  String get productivityScoreModerate => '普通';

  @override
  String get productivityScoreNeedsAttention => '注意が必要';

  @override
  String get productiveAppMotivation => '生産的なアプリ — この調子で';

  @override
  String get nonProductiveAppSuggestion => '非生産的 — 使用を減らすことを検討';

  @override
  String get legendUsage => '使用量';

  @override
  String get legendAverage => '平均';

  @override
  String get legendLimit => '制限';

  @override
  String get chartPeak => 'ピーク';

  @override
  String overLimitBy(String duration) {
    return '+$duration 制限超過';
  }

  @override
  String get noData => 'データなし';

  @override
  String get yesterday => '昨日';

  @override
  String get changelog => '変更履歴';

  @override
  String get exportingLabel => 'エクスポート中...';

  @override
  String get exportExcelLabel => 'Excelをエクスポート';
}
