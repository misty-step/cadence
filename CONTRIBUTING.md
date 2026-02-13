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

No test target yet.

If you add non-trivial logic, add a `Tests/` target with coverage for it.

