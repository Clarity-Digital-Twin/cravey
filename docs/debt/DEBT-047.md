# DEBT-047: Missing targeted integration tests for MessageRepository and FileStorageManager edge cases

**Priority:** P3 (Correctness hardening / regression prevention)
**Status:** OPEN
**Created:** 2026-01-30

## Problem

The app has good coverage for cravings/usages end-to-end, and UI tests pass. However, there are still high-risk areas with minimal/no direct integration coverage:

1. **MessageRepository**
   - No integration tests for `seedDefaultMessagesIfNeeded()` or `update(_:)` behavior.
   - Edge cases: ensuring `modifiedAt`, `lastShownAt`, `timesShown` persist correctly and deterministically.

2. **FileStorageManager**
   - No tests covering `saveRecording(from:)` semantics:
     - Replace behavior when destination already exists.
     - Storage limit enforcement.
     - Temp file cleanup guarantees.

These areas are exactly where “it works on my machine” bugs and regressions tend to hide.

## Location

- `Cravey/Data/Repositories/MessageRepository.swift`
- `Cravey/Data/Storage/FileStorageManager.swift`
- Suggested new tests under `CraveyTests/Integration/`

## Proposed Fix

Add a small set of fast integration tests:

- `MessageRepositoryIntegrationTests`
  - Seeds defaults when empty.
  - Does not seed when non-empty.
  - `update(_:)` persists `modifiedAt` from the entity (and does not silently overwrite it).

- `FileStorageManagerTests`
  - Saving to a path that already exists replaces atomically (no data loss / no partial state).
  - Exceeding `maxTotalRecordingBytes` throws `storageLimitExceeded`.
  - On fallback copy path, temp files are removed best-effort.

If the current `FileStorageManager` API makes this awkward, add a minimal test seam:
- injectable base directory (instead of always using `.documentDirectory`), scoped to tests only.

## Acceptance Criteria

- [ ] Integration tests exist for MessageRepository seeding + update semantics.
- [ ] Integration tests exist for FileStorageManager overwrite + storage limit behavior.
- [ ] Tests are deterministic and clean up any on-disk artifacts they create.

