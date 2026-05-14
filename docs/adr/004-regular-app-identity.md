# 004. Regular App Identity over Agent App

Date: 2026-05-14

## Status

Accepted

## Context

Cadence previously ran as an agent app by setting `LSUIElement=true` in the
manual app bundle and `.accessory` as the runtime activation policy. That kept
Cadence out of the Dock and Command-Tab app switcher.

The timer still has a menu bar control, but users also expect standard macOS
navigation to work for a visible app window.

## Decision

Run Cadence as a regular macOS app. The app appears in the Dock and Command-Tab,
and the menu bar item remains available for quick show/hide control.

Because Cadence uses Swift Package Manager rather than an Xcode project, the
bundle scripts generate and copy `Cadence.icns` directly into the app bundle.

## Consequences

- **Good**: Users can return to Cadence through standard macOS app switching.
- **Good**: The app has a real Dock and Command-Tab icon.
- **Good**: The menu bar control remains available.
- **Bad**: Cadence now takes a Dock slot while running.
- **Bad**: Manual bundle assembly has one more packaging responsibility.
