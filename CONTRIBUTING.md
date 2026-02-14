# Contributing

Cadence is intentionally small. Keep changes minimal and obvious.

## Prereqs

- macOS 14+
- Xcode Command Line Tools (`xcode-select --install`)

## Build + Run

```bash
swift build
swift run
```

For the real `.app` bundle:

```bash
./scripts/bundle.sh
open Cadence.app
```

## Tests

```bash
swift test
```

Tests live in `Tests/CadenceTests/`. The test suite covers `TimerState` phase logic:
session counting, break selection, full pomodoro cycle, and basic operations.

