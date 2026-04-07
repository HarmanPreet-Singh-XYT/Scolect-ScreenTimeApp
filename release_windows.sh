#!/bin/bash

# Exit on any error
set -e

# 1. Get version from pubspec.yaml
VERSION=$(grep '^version: ' pubspec.yaml | sed 's/version: //' | cut -d '+' -f 1)
echo "🚀 Starting Windows release process for version $VERSION..."

# 2. Build the Windows setup using flutter_distributor
echo "📦 Generating Windows Setup..."
flutter_distributor release --name prod --jobs windows-exe

# 3. Locate the generated executable and rename it
SOURCE_EXE=$(find dist/prod/windows-exe -name "*.exe" | head -n 1)
DEST_EXE="dist/screentime-$VERSION-windows-setup.exe"

if [ -f "$SOURCE_EXE" ]; then
    echo "📂 Moving $SOURCE_EXE to $DEST_EXE"
    mv "$SOURCE_EXE" "$DEST_EXE"
else
    echo "❌ Error: Could not find generated executable in dist/prod/windows-exe"
    exit 1
fi

# 4. Sign the update and print the signature for appcast.xml
echo "✍️ Signing update for WinSparkle..."
echo "--------------------------------------------------------------------------------"
dart run auto_updater:sign_update "$DEST_EXE"
echo "--------------------------------------------------------------------------------"

echo "✅ Done! Your signed release is ready at: $DEST_EXE"
