# P0 - Critical Bugs

**Status:** ACTIVE
**Last Updated:** 2025-01-24

These bugs can cause crashes, data loss, or prevent the app from running.

---

## BUG-001: DependencyContainer fatalError on Init Failure

**File:** `Cravey/App/DependencyContainer.swift`
**Line:** 93

### Problem
```swift
} catch {
    fatalError("Failed to initialize DependencyContainer: \(error)")
}
```

If ModelContainer or repository setup fails (disk full, corrupted data, etc.), the entire app crashes immediately with no recovery option.

### Impact
- App won't launch
- User loses all data access
- No way to recover without reinstalling

### Fix
Replace `fatalError` with proper error propagation:
```swift
// Option 1: Throwing initializer
init() throws {
    do {
        // setup...
    } catch {
        throw DependencyContainerError.initializationFailed(error)
    }
}

// Option 2: Fallback to in-memory storage
catch {
    print("[ERROR] Failed to init persistent storage, using in-memory: \(error)")
    // Initialize with in-memory ModelContainer as fallback
}
```

### Acceptance Criteria
- [ ] App doesn't crash on init failure
- [ ] User sees error message if storage unavailable
- [ ] Fallback to read-only or in-memory mode if possible

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
| BUG-001 | fatalError in DependencyContainer | OPEN |
| BUG-002 | Swift 6 reduceMotion concurrency | ✅ FIXED |
