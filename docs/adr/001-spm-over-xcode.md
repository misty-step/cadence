# 001. Swift Package Manager over Xcode Project

Date: 2025-01-31

## Status

Accepted

## Context

macOS apps are typically built with Xcode projects (.xcodeproj). However, Cadence is a minimal single-window app with no storyboards, asset catalogs, or complex build settings.

## Decision

Use Swift Package Manager with an executable target. Construct the .app bundle manually via `scripts/bundle.sh`, embedding Info.plist into the binary with `-sectcreate __TEXT __info_plist` linker flags.

## Consequences

- **Good**: No Xcode project files to maintain. Clean git history. CI-friendly builds with `swift build`/`swift test`.
- **Good**: Any Swift toolchain works — no Xcode version coupling.
- **Bad**: .app bundle requires manual assembly (scripts/bundle.sh). Info.plist embedded via linker flags is non-standard.
- **Bad**: No Interface Builder, asset catalogs, or Xcode-managed entitlements. All done in code or scripts.
