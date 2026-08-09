#!/bin/bash
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Scolect – Build Browser Extension (Chrome & Firefox)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Build Flutter Web with CSP mode (required for MV3 extensions)
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

# 6. Generate extension ZIP archive (for distribution or Firefox loading)
echo "▶ Creating extension ZIP archive..."
rm -f build/scolect-extension.zip
(cd build/web && zip -q -r ../scolect-extension.zip .)

# 7. Output loading instructions
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " ✅ Done! Load the extension in your browser:"
echo ""
echo "  ▶ Chrome / Edge / Brave:"
echo "     1. Open chrome://extensions"
echo "     2. Enable 'Developer mode' (top right)"
echo "     3. Click 'Load unpacked'"
echo "     4. Select:  $(pwd)/build/web"
echo ""
echo "  ▶ Firefox (Mozilla):"
echo "     1. Open about:debugging#/runtime/this-firefox"
echo "     2. Click 'Load Temporary Add-on...'"
echo "     3. Select:  $(pwd)/build/web/manifest.json"
echo "        (or select: $(pwd)/build/scolect-extension.zip)"
echo ""
echo "  ⚠️ NOTE for Firefox:"
echo "     Do NOT drag the ZIP file into about:addons or standard Firefox settings!"
echo "     Firefox requires unsigned local extensions to be loaded via about:debugging."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
