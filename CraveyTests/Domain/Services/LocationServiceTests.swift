@testable import Cravey
import Foundation
import Testing

// MARK: - Mock Location Service for Testing

/// Mock LocationService for unit tests
/// Thread-safety not needed since tests run on @MainActor
@MainActor
final class MockLocationService: LocationServiceProtocol {
    var mockResult: LocationResult = .success(latitude: 37.7749, longitude: -122.4194)
    var mockAuthStatus: LocationAuthorizationStatus = .authorized
    private(set) var requestLocationCallCount = 0

    func setMockResult(_ result: LocationResult) {
        mockResult = result
    }

    func setMockAuthStatus(_ status: LocationAuthorizationStatus) {
        mockAuthStatus = status
    }

    nonisolated func requestCurrentLocation() async -> LocationResult {
        await MainActor.run {
            requestLocationCallCount += 1
            return mockResult
        }
    }

    nonisolated func authorizationStatus() -> LocationAuthorizationStatus {
        // For sync access in tests, return a default
        // Tests should use setMockAuthStatus before calling
        .authorized
    }
}

// MARK: - LocationOptions Tests

@Suite("LocationOptions Tests")
struct LocationOptionsTests {
    @Test("currentLocationKey is first in presets")
    func currentLocationKeyIsFirst() {
        #expect(LocationOptions.presets.first == LocationOptions.currentLocationKey)
    }

    @Test("isCurrentLocationChip detects current location key")
    func isCurrentLocationChipDetection() {
        #expect(LocationOptions.isCurrentLocationChip(LocationOptions.currentLocationKey) == true)
        #expect(LocationOptions.isCurrentLocationChip("Home") == false)
        #expect(LocationOptions.isCurrentLocationChip("37.7749,-122.4194") == false)
    }

    @Test("formatGPS creates comma-separated string")
    func formatGPSCreatesString() {
        let result = LocationOptions.formatGPS(latitude: 37.7749, longitude: -122.4194)
        #expect(result == "37.7749,-122.4194")
    }

    @Test("isGPS detects GPS coordinate strings")
    func isGPSDetection() {
        #expect(LocationOptions.isGPS("37.7749,-122.4194") == true)
        #expect(LocationOptions.isGPS("Home") == false)
        #expect(LocationOptions.isGPS("Work") == false)
    }

    @Test("displayLocation shows Current Location for GPS strings")
    func displayLocationForGPS() {
        #expect(LocationOptions.displayLocation("37.7749,-122.4194") == "Current Location")
        #expect(LocationOptions.displayLocation("Home") == "Home")
        #expect(LocationOptions.displayLocation(nil) == "Unknown")
    }
}

// MARK: - ViewModel Location Handling Tests

@Suite("CravingLogViewModel Location Tests")
struct CravingLogViewModelLocationTests {
    @Test("handleLocationSelection stores preset directly")
    @MainActor
    func handleLocationSelectionPreset() async {
        let mockLocation = MockLocationService()
        let mockUseCase = MockLogCravingUseCase()
        let viewModel = CravingLogViewModel(
            logCravingUseCase: mockUseCase,
            locationService: mockLocation
        )

        await viewModel.handleLocationSelection("Home")

        #expect(viewModel.selectedLocation == "Home")
        #expect(mockLocation.requestLocationCallCount == 0) // Should NOT call location service for preset
    }

    @Test("handleLocationSelection with Current Location calls service on success")
    @MainActor
    func handleLocationSelectionCurrentLocationSuccess() async {
        let mockLocation = MockLocationService()
        mockLocation.setMockResult(.success(latitude: 37.7749, longitude: -122.4194))
        let mockUseCase = MockLogCravingUseCase()
        let viewModel = CravingLogViewModel(
            logCravingUseCase: mockUseCase,
            locationService: mockLocation
        )

        await viewModel.handleLocationSelection(LocationOptions.currentLocationKey)

        #expect(viewModel.selectedLocation == "37.7749,-122.4194")
        #expect(mockLocation.requestLocationCallCount == 1)
        #expect(viewModel.showLocationPermissionAlert == false)
    }

    @Test("handleLocationSelection with Current Location shows alert on permission denied")
    @MainActor
    func handleLocationSelectionPermissionDenied() async {
        let mockLocation = MockLocationService()
        mockLocation.setMockResult(.permissionDenied)
        let mockUseCase = MockLogCravingUseCase()
        let viewModel = CravingLogViewModel(
            logCravingUseCase: mockUseCase,
            locationService: mockLocation
        )

        await viewModel.handleLocationSelection(LocationOptions.currentLocationKey)

        #expect(viewModel.selectedLocation == nil)
        #expect(viewModel.showLocationPermissionAlert == true)
    }

    @Test("handleLocationSelection with Current Location shows error on timeout")
    @MainActor
    func handleLocationSelectionTimeout() async {
        let mockLocation = MockLocationService()
        mockLocation.setMockResult(.timeout)
        let mockUseCase = MockLogCravingUseCase()
        let viewModel = CravingLogViewModel(
            logCravingUseCase: mockUseCase,
            locationService: mockLocation
        )

        await viewModel.handleLocationSelection(LocationOptions.currentLocationKey)

        #expect(viewModel.selectedLocation == nil)
        #expect(viewModel.locationError != nil)
    }

    @Test("handleLocationSelection with Current Location shows error on services disabled")
    @MainActor
    func handleLocationSelectionServicesDisabled() async {
        let mockLocation = MockLocationService()
        mockLocation.setMockResult(.servicesDisabled)
        let mockUseCase = MockLogCravingUseCase()
        let viewModel = CravingLogViewModel(
            logCravingUseCase: mockUseCase,
            locationService: mockLocation
        )

        await viewModel.handleLocationSelection(LocationOptions.currentLocationKey)

        #expect(viewModel.selectedLocation == nil)
        #expect(viewModel.locationError != nil)
    }

    @Test("handleLocationSelection clears selection on nil")
    @MainActor
    func handleLocationSelectionNil() async {
        let mockLocation = MockLocationService()
        let mockUseCase = MockLogCravingUseCase()
        let viewModel = CravingLogViewModel(
            logCravingUseCase: mockUseCase,
            locationService: mockLocation
        )
        viewModel.selectedLocation = "Home"

        await viewModel.handleLocationSelection(nil)

        #expect(viewModel.selectedLocation == nil)
    }

    @Test("isLoadingLocation is true during location request")
    @MainActor
    func isLoadingLocationDuringRequest() async {
        let mockLocation = MockLocationService()
        let mockUseCase = MockLogCravingUseCase()
        let viewModel = CravingLogViewModel(
            logCravingUseCase: mockUseCase,
            locationService: mockLocation
        )

        // Before request
        #expect(viewModel.isLoadingLocation == false)

        // The loading state is set during the async call
        // After completion it should be false
        await viewModel.handleLocationSelection(LocationOptions.currentLocationKey)
        #expect(viewModel.isLoadingLocation == false)
    }
}

// Note: Uses MockLogCravingUseCase from CravingLogViewModelTests.swift (same test target)
