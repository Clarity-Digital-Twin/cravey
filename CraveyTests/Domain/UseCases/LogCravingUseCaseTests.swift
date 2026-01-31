@testable import Cravey
import Foundation
import Testing

/// Unit tests for LogCravingUseCase
/// Tests business logic in isolation with mocked repository
@Suite("LogCravingUseCase Tests")
struct LogCravingUseCaseTests {
    // MARK: - Tests

    @Test("Should save valid craving")
    func logValidCraving() async throws {
        // Arrange
        let fixedNow = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: fixedNow)
        let mockRepo = MockCravingRepository()
        let useCase = DefaultLogCravingUseCase(repository: mockRepo, clock: clock)

        // Act
        let result = try await useCase.execute(
            timestamp: fixedNow.addingTimeInterval(-TestConstants.Time.secondsPerHour), // 1 hour before "now"
            intensity: 5,
            triggers: ["Anxious", "Bored"],
            notes: "Test note",
            location: "Office"
        )

        // Assert
        #expect(result.intensity == 5)
        #expect(result.triggers == ["Anxious", "Bored"])
        #expect(result.createdAt == fixedNow) // Now verifiable!
        let savedCount = try await mockRepo.count()
        #expect(savedCount == 1)
    }

    @Test("Should reject invalid intensity")
    func rejectInvalidIntensity() async {
        // Arrange
        let fixedNow = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: fixedNow)
        let mockRepo = MockCravingRepository()
        let useCase = DefaultLogCravingUseCase(repository: mockRepo, clock: clock)

        // Act & Assert
        await #expect(throws: CravingError.self) {
            try await useCase.execute(
                timestamp: fixedNow,
                intensity: 11, // Invalid
                triggers: [],
                notes: nil,
                location: nil
            )
        }
    }

    @Test("Should reject future timestamp")
    func rejectFutureTimestamp() async throws {
        let fixedNow = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: fixedNow)
        let mockRepo = MockCravingRepository()
        let useCase = DefaultLogCravingUseCase(repository: mockRepo, clock: clock)

        do {
            _ = try await useCase.execute(
                timestamp: fixedNow.addingTimeInterval(TestConstants.Time.secondsPerMinute), // Always future relative to fixedNow
                intensity: 5,
                triggers: [],
                notes: nil,
                location: nil
            )
            Issue.record("Should have thrown futureTimestamp error")
        } catch CravingError.futureTimestamp {
            // ✅ Expected
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }

    @Test("Should reject notes longer than 500 characters")
    func rejectNotesTooLong() async throws {
        let fixedNow = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: fixedNow)
        let mockRepo = MockCravingRepository()
        let useCase = DefaultLogCravingUseCase(repository: mockRepo, clock: clock)

        let longNotes = String(repeating: "a", count: TestConstants.Notes.overMaxLength)

        do {
            _ = try await useCase.execute(
                timestamp: fixedNow,
                intensity: 5,
                triggers: [],
                notes: longNotes,
                location: nil
            )
            Issue.record("Should have thrown notesTooLong error")
        } catch CravingError.notesTooLong {
            // ✅ Expected
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }
}

// MARK: - Mock Repository

actor MockCravingRepository: CravingRepositoryProtocol {
    var savedCravings: [CravingEntity] = []
    var updateCallCount = 0
    var lastUpdatedCraving: CravingEntity?

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
        updateCallCount += 1
        lastUpdatedCraving = craving
        if let index = savedCravings.firstIndex(where: { $0.id == craving.id }) {
            savedCravings[index] = craving
        }
    }

    func count() async throws -> Int {
        savedCravings.count
    }
}
