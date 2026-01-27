# DEBT-011: Recording File Lifecycle Not Managed (Orphan Files Risk)

**Priority:** P2 (Privacy / Data Hygiene)
**Status:** OPEN
**Created:** 2026-01-27
**Last Audited:** 2026-01-27

## Problem

`RecordingRepository.delete(id:)` deletes the SwiftData model but does not delete the on-disk recording file referenced by `RecordingEntity.filePath` (and optional thumbnail).

There is a `FileStorageManager` capable of deleting individual recording files, but it is not currently wired into any recording deletion path.

`SwiftDataDeleteAllUserDataUseCase` *does* delete the entire `Documents/Recordings/` directory (staged/rollback-safe), but that only covers the “delete all data” flow.

## Impact

- Orphaned recording files can remain on-device after deleting a recording (privacy risk).
- Storage can grow without an obvious in-app reason.

## Recommended Direction

- Add a `DeleteRecordingUseCase` that:
  1) Looks up the recording (to get paths)
  2) Deletes files (recording + thumbnail)
  3) Deletes the SwiftData model
  4) Rolls back appropriately on failures (or uses a staged approach like delete-all)

## Acceptance Criteria

- [ ] Deleting a recording removes both the SwiftData model and its on-disk files
- [ ] Unit/integration tests cover the behavior with a temporary directory-backed `FileStorageManager`
- [ ] `bash scripts/verify.sh` still passes

