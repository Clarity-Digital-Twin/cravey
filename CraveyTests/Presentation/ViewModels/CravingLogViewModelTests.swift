@testable import Cravey
import Foundation
import Testing

/// Unit tests for CravingLogViewModel
/// Tests UI logic in isolation with mocked use case
@Suite("CravingLogViewModel Tests")
@MainActor
struct CravingLogViewModelTests {
    @Test("Should log craving successfully")
    func logCravingSuccess() async throws {
        // Arrange
        let mockUseCase = MockLogCravingUseCase()
        let viewModel = CravingLogViewModel(logCravingUseCase: mockUseCase)

        viewModel.intensity = 7
        viewModel.selectedTriggers = ["Anxious"]

        // Act
        await viewModel.logCraving()

        // Assert
        #expect(viewModel.didSucceed == true)
        #expect(viewModel.errorMessage == nil)
        let count = await mockUseCase.getExecutionCount()
        #expect(count == 1)
    }

    @Test("Fresh ViewModel should have default values")
    func freshViewModelHasDefaults() async {
        // Arrange: Create a fresh ViewModel (as HomeView does on sheet open)
        let mockUseCase = MockLogCravingUseCase()
        let viewModel = CravingLogViewModel(logCravingUseCase: mockUseCase)

        // Assert: Fresh VM has default state
        // Note: 2025 pattern is deferred init - VMs are discarded after success,
        // new VM created next time sheet opens (see HomeView onDismiss)
        #expect(viewModel.intensity == 5) // Default value
        #expect(viewModel.selectedTriggers == []) // Empty
        #expect(viewModel.notes == "") // Empty
        #expect(viewModel.didSucceed == false) // Not succeeded yet
        #expect(viewModel.errorMessage == nil) // No error
    }

    @Test("Notes should enforce 500 character limit")
    func notesEnforcesCharacterLimit() {
        let mockUseCase = MockLogCravingUseCase()
        let viewModel = CravingLogViewModel(logCravingUseCase: mockUseCase)

        viewModel.notes = String(repeating: "a", count: 501)

        #expect(viewModel.notes.count == 500)
        #expect(viewModel.notesCharacterCount == 500)
    }

    @Test("Cancelling a GPS request clears loading state and preserves new selection")
    func cancellingGPSRequestClearsLoadingState() async {
        let mockUseCase = MockLogCravingUseCase()
        let locationService = HangingLocationService()
        let viewModel = CravingLogViewModel(
            logCravingUseCase: mockUseCase,
            locationService: locationService
        )

        let gpsTask = Task {
            await viewModel.handleLocationSelection(LocationOptions.currentLocationKey)
        }

        // Wait until loading starts (avoid race with immediate selection change).
        while viewModel.isLoadingLocation == false {
            await Task.yield()
        }

        await viewModel.handleLocationSelection("Home")

        #expect(viewModel.selectedLocation == "Home")
        #expect(viewModel.isLoadingLocation == false)

        await gpsTask.value
    }
}

// MARK: - Mock Use Case

actor MockLogCravingUseCase: LogCravingUseCase {
    var executionCount = 0

    func execute(
        timestamp: Date,
        intensity: Int,
        triggers: [String],
        notes: String?,
        location: String?
    ) async throws -> CravingEntity {
        executionCount += 1
        return CravingEntity(
            timestamp: timestamp,
            intensity: intensity,
            triggers: triggers,
            location: location,
            notes: notes
        )
    }

    func getExecutionCount() async -> Int {
        executionCount
    }
}

// MARK: - Mock Location Service

actor HangingLocationService: LocationServiceProtocol {
    func requestCurrentLocation() async -> LocationResult {
        do {
            try await Task.sleep(for: .seconds(60))
            return .success(latitude: 1.0, longitude: 2.0)
        } catch {
            return .cancelled
        }
    }

    func authorizationStatus() async -> LocationAuthorizationStatus {
        .authorized
    }
}
