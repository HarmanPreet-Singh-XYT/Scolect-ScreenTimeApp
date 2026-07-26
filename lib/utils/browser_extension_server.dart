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
    _setCors(req.response);

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

      if (domain == null || domain.isEmpty || seconds < 0) continue;

      final appName = 'web:$domain';
      final timeSpent = Duration(seconds: seconds);
      final now = DateTime.now();

      // Create a single usage period spanning the recorded duration
      final usagePeriods = seconds > 0
          ? [TimeRange(startTime: now.subtract(timeSpent), endTime: now)]
          : <TimeRange>[];

      await _dataStore.recordAppUsage(appName, date, timeSpent, visits, usagePeriods);

      // Ensure metadata exists for this domain (first-time setup)
      final existing = _dataStore.getAppMetadata(appName);
      if (existing == null) {
        final category = WebsiteCategories.categorizeWebsite(domain);
        await _dataStore.updateAppMetadata(
          appName,
          category: category,
          isProductive: !WebsiteCategories.isDefaultCategory(category) &&
              category != 'Entertainment' &&
              category != 'Gaming' &&
              category != 'Social Media',
          isTracking: true,
          isVisible: true,
          siteName: siteName,
        );
      } else {
        // Retroactively categorize domains that were saved with a placeholder
        if (WebsiteCategories.isDefaultCategory(existing.category)) {
          final category = WebsiteCategories.categorizeWebsite(domain);
          if (!WebsiteCategories.isDefaultCategory(category)) {
            await _dataStore.updateAppMetadata(appName, category: category);
          }
        }
        // Update siteName if we now have one and the stored one is still empty
        if (siteName.isNotEmpty && existing.siteName.isEmpty) {
          await _dataStore.updateAppMetadata(appName, siteName: siteName);
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
    for (final appName in _dataStore.allAppNames) {
      if (!appName.startsWith('web:')) continue;
      final meta = _dataStore.getAppMetadata(appName);
      if (meta == null || meta.dailyLimit == Duration.zero) continue;
      final record = _dataStore.getAppUsage(appName, startOfDay);
      if (record != null && record.timeSpent >= meta.dailyLimit) {
        blockedDomains.add(appName.replaceFirst('web:', ''));
      }
    }

    await _sendJson(req.response, HttpStatus.ok, {
      'active': isActive,
      'blockedDomains': blockedDomains,
      'allowedDomains': <String>[],
      'endTimeEpochMs': endTimeEpochMs,
      'sessionLabel': sessionLabel,
    });
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  static void _setCors(HttpResponse response) {
    response.headers
      ..add('Access-Control-Allow-Origin', '*')
      ..add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
      ..add('Access-Control-Allow-Headers', 'Content-Type');
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
