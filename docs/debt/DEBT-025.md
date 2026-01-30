# DEBT-025: Alert Patterns Duplicated Across Views

**Priority:** P2 (Important - DRY Violation)
**Status:** OPEN
**Created:** 2026-01-28

## Problem

Three alert patterns are **100% identical** across multiple views - ~70+ lines of copy-pasted code.

---

## Duplicated Alerts

### 1. Error Alert (100% identical in 4+ views)

**Files:**
- `CravingLogForm.swift` (lines 119-130)
- `UsageLogForm.swift` (lines 129-140)
- Other views with error handling

```swift
.alert("Error", isPresented: Binding(
    get: { viewModel.errorMessage != nil },
    set: { if !$0 { viewModel.errorMessage = nil } }
)) {
    Button("OK") {
        viewModel.errorMessage = nil
    }
} message: {
    if let error = viewModel.errorMessage {
        Text(error)
    }
}
```

### 2. Old Timestamp Warning (95% identical in 2 views)

**Files:**
- `CravingLogForm.swift` (lines 107-118)
- `UsageLogForm.swift` (lines 117-128)

```swift
.alert("Old Timestamp", isPresented: $viewModel.showTimestampWarning) {
    Button("Cancel", role: .cancel) {
        viewModel.showTimestampWarning = false
    }
    Button("Continue Anyway") {
        Task {
            await viewModel.confirmOldTimestamp()
        }
    }
} message: {
    Text("This craving is more than 7 days old. Are you sure you want to log it?")
}
```

### 3. Location Permission Alert (100% identical in 2 views)

**Files:**
- `CravingLogForm.swift` (lines 132-141)
- `UsageLogForm.swift` (lines 142-151)

```swift
.alert("Location Permission Required", isPresented: $viewModel.showLocationPermissionAlert) {
    Button("Open Settings") {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    Button("Cancel", role: .cancel) {}
} message: {
    Text("Enable location access in Settings to use Current Location.")
}
```

---

## Rob C. Martin Fix: ViewModifier Extensions

```swift
// Cravey/Presentation/Views/Modifiers/AlertModifiers.swift

import SwiftUI

// MARK: - Error Alert Protocol

protocol ErrorDisplaying: AnyObject {
    var errorMessage: String? { get set }
}

extension View {
    /// Reusable error alert for any ViewModel with an errorMessage property
    func errorAlert<VM: ErrorDisplaying & Observable>(viewModel: VM) -> some View {
        self.alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

// MARK: - Timestamp Warning Protocol

protocol TimestampWarningDisplaying: AnyObject {
    var showTimestampWarning: Bool { get set }
    func confirmOldTimestamp() async
}

extension View {
    /// Reusable old timestamp warning alert
    func timestampWarningAlert<VM: TimestampWarningDisplaying & Observable>(
        viewModel: VM,
        itemType: String = "entry"
    ) -> some View {
        self.alert("Old Timestamp", isPresented: Binding(
            get: { viewModel.showTimestampWarning },
            set: { viewModel.showTimestampWarning = $0 }
        )) {
            Button("Cancel", role: .cancel) {
                viewModel.showTimestampWarning = false
            }
            Button("Continue Anyway") {
                Task {
                    await viewModel.confirmOldTimestamp()
                }
            }
        } message: {
            Text("This \(itemType) is more than 7 days old. Are you sure you want to log it?")
        }
    }
}

// MARK: - Location Permission Protocol

protocol LocationPermissionDisplaying: AnyObject {
    var showLocationPermissionAlert: Bool { get set }
}

extension View {
    /// Reusable location permission alert
    func locationPermissionAlert<VM: LocationPermissionDisplaying & Observable>(
        viewModel: VM
    ) -> some View {
        self.alert("Location Permission Required", isPresented: Binding(
            get: { viewModel.showLocationPermissionAlert },
            set: { viewModel.showLocationPermissionAlert = $0 }
        )) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enable location access in Settings to use Current Location.")
        }
    }
}

// MARK: - Usage in Views

// Before (duplicated):
.alert("Error", isPresented: ...)
.alert("Old Timestamp", isPresented: ...)
.alert("Location Permission Required", isPresented: ...)

// After (DRY):
.errorAlert(viewModel: viewModel)
.timestampWarningAlert(viewModel: viewModel, itemType: "craving")
.locationPermissionAlert(viewModel: viewModel)
```

---

## Files to Modify

| File | Change |
|------|--------|
| Create `Cravey/Presentation/Views/Modifiers/AlertModifiers.swift` | New file with protocols + extensions |
| `CravingLogForm.swift` | Replace 3 alerts with modifier calls (~33 lines removed) |
| `UsageLogForm.swift` | Replace 3 alerts with modifier calls (~33 lines removed) |

---

## Acceptance Criteria

- [ ] `AlertModifiers.swift` created with 3 reusable alert modifiers
- [ ] `CravingLogForm` uses `.errorAlert()`, `.timestampWarningAlert()`, `.locationPermissionAlert()`
- [ ] `UsageLogForm` uses same modifiers
- [ ] ~66 lines of duplicated code removed
- [ ] All tests pass
