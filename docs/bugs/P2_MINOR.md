# P2 - Minor Bugs

**Status:** ACTIVE
**Last Updated:** 2026-01-25

UI glitches, edge case issues, style violations.

---

## BUG-007: FileStorageManager Silent Directory Failure

**File:** `Cravey/Data/Storage/FileStorageManager.swift`
**Verify:** `rg -n \"Failed to resolve Documents directory\" Cravey/Data/Storage/FileStorageManager.swift`

### Status
✅ **FIXED** (2026-01-24)

### Problem
```swift
guard let documents = try? fileManager.url(
    for: .documentDirectory,
    in: .userDomainMask,
    appropriateFor: nil,
    create: false
) else { return nil }
```

### Impact
If Documents directory can't be accessed, method returns nil without logging why. Makes debugging hard.

### Fix
```swift
do {
    let documents = try fileManager.url(...)
    return documents
} catch {
    Logger.error("Failed to access Documents directory: \(error)")
    return nil
}
```

---

## BUG-008: UsageLogForm 6 Parameter Helper

**File:** `Cravey/Presentation/Views/Usage/UsageLogForm.swift:185`

### Problem
This is not a “helper” function — it is the `LogUsageUseCase.execute(...)` signature being implemented in a preview mock.

This issue is therefore a **duplicate** of BUG-005 (the protocol/API design), and will be resolved if/when BUG-005 is addressed.

### Status
**CLOSED (Duplicate of BUG-005)**

---

## BUG-009: UI Test Function Too Long

**File:** `CraveyUITests/Phase1ScreenshotTests.swift`

### Status
✅ **FIXED** (2026-01-24)

### Problem
Test function spans 79 lines (limit is 50).

### Fix
Split into smaller, focused test functions:
```swift
func testScreenshot_HomeView() { ... }
func testScreenshot_CravingForm() { ... }
func testScreenshot_UsageForm() { ... }
```

---

## BUG-010: UI Test Line Too Long

**File:** `CraveyUITests/UsageLogUITests.swift`

### Status
✅ **FIXED** (2026-01-24)

### Problem
Line has 121 characters (limit 120).

### Fix
Break into multiple lines.

---

## BUG-011: Trailing Comma Violations (8 locations)

**Files:**
- `ModelContainerSetup.swift` lines 14, 37, 64
- `MotivationalMessageEntity.swift` line 115
- `LocationOptions.swift` line 13
- `TriggerOptions.swift` lines 14, 22
- `UsageListView.swift` line 263
- `UsageListViewModelTests.swift` line 48

### Problem
Collection literals have unnecessary trailing commas.

### Status
✅ **FIXED** (2026-01-24)

### Fix Implemented
- SwiftFormat is authoritative for formatting.
- SwiftLint `trailing_comma` rule is disabled in `.swiftlint.yml` to match SwiftFormat expectations.

---

## BUG-019: Sheets Can Be Dismissed During Save (Lost Success Feedback)

**Files:**
- `Cravey/Presentation/Views/Craving/CravingLogForm.swift`
- `Cravey/Presentation/Views/Usage/UsageLogForm.swift`
**Verify:** `rg -n "interactiveDismissDisabled\\(" Cravey/Presentation/Views/Craving/CravingLogForm.swift Cravey/Presentation/Views/Usage/UsageLogForm.swift`

### Status
✅ **FIXED** (2026-01-25)

### Problem
If the user swipes down to dismiss the sheet while a save is in-flight (`isLoading == true`), the save can still
complete, but the parent view may not receive the success signal in time to reliably show the toast or refresh lists.

### Fix Implemented
- Disabled interactive sheet dismissal while saving:
  - `.interactiveDismissDisabled(viewModel.isLoading)`

---

## BUG-020: Intensity Color Scale Mismatch (9 Should Be Orange, Not Red)

**File:** `Cravey/Presentation/Utilities/IntensityColorScale.swift`
**Spec:** `docs/master/MVP_PRODUCT_SPEC.md` (Craving Intensity scale: 7-9 strong, 10 overwhelming)
**Verify:** `rg -n "case 7 \\.\\.\\. 9|case 10" Cravey/Presentation/Utilities/IntensityColorScale.swift`

### Status
✅ **FIXED** (2026-01-25)

### Problem
Intensity colors treated 9 as “severe/red” instead of “strong/orange,” conflicting with the spec’s 7–9 grouping.

### Fix Implemented
- Updated intensity color mapping:
  - 7–9 → orange
  - 10 → red

---

## BUG-021: Dashboard Top Triggers Ignored Usage Triggers

**File:** `Cravey/Presentation/ViewModels/DashboardViewModel.swift`
**Spec:** `docs/master/MVP_PRODUCT_SPEC.md` (Trigger breakdown applies to cravings + usage combined)
**Verify:** `rg -n "calculateTopTriggers\\(cravings:.*usages:" Cravey/Presentation/ViewModels/DashboardViewModel.swift`

### Status
✅ **FIXED** (2026-01-25)

### Problem
`topTriggers` was computed only from craving triggers, ignoring usage triggers, leading to incorrect dashboard insights.

### Fix Implemented
- Count triggers across both `CravingEntity.triggers` and `UsageEntity.triggers`.

---

## BUG-022: Domain Validation Gaps (Future Timestamp + Notes Length)

**Files:**
- `Cravey/Domain/UseCases/LogCravingUseCase.swift`
- `Cravey/Domain/UseCases/LogUsageUseCase.swift`
**Verify:**
- `rg -n "futureTimestamp|notesTooLong" Cravey/Domain/UseCases/LogCravingUseCase.swift Cravey/Domain/UseCases/LogUsageUseCase.swift`
- `bash scripts/verify.sh`

### Status
✅ **FIXED** (2026-01-25)

### Problem
Domain use cases did not fully enforce spec invariants when called programmatically:
- Usage logging allowed future timestamps (UI prevented it, Domain didn’t).
- Notes length limits were not enforced in Domain.

### Fix Implemented
- Added Domain-level validation:
  - Reject future timestamps
  - Reject notes > 500 characters

---

## BUG-024: UsageListViewModel Hardcoded Error Message

**File:** `Cravey/Presentation/ViewModels/UsageListViewModel.swift:31`
**Verify:** `rg -n '"Failed to load usage history"' Cravey/Presentation/ViewModels/UsageListViewModel.swift`

### Status
🔴 **OPEN** (2026-01-25)

### Problem
```swift
} catch {
    errorMessage = "Failed to load usage history"  // ← Loses error details
}
```

Contrast with `CravingListViewModel.swift:30` which correctly preserves error:
```swift
errorMessage = error.localizedDescription  // ← Correct
```

### Impact
- Users and developers lose diagnostic information about WHY data loading failed
- Makes debugging production issues impossible
- Inconsistent with craving list error handling

### Fix
```swift
} catch {
    errorMessage = error.localizedDescription
}
```

---

## Summary

| Bug ID | Description | Status |
|--------|-------------|--------|
| BUG-007 | Silent directory failure | ✅ FIXED |
| BUG-008 | Duplicate of BUG-005 | ✅ CLOSED |
| BUG-009 | Test function too long | ✅ FIXED |
| BUG-010 | Line too long | ✅ FIXED |
| BUG-011 | Trailing commas (8x) | ✅ FIXED |
| BUG-019 | Sheet dismiss during save | ✅ FIXED |
| BUG-020 | Intensity color scale mismatch | ✅ FIXED |
| BUG-021 | Dashboard triggers ignored usage | ✅ FIXED |
| BUG-022 | Domain validation gaps | ✅ FIXED |
| BUG-024 | UsageListViewModel hardcoded error | 🔴 OPEN |
