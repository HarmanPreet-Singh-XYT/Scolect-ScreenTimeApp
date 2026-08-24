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
import '../utils/private_mode_access.dart';
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
    // Normalize domains (strip www., lowercase) and merge any duplicates that
    // may have been written before the write-time normalization was added.
    final merged = <String, _RawDomain>{};
    for (final raw in rawDomains.whereType<Map<String, dynamic>>()) {
      final rawDomain = (raw['domain'] as String? ?? '').trim();
      if (rawDomain.isEmpty) continue;
      final domain = rawDomain.replaceFirst(RegExp(r'^www\.', caseSensitive: false), '').toLowerCase();
      final seconds = (raw['seconds'] as num?)?.toInt() ?? 0;
      final visits  = (raw['visits']  as num?)?.toInt() ?? 0;
      final lastSeen = (raw['lastSeen'] as num?)?.toInt() ?? 0;
      final siteName = raw['siteName'] as String? ?? '';
      if (merged.containsKey(domain)) {
        final existing = merged[domain]!;
        merged[domain] = _RawDomain(
          domain: domain,
          seconds: existing.seconds + seconds,
          visits: existing.visits + visits,
          lastSeen: existing.lastSeen > lastSeen ? existing.lastSeen : lastSeen,
          siteName: existing.siteName.isNotEmpty ? existing.siteName : siteName,
        );
      } else {
        merged[domain] = _RawDomain(
          domain: domain,
          seconds: seconds,
          visits: visits,
          lastSeen: lastSeen,
          siteName: siteName,
        );
      }
    }
    return merged.values.toList();
  }

  // ── All-time known domains ────────────────────────────────────────────────

  /// Every domain that has ever appeared in any 'scolect_day_*' record, not
  /// just today's. A domain visited on a past day that never had metadata
  /// written for it (no limit/category ever set) would otherwise be
  /// invisible to fetchAllWebsites() — it has no entry in today's usage and
  /// no entry in ExtensionSettings metadata, so it silently never shows up
  /// in the Limits tab even though the user genuinely tracked time on it.
  Future<Set<String>> _fetchAllKnownDomains() async {
    final all = await chromeStorageGetAll();
    final domains = <String>{};
    for (final entry in all.entries) {
      if (!entry.key.startsWith('scolect_day_')) continue;
      final day = entry.value;
      if (day is! Map) continue;
      final rawDomains = day['domains'];
      if (rawDomains is! List) continue;
      for (final raw in rawDomains.whereType<Map<String, dynamic>>()) {
        final domain = (raw['domain'] as String? ?? '').trim();
        if (domain.isNotEmpty) domains.add(domain);
      }
    }
    return domains;
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

  /// [includeHistorical] additionally unions in every domain ever seen in
  /// past 'scolect_day_*' records, not just today + anything with metadata.
  /// This requires a full chrome.storage.local scan, so it's opt-in — only
  /// the Limits tab needs "every site I could set a limit on", the
  /// Websites/Categories/Overview tabs are about today's activity and
  /// shouldn't pay for the extra scan on every load.
  Future<List<WebsiteBasicDetail>> fetchAllWebsites({
    bool includeHistorical = false,
  }) async {
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
        isPrivate: meta.isPrivate,
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
          isPrivate: entry.value.isPrivate,
        ));
        seenDomains.add(entry.key);
      }
    }

    if (includeHistorical) {
      // Add domains tracked on past days that never got a metadata entry
      // (e.g. briefly visited once, no limit/category ever set) so they
      // still show up to have a limit applied — otherwise they're invisible.
      final allKnownDomains = await _fetchAllKnownDomains();
      for (final domain in allKnownDomains) {
        if (seenDomains.contains(domain)) continue;
        sites.add(WebsiteBasicDetail(
          domain: domain,
          siteName: '',
          category: AppCategories.categorizeApp(domain),
          timeSpent: Duration.zero,
          isTracking: true,
          isHidden: false,
          isProductive: false,
          dailyLimit: Duration.zero,
          limitStatus: false,
          visits: 0,
          isPrivate: false,
        ));
        seenDomains.add(domain);
      }
    }

    final showPrivate = shouldShowPrivateOnly();
    sites.removeWhere((s) => s.isPrivate != showPrivate);

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
    bool? isPrivate,
  }) async {
    try {
      await _settings.updateMetadata(
        domain,
        category: category,
        isTracking: isTracking,
        isProductive: isProductive,
        dailyLimit: dailyLimit,
        siteName: siteName,
        isPrivate: isPrivate,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Per-site history (last N days) ───────────────────────────────────────

  Future<List<({String date, Duration timeSpent, int visits})>> fetchSiteHistory(
      String domain, {int days = 7}) async {
    final cleanTargetDomain = domain
        .replaceFirst(RegExp(r'^www\.', caseSensitive: false), '')
        .toLowerCase()
        .trim();
    final now = DateTime.now();

    final dateEntries = <({DateTime date, String dateKey, String storageKey})>[];
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final y = date.year;
      final m = date.month.toString().padLeft(2, '0');
      final d = date.day.toString().padLeft(2, '0');
      final dateKey = '$y-$m-$d';
      final storageKey = _storageKey(dateKey);
      dateEntries.add((date: date, dateKey: dateKey, storageKey: storageKey));
    }

    final allData = await chromeStorageGet(dateEntries.map((e) => e.storageKey).toList());
    final result = <({String date, Duration timeSpent, int visits})>[];

    for (final entry in dateEntries) {
      final day = allData[entry.storageKey];
      if (day == null) {
        result.add((date: entry.dateKey, timeSpent: Duration.zero, visits: 0));
        continue;
      }

      int seconds = 0;
      int visits = 0;

      if (day is Map<String, dynamic>) {
        final domains = day['domains'];
        if (domains is List) {
          for (final raw in domains.whereType<Map<String, dynamic>>()) {
            final rawDomain = (raw['domain'] as String? ?? '')
                .replaceFirst(RegExp(r'^www\.', caseSensitive: false), '')
                .toLowerCase()
                .trim();
            if (rawDomain == cleanTargetDomain) {
              seconds += (raw['seconds'] as num?)?.toInt() ?? 0;
              visits += (raw['visits'] as num?)?.toInt() ?? 0;
            }
          }
        } else if (day.containsKey(cleanTargetDomain)) {
          final raw = day[cleanTargetDomain];
          if (raw is Map<String, dynamic>) {
            seconds = (raw['seconds'] as num?)?.toInt() ?? 0;
            visits = (raw['visits'] as num?)?.toInt() ?? 0;
          } else if (raw is num) {
            seconds = raw.toInt();
          }
        }
      } else if (day is List) {
        for (final raw in day.whereType<Map<String, dynamic>>()) {
          final rawDomain = (raw['domain'] as String? ?? '')
              .replaceFirst(RegExp(r'^www\.', caseSensitive: false), '')
              .toLowerCase()
              .trim();
          if (rawDomain == cleanTargetDomain) {
            seconds += (raw['seconds'] as num?)?.toInt() ?? 0;
            visits += (raw['visits'] as num?)?.toInt() ?? 0;
          }
        }
      }

      result.add((
        date: entry.dateKey,
        timeSpent: Duration(seconds: seconds),
        visits: visits,
      ));
    }
    return result;
  }

  // ── Historical data (last N days) ─────────────────────────────────────────

  Future<List<({String date, Duration totalTime, int siteCount})>> fetchHistory({int days = 7}) async {
    final now = DateTime.now();
    final dateEntries = <({DateTime date, String dateKey, String storageKey})>[];
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final y = date.year;
      final m = date.month.toString().padLeft(2, '0');
      final d = date.day.toString().padLeft(2, '0');
      final dateKey = '$y-$m-$d';
      final storageKey = _storageKey(dateKey);
      dateEntries.add((date: date, dateKey: dateKey, storageKey: storageKey));
    }

    final allData = await chromeStorageGet(dateEntries.map((e) => e.storageKey).toList());
    final result = <({String date, Duration totalTime, int siteCount})>[];

    for (final entry in dateEntries) {
      final day = allData[entry.storageKey];
      if (day == null) {
        result.add((date: entry.dateKey, totalTime: Duration.zero, siteCount: 0));
        continue;
      }
      final domains = (day is Map<String, dynamic> ? (day['domains'] as List<dynamic>? ?? []) : [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final total = domains.fold<int>(
        0, (s, d) => s + ((d['seconds'] as num?)?.toInt() ?? 0));
      result.add((
        date: entry.dateKey,
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
