#!/bin/bash
# Build Cadence.app bundle from SwiftPM executable
# This embeds Info.plist into the binary for proper macOS app behavior

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/.build/release"
APP_NAME="Cadence"
APP_BUNDLE="$PROJECT_DIR/$APP_NAME.app"

# Create Info.plist in a temp location
TEMP_PLIST="/tmp/Cadence_Info.plist"
cat > "$TEMP_PLIST" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Cadence</string>
    <key>CFBundleDisplayName</key>
    <string>Cadence</string>
    <key>CFBundleIdentifier</key>
    <string>com.mistystep.cadence</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>Cadence</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSUserNotificationAlertStyle</key>
    <string>alert</string>
</dict>
</plist>
EOF

echo "Building release with embedded plist..."
# Build with the Info.plist embedded as a section in the binary
swift build -c release --package-path "$PROJECT_DIR" -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker "$TEMP_PLIST"

echo "Creating app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy executable
cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/"

# Copy Info.plist to bundle as well (for app discovery)
cp "$TEMP_PLIST" "$APP_BUNDLE/Contents/Info.plist"

echo "Signing app..."
# Ad-hoc sign the app with entitlements for notifications
cat > /tmp/Cadence.entitlements << 'ENTEOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.automation.apple-events</key>
    <true/>
</dict>
</plist>
ENTEOF

codesign --force --deep --sign - --entitlements /tmp/Cadence.entitlements "$APP_BUNDLE"

# Clean up
rm -f "$TEMP_PLIST" /tmp/Cadence.entitlements

echo "Done: $APP_BUNDLE"
echo "Run with: open $APP_BUNDLE"
