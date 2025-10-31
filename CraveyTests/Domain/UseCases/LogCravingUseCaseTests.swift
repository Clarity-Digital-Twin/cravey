import Testing
import Foundation
@testable import Cravey

/// Unit tests for LogCravingUseCase
/// Tests business logic in isolation with mocked repository
@Suite("LogCravingUseCase Tests")
struct LogCravingUseCaseTests {
    @Test("Should save valid craving")
    func testLogValidCraving() async throws {
        // Arrange
        let mockRepo = MockCravingRepository()
        let useCase = DefaultLogCravingUseCase(repository: mockRepo)

        // Act
        let result = try await useCase.execute(
            intensity: 5,
            triggers: ["Anxious", "Bored"],
            notes: "Test note",
            location: "Office",
            wasManagedSuccessfully: true
        )

        // Assert
        #expect(result.intensity == 5)
        #expect(result.triggers == ["Anxious", "Bored"])
        let savedCount = try await mockRepo.count()
        #expect(savedCount == 1)
    }

    @Test("Should reject invalid intensity")
    func testRejectInvalidIntensity() async {
        // Arrange
        let mockRepo = MockCravingRepository()
        let useCase = DefaultLogCravingUseCase(repository: mockRepo)

        // Act & Assert
        await #expect(throws: CravingError.self) {
            try await useCase.execute(
                intensity: 11,  // Invalid
                triggers: [],
                notes: nil,
                location: nil,
                wasManagedSuccessfully: false
            )
        }
    }
}

// MARK: - Mock Repository

actor MockCravingRepository: CravingRepositoryProtocol {
    var savedCravings: [CravingEntity] = []

    func save(_ craving: CravingEntity) async throws {
        savedCravings.append(craving)
    }

    func fetchAll() async throws -> [CravingEntity] {
        savedCravings
    }

    func fetch(from startDate: Date, to endDate: Date) async throws -> [CravingEntity] {
        savedCravings.filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
    }

    func delete(id: UUID) async throws {
        savedCravings.removeAll { $0.id == id }
    }

    func update(_ craving: CravingEntity) async throws {
        // Mock implementation
    }

    func count() async throws -> Int {
        savedCravings.count
    }
}
