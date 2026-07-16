import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Safe platform checks that won't throw UnsupportedError on Flutter Web.
class PlatformUtils {
  static bool get isMacOS {
    if (kIsWeb) return false;
    return io.Platform.isMacOS;
  }

  static bool get isWindows {
    if (kIsWeb) return false;
    return io.Platform.isWindows;
  }

  static bool get isLinux {
    if (kIsWeb) return false;
    return io.Platform.isLinux;
  }
}
