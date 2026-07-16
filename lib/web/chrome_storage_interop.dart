// ─── chrome.storage.local JS Interop ─────────────────────────────────────────
//
// Provides async Dart access to chrome.storage.local.
// Only used on kIsWeb; gracefully no-ops when chrome.storage is unavailable
// (e.g. plain Flutter web dev server preview).

// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:js_interop';

// ─── Low-level JS bindings ────────────────────────────────────────────────────

@JS('chrome.storage.local.get')
external JSPromise<JSObject> _storageGet(JSAny? keys);

@JS('chrome.storage.local.set')
external JSPromise<JSObject> _storageSet(JSObject items);

@JS('chrome.storage.local.remove')
external JSPromise<JSObject> _storageRemove(JSAny keys);

@JS('JSON.stringify')
external JSString _jsonStringify(JSAny? value);

@JS('JSON.parse')
external JSObject _jsonParse(JSString text);

@JS('globalThis.chrome.storage.local')
external JSAny? get _chromeStorageLocal;

// ─── Availability check ───────────────────────────────────────────────────────

bool get isChromeStorageAvailable {
  try {
    return _chromeStorageLocal != null;
  } catch (_) {
    return false;
  }
}

// ─── Public async API ─────────────────────────────────────────────────────────

/// Reads the given [keys] from chrome.storage.local.
/// Returns a decoded Map; missing keys are absent from the result.
Future<Map<String, dynamic>> chromeStorageGet(List<String> keys) async {
  if (!isChromeStorageAvailable) return {};
  try {
    final jsKeys = keys.map((k) => k.toJS).toList().toJS;
    final jsResult = await _storageGet(jsKeys).toDart;
    final jsonStr = _jsonStringify(jsResult).toDart;
    return (jsonDecode(jsonStr) as Map<String, dynamic>?) ?? {};
  } catch (e) {
    return {};
  }
}

/// Reads ALL keys from chrome.storage.local.
Future<Map<String, dynamic>> chromeStorageGetAll() async {
  if (!isChromeStorageAvailable) return {};
  try {
    final jsResult = await _storageGet(null).toDart;
    final jsonStr = _jsonStringify(jsResult).toDart;
    return (jsonDecode(jsonStr) as Map<String, dynamic>?) ?? {};
  } catch (e) {
    return {};
  }
}

/// Writes [data] into chrome.storage.local.
/// Values must be JSON-serialisable.
Future<void> chromeStorageSet(Map<String, dynamic> data) async {
  if (!isChromeStorageAvailable) return;
  try {
    final jsonStr = jsonEncode(data);
    final jsObj = _jsonParse(jsonStr.toJS);
    await _storageSet(jsObj).toDart;
  } catch (_) {}
}

/// Removes [key] from chrome.storage.local.
Future<void> chromeStorageRemove(String key) async {
  if (!isChromeStorageAvailable) return;
  try {
    await _storageRemove(key.toJS).toDart;
  } catch (_) {}
}
