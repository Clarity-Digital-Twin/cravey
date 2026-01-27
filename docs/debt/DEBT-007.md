# DEBT-007: UI Tests Not in Convergence Gate

**Priority:** P2 (Important - Tests Are Safety Net)
**Status:** OPEN (ViewModel coverage closed; UI gate remains)
**Created:** 2026-01-27
**Last Audited:** 2026-01-27

## Current State

- `bash scripts/verify.sh` passes (format, lint, iOS Simulator compile check, and unit/integration tests).
- **ViewModel coverage gaps closed** (2026-01-27): `CravingListViewModelTests` (5 tests) and `SettingsViewModelTests` (8 tests) added.
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

- [x] `bash scripts/verify.sh` passes
- [ ] `xcodebuild test ... -only-testing:CraveyUITests` exits `0` (UI tests run successfully)
- [x] `CravingListViewModelTests` exist and pass (5 tests added 2026-01-27)
- [x] `SettingsViewModelTests` exist and pass (8 tests added 2026-01-27)

