# DEBT-010: Home Motivation Card Not Backed by Message Repository

**Priority:** P3 (Architecture / Feature Completeness)
**Status:** OPEN
**Created:** 2026-01-27
**Last Audited:** 2026-01-27

## Problem

We persist and seed default motivational messages (`MotivationalMessageModel` + `MessageRepository`), but the Home tab currently selects a message deterministically from defaults and does not:

- Fetch active messages from persistence
- Track `timesShown` / `lastShownAt`
- Prefer category/context (urge/anxiety/boredom/social/celebration)
- Support custom messages (future UI)

This creates a “half-wired” vertical slice: data exists, but the UI doesn’t use it.

## Impact

- Duplicate sources of truth for motivational copy
- No feedback loop to improve message selection quality over time
- Makes future “custom messages” feature harder (UI isn’t already repository-backed)

## Recommended Direction

- Introduce a small `FetchMotivationalMessageUseCase` (or `SelectMotivationalMessageUseCase`) in Domain.
- Back it with `MessageRepository` in Data.
- Add a lightweight view model for Home motivation state (or extend `DashboardViewModel` with a dedicated dependency).
- Update message metadata (`markAsShown`) when displayed.

## Acceptance Criteria

- [ ] Home motivation message is fetched from `MessageRepository` (not hard-coded)
- [ ] Displaying a message updates `timesShown` / `lastShownAt`
- [ ] Unit tests cover selection + metadata updates

