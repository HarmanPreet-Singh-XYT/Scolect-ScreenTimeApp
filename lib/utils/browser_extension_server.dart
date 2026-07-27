import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../sections/controller/app_data_controller.dart';
import '../sections/controller/categories_controller.dart';
import '../sections/controller/focus_mode_controller.dart';

/// Lightweight HTTP server on port 46000 for the Scolect browser extension.
///
/// Routes:
///   GET  /ping   → health check + focus state summary
///   POST /usage  → ingest domain-level usage data from the extension
///   GET  /focus  → full focus state for the extension's blocker
class BrowserExtensionServer {
  static const int defaultPort = 46000;
  static const String _version = '1.0';

  static HttpServer? _server;
  static int _currentPort = defaultPort;
  static final AppDataStore _dataStore = AppDataStore();

  static int get currentPort => _currentPort;

  static Future<void> startServer({int port = defaultPort}) async {
    _currentPort = port;
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, _currentPort);
      debugPrint('✅ Extension server started on port $_currentPort');
      _server!.listen(_handleRequest, onError: (e) {
        debugPrint('⚠️ Extension server error: $e');
      });
    } catch (e) {
      debugPrint('⚠️ Extension server bind failed (port $_currentPort in use?): $e');
    }
  }

  static Future<void> restartWithPort(int port) async {
    await dispose();
    await startServer(port: port);
  }

  static Future<void> dispose() async {
    await _server?.close(force: true);
    _server = null;
    debugPrint('🛑 Extension server closed');
  }

  // ─── Request dispatcher ──────────────────────────────────────────────────

  static Future<void> _handleRequest(HttpRequest req) async {
    // ─── CORS origin check ─────────────────────────────────────────
    // Only allow requests from the Scolect Chrome Extension.
    // The server binds to 127.0.0.1 so it's local-only, but any webpage
    // open in the browser could fetch http://localhost:46000/focus and
    // read the user's blocked domain list. Restrict to chrome-extension://
    // origins to prevent that.
    final origin = req.headers.value('origin') ?? '';
    final isExtension = origin.startsWith('chrome-extension://');

    if (!isExtension && req.method != 'OPTIONS') {
      // Allow requests with no Origin header (e.g., curl, same-process tests)
      // only if they genuinely have no origin — browsers always set it for
      // cross-origin fetch. Blank origin = direct/non-browser caller = OK.
      if (origin.isNotEmpty) {
        req.response.statusCode = HttpStatus.forbidden;
        req.response.write(jsonEncode({'error': 'Forbidden: extension-only endpoint'}));
        await req.response.close();
        return;
      }
    }

    _setCors(req.response, origin);

    // Pre-flight
    if (req.method == 'OPTIONS') {
      req.response.statusCode = HttpStatus.noContent;
      await req.response.close();
      return;
    }

    try {
      switch ('${req.method} ${req.uri.path}') {
        case 'GET /ping':
          await _handlePing(req);
        case 'POST /usage':
        case 'POST /api/browser-sync':
          await _handleUsage(req);
        case 'GET /focus':
          await _handleFocus(req);
        default:
          await _sendJson(req.response, HttpStatus.notFound, {'error': 'Not found'});
      }
    } catch (e) {
      debugPrint('⚠️ Extension server handler error: $e');
      await _sendJson(req.response, HttpStatus.internalServerError, {'error': '$e'});
    }
  }

  // ─── GET /ping ───────────────────────────────────────────────────────────

  static Future<void> _handlePing(HttpRequest req) async {
    final timer = PomodoroTimerService.instance;
    await _sendJson(req.response, HttpStatus.ok, {
      'ok': true,
      'version': _version,
      'focusActive': timer.isRunning && timer.currentState != TimerState.idle,
    });
  }

  // ─── POST /usage ─────────────────────────────────────────────────────────

  static Future<void> _handleUsage(HttpRequest req) async {
    final body = await _readBody(req);
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      await _sendJson(req.response, HttpStatus.badRequest, {'error': 'Invalid JSON'});
      return;
    }

    final dateStr = json['date'] as String?;
    final domains = json['domains'] as List<dynamic>?;

    if (dateStr == null || domains == null) {
      await _sendJson(req.response, HttpStatus.badRequest, {'error': 'Missing date or domains'});
      return;
    }

    final date = DateTime.tryParse(dateStr);
    if (date == null) {
      await _sendJson(req.response, HttpStatus.badRequest, {'error': 'Invalid date'});
      return;
    }

    for (final raw in domains) {
      final entry = raw as Map<String, dynamic>;
      final domain = entry['domain'] as String?;
      final seconds = (entry['seconds'] as num?)?.toInt() ?? 0;
      final visits = (entry['visits'] as num?)?.toInt() ?? 0;
      final siteName = entry['siteName'] as String? ?? '';

      // Extension-pushed metadata fields (new in sync protocol v2)
      final extLimitSecs = (entry['dailyLimitSeconds'] as num?)?.toInt();
      final extIsTracking = entry['isTracking'] as bool?;
      final extIsProductive = entry['isProductive'] as bool?;
      final extCategory = entry['category'] as String?;

      if (domain == null || domain.isEmpty || seconds < 0) continue;

      final appName = 'web:$domain';
      final timeSpent = Duration(seconds: seconds);
      final now = DateTime.now();

      // ─── Max-wins usage merge ───────────────────────────────────────
      // The extension sends cumulative day totals; only overwrite if the
      // incoming value is strictly larger than what's already stored.
      // This prevents a stale push (e.g. after a SW restart mid-day) from
      // overwriting a more recent record.
      final existingUsage = _dataStore.getAppUsage(appName, date);
      final shouldUpdate = existingUsage == null ||
          timeSpent > existingUsage.timeSpent;

      if (shouldUpdate) {
        // Preserve existing usage periods if they're richer than the
        // synthetic single-block we'd generate from the cumulative total.
        final existingPeriods = existingUsage?.usagePeriods ?? [];
        final usagePeriods = existingPeriods.isNotEmpty
            ? existingPeriods // keep real timeline data already on desktop
            : (seconds > 0
                ? [TimeRange(startTime: now.subtract(timeSpent), endTime: now)]
                : <TimeRange>[]);
        await _dataStore.setAppUsage(appName, date, timeSpent, visits, usagePeriods);
      }

      // ─── Metadata sync (extension is authority) ──────────────────────
      // Ensure metadata exists for this domain (first-time setup)
      final existingMeta = _dataStore.getAppMetadata(appName);
      if (existingMeta == null) {
        final category = (extCategory != null && extCategory.isNotEmpty)
            ? extCategory
            : WebsiteCategories.categorizeWebsite(domain);
        await _dataStore.updateAppMetadata(
          appName,
          category: category,
          isProductive: extIsProductive ??
              (!WebsiteCategories.isDefaultCategory(category) &&
               category != 'Entertainment' &&
               category != 'Gaming' &&
               category != 'Social Media'),
          isTracking: extIsTracking ?? true,
          isVisible: true,
          siteName: siteName,
          dailyLimit: extLimitSecs != null && extLimitSecs > 0
              ? Duration(seconds: extLimitSecs)
              : null,
        );
      } else {
        // Retroactively categorize domains that were saved with a placeholder
        if (WebsiteCategories.isDefaultCategory(existingMeta.category)) {
          final category = (extCategory != null && extCategory.isNotEmpty)
              ? extCategory
              : WebsiteCategories.categorizeWebsite(domain);
          if (!WebsiteCategories.isDefaultCategory(category)) {
            await _dataStore.updateAppMetadata(appName, category: category);
          }
        }
        // Update siteName if we now have one and the stored one is still empty
        if (siteName.isNotEmpty && existingMeta.siteName.isEmpty) {
          await _dataStore.updateAppMetadata(appName, siteName: siteName);
        }
        // Sync limit from extension into Hive (extension wins).
        // Only update if the extension explicitly sent a non-zero limit AND
        // the desktop's stored limit differs — avoids pointless Hive writes.
        if (extLimitSecs != null && extLimitSecs > 0) {
          final extDuration = Duration(seconds: extLimitSecs);
          if (existingMeta.dailyLimit != extDuration) {
            await _dataStore.updateAppMetadata(appName, dailyLimit: extDuration);
          }
        }
        // Sync isTracking / isProductive if extension sent explicit values
        if (extIsTracking != null && extIsTracking != existingMeta.isTracking) {
          await _dataStore.updateAppMetadata(appName, isTracking: extIsTracking);
        }
        if (extIsProductive != null && extIsProductive != existingMeta.isProductive) {
          await _dataStore.updateAppMetadata(appName, isProductive: extIsProductive);
        }
      }
    }

    await _sendJson(req.response, HttpStatus.ok, {'ok': true});
  }

  // ─── GET /focus ──────────────────────────────────────────────────────────

  static Future<void> _handleFocus(HttpRequest req) async {
    final timer = PomodoroTimerService.instance;
    final isActive = timer.isRunning && timer.currentState != TimerState.idle;

    String? sessionLabel;
    int? endTimeEpochMs;

    if (isActive) {
      sessionLabel = switch (timer.currentState) {
        TimerState.work => 'Work Session',
        TimerState.shortBreak => 'Short Break',
        TimerState.longBreak => 'Long Break',
        TimerState.idle => null,
      };
      endTimeEpochMs =
          DateTime.now().millisecondsSinceEpoch + (timer.secondsRemaining * 1000);
    }

    // Collect blocked domains (limit exceeded)
    final now2 = DateTime.now();
    final startOfDay = DateTime(now2.year, now2.month, now2.day);
    final blockedDomains = <String>[];

    // Build domainLimits map — returned to the extension so it can merge
    // desktop-only limits into scolect_settings.metadata (fills gaps only;
    // extension values always win, which is handled on the extension side).
    final domainLimits = <String, Map<String, dynamic>>{};

    for (final appName in _dataStore.allAppNames) {
      if (!appName.startsWith('web:')) continue;
      final domain = appName.replaceFirst('web:', '');
      final meta = _dataStore.getAppMetadata(appName);
      if (meta == null) continue;

      // Add to domainLimits regardless of whether a limit is set, so the
      // extension can sync metadata fields (category, isTracking, etc.) too.
      domainLimits[domain] = {
        'dailyLimitSeconds': meta.dailyLimit.inSeconds,
        'isTracking':        meta.isTracking,
        'isProductive':      meta.isProductive,
        'category':          meta.category,
        'siteName':          meta.siteName,
      };

      if (meta.dailyLimit == Duration.zero) continue;
      final record = _dataStore.getAppUsage(appName, startOfDay);
      if (record != null && record.timeSpent >= meta.dailyLimit) {
        blockedDomains.add(domain);
      }
    }

    await _sendJson(req.response, HttpStatus.ok, {
      'active': isActive,
      'blockedDomains': blockedDomains,
      'allowedDomains': <String>[],
      'endTimeEpochMs': endTimeEpochMs,
      'sessionLabel': sessionLabel,
      // New in sync protocol v2: lets the extension merge desktop-only limits
      // and metadata into scolect_settings.metadata (gaps-fill, extension wins).
      'domainLimits': domainLimits,
    });
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  static void _setCors(HttpResponse response, [String origin = '']) {
    // Echo back the extension origin rather than '*' so browsers enforce
    // the same-origin policy against non-extension callers.
    final allowedOrigin = origin.startsWith('chrome-extension://')
        ? origin
        : 'null'; // 'null' deliberately blocks non-extension browser fetches
    response.headers
      ..add('Access-Control-Allow-Origin', allowedOrigin)
      ..add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
      ..add('Access-Control-Allow-Headers', 'Content-Type')
      ..add('Vary', 'Origin');
  }

  static Future<String> _readBody(HttpRequest req) async {
    final bytes = await req.fold<List<int>>([], (a, b) => [...a, ...b]);
    return utf8.decode(bytes);
  }

  static Future<void> _sendJson(
    HttpResponse response,
    int statusCode,
    Map<String, dynamic> body,
  ) async {
    response
      ..statusCode = statusCode
      ..headers.contentType = ContentType.json;
    response.write(jsonEncode(body));
    await response.close();
  }
}
