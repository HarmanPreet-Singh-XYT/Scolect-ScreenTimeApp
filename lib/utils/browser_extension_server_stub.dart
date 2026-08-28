/// Web (browser extension) stub for [BrowserExtensionServer].
///
/// The real implementation only exists on desktop (it binds a local HTTP/WS
/// server on dart:io). This stub lets shared widgets like browser.dart read
/// [lastUsageSyncAt] without platform-branching on every call site.
class BrowserExtensionServer {
  static DateTime? get lastUsageSyncAt => null;
  static void pingBrowser(String browserId) {}
  static void broadcastBrowserRenamed(
    String browserId,
    String displayName, {
    int? nameUpdatedAt,
  }) {}
  static void broadcastFocusState() {}
}
