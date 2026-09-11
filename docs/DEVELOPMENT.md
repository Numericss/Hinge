# Hinge development

Run `swift test`, `./build.sh`, and `"$HOME/Library/Caches/Hinge/build/Hinge.app/Contents/MacOS/Hinge" --render-check validation` from the repository root. Metal checks render synthetic artwork and require a working GPU session. They do not request Screen Recording.

`Sources/FoldCore` contains effect metadata, math, stillness/frame pacing, and the new serializable motion preset type. `Sources/Hinge` contains the inherited sensor/capture/Metal implementation and native controls. `StudioSettings.swift` is the new preset/calibration interface.

The application uses `com.datalynlabs.hinge.mac` as its working bundle identity. Confirm it before initial distribution; changing it later can affect stored preferences and Screen Recording permission. No upstream preferences are migrated.

Saving a preset writes to UserDefaults. Loading one clamps rendering values and never enables capture. Calibration accepts only a current sensor reading in the supported 60–140 degree interval. All enablement remains an explicit user action.

`./build.sh` creates `~/Library/Caches/Hinge/build/Hinge.app` and includes both LICENSE and ATTRIBUTION.md. `scripts/package-release.sh` requires a Developer ID Application identity and notarytool profile; it produces a customer ZIP only after notarization, stapling, and Gatekeeper assessment.

The upstream source history is retained, and the source remote is named `upstream`. No seller repository has been configured. See ATTRIBUTION.md for inherited research notes and license provenance.
