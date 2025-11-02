import Testing
import SwiftData
import Foundation
@testable import Cravey

/// Integration tests for craving log flow
/// Tests end-to-end flow: Form → ViewModel → UseCase → Repository → SwiftData
@Suite("Craving Log Integration Tests")
struct CravingLogIntegrationTests {

    @Test("Should log craving end-to-end (Form → ViewModel → UseCase → Repository → SwiftData)")
    @MainActor
    func testEndToEndCravingLog() async throws {
        // Setup: In-memory SwiftData container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: CravingModel.self,
            configurations: config
        )
        let context = ModelContext(container)

        // Setup: Real dependencies (no mocks)
        let repository = CravingRepository(modelContext: context)
        let useCase = DefaultLogCravingUseCase(repository: repository)
        let viewModel = CravingLogViewModel(logCravingUseCase: useCase)

        // Given: User fills form
        viewModel.intensity = 7
        viewModel.selectedTriggers = Set(["Anxious", "Bored"])
        viewModel.notes = "Integration test"
        viewModel.location = "Home"
        viewModel.wasManagedSuccessfully = false

        // When: User taps Save
        await viewModel.logCraving()

        // Then: Craving saved to SwiftData
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.showSuccessAlert == true)

        // Verify: Fetch from SwiftData
        let descriptor = FetchDescriptor<CravingModel>()
        let results = try context.fetch(descriptor)
        #expect(results.count == 1)

        let savedCraving = results[0]
        #expect(savedCraving.intensity == 7)
        #expect(savedCraving.triggers.sorted() == ["Anxious", "Bored"].sorted())
        #expect(savedCraving.notes == "Integration test")
    }

    @Test("Should fetch cravings end-to-end (SwiftData → Repository → UseCase → ViewModel)")
    @MainActor
    func testEndToEndFetchCravings() async throws {
        // Setup
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: CravingModel.self,
            configurations: config
        )
        let context = ModelContext(container)

        // Insert sample craving
        let craving = CravingModel(
            timestamp: Date(),
            intensity: 5,
            triggers: ["Stressed"],
            notes: "Test",
            wasManagedSuccessfully: true
        )
        context.insert(craving)
        try context.save()

        // Setup: Real dependencies
        let repository = CravingRepository(modelContext: context)
        let useCase = DefaultFetchCravingsUseCase(repository: repository)
        let viewModel = CravingListViewModel(fetchCravingsUseCase: useCase)

        // When: Fetch cravings
        await viewModel.fetchCravings()

        // Then: Craving appears in ViewModel
        #expect(viewModel.cravings.count == 1)
        #expect(viewModel.cravings[0].intensity == 5)
        #expect(viewModel.cravings[0].triggers == ["Stressed"])
    }
}
