# Cadence

> The natural rhythm of focused work.

A macOS menu bar Pomodoro timer that does one thing exceptionally well.

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

Click the circle in your menu bar. Press Start. Focus.

## Design

- Native Swift + SwiftUI
- Menu bar only (no dock icon)
- Gentle notifications
- ~50KB binary

## License

MIT © [Misty Step](https://github.com/misty-step)

---

*Less, but better.*
