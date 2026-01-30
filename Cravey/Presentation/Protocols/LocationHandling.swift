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
}

extension LocationHandling {
    /// Handle location chip selection
    /// For "Current Location", requests GPS; for presets, stores directly
    func handleLocationSelection(_ selection: String?) async {
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
