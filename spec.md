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
- Desktop window app (persistent, always visible on desktop)
- Minimal chrome, maximum clarity
- Subtle, satisfying animations
- Beautiful typography

### UX
- Zero onboarding - open it and it works
- Single click to start/pause
- Keyboard shortcuts for power users (Space = play/pause, Cmd+R = reset)
- Gentle, non-jarring notifications
- Respects Do Not Disturb

### Technical
- Swift + SwiftUI
- Native macOS APIs (no Electron)
- Lightweight (~250KB app bundle)
- Fast launch, minimal memory footprint
- Runs as a persistent desktop window, not in menu bar

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

**Desktop window:** A compact, beautiful window that sits on your desktop.

**Window contents:**
- Current phase (Focus / Short Break / Long Break) with distinct colors
  - Focus: warm orange (#FF9400)
  - Short Break: teal (#30D6C8)
  - Long Break: indigo (#5957D6)
- Large, clear time remaining (MM:SS) in monospaced font
- 4 session progress dots showing which focus session you're in
- Circular progress ring that fills as timer progresses
- Play/Pause button + Reset button
- Background subtly shifts color based on phase

**Keyboard shortcuts:**
- Space = Play/Pause
- Cmd+R = Reset

**That's it.** No settings panel. No preferences window. No about screen with social links.

## Open Source

MIT licensed under the Misty Step umbrella. Clean, readable Swift code that serves as an example of how to build a focused macOS desktop window app.

## Success Criteria

1. Someone downloads it, opens it, and immediately understands how to use it
2. It looks so good people screenshot it
3. It stays visible on desktop until you need it
4. The codebase is small enough to read in one sitting

## Name

**Cadence** - the natural rhythm of focused work.

---

*Less, but better.*
