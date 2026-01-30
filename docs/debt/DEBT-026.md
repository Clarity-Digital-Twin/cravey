# DEBT-026: Location Selector UI Duplicated in Forms

**Priority:** P2 (Important - DRY Violation)
**Status:** ✅ RESOLVED
**Created:** 2026-01-28
**Resolved:** 2026-01-30

## Problem

The location selector UI with GPS binding is **98% identical** across two forms - ~25 lines duplicated.

---

## Duplicated Code

### CravingLogForm.swift (lines 35-66)
### UsageLogForm.swift (lines 171-204, in `locationSelector` computed property)

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

/// Uses the shared `LocationHandling` protocol (see `Cravey/Presentation/Protocols/LocationHandling.swift`).

/// Reusable location selector component with GPS support
struct LocationSelector<VM: LocationHandling & Observable>: View {
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
| `CravingLogViewModel.swift` | Conform to `LocationHandling` (already done) |
| `UsageLogViewModel.swift` | Conform to `LocationHandling` (already done) |

---

## Acceptance Criteria

- [x] `LocationSelector` component created
- [x] Both forms use `LocationSelector` instead of duplicated code
- [x] ~60 lines of duplicated code removed
- [x] ViewModels conform to `LocationHandling`
- [x] All 93 tests pass
