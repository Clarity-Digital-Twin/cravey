# DEBT-001: Duplicate Timestamp Warning Logic

**Status:** OPEN
**Priority:** P4
**Files:**
- `Cravey/Presentation/ViewModels/CravingLogViewModel.swift`
- `Cravey/Presentation/ViewModels/UsageLogViewModel.swift`

## Problem

Both ViewModels implement identical `isTimestampOld` logic checking if timestamp is >7 days old.

## Current Code (duplicated in both files)

```swift
var isTimestampOld: Bool {
    guard let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
        return false
    }
    return timestamp < sevenDaysAgo
}
```

## Expected

Single source of truth for this logic.

## Fix

Create `TimestampValidation` utility with shared threshold constant.
