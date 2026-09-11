# Version 2.0.0 preview validation

## Passed

- Full Xcode build targeting macOS 14+: release executable built successfully.
- 32 tests: 19 FoldCore Swift Testing tests, 3 preset serialization/validation tests, and 10 app-model tests.
- New coverage: temporary tests restore prior enablement; preview stopping preserves desktop state; motion reset preserves effect/favorite; saved visual parameters are clamped on launch.
- Offscreen Metal checks passed with the version 2 executable. Reports in validation-v2 retain the inherited render-suite version label 0.1.5.
- Initial native Effects window launched and was inspected using accessibility and a screenshot. The screenshot revealed an oversized preview; final code caps its height at 250 points and removes the cramped picker label.
- Final release executable and app bundle built and signature verified.
- DMG checksum verified. Disk image mounted read-only; bundled app signature, version 2.0.0/build 200, license, and Applications shortcut verified, then detached.
- Shell syntax and git whitespace checks passed.

## Remaining verification

The native inspection service repeatedly returned “Sky Computer Use native pipe closed before response.” Resetting the inspection session did not provide a sustained connection. The app process remained running, with no Hinge crash report found during that check.

Final interactive review of Motion and Setup pages, light appearance, smallest window geometry, and the final preview-height adjustment remains outstanding. Physical lid-driven desktop capture, permission grant/deny/revoke, sleep/wake, and a clean install on another Mac also remain unverified for this build.

This DMG is an ad-hoc signed development preview. Developer ID signing and notarization are still required for the intended customer release. The existing version 0.1 promotional artwork is labeled as outdated for this interface.
