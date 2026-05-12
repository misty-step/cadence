#!/bin/bash
# Build Tempo.app bundle from SwiftPM executable
# This embeds Info.plist into the binary for proper macOS app behavior

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/.build/release"
APP_NAME="Tempo"
APP_BUNDLE="$PROJECT_DIR/$APP_NAME.app"

TEMP_PLIST="/tmp/Tempo_Info.plist"
cat > "$TEMP_PLIST" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Tempo</string>
    <key>CFBundleDisplayName</key>
    <string>Tempo</string>
    <key>CFBundleIdentifier</key>
    <string>com.mistystep.tempo</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>Tempo</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSUserNotificationAlertStyle</key>
    <string>alert</string>
</dict>
</plist>
EOF

echo "Building release with embedded plist..."
swift build -c release --package-path "$PROJECT_DIR" --product Tempo -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker "$TEMP_PLIST"

echo "Creating app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/"

RESOURCES_BUNDLE="$PROJECT_DIR/.build/release/Cadence_CadenceKit.bundle"
if [ -d "$RESOURCES_BUNDLE" ]; then
    find "$RESOURCES_BUNDLE" -maxdepth 1 -type f | while read -r f; do
        cp "$f" "$APP_BUNDLE/Contents/Resources/"
    done
fi

cp "$TEMP_PLIST" "$APP_BUNDLE/Contents/Info.plist"

echo "Signing app..."
cat > /tmp/Tempo.entitlements << 'ENTEOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.automation.apple-events</key>
    <true/>
</dict>
</plist>
ENTEOF

codesign --force --deep --sign - --entitlements /tmp/Tempo.entitlements "$APP_BUNDLE"

rm -f "$TEMP_PLIST" /tmp/Tempo.entitlements

echo "Done: $APP_BUNDLE"
echo "Run with: open $APP_BUNDLE"
