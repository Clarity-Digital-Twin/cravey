@testable import Cravey
import Foundation
import Testing

/// Unit tests for LogUsageUseCase
/// Tests business logic in isolation with mocked repository
@Suite("LogUsageUseCase Tests")
struct LogUsageUseCaseTests {
    // MARK: - Happy Path

    @Test("Should save valid usage")
    func logValidUsage() async throws {
        let fixedNow = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: fixedNow)
        let mockRepo = MockUsageRepository()
        let useCase = DefaultLogUsageUseCase(repository: mockRepo, clock: clock)

        let request = LogUsageRequest(
            timestamp: fixedNow.addingTimeInterval(-TestConstants.Time.secondsPerHour),
            method: "Bowls",
            amount: 1.0,
            triggers: ["Anxious", "Bored"],
            location: "Home",
            notes: "Test note"
        )

        let result = try await useCase.execute(request)

        #expect(result.method == "Bowls")
        #expect(result.amount == 1.0)
        #expect(result.triggers == ["Anxious", "Bored"])
        #expect(result.createdAt == fixedNow)

        let savedCount = await mockRepo.count()
        #expect(savedCount == 1)
    }

    // MARK: - Method Validation

    @Test("Should reject invalid method")
    func rejectInvalidMethod() async {
        let fixedNow = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: fixedNow)
        let mockRepo = MockUsageRepository()
        let useCase = DefaultLogUsageUseCase(repository: mockRepo, clock: clock)

        let request = LogUsageRequest(
            timestamp: fixedNow,
            method: "InvalidMethod",
            amount: 1.0
        )

        await #expect(throws: UsageError.self) {
            try await useCase.execute(request)
        }
    }

    @Test("Should accept all valid ROA methods")
    func acceptAllValidMethods() async throws {
        let fixedNow = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: fixedNow)
        let validMethods = ["Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible"]

        for method in validMethods {
            let mockRepo = MockUsageRepository()
            let useCase = DefaultLogUsageUseCase(repository: mockRepo, clock: clock)

            // Use valid amount for each method
            let amount: Double = method == "Edible" ? 10.0 : 1.0

            let request = LogUsageRequest(
                timestamp: fixedNow,
                method: method,
                amount: amount
            )

            let result = try await useCase.execute(request)
            #expect(result.method == method, "Method \(method) should be accepted")
        }
    }

    // MARK: - Amount Validation

    @Test("Should reject zero amount")
    func rejectZeroAmount() async {
        let fixedNow = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: fixedNow)
        let mockRepo = MockUsageRepository()
        let useCase = DefaultLogUsageUseCase(repository: mockRepo, clock: clock)

        let request = LogUsageRequest(
            timestamp: fixedNow,
            method: "Bowls",
            amount: 0
        )

        await #expect(throws: UsageError.self) {
            try await useCase.execute(request)
        }
    }

    @Test("Should reject negative amount")
    func rejectNegativeAmount() async {
        let fixedNow = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: fixedNow)
        let mockRepo = MockUsageRepository()
        let useCase = DefaultLogUsageUseCase(repository: mockRepo, clock: clock)

        let request = LogUsageRequest(
            timestamp: fixedNow,
            method: "Bowls",
            amount: -1.0
        )

        await #expect(throws: UsageError.self) {
            try await useCase.execute(request)
        }
    }

    @Test("Should reject amount out of range for method")
    func rejectAmountOutOfRange() async {
        let fixedNow = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: fixedNow)
        let mockRepo = MockUsageRepository()
        let useCase = DefaultLogUsageUseCase(repository: mockRepo, clock: clock)

        // Bowls max is 5.0, so 10.0 should fail
        let request = LogUsageRequest(
            timestamp: fixedNow,
            method: "Bowls",
            amount: 10.0
        )

        await #expect(throws: UsageError.self) {
            try await useCase.execute(request)
        }
    }

    // MARK: - Timestamp Validation

    @Test("Should reject future timestamp")
    func rejectFutureTimestamp() async {
        let fixedNow = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: fixedNow)
        let mockRepo = MockUsageRepository()
        let useCase = DefaultLogUsageUseCase(repository: mockRepo, clock: clock)

        let request = LogUsageRequest(
            timestamp: fixedNow.addingTimeInterval(60), // 1 minute in future
            method: "Bowls",
            amount: 1.0
        )

        do {
            _ = try await useCase.execute(request)
            Issue.record("Should have thrown futureTimestamp error")
        } catch UsageError.futureTimestamp {
            // ✅ Expected
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }

    // MARK: - Notes Validation

    @Test("Should reject notes longer than max")
    func rejectNotesTooLong() async {
        let fixedNow = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: fixedNow)
        let mockRepo = MockUsageRepository()
        let useCase = DefaultLogUsageUseCase(repository: mockRepo, clock: clock)

        let longNotes = String(repeating: "a", count: TestConstants.Notes.overMaxLength)

        let request = LogUsageRequest(
            timestamp: fixedNow,
            method: "Bowls",
            amount: 1.0,
            notes: longNotes
        )

        do {
            _ = try await useCase.execute(request)
            Issue.record("Should have thrown notesTooLong error")
        } catch UsageError.notesTooLong {
            // ✅ Expected
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }

    @Test("Should accept notes at exactly max length")
    func acceptNotesAtMaxLength() async throws {
        let fixedNow = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: fixedNow)
        let mockRepo = MockUsageRepository()
        let useCase = DefaultLogUsageUseCase(repository: mockRepo, clock: clock)

        let maxNotes = String(repeating: "a", count: TestConstants.Notes.atMaxLength)

        let request = LogUsageRequest(
            timestamp: fixedNow,
            method: "Bowls",
            amount: 1.0,
            notes: maxNotes
        )

        let result = try await useCase.execute(request)
        #expect(result.notes?.count == ValidationLimits.notesMaxLength)
    }
}

// MARK: - Mock Repository

actor MockUsageRepository: UsageRepositoryProtocol {
    private var usages: [UsageEntity] = []

    func save(_ usage: UsageEntity) async throws {
        usages.append(usage)
    }

    func fetchAll() async throws -> [UsageEntity] {
        usages
    }

    func fetch(since date: Date) async throws -> [UsageEntity] {
        usages.filter { $0.timestamp >= date }
    }

    func delete(id: UUID) async throws {
        usages.removeAll { $0.id == id }
    }

    func deleteAll() async throws {
        usages.removeAll()
    }

    func count() -> Int {
        usages.count
    }
}
