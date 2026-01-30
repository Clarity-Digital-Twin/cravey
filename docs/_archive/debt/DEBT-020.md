# DEBT-020: Silent Error Suppression in Delete All Data Flow

**Priority:** P2 (Important - Data Hygiene)
**Status:** RESOLVED
**Created:** 2026-01-28
**Resolved:** 2026-01-28
**Resolution:** Implemented OSLog warning logs for best-effort cleanup failures in `SwiftDataDeleteAllUserDataUseCase`.

## Problem

`try?` silently swallows errors during file cleanup, potentially leaving orphaned files.

**File:** `Cravey/Data/UseCases/SwiftDataDeleteAllUserDataUseCase.swift`

```swift
// Lines 119-121 - SILENT FAILURE
let existingItems = (try? fileManager.contentsOfDirectory(...)) ?? []
for url in existingItems where url.lastPathComponent.hasPrefix(stagedPrefix) {
    try? fileManager.removeItem(at: url)  // Errors ignored
}
```

**Risk:**
- Orphaned temporary files accumulate silently
- User believes data is deleted when it's not
- No way to diagnose cleanup failures

---

## Files to Modify

| File | Lines | Fix |
| --- | --- | --- |
| `SwiftDataDeleteAllUserDataUseCase.swift` | 119-121 | Log errors even if best-effort cleanup |

---

## Recommended Fix

```swift
import OSLog

private static let logger = Logger(subsystem: "com.cravey", category: "DeleteAllData")

// Instead of:
try? fileManager.removeItem(at: url)

// Use:
do {
    try fileManager.removeItem(at: url)
} catch {
    logger.warning("Failed to remove staged file \(url.lastPathComponent): \(error.localizedDescription)")
    // Continue - best effort cleanup
}
```

---

## Acceptance Criteria

- [x] Cleanup errors are logged (not silently swallowed)
- [x] Best-effort cleanup continues even on individual failures
- [x] Logger added if not present
- [x] Delete all still works end-to-end
