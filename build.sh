#!/bin/bash
# Build an ad-hoc (or optionally Developer ID–signed) Hinge.app for local use.
#
# Usage:
#   ./build.sh
#   HINGE_SIGNING_IDENTITY='Developer ID Application: Name (TEAMID)' ./build.sh
#   HINGE_SUPPORT_EMAIL='you@example.com' ./build.sh   # embeds Support mailto in About
#
# Customer / Gumroad archives must use scripts/package-release.sh (notarization).
# Do not upload an ad-hoc build as the paid download.
#
# Env:
#   HINGE_BUILD_DIR       Swift scratch path (default .build)
#   HINGE_OUTPUT_DIR      App bundle parent (default ~/Library/Caches/Hinge/build)
#   HINGE_SIGNING_IDENTITY  "-" (ad-hoc, default) or Developer ID Application: …
#   HINGE_SUPPORT_EMAIL   Optional; written to Info.plist HingeSupportEmail
#   DEVELOPER_DIR         Full Xcode developer directory when CLT is selected
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
SUPPORT_EMAIL="${HINGE_SUPPORT_EMAIL:-}"
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
# Escape XML special characters for optional support email in Info.plist.
SUPPORT_EMAIL_XML="$(printf '%s' "$SUPPORT_EMAIL" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e "s/'/\&apos;/g" -e 's/"/\&quot;/g')"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>Hinge</string>
<key>CFBundleDisplayName</key><string>Hinge</string>
<key>CFBundleIdentifier</key><string>com.datalynlabs.hinge.mac</string>
<key>CFBundleExecutable</key><string>Hinge</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleIconFile</key><string>Hinge</string>
<key>CFBundleShortVersionString</key><string>3.0.0</string>
<key>CFBundleVersion</key><string>300</string>
<key>LSMinimumSystemVersion</key><string>14.0</string>
<key>LSUIElement</key><true/>
<key>NSHighResolutionCapable</key><true/>
<key>NSScreenCaptureUsageDescription</key><string>Hinge displays a temporary animated copy of your desktop as you move the lid. Frames stay in memory on this Mac.</string>
<key>HingeSupportEmail</key><string>${SUPPORT_EMAIL_XML}</string>
</dict></plist>
PLIST
xattr -cr "$APP"
if [[ "$IDENTITY" == "-" ]]; then
  codesign --force --sign - "$APP"
else
  if [[ "$IDENTITY" != 'Developer ID Application:'* ]]; then
    echo "HINGE_SIGNING_IDENTITY must be ad-hoc (-) or start with 'Developer ID Application:'." >&2
    echo "Got: $IDENTITY" >&2
    exit 1
  fi
  codesign --force --options runtime --timestamp --sign "$IDENTITY" "$APP"
fi
codesign --verify --strict "$APP"
plutil -lint "$APP/Contents/Info.plist"
printf 'Built %s\n' "$APP"
if [[ -n "$SUPPORT_EMAIL" ]]; then
  printf 'Support email embedded: %s\n' "$SUPPORT_EMAIL"
else
  printf 'Support email not set (HINGE_SUPPORT_EMAIL). About will omit Contact support.\n'
fi
