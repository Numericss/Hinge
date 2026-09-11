#!/bin/bash
# Local evaluation disk image. Never represents a notarized customer release.
set -euo pipefail
cd "$(dirname "$0")/.."
APP="${HINGE_OUTPUT_DIR:-$HOME/Library/Caches/Hinge/build}/Hinge.app"
[[ -d "$APP" ]] || { echo 'Run ./build.sh first.' >&2; exit 1; }
VERSION="$(plutil -extract CFBundleShortVersionString raw -o - "$APP/Contents/Info.plist")"
[[ "$VERSION" == "3.0.0" ]] || { echo 'Expected Hinge 3.0.0. Rebuild or set HINGE_OUTPUT_DIR to the version 3 build.' >&2; exit 1; }
codesign --verify --strict "$APP"
mkdir -p build
STAGE="$(mktemp -d /tmp/hinge-dmg.XXXXXX)"
trap 'rm -rf "$STAGE"' EXIT
COPYFILE_DISABLE=1 ditto --norsrc "$APP" "$STAGE/Hinge.app"
ln -s /Applications "$STAGE/Applications"
cp LICENSE ATTRIBUTION.md "$STAGE/"
cat > "$STAGE/READ ME FIRST.txt" <<'TEXT'
Hinge 3.0.0 — DEVELOPMENT PREVIEW

Drag Hinge.app into Applications. Quit an older copy before replacing it.

This preview is ad-hoc signed and has NOT been notarized by Apple.
It is for evaluation, not the final paid Gumroad download. macOS may block
launch. A customer release will use Developer ID signing and notarization.

Requirements: Apple-silicon MacBook, macOS 14+, and a compatible lid-angle
sensor for automatic effects. External displays are not animated.

Replay previews generated artwork without screen access. Animating your
actual desktop requires Screen Recording permission. Frames remain in memory.
Esc or Control–Option–Command–F pauses the overlay.

Motion includes built-in and named presets plus calibration. Automation offers
performance modes, optional pause rules, and launch at login. The menu-bar
panel provides quick controls. Setup & Help exports diagnostics locally.
Hinge is based on MacDuo. See LICENSE and ATTRIBUTION.md for credits.
TEXT
codesign --verify --strict "$STAGE/Hinge.app"
hdiutil create -volname 'Hinge Preview' -srcfolder "$STAGE" -format UDZO -ov build/Hinge-3.0.0-preview.dmg
hdiutil verify build/Hinge-3.0.0-preview.dmg
shasum -a 256 build/Hinge-3.0.0-preview.dmg > build/Hinge-3.0.0-preview.dmg.sha256
