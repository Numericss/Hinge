#!/bin/bash
# Produce the Gumroad customer archive: Developer ID sign → notarytool → staple → ZIP.
#
# Prerequisites (Mac + Apple Developer account):
#   1. Full Xcode installed; `xcode-select -p` points at it.
#   2. Developer ID Application certificate installed in the keychain.
#      List with: security find-identity -v -p codesigning
#   3. notarytool keychain profile created once:
#      xcrun notarytool store-credentials 'PROFILE_NAME' \
#        --apple-id 'APPLE_ID' --team-id 'TEAMID' --password 'app-specific-password'
#   4. Do not commit certificates, passwords, or profiles to git.
#
# Usage:
#   export HINGE_SIGNING_IDENTITY='Developer ID Application: Your Name (TEAMID)'
#   export HINGE_NOTARY_PROFILE='your-keychain-profile'
#   export HINGE_SUPPORT_EMAIL='you@example.com'   # recommended; embeds Support mailto
#   ./scripts/package-release.sh
#
# Output (only written after notarization + staple + Gatekeeper assess succeed):
#   build/distribution/Hinge-3.0.0.zip
#   build/distribution/Hinge-3.0.0.zip.sha256
#
# Failures: missing env, non–Developer ID identity, or notary/staple/spctl errors
# exit non-zero and leave no customer ZIP (previous archive is removed first).
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -z "${HINGE_SIGNING_IDENTITY:-}" ]]; then
  echo 'HINGE_SIGNING_IDENTITY is required.' >&2
  echo "Example: export HINGE_SIGNING_IDENTITY='Developer ID Application: Your Name (TEAMID)'" >&2
  echo 'List identities: security find-identity -v -p codesigning' >&2
  exit 1
fi
if [[ -z "${HINGE_NOTARY_PROFILE:-}" ]]; then
  echo 'HINGE_NOTARY_PROFILE is required (notarytool keychain profile name).' >&2
  echo "Create one: xcrun notarytool store-credentials 'PROFILE_NAME' --apple-id … --team-id … --password …" >&2
  echo "Then: export HINGE_NOTARY_PROFILE='PROFILE_NAME'" >&2
  exit 1
fi
if [[ "$HINGE_SIGNING_IDENTITY" != 'Developer ID Application:'* ]]; then
  echo 'A Developer ID Application identity is required for customer packaging.' >&2
  echo "HINGE_SIGNING_IDENTITY must start with 'Developer ID Application:'." >&2
  echo "Got: $HINGE_SIGNING_IDENTITY" >&2
  exit 1
fi

# Confirm the identity exists in the keychain before spending time on a full build.
if ! security find-identity -v -p codesigning | grep -F "$HINGE_SIGNING_IDENTITY" >/dev/null; then
  echo "Signing identity not found in the keychain:" >&2
  echo "  $HINGE_SIGNING_IDENTITY" >&2
  echo 'Install your Developer ID Application certificate, then re-run.' >&2
  security find-identity -v -p codesigning >&2 || true
  exit 1
fi

# Confirm the notary profile responds before building (avoids a long build then fail).
if ! xcrun notarytool history --keychain-profile "$HINGE_NOTARY_PROFILE" >/dev/null 2>&1; then
  echo "notarytool could not use keychain profile '$HINGE_NOTARY_PROFILE'." >&2
  echo 'Create or fix the profile with: xcrun notarytool store-credentials …' >&2
  echo 'Do not put Apple ID passwords or API keys in this repository.' >&2
  exit 1
fi

export HINGE_OUTPUT_DIR="${HINGE_OUTPUT_DIR:-$HOME/Library/Caches/Hinge/build}"
APP="$HINGE_OUTPUT_DIR/Hinge.app"
mkdir -p build/distribution
ARCHIVE="$PWD/build/distribution/Hinge-3.0.0.zip"
# Remove a previous archive so a failed submission cannot leave an old customer ZIP.
rm -f "$ARCHIVE" "$ARCHIVE.sha256"

printf 'Building and signing with Developer ID…\n'
./build.sh

printf 'Submitting to Apple notary service (profile: %s)…\n' "$HINGE_NOTARY_PROFILE"
SUBMISSION="$HINGE_OUTPUT_DIR/Hinge-notary-submission.zip"
rm -f "$SUBMISSION"
ditto -c -k --keepParent "$APP" "$SUBMISSION"
xcrun notarytool submit "$SUBMISSION" --keychain-profile "$HINGE_NOTARY_PROFILE" --wait
xcrun stapler staple "$APP"
xcrun stapler validate "$APP"
spctl --assess --type execute --verbose=2 "$APP"
ditto -c -k --keepParent "$APP" "$ARCHIVE"
shasum -a 256 "$ARCHIVE" > "$ARCHIVE.sha256"
rm -f "$SUBMISSION"
printf 'Customer archive: %s\n' "$ARCHIVE"
printf 'Checksum:         %s\n' "$ARCHIVE.sha256"
if [[ -z "${HINGE_SUPPORT_EMAIL:-}" ]]; then
  printf 'Note: HINGE_SUPPORT_EMAIL was unset; About will omit Contact support for this build.\n' >&2
fi
