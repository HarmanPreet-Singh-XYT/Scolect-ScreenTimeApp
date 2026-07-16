// ─── Stub for desktop builds ──────────────────────────────────────────────────
// Same public API as chrome_storage_interop.dart but all no-ops.
// Used so web_dashboard.dart compiles on macOS/Windows/Linux.

bool get isChromeStorageAvailable => false;

Future<Map<String, dynamic>> chromeStorageGet(List<String> keys) async => {};
Future<Map<String, dynamic>> chromeStorageGetAll() async => {};
Future<void> chromeStorageSet(Map<String, dynamic> data) async {}
Future<void> chromeStorageRemove(String key) async {}
