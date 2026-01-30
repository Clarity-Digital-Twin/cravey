# DEBT-040: AppConstants lives in Presentation but includes non-UI infrastructure configuration

**Priority:** P3 (Architecture clarity)
**Status:** OPEN
**Created:** 2026-01-30

## Problem

`AppConstants` is located under the Presentation layer:

- `Cravey/Presentation/Constants/AppConstants.swift`

…but it contains configuration that is not Presentation-specific:

- Location service timeout / retry counts
- Storage limits for recordings

These are **app/infrastructure concerns** and are used by the composition root (`DependencyContainer`) to configure Data layer services.

## Why This Is Bad

- **Layer confusion:** “Presentation” folder contains app-wide infrastructure config.
- **Easier to violate boundaries later:** It invites Data layer imports if someone “just needs the constant”.
- **Harder to reason about ownership:** UI constants already exist as `UIConstants`.

## Proposed Fix

Option A (Preferred): Move and split constants:

- Move infra constants to `Cravey/App/Constants/InfrastructureConstants.swift` (or similar).
- Keep UI defaults/timing in `Cravey/Presentation/Constants`.

Option B: Keep file but rename/split enums to reflect ownership and intent (less ideal).

## Acceptance Criteria

- [ ] Presentation contains UI-only constants.
- [ ] App/infrastructure constants live in App layer (composition root).
- [ ] No Data layer types import Presentation constants.

