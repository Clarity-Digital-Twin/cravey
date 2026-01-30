# DEBT-038: Domain logic uses Date()/Calendar.current directly (hidden, untestable dependencies)

**Priority:** P3 (Architecture / testability)
**Status:** ✅ RESOLVED
**Created:** 2026-01-30
**Resolved:** 2026-01-30

## Resolution

- Introduced `Clock` protocol + `SystemClock` in Domain.
- Injected `Clock` into time-sensitive use cases and removed direct `Date()`/`Calendar.current` usage in business rules.
- Removed implicit `Date()` defaults from time-dependent helpers (`LogUsageRequest.timestamp`, `CravingEntity.isWithinLast`).

## Problem

Several Domain entities and use cases depend on real time via `Date()` and `Calendar.current`. This introduces hidden dependencies that make time-based logic:

- harder to test deterministically,
- harder to reason about (implicit time zone / locale),
- more likely to become flaky over time (midnight boundary, clock changes).

## Examples / Locations

- `Cravey/Domain/Entities/CravingEntity.swift`
  - defaults: `timestamp: Date = Date()`, `createdAt: Date = Date()`
  - logic: `isWithinLast(_:)` uses `Date()` directly
- `Cravey/Domain/UseCases/LogCravingUseCase.swift`
  - future timestamp validation uses `Date()`
- `Cravey/Domain/UseCases/LogUsageUseCase.swift`
  - `LogUsageRequest(timestamp: Date = Date())`
  - future timestamp validation uses `Date()`
- `Cravey/Domain/UseCases/SelectMotivationalMessageUseCase.swift`
  - selection uses `Calendar.current` + `Date()`
- `Cravey/Domain/UseCases/ExportUserDataUseCase.swift`
  - export payload uses `exportDate: Date()`

## Why This Is Bad (Rob C. Martin / SOLID)

- **Dependency Inversion:** High-level rules should not reach out to global state when a dependency can be injected.
- **Testability:** You can’t reliably test “future timestamp” logic without controlling “now”.
- **Consistency:** Some Presentation code already uses `nowProvider`; Domain should be equally deterministic.

## Proposed Fix

- Introduce a small Domain protocol (e.g., `Clock` / `NowProviding`):
  - `func now() -> Date`
  - optionally `var calendar: Calendar` if needed.
- Inject it into time-sensitive use cases (`LogCraving`, `LogUsage`, `SelectMotivationalMessage`, `ExportUserData`).
- Prefer passing `now` explicitly into entity methods that depend on time (e.g., `isWithinLast(hours:now:)`), or accept a `now` parameter and default only at call sites (outside Domain).

## Acceptance Criteria

- [x] Domain time-based rules can be unit-tested with a fixed clock.
- [x] No “business rule” depends on `Date()` directly outside of a `Clock.system`.
- [x] Calendar usage is explicit and testable.
