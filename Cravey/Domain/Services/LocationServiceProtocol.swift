import Foundation

/// Result of a location request
/// Domain layer - no CoreLocation dependency
enum LocationResult: Sendable, Equatable {
    case success(latitude: Double, longitude: Double)
    case permissionDenied
    case permissionRestricted
    case servicesDisabled
    case timeout
    case cancelled // User or system cancelled the request (BUG-033)
    case error(String)
}

/// Authorization status for location services
/// Domain layer - no CoreLocation dependency
enum LocationAuthorizationStatus: Sendable, Equatable {
    case notDetermined
    case authorized
    case denied
    case restricted
}

/// Protocol for location services
/// Domain layer - framework-independent for testability
protocol LocationServiceProtocol: Sendable {
    /// Request current location (may trigger permission prompt if not determined)
    /// Returns immediately with denied/restricted if not authorized
    func requestCurrentLocation() async -> LocationResult

    /// Check current authorization without triggering prompt
    /// Async to allow @MainActor implementations
    func authorizationStatus() async -> LocationAuthorizationStatus
}
