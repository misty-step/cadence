#!/bin/bash
# Build and run Tempo debug version as app bundle for testing
set -e

swift build --product Tempo

# Create minimal app bundle structure for debug
DEBUG_APP=".build/debug/Tempo-Dev.app"
rm -rf "$DEBUG_APP"
mkdir -p "$DEBUG_APP/Contents/MacOS"
mkdir -p "$DEBUG_APP/Contents/Resources"

# Copy binary
cp .build/debug/Tempo "$DEBUG_APP/Contents/MacOS/"

# Copy SPM resources bundle (fonts, etc.) — SPM puts resources flat in bundle root
RESOURCES_BUNDLE=".build/debug/Cadence_CadenceKit.bundle"
if [ -d "$RESOURCES_BUNDLE" ]; then
    find "$RESOURCES_BUNDLE" -maxdepth 1 -type f | while read -r f; do
        cp "$f" "$DEBUG_APP/Contents/Resources/"
    done
fi

# Create Info.plist
cat > "$DEBUG_APP/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Tempo</string>
    <key>CFBundleIdentifier</key>
    <string>dev.mistystep.tempo.debug</string>
    <key>CFBundleName</key>
    <string>Tempo-Dev</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

# Kill existing and launch
pkill -x Tempo 2>/dev/null || true
pkill -x Tempo-Dev 2>/dev/null || true
sleep 0.5

echo "Launching Tempo debug app..."
open "$DEBUG_APP"
