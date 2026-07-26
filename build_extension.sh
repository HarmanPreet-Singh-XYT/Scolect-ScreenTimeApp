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

# 4. Disable Flutter service worker & set CanvasKit path
echo "▶ Disabling flutter service worker and adding local CanvasKit config..."
BOOTSTRAP_JS=$(ls build/web/flutter_bootstrap*.js | head -n 1)

sed -i '' 's/serviceWorkerSettings: {/serviceWorkerSettings: null, oldServiceWorker: {/g' "$BOOTSTRAP_JS"
sed -i '' 's/serviceWorkerVersion: "\([0-9]*\)"/serviceWorkerVersion: "\1" }, config: { canvasKitBaseUrl: "canvaskit\/"/g' "$BOOTSTRAP_JS"

# 5. Force local CanvasKit (MV3 extensions cannot load external scripts from CDN)
echo "▶ Forcing local CanvasKit in buildConfig..."
sed -i '' 's/"engineRevision"/"useLocalCanvasKit":true,"engineRevision"/g' "$BOOTSTRAP_JS"

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
