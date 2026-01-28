import CoreLocation
import Foundation

/// CoreLocation implementation of LocationServiceProtocol
/// Uses iOS 17+ async/await APIs for modern, clean location handling
/// Data layer - implements Domain protocol with framework-specific code
final class LocationService: LocationServiceProtocol, @unchecked Sendable {
    private let locationManager: CLLocationManager
    private let timeout: TimeInterval

    init(timeout: TimeInterval = 10.0) {
        locationManager = CLLocationManager()
        self.timeout = timeout
    }

    func requestCurrentLocation() async -> LocationResult {
        // Check system-wide location services
        guard CLLocationManager.locationServicesEnabled() else {
            return .servicesDisabled
        }

        // Check/request authorization
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            // Request permission - this will show system prompt
            locationManager.requestWhenInUseAuthorization()
            // Wait briefly for user response, then check again
            try? await Task.sleep(for: .milliseconds(500))
            return await requestCurrentLocation() // Recursive call after permission prompt

        case .denied:
            return .permissionDenied

        case .restricted:
            return .permissionRestricted

        case .authorizedWhenInUse, .authorizedAlways:
            break // Authorized, proceed to get location

        @unknown default:
            return .error("Unknown authorization status")
        }

        // Use iOS 17+ async location updates
        do {
            // Create a task that times out
            return try await withThrowingTaskGroup(of: LocationResult.self) { group in
                // Location fetch task
                group.addTask {
                    // iOS 17+ liveUpdates() returns an AsyncSequence
                    for try await update in CLLocationUpdate.liveUpdates() {
                        if let location = update.location {
                            return .success(
                                latitude: location.coordinate.latitude,
                                longitude: location.coordinate.longitude
                            )
                        }
                    }
                    return .error("No location received")
                }

                // Timeout task
                group.addTask {
                    try await Task.sleep(for: .seconds(self.timeout))
                    return .timeout
                }

                // Return whichever finishes first
                if let result = try await group.next() {
                    group.cancelAll()
                    return result
                }
                return .timeout
            }
        } catch is CancellationError {
            return .timeout
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func authorizationStatus() -> LocationAuthorizationStatus {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .authorizedWhenInUse, .authorizedAlways:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
}
