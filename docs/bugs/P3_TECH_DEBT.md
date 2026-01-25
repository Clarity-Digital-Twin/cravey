# P3 - Tech Debt

**Status:** ACTIVE
**Last Updated:** 2026-01-25

Architecture violations, incomplete implementations, design issues that need addressing.

---

## DEBT-001: SettingsViewModel Violates Clean Architecture 🔴

**File:** `Cravey/Presentation/ViewModels/SettingsViewModel.swift`
**Lines:** 6, 48-49

### Problem
ViewModel directly imports and uses Data layer classes:
```swift
import SwiftData  // ❌ Presentation should not import Data framework

// Direct access to models
let cravings = try context.fetch(FetchDescriptor<CravingModel>())
let usages = try context.fetch(FetchDescriptor<UsageModel>())
```

### Violation
**Clean Architecture Rule:** Presentation → Domain ← Data

SettingsViewModel bypasses Domain layer entirely:
```
Current:   SettingsViewModel → Data (CravingModel, UsageModel)
Should be: SettingsViewModel → Domain (ExportDataUseCase, DeleteAllDataUseCase)
```

### Impact
- Breaks testability (can't mock without SwiftData)
- Couples UI to persistence framework
- Makes future changes harder

### Fix
1. Create Domain use cases:
```swift
// Domain/UseCases/ExportDataUseCase.swift
protocol ExportDataUseCase {
    func execute() async throws -> ExportData
}

// Domain/UseCases/DeleteAllDataUseCase.swift
protocol DeleteAllDataUseCase {
    func execute() async throws
}
```

2. Implement in Data layer
3. Inject into SettingsViewModel via DependencyContainer

### Acceptance Criteria
- [x] SettingsViewModel has no SwiftData imports
- [x] Export/Delete logic lives behind Domain use cases
- [x] SettingsViewModel depends only on use case protocols

### Status
✅ **FIXED** (2026-01-24)

---

## DEBT-002: UI Tests Are Brittle / Out-of-Sync

**Files:**
- `CraveyUITests/CraveyUITests.swift`
- `CraveyUITests/UsageLogUITests.swift`
- `CraveyUITests/Phase1ScreenshotTests.swift`

### Problem
The UI tests currently have multiple reliability issues:
- Heavy use of `sleep()` for timing (flaky under load / CI).
- Screenshot-style tests are tightly coupled to UI structure and strings.
- At least one test uses a trigger option that does not exist in the app UI (`"Stressed"`).
- Uses `nonisolated(unsafe)` for `XCUIApplication` storage (works, but is a concurrency escape hatch).

### Impact
- UI tests cannot be treated as a stable gate for regressions.
- Higher risk of false failures (wasted time) or false confidence (tests not asserting the right thing).

### Fix
- Remove `sleep()` and replace with `waitForExistence` + explicit accessibility identifiers.
- Update tests to match real UI text/options (e.g., remove `"Stressed"` chip expectation).
- Prefer `@MainActor` + `setUpWithError()` (or async `setUp()` where appropriate), and avoid `nonisolated(unsafe)` unless required.
- Keep “screenshot capture” tests out of required CI gating (or mark them skipped).

### Status
✅ **FIXED (Stability Improvements)** (2026-01-24)

**Verify:**
- `rg -n \"\\bsleep\\(\" CraveyUITests` (should return no matches)

---

## DEBT-003: Deferred Phase Features (Quick Play, GPS Location)

**Files:**
- `Cravey/Presentation/Views/Home/HomeView.swift` - `PHASE_4: Quick Play section (Recordings)`
- `Cravey/Presentation/Views/Components/LocationOptions.swift` - `PHASE_2: Wire CoreLocation GPS detection`
**Verify:** `rg -n "PHASE_4:|PHASE_2:" Cravey/Presentation/Views/Home/HomeView.swift Cravey/Presentation/Views/Components/LocationOptions.swift`

### Impact
Features specified in master specs but not implemented.

### Decision
These are deferred to future phases, but should remain explicitly referenced (and searchable) in code with `PHASE_X`
markers that link back to the authoritative spec section.

---

## DEBT-004: Missing Error Recovery in App Init

**File:** `Cravey/App/DependencyContainer.swift`

### Problem
No try-catch around ModelContainer creation. If it fails, app crashes.

### Related To
BUG-001 (P0) - Same root cause.

### Status
✅ **FIXED** (2026-01-24)

---

## DEBT-005: DashboardViewModel Streak Logic Unclear

**File:** `Cravey/Presentation/ViewModels/DashboardViewModel.swift`
**Lines:** 79-114

### Problem
Streak calculation logic is confusing:
- `calculateCurrentStreak()` - Days since last usage
- `calculateLongestStreak()` - Longest gap between usages

### Questions
1. Is "streak" days clean, or days between usages?
2. What if user has never used? (streak = days since install?)
3. What if user uses multiple times per day?

### Fix
1. Add clear documentation for streak semantics
2. Add unit tests for edge cases
3. Consider renaming: `daysSinceLastUsage`, `longestCleanPeriod`

### Status
✅ **FIXED** (2026-01-24)

**Verify:**
- `CraveyTests/Presentation/ViewModels/DashboardViewModelTests.swift`

---

## DEBT-006: Motivational Message Model/Domain Drift vs Master Spec

**Files:**
- `Cravey/Domain/Entities/MotivationalMessageEntity.swift:42-49`
- `Cravey/Data/Models/MotivationalMessageModel.swift:8-17`

### Problem
Master specs define message categories like `"urge"`, `"anxiety"`, `"boredom"`, `"social"`, `"celebration"` plus fields like `isCustom` and `priority`. Current code uses a different category set and different field naming (`isUserCreated`, `displayPriority`, plus `wasHelpful`).

### Impact
- Implementing the Motivational Messages UI per `docs/master/` will require schema + domain alignment and likely a migration.
- Risk of building UI against the wrong data semantics.

### Fix
- Decide whether to align code to `docs/master/` (authoritative) or update master specs (requires product/clinical approval).
- If aligning to master:
  - Update `MessageCategory` cases and raw values.
  - Align model fields (`isCustom`, `priority`, `modifiedAt`, etc.).
  - Update seeding logic and mappers.
  - Add migration notes/tests for existing data.

### Status
✅ **FIXED** (2026-01-24)

**Verify:**
- `Cravey/Domain/Entities/MotivationalMessageEntity.swift` (categories + fields)
- `Cravey/Data/Models/MotivationalMessageModel.swift` (spec fields)

---

## DEBT-007: Recording Model Drift vs Master Spec (Fields + Naming)

**Files:**
- `Cravey/Data/Models/RecordingModel.swift:8-23`
- `Cravey/Domain/Entities/RecordingEntity.swift:5-16`

### Problem
The master data model spec includes fields like `timestamp`, `modifiedAt`, `filePath`, and `thumbnailPath`. Current `RecordingModel` uses different naming (`createdAt`, `fileURL`, `thumbnailURL`) and omits some spec fields.

### Impact
- Recording feature implementation (recordings tab, quick play, attachments) is blocked without agreeing on the schema.
- Increased migration risk once recordings are actually written to disk/database.

### Fix
- Choose a single source of truth (prefer `docs/master/DATA_MODEL_SPEC.md`).
- Align `RecordingModel` + `RecordingEntity` + `RecordingMapper` accordingly before shipping recordings UI.

### Status
✅ **FIXED** (2026-01-24)

**Verify:**
- `Cravey/Domain/Entities/RecordingEntity.swift` (timestamp/type/purpose/filePath)
- `Cravey/Data/Models/RecordingModel.swift` (spec fields)

---

## DEBT-008: Verification Script Didn’t Compile iOS (Platform Blind Spot)

**File:** `scripts/verify.sh`
**Verify:** `bash scripts/verify.sh`

### Problem
`scripts/verify.sh` only ran Mac Catalyst unit tests. iOS Simulator builds could be broken without failing the primary
verification gate.

### Impact
- Platform-specific regressions can slip through (iOS vs Mac Catalyst)
- “Green verify” can be a false completion signal

### Status
✅ **FIXED** (2026-01-25)

### Fix Implemented
- Added an iOS Simulator compile step to `scripts/verify.sh` (defaults to `iPhone 17 Pro`, override via
  `IOS_SIMULATOR_NAME`).

---

## DEBT-009: FileStorageManager Performs Potentially Heavy I/O on MainActor

**File:** `Cravey/Data/Storage/FileStorageManager.swift`
**Verify:** `rg -n "@MainActor\\s*\\n\\s*final class FileStorageManager" Cravey/Data/Storage/FileStorageManager.swift`

### Problem
`FileStorageManager` is `@MainActor`, but contains synchronous file operations that can become expensive:
- Copying large media files
- Directory enumeration
- Thumbnail generation

### Impact
- Risk of UI stalls once recordings are implemented and heavily used

### Status
🟡 **DEFERRED** (2026-01-25)

### Recommendation
- Keep UI-facing APIs `async` and move heavy file work off-main (structured tasks / background executor), while still
  keeping state updates on MainActor.

---

## Summary

| Debt ID | Description | Impact | Status |
|---------|-------------|--------|--------|
| DEBT-001 | SettingsViewModel Clean Arch violation | High | ✅ FIXED |
| DEBT-002 | UI Tests brittle / out-of-sync | Medium | ✅ FIXED |
| DEBT-003 | Deferred phase features | Low | DEFERRED |
| DEBT-004 | No error recovery in init | High | ✅ FIXED |
| DEBT-005 | Streak logic unclear | Medium | ✅ FIXED |
| DEBT-006 | Message schema/category drift | Medium | ✅ FIXED |
| DEBT-007 | Recording schema drift | Medium | ✅ FIXED |
| DEBT-008 | Verify script platform blind spot | High | ✅ FIXED |
| DEBT-009 | File I/O on MainActor | Medium | DEFERRED |
