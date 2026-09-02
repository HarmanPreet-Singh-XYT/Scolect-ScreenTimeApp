/// Web (browser extension) stub for [BrowserExtensionServer].
///
/// The real implementation only exists on desktop (it binds a local HTTP/WS
/// server on dart:io). This stub lets shared widgets like browser.dart and
/// settings.dart reference the API without platform-branching on every call
/// site — there is nothing to bind on web, so the mutating methods are no-ops
/// that report failure rather than silently pretending to succeed.
class BrowserExtensionServer {
  static const int defaultPort = 46000;

  static DateTime? get lastUsageSyncAt => null;
  static void pingBrowser(String browserId) {}
  static void broadcastBrowserRenamed(
    String browserId,
    String displayName, {
    int? nameUpdatedAt,
  }) {}
  static void broadcastFocusState() {}

  static Future<bool> startServer({int port = defaultPort}) async => false;
  static Future<bool> restartWithPort(int port) async => false;
  static Future<void> dispose() async {}
}
