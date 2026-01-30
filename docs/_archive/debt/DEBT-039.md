# DEBT-039: LocationService mixes flow-control with errors; polling + cancellation mapping + complexity warnings

**Priority:** P2 (Reliability + Clean Code)
**Status:** ✅ RESOLVED
**Created:** 2026-01-30
**Resolved:** 2026-01-30

## Resolution

- Refactored `LocationService` to avoid recursion and silent cancellation swallowing.
- Added `LocationResult.cancelled` and ensured cancellation is not mislabeled as timeout.
- Resolved SwiftLint complexity warnings without suppressions.

## Problem

`LocationService` currently:

- polls authorization with recursion + `Task.sleep`,
- uses `try?` to ignore `Task.sleep` cancellation,
- maps `CancellationError` to `.timeout` (conflates distinct outcomes),
- trips SwiftLint complexity/body-length rules.

Even if behavior is “mostly fine”, this implementation is brittle and hard to maintain.

## Location

- `Cravey/Data/Services/LocationService.swift`
  - `requestCurrentLocationWithRetry` (lines ~27–100)

## Current Smells

- Silent cancellation swallow:
  - `try? await Task.sleep(for: .milliseconds(500))`
- Cancellation reported as timeout:
  - `catch is CancellationError { return .timeout }`
- Function complexity warnings:
  - `Cyclomatic Complexity` and `Function Body Length` from SwiftLint.

## Proposed Refactor

- Split responsibilities into focused helpers:
  - `isLocationServicesEnabled()`
  - `ensureAuthorization(timeout:)` (awaits status change once)
  - `fetchFirstLocationUpdate(timeout:)`
- Avoid recursion for authorization polling.
- Handle cancellation distinctly:
  - either add `LocationResult.cancelled` in Domain, or propagate cancellation and let Presentation decide.
- Keep a single, explicit timeout budget.

## Acceptance Criteria

- [x] No `try?` for cancellation-prone operations; catch `CancellationError` explicitly.
- [x] Cancellation is not mislabeled as timeout.
- [x] SwiftLint warnings for `LocationService` are resolved without suppressions.
- [x] Unit tests cover “denied”, “restricted”, “services disabled”, and “granted after prompt” flows (mocking via protocol).
