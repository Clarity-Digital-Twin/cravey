# DEBT-034: Magic Numbers in LocationService, UsageLogViewModel, FileStorageManager

**Priority:** P2 (Important - Maintainability)
**Status:** OPEN
**Created:** 2026-01-29

## Problem

Several configuration values are hardcoded as magic numbers instead of named constants, making the code harder to understand and maintain.

---

## Instances Found

### 1. LocationService.swift:14

```swift
init(timeout: TimeInterval = 10.0, maxAuthRetries: Int = 10) {
```

**Issues:**
- `10.0` seconds timeout - why 10? Is this documented?
- `10` max retries - should this match timeout? Is there a relationship?

### 2. UsageLogViewModel.swift:26

```swift
var amount: Double = 0.5 // Default to first valid option for Bowls
```

**Issues:**
- `0.5` is hardcoded but should come from `ROAAmountRange`
- Comment says "first valid option for Bowls" but doesn't use `ROAAmountRange.defaultAmount(for:)`

### 3. FileStorageManager.swift:48

```swift
init(
    fileManager: FileManager = .default,
    maxTotalRecordingBytes: Int64 = 500_000_000
) {
```

**Issues:**
- `500_000_000` (500MB) is a significant limit with no named constant
- Changing this limit requires finding this buried init parameter

---

## Rob C. Martin Fix: Extract Constants

```swift
// Cravey/Domain/Entities/LocationConstants.swift
enum LocationConstants {
    /// Maximum time to wait for a location fix
    static let timeout: TimeInterval = 10.0

    /// Maximum authorization retry attempts before giving up
    static let maxAuthRetries: Int = 10
}

// Cravey/Domain/Entities/StorageLimits.swift (extend existing or new file)
extension StorageLimits {  // or ValidationLimits
    /// Maximum total storage for all recordings (500MB)
    static let maxRecordingBytes: Int64 = 500_000_000
}
```

Then update usages:

```swift
// LocationService.swift
init(
    timeout: TimeInterval = LocationConstants.timeout,
    maxAuthRetries: Int = LocationConstants.maxAuthRetries
) { ... }

// UsageLogViewModel.swift
var amount: Double = ROAAmountRange.defaultAmount(for: "Bowls")

// FileStorageManager.swift
init(
    fileManager: FileManager = .default,
    maxTotalRecordingBytes: Int64 = StorageLimits.maxRecordingBytes
) { ... }
```

---

## Files to Modify

| File | Change |
|------|--------|
| Create `Cravey/Domain/Entities/LocationConstants.swift` | New file with timeout/retry constants |
| Extend `ValidationLimits.swift` or create `StorageLimits.swift` | Add `maxRecordingBytes` |
| `LocationService.swift` | Use `LocationConstants.*` |
| `UsageLogViewModel.swift` | Use `ROAAmountRange.defaultAmount(for:)` |
| `FileStorageManager.swift` | Use `StorageLimits.maxRecordingBytes` |

---

## Acceptance Criteria

- [ ] All magic numbers replaced with named constants
- [ ] Constants have documentation explaining the value
- [ ] Single source of truth for each configuration value
- [ ] All tests pass
