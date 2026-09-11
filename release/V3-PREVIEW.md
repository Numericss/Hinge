# Hinge 3.0.0 development preview

This update adds a menu-bar control panel; named preset creation, renaming, and deletion; battery-aware performance modes; optional pausing for chosen foreground applications or connected external displays; guided setup; optional launch at login; and local diagnostics export.

Existing favorites migrate into the named preset library. Automatic pause rules preserve the enabled preference, and manual Pause prevents automatic resumption. Launch at login does not enable desktop capture. Diagnostics are saved locally and omit excluded app names and identifiers.

## Validation

- All 42 automated tests passed with full Xcode, including preset migration, persistence, frame/capture limits, manual-pause precedence, and diagnostic privacy.
- Offscreen Metal checks passed for all five effects, including exact open/reopen frames, reduced motion, and cached-source freshness. This excludes screen capture and window composition.
- Release build completed; bundle version is 3.0.0 (300).
- Interactive native UI verification remains incomplete because the computer-use bridge repeatedly disconnected. Launch-at-login approval, actual lid movement, Screen Recording, and external-display transitions still require live validation.
- Performance modes enforce limits; battery savings and navigation latency have not been benchmarked on hardware.

The DMG is an ad-hoc-signed evaluation build. Developer ID signing, Apple notarization, and successful live-use validation are required before replacing the paid customer download.
