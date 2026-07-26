import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';

class AppCategory {
  final String name;
  final List<String> apps;

  /// Pre-computed lowercase app names for fast matching.
  late final List<String> _lowerApps =
      apps.map((a) => a.toLowerCase()).toList(growable: false);

  AppCategory({required this.name, required this.apps});

  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _categoryL10nMap[name]?.call(l10n) ?? name;
  }

  bool containsApp(String appName, BuildContext? context) {
    final lower = appName.toLowerCase();

    // Fast path: check pre-computed lowercase English names
    if (_lowerApps.any((app) => lower.contains(app))) return true;

    // Slow path: check localized names only when context is available
    if (context == null) return false;
    final l10n = AppLocalizations.of(context)!;
    return apps.any((app) {
      final localized = _appL10nMap[app]?.call(l10n);
      return localized != null && lower.contains(localized.toLowerCase());
    });
  }
}

class AppCategories {
  AppCategories._();

  static final List<AppCategory> categories = [
    AppCategory(name: "All", apps: const []),
    AppCategory(
      name: "Productivity",
      apps: const [
        "Microsoft Word",
        "Excel",
        "PowerPoint",
        "Google Docs",
        "Notion",
        "Evernote",
        "Trello",
        "Asana",
        "Slack",
        "Microsoft Teams",
        "Zoom",
        "Google Calendar",
        "Apple Calendar",
      ],
    ),
    AppCategory(
      name: "Development",
      apps: const [
        "Visual Studio Code",
        "IntelliJ IDEA",
        "PyCharm",
        "Xcode",
        "Eclipse",
        "Android Studio",
        "Sublime Text",
        "GitHub Desktop",
        "Terminal",
        "Command Prompt",
        "iTerm",
      ],
    ),
    AppCategory(
      name: "Social Media",
      apps: const [
        "Facebook",
        "Instagram",
        "Twitter",
        "LinkedIn",
        "TikTok",
        "Snapchat",
        "Reddit",
        "WhatsApp",
        "Messenger",
      ],
    ),
    AppCategory(
      name: "Entertainment",
      apps: const [
        "Netflix",
        "YouTube",
        "Spotify",
        "Apple Music",
        "Amazon Prime Video",
        "Hulu",
        "Disney+",
        "Twitch",
        "VLC Media Player",
        "Plex",
      ],
    ),
    AppCategory(
      name: "Gaming",
      apps: const [
        "Steam",
        "Epic Games Launcher",
        "Origin",
        "Uplay",
        "Minecraft",
        "League of Legends",
        "World of Warcraft",
        "Counter-Strike",
        "Valorant",
      ],
    ),
    AppCategory(
      name: "Communication",
      apps: const [
        "Zoom",
        "Skype",
        "Microsoft Teams",
        "Google Meet",
        "FaceTime",
        "Telegram",
        "Signal",
        "Discord",
      ],
    ),
    AppCategory(
      name: "Web Browsing",
      apps: const [
        "Chrome",
        "Firefox",
        "Safari",
        "Edge",
        "Opera",
        "Brave",
        "Vivaldi",
      ],
    ),
    AppCategory(
      name: "Creative",
      apps: const [
        "Adobe Photoshop",
        "Illustrator",
        "Premiere Pro",
        "Final Cut Pro",
        "Blender",
        "Lightroom",
        "Figma",
        "Sketch",
        "InDesign",
      ],
    ),
    AppCategory(
      name: "Education",
      apps: const [
        "Coursera",
        "edX",
        "Udemy",
        "Khan Academy",
        "Duolingo",
        "Grammarly",
        "Kindle",
        "Audible",
      ],
    ),
    AppCategory(
      name: "Utility",
      apps: const [
        "Calculator",
        "Notes",
        "Terminal",
        "System Preferences",
        "Task Manager",
        "File Explorer",
        "Dropbox",
        "Google Drive",
      ],
    ),
  ];

  /// Pre-built lookup: category name → AppCategory
  static final Map<String, AppCategory> _categoryMap = {
    for (final cat in categories) cat.name: cat,
  };

  static const _uncategorized = "Uncategorized";

  static String categorizeApp(String appName, [BuildContext? context]) {
    // Skip "All" (index 0) — it matches everything
    for (var i = 1; i < categories.length; i++) {
      if (categories[i].containsApp(appName, context)) {
        return categories[i].name;
      }
    }
    return _uncategorized;
  }

  static String getLocalizedCategoryName(
      String categoryName, BuildContext context) {
    return (_categoryMap[categoryName] ??
            AppCategory(name: _uncategorized, apps: const []))
        .getLocalizedName(context);
  }

  static final Map<String, Color> _colorMap = {
    "Productivity": Colors.blue,
    "Development": Colors.green,
    "Social Media": Colors.purple,
    "Entertainment": Colors.red,
    "Gaming": Colors.orange,
    "Communication": Colors.teal,
    "Web Browsing": Colors.grey,
    "Creative": Colors.yellow,
    "Education": Colors.successPrimaryColor,
    "Utility": Colors.warningPrimaryColor,
  };

  static Color getCategoryColor(String categoryName) =>
      _colorMap[categoryName] ?? Colors.grey[500];

  static List<String> getCategoryNames() =>
      categories.map((c) => c.name).toList(growable: false);

  static List<String> getLocalizedCategoryNames(BuildContext context) =>
      categories
          .map((c) => c.getLocalizedName(context))
          .toList(growable: false);
}

// ────────────────────── Website Auto-Categorization ─────────────

/// Domain-pattern–based category classifier for website tracking.
///
/// Uses the same category names as [AppCategories] so that all existing
/// color, localization, and filter logic applies automatically.
///
/// Matching is done on the eTLD+1 portion of the domain (e.g. "github.com"
/// from "gist.github.com") using case-insensitive substring checks.
class WebsiteCategories {
  WebsiteCategories._();

  static const _uncategorized = 'Uncategorized';

  // Each entry is a list of domain keywords that belong to a category.
  // Order matters — first match wins.
  static const Map<String, List<String>> _domainPatterns = {
    'Social Media': [
      'facebook', 'instagram', 'twitter', 'x.com', 'tiktok', 'snapchat',
      'reddit', 'linkedin', 'pinterest', 'tumblr', 'mastodon', 'threads',
      'vk.com', 'weibo', 'quora', 'nextdoor',
    ],
    'Entertainment': [
      'youtube', 'netflix', 'hulu', 'disneyplus', 'primevideo', 'amazon',
      'twitch', 'spotify', 'soundcloud', 'deezer', 'tidal', 'pandora',
      'vimeo', 'dailymotion', 'crunchyroll', 'funimation', 'peacocktv',
      'max.com', 'paramountplus', 'appletv', 'plex', 'imdb',
    ],
    'Development': [
      'github', 'gitlab', 'bitbucket', 'stackoverflow', 'stackexchange',
      'npmjs', 'pypi', 'crates.io', 'rubygems', 'packagist',
      'developer.mozilla', 'developers.google', 'developer.apple',
      'docs.microsoft', 'learn.microsoft', 'developer.android',
      'codepen', 'jsfiddle', 'replit', 'codesandbox', 'glitch.me',
      'leetcode', 'hackerrank', 'codewars', 'exercism',
      'docker', 'kubernetes', 'terraform', 'ansible',
      'vercel', 'netlify', 'heroku', 'render.com', 'railway',
    ],
    'Productivity': [
      'notion', 'trello', 'asana', 'todoist', 'clickup', 'monday.com',
      'basecamp', 'jira', 'confluence', 'linear.app', 'height.app',
      'airtable', 'coda.io', 'roamresearch', 'obsidian',
      'docs.google', 'sheets.google', 'slides.google', 'drive.google',
      'calendar.google', 'office365', 'microsoft365', 'office.com',
      'evernote', 'onenote', 'bear.app', 'craft.do',
    ],
    'Communication': [
      'slack', 'discord', 'telegram', 'signal', 'teams.microsoft',
      'meet.google', 'zoom', 'webex', 'skype', 'whereby',
      'mail.google', 'gmail', 'outlook', 'mail.yahoo', 'protonmail',
      'fastmail', 'hey.com', 'superhuman',
    ],
    'Education': [
      'coursera', 'udemy', 'edx', 'khanacademy', 'duolingo', 'brilliant',
      'skillshare', 'pluralsight', 'lynda', 'linkedin.com/learning',
      'codecademy', 'freecodecamp', 'theodinproject', 'boot.dev',
      'wikipedia', 'britannica', 'scholarpedia',
      'scholar.google', 'academia.edu', 'arxiv', 'researchgate',
      'jstor', 'pubmed', 'semanticscholar',
    ],
    'Creative': [
      'figma', 'sketch.cloud', 'adobe', 'canva', 'dribbble', 'behance',
      'unsplash', 'pexels', 'pixabay', 'shutterstock', 'gettyimages',
      'midjourney', 'runwayml', 'stability.ai',
      'deviantart', 'artstation',
    ],
    'Gaming': [
      'steampowered', 'epicgames', 'gog.com', 'ea.com', 'ubisoft',
      'xbox', 'playstation', 'nintendo',
      'ign', 'gamespot', 'kotaku', 'pcgamer', 'polygon',
    ],
    'Utility': [
      'translate.google', 'deepl', 'wolframalpha',
      'weather', 'maps.google', 'bing.com/maps', 'openstreetmap',
      'archive.org', 'web.archive',
      'pastebin', 'gist.github', 'hastebin',
      'regex101', 'crontab.guru', 'jsonlint',
      'transferwise', 'wise.com', 'paypal', 'stripe',
    ],
  };

  /// Returns the best-matching category name for a given domain.
  ///
  /// [domain] should be the bare domain (e.g. "github.com" or
  /// "gist.github.com") — no scheme, no path.
  static String categorizeWebsite(String domain) {
    final lower = domain.toLowerCase();
    // Strip common subdomains to get the core domain for matching
    final core = lower
        .replaceFirst(RegExp(r'^www\.'), '')
        .replaceFirst(RegExp(r'^m\.'), '');

    for (final entry in _domainPatterns.entries) {
      for (final keyword in entry.value) {
        if (core.contains(keyword)) return entry.key;
      }
    }
    return _uncategorized;
  }

  /// Returns true if this domain's category is not yet known
  /// (i.e. was assigned a default placeholder by the server).
  static bool isDefaultCategory(String category) =>
      category == 'Browser' || category == 'Web' || category == _uncategorized;
}

// ────────────────────── Localization Maps ──────────────────────
// Single source of truth — replaces two giant switch statements.

typedef _L10nAccessor = String Function(AppLocalizations l10n);

const Map<String, _L10nAccessor> _categoryL10nMap = {
  "All": _catAll,
  "Productivity": _catProductivity,
  "Development": _catDevelopment,
  "Social Media": _catSocialMedia,
  "Entertainment": _catEntertainment,
  "Gaming": _catGaming,
  "Communication": _catCommunication,
  "Web Browsing": _catWebBrowsing,
  "Creative": _catCreative,
  "Education": _catEducation,
  "Utility": _catUtility,
  "Uncategorized": _catUncategorized,
};

// Top-level tear-off–friendly functions (const-map compatible)
String _catAll(AppLocalizations l) => l.categoryAll;
String _catProductivity(AppLocalizations l) => l.categoryProductivity;
String _catDevelopment(AppLocalizations l) => l.categoryDevelopment;
String _catSocialMedia(AppLocalizations l) => l.categorySocialMedia;
String _catEntertainment(AppLocalizations l) => l.categoryEntertainment;
String _catGaming(AppLocalizations l) => l.categoryGaming;
String _catCommunication(AppLocalizations l) => l.categoryCommunication;
String _catWebBrowsing(AppLocalizations l) => l.categoryWebBrowsing;
String _catCreative(AppLocalizations l) => l.categoryCreative;
String _catEducation(AppLocalizations l) => l.categoryEducation;
String _catUtility(AppLocalizations l) => l.categoryUtility;
String _catUncategorized(AppLocalizations l) => l.categoryUncategorized;

const Map<String, _L10nAccessor> _appL10nMap = {
  // Productivity
  "Microsoft Word": _appMicrosoftWord,
  "Excel": _appExcel,
  "PowerPoint": _appPowerPoint,
  "Google Docs": _appGoogleDocs,
  "Notion": _appNotion,
  "Evernote": _appEvernote,
  "Trello": _appTrello,
  "Asana": _appAsana,
  "Slack": _appSlack,
  "Microsoft Teams": _appMicrosoftTeams,
  "Zoom": _appZoom,
  "Google Calendar": _appGoogleCalendar,
  "Apple Calendar": _appAppleCalendar,
  // Development
  "Visual Studio Code": _appVSCode,
  "Terminal": _appTerminal,
  "Command Prompt": _appCommandPrompt,
  // Web Browsing
  "Chrome": _appChrome,
  "Firefox": _appFirefox,
  "Safari": _appSafari,
  "Edge": _appEdge,
  "Opera": _appOpera,
  "Brave": _appBrave,
  // Entertainment
  "Netflix": _appNetflix,
  "YouTube": _appYouTube,
  "Spotify": _appSpotify,
  "Apple Music": _appAppleMusic,
  // Utility
  "Calculator": _appCalculator,
  "Notes": _appNotes,
  "System Preferences": _appSystemPreferences,
  "Task Manager": _appTaskManager,
  "File Explorer": _appFileExplorer,
  "Dropbox": _appDropbox,
  "Google Drive": _appGoogleDrive,
};

String _appMicrosoftWord(AppLocalizations l) => l.appMicrosoftWord;
String _appExcel(AppLocalizations l) => l.appExcel;
String _appPowerPoint(AppLocalizations l) => l.appPowerPoint;
String _appGoogleDocs(AppLocalizations l) => l.appGoogleDocs;
String _appNotion(AppLocalizations l) => l.appNotion;
String _appEvernote(AppLocalizations l) => l.appEvernote;
String _appTrello(AppLocalizations l) => l.appTrello;
String _appAsana(AppLocalizations l) => l.appAsana;
String _appSlack(AppLocalizations l) => l.appSlack;
String _appMicrosoftTeams(AppLocalizations l) => l.appMicrosoftTeams;
String _appZoom(AppLocalizations l) => l.appZoom;
String _appGoogleCalendar(AppLocalizations l) => l.appGoogleCalendar;
String _appAppleCalendar(AppLocalizations l) => l.appAppleCalendar;
String _appVSCode(AppLocalizations l) => l.appVisualStudioCode;
String _appTerminal(AppLocalizations l) => l.appTerminal;
String _appCommandPrompt(AppLocalizations l) => l.appCommandPrompt;
String _appChrome(AppLocalizations l) => l.appChrome;
String _appFirefox(AppLocalizations l) => l.appFirefox;
String _appSafari(AppLocalizations l) => l.appSafari;
String _appEdge(AppLocalizations l) => l.appEdge;
String _appOpera(AppLocalizations l) => l.appOpera;
String _appBrave(AppLocalizations l) => l.appBrave;
String _appNetflix(AppLocalizations l) => l.appNetflix;
String _appYouTube(AppLocalizations l) => l.appYouTube;
String _appSpotify(AppLocalizations l) => l.appSpotify;
String _appAppleMusic(AppLocalizations l) => l.appAppleMusic;
String _appCalculator(AppLocalizations l) => l.appCalculator;
String _appNotes(AppLocalizations l) => l.appNotes;
String _appSystemPreferences(AppLocalizations l) => l.appSystemPreferences;
String _appTaskManager(AppLocalizations l) => l.appTaskManager;
String _appFileExplorer(AppLocalizations l) => l.appFileExplorer;
String _appDropbox(AppLocalizations l) => l.appDropbox;
String _appGoogleDrive(AppLocalizations l) => l.appGoogleDrive;

// ────────────────────────── Widget ──────────────────────────

class AppCategoryWidget extends StatelessWidget {
  final String appName;

  const AppCategoryWidget({super.key, required this.appName});

  @override
  Widget build(BuildContext context) {
    final categoryName = AppCategories.categorizeApp(appName, context);
    final localizedName =
        AppCategories.getLocalizedCategoryName(categoryName, context);
    final categoryColor = AppCategories.getCategoryColor(categoryName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        localizedName,
        style: TextStyle(
          color: categoryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
