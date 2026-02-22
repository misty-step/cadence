# CLAUDE.md

## What This Is

Cadence is a macOS-native Pomodoro timer. Floating desktop window + menu bar icon. No configuration, no integrations — just the standard 25/5/15 cycle. Built with Swift 6, SwiftUI, zero dependencies.

## Essential Commands

```bash
# Dev build + run
./scripts/dev.sh

# Release build (creates Cadence.app)
./scripts/bundle.sh

# Run tests
swift test

# Build only
swift build
```

## Architecture

5 source files, single target. `TimerState` is the core state machine (`@Observable`). `TimerView` renders it. `WindowManager` creates the floating `NSWindow`. `NotificationManager` handles system notifications. `AppDelegate` wires everything and manages the menu bar icon.

See [docs/CODEBASE_MAP.md](docs/CODEBASE_MAP.md) for full architecture.

## Tech Stack

| Component | Version |
|-----------|---------|
| Swift | 6.0 |
| SwiftUI | macOS 14+ |
| SPM | Package.swift manifest |
| Testing | Swift Testing (`@Test`, `#expect`) |
| CI | Cerberus AI review council (GitHub Actions) |
| Dependencies | None |

## Quality Gates

- **CI**: Cerberus runs 5 AI reviewers (correctness, architecture, security, performance, maintainability) on every PR
- **Tests**: `swift test` — 14 tests covering `TimerState` logic
- **No linter/formatter configured** — follow existing code style
- **Swift 6 strict concurrency**: all mutable state must be `@MainActor`

## Gotchas

- **SPM executable, not Xcode project.** Build with `swift build`, not Xcode. App bundle constructed manually by `scripts/bundle.sh` with embedded Info.plist via linker flags.
- **`@Observable`, not `ObservableObject`.** Uses Swift Observation framework. Views use `@Bindable`, not `@ObservedObject`.
- **Timer durations are intentionally hardcoded.** 25/5/15 minutes. Not configurable by design (see spec.md).
- **LSUIElement = true.** No dock icon. Menu bar + floating window only.
- **Ad-hoc code signing.** No developer certificate. `codesign --sign -`.
- **`NotificationManager()` created per tick.** `startBackgroundTimer` creates a new instance each second instead of using the shared one. Functional but wasteful.
- **Status bar polls at 0.5s** instead of using `withObservationTracking`.

## Environment

No env vars, no secrets, no external services. Pure local macOS app.

Requires: macOS 14+, Swift 6.0 toolchain.

## Deployment

Local only. `./scripts/bundle.sh` → `open Cadence.app` or copy to `/Applications/`.
