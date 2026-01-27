# DEBT-011: Recording File Lifecycle Not Managed (Orphan Files Risk)

**Priority:** P2 (Privacy / Data Hygiene)
**Status:** CLOSED (2026-01-27)
**Created:** 2026-01-27
**Last Audited:** 2026-01-27

## Problem (Resolved)

`RecordingRepository.delete(id:)` now deletes both the SwiftData model AND the on-disk recording files.

## Solution Implemented

1. Created `RecordingFileDeleting` protocol for file deletion operations
2. `FileStorageManager` conforms to `RecordingFileDeleting`
3. `RecordingRepository` now accepts `any RecordingFileDeleting` via dependency injection
4. `delete(id:)` implementation:
   - Fetches recording to get file paths
   - Deletes SwiftData model (so UI reflects deletion immediately)
   - Deletes files best-effort (logs errors but doesn't fail)
   - Orphan files are acceptable edge case (cleaned up by "delete all data")

## Acceptance Criteria

- [x] Deleting a recording removes both the SwiftData model and its on-disk files
- [x] Unit/integration tests cover the behavior with mock `RecordingFileDeleting`
- [x] `bash scripts/verify.sh` still passes

## Files Changed

- `Cravey/Data/Storage/FileStorageManager.swift` - Added `RecordingFileDeleting` protocol
- `Cravey/Data/Repositories/RecordingRepository.swift` - Inject file storage, delete files in `delete(id:)`
- `Cravey/App/DependencyContainer.swift` - Pass `FileStorageManager` to `RecordingRepository`
- `CraveyTests/Integration/RecordingRepositoryTests.swift` - 5 new tests

