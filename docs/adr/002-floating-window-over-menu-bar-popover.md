# 002. Persistent Floating Window over Menu Bar Popover

Date: 2025-02-13

## Status

Accepted (supersedes original menu bar popover design)

## Context

The original design used a menu bar popover (click menu bar icon to show/hide timer). This made the timer invisible by default, requiring user action to check progress. For a Pomodoro timer, ambient visibility is a core feature.

## Decision

Use a persistent floating NSWindow (`level: .floating`, `canJoinAllSpaces`) that stays visible across all spaces. Menu bar icon toggles window visibility. Window position is persisted via `setFrameAutosaveName`.

## Consequences

- **Good**: Timer is always visible during focus sessions. Ambient awareness without active checking.
- **Good**: Window follows across spaces. Position remembered across launches.
- **Bad**: Takes screen real estate (380x480). Some users may find it intrusive.
- **Bad**: More complex window management code than a simple popover.
