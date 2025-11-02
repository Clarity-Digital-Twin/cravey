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
        #expect(viewModel.showSuccessAlert == true)
        #expect(viewModel.errorMessage == nil)
        let count = await mockUseCase.getExecutionCount()
        #expect(count == 1)
    }

    @Test("Should reset form after successful submission")
    func formResetAfterSuccess() async {
        // Arrange
        let mockUseCase = MockLogCravingUseCase()
        let viewModel = CravingLogViewModel(logCravingUseCase: mockUseCase)

        viewModel.intensity = 8
        viewModel.selectedTriggers = ["Bored"]

        // Act
        await viewModel.logCraving()

        // Assert
        #expect(viewModel.intensity == 5) // Reset to default
        #expect(viewModel.selectedTriggers == []) // Cleared
    }
}

// MARK: - Mock Use Case

actor MockLogCravingUseCase: LogCravingUseCase {
    var executionCount = 0

    func execute(
        intensity: Int,
        triggers: [String],
        notes: String?,
        location: String?,
        wasManagedSuccessfully: Bool
    ) async throws -> CravingEntity {
        executionCount += 1
        return CravingEntity(
            intensity: intensity,
            triggers: triggers,
            notes: notes,
            location: location,
            wasManagedSuccessfully: wasManagedSuccessfully
        )
    }

    func getExecutionCount() async -> Int {
        executionCount
    }
}
