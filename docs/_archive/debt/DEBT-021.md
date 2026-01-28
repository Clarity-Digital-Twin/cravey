# DEBT-021: Hardcoded Magic Numbers Scattered Across Codebase

**Priority:** P3 (Architecture)
**Status:** OPEN
**Created:** 2026-01-28

## Problem

Magic numbers are duplicated across Domain, Presentation, and ViewModel layers.

---

## Issues Found

### 1. Notes Character Limit (500)

| File | Line | Code |
|------|------|------|
| `CravingLogViewModel.swift` | 19 | `if notes.count > 500` |
| `UsageLogViewModel.swift` | 34 | `if notes.count > 500` |
| `LogCravingUseCase.swift` | 41 | `notes.count > 500` |
| `LogUsageUseCase.swift` | 64 | `notes.count > 500` |

### 2. Character Counter Threshold (400)

| File | Line | Code |
|------|------|------|
| `CravingLogViewModel.swift` | 203 | `notes.count >= 400` |
| `UsageLogViewModel.swift` | 78 | `notes.count >= 400` |

### 3. Toast Display Duration (2 seconds)

| File | Line | Code |
|------|------|------|
| `LogView.swift` | 112 | `Task.sleep(for: .seconds(2))` |
| `SettingsView.swift` | 151 | `Task.sleep(for: .seconds(2))` |

---

## Recommended Fix

Create a constants file in Domain layer:

```swift
// Cravey/Domain/Entities/ValidationLimits.swift

enum ValidationLimits {
    /// Maximum characters for notes field
    static let notesMaxLength = 500

    /// Show character counter when notes reach this length
    static let notesCounterThreshold = 400
}

// Cravey/Presentation/Constants/UIConstants.swift

enum UIConstants {
    /// Duration to show toast/banner messages
    static let toastDisplayDuration: TimeInterval = 2.0
}
```

---

## Files to Modify

| File | Change |
|------|--------|
| Create `Cravey/Domain/Entities/ValidationLimits.swift` | New file with constants |
| Create `Cravey/Presentation/Constants/UIConstants.swift` | New file with UI constants |
| `CravingLogViewModel.swift` | Replace 500/400 with `ValidationLimits.*` |
| `UsageLogViewModel.swift` | Replace 500/400 with `ValidationLimits.*` |
| `LogCravingUseCase.swift` | Replace 500 with `ValidationLimits.notesMaxLength` |
| `LogUsageUseCase.swift` | Replace 500 with `ValidationLimits.notesMaxLength` |
| `LogView.swift` | Replace 2 with `UIConstants.toastDisplayDuration` |
| `SettingsView.swift` | Replace 2 with `UIConstants.toastDisplayDuration` |

---

## Acceptance Criteria

- [ ] All magic numbers replaced with named constants
- [ ] Constants defined in appropriate layer (Domain for validation, Presentation for UI)
- [ ] Single source of truth for each value
- [ ] All tests pass
