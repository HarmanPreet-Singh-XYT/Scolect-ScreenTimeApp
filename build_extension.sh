#!/bin/bash
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Scolect – Build Chrome Extension"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Build Flutter Web with CSP mode (required for Chrome extensions)
echo ""
echo "▶ Building Flutter Web (--csp)..."
flutter build web --csp

# 2. Patch base href to use relative paths (required for extension pages)
echo "▶ Patching base href..."
sed -i '' 's|<base href="/">|<base href="./">|g' build/web/index.html

# 3. Update the title in index.html
echo "▶ Updating index.html title..."
sed -i '' 's|<title>screentime</title>|<title>Scolect – Web Time Tracker</title>|g' build/web/index.html

# 4. Disable Flutter service worker (MV3 extensions don't allow inline workers)
echo "▶ Disabling flutter service worker and adding local CanvasKit config..."
sed -i '' 's/serviceWorkerSettings: {/serviceWorkerSettings: null, oldServiceWorker: {/g' build/web/flutter_bootstrap.js
# Inject canvasKitBaseUrl config parameter
sed -i '' 's/serviceWorkerVersion: "\([0-9]*\)"/serviceWorkerVersion: "\1" }, config: { canvasKitBaseUrl: "canvaskit\/"/g' build/web/flutter_bootstrap.js

# 5. Force local CanvasKit (MV3 extensions cannot load external scripts from CDN)
echo "▶ Forcing local CanvasKit in buildConfig..."
sed -i '' 's/"engineRevision"/"useLocalCanvasKit":true,"engineRevision"/g' build/web/flutter_bootstrap.js

# 6. Cache-bust by renaming bootstrap script
echo "▶ Cache-busting bootstrap script..."
mv build/web/flutter_bootstrap.js build/web/flutter_bootstrap_v4.js
sed -i '' 's/flutter_bootstrap.js/flutter_bootstrap_v4.js/g' build/web/index.html

# 7. The output IS the extension — no copying needed
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " ✅ Done! Load the extension in Chrome:"
echo ""
echo "  1. Open chrome://extensions"
echo "  2. Enable 'Developer mode' (top right)"
echo "  3. Click 'Load unpacked'"
echo "  4. Select:  $(pwd)/build/web"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
