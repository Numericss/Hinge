# Hinge 2.0.0 Preview

Hinge keeps its original five effects and teal identity, with a more manageable native macOS workspace.

## Interface

- Effects: large selectable effect tiles, automatic preview on selection, replay/stop, and clearly labeled lid/manual preview modes.
- Motion: mood presets, save/restore favorite, calibration, stillness timing, and visual adjustments on one scrollable page.
- Setup & Help: three setup steps, screen-access explanation and settings link, temporary desktop test, appearance, shortcuts, and credits.
- Persistent status and enable/pause action. Error details wrap instead of being clipped into a tiny footer.
- Native sidebar selection, system colors/materials and controls, readable typography, and remembered window geometry. Smaller windows scroll rather than shrinking all text.

## Fixes

- Temporary desktop tests now restore the prior enabled state instead of silently leaving the app enabled.
- Test requests cannot overlap a pending permission request or another test.
- Saved visual values are validated on launch before reaching sliders or the renderer.
- Preview replay can be stopped independently of desktop effects.
- Reset motion restores defaults without losing the selected effect or saved favorite.
- Menu-bar enablement can cancel a pending screen-access request.

## Distribution

Same bundle identity and preference keys as the earlier Hinge preview. Version 2.0.0, build 200. Preserve existing presets and settings when upgrading. Quit any other Hinge copies before opening this version.

This preview is ad-hoc signed, not notarized. It is not a paid customer release. Version 0.1 promotional mockups show the old interface and should not be used to represent version 2.0.
