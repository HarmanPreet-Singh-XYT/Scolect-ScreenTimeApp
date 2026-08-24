/// Web (browser extension) stub for [BrowserExtensionServer].
///
/// The real implementation only exists on desktop (it binds a local HTTP/WS
/// server on dart:io). This stub lets shared widgets like browser.dart read
/// [lastUsageSyncAt] without platform-branching on every call site.
class BrowserExtensionServer {
  static DateTime? get lastUsageSyncAt => null;
}
