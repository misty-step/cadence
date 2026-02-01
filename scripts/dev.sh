#!/bin/bash
# Build and run debug version as app bundle for testing
set -e

swift build

# Create minimal app bundle structure for debug
DEBUG_APP=".build/debug/Cadence-Dev.app"
rm -rf "$DEBUG_APP"
mkdir -p "$DEBUG_APP/Contents/MacOS"

# Copy binary
cp .build/debug/Cadence "$DEBUG_APP/Contents/MacOS/"

# Create Info.plist
cat > "$DEBUG_APP/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Cadence</string>
    <key>CFBundleIdentifier</key>
    <string>dev.mistystep.cadence.debug</string>
    <key>CFBundleName</key>
    <string>Cadence-Dev</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

# Kill existing and launch
pkill -x Cadence 2>/dev/null || true
pkill -x Cadence-Dev 2>/dev/null || true
sleep 0.5

echo "Launching debug app..."
open "$DEBUG_APP"
