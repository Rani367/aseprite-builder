#!/bin/bash
# Automatically update Aseprite to the latest version
# Usage: ./update-aseprite.sh

set -e

DOWNLOAD_DIR="$HOME/Downloads"
REPO="aseprite/aseprite"

# Get installed version
if [ -f /Applications/Aseprite.app/Contents/MacOS/aseprite ]; then
    INSTALLED=$(/Applications/Aseprite.app/Contents/MacOS/aseprite --version 2>&1 | head -1 | sed 's/Aseprite //' | sed 's/-dev//')
else
    INSTALLED="none"
fi
echo "Installed version: $INSTALLED"

# Get latest release from GitHub
echo "Checking GitHub for latest release..."
LATEST_JSON=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")
SOURCE_FILENAME=$(echo "$LATEST_JSON" | grep '"name":' | grep 'Source.zip' | sed -E 's/.*"(Aseprite-v[^"]+Source\.zip)".*/\1/' | head -1)
LATEST=$(echo "$SOURCE_FILENAME" | sed -E 's/Aseprite-v([0-9.]+)-Source\.zip/\1/')
DOWNLOAD_URL=$(echo "$LATEST_JSON" | grep '"browser_download_url":' | grep 'Source.zip' | sed -E 's/.*"([^"]+)".*/\1/')

echo "Latest version: $LATEST"

# Compare versions
if [ "$INSTALLED" = "$LATEST" ]; then
    echo "Already up to date!"
    exit 0
fi

echo "Update available: $INSTALLED -> $LATEST"
echo ""

# Download
SOURCE_ZIP="$DOWNLOAD_DIR/Aseprite-v${LATEST}-Source.zip"
SOURCE_DIR="$DOWNLOAD_DIR/Aseprite-v${LATEST}-Source"

if [ ! -f "$SOURCE_ZIP" ]; then
    echo "Downloading $DOWNLOAD_URL..."
    curl -L -o "$SOURCE_ZIP" "$DOWNLOAD_URL"
else
    echo "Source zip already downloaded."
fi

# Unzip (overwrite without prompting)
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Extracting..."
    unzip -q -o "$SOURCE_ZIP" -d "$DOWNLOAD_DIR"
else
    echo "Source already extracted."
fi

# Build
echo "Building Aseprite..."
cd "$SOURCE_DIR"
./build.sh --auto --norun

# Copy to Applications
echo "Installing to Applications..."
rm -rf /Applications/Aseprite.app
cp -r "$SOURCE_DIR/build/bin/Aseprite.app" /Applications/

# Create icon
echo "Creating app icon..."
ICONS="$SOURCE_DIR/data/icons"
ICONSET="/tmp/Aseprite.iconset"
rm -rf "$ICONSET"
mkdir -p "$ICONSET"

cp "$ICONS/ase16.png" "$ICONSET/icon_16x16.png"
cp "$ICONS/ase32.png" "$ICONSET/icon_16x16@2x.png"
cp "$ICONS/ase32.png" "$ICONSET/icon_32x32.png"
cp "$ICONS/ase64.png" "$ICONSET/icon_32x32@2x.png"
cp "$ICONS/ase128.png" "$ICONSET/icon_128x128.png"
cp "$ICONS/ase256.png" "$ICONSET/icon_128x128@2x.png"
cp "$ICONS/ase256.png" "$ICONSET/icon_256x256.png"
sips -z 512 512 "$ICONS/ase256.png" --out "$ICONSET/icon_256x256@2x.png" >/dev/null
sips -z 512 512 "$ICONS/ase256.png" --out "$ICONSET/icon_512x512.png" >/dev/null
sips -z 1024 1024 "$ICONS/ase256.png" --out "$ICONSET/icon_512x512@2x.png" >/dev/null

iconutil -c icns "$ICONSET" -o /Applications/Aseprite.app/Contents/Resources/Aseprite.icns
rm -rf "$ICONSET"

# Refresh Finder
touch /Applications/Aseprite.app
killall Finder 2>/dev/null || true

# Clean up old source files (keep current version)
echo "Cleaning up old versions..."
find "$DOWNLOAD_DIR" -maxdepth 1 -name "Aseprite-v*-Source" -type d ! -name "Aseprite-v${LATEST}-Source" -exec rm -rf {} \; 2>/dev/null || true
find "$DOWNLOAD_DIR" -maxdepth 1 -name "Aseprite-v*-Source.zip" ! -name "Aseprite-v${LATEST}-Source.zip" -exec rm {} \; 2>/dev/null || true

echo ""
echo "Done! Aseprite $LATEST installed."
open /Applications/Aseprite.app
