# Hinge

Project repository: [Numericss/Hinge](https://github.com/Numericss/Hinge).

A native macOS desktop-effects app that responds to a compatible MacBook lid sensor. Working product name; version 2.0.0 is a development preview, not yet a customer release.

## Version 2.0

- Five inherited Swift + Metal effects: Duo, Roll, Shutter, Flex, and Iris.
- New Subtle, Cinematic, and Crisp motion presets.
- New personal preset saved locally across launches.
- New calibration to your normal working lid angle.
- Native sidebar with Effects, Motion, and Setup & Help pages.
- Larger effect choices, one-click replay, a stoppable preview, and readable persistent status.
- Teal visual identity, original geometric icon, and in-app attribution.
- Desktop tests return to their prior on/off state; saved settings are validated on launch.
- Independent app identity and preferences so it can coexist with MacDuo.
- Developer ID signing and notarization packaging script for direct distribution.

Requires macOS 14+, Apple silicon, and a compatible MacBook lid sensor for automatic effects. External displays are not animated. A generated-artwork preview works without Screen Recording permission; animating the real desktop requires permission. No account, analytics, or network service is added. Frames remain in memory on the Mac.

## Build and test

```sh
swift test
./build.sh
open "$HOME/Library/Caches/Hinge/build/Hinge.app"
"$HOME/Library/Caches/Hinge/build/Hinge.app/Contents/MacOS/Hinge" --render-check validation
```

Tests require a full Xcode installation. If your active toolchain is Command Line Tools, run with `DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer` (adjust for your Xcode location).

Signed app bundles are built in `~/Library/Caches/Hinge/build` to avoid file-provider metadata in synced Documents folders. Override with `HINGE_OUTPUT_DIR` if needed.

The default build is ad-hoc signed for local preview. Use `HINGE_SIGNING_IDENTITY` to select a signing identity. Do not upload the preview build as a finished paid download.

Open **Motion** for presets, your favorite setup, and calibration. **Effects** provides one-click selection and replay. **Setup & Help** explains permissions and the temporary desktop test. Manual preview changes the preview only; Pause Hinge controls the actual desktop. Enable Hinge only when ready to grant screen access. Esc and Control–Option–Command–F pause the desktop overlay.

## Release

See [the release checklist](release/CHECKLIST.md), [Gumroad listing draft](release/GUMROAD.md), and [development notes](docs/DEVELOPMENT.md). The customer packaging command is:

```sh
HINGE_SIGNING_IDENTITY='Developer ID Application: Your Name (TEAMID)' \
HINGE_NOTARY_PROFILE='your-keychain-profile' ./scripts/package-release.sh
```

## Credits and license

Hinge is a modified distribution of [MacDuo](https://github.com/DhananjayBhosale/MacDuo), copyright 2026 Mac Duo contributors, licensed under MIT. Its core rendering, capture, and sensor implementation are inherited. The license and attribution are retained in the repository and bundled app. See [LICENSE](LICENSE) and [ATTRIBUTION.md](ATTRIBUTION.md). Independent software, not affiliated with Apple or the upstream authors.
