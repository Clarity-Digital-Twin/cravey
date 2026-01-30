# DEBT-046: SwiftLint pre-build script runs on every build, slowing tests

**Priority:** P4 (DevEx / build performance)
**Status:** OPEN
**Created:** 2026-01-30

## Problem

`xcodebuild` reports that the `SwiftLint` run script phase executes during every build because it is configured with dependency analysis disabled.

This adds noticeable overhead, especially for UI tests (minutes), and duplicates linting already enforced via `scripts/verify.sh`.

## Location

- `project.yml` (`targets.Cravey.preBuildScripts[SwiftLint]`)

## Proposed Fix

Choose one of:

1. **Move linting out of Xcode build phases** (preferred if CI/verify is the gate):
   - Remove the `SwiftLint` pre-build script from `project.yml`.
   - Keep `scripts/verify.sh` as the canonical lint gate.

2. **Keep build-phase linting but make it incremental**:
   - Configure script phase inputs/outputs and enable dependency analysis.
   - Ensure it still runs when any Swift source (or `.swiftlint.yml`) changes.

## Acceptance Criteria

- [ ] `xcodebuild` no longer runs SwiftLint on every build by default.
- [ ] Linting remains enforced via `scripts/verify.sh`.
- [ ] Local “build + test” iteration time improves measurably (especially UI tests).

