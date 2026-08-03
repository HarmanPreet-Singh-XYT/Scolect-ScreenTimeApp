// ─── Web Browser Data Provider ───────────────────────────────────────────────
//
// Implements the same public API as the desktop BrowserDataProvider but reads
// from chrome.storage.local instead of Hive/SQLite.
//
// Data is written by web/background.js service worker:
//   Key: 'scolect_day_YYYY-MM-DD'
//   Value: { date, domains: [{domain, seconds, visits, lastSeen}] }
//
// Per-domain metadata (category, tracking, limits) is stored in ExtensionSettings.


import '../sections/controller/data_controllers/browser_data_controller.dart';
import '../sections/controller/categories_controller.dart';
import '../sections/controller/settings_data_controller.dart';
import 'chrome_storage_interop.dart';
import 'extension_settings.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _todayKey() {
  final now = SettingsManager().getLogicalDate(DateTime.now());
  final y = now.year;
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _storageKey(String dateKey) => 'scolect_day_$dateKey';

// ─── Web Data Provider ────────────────────────────────────────────────────────

class WebBrowserDataProvider {
  static final WebBrowserDataProvider _instance = WebBrowserDataProvider._();
  factory WebBrowserDataProvider() => _instance;
  WebBrowserDataProvider._();

  final ExtensionSettings _settings = ExtensionSettings();

  // ── Fetch today's domain list from chrome.storage ─────────────────────────

  Future<List<_RawDomain>> _fetchTodayDomains() async {
    final key = _storageKey(_todayKey());
    final data = await chromeStorageGet([key]);
    final day = data[key] as Map<String, dynamic>?;
    if (day == null) return [];

    final rawDomains = day['domains'] as List<dynamic>? ?? [];
    return rawDomains
        .whereType<Map<String, dynamic>>()
        .map((d) => _RawDomain(
              domain: d['domain'] as String? ?? '',
              seconds: (d['seconds'] as num?)?.toInt() ?? 0,
              visits: (d['visits'] as num?)?.toInt() ?? 0,
              lastSeen: (d['lastSeen'] as num?)?.toInt() ?? 0,
              siteName: d['siteName'] as String? ?? '',
            ))
        .where((d) => d.domain.isNotEmpty)
        .toList();
  }

  // ── fetchAllWebsites ──────────────────────────────────────────────────────

  /// Reads site names captured by background.js from scolect_app_metadata.
  Future<Map<String, String>> _fetchSiteNames() async {
    final result = await chromeStorageGet(['scolect_app_metadata']);
    final raw = result['scolect_app_metadata'] as Map<String, dynamic>? ?? {};
    return {
      for (final e in raw.entries)
        e.key: (e.value as Map<String, dynamic>?)?['siteName'] as String? ?? '',
    };
  }

  Future<List<WebsiteBasicDetail>> fetchAllWebsites() async {
    // Active sync: trigger immediate background flush & desktop push when viewing analytics
    await triggerExtensionSync();
    final domains = await _fetchTodayDomains();
    final metaMap = await _settings.getAllMetadata();
    final siteNames = await _fetchSiteNames();

    final sites = <WebsiteBasicDetail>[];
    for (final d in domains) {
      final meta = metaMap[d.domain] ?? const WebsiteMetadata();
      // Priority: user-set name (scolect_settings) > day-record name (background-cleaned title) > app_metadata fallback
      final siteName = meta.siteName.isNotEmpty
          ? meta.siteName
          : d.siteName.isNotEmpty
              ? d.siteName
              : (siteNames[d.domain] ?? '');
      final rawCat = meta.category;
      final displayName = siteName.isNotEmpty ? siteName : d.domain;
      final category = (rawCat.isNotEmpty && rawCat != 'Uncategorized')
          ? rawCat
          : AppCategories.categorizeApp(displayName);

      sites.add(WebsiteBasicDetail(
        domain: d.domain,
        siteName: siteName,
        category: category,
        timeSpent: Duration(seconds: d.seconds),
        isTracking: meta.isTracking,
        isHidden: false,
        isProductive: meta.isProductive,
        dailyLimit: meta.dailyLimit,
        limitStatus: meta.dailyLimitSeconds > 0,
        visits: d.visits,
      ));
    }

    // Add metadata-only entries (domains with metadata but no usage today)
    final seenDomains = sites.map((s) => s.domain).toSet();
    for (final entry in metaMap.entries) {
      if (!seenDomains.contains(entry.key)) {
        final displayName = entry.value.siteName.isNotEmpty ? entry.value.siteName : entry.key;
        final rawCat = entry.value.category;
        final category = (rawCat.isNotEmpty && rawCat != 'Uncategorized')
            ? rawCat
            : AppCategories.categorizeApp(displayName);
        sites.add(WebsiteBasicDetail(
          domain: entry.key,
          siteName: entry.value.siteName,
          category: category,
          timeSpent: Duration.zero,
          isTracking: entry.value.isTracking,
          isHidden: false,
          isProductive: entry.value.isProductive,
          dailyLimit: entry.value.dailyLimit,
          limitStatus: false,
          visits: 0,
        ));
      }
    }

    sites.sort((a, b) => b.timeSpent.compareTo(a.timeSpent));

    return sites;
  }

  /// background.js is the single writer of scolect_blocked_domains.
  /// This read-only helper lets the UI display the current blocked list
  /// (e.g. lock icons) without the Flutter app needing to recompute it.
  Future<List<String>> fetchBlockedDomains() async {
    final result = await chromeStorageGet(['scolect_blocked_domains']);
    return List<String>.from(
        (result['scolect_blocked_domains'] as List<dynamic>?) ?? []);
  }

  // ── fetchTodaySummary ─────────────────────────────────────────────────────

  Future<({Duration totalTime, int siteCount, int visitCount})> fetchTodaySummary() async {
    await triggerExtensionSync();
    final domains = await _fetchTodayDomains();
    Duration total = Duration.zero;
    int visits = 0;
    int sites = 0;
    for (final d in domains) {
      if (d.seconds > 0) {
        total += Duration(seconds: d.seconds);
        visits += d.visits;
        sites++;
      }
    }
    return (totalTime: total, siteCount: sites, visitCount: visits);
  }

  // ── fetchCategoryBreakdown ────────────────────────────────────────────────

  Future<List<WebsiteCategorySummary>> fetchCategoryBreakdown() async {
    final domains = await _fetchTodayDomains();
    final metaMap = await _settings.getAllMetadata();

    final Map<String, Duration> categoryTime = {};
    final Map<String, int> categorySiteCount = {};
    Duration grandTotal = Duration.zero;

    for (final d in domains) {
      if (d.seconds == 0) continue;
      final meta = metaMap[d.domain] ?? const WebsiteMetadata();
      final cat = meta.category;
      final dur = Duration(seconds: d.seconds);
      categoryTime[cat] = (categoryTime[cat] ?? Duration.zero) + dur;
      categorySiteCount[cat] = (categorySiteCount[cat] ?? 0) + 1;
      grandTotal += dur;
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

  // ── fetchAllCategories ────────────────────────────────────────────────────

  Future<List<String>> fetchAllCategories() async {
    final metaMap = await _settings.getAllMetadata();
    final cats = metaMap.values.map((m) => m.category).toSet();
    // Also check today's domains (they may lack metadata)
    final domains = await _fetchTodayDomains();
    for (final d in domains) {
      if (!metaMap.containsKey(d.domain)) cats.add('Uncategorized');
    }
    return ['All', ...cats.toList()..sort()];
  }

  // ── updateWebsiteMetadata ─────────────────────────────────────────────────

  Future<bool> updateWebsiteMetadata(
    String domain, {
    String? category,
    bool? isProductive,
    bool? isTracking,
    bool? isVisible,
    Duration? dailyLimit,
    String? siteName,
  }) async {
    try {
      await _settings.updateMetadata(
        domain,
        category: category,
        isTracking: isTracking,
        isProductive: isProductive,
        dailyLimit: dailyLimit,
        siteName: siteName,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Per-site history (last N days) ───────────────────────────────────────

  Future<List<({String date, Duration timeSpent, int visits})>> fetchSiteHistory(
      String domain, {int days = 7}) async {
    final result = <({String date, Duration timeSpent, int visits})>[];
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final y = date.year;
      final m = date.month.toString().padLeft(2, '0');
      final d = date.day.toString().padLeft(2, '0');
      final dateKey = '$y-$m-$d';
      final storageKey = _storageKey(dateKey);

      final data = await chromeStorageGet([storageKey]);
      final day = data[storageKey] as Map<String, dynamic>?;
      if (day == null) {
        result.add((date: dateKey, timeSpent: Duration.zero, visits: 0));
        continue;
      }
      final domains = (day['domains'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final entry = domains.firstWhere(
        (d) => d['domain'] == domain,
        orElse: () => <String, dynamic>{},
      );
      result.add((
        date: dateKey,
        timeSpent: Duration(seconds: (entry['seconds'] as num?)?.toInt() ?? 0),
        visits: (entry['visits'] as num?)?.toInt() ?? 0,
      ));
    }
    return result;
  }

  // ── Historical data (last N days) ─────────────────────────────────────────

  Future<List<({String date, Duration totalTime, int siteCount})>> fetchHistory({int days = 7}) async {
    final result = <({String date, Duration totalTime, int siteCount})>[];
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final y = date.year;
      final m = date.month.toString().padLeft(2, '0');
      final d = date.day.toString().padLeft(2, '0');
      final dateKey = '$y-$m-$d';
      final storageKey = _storageKey(dateKey);

      final data = await chromeStorageGet([storageKey]);
      final day = data[storageKey] as Map<String, dynamic>?;
      if (day == null) {
        result.add((date: dateKey, totalTime: Duration.zero, siteCount: 0));
        continue;
      }
      final domains = (day['domains'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final total = domains.fold<int>(
        0, (s, d) => s + ((d['seconds'] as num?)?.toInt() ?? 0));
      result.add((
        date: dateKey,
        totalTime: Duration(seconds: total),
        siteCount: domains.where((d) => (d['seconds'] as num? ?? 0) > 0).length,
      ));
    }
    return result;
  }
}

// ─── Internal raw domain model ────────────────────────────────────────────────

class _RawDomain {
  final String domain;
  final int seconds;
  final int visits;
  final int lastSeen;
  final String siteName;

  const _RawDomain({
    required this.domain,
    required this.seconds,
    required this.visits,
    required this.lastSeen,
    this.siteName = '',
  });
}
