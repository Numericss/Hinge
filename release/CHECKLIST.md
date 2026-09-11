# Hinge release checklist

## Completed in the code

- Independent app name, bundle identifier, preferences, and icon.
- Presets, local personal-preset persistence, and live-angle calibration.
- Upstream MIT license and credits included in the app bundle.
- Developer ID signing, hardened runtime, notarization submission, stapling, and archive script.
- Gumroad product-copy draft.

## Required before taking payment

- Confirm final product name, bundle identifier, seller identity, price, and support details.
- Obtain a Developer ID Application certificate and a working notarytool keychain profile.
- Build and notarize via scripts/package-release.sh; verify the ZIP on another Mac.
- Test actual lid motion and Screen Recording grant/deny/revoke on supported hardware.
- Verify Esc/global pause, sleep/wake, switching Spaces, external displays, sensor loss, and reduced-motion behavior with real capture.
- Check presets, saving/restoring after relaunch, and calibration on the packaged build.
- Capture Hinge-specific screenshots and demo footage; do not reuse upstream marketing media.
- Record verified hardware and macOS versions. Upstream's hardware claims are not Hinge verification.
- Upload the notarized archive and finished listing to the seller's Gumroad account, then review checkout/delivery.

The local preview is not notarized. Passing unit and offscreen Metal tests does not prove live-camera/lid compatibility, real screen-capture permission behavior, battery impact, or customer installation behavior.
