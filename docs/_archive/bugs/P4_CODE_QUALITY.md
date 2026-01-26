# P4 - Code Quality Issues

**Status:** ACTIVE
**Last Updated:** 2026-01-25

Code smells, style issues, minor improvements.

---

## QUALITY-001: Print Statements in Production Code

**Files:**
- `Cravey/Data/Storage/ModelContainerSetup.swift`
- `Cravey/Presentation/ViewModels/DashboardViewModel.swift`
**Verify:** `! rg -n "\\bprint\\(" Cravey/Data/Storage/ModelContainerSetup.swift Cravey/Presentation/ViewModels/DashboardViewModel.swift` (should return no matches)

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

### Status
✅ **FIXED** (2026-01-24)

---

## QUALITY-002: SettingsViewModel Mixed Concerns

**File:** `Cravey/Presentation/ViewModels/SettingsViewModel.swift`

### Problem
Single ViewModel handles:
- Export data logic
- Delete all data logic
- Data transformation (model → export format)

### Fix
Split into focused ViewModels:
- `ExportViewModel` - Export functionality
- `SettingsViewModel` - Just settings UI state

### Status
✅ **CLOSED** (2026-01-24)

### Rationale
SettingsViewModel no longer depends on SwiftData/models; data export + deletion are behind use cases. Remaining work
(JSON encoding + share sheet URL) is UI/presentation responsibility and not an architecture violation.

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

### Status
✅ **FIXED** (2026-01-24)

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

**File:** `Cravey/Data/Models/RecordingModel.swift`
**Verify:** `rg -n "@Attribute\\(\\.unique\\) var id: UUID" Cravey/Data/Models/RecordingModel.swift`

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

### Status
✅ **FIXED** (2026-01-24)

---

## QUALITY-009: MotivationalMessageModel Missing @Attribute(.unique)

**File:** `Cravey/Data/Models/MotivationalMessageModel.swift`
**Verify:** `rg -n "@Attribute\\(\\.unique\\) var id: UUID" Cravey/Data/Models/MotivationalMessageModel.swift`

### Problem
`MotivationalMessageModel.id` is not marked unique, unlike `CravingModel` and `UsageModel`.

### Impact
Potential for duplicate IDs and harder-to-reason-about fetch/update logic if messages become user-editable.

### Fix
Add:
```swift
@Attribute(.unique) var id: UUID
```

### Status
✅ **FIXED** (2026-01-24)

---

## QUALITY-010: Unused Recording Infrastructure (Dead Code in Current App)

**Files:**
- `Cravey/App/DependencyContainer.swift`
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

### Status
🟡 **DEFERRED** (2026-01-24)

### Rationale
Recording infrastructure is intentionally present for the upcoming Recordings feature. `FileStorageManager` is now used
by “Delete All Data” (privacy cleanup), but recording capture/playback remains out of MVP scope for this loop.

---

## QUALITY-006: DashboardViewModel Redundant Calculation

**File:** `Cravey/Presentation/ViewModels/DashboardViewModel.swift`

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

### Status
✅ **FIXED** (2026-01-24)

---

## QUALITY-007: Calendar Fallback May Be Wrong

**File:** `Cravey/Presentation/ViewModels/DashboardViewModel.swift`

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

### Status
✅ **FIXED** (2026-01-24)

---

## QUALITY-008: Test Mock Incomplete

**File:** `CraveyTests/Domain/UseCases/LogCravingUseCaseTests.swift`

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

### Status
✅ **FIXED** (2026-01-24)

---

## QUALITY-011: Broken Internal Doc Reference (ChipSelector)

**File:** `Cravey/Presentation/Views/Components/ChipSelector.swift`
**Verify:** `rg -n "BUG_009_CHIP_SELECTOR" Cravey/Presentation/Views/Components/ChipSelector.swift`

### Problem
The code referenced `BUG_009_CHIP_SELECTOR.md`, but the actual write-up lived under `docs/_archive/…`, making the
reference effectively dead.

### Status
✅ **FIXED** (2026-01-25)

### Fix Implemented
- Updated the comment to reference:
  - `docs/_archive/specs/BUG_009_CHIP_SELECTOR_FIXED_2025-01-05.md`

---

## QUALITY-012: Logger Subsystem Inconsistency

**Files:**
- `Cravey/App/DependencyContainer.swift` (`com.cravey`)
- `Cravey/Data/Storage/ModelContainerSetup.swift` (`com.cravey`)
- `Cravey/Data/Mappers/RecordingMapper.swift` (`com.cravey.app`)
- `Cravey/Data/Mappers/MessageMapper.swift` (`com.cravey.app`)

### Problem
Logger subsystems are inconsistent, which makes filtering logs harder and increases the chance of missed signals during
debugging.

### Status
🟡 **DEFERRED** (2026-01-25)

### Recommendation
- Standardize the subsystem to the app bundle identifier (`com.cravey.app`).

---

## QUALITY-013: RecordingModel Optional Array Type Inconsistency

**File:** `Cravey/Data/Models/RecordingModel.swift`
**Verify:** `rg -n "linkedCravings: \\[CravingModel\\] = \\[\\]" Cravey/Data/Models/RecordingModel.swift`

### Problem
```swift
var linkedCravings: [CravingModel]?  // ← Optional array
```

Type semantics were unclear (optional array but always initialized as empty).

### Impact
- SwiftData may not handle optional arrays optimally
- Type semantics unclear to future maintainers

### Fix
```swift
var linkedCravings: [CravingModel] = []  // Non-optional with default
```

### Status
✅ **FIXED** (2026-01-25)

---

## QUALITY-014: LogCravingUseCase Missing Save Error Handling

**Files:**
- `Cravey/Domain/UseCases/LogCravingUseCase.swift`
- `Cravey/Domain/UseCases/LogUsageUseCase.swift`
**Verify:**
- `rg -n "saveFailed\\(underlying:" Cravey/Domain/UseCases/LogCravingUseCase.swift Cravey/Domain/UseCases/LogUsageUseCase.swift`
- `bash scripts/verify.sh`

### Problem
LogCravingUseCase and LogUsageUseCase handle repository errors inconsistently:
- LogCravingUseCase: Propagated repository errors directly
- LogUsageUseCase: Converted save failures into `UsageError.saveFailed`, losing context

### Impact
- Inconsistent error semantics between craving and usage logging
- Harder to reason about error handling and to debug save failures reliably

### Fix Implemented
- Both use cases now:
  - Re-throw `CancellationError` unchanged
  - Map repository save failures into a domain-level `.saveFailed(underlying: ...)` error, preserving underlying error
    details via `failureReason` while keeping a stable user-facing `errorDescription`.

### Status
✅ **FIXED** (2026-01-25)

---

## Summary

| Quality ID | Description | Status |
|------------|-------------|--------|
| QUALITY-001 | Print statements | ✅ FIXED |
| QUALITY-002 | SettingsVM mixed concerns | ✅ CLOSED |
| QUALITY-003 | No storage limits | ✅ FIXED |
| QUALITY-004 | Incomplete mappers (outdated doc) | ✅ CLOSED |
| QUALITY-005 | RecordingModel unique id | ✅ FIXED |
| QUALITY-009 | MotivationalMessage unique id | ✅ FIXED |
| QUALITY-010 | Unused recording infrastructure | 🟡 DEFERRED |
| QUALITY-006 | Redundant calculation | ✅ FIXED |
| QUALITY-007 | Calendar fallback | ✅ FIXED |
| QUALITY-008 | Test mock incomplete | ✅ FIXED |
| QUALITY-011 | Broken ChipSelector doc reference | ✅ FIXED |
| QUALITY-012 | Logger subsystem inconsistency | 🟡 DEFERRED |
| QUALITY-013 | RecordingModel optional array | ✅ FIXED |
| QUALITY-014 | LogCravingUseCase error handling | ✅ FIXED |
