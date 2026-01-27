# DEBT-007: UI Tests Not in Convergence Gate + Coverage Gaps

**Priority:** P2 (Important - Tests Are Safety Net)
**Status:** OPEN
**Created:** 2026-01-27
**Last Audited:** 2026-01-27

## Current State

- `bash scripts/verify.sh` passes (format, lint, iOS Simulator compile check, and unit/integration tests).
- UI tests exist and match the current 4-tab UI (Page Object Pattern in `CraveyUITests/`), but:
  - They are **not executed** by `scripts/verify.sh` (so UI regressions can ship undetected).
  - Building/running UI tests on iOS Simulator surfaces Swift 6 actor-isolation diagnostics because `XCUIApplication` / `XCUIElement` APIs are `@MainActor`.

## Impact

- UI flows (Home/Log/History/Settings) can regress without failing the convergence gate.
- Actor-isolation warnings may become errors in future toolchains, blocking UI test execution.

## Work Items

### 1) Make UI Tests Concurrency-Clean (Swift 6)

Pick one approach and apply consistently across `CraveyUITests/`:

- **Option A (preferred):** Convert UI tests + page objects to `async` and wrap UI interactions in `await MainActor.run { ... }`, returning only `Sendable` values from cross-actor boundaries.
- **Option B (tests-only escape hatch):** Use `@preconcurrency import XCTest` in UI test sources to intentionally suppress actor-isolation diagnostics in test code.

### 2) Close High-Value Coverage Gaps (Fast Tests)

Add missing Swift Testing coverage for:

- `CravingListViewModel` (parity with `UsageListViewModelTests`)
- `SettingsViewModel` (export + delete flows)

## Verification Commands

```bash
# Convergence gate (fast)
bash scripts/verify.sh

# UI tests (slow)
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyUITests | xcbeautify
```

## Acceptance Criteria

- [ ] `bash scripts/verify.sh` passes
- [ ] `xcodebuild test ... -only-testing:CraveyUITests` exits `0` (UI tests run successfully)
- [ ] `CravingListViewModelTests` exist and pass
- [ ] `SettingsViewModelTests` exist and pass

