import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../sections/controller/app_data_controller.dart';
import '../sections/controller/categories_controller.dart';
import '../sections/controller/focus_mode_controller.dart';

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
        await _ingestDomains(date, domains);
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

    await _ingestDomains(date, domains);
    await _sendJson(req.response, HttpStatus.ok, {'ok': true});
  }

  // ─── Shared domain ingestion (used by both HTTP and WebSocket paths) ──────

  static Future<void> _ingestDomains(DateTime date, List<dynamic> domains) async {
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
      final timeSpent = Duration(seconds: seconds);
      final now = DateTime.now();

      final existingUsage = _dataStore.getAppUsage(appName, date);
      final shouldUpdate = existingUsage == null || timeSpent > existingUsage.timeSpent;

      if (shouldUpdate) {
        final existingPeriods = existingUsage?.usagePeriods ?? [];
        final usagePeriods = existingPeriods.isNotEmpty
            ? existingPeriods
            : (seconds > 0
                ? [TimeRange(startTime: now.subtract(timeSpent), endTime: now)]
                : <TimeRange>[]);
        await _dataStore.setAppUsage(appName, date, timeSpent, visits, usagePeriods);
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
          dailyLimit: extLimitSecs != null && extLimitSecs > 0
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
        if (extLimitSecs != null && extLimitSecs > 0) {
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

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
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
      final record = _dataStore.getAppUsage(appName, startOfDay);
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
