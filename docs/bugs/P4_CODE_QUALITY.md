# P4 - Code Quality Issues

**Status:** ACTIVE
**Last Updated:** 2026-01-24

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

## QUALITY-004: Incomplete Mappers (Stubs) ❌ INCORRECT / OUTDATED

**Files:**
- `Data/Mappers/RecordingMapper.swift`
- `Data/Mappers/MessageMapper.swift`

### Finding
Both mappers are implemented and map fields in both directions:
- `Cravey/Data/Mappers/RecordingMapper.swift`
- `Cravey/Data/Mappers/MessageMapper.swift`

### Action
- Mark this issue as **CLOSED** (documentation was stale).

---

## QUALITY-005: RecordingModel Missing @Attribute(.unique)

**File:** `Cravey/Data/Models/RecordingModel.swift:8`

### Problem
```swift
var id: UUID  // Missing @Attribute(.unique)
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

## QUALITY-009: MotivationalMessageModel Missing @Attribute(.unique)

**File:** `Cravey/Data/Models/MotivationalMessageModel.swift:8`

### Problem
`MotivationalMessageModel.id` is not marked unique, unlike `CravingModel` and `UsageModel`.

### Impact
Potential for duplicate IDs and harder-to-reason-about fetch/update logic if messages become user-editable.

### Fix
Add:
```swift
@Attribute(.unique) var id: UUID
```

---

## QUALITY-010: Unused Recording Infrastructure (Dead Code in Current App)

**Files:**
- `Cravey/App/DependencyContainer.swift:13,73`
- `Cravey/Data/Storage/FileStorageManager.swift` (multiple unused public methods)

### Problem
Recording infrastructure exists, but is not used by any ViewModel/View:
- `DependencyContainer.fileStorage` is never referenced outside initialization.
- `FileStorageManager` APIs like `saveRecording`, `generateThumbnail`, `getDuration`, and `getTotalStorageUsed` have no call sites in the app.

### Impact
- Increases maintenance surface area and cognitive load.
- Makes it easy for future work to wire recording behavior inconsistently with master specs.

### Fix
- Either implement the Recordings feature end-to-end (preferred) or remove/feature-flag unused APIs until the feature is ready.

---

## QUALITY-006: DashboardViewModel Redundant Calculation

**File:** `Cravey/Presentation/ViewModels/DashboardViewModel.swift`
**Lines:** 47-51, 111

### Problem
```swift
currentStreak = calculateCurrentStreak(usages: usages)  // Calculates streak
longestStreak = calculateLongestStreak(usages: usages)  // Recalculates similar logic
```

Note: `calculateLongestStreak` currently references the **property** `currentStreak` (not a local variable), but still re-sorts usages and duplicates date math.

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
| QUALITY-004 | Incomplete mappers (outdated doc) | Low |
| QUALITY-005 | Missing @Attribute | Low |
| QUALITY-009 | Missing @Attribute | Low |
| QUALITY-010 | Unused recording infrastructure | Low |
| QUALITY-006 | Redundant calculation | Low |
| QUALITY-007 | Calendar fallback | Low |
| QUALITY-008 | Test mock incomplete | Low |
