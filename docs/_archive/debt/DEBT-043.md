# DEBT-043: FileStorageManager has unused APIs and non-ideal save semantics (copy + temp cleanup)

**Priority:** P3 (Storage correctness / maintainability)
**Status:** ✅ RESOLVED
**Created:** 2026-01-30
**Resolved:** 2026-01-30

## Resolution

- Removed unused `deleteAllRecordings()` API.
- Updated save semantics to prefer `moveItem` and clean up temp files.
- Made `deleteRecording` idempotent to match `deleteThumbnail`.

## Problem

`FileStorageManager` contains functionality that is currently unused and/or has semantics that could be improved:

1. `deleteAllRecordings()` exists but is not referenced anywhere in the codebase.
2. `saveRecording(from:)` uses `copyItem` (duplicate bytes) and does not remove the temp file it copies from.

While not necessarily broken today, these are classic “halfway” signals and can become storage bloat or maintenance traps.

## Location

- `Cravey/Data/Storage/FileStorageManager.swift`
  - `saveRecording(from:)` (copy semantics)
  - `deleteAllRecordings()` (lines ~207–224)

## Proposed Fix

- Decide ownership:
  - If bulk delete is needed, wire it into `DeleteAllUserDataUseCase` (or remove the method until it’s needed).
- Prefer `moveItem` when possible (or `copy` + explicit delete of temp) to avoid double disk usage.
- Make delete operations idempotent:
  - treat “file not found” as a no-op for delete paths.

## Acceptance Criteria

- [x] No unused public APIs in `FileStorageManager` (either wired or removed).
- [x] Recording save does not leave behind temp artifacts.
- [x] Delete operations are idempotent and do not spam logs for expected missing files.
