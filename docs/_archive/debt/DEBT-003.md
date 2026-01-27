# DEBT-003: DateFormatter Created Per SettingsViewModel Instance

**Status:** FIXED
**Priority:** P4
**File:** `Cravey/Presentation/ViewModels/SettingsViewModel.swift:17-21`

## Problem

DateFormatter is expensive to create but is instantiated per SettingsViewModel instance.

## Current Code

```swift
@ObservationIgnored
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd-HHmmss"
    return formatter
}()
```

## Expected

DateFormatters should be shared/cached.

## Fix

Use static property: `private static let exportDateFormatter = ...`

✅ Implemented as a shared `exportFileDateFormatter`.
