# DEBT-045: Default motivational message seeding leaks into Domain and is duplicated

**Priority:** P3 (Clean Architecture / separation of concerns)
**Status:** OPEN
**Created:** 2026-01-30

## Problem

Motivational message “seeding” exists in multiple places and is exposed as a Domain concern:

- `SelectMotivationalMessageUseCase.execute()` calls `MessageRepositoryProtocol.seedDefaultMessagesIfNeeded()`.
- App startup also seeds messages via `ModelContainerSetup.seedDefaultMessages(context:)`.
- `MessageRepositoryProtocol` includes a `seedDefaultMessagesIfNeeded()` method, which is an initialization concern rather than a business capability.

This creates two risks:

1. **Duplication drift:** Multiple seeding paths can diverge over time (different default sets, different rules).
2. **Layering smell:** Domain repository protocol exposes “bootstrap” behavior that is not part of core business logic.

## Location

- `Cravey/Domain/Repositories/MessageRepositoryProtocol.swift`
- `Cravey/Domain/UseCases/SelectMotivationalMessageUseCase.swift`
- `Cravey/App/DependencyContainer.swift` (startup seeding)
- `Cravey/Data/Storage/ModelContainerSetup.swift` (startup seeding implementation)
- `Cravey/Data/Repositories/MessageRepository.swift` (repository seeding implementation)

## Proposed Fix

Pick a single source of truth and a single call site:

Option A (preferred, simplest):
- Remove `seedDefaultMessagesIfNeeded()` from `MessageRepositoryProtocol`.
- Seed default messages at startup only (composition root / App layer).
- `SelectMotivationalMessageUseCase` becomes read-only: fetch + select, returning `nil` if empty.
- UI already has a safe fallback string; keep it as a last resort.

Option B (if seeding is truly a business rule):
- Keep a Domain use case like `EnsureDefaultMessagesSeededUseCase`.
- Call it once at startup.
- Keep repository protocol free of “seed” verbs unless domain explicitly requires it.

## Acceptance Criteria

- [ ] Exactly one seeding implementation path exists (no duplicated logic).
- [ ] `SelectMotivationalMessageUseCase` does not mutate storage as a side effect.
- [ ] Domain repository protocol does not expose infrastructure/bootstrap operations.
- [ ] UI testing mode behavior is explicit (seeded or not) and predictable.

