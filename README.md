# Cadence

> The natural rhythm of focused work.

A macOS desktop Pomodoro timer that does one thing exceptionally well.

## Philosophy

Opinionated defaults over configuration. The Pomodoro technique works:

- **Focus:** 25 minutes
- **Short break:** 5 minutes  
- **Long break:** 15 minutes (after 4 focus sessions)

These values are not configurable. They're correct.

## Install

```bash
./scripts/bundle.sh
open Cadence.app
```

Requires macOS 14+.

## Development

```bash
swift build
swift run
```

Note: notifications require the bundled app (`./scripts/bundle.sh`) since `swift run` has no app bundle identifier.

### Permanent Installation

```bash
# Install to Applications
./scripts/bundle.sh
# May require sudo on standard macOS installs
sudo cp -R Cadence.app /Applications/

# Optional: Auto-start on login
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Cadence.app", hidden:false}'
```

## Usage

Open Cadence. Keep the window on your desktop.

- `Space`: start/pause
- `Cmd+R`: reset

Closing the window quits the app.

## Design

- Native Swift + SwiftUI
- Persistent desktop window (no menu bar UI)
- Gentle notifications
- Small binary (~200KB release build)

## License

MIT © [Misty Step](https://github.com/misty-step)

---

*Less, but better.*
