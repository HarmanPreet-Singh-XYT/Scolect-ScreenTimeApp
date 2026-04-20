import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// ============================================================================
// SENTRY SERVICE
// Replace the placeholder DSN below with your real one from:
// https://sentry.io → Project Settings → Client Keys (DSN)
// ============================================================================

const String _sentryDsn =
    'https://f99b626e0123176aacea7961235193d0@o4511210181951488.ingest.us.sentry.io/4511210257776640';

class SentryService {
  SentryService._();

  /// Call this as the outermost wrapper in main(), passing the real app runner.
  ///
  ///   await SentryService.init(() => runApp(MyApp()));
  static Future<void> init(AppRunner appRunner) async {
    if (kDebugMode) {
      await appRunner();
      return;
    }
    await SentryFlutter.init(
      (options) {
        options.dsn = _sentryDsn;

        // Capture 100 % of crashes; tune down for high-traffic apps.
        options.tracesSampleRate = 1.0;

        // Record the OS, device model, locale, etc. in every event.
        options.attachScreenshot = false; // no UI screenshots (privacy)
        options.attachViewHierarchy = false;

        // Tag every event with the platform so you can filter Windows-only.
        options.environment = kReleaseMode ? 'production' : 'development';

        // Enable auto-session tracking (helps measure crash-free rate).
        options.enableAutoSessionTracking = true;
        options.autoSessionTrackingInterval =
            const Duration(milliseconds: 30000);

        // Breadcrumbs for HTTP, navigation, and lifecycle events.
        options.enableAutoNativeBreadcrumbs = true;

        // Print Sentry debug output only in non-release builds.
        options.debug = !kReleaseMode;
      },
      appRunner: appRunner,
    );
  }

  // --------------------------------------------------------------------------
  // Helpers — call these anywhere in the app
  // --------------------------------------------------------------------------

  /// Report a caught exception with optional context.
  static Future<void> captureException(
    Object exception, {
    StackTrace? stackTrace,
    String? tag,
    Map<String, dynamic>? extras,
  }) async {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (tag != null) scope.setTag('component', tag);
        extras?.forEach((k, v) => scope.setTag(k, v.toString()));
        scope.setTag('platform', Platform.operatingSystem);
      },
    );
  }

  /// Add a manual breadcrumb (e.g. "user opened Focus Mode").
  static void addBreadcrumb(String message, {String category = 'app'}) {
    Sentry.addBreadcrumb(
      Breadcrumb(message: message, category: category),
    );
  }

  /// Set the active user context (call after login / settings load).
  static void setUserContext({String? id, String? username}) {
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: id, username: username));
    });
  }

  /// Clear user context (e.g. on logout / reset).
  static void clearUserContext() {
    Sentry.configureScope((scope) => scope.setUser(null));
  }
}
