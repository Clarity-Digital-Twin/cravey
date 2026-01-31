# DEBT-053: Test Suite Magic Numbers & Structure Alignment

**Created:** 2026-01-31
**Priority:** P4 (Code quality - fix opportunistically)
**Status:** ✅ RESOLVED
**Resolved:** 2026-01-31

## Resolution

- Added `CraveyTests/Support/TestConstants.swift` (`TestConstants`, `FixedClock`).
- Replaced remaining time math (`3600`, `86400`, fixed epoch) with `TestConstants.Time` / `TestConstants.fixedEpoch`.
- Replaced remaining notes-length fixtures (`500`, `501`) with `TestConstants.Notes` / `ValidationLimits`.
- Removed non-essential `Date()` usage in tests (kept only where explicitly testing `Date()` fallback or performance timing).

## Problem

Test files contain magic numbers that should reference production constants, and test folder structure doesn't perfectly mirror source structure.

### Magic Numbers Found

| Magic Number | Meaning | Should Use |
|--------------|---------|------------|
| `500`, `501` | Notes max length | `ValidationLimits.notesMaxLength` |
| `86400` | Seconds per day | `TimeConstants.secondsPerDay` (new) |
| `3600` | Seconds per hour | `TimeConstants.secondsPerHour` (new) |
| `10_000_000` | Test storage limit | `InfrastructureConstants.Storage.maxRecordingBytes` or test-specific |
| `24` | Hours in day | `TimeConstants.hoursPerDay` (new) |

### Folder Structure Gap

Tests use `Integration/` folder for Data layer tests rather than mirroring `Data/Mappers/`, `Data/Repositories/`, etc. This is a valid pattern (integration tests with real SwiftData) but inconsistent with Domain/Presentation mirroring.

## Why P4

1. **Tests still pass** - no functional impact
2. **Production code is clean** - constants already exist where business logic lives
3. **Test magic numbers are somewhat self-documenting** - test names explain intent
4. **High effort, low ROI** - dozens of files to update

## Proposed Fix (When Opportunistic)

### Option A: Add TestConstants

Create `CraveyTests/Support/TestConstants.swift`:

```swift
import Foundation
@testable import Cravey

/// Test-specific constants that extend production constants
enum TestConstants {
    /// Time intervals for date arithmetic in tests
    enum Time {
        static let secondsPerHour: TimeInterval = 3600
        static let secondsPerDay: TimeInterval = 86400
        static let hoursPerDay = 24
    }

    /// Fixed epoch for deterministic date testing
    /// Using Sept 9, 2001 00:46:40 UTC (arbitrary but stable)
    static let fixedEpoch = Date(timeIntervalSince1970: 1_000_000_000)
}
```

Update tests to use:
```swift
// Before
let longNotes = String(repeating: "a", count: 501)
let old = now.addingTimeInterval(-86400)

// After
let longNotes = String(repeating: "a", count: ValidationLimits.notesMaxLength + 1)
let old = now.addingTimeInterval(-TestConstants.Time.secondsPerDay)
```

### Option B: Accept Current State

Document that test magic numbers are acceptable test fixtures and close this debt item.

## Files Affected

- `CraveyTests/Integration/*.swift` (6 files)
- `CraveyTests/Domain/UseCases/*.swift` (7 files)
- `CraveyTests/Domain/Entities/*.swift` (2 files)
- `CraveyTests/Presentation/ViewModels/*.swift` (7 files)

## Uncle Bob's Principle

> "Magic numbers should be hidden behind well-named constants" - *Clean Code*

However, tests serve as documentation. A test named `"Should reject notes longer than 500 characters"` with `count: 501` is readable. The risk is if `ValidationLimits.notesMaxLength` changes, tests become inconsistent.

## Decision

- [x] Implement Option A (add TestConstants)
- [ ] Implement Option B (accept and close)
- [ ] Defer (keep as P4 debt)
