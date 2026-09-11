#!/bin/bash
# Customer archives are produced only after Developer ID signing and notarization.
set -euo pipefail
cd "$(dirname "$0")/.."
: "${HINGE_SIGNING_IDENTITY:?Set a Developer ID Application signing identity}"
: "${HINGE_NOTARY_PROFILE:?Set your notarytool keychain profile name}"
[[ "$HINGE_SIGNING_IDENTITY" == 'Developer ID Application:'* ]] || { echo 'A Developer ID Application identity is required.' >&2; exit 1; }
export HINGE_OUTPUT_DIR="${HINGE_OUTPUT_DIR:-$HOME/Library/Caches/Hinge/build}"
APP="$HINGE_OUTPUT_DIR/Hinge.app"
mkdir -p build/distribution
ARCHIVE="$PWD/build/distribution/Hinge-2.0.0.zip"
# Remove a previous archive so a failed submission cannot leave an old customer ZIP.
rm -f "$ARCHIVE"
./build.sh
SUBMISSION="$HINGE_OUTPUT_DIR/Hinge-notary-submission.zip"
ditto -c -k --keepParent "$APP" "$SUBMISSION"
xcrun notarytool submit "$SUBMISSION" --keychain-profile "$HINGE_NOTARY_PROFILE" --wait
xcrun stapler staple "$APP"
xcrun stapler validate "$APP"
spctl --assess --type execute --verbose=2 "$APP"
ditto -c -k --keepParent "$APP" "$ARCHIVE"
shasum -a 256 "$ARCHIVE" > "$ARCHIVE.sha256"
printf 'Customer archive: %s\n' "$ARCHIVE"
