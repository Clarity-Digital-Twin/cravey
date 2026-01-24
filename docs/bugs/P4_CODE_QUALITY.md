# P4 - Code Quality Issues

**Status:** ACTIVE
**Last Updated:** 2025-01-24

Code smells, style issues, minor improvements.

---

## QUALITY-001: Print Statements in Production Code

**Files:**
- `ModelContainerSetup.swift:94,130`
- `DashboardViewModel.swift:73`

### Problem
```swift
print("[ModelContainerSetup] Failed to seed default messages: \(error)")
print("[DashboardViewModel] Failed to load metrics: \(error)")
```

### Fix
Use proper logging:
```swift
import OSLog

private let logger = Logger(subsystem: "com.cravey", category: "DataSetup")

logger.error("Failed to seed messages: \(error.localizedDescription)")
```

---

## QUALITY-002: SettingsViewModel Mixed Concerns

**File:** `Cravey/Presentation/ViewModels/SettingsViewModel.swift`
**Lines:** Full file (172 lines)

### Problem
Single ViewModel handles:
- Export data logic
- Delete all data logic
- Data transformation (model → export format)

### Fix
Split into focused ViewModels:
- `ExportViewModel` - Export functionality
- `SettingsViewModel` - Just settings UI state

---

## QUALITY-003: FileStorageManager No Size Limits

**File:** `Cravey/Data/Storage/FileStorageManager.swift`

### Problem
Recording files saved without:
- Maximum file size check
- Total storage quota
- Cleanup strategy for old files

### Impact
User could fill device storage with recordings.

### Fix
Add storage management:
```swift
func canSaveFile(size: Int64) -> Bool {
    let currentUsage = calculateStorageUsage()
    let maxAllowed: Int64 = 500_000_000 // 500MB
    return (currentUsage + size) <= maxAllowed
}
```

---

## QUALITY-004: Incomplete Mappers (Stubs)

**Files:**
- `Data/Mappers/RecordingMapper.swift`
- `Data/Mappers/MessageMapper.swift`

### Problem
These mappers exist but may not properly map all fields since Recording/Message features aren't implemented.

### Risk
If used, could cause data loss or corruption.

### Fix
Mark as not-implemented:
```swift
enum RecordingMapper {
    static func toEntity(_ model: RecordingModel) -> RecordingEntity {
        fatalError("RecordingMapper not implemented - see docs/future/RECORDINGS_SPEC.md")
    }
}
```

---

## QUALITY-005: RecordingModel Missing @Attribute(.unique)

**File:** `Cravey/Data/Models/RecordingModel.swift:8`

### Problem
```swift
var id: UUID = UUID()  // Missing @Attribute(.unique)
```

Other models have it:
```swift
@Attribute(.unique) var id: UUID = UUID()  // CravingModel, UsageModel
```

### Fix
Add consistency:
```swift
@Attribute(.unique) var id: UUID = UUID()
```

---

## QUALITY-006: DashboardViewModel Redundant Calculation

**File:** `Cravey/Presentation/ViewModels/DashboardViewModel.swift`
**Lines:** 47-51, 111

### Problem
```swift
currentStreak = calculateCurrentStreak(usages: usages)  // Calculates streak
longestStreak = calculateLongestStreak(usages: usages)  // Recalculates similar logic
```

Inside `calculateLongestStreak`:
```swift
longestDays = max(longestDays, currentStreak)  // Uses local var, not the class property
```

### Fix
Calculate once, reuse:
```swift
let (current, longest) = calculateStreaks(usages: usages)
currentStreak = current
longestStreak = longest
```

---

## QUALITY-007: Calendar Fallback May Be Wrong

**File:** `Cravey/Presentation/ViewModels/DashboardViewModel.swift`
**Lines:** 55-56

### Problem
```swift
let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now
```

If date calculation fails, falls back to `now`, which means:
- 7-day filter would include ALL data
- 30-day filter would include ALL data

### Fix
This should never fail, but if it does:
```swift
guard let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now),
      let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now) else {
    Logger.error("Calendar calculation failed - this should never happen")
    return  // Don't proceed with bad data
}
```

---

## QUALITY-008: Test Mock Incomplete

**File:** `CraveyTests/Domain/UseCases/LogCravingUseCaseTests.swift:71`

### Problem
```swift
func update(_ entity: CravingEntity) async throws {
    // Mock implementation
}
```

Empty stub - if called, test would silently pass when it shouldn't.

### Fix
```swift
func update(_ entity: CravingEntity) async throws {
    updateCallCount += 1
    lastUpdatedEntity = entity
}
```

---

## Summary

| Quality ID | Description | Effort |
|------------|-------------|--------|
| QUALITY-001 | Print statements | Low |
| QUALITY-002 | SettingsVM mixed concerns | Medium |
| QUALITY-003 | No storage limits | Medium |
| QUALITY-004 | Incomplete mappers | Low |
| QUALITY-005 | Missing @Attribute | Low |
| QUALITY-006 | Redundant calculation | Low |
| QUALITY-007 | Calendar fallback | Low |
| QUALITY-008 | Test mock incomplete | Low |
