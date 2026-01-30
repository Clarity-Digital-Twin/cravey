# DEBT-017: LocationService Main Thread Blocking Warning

**Priority:** P3 (Architecture)
**Status:** RESOLVED
**Resolved:** 2026-01-29
**Resolution:** Moved CLLocationManager.locationServicesEnabled() to Task.detached background thread. Full delegate-based refactor deferred.
**Created:** 2026-01-28
**Xcode Warning:** "This method can cause UI unresponsiveness if invoked on the main thread. Instead, consider waiting for the `-locationManagerDidChangeAuthorization:` callback and checking `authorizationStatus` first."

## Problem

The `LocationService.swift` has two issues that can cause UI unresponsiveness:

### Issue 1: `CLLocationManager.locationServicesEnabled()` blocks main thread

```swift
// Line 26 - PROBLEMATIC
guard CLLocationManager.locationServicesEnabled() else {
    return .servicesDisabled
}
```

This is a **synchronous class method** that checks system-wide location services. When called on the main thread (which our `@MainActor` class does), it can block the UI while querying the system.

### Issue 2: Sleep/Retry pattern for authorization is a hack

```swift
// Lines 39-42 - PROBLEMATIC
locationManager.requestWhenInUseAuthorization()
try? await Task.sleep(for: .milliseconds(500))
return await requestCurrentLocationWithRetry(retriesRemaining: retriesRemaining - 1)
```

This pattern:
- Wastes time sleeping even if user responds immediately
- May not wait long enough if user is slow
- Causes up to 10 retries × 500ms = 5 seconds of potential delay
- Is fundamentally a polling hack instead of event-driven

---

## Root Cause

`CLLocationManager` was designed for the delegate pattern, not async/await. The modern iOS 17+ `CLLocationUpdate.liveUpdates()` API helps with location fetching, but **authorization handling still requires the delegate**.

---

## Recommended Fix: Delegate-based Authorization with AsyncStream

### Pattern Overview

1. Implement `CLLocationManagerDelegate` with `locationManagerDidChangeAuthorization(_:)`
2. Use `AsyncStream` to bridge delegate callbacks to async/await
3. Await authorization changes instead of polling with sleep

### Reference Implementation

```swift
import CoreLocation

@MainActor
final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager
    private let timeout: TimeInterval

    // AsyncStream for authorization changes
    private var authorizationContinuation: AsyncStream<CLAuthorizationStatus>.Continuation?
    private lazy var authorizationStream: AsyncStream<CLAuthorizationStatus> = {
        AsyncStream { continuation in
            self.authorizationContinuation = continuation
        }
    }()

    override init() {
        locationManager = CLLocationManager()
        self.timeout = 10.0
        super.init()
        locationManager.delegate = self
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationContinuation?.yield(manager.authorizationStatus)
        }
    }

    // MARK: - Public API

    func requestCurrentLocation() async -> LocationResult {
        // Check authorization first (property access, not blocking call)
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            // Request permission and wait for delegate callback
            locationManager.requestWhenInUseAuthorization()

            // Wait for authorization change (with timeout)
            let authorized = await waitForAuthorization()
            guard authorized else {
                return .permissionDenied
            }

        case .denied:
            return .permissionDenied

        case .restricted:
            return .permissionRestricted

        case .authorizedWhenInUse, .authorizedAlways:
            break

        @unknown default:
            return .error("Unknown authorization status")
        }

        // Now fetch location using iOS 17+ API
        return await fetchLocation()
    }

    private func waitForAuthorization() async -> Bool {
        // Wait for authorization with timeout
        return await withTaskGroup(of: Bool.self) { group in
            group.addTask {
                for await status in self.authorizationStream {
                    switch status {
                    case .authorizedWhenInUse, .authorizedAlways:
                        return true
                    case .denied, .restricted:
                        return false
                    case .notDetermined:
                        continue // Keep waiting
                    @unknown default:
                        return false
                    }
                }
                return false
            }

            group.addTask {
                try? await Task.sleep(for: .seconds(30)) // Generous timeout for user interaction
                return false
            }

            let result = await group.next() ?? false
            group.cancelAll()
            return result
        }
    }

    private func fetchLocation() async -> LocationResult {
        // Existing iOS 17+ implementation with liveUpdates()
        // ... (keep current implementation)
    }
}
```

### Key Changes

| Current | Proposed |
|---------|----------|
| `CLLocationManager.locationServicesEnabled()` sync call | Check `authorizationStatus` property (instant) |
| Sleep 500ms then retry polling | `AsyncStream` + delegate callback |
| Up to 10 retries (5 sec worst case) | Event-driven, immediate response |
| No delegate | Implement `CLLocationManagerDelegate` |

---

## Files to Modify

| File | Change |
|------|--------|
| `Cravey/Data/Services/LocationService.swift` | Full refactor to delegate-based pattern |
| `CraveyTests/Domain/Services/LocationServiceTests.swift` | Update tests for new behavior |

---

## Alternative: Third-Party Library

If full refactor is too risky, consider:
- [SwiftLocation](https://github.com/malcommac/SwiftLocation) - Mature async/await wrapper
- [AsyncLocationKit](https://github.com/AsyncSwift/AsyncLocationKit) - Lightweight alternative

However, **our current implementation works** - the warning is about potential UI jank, not crashes. This can be deferred if higher-priority items exist.

---

## Sources

- [How to Build Modern async/await Location Manager with Swift Concurrency](https://www.vbutko.com/articles/swift-async-await-location-manager/)
- [Thread-safe async location fetching in Swift](https://dev.to/randomengy/thread-safe-async-location-fetching-in-swift-31gm)
- [Updating the User's Location with Core Location and Swift Concurrency in SwiftUI](https://www.createwithswift.com/updating-the-users-location-with-core-location-and-swift-concurrency-in-swiftui/)
- [Apple CLLocationManager Documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager)

---

## Acceptance Criteria

- [x] No Xcode warnings about main thread blocking
- [ ] Authorization handled via delegate callback, not polling (deferred)
- [x] `CLLocationManager.locationServicesEnabled()` removed or moved off main thread
- [x] All existing location tests pass
- [x] Manual test: Location permission prompt works correctly
