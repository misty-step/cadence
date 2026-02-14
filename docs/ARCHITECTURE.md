# Architecture

Cadence is a single-window SwiftUI app. Core logic lives in `TimerState`. UI is a thin layer that renders state + sends intents.

## Modules

- `Sources/CadenceApp/CadenceApp.swift`
  - App entry point.
  - Owns long-lived state: `TimerState`, `NotificationManager`.
  - Defines the main `Window` scene.
  - AppKit glue: quit when the last window closes.

- `Sources/CadenceApp/TimerState.swift`
  - Domain model (phase, durations, progress).
  - State machine for phase transitions.
  - Tick-driven countdown (`tick()`).
  - Emits phase changes via `onPhaseChange`.

- `Sources/CadenceApp/TimerWindowView.swift`
  - Main UI.
  - Drives ticking via a 1s timer publisher.
  - Buttons call `timerState.toggle()` / `timerState.reset()`.

- `Sources/CadenceApp/NotificationManager.swift`
  - Requests notification auth (only when running as a bundled app).
  - Plays phase-specific system sounds.
  - Posts macOS notifications on phase changes.

## Control Flow

- UI ticks once/second and calls `TimerState.tick()`.
- When `secondsRemaining` hits 0, `TimerState` advances phase and calls `onPhaseChange`.
- `CadenceApp` wires `onPhaseChange` to `NotificationManager.notify(...)`.
- Start/pause is just `TimerState.isRunning` toggling.

## Packaging Notes

- `scripts/bundle.sh` builds a release binary with an embedded `Info.plist`, then creates `Cadence.app`.
- Notifications require a bundle identifier; `swift run` does not have one, so `NotificationManager` is effectively a no-op in dev-run mode.
