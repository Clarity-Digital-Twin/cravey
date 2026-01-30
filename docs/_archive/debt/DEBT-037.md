# DEBT-037: AppStartupHandler is unused; CraveyApp startup/reset logic is duplicated

**Priority:** P2 (Important - DRY / maintainability)
**Status:** ✅ RESOLVED
**Created:** 2026-01-30
**Resolved:** 2026-01-30

## Resolution

- Adopted `AppStartupHandler.initialize()` in `Cravey/App/CraveyApp.swift` for both initial startup and retry.
- Eliminated duplicated startup wiring and “nil out state” blocks.

## Problem

The repo contains `AppStartupHandler` (introduced to centralize startup wiring), but `CraveyApp` does not use it. As a result:

- Startup logic is duplicated between `init()` and `retryStartup()`.
- “Reset all view models to nil” logic is duplicated across multiple catch blocks.
- `AppStartupHandler` is effectively dead code (high signal of a “halfway” refactor).

## Location

- `Cravey/App/CraveyApp.swift` (duplicated initialization + error handling)
  - `init()` (lines ~17–52)
  - `retryStartup()` (lines ~112–145)
- `Cravey/App/AppStartupHandler.swift` (unused)

## Why This Is Bad (Clean Architecture / Clean Code)

- **Violates DRY:** Updating startup state requires touching multiple places.
- **Increases bug risk:** Easy to forget to update one catch path when adding/removing a ViewModel.
- **Dead code smell:** `AppStartupHandler` exists but provides no value unless adopted or removed.

## Proposed Fix

Choose one:

### Option A (Preferred): Adopt `AppStartupHandler`

- Use `AppStartupHandler.initialize()` in both `init()` and `retryStartup()`.
- Assign all `@State` values from its `Result`.

### Option B: Remove `AppStartupHandler`

- Delete `Cravey/App/AppStartupHandler.swift`.
- Replace duplication with a private helper in `CraveyApp.swift` (single “initialize” function + a single “failed” initializer).

## Acceptance Criteria

- [x] Single source of truth for startup wiring and failure handling.
- [x] No duplicated "nil out all view models" blocks.
- [x] No unused startup handler code remains in the app target.
- [x] All tests pass.
