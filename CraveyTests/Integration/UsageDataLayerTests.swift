@testable import Cravey
import Foundation
import SwiftData
import Testing

@Suite("Usage Data Layer Integration Tests (Phase 2A)")
struct UsageDataLayerTests {
    @MainActor
    private static func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        return ModelContext(container)
    }

    // MARK: - Test 1: End-to-End Validation

    @Test("Should log usage end-to-end (UseCase → Repository → SwiftData)")
    @MainActor
    func endToEndUsageLog() async throws {
        // Setup in-memory SwiftData
        let context = try Self.makeInMemoryContext()

        // Create real repository and use case
        let repository = UsageRepository(modelContext: context)
        let now = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: now)
        let useCase = DefaultLogUsageUseCase(repository: repository, clock: clock)

        // Execute
        let request = LogUsageRequest(
            timestamp: now,
            method: "Bowls",
            amount: 2.5,
            triggers: ["Anxious", "Bored"],
            location: "Home",
            notes: "Test note"
        )
        let result = try await useCase.execute(request)

        // Verify entity returned
        #expect(result.method == "Bowls")
        #expect(result.amount == 2.5)
        #expect(result.triggers.count == 2)

        // Verify persisted to SwiftData
        let descriptor = FetchDescriptor<UsageModel>()
        let saved = try context.fetch(descriptor)
        #expect(saved.count == 1)
        #expect(saved.first?.method == "Bowls")
        #expect(saved.first?.amount == 2.5)
    }

    // MARK: - Test 2: Fetch Validation

    @Test("Should fetch usage from SwiftData")
    @MainActor
    func fetchUsage() async throws {
        // Setup
        let context = try Self.makeInMemoryContext()

        // Insert test data directly
        let now = TestConstants.fixedEpoch
        let model1 = UsageModel(timestamp: now, method: "Vape", amount: 5.0)
        let model2 = UsageModel(
            timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerHour),
            method: "Edible",
            amount: 10.0
        )
        context.insert(model1)
        context.insert(model2)
        try context.save()

        // Fetch via use case
        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultFetchUsageUseCase(repository: repository)
        let results = try await useCase.execute()

        // Verify sorted by timestamp descending
        #expect(results.count == 2)
        #expect(results[0].method == "Vape") // Most recent
        #expect(results[1].method == "Edible")
    }

    // MARK: - Test 3: Validate All 6 ROAs

    @Test("Should accept all 6 valid ROA methods")
    @MainActor
    func allROAMethods() async throws {
        let context = try Self.makeInMemoryContext()

        let repository = UsageRepository(modelContext: context)
        let now = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: now)
        let useCase = DefaultLogUsageUseCase(repository: repository, clock: clock)

        let methods = UsageMethod.allCases.map(\.rawValue)

        for method in methods {
            let validAmount = ROAAmountRange.range(for: method).first ?? 1.0
            let result = try await useCase.execute(
                LogUsageRequest(timestamp: now, method: method, amount: validAmount)
            )
            #expect(result.method == method)
        }

        // Verify all 6 saved
        let descriptor = FetchDescriptor<UsageModel>()
        let saved = try context.fetch(descriptor)
        #expect(saved.count == 6)
    }

    // MARK: - Test 4: Invalid Method Validation

    @Test("Should reject invalid ROA method")
    @MainActor
    func testInvalidMethod() async throws {
        let context = try Self.makeInMemoryContext()

        let repository = UsageRepository(modelContext: context)
        let now = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: now)
        let useCase = DefaultLogUsageUseCase(repository: repository, clock: clock)

        do {
            _ = try await useCase.execute(
                LogUsageRequest(timestamp: now, method: "InvalidMethod", amount: 2.0)
            )
            Issue.record("Should have thrown invalidMethod error")
        } catch UsageError.invalidMethod {
            // ✅ Expected error
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }

    // MARK: - Test 5: Amount Validation

    @Test("Should reject amount = 0")
    @MainActor
    func zeroAmount() async throws {
        let context = try Self.makeInMemoryContext()

        let repository = UsageRepository(modelContext: context)
        let now = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: now)
        let useCase = DefaultLogUsageUseCase(repository: repository, clock: clock)

        do {
            _ = try await useCase.execute(LogUsageRequest(timestamp: now, method: "Bowls", amount: 0))
            Issue.record("Should have thrown invalidAmount error")
        } catch UsageError.invalidAmount {
            // ✅ Expected error
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }

    // MARK: - Test 6: Future Timestamp Validation

    @Test("Should reject future timestamp")
    @MainActor
    func futureTimestamp() async throws {
        let context = try Self.makeInMemoryContext()

        let repository = UsageRepository(modelContext: context)
        let now = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: now)
        let useCase = DefaultLogUsageUseCase(repository: repository, clock: clock)

        do {
            _ = try await useCase.execute(
                LogUsageRequest(
                    timestamp: now.addingTimeInterval(TestConstants.Time.secondsPerMinute),
                    method: "Bowls",
                    amount: 1.0
                )
            )
            Issue.record("Should have thrown futureTimestamp error")
        } catch UsageError.futureTimestamp {
            // ✅ Expected error
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }

    // MARK: - Test 7: Notes Length Validation

    @Test("Should reject notes longer than 500 characters")
    @MainActor
    func notesTooLong() async throws {
        let context = try Self.makeInMemoryContext()

        let repository = UsageRepository(modelContext: context)
        let now = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: now)
        let useCase = DefaultLogUsageUseCase(repository: repository, clock: clock)

        let longNotes = String(repeating: "a", count: TestConstants.Notes.overMaxLength)

        do {
            _ = try await useCase.execute(
                LogUsageRequest(timestamp: now, method: "Bowls", amount: 1.0, notes: longNotes)
            )
            Issue.record("Should have thrown notesTooLong error")
        } catch UsageError.notesTooLong {
            // ✅ Expected error
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }

    // MARK: - Test 8: Notes at Boundary (500 chars accepted)

    @Test("Should accept notes at exactly 500 characters")
    @MainActor
    func notesAtLimit() async throws {
        let context = try Self.makeInMemoryContext()

        let repository = UsageRepository(modelContext: context)
        let now = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: now)
        let useCase = DefaultLogUsageUseCase(repository: repository, clock: clock)

        let maxNotes = String(repeating: "a", count: TestConstants.Notes.atMaxLength)
        let result = try await useCase.execute(
            LogUsageRequest(timestamp: now, method: "Bowls", amount: 1.0, notes: maxNotes)
        )

        #expect(result.notes == maxNotes)
        #expect(result.notes?.count == TestConstants.Notes.atMaxLength)
    }

    // MARK: - Test 9: HAALT Triggers Validation

    @Test("Should accept HAALT triggers array")
    @MainActor
    func hAALTTriggers() async throws {
        let context = try Self.makeInMemoryContext()

        let repository = UsageRepository(modelContext: context)
        let now = TestConstants.fixedEpoch
        let clock = FixedClock(fixedNow: now)
        let useCase = DefaultLogUsageUseCase(repository: repository, clock: clock)

        // Test with all 10 HAALT triggers
        let allTriggers = TriggerOptions.all
        let result = try await useCase.execute(
            LogUsageRequest(timestamp: now, method: "Edible", amount: 25.0, triggers: allTriggers)
        )

        #expect(result.triggers.count == 10)
        #expect(result.triggers.contains("Hungry"))
        #expect(result.triggers.contains("Paraphernalia"))
    }
}
