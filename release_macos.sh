#!/bin/bash

# Exit on any error
set -e

# 1. Get version from pubspec.yaml
VERSION=$(grep '^version: ' pubspec.yaml | sed 's/version: //' | cut -d '+' -f 1)
echo "🚀 Starting release process for version $VERSION..."

# 2. Build the DMG
echo "📦 Building DMG..."
dart run dmg

# 3. Build the macOS ZIP using flutter_distributor
echo "🗜️ Generating macOS ZIP..."
flutter_distributor release --name prod --jobs macos-zip

# 4. Locate the generated zip and rename it
# flutter_distributor usually outputs to dist/prod/<job-name>/<app-name>-<version>-macos.zip
SOURCE_ZIP=$(find dist/prod/macos-zip -name "*.zip" | head -n 1)
DEST_ZIP="dist/screentime-$VERSION-macos.zip"

if [ -f "$SOURCE_ZIP" ]; then
    echo "📂 Moving $SOURCE_ZIP to $DEST_ZIP"
    mv "$SOURCE_ZIP" "$DEST_ZIP"
else
    echo "❌ Error: Could not find generated ZIP file in dist/prod/macos-zip"
    exit 1
fi

# 5. Sign the update and print the signature for appcast.xml
echo "✍️ Signing update for Sparkle..."
echo "--------------------------------------------------------------------------------"
dart run auto_updater:sign_update "$DEST_ZIP"
echo "--------------------------------------------------------------------------------"

echo "✅ Done! Your signed release is ready at: $DEST_ZIP"
