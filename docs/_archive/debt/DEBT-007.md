# DEBT-007: UI Tests Not in Convergence Gate

**Priority:** P2 (Important - Tests Are Safety Net)
**Status:** CLOSED (2026-01-27)
**Created:** 2026-01-27
**Last Audited:** 2026-01-27

## Resolution Summary

UI tests now pass. The issue was a race condition in test assertions, not Swift 6 concurrency.

**Root Cause:** Tests that called `verifyFormDismissed()` before `verifySuccessToastAppears()` would miss the toast because:
- Toast auto-dismisses after 2 seconds
- `verifyFormDismissed()` waits up to 3 seconds
- By the time form dismiss was confirmed, toast had already disappeared

**Fix:** Removed redundant `verifyFormDismissed()` calls - toast appearing inherently proves form dismissed.

## Solution Implemented

1. **Fixed 5 failing UI tests** (toast race condition):
   - `CravingLogTests.testLogCravingWithMinimalData`
   - `CravingLogTests.testLogCravingWithFullData`
   - `UsageLogTests.testLogUsageWithMinimalData`
   - `UsageLogTests.testLogUsageWithDifferentMethod`
   - `UsageLogTests.testLogUsageWithFullData`

2. **Added optional UI test flag to verify.sh**:
   - `./scripts/verify.sh` - Fast gate (unit tests only, ~30s)
   - `./scripts/verify.sh --ui` - Full gate (unit + UI tests, ~5min)

## Acceptance Criteria

- [x] `bash scripts/verify.sh` passes
- [x] `xcodebuild test ... -only-testing:CraveyUITests` exits `0` (22 tests pass)
- [x] `CravingListViewModelTests` exist and pass (5 tests)
- [x] `SettingsViewModelTests` exist and pass (8 tests)

## Verification Commands

```bash
# Fast convergence gate (unit tests only)
bash scripts/verify.sh

# Full verification including UI tests (slow)
bash scripts/verify.sh --ui

# UI tests only (manual)
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyUITests | xcbeautify
```

## Files Changed

- `CraveyUITests/Tests/CravingLogTests.swift` - Fixed toast race condition
- `CraveyUITests/Tests/UsageLogTests.swift` - Fixed toast race condition
- `scripts/verify.sh` - Added `--ui` flag for optional UI test execution

## Test Summary (as of closure)

- **Unit tests:** 69 tests passing (CraveyTests)
- **UI tests:** 22 tests passing (CraveyUITests)
- **Total at closure:** 91 tests

_Note: Test count has grown since closure. See current verify.sh output for latest._
