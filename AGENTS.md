# AGENTS.md

Operational playbook for AI agents working in this repo.

## Commit Conventions

Conventional commits. Scope optional.

```
feat: add keyboard shortcut for reset
fix: correct phase transition after long break
refactor: extract progress ring into component
test: add edge case for zero-second tick
ci: update Cerberus config
```

Commits are concise, imperative, lowercase. No periods.

## Testing Guidelines

- **Framework**: Swift Testing (`import Testing`, `@Test`, `#expect`)
- **NOT XCTest** — don't use `XCTAssert*`
- **Tests live in**: `Tests/CadenceTests/`
- **Pattern**: Test file mirrors source: `TimerState.swift` → `TimerStateTests.swift`
- **All tests are `@MainActor`** (required by `TimerState`)
- **`NotificationManager` is passed to `tick()`** — create a local instance in tests
- **Coverage**: Timer logic is well-tested. Views are not tested (SwiftUI).

To run:
```bash
swift test
```

## PR Guidelines

PRs get AI review from Cerberus (5 reviewers: correctness, architecture, security, performance, maintainability). Write clear PR descriptions — the reviewers read them.

Required:
1. Summary of what and why
2. Test coverage for logic changes
3. Manual QA steps if UI changed

## Coding Style

- **Swift 6 strict concurrency**: `@MainActor` on all mutable state, `Sendable` conformance
- **SwiftUI Observation**: `@Observable` classes, `@Bindable` in views
- **No third-party dependencies**: Keep it that way unless absolutely necessary
- **Constants**: Extract magic numbers into named constants (see `MenuBarIconImage.Constants`)
- **MARK comments**: Use `// MARK: -` to section files
- **Fixed window size**: 380x480. Don't change without design review.
- **Phase enum**: All phase-specific data lives on `TimerState.Phase` as computed properties

## Definition of Done

- [ ] `swift build` succeeds with no warnings
- [ ] `swift test` passes all tests
- [ ] New logic has corresponding tests
- [ ] No new dependencies added without justification
- [ ] Commit message follows conventional commits

## Security Boundaries

- No network access. App is fully offline.
- No file system access beyond window position autosave.
- No user data collection or telemetry.
- Notification permission is the only system permission requested.
