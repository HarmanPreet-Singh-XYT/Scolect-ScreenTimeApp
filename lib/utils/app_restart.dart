import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Utility class for restarting the application
///
/// This class provides a platform channel to restart the app.
/// Requires native implementation on macOS side.
class AppRestart {
  static const _channel = MethodChannel('app_restart');

  /// Restarts the application
  ///
  /// This will close the current app instance and relaunch it.
  /// Useful after permission changes that require a restart to take effect.
  ///
  /// Returns a Future that completes when the restart is initiated.
  /// On macOS, the app will quit and relaunch automatically.
  ///
  /// Example:
  /// ```dart
  /// await AppRestart.restart();
  /// ```
  static Future<void> restart() async {
    try {
      await _channel.invokeMethod('restartApp');
    } catch (e) {
      debugPrint('Failed to restart app: $e');
      rethrow; // Re-throw so caller can handle the error
    }
  }
}
