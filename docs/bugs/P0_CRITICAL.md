# P0 - Critical Bugs

**Status:** ACTIVE
**Last Updated:** 2026-01-24

These bugs can cause crashes, data loss, or prevent the app from running.

---

## BUG-001: DependencyContainer fatalError on Init Failure

**File:** `Cravey/App/DependencyContainer.swift`
**Verify:** `rg -n "Falling back to in-memory" Cravey/App/DependencyContainer.swift`

### Problem
Historical snippet (no longer present):

```swift
} catch {
    fatalError("Failed to initialize DependencyContainer: \\(error)")
}
```

If ModelContainer or repository setup fails (disk full, corrupted data, etc.), the entire app crashes immediately with no recovery option.

### Impact
- App won't launch
- User loses all data access
- No way to recover without reinstalling

### Status
✅ **FIXED** (2026-01-24)

### Fix Implemented
- Persistent init failure no longer crashes the app.
- App falls back to an in-memory SwiftData container and surfaces a user-facing alert.

**Related Files:**
- `Cravey/App/DependencyContainer.swift`
- `Cravey/App/CraveyApp.swift` (alert UI)

### Acceptance Criteria
- [x] App does not crash on persistent storage init failure
- [x] In-memory fallback mode activates
- [x] User sees a storage-unavailable alert

---

## BUG-002: Swift 6 Concurrency - DashboardView reduceMotion ✅ FIXED

**File:** `Cravey/Presentation/Views/Dashboard/DashboardView.swift`
**Lines:** 120-121, 189-190, 245-246, 309-310

### Problem
~~`@Environment(\.accessibilityReduceMotion)` accessed inside `@Sendable` `.scrollTransition {}` closures.~~

### Status
**FIXED** in commit `0a19b34` - Captured value before closure in all 4 card components.

---

## Summary

| Bug ID | Description | Status |
|--------|-------------|--------|
| BUG-001 | fatalError in DependencyContainer | ✅ FIXED |
| BUG-002 | Swift 6 reduceMotion concurrency | ✅ FIXED |
