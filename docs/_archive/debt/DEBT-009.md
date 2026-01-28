# DEBT-009: GPS "Current Location" Spec Not Implemented

**Priority:** P3 (Spec Drift / Feature Gap)
**Status:** ✅ CLOSED - Implemented
**Created:** 2026-01-27
**Last Audited:** 2026-01-27
**Closed:** 2026-01-27

## Problem

The master specs (UX_FLOW_SPEC.md lines 266-270, DATA_MODEL_SPEC.md lines 195-219) define a "Current Location" chip that auto-detects GPS coordinates via CoreLocation. This provides convenience for users having cravings in unfamiliar locations.

**Current state:** No "Current" chip exists; no CoreLocation integration.

## User Story

> As a user logging a craving, I want to tap "Current Location" so that my GPS coordinates are automatically captured without typing, especially when I'm somewhere unfamiliar.

## Solution: Implement GPS (Option A)

### 1. Architecture (Clean Architecture)

```
Domain/
├── Services/
│   └── LocationServiceProtocol.swift    # Protocol (framework-free)

Data/
├── Services/
│   └── LocationService.swift            # CoreLocation implementation

Presentation/
├── Views/Components/
│   └── LocationOptions.swift            # Add "Current Location" to presets
│   └── CurrentLocationChip.swift        # NEW: Smart chip with loading state
```

**Why this structure:**
- Domain stays framework-free (LocationServiceProtocol has no CoreLocation import)
- Data layer contains the CoreLocation concrete implementation
- Presentation uses the service via DependencyContainer injection

### 2. Domain Layer - Protocol

```swift
// Cravey/Domain/Services/LocationServiceProtocol.swift

import Foundation

/// Location service result
enum LocationResult: Sendable {
    case success(latitude: Double, longitude: Double)
    case permissionDenied
    case permissionRestricted  // Parental controls
    case servicesDisabled      // System-wide location off
    case timeout
    case error(String)
}

/// Protocol for location services (framework-independent)
protocol LocationServiceProtocol: Sendable {
    /// Request current location (requests permission if needed)
    func requestCurrentLocation() async -> LocationResult

    /// Check current authorization status without triggering prompt
    func authorizationStatus() -> LocationAuthorizationStatus
}

enum LocationAuthorizationStatus: Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted
}
```

### 3. Data Layer - CoreLocation Implementation

```swift
// Cravey/Data/Services/LocationService.swift

import CoreLocation

actor LocationService: NSObject, LocationServiceProtocol {
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<LocationResult, Never>?

    // Reduced accuracy is fine for "where am I" - faster, less battery
    private let desiredAccuracy = kCLLocationAccuracyHundredMeters
    private let timeout: TimeInterval = 10.0

    func requestCurrentLocation() async -> LocationResult {
        // Check system-wide location services
        guard CLLocationManager.locationServicesEnabled() else {
            return .servicesDisabled
        }

        // Check/request authorization
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            // Will trigger system prompt
            locationManager.requestWhenInUseAuthorization()
            // Wait for authorization then proceed

        case .denied:
            return .permissionDenied

        case .restricted:
            return .permissionRestricted

        case .authorizedWhenInUse, .authorizedAlways:
            break // Good to go

        @unknown default:
            return .error("Unknown authorization status")
        }

        // Request location with timeout
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            locationManager.desiredAccuracy = desiredAccuracy
            locationManager.requestLocation()

            // Timeout after 10 seconds
            Task {
                try? await Task.sleep(for: .seconds(timeout))
                if let cont = self.continuation {
                    self.continuation = nil
                    cont.resume(returning: .timeout)
                }
            }
        }
    }

    func authorizationStatus() -> LocationAuthorizationStatus {
        switch locationManager.authorizationStatus {
        case .notDetermined: return .notDetermined
        case .authorizedWhenInUse, .authorizedAlways: return .authorized
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }
}

// CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager,
                                      didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task {
            if let cont = await self.continuation {
                await self.clearContinuation()
                cont.resume(returning: .success(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                ))
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                      didFailWithError error: Error) {
        Task {
            if let cont = await self.continuation {
                await self.clearContinuation()
                cont.resume(returning: .error(error.localizedDescription))
            }
        }
    }

    private func clearContinuation() {
        continuation = nil
    }
}
```

### 4. Presentation Layer - UI Changes

#### 4.1 Update LocationOptions.swift

```swift
// Add "Current Location" as special first option
enum LocationOptions {
    static let currentLocationKey = "📍 Current"  // Special key

    static let presets: [String] = [
        currentLocationKey,  // NEW: First option
        "Home",
        "Work",
        "Social",
        "Outside",
        "Car",
    ]

    static func isCurrentLocationChip(_ value: String) -> Bool {
        value == currentLocationKey
    }

    // Existing helpers unchanged...
}
```

#### 4.2 Smart Chip Behavior in Form

When user taps "📍 Current":

1. **If permission not determined:** System prompt appears
2. **If permission denied:** Show alert with Settings link
3. **If permission granted:**
   - Chip shows loading indicator (replace text with spinner)
   - On success: Store `"37.7749,-122.4194"` as location value
   - On timeout/error: Show toast, revert to no selection

```swift
// In CravingLogViewModel / UsageLogViewModel

func handleLocationSelection(_ selection: String?) async {
    guard let selection, LocationOptions.isCurrentLocationChip(selection) else {
        // Normal preset - just store it
        selectedLocation = selection
        return
    }

    // Current Location tapped - get GPS
    isLoadingLocation = true
    defer { isLoadingLocation = false }

    let result = await locationService.requestCurrentLocation()

    switch result {
    case .success(let lat, let long):
        selectedLocation = LocationOptions.formatGPS(latitude: lat, longitude: long)

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

    case .error(let message):
        locationError = message
        selectedLocation = nil
    }
}
```

### 5. Info.plist Privacy Description

Add to `Config/iOS.Info.plist.template`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cravey uses your location to help you track where cravings occur. Location data is stored locally and never leaves your device.</string>
```

### 6. Permission Denied Alert (per UX_FLOW_SPEC.md)

```swift
.alert("Location Permission Required", isPresented: $showLocationPermissionAlert) {
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

### 7. DependencyContainer Wiring

```swift
// Cravey/App/DependencyContainer.swift

// Add to stored properties
private(set) var locationService: LocationServiceProtocol

// Add to init
self.locationService = LocationService()

// Update ViewModel factories to inject locationService
func makeCravingLogViewModel() -> CravingLogViewModel {
    CravingLogViewModel(
        logCravingUseCase: logCravingUseCase,
        locationService: locationService  // NEW
    )
}
```

### 8. Testing Strategy

**Unit Tests (Mock Location Service):**
```swift
actor MockLocationService: LocationServiceProtocol {
    var mockResult: LocationResult = .success(latitude: 37.7749, longitude: -122.4194)
    var requestLocationCalled = false

    func requestCurrentLocation() async -> LocationResult {
        requestLocationCalled = true
        return mockResult
    }

    func authorizationStatus() -> LocationAuthorizationStatus {
        return .authorized
    }
}

// Test cases:
// - Success: stores "lat,long" string
// - Permission denied: shows alert, clears selection
// - Timeout: shows error toast, clears selection
// - Services disabled: shows appropriate message
```

**Manual Testing:**
- Fresh install → tap Current → system prompt appears
- Deny permission → tap Current → alert with Settings link
- Grant permission → tap Current → spinner → location captured
- Airplane mode → tap Current → timeout message

## Files to Create/Modify

### New Files
1. `Cravey/Domain/Services/LocationServiceProtocol.swift`
2. `Cravey/Data/Services/LocationService.swift`
3. `CraveyTests/Presentation/ViewModels/LocationServiceMock.swift`

### Modified Files
1. `Config/iOS.Info.plist.template` - Add NSLocationWhenInUseUsageDescription
2. `Cravey/Presentation/Views/Components/LocationOptions.swift` - Add currentLocationKey
3. `Cravey/Presentation/ViewModels/CravingLogViewModel.swift` - Add location handling
4. `Cravey/Presentation/ViewModels/UsageLogViewModel.swift` - Add location handling
5. `Cravey/Presentation/Views/Craving/CravingLogForm.swift` - Loading state for chip
6. `Cravey/Presentation/Views/Usage/UsageLogForm.swift` - Loading state for chip
7. `Cravey/App/DependencyContainer.swift` - Wire LocationService
8. `project.yml` - Ensure CoreLocation framework linked (should be automatic)

## Acceptance Criteria

- [x] "📍 Current" chip appears first in location options
- [x] Tapping "Current" requests location permission (first time)
- [x] If denied: Alert appears with "Open Settings" button
- [x] If granted: Chip shows loading state, then location is stored as "lat,long"
- [x] Stored location displays as "Current Location" in history views
- [x] Info.plist contains privacy description
- [x] Location data is local-only (no network calls, no reverse geocoding)
- [x] Unit tests cover success/denied/timeout scenarios via mock
- [x] `bash scripts/verify.sh` passes

## Privacy Considerations

✅ **Local-only:** GPS coordinates stored in SwiftData, never transmitted
✅ **No reverse geocoding:** No API calls to convert coords to address (future enhancement)
✅ **When-in-use only:** Uses `requestWhenInUseAuthorization`, not "always"
✅ **Reduced accuracy:** `kCLLocationAccuracyHundredMeters` - good enough, less creepy
✅ **User-initiated:** Only activates when user explicitly taps "Current"

## Estimated Scope

- **New code:** ~200 lines (protocol, service, mock, UI changes)
- **Test code:** ~50 lines (mock + 4-5 test cases)
- **Risk:** Low - isolated feature, doesn't affect existing flows
