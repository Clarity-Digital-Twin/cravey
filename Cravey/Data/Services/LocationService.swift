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
    private let maxAuthRetries: Int

    init(
        timeout: TimeInterval = AppConstants.Location.requestTimeout,
        maxAuthRetries: Int = AppConstants.Location.maxAuthRetries
    ) {
        locationManager = CLLocationManager()
        self.timeout = timeout
        self.maxAuthRetries = maxAuthRetries
    }

    func requestCurrentLocation() async -> LocationResult {
        await requestCurrentLocationWithRetry(retriesRemaining: maxAuthRetries)
    }

    private func requestCurrentLocationWithRetry(retriesRemaining: Int) async -> LocationResult {
        // Check system-wide location services (DEBT-017: moved to background to avoid blocking main thread)
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
            // Guard against infinite retries
            guard retriesRemaining > 0 else {
                return .error("Location permission not determined after retries")
            }
            // Request permission - this will show system prompt
            locationManager.requestWhenInUseAuthorization()
            // Wait briefly for user response, then check again
            try? await Task.sleep(for: .milliseconds(500))
            return await requestCurrentLocationWithRetry(retriesRemaining: retriesRemaining - 1)

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
