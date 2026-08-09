#!/bin/bash

# Exit on any error
set -e

# Ensure pub cache bin is in PATH for global CLI tools like flutter_distributor
export PATH="$HOME/.pub-cache/bin:$PATH"

MAIN_DART="lib/main.dart"

# Clean up / revert autoUpdates flag back to false when script finishes or exits on error
cleanup() {
    echo "🧹 Restoring autoUpdates = false in $MAIN_DART..."
    sed -i '' 's/const bool autoUpdates = true;/const bool autoUpdates = false;/' "$MAIN_DART" 2>/dev/null || true
}
trap cleanup EXIT

# 1. Enable autoUpdates in lib/main.dart for the release build
echo "🔧 Setting autoUpdates = true in $MAIN_DART for release build..."
sed -i '' 's/const bool autoUpdates = false;/const bool autoUpdates = true;/' "$MAIN_DART"

# 2. Get version from pubspec.yaml
VERSION=$(grep '^version: ' pubspec.yaml | sed 's/version: //' | cut -d '+' -f 1)
echo "🚀 Starting release process for version $VERSION..."

# Ensure target output directory exists
mkdir -p "dist/$VERSION"

# 3. Build and Notarize the DMG
echo "📦 Building DMG..."
dart run dmg

# 4. Preserve the built DMG before flutter_distributor cleans/rebuilds
SOURCE_DMG="./build/macos/Build/Products/Release/Scolect.dmg"
DEST_DMG="dist/$VERSION/screentime-$VERSION-macos.dmg"

if [ -f "$SOURCE_DMG" ]; then
    echo "📂 Copying DMG to $DEST_DMG"
    cp "$SOURCE_DMG" "$DEST_DMG"
else
    echo "❌ Error: Could not find generated DMG file at $SOURCE_DMG"
    exit 1
fi

# 5. Build the macOS ZIP using flutter_distributor
echo "🗜️ Generating macOS ZIP..."
if ! command -v flutter_distributor &> /dev/null; then
    echo "Installing flutter_distributor..."
    dart pub global activate flutter_distributor
    export PATH="$HOME/.pub-cache/bin:$PATH"
fi
flutter_distributor release --name prod --jobs macos-zip

# 6. Locate the generated ZIP file (flutter_distributor places it in dist/$VERSION/)
ZIP_FILE="dist/$VERSION/screentime-$VERSION-macos.zip"

if [ ! -f "$ZIP_FILE" ]; then
    # Fallback search inside dist/
    ZIP_FILE=$(find dist -name "*$VERSION*.zip" | head -n 1)
fi

if [ -f "$ZIP_FILE" ]; then
    echo "📂 Found generated ZIP file: $ZIP_FILE"
else
    echo "❌ Error: Could not find generated ZIP file in dist/$VERSION"
    exit 1
fi

# 7. Sign the update and save/output the signature for appcast.xml
SIGNATURE_FILE="dist/$VERSION/signature.txt"
echo "✍️ Signing update for Sparkle..."
echo "--------------------------------------------------------------------------------"
dart run auto_updater:sign_update "$ZIP_FILE" | tee "$SIGNATURE_FILE"
echo "--------------------------------------------------------------------------------"
echo "📄 Signature saved to: $SIGNATURE_FILE"

echo "✅ Done! Your signed release files are ready in dist/$VERSION:"
echo "   DMG:       $DEST_DMG"
echo "   ZIP:       $ZIP_FILE"
echo "   Signature: $SIGNATURE_FILE"


