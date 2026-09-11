# Hinge

Project repository: [Numericss/Hinge](https://github.com/Numericss/Hinge).

A native macOS desktop-effects app that responds to a compatible MacBook lid sensor. Working product name; version 0.1.0 is a development preview, not yet a customer release.

## Our version

- Five inherited Swift + Metal effects: Duo, Roll, Shutter, Flex, and Iris.
- New Subtle, Cinematic, and Crisp motion presets.
- New personal preset saved locally across launches.
- New calibration to your normal working lid angle.
- New teal visual identity, original geometric icon, and in-app attribution.
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

Open **Motion studio** for presets, personal settings, and calibration. Use **Replay** to try the generated preview. Enable Hinge only when ready to grant screen access. Esc and Control–Option–Command–F pause the desktop overlay.

## Release

See [the release checklist](release/CHECKLIST.md), [Gumroad listing draft](release/GUMROAD.md), and [development notes](docs/DEVELOPMENT.md). The customer packaging command is:

```sh
HINGE_SIGNING_IDENTITY='Developer ID Application: Your Name (TEAMID)' \
HINGE_NOTARY_PROFILE='your-keychain-profile' ./scripts/package-release.sh
```

## Credits and license

Hinge is a modified distribution of [MacDuo](https://github.com/DhananjayBhosale/MacDuo), copyright 2026 Mac Duo contributors, licensed under MIT. Its core rendering, capture, and sensor implementation are inherited. The license and attribution are retained in the repository and bundled app. See [LICENSE](LICENSE) and [ATTRIBUTION.md](ATTRIBUTION.md). Independent software, not affiliated with Apple or the upstream authors.
