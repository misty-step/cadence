# Cadence

> A macOS-native Pomodoro timer that does one thing exceptionally well.

## Vision

Super simple. Super smooth. Beautiful. No feature bloat, no complexity - just the rhythmic pulse of focused work and intentional rest.

## Philosophy

**Opinionated defaults over configuration.** The Pomodoro technique has been refined for decades. We know what works:

- **Focus session:** 25 minutes
- **Short break:** 5 minutes
- **Long break:** 15 minutes (after 4 focus sessions)
- **Cycle:** Focus → Short Break → Focus → Short Break → Focus → Short Break → Focus → Long Break → Repeat

These values are not configurable. They're correct.

**One thing, done perfectly.** No task lists. No integrations. No statistics dashboards. No gamification. Just a timer that respects your attention and gets out of the way.

## Design Goals

### Aesthetic
- Native macOS design language
- Menu bar app (unobtrusive, always accessible)
- Minimal chrome, maximum clarity
- Subtle, satisfying animations
- Beautiful typography

### UX
- Zero onboarding - open it and it works
- Single click to start/pause
- Keyboard shortcuts for power users
- Gentle, non-jarring notifications
- Respects Do Not Disturb

### Technical
- Swift + SwiftUI
- Native macOS APIs (no Electron)
- Lightweight (~5MB)
- Fast launch, minimal memory footprint
- Runs in menu bar, not dock

## The Loop

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   FOCUS (25m) → BREAK (5m) → FOCUS → BREAK →           │
│   FOCUS → BREAK → FOCUS → LONG BREAK (15m) → repeat    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

Session 1: Focus (25) → Short Break (5)
Session 2: Focus (25) → Short Break (5)
Session 3: Focus (25) → Short Break (5)
Session 4: Focus (25) → Long Break (15)
...repeat

## UI Concept

**Menu bar icon:** Simple circle that fills as the timer progresses. Red during focus, green during break.

**Click to expand:** Shows current phase, time remaining, and a single Start/Pause button.

**That's it.** No settings panel. No preferences window. No about screen with social links.

## Open Source

MIT licensed under the Misty Step umbrella. Clean, readable Swift code that serves as an example of how to build a focused macOS menu bar app.

## Success Criteria

1. Someone downloads it, opens it, and immediately understands how to use it
2. It looks so good people screenshot it
3. It stays out of the way until you need it
4. The codebase is small enough to read in one sitting

## Name

**Cadence** - the natural rhythm of focused work.

---

*Less, but better.*
