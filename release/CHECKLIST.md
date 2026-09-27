# Hinge 3.0.0 release checklist

Execute on a Mac with full Xcode before taking payment. Customer archive: notarized `Hinge-3.0.0.zip` from `scripts/package-release.sh` only.

Legend:

- **Code-complete** — already true in this repository; re-verify only if you change related code.
- **Mac-only** — requires your Mac, Apple certificates, hardware, or Gumroad account. This cloud/CI environment cannot finish these steps.

---

## A. Pre-payment (seller decisions)

Do these before publishing a paid listing.

| Step | Owner | Status |
| --- | --- | --- |
| Confirm final product name and Gumroad URL slug | Seller | Mac-only / TBD |
| Confirm bundle identifier `com.datalynlabs.hinge.mac` (changing later breaks preferences / Screen Recording grants) | Seller | Code-complete default; Mac-only to confirm |
| Set price → fill `[PRICE]` in [GUMROAD.md](GUMROAD.md) | Seller | Mac-only / TBD |
| Set support address → fill `[SUPPORT_EMAIL]` in listing docs; export `HINGE_SUPPORT_EMAIL` when packaging | Seller | Mac-only / TBD |
| Write refund / update-scope wording → `[REFUND_POLICY]` / `[UPDATE_SCOPE]` in [GUMROAD.md](GUMROAD.md) | Seller | Mac-only / TBD |
| Record hardware you personally tested → `[VERIFIED_HARDWARE_LIST]` | Seller on hardware | Mac-only |
| Capture Hinge-specific screenshots / demo (do not reuse upstream marketing) | Seller | Mac-only |
| Obtain **Developer ID Application** certificate in your Apple Developer account | Seller | Mac-only |
| Create a working **notarytool** keychain profile (`xcrun notarytool store-credentials`) | Seller | Mac-only |

No paid license enforcement is implemented. Gumroad is direct-download only. Do not invent prices, emails, or verified hardware lists.

---

## B. Code-complete (repo readiness)

Already in tree for 3.0.0 packaging. Spot-check before a customer build:

- [x] Independent app name, bundle identifier, preferences, and icon
- [x] Presets, local personal-preset persistence, working-angle calibration
- [x] Upstream MIT license + ATTRIBUTION.md copied into the app bundle by `./build.sh`
- [x] Customer packaging script: Developer ID sign → notarytool → staple → Gatekeeper assess → ZIP + SHA-256
- [x] Customer release notes: [V3.0-CUSTOMER.md](V3.0-CUSTOMER.md)
- [x] Gumroad listing draft: [GUMROAD.md](GUMROAD.md)
- [x] In-app About / Support path that uses `HINGE_SUPPORT_EMAIL` when set (no invented domain)
- [x] UI no longer labels 3.0.0 as a “development preview” for buyers

Historical preview validation notes: [V3-PREVIEW.md](V3-PREVIEW.md).

---

## C. Post-build (Mac packaging)

Run on your Mac after certificates and `HINGE_SUPPORT_EMAIL` are ready.

1. **Mac-only** — Install full Xcode (not Command Line Tools alone). Confirm `xcode-select -p` points at Xcode.
2. **Mac-only** — List signing identities and pick Developer ID Application:

   ```sh
   security find-identity -v -p codesigning
   ```

3. **Mac-only** — Confirm notary profile exists (name must match what you pass below):

   ```sh
   xcrun notarytool history --keychain-profile 'YOUR_PROFILE_NAME'
   ```

4. **Mac-only** — Run automated checks:

   ```sh
   swift test
   ./build.sh
   "$HOME/Library/Caches/Hinge/build/Hinge.app/Contents/MacOS/Hinge" --render-check validation
   ```

5. **Mac-only** — Produce the customer ZIP (script fails clearly if identity/profile are missing or not Developer ID):

   ```sh
   export HINGE_SIGNING_IDENTITY='Developer ID Application: Your Name (TEAMID)'
   export HINGE_NOTARY_PROFILE='your-keychain-profile'
   export HINGE_SUPPORT_EMAIL='[SUPPORT_EMAIL]'   # optional but recommended; embeds support mailto in the app
   ./scripts/package-release.sh
   ```

6. **Mac-only** — Confirm outputs:

   - `build/distribution/Hinge-3.0.0.zip`
   - `build/distribution/Hinge-3.0.0.zip.sha256`
   - Script printed staple / `spctl` success

7. **Mac-only** — Install the ZIP on a second Mac (or a clean user account). Confirm Gatekeeper opens the app without blocking, About shows the expected version, and Support mailto works if `HINGE_SUPPORT_EMAIL` was set.

Do **not** upload:

- Ad-hoc `./build.sh` output
- `scripts/package-preview-dmg.sh` preview DMGs

---

## D. Hardware / live-behavior validation (Mac-only)

Unit and offscreen Metal tests do **not** prove these. Validate before payment:

- [ ] Physical lid motion on each model you will list under `[VERIFIED_HARDWARE_LIST]`
- [ ] Screen Recording grant / deny / revoke (including reopen-after-grant if macOS requires it)
- [ ] Esc and ⌃⌥⌘F global pause
- [ ] Sleep / wake, switching Spaces, external display connected (effects stay on built-in only)
- [ ] Sensor loss while enabled; reduced-motion behavior with real capture
- [ ] Named presets save/restore after relaunch; calibration on the packaged build
- [ ] Launch at login approval path (does not auto-enable capture)

---

## E. Gumroad upload (Mac-only)

- [ ] Paste finished copy from [GUMROAD.md](GUMROAD.md) with all placeholders replaced
- [ ] Attach notarized `Hinge-3.0.0.zip` (and optionally publish the `.sha256` checksum in the listing or delivery note)
- [ ] Set `[PRICE]`, support email, refund policy, verified hardware list
- [ ] Complete a test purchase / delivery check on Gumroad
- [ ] Keep LICENSE + ATTRIBUTION honesty in the public listing (“Before you buy”)

---

## Honesty reminders

- The local preview DMG is not notarized.
- Passing `swift test` and `--render-check` does not prove live lid compatibility, Screen Recording UX, battery impact, or clean customer install behavior.
- Do not claim universal MacBook support or notarization until your Mac run of `package-release.sh` succeeds and you have verified hardware yourself.
