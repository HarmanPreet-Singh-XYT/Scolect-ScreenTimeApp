import 'package:flutter/foundation.dart' show kIsWeb;
import '../app_data_controller.dart';
import '../settings_data_controller.dart';
import 'applications_data_controller.dart';
import '../../../web/web_browser_data_provider.dart'
    if (dart.library.io) '../../../web/web_browser_data_provider_stub.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const _kWebPrefix = 'web:';

// ─── Data Models ─────────────────────────────────────────────────────────────

class WebsiteBasicDetail {
  final String domain;
  final String category;
  final Duration timeSpent;
  final String formattedTimeSpent;
  final bool isTracking;
  final bool isHidden;
  final bool isProductive;
  final Duration dailyLimit;
  final bool limitStatus;
  final int visits;

  WebsiteBasicDetail({
    required this.domain,
    required this.category,
    required this.timeSpent,
    required this.isTracking,
    required this.isHidden,
    required this.isProductive,
    required this.dailyLimit,
    required this.limitStatus,
    required this.visits,
  }) : formattedTimeSpent = timeSpent.toHourMinuteFormat();

  bool matchesSearch(String query) =>
      query.isEmpty || domain.toLowerCase().contains(query.toLowerCase());

  bool matchesCategory(String category) =>
      category == 'All' || this.category == category;

  bool matchesTracking(String filter) => switch (filter) {
        'tracked' => isTracking,
        'untracked' => !isTracking,
        _ => true,
      };

  bool matchesProductivity(String filter) => switch (filter) {
        'productive' => isProductive,
        'unproductive' => !isProductive,
        _ => true,
      };
}

class WebsiteCategorySummary {
  final String category;
  final Duration totalTime;
  final String formattedTime;
  final int siteCount;
  final double percentage;

  WebsiteCategorySummary({
    required this.category,
    required this.totalTime,
    required this.siteCount,
    required this.percentage,
  }) : formattedTime = totalTime.toHourMinuteFormat();
}

// ─── Data Provider ────────────────────────────────────────────────────────────

class BrowserDataProvider {
  // On web, delegate everything to WebBrowserDataProvider which reads
  // from chrome.storage.local instead of the desktop Hive/SQLite store.
  static final BrowserDataProvider _instance = BrowserDataProvider._internal();
  static final _webInstance = WebBrowserDataProvider();

  factory BrowserDataProvider() {
    if (kIsWeb) return _WebDelegatingProvider(_webInstance) as BrowserDataProvider;
    return _instance;
  }

  BrowserDataProvider._internal();

  final AppDataStore _dataStore = AppDataStore();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      _initialized = await _dataStore.init();
    }
  }

  /// Returns all app names that are website entries (prefixed with "web:")
  List<String> get _webAppNames =>
      _dataStore.allAppNames.where((n) => n.startsWith(_kWebPrefix)).toList();

  /// Strip the "web:" prefix to get the display domain
  String _toDomain(String appName) => appName.replaceFirst(_kWebPrefix, '');

  // ─── Fetch all websites for today ────────────────────────────────────────

  Future<List<WebsiteBasicDetail>> fetchAllWebsites() async {
    await _ensureInitialized();

    final DateTime today = SettingsManager().getLogicalDate(DateTime.now());
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);
    final sites = <WebsiteBasicDetail>[];

    for (final appName in _webAppNames) {
      final metadata = _dataStore.getAppMetadata(appName);
      if (metadata == null) continue;

      final record = _dataStore.getAppUsage(appName, startOfDay);

      sites.add(WebsiteBasicDetail(
        domain: _toDomain(appName),
        category: metadata.category,
        timeSpent: record?.timeSpent ?? Duration.zero,
        isTracking: metadata.isTracking,
        isHidden: !metadata.isVisible,
        isProductive: metadata.isProductive,
        dailyLimit: metadata.dailyLimit,
        limitStatus: metadata.limitStatus,
        visits: record?.openCount ?? 0,
      ));
    }

    sites.sort((a, b) => b.timeSpent.compareTo(a.timeSpent));
    return sites;
  }

  // ─── Today summary stats ─────────────────────────────────────────────────

  Future<({Duration totalTime, int siteCount, int visitCount})>
      fetchTodaySummary() async {
    await _ensureInitialized();

    final DateTime today = SettingsManager().getLogicalDate(DateTime.now());
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);

    Duration total = Duration.zero;
    int visits = 0;
    int sites = 0;

    for (final appName in _webAppNames) {
      final record = _dataStore.getAppUsage(appName, startOfDay);
      if (record != null && record.timeSpent > Duration.zero) {
        total += record.timeSpent;
        visits += record.openCount;
        sites++;
      }
    }

    return (totalTime: total, siteCount: sites, visitCount: visits);
  }

  // ─── Category breakdown ───────────────────────────────────────────────────

  Future<List<WebsiteCategorySummary>> fetchCategoryBreakdown() async {
    await _ensureInitialized();

    final DateTime today = SettingsManager().getLogicalDate(DateTime.now());
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);

    final Map<String, Duration> categoryTime = {};
    final Map<String, int> categorySiteCount = {};
    Duration grandTotal = Duration.zero;

    for (final appName in _webAppNames) {
      final metadata = _dataStore.getAppMetadata(appName);
      if (metadata == null) continue;

      final record = _dataStore.getAppUsage(appName, startOfDay);
      final time = record?.timeSpent ?? Duration.zero;
      if (time == Duration.zero) continue;

      final cat = metadata.category;
      categoryTime[cat] = (categoryTime[cat] ?? Duration.zero) + time;
      categorySiteCount[cat] = (categorySiteCount[cat] ?? 0) + 1;
      grandTotal += time;
    }

    return categoryTime.entries.map((e) {
      final pct = grandTotal.inSeconds > 0
          ? e.value.inSeconds / grandTotal.inSeconds * 100
          : 0.0;
      return WebsiteCategorySummary(
        category: e.key,
        totalTime: e.value,
        siteCount: categorySiteCount[e.key] ?? 0,
        percentage: pct,
      );
    }).toList()
      ..sort((a, b) => b.totalTime.compareTo(a.totalTime));
  }

  // ─── All known categories across all web entries ──────────────────────────

  Future<List<String>> fetchAllCategories() async {
    await _ensureInitialized();

    final Set<String> cats = {};
    for (final appName in _webAppNames) {
      final metadata = _dataStore.getAppMetadata(appName);
      if (metadata != null) cats.add(metadata.category);
    }
    return ['All', ...cats.toList()..sort()];
  }

  // ─── Update website metadata ──────────────────────────────────────────────

  Future<bool> updateWebsiteMetadata(
    String domain, {
    String? category,
    bool? isProductive,
    bool? isTracking,
    bool? isVisible,
    Duration? dailyLimit,
  }) async {
    await _ensureInitialized();
    return _dataStore.updateAppMetadata(
      '$_kWebPrefix$domain',
      category: category,
      isProductive: isProductive,
      isTracking: isTracking,
      isVisible: isVisible,
      dailyLimit: dailyLimit,
    );
  }
}

// ─── Web delegating wrapper ───────────────────────────────────────────────────
//
// Wraps WebBrowserDataProvider in a BrowserDataProvider-shaped object so the
// factory can return it without changing any call site.

class _WebDelegatingProvider extends BrowserDataProvider {
  final WebBrowserDataProvider _web;
  _WebDelegatingProvider(this._web) : super._internal();

  @override
  Future<List<WebsiteBasicDetail>> fetchAllWebsites() => _web.fetchAllWebsites();

  @override
  Future<({Duration totalTime, int siteCount, int visitCount})> fetchTodaySummary() =>
      _web.fetchTodaySummary();

  @override
  Future<List<WebsiteCategorySummary>> fetchCategoryBreakdown() =>
      _web.fetchCategoryBreakdown();

  @override
  Future<List<String>> fetchAllCategories() => _web.fetchAllCategories();

  @override
  Future<bool> updateWebsiteMetadata(
    String domain, {
    String? category,
    bool? isProductive,
    bool? isTracking,
    bool? isVisible,
    Duration? dailyLimit,
  }) =>
      _web.updateWebsiteMetadata(
        domain,
        category: category,
        isProductive: isProductive,
        isTracking: isTracking,
        isVisible: isVisible,
        dailyLimit: dailyLimit,
      );
}
