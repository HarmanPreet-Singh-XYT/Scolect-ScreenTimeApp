import '../sections/controller/data_controllers/browser_data_controller.dart';

class WebBrowserDataProvider {
  static final WebBrowserDataProvider _instance = WebBrowserDataProvider._();
  factory WebBrowserDataProvider() => _instance;
  WebBrowserDataProvider._();

  Future<List<WebsiteBasicDetail>> fetchAllWebsites() async => [];
  
  Future<({Duration totalTime, int siteCount, int visitCount})> fetchTodaySummary() async => 
      (totalTime: Duration.zero, siteCount: 0, visitCount: 0);

  Future<List<WebsiteCategorySummary>> fetchCategoryBreakdown() async => [];

  Future<List<String>> fetchAllCategories() async => ['All'];

  Future<bool> updateWebsiteMetadata(
    String domain, {
    String? category,
    bool? isProductive,
    bool? isTracking,
    bool? isVisible,
    Duration? dailyLimit,
  }) async => false;

  Future<List<({String date, Duration totalTime, int siteCount})>> fetchHistory({int days = 7}) async => [];
}
