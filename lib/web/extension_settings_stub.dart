// ─── Stub for desktop builds ──────────────────────────────────────────────────
// Never instantiated at runtime on desktop; only exists so conditional imports
// compile successfully on non-web platforms.

enum ExtensionMode { standalone, trackerOnly, hybrid }

extension ExtensionModeExt on ExtensionMode {
  String get key => name;
  String get label => name;
  String get description => '';
  static ExtensionMode fromKey(String key) => ExtensionMode.standalone;
}

class WebsiteMetadata {
  final String category;
  final bool isTracking;
  final bool isProductive;
  final int dailyLimitSeconds;
  Duration get dailyLimit => Duration(seconds: dailyLimitSeconds);

  const WebsiteMetadata({
    this.category = 'Uncategorized',
    this.isTracking = true,
    this.isProductive = false,
    this.dailyLimitSeconds = 0,
  });

  WebsiteMetadata copyWith({
    String? category,
    bool? isTracking,
    bool? isProductive,
    int? dailyLimitSeconds,
  }) => WebsiteMetadata(
        category: category ?? this.category,
        isTracking: isTracking ?? this.isTracking,
        isProductive: isProductive ?? this.isProductive,
        dailyLimitSeconds: dailyLimitSeconds ?? this.dailyLimitSeconds,
      );

  factory WebsiteMetadata.fromMap(Map<String, dynamic> m) =>
      const WebsiteMetadata();

  Map<String, dynamic> toMap() => {};
}

class ExtensionSettings {
  ExtensionSettings._();
  static final ExtensionSettings _instance = ExtensionSettings._();
  factory ExtensionSettings() => _instance;

  ExtensionMode get mode => ExtensionMode.standalone;
  String get desktopUrl => 'http://localhost:46000';

  Future<void> load() async {}
  Future<ExtensionMode> getMode() async => ExtensionMode.standalone;
  Future<WebsiteMetadata> getMetadata(String domain) async => const WebsiteMetadata();
  Future<Map<String, WebsiteMetadata>> getAllMetadata() async => {};
  Future<void> setMode(ExtensionMode mode) async {}
  Future<void> setDesktopUrl(String url) async {}
  Future<void> updateMetadata(String domain, {String? category, bool? isTracking, bool? isProductive, Duration? dailyLimit}) async {}
  Future<void> clearAllData() async {}
}
