# DEBT-026: Location Selector UI Duplicated in Forms

**Priority:** P2 (Important - DRY Violation)
**Status:** OPEN
**Created:** 2026-01-28

## Problem

The location selector UI with GPS binding is **98% identical** across two forms - ~25 lines duplicated.

---

## Duplicated Code

### CravingLogForm.swift (lines 33-66)
### UsageLogForm.swift (lines 167-205)

```swift
OptionalSingleSelectChipSelector(
    title: "Location",
    options: LocationOptions.presets,
    selectedValue: Binding(
        get: {
            if let loc = viewModel.selectedLocation, LocationOptions.isGPS(loc) {
                return LocationOptions.currentLocationKey
            }
            return viewModel.selectedLocation
        },
        set: { newValue in
            Task {
                await viewModel.handleLocationSelection(newValue)
            }
        }
    )
)
.overlay {
    if viewModel.isLoadingLocation {
        ProgressView()
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 8)
    }
}

if let locationError = viewModel.locationError {
    Text(locationError)
        .font(.caption)
        .foregroundStyle(.red)
}
```

---

## Rob C. Martin Fix: Extract to Reusable Component

```swift
// Cravey/Presentation/Views/Components/LocationSelector.swift

import SwiftUI

/// Protocol for ViewModels that support location selection
@MainActor
protocol LocationSelectable: AnyObject, Observable {
    var selectedLocation: String? { get set }
    var isLoadingLocation: Bool { get }
    var locationError: String? { get }
    func handleLocationSelection(_ selection: String?) async
}

/// Reusable location selector component with GPS support
struct LocationSelector<VM: LocationSelectable>: View {
    @Bindable var viewModel: VM

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            OptionalSingleSelectChipSelector(
                title: "Location",
                options: LocationOptions.presets,
                selectedValue: locationBinding
            )
            .overlay(alignment: .trailing) {
                if viewModel.isLoadingLocation {
                    ProgressView()
                        .padding(.trailing, 8)
                }
            }

            if let locationError = viewModel.locationError {
                Text(locationError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private var locationBinding: Binding<String?> {
        Binding(
            get: {
                if let loc = viewModel.selectedLocation, LocationOptions.isGPS(loc) {
                    return LocationOptions.currentLocationKey
                }
                return viewModel.selectedLocation
            },
            set: { newValue in
                Task {
                    await viewModel.handleLocationSelection(newValue)
                }
            }
        )
    }
}

// MARK: - Usage in Forms

// Before (duplicated 25 lines in each form):
OptionalSingleSelectChipSelector(...)
.overlay { ... }
if let locationError = ... { ... }

// After (1 line each):
LocationSelector(viewModel: viewModel)
```

---

## Files to Modify

| File | Change |
|------|--------|
| Create `Cravey/Presentation/Views/Components/LocationSelector.swift` | New component |
| `CravingLogForm.swift` | Replace ~25 lines with `LocationSelector(viewModel: viewModel)` |
| `UsageLogForm.swift` | Replace ~25 lines with `LocationSelector(viewModel: viewModel)` |
| `CravingLogViewModel.swift` | Conform to `LocationSelectable` |
| `UsageLogViewModel.swift` | Conform to `LocationSelectable` |

---

## Acceptance Criteria

- [ ] `LocationSelector` component created
- [ ] Both forms use `LocationSelector` instead of duplicated code
- [ ] ~50 lines of duplicated code removed
- [ ] ViewModels conform to `LocationSelectable`
- [ ] All tests pass
