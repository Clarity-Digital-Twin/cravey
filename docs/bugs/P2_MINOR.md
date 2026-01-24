# P2 - Minor Bugs

**Status:** ACTIVE
**Last Updated:** 2026-01-24

UI glitches, edge case issues, style violations.

---

## BUG-007: FileStorageManager Silent Directory Failure

**File:** `Cravey/Data/Storage/FileStorageManager.swift:125`

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

**File:** `CraveyUITests/Phase1ScreenshotTests.swift:14`

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

**File:** `CraveyUITests/UsageLogUITests.swift:63`

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

### Fix
Remove the trailing commas at the listed sites (or change SwiftLint config to allow trailing commas).

---

## Summary

| Bug ID | Description | Status |
|--------|-------------|--------|
| BUG-007 | Silent directory failure | OPEN |
| BUG-008 | Duplicate of BUG-005 | ✅ CLOSED |
| BUG-009 | Test function too long | OPEN |
| BUG-010 | Line too long | OPEN |
| BUG-011 | Trailing commas (8x) | OPEN |
