# 003. No User Configuration

Date: 2025-01-31

## Status

Accepted

## Context

Most Pomodoro apps offer configurable durations, themes, sounds, and integrations. This creates UI complexity (settings screens), code complexity (persistence, validation, migration), and decision fatigue for users.

## Decision

Hardcode all values. 25/5/15 minute durations. Fixed color scheme. Fixed notification sounds. No settings screen, no preferences window.

## Consequences

- **Good**: Zero onboarding. Open and it works. No decisions to make.
- **Good**: Dramatically simpler codebase. No UserDefaults, no settings UI, no migration logic.
- **Good**: Consistent experience — bug reports are reproducible without "what are your settings?"
- **Bad**: Users who prefer different durations cannot use this app. That's intentional.
