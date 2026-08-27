import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../sections/controller/app_data_controller.dart';
import '../sections/controller/categories_controller.dart';
import '../sections/controller/focus_mode_controller.dart';
import '../sections/controller/settings_data_controller.dart';

/// Lightweight server on port 46000 for the Scolect browser extension.
///
/// HTTP routes (unchanged for backwards compat):
///   GET  /ping   → health check + focus state summary
///   POST /usage  → ingest domain-level usage data from the extension
///   GET  /focus  → full focus state for the extension's blocker
///
/// WebSocket route:
///   GET  /ws     → upgrade to WebSocket; desktop pushes focus_state on connect
///                  and on every timer state change; extension pushes usage data
///                  every 5 s instead of polling once per minute.
class BrowserExtensionServer {
  static const int defaultPort = 46000;
  static const String _version = '1.0';

  static HttpServer? _server;
  static int _currentPort = defaultPort;
  static final AppDataStore _dataStore = AppDataStore();

  // Timestamp of the last successfully ingested usage push (HTTP or WS), so
  // the UI can show "last synced" / warn when the extension has gone quiet.
  static DateTime? _lastUsageSyncAt;
  static DateTime? get lastUsageSyncAt => _lastUsageSyncAt;

  // ─── WebSocket state ─────────────────────────────────────────────────────
  static final Set<WebSocket> _clients = {};
  static StreamSubscription<TimerUpdate>? _timerSubscription;
  static TimerState? _lastBroadcastState;
  static bool? _lastBroadcastRunning;

  static int get currentPort => _currentPort;

  static Future<void> startServer({int port = defaultPort}) async {
    _currentPort = port;
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, _currentPort);
      debugPrint('✅ Extension server started on port $_currentPort');
      _server!.listen(_handleRequest, onError: (e) {
        debugPrint('⚠️ Extension server error: $e');
      });

      // Push focus_state to extension whenever the timer transitions state.
      // Only broadcast on actual transitions, not every second tick.
      _timerSubscription =
          PomodoroTimerService.instance.timerUpdates.listen((update) {
        final stateChanged = update.state != _lastBroadcastState;
        final runningChanged = update.isRunning != _lastBroadcastRunning;
        if (stateChanged || runningChanged) {
          _lastBroadcastState = update.state;
          _lastBroadcastRunning = update.isRunning;
          _broadcastFocusState();
        }
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
    await _timerSubscription?.cancel();
    _timerSubscription = null;
    _lastBroadcastState = null;
    _lastBroadcastRunning = null;
    _lastUsageSyncAt = null;

    for (final ws in List.of(_clients)) {
      await ws.close(WebSocketStatus.goingAway).catchError((_) {});
    }
    _clients.clear();

    await _server?.close(force: true);
    _server = null;
    debugPrint('🛑 Extension server closed');
  }

  // ─── Request dispatcher ──────────────────────────────────────────────────

  static Future<void> _handleRequest(HttpRequest req) async {
    final origin = req.headers.value('origin') ?? '';
    final isExtension = origin.startsWith('chrome-extension://');

    if (!isExtension && req.method != 'OPTIONS') {
      if (origin.isNotEmpty) {
        req.response.statusCode = HttpStatus.forbidden;
        req.response.write(jsonEncode({'error': 'Forbidden: extension-only endpoint'}));
        await req.response.close();
        return;
      }
    }

    _setCors(req.response, origin);

    if (req.method == 'OPTIONS') {
      req.response.statusCode = HttpStatus.noContent;
      await req.response.close();
      return;
    }

    try {
      switch ('${req.method} ${req.uri.path}') {
        case 'GET /ping':
          await _handlePing(req);
        case 'GET /ws':
          await _handleWsUpgrade(req);
        case 'POST /usage':
        case 'POST /api/browser-sync':
          await _handleUsage(req);
        case 'POST /clear-web-data':
          await _handleClearWebData(req);
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

  // ─── POST /clear-web-data ────────────────────────────────────────────────

  static Future<void> _handleClearWebData(HttpRequest req) async {
    await _dataStore.clearWebData();
    await _sendJson(req.response, HttpStatus.ok, {'ok': true});
  }

  // ─── GET /ws  (WebSocket upgrade) ────────────────────────────────────────

  static Future<void> _handleWsUpgrade(HttpRequest req) async {
    WebSocket ws;
    try {
      ws = await WebSocketTransformer.upgrade(req);
    } catch (e) {
      debugPrint('⚠️ WS upgrade failed: $e');
      return;
    }

    _clients.add(ws);
    debugPrint('🔌 WS client connected (${_clients.length} total)');

    // Immediately push current focus state so the extension is in sync.
    _broadcastFocusState(target: ws);

    ws.listen(
      (data) => _handleWsMessage(ws, data),
      onDone: () {
        _clients.remove(ws);
        debugPrint('🔌 WS client disconnected (${_clients.length} remaining)');
      },
      onError: (e) {
        _clients.remove(ws);
        debugPrint('⚠️ WS client error: $e');
      },
      cancelOnError: true,
    );
  }

  // ─── WebSocket incoming message handler ──────────────────────────────────

  static Future<void> _handleWsMessage(WebSocket ws, dynamic data) async {
    try {
      final msg = jsonDecode(data as String) as Map<String, dynamic>;

      if (msg['type'] == 'usage') {
        final dateStr = msg['date'] as String?;
        final domains = msg['domains'] as List<dynamic>?;
        if (dateStr == null || domains == null) return;
        final date = DateTime.tryParse(dateStr);
        if (date == null) return;
        final browserId = msg['browserId'] as String?;
        final browserName = msg['browserName'] as String?;
        await _ingestDomains(date, domains, browserId: browserId, browserName: browserName);
        return;
      }

      if (msg['type'] == 'register') {
        final browserId = msg['browserId'] as String?;
        final browserName = msg['browserName'] as String? ?? 'Unknown';
        if (browserId == null || browserId.isEmpty) return;
        await _dataStore.upsertBrowserSource(browserId, browserName);
        return;
      }

      if (msg['type'] == 'focus_control') {
        final action = msg['action'] as String?;
        final timer = PomodoroTimerService.instance;
        switch (action) {
          case 'start':
            timer.startWorkSession();
          case 'pause':
            timer.pauseTimer();
          case 'resume':
            timer.resumeTimer();
          case 'reset':
            timer.resetTimer();
          case 'skip_forward':
            timer.navigateForward();
          case 'skip_backward':
            timer.navigateBackward();
          case 'phase_work':
            timer.resetTimer();
            timer.startWorkSession();
          case 'phase_shortBreak':
            timer.resetTimer();
            timer.startShortBreak();
          case 'phase_longBreak':
            timer.resetTimer();
            timer.startLongBreak();
        }
        // Push updated state back to all clients immediately so the popup
        // reflects the new timer state without waiting for the next tick.
        _broadcastFocusState();
      }
    } catch (e) {
      debugPrint('⚠️ WS message error: $e');
    }
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

    final browserId = json['browserId'] as String?;
    final browserName = json['browserName'] as String?;
    await _ingestDomains(date, domains, browserId: browserId, browserName: browserName);
    await _sendJson(req.response, HttpStatus.ok, {'ok': true});
  }

  // ─── Shared domain ingestion (used by both HTTP and WebSocket paths) ──────

  // The extension always reports a literal calendar date (no concept of the
  // desktop's configurable day-reset hour), so [reportedDate] is only used
  // to reject malformed payloads. Bucketing always uses the desktop's own
  // logical date so it agrees with how the UI reads usage back out via
  // SettingsManager().getLogicalDate() — otherwise usage synced during the
  // reset-hour window lands under a date key the UI never queries.
  //
  // [browserId] identifies which browser extension sent this payload (see
  // web/background.js getBrowserId()) — usage TIME is stored per-source
  // ('web:$domain::$browserId') so the desktop can filter/break down by
  // browser, but metadata (category/limits/tracking) stays keyed by plain
  // domain ('web:$domain') since categorization is a property of the site,
  // not of which browser visited it. Payloads without a browserId (should
  // not happen with the current extension, but kept for robustness) fall
  // back to the legacy plain-domain usage key.
  static Future<void> _ingestDomains(
      DateTime reportedDate, List<dynamic> domains,
      {String? browserId, String? browserName}) async {
    _lastUsageSyncAt = DateTime.now();
    final date = SettingsManager().getLogicalDate(DateTime.now());

    if (browserId != null && browserId.isNotEmpty) {
      await _dataStore.upsertBrowserSource(browserId, browserName ?? 'Unknown');
    }

    for (final raw in domains) {
      final entry = raw as Map<String, dynamic>;
      final domain = entry['domain'] as String?;
      final seconds = (entry['seconds'] as num?)?.toInt() ?? 0;
      final visits = (entry['visits'] as num?)?.toInt() ?? 0;
      final siteName = entry['siteName'] as String? ?? '';

      final extLimitSecs = (entry['dailyLimitSeconds'] as num?)?.toInt();
      final extIsTracking = entry['isTracking'] as bool?;
      final extIsProductive = entry['isProductive'] as bool?;
      final extCategory = entry['category'] as String?;

      if (domain == null || domain.isEmpty || seconds < 0) continue;

      final appName = 'web:$domain';
      final usageAppName = (browserId != null && browserId.isNotEmpty)
          ? '$appName::$browserId'
          : appName;
      final timeSpent = Duration(seconds: seconds);
      final now = DateTime.now();

      final existingUsage = _dataStore.getAppUsage(usageAppName, date);
      final shouldUpdate = existingUsage == null || timeSpent > existingUsage.timeSpent;

      if (shouldUpdate) {
        final existingPeriods = existingUsage?.usagePeriods ?? [];
        final usagePeriods = existingPeriods.isNotEmpty
            ? existingPeriods
            : (seconds > 0
                ? [TimeRange(startTime: now.subtract(timeSpent), endTime: now)]
                : <TimeRange>[]);
        await _dataStore.setAppUsage(usageAppName, date, timeSpent, visits, usagePeriods);
      }

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
          dailyLimit: extLimitSecs != null
              ? Duration(seconds: extLimitSecs)
              : null,
        );
      } else {
        if (WebsiteCategories.isDefaultCategory(existingMeta.category)) {
          final category = (extCategory != null && extCategory.isNotEmpty)
              ? extCategory
              : WebsiteCategories.categorizeWebsite(domain);
          if (!WebsiteCategories.isDefaultCategory(category)) {
            await _dataStore.updateAppMetadata(appName, category: category);
          }
        }
        if (siteName.isNotEmpty && existingMeta.siteName.isEmpty) {
          await _dataStore.updateAppMetadata(appName, siteName: siteName);
        }
        if (extLimitSecs != null) {
          final extDuration = Duration(seconds: extLimitSecs);
          if (existingMeta.dailyLimit != extDuration) {
            await _dataStore.updateAppMetadata(appName, dailyLimit: extDuration);
          }
        }
        if (extIsTracking != null && extIsTracking != existingMeta.isTracking) {
          await _dataStore.updateAppMetadata(appName, isTracking: extIsTracking);
        }
        if (extIsProductive != null && extIsProductive != existingMeta.isProductive) {
          await _dataStore.updateAppMetadata(appName, isProductive: extIsProductive);
        }
      }
    }
  }

  // ─── GET /focus ──────────────────────────────────────────────────────────

  static Future<void> _handleFocus(HttpRequest req) async {
    final payload = Map<String, dynamic>.from(_buildFocusStatePayload())
      ..remove('type');
    await _sendJson(req.response, HttpStatus.ok, payload);
  }

  // ─── Focus state builder (shared by HTTP and WS push) ────────────────────

  static Map<String, dynamic> _buildFocusStatePayload() {
    final timer = PomodoroTimerService.instance;
    final isActive = timer.isRunning && timer.currentState != TimerState.idle;

    String? sessionLabel;
    int? endTimeEpochMs;

    if (isActive) {
      sessionLabel = switch (timer.currentState) {
        TimerState.work       => 'Work Session',
        TimerState.shortBreak => 'Short Break',
        TimerState.longBreak  => 'Long Break',
        TimerState.idle       => null,
      };
      endTimeEpochMs =
          DateTime.now().millisecondsSinceEpoch + (timer.secondsRemaining * 1000);
    }

    final startOfDay = SettingsManager().getLogicalDate(DateTime.now());
    final blockedDomains = <String>[];
    final domainLimits = <String, Map<String, dynamic>>{};

    for (final appName in _dataStore.allAppNames) {
      if (!appName.startsWith('web:')) continue;
      final domain = appName.replaceFirst('web:', '');
      final meta = _dataStore.getAppMetadata(appName);
      if (meta == null) continue;

      domainLimits[domain] = {
        'dailyLimitSeconds': meta.dailyLimit.inSeconds,
        'isTracking':        meta.isTracking,
        'isProductive':      meta.isProductive,
        'category':          meta.category,
        'siteName':          meta.siteName,
      };

      if (meta.dailyLimit == Duration.zero) continue;
      // Daily limits apply to the domain as a whole, across every browser
      // that visited it — not per-source — so this always uses the combined
      // total regardless of what the UI's browser filter is currently set to.
      final record = _dataStore.getWebsiteUsage(appName, startOfDay);
      if (record != null && record.timeSpent >= meta.dailyLimit) {
        blockedDomains.add(domain);
      }
    }

    return {
      'type': 'focus_state',
      'active': isActive,
      'blockedDomains': blockedDomains,
      'allowedDomains': <String>[],
      'endTimeEpochMs': endTimeEpochMs,
      'sessionLabel': sessionLabel,
      'domainLimits': domainLimits,
    };
  }

  // ─── Broadcast focus state to WS clients ─────────────────────────────────

  static void _broadcastFocusState({WebSocket? target}) {
    if (target == null && _clients.isEmpty) return;
    final payload = jsonEncode(_buildFocusStatePayload());
    final targets = target != null ? [target] : List.of(_clients);
    for (final ws in targets) {
      try {
        ws.add(payload);
      } catch (e) {
        debugPrint('⚠️ WS send error: $e');
      }
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  static void _setCors(HttpResponse response, [String origin = '']) {
    final allowedOrigin = origin.startsWith('chrome-extension://')
        ? origin
        : 'null';
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
