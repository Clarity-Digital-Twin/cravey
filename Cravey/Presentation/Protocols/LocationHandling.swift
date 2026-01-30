import Foundation

/// Protocol for ViewModels that handle GPS location selection
/// Extracts common location handling logic (DEBT-023)
@MainActor
protocol LocationHandling: AnyObject {
    var selectedLocation: String? { get set }
    var isLoadingLocation: Bool { get set }
    var showLocationPermissionAlert: Bool { get set }
    var locationError: String? { get set }
    var locationService: LocationServiceProtocol? { get }
    /// Task handle for in-flight location requests (BUG-034: enables cancellation)
    var locationTask: Task<Void, Never>? { get set }
}

extension LocationHandling {
    /// Handle location chip selection
    /// For "Current Location", requests GPS; for presets, stores directly
    /// BUG-034: Cancels any in-flight GPS request before starting new one
    func handleLocationSelection(_ selection: String?) async {
        // Cancel any in-flight location request (BUG-034: prevents race condition)
        locationTask?.cancel()
        locationTask = nil

        // Clear any previous location error
        locationError = nil

        guard let selection else {
            selectedLocation = nil
            return
        }

        // Check if this is the "Current Location" chip
        guard LocationOptions.isCurrentLocationChip(selection) else {
            // Normal preset - store directly
            selectedLocation = selection
            return
        }

        // Current Location tapped - request GPS
        guard let locationService else {
            // No location service available (e.g., in tests without mock)
            locationError = "Location service unavailable"
            selectedLocation = nil
            return
        }

        isLoadingLocation = true

        // Store task reference for potential cancellation (BUG-034)
        let task = Task {
            defer {
                if !Task.isCancelled {
                    isLoadingLocation = false
                }
            }

            let result = await locationService.requestCurrentLocation()

            // Check if cancelled before applying result (BUG-034)
            guard !Task.isCancelled else { return }

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

            case .cancelled:
                // User or system cancelled - silently ignore (BUG-033/034)
                break

            case let .error(message):
                locationError = message
                selectedLocation = nil
            }
        }
        locationTask = task
        await task.value
    }
}
