#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
# SwiftUI macros and the test runtime require full Xcode, not standalone CLT.
if [[ -z "${DEVELOPER_DIR:-}" && "$(xcode-select -p)" == *CommandLineTools* ]]; then
  for candidate in /Applications/Xcode.app/Contents/Developer /Applications/Xcode-beta.app/Contents/Developer; do
    if [[ -d "$candidate" ]]; then export DEVELOPER_DIR="$candidate"; break; fi
  done
fi
BUILD_DIR="${HINGE_BUILD_DIR:-.build}"
IDENTITY="${HINGE_SIGNING_IDENTITY:--}"
swift build -c release --scratch-path "$BUILD_DIR"
BIN_DIR="$(swift build -c release --scratch-path "$BUILD_DIR" --show-bin-path)"
swift scripts/make-icon.swift Resources
iconutil -c icns Resources/Hinge.iconset -o Resources/Hinge.icns
# Keep signed bundles outside synced Documents folders, whose file-provider
# metadata can invalidate strict code-signature checks after a successful build.
OUTPUT_DIR="${HINGE_OUTPUT_DIR:-$HOME/Library/Caches/Hinge/build}"
mkdir -p "$OUTPUT_DIR"
APP="$OUTPUT_DIR/Hinge.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/Hinge" "$APP/Contents/MacOS/Hinge"
xcrun strip -S "$APP/Contents/MacOS/Hinge"
cp Resources/HingeMark.png Resources/Hinge.icns LICENSE ATTRIBUTION.md "$APP/Contents/Resources/"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>Hinge</string>
<key>CFBundleDisplayName</key><string>Hinge</string>
<key>CFBundleIdentifier</key><string>com.datalynlabs.hinge.mac</string>
<key>CFBundleExecutable</key><string>Hinge</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleIconFile</key><string>Hinge</string>
<key>CFBundleShortVersionString</key><string>2.0.1</string>
<key>CFBundleVersion</key><string>201</string>
<key>LSMinimumSystemVersion</key><string>14.0</string>
<key>LSUIElement</key><true/>
<key>NSHighResolutionCapable</key><true/>
<key>NSScreenCaptureUsageDescription</key><string>Hinge displays a temporary animated copy of your desktop as you move the lid. Frames stay in memory on this Mac.</string>
</dict></plist>
PLIST
xattr -cr "$APP"
if [[ "$IDENTITY" == "-" ]]; then
  codesign --force --sign - "$APP"
else
  codesign --force --options runtime --timestamp --sign "$IDENTITY" "$APP"
fi
codesign --verify --strict "$APP"
plutil -lint "$APP/Contents/Info.plist"
printf 'Built %s\n' "$APP"
