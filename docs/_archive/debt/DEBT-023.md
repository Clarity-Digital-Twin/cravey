# DEBT-023: Location Handling Logic Duplicated Across ViewModels

**Priority:** P2 (Important - DRY Violation)
**Status:** RESOLVED
**Resolved:** 2026-01-29
**Resolution:** Created LocationHandling protocol with handleLocationSelection default implementation. Both ViewModels now conform.
**Created:** 2026-01-28

## Problem

`handleLocationSelection()` is **95% identical** across two ViewModels - 54 lines of copy-pasted code.

---

## Duplicated Code

### CravingLogViewModel.swift (lines 122-175)
### UsageLogViewModel.swift (lines 162-215)

```swift
func handleLocationSelection(_ selection: String?) async {
    locationError = nil

    guard let selection else {
        selectedLocation = nil
        return
    }

    guard LocationOptions.isCurrentLocationChip(selection) else {
        selectedLocation = selection
        return
    }

    guard let locationService else {
        locationError = "Location service unavailable"
        selectedLocation = nil
        return
    }

    isLoadingLocation = true
    defer { isLoadingLocation = false }

    let result = await locationService.requestCurrentLocation()

    switch result {
    case let .success(latitude, longitude):
        selectedLocation = LocationOptions.formatGPS(latitude: latitude, longitude: longitude)
    case .permissionDenied:
        showLocationPermissionAlert = true
        selectedLocation = nil
    case .permissionRestricted:
        locationError = "Location restricted by parental controls"
        selectedLocation = nil
    case .servicesDisabled:
        locationError = "Location Services disabled. Enable in Settings > Privacy."
        selectedLocation = nil
    case .timeout:
        locationError = "Couldn't get location. Try again."
        selectedLocation = nil
    case let .error(message):
        locationError = message
        selectedLocation = nil
    }
}
```

---

## Rob C. Martin Fix: Protocol with Default Implementation

```swift
// Cravey/Presentation/Protocols/LocationHandling.swift

/// Shared location handling for ViewModels that support GPS location selection.
/// Eliminates duplication between CravingLogViewModel and UsageLogViewModel.
@MainActor
protocol LocationHandling: AnyObject {
    var selectedLocation: String? { get set }
    var isLoadingLocation: Bool { get set }
    var showLocationPermissionAlert: Bool { get set }
    var locationError: String? { get set }
    var locationService: LocationServiceProtocol? { get }
}

extension LocationHandling {
    func handleLocationSelection(_ selection: String?) async {
        locationError = nil

        guard let selection else {
            selectedLocation = nil
            return
        }

        guard LocationOptions.isCurrentLocationChip(selection) else {
            selectedLocation = selection
            return
        }

        guard let locationService else {
            locationError = "Location service unavailable"
            selectedLocation = nil
            return
        }

        isLoadingLocation = true
        defer { isLoadingLocation = false }

        let result = await locationService.requestCurrentLocation()

        switch result {
        case let .success(latitude, longitude):
            selectedLocation = LocationOptions.formatGPS(latitude: latitude, longitude: longitude)
        case .permissionDenied:
            showLocationPermissionAlert = true
            selectedLocation = nil
        case .permissionRestricted:
            locationError = "Location restricted by parental controls"
            selectedLocation = nil
        case .servicesDisabled:
            locationError = "Location Services disabled. Enable in Settings > Privacy."
            selectedLocation = nil
        case .timeout:
            locationError = "Couldn't get location. Try again."
            selectedLocation = nil
        case let .error(message):
            locationError = message
            selectedLocation = nil
        }
    }
}

// Usage:
@Observable
@MainActor
final class CravingLogViewModel: LocationHandling {
    // Just declare the required properties - get handleLocationSelection() for free
}
```

---

## Files to Modify

| File | Change |
|------|--------|
| Create `Cravey/Presentation/Protocols/LocationHandling.swift` | New protocol + extension |
| `CravingLogViewModel.swift` | Conform to `LocationHandling`, delete 54 lines |
| `UsageLogViewModel.swift` | Conform to `LocationHandling`, delete 54 lines |

---

## Acceptance Criteria

- [ ] Single source of truth for location handling logic
- [ ] Both ViewModels conform to `LocationHandling` protocol
- [ ] No duplicated code
- [ ] All tests pass
