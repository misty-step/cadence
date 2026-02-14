# ADR: Desktop Window UI

Status: accepted (2026-02-13)

## Context

Cadence started as a menu bar extra. The primary UX cost: the timer is hidden until clicked.

Goal: make Cadence glanceable, always visible, and still minimal.

Constraints:

- SwiftUI-first
- No settings surface
- Keep code small and obvious

## Decision

Replace the menu bar extra UI with a single persistent desktop window.

## Consequences

- Better: glanceable timer, always on screen.
- Worse: no longer “out of the way” like a menu bar extra.
- Risk: if the window is closed, the app must not become “lost” (no UI to reopen).

## Alternatives Considered

- Keep menu bar extra and add a desktop “always-on-top” mode.
- Menu bar extra + floating panel.

