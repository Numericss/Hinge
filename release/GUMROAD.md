# Gumroad listing — Hinge 3.0.0 (publish-ready draft)

Replace every `[PLACEHOLDER]` before going live. Do not invent a finished price, support address, or verified hardware list.

---

## Product name

**Hinge 3.0**

Suggested URL slug: `hinge` (confirm availability on Gumroad).

## Tagline

Give your MacBook a little motion.

## Short description (Gumroad summary)

Hinge adds a playful finishing touch to your Mac: desktop effects that respond as you move its lid. Choose from five effects, start with a mood preset, and save a setup that feels like yours.

## Price

`[PRICE]`

## What’s included

- Five lid-reactive effects: Duo, Roll, Shutter, Flex, and Iris.
- Subtle, Cinematic, and Crisp motion presets.
- Native Effects, Motion, Automation, and Setup & Help pages.
- Named presets with save, rename, and delete, plus working-angle calibration.
- Battery-aware performance modes and optional automatic pause rules.
- Guided setup, optional launch at login, and local diagnostics export.
- One-click effect previews and a clear status area.
- Live preview and a replay mode that works without screen access.
- Menu-bar controls, light and dark appearance, and quick pause shortcuts.
- Local processing only — no account, analytics, or license server.
- Direct download of a **Developer ID–signed, Apple-notarized** `Hinge-3.0.0.zip` (produced with `scripts/package-release.sh` on the seller’s Mac).

## Full description (paste into Gumroad)

Hinge is a native macOS app that animates your built-in desktop as you move a compatible MacBook lid. Pick an effect, tune motion with presets or your own saved setups, and keep everyday controls in the menu bar.

**Requirements**

- Apple-silicon MacBook
- macOS 14 or later
- Compatible lid-angle sensor for automatic effects
- Screen Recording permission to animate your real desktop (frames stay in memory on your Mac; audio is never captured)

**Verified on (seller-filled)**

`[VERIFIED_HARDWARE_LIST]`

Only list models you personally tested with this Hinge 3.0.0 build. Do not copy upstream hardware claims as verified for Hinge.

**Delivery**

After purchase you receive a notarized ZIP. Open `Hinge.app` (or drag it into Applications). Quit any older Hinge copy before replacing it.

**Support**

Email `[SUPPORT_EMAIL]` for install help and product questions. Update and support scope: `[UPDATE_SCOPE]`.

**Refunds**

`[REFUND_POLICY]`

---

## Before you buy

Requires an Apple-silicon MacBook running macOS 14 or later with a compatible lid-angle sensor. Automatic effects animate the **built-in display only**. Screen Recording permission is required to animate your desktop; frames stay in memory. Sensor compatibility varies — see `[VERIFIED_HARDWARE_LIST]` above for models the seller has verified with this build.

Hinge is an independently maintained, MIT-licensed fork of MacDuo. The original open-source project is available at https://github.com/DhananjayBhosale/MacDuo. Hinge adds preset workflows, calibration, and its own interface and packaging. Not affiliated with Apple or MacDuo’s authors.

This is a **direct-download purchase**. No paid license keys or DRM are implemented.

Do not promise lifetime updates, universal MacBook compatibility, or ownership of the inherited MacDuo core.

---

## Seller preflight (before Publish)

- [ ] `[PRICE]`, `[SUPPORT_EMAIL]`, `[REFUND_POLICY]`, `[UPDATE_SCOPE]`, and `[VERIFIED_HARDWARE_LIST]` replaced with real values
- [ ] Notarized ZIP from `scripts/package-release.sh` attached (not an ad-hoc build or preview DMG)
- [ ] Listing copy matches [V3.0-CUSTOMER.md](V3.0-CUSTOMER.md) on requirements and limitations
- [ ] Screenshots / video are from this Hinge UI (not upstream MacDuo marketing)
- [ ] Test purchase delivers the ZIP cleanly
- [ ] Support mailto works in the packaged app (`HINGE_SUPPORT_EMAIL` set at build time)
