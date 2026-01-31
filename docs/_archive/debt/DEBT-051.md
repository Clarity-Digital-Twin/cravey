# DEBT-051: Missing CravingEntity Unit Tests

**Created:** 2026-01-31
**Resolved:** 2026-01-31
**Priority:** P2 (Important)
**Status:** ✅ RESOLVED

## Resolution

- Added `CraveyTests/Domain/Entities/CravingEntityTests.swift`.

## Problem

`CravingEntity` has helper methods (`isWithinLast(_:now:)`) that are business logic but have no unit tests. DEBT-038 added the `now` parameter for testability, but no tests were added.

## Current State

- Entity exists with `isWithinLast` method
- Method is used by DashboardViewModel for streak calculation
- No direct unit tests

## Missing Tests

1. **isWithinLast returns true for recent timestamp**
2. **isWithinLast returns false for old timestamp**
3. **isWithinLast boundary condition** - exactly N hours ago

## Solution

Add `CraveyTests/Domain/Entities/CravingEntityTests.swift`:

```swift
@Suite("CravingEntity Tests")
struct CravingEntityTests {
    @Test("isWithinLast returns true for recent craving")
    func isWithinLastTrueForRecent() {
        let now = Date(timeIntervalSince1970: 1_000_000_000)
        let craving = CravingEntity(
            timestamp: now.addingTimeInterval(-3600), // 1 hour ago
            intensity: 5
        )

        #expect(craving.isWithinLast(24, now: now) == true)
    }

    @Test("isWithinLast returns false for old craving")
    func isWithinLastFalseForOld() {
        let now = Date(timeIntervalSince1970: 1_000_000_000)
        let craving = CravingEntity(
            timestamp: now.addingTimeInterval(-86400 * 2), // 2 days ago
            intensity: 5
        )

        #expect(craving.isWithinLast(24, now: now) == false)
    }

    @Test("isWithinLast boundary - exactly N hours ago")
    func isWithinLastBoundary() {
        let now = Date(timeIntervalSince1970: 1_000_000_000)
        let craving = CravingEntity(
            timestamp: now.addingTimeInterval(-24 * 3600), // Exactly 24h ago
            intensity: 5
        )

        // Exactly on boundary should be included
        #expect(craving.isWithinLast(24, now: now) == true)
    }

    @Test("isWithinLast just past boundary")
    func isWithinLastPastBoundary() {
        let now = Date(timeIntervalSince1970: 1_000_000_000)
        let craving = CravingEntity(
            timestamp: now.addingTimeInterval(-24 * 3600 - 1), // 24h + 1s ago
            intensity: 5
        )

        #expect(craving.isWithinLast(24, now: now) == false)
    }
}
```

## Files to Create/Modify

- Create: `CraveyTests/Domain/Entities/CravingEntityTests.swift`

## Verification

```bash
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests/CravingEntityTests | xcbeautify
```
