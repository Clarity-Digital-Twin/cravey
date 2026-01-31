import CoreLocation
import Foundation

/// CoreLocation implementation of LocationServiceProtocol
/// Uses iOS 17+ async/await APIs for modern, clean location handling
/// Data layer - implements Domain protocol with framework-specific code
/// @MainActor ensures CLLocationManager is accessed from the main thread
@MainActor
final class LocationService: LocationServiceProtocol {
    private let locationManager: CLLocationManager
    private let timeout: TimeInterval

    init(timeout: TimeInterval) {
        locationManager = CLLocationManager()
        self.timeout = timeout
    }

    func requestCurrentLocation() async -> LocationResult {
        await requestCurrentLocationWithRetry()
    }

    private func requestCurrentLocationWithRetry() async -> LocationResult {
        // Check system-wide location services (moved to background to avoid blocking main thread)
        let servicesEnabled = await Task.detached {
            CLLocationManager.locationServicesEnabled()
        }.value

        guard servicesEnabled else {
            return .servicesDisabled
        }

        // Check/request authorization
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            // Request permission and await response (DEBT-039)
            // Uses polling with reasonable intervals since CLLocationManager
            // doesn't have a native async auth stream we can await here.
            locationManager.requestWhenInUseAuthorization()

            // Poll for authorization change until user responds (BUG-033 fix)
            let pollInterval: Duration = .milliseconds(100)
            while locationManager.authorizationStatus == .notDetermined {
                // Check if cancelled
                if Task.isCancelled {
                    return .cancelled
                }

                // Wait before polling again
                do {
                    try await Task.sleep(for: pollInterval)
                } catch {
                    return .cancelled
                }
            }

            return await handleAuthorizedStatus(locationManager.authorizationStatus)

        case .denied:
            return .permissionDenied

        case .restricted:
            return .permissionRestricted

        case .authorizedWhenInUse, .authorizedAlways:
            return await fetchLocation()

        @unknown default:
            return .error("Unknown authorization status")
        }
    }

    /// Handle result after authorization change
    private func handleAuthorizedStatus(_ status: CLAuthorizationStatus) async -> LocationResult {
        switch status {
        case .denied:
            .permissionDenied
        case .restricted:
            .permissionRestricted
        case .authorizedWhenInUse, .authorizedAlways:
            await fetchLocation()
        default:
            .error("Authorization not granted")
        }
    }

    /// Fetch actual location after authorization confirmed
    private func fetchLocation() async -> LocationResult {
        do {
            return try await withThrowingTaskGroup(of: LocationResult.self) { group in
                // Location fetch task using iOS 17+ liveUpdates
                group.addTask {
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
                guard let result = try await group.next() else {
                    return .timeout
                }
                group.cancelAll()
                return result
            }
        } catch is CancellationError {
            return .cancelled
        } catch {
            return .error(error.localizedDescription)
        }
    }

    /// Returns current authorization status
    /// Async to allow cross-actor access from non-MainActor contexts
    func authorizationStatus() async -> LocationAuthorizationStatus {
        let status = locationManager.authorizationStatus
        switch status {
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
