# Scolect – Claude Code Context

## What this project is

Scolect is a **screen time tracking** app with two separate products built from one Flutter codebase:

1. **Desktop app** (macOS/Windows) — tracks which native applications are in the foreground and for how long. Has a full sidebar UI with Overview, Applications, Reports, Alerts & Limits, Focus Mode, Settings.
2. **Browser extension** — a Chrome extension that tracks time spent on websites. Has its own dashboard (opened as a browser tab) that reuses most of the same Flutter widgets, plus a popup and a background service worker.

These two products share `lib/` but are differentiated at compile time via `kIsWeb` and Dart conditional imports (`if (dart.library.io)`).

---

## Entry points

| Product | Entry | Notes |
|---|---|---|
| Desktop | `main()` → `_appMain()` in `lib/main.dart` | Window manager, tray icon, auto-updater, starts HTTP server on port 46000 for extension IPC |
| Web extension | `main()` → `_appMainWeb()` in `lib/main.dart` | Simpler init, no window chrome, mounts `WebDashboard` |
| Extension popup | `web/popup.js` + `web/popup.html` | Vanilla JS, reads chrome.storage directly |
| Extension background | `web/background.js` | Service worker, alarm-based tracking, syncs to desktop via HTTP |

---

## File ownership — what belongs to what

### Web extension ONLY
```
lib/sections/web_dashboard.dart          # Shell UI: sidebar, top bar, page routing for extension tab
lib/onboarding/web_onboarding_screen.dart
lib/web/chrome_storage_interop.dart      # JS interop for chrome.storage.local
lib/web/extension_settings.dart          # Extension mode (standalone/trackerOnly/hybrid) + per-domain metadata
lib/web/web_browser_data_provider.dart   # Reads scolect_day_* keys from chrome.storage
lib/web/web_location_helper.dart         # Hash routing, openDownloadUrl
lib/sections/UI sections/Browser/browser_extension_status.dart
lib/sections/UI sections/Browser/browser_extension_settings.dart
web/background.js                        # Chrome extension service worker
web/popup.js / popup.html               # Extension popup
web/blocked.html                         # Blocked site page
```

### Desktop ONLY
```
lib/onboarding/onboarding_screen.dart
lib/utils/browser_extension_server.dart  # HTTP server on :46000 for extension↔desktop IPC
lib/utils/mac_launch.dart
lib/utils/macos_window.dart
lib/utils/update_service.dart
lib/utils/single_instance_ipc.dart
lib/utils/screenstate_desktop.dart
lib/utils/maintenance_service.dart
lib/foreground_window_plugin_desktop.dart
lib/foreground_window_plugin_windows.dart
lib/sections/controller/application_controller.dart
lib/sections/controller/analytics_xlsx_exporter.dart
lib/sections/controller/maintenance_service.dart
```

### Shared (render on both desktop and web)
```
lib/app_design.dart                      # Design tokens: colors, spacing, radius, animation durations
lib/sections/overview.dart
lib/sections/applications.dart
lib/sections/browser.dart                # Browser/website section (has kIsWeb branches)
lib/sections/focus_mode.dart
lib/sections/settings.dart
lib/sections/help.dart
lib/sections/alerts_limits.dart
lib/sections/reports.dart
lib/sections/controller/                 # All state management / business logic
lib/sections/UI sections/               # All UI components (except browser_extension_* which are web-only)
lib/sections/graphs/                     # Chart widgets
lib/l10n/                               # All localizations
lib/adaptive_fluent/                    # Fluent UI theme wrapper
```

### Conditional stubs (these are legitimate — not dead code)
Every web-only file in `lib/web/` has a `_stub.dart` counterpart used by desktop via `if (dart.library.io)`. Same for `foreground_window_plugin_stub.dart` and `screenstate_stub.dart`.

---

## Architecture patterns

**Platform branching — 3 ways it happens:**

1. **Conditional imports** (compile-time, preferred):
   ```dart
   import 'package:screentime/web/chrome_storage_interop.dart'
       if (dart.library.io) 'package:screentime/web/chrome_storage_interop_stub.dart';
   ```

2. **`kIsWeb` runtime checks** (for UI branching within shared widgets):
   ```dart
   if (kIsWeb) { /* extension UI */ } else { /* desktop UI */ }
   ```

3. **`Platform.isWindows` / `Platform.isMacOS`** (desktop-only, inside `if (!kIsWeb)` guards):
   Use `PlatformUtils` from `lib/utils/platform_utils.dart` — it handles the web-safe check.

**State management:** Provider throughout. Key providers:
- `ThemeCustomizationProvider` — custom theme (accent colors, etc.)
- `NavigationState` — which sidebar section is active
- `SettingsProvider` — settings values for reactive UI

**Storage:**
- Desktop: Hive boxes via `AppDataStore` (`lib/sections/controller/app_data_controller.dart`)
- Web: `chrome.storage.local` via `ChromeStorageInterop`
- Settings (both): `SharedPreferences` via `SettingsManager` (`lib/sections/controller/settings_data_controller.dart`)

**Localization:** All UI strings go through `AppLocalizations.of(context)`. Source of truth is `lib/l10n/app_en.arb`. The `.dart` files in `lib/l10n/` are generated — edit the `.arb` files to change strings, then run `flutter gen-l10n`. **Exception:** the `_en.dart`, `_fr.dart` etc. files were hand-edited here since gen-l10n wasn't being run — treat them as the source.

---

## When making changes — how to identify the right file

| "Change X in the..." | Look in... |
|---|---|
| Extension popup (click the toolbar icon) | `web/popup.js`, `web/popup.html` |
| Extension dashboard shell (sidebar, title bar) | `lib/sections/web_dashboard.dart` |
| Extension background tracking logic | `web/background.js` |
| Browser websites tab (shown in both desktop and extension) | `lib/sections/UI sections/Browser/browser_websites.dart` |
| Extension-only settings (mode switcher) | `lib/sections/UI sections/Browser/browser_extension_settings.dart` |
| Desktop sidebar / navigation | `lib/main.dart` (desktop `HomePage`) |
| Shared settings page | `lib/sections/settings.dart` + `lib/sections/UI sections/Settings/` |
| Any localized string | `lib/l10n/app_localizations_en.dart` (and mirror to other `_xx.dart` files) |
| Design tokens (colors, spacing, radius) | `lib/app_design.dart` |

---

## Extension ↔ Desktop sync

- Desktop runs an HTTP server on port 46000 (`browser_extension_server.dart`)
- Background service worker (`background.js`) POSTs usage data to `http://localhost:46000/usage`
- Extension mode `hybrid` or `trackerOnly` enables this sync
- Port is configurable via `browserServerPort` setting

---

## Key things to NOT confuse

- **`lib/sections/applications.dart`** = the desktop "Applications" tab showing native app screen time. NOT the browser extension "Websites" list.
- **`lib/sections/browser.dart`** = the desktop "Browser" section that shows a summary of browser data synced FROM the extension. NOT the extension's own dashboard.
- **`lib/sections/web_dashboard.dart`** = the full-page Flutter UI loaded when the extension opens its dashboard tab. This is the extension's "app shell", not related to the desktop sidebar.
- **`web/background.js`** = Chrome extension service worker (vanilla JS). NOT a Flutter file.
- **`AppDesign`** (dynamic, needs context) vs **`AppDesignLegacy`** (static constants, no context needed) — both in `lib/app_design.dart`.
