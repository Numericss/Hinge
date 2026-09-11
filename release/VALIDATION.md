# Preview validation — September 10, 2026

- Full Xcode toolchain: `/Applications/Xcode-beta.app/Contents/Developer`.
- Final bundle: `/Users/kevinrosarioi/Library/Caches/Hinge/build/Hinge.app`. Synced Documents output was replaced after file-provider metadata caused a later signature check to fail.
- Release app built successfully; ad-hoc signature verified and Info.plist passed validation.
- 19 inherited Swift Testing tests and 3 new XCTest tests passed (22 total).
- Offscreen Metal render checks passed using the packaged executable and generated pixels.
- Native UI inspected: main window and Motion studio fit without clipped controls.
- Cinematic selection, personal save, switching to Subtle, and restoring Cinematic verified through the UI. Main controls showed the restored Roll effect and 85%/75%/80% values.
- Live lid sensor detected; calibration set the clear angle to the observed 103 degrees.
- Replay entered its running state without enabling desktop capture.
- Shell syntax and git whitespace checks passed.

Not verified: cross-launch UI restore (serialization round trip is tested), real desktop capture/permission lifecycle, physical lid-driven overlay, multi-display/sleep behavior, clean customer install, notarization, or Gumroad checkout.

This is development-preview evidence, not certification of all macOS 14+ devices. The upstream render report retains its own test-suite version label.
