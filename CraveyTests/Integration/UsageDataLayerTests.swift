@testable import Cravey
import Foundation
import SwiftData
import Testing

@Suite("Usage Data Layer Integration Tests (Phase 2A)")
struct UsageDataLayerTests {
    // MARK: - Test 1: End-to-End Validation

    @Test("Should log usage end-to-end (UseCase → Repository → SwiftData)")
    @MainActor
    func endToEndUsageLog() async throws {
        // Setup in-memory SwiftData
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        // Create real repository and use case
        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)

        // Execute
        let request = LogUsageRequest(
            timestamp: Date(),
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
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        // Insert test data directly
        let model1 = UsageModel(timestamp: Date(), method: "Vape", amount: 5.0)
        let model2 = UsageModel(timestamp: Date().addingTimeInterval(-3600), method: "Edible", amount: 10.0)
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
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)

        let methods = ["Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible"]

        for method in methods {
            let validAmount = ROAAmountRange.range(for: method).first ?? 1.0
            let result = try await useCase.execute(LogUsageRequest(method: method, amount: validAmount))
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
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)

        do {
            _ = try await useCase.execute(LogUsageRequest(method: "InvalidMethod", amount: 2.0))
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
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)

        do {
            _ = try await useCase.execute(LogUsageRequest(method: "Bowls", amount: 0))
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
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)

        do {
            _ = try await useCase.execute(
                LogUsageRequest(timestamp: Date().addingTimeInterval(60), method: "Bowls", amount: 1.0)
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
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)

        let longNotes = String(repeating: "a", count: 501)

        do {
            _ = try await useCase.execute(LogUsageRequest(method: "Bowls", amount: 1.0, notes: longNotes))
            Issue.record("Should have thrown notesTooLong error")
        } catch UsageError.notesTooLong {
            // ✅ Expected error
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }

    // MARK: - Test 8: HAALT Triggers Validation

    @Test("Should accept HAALT triggers array")
    @MainActor
    func hAALTTriggers() async throws {
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)

        // Test with all 10 HAALT triggers
        let allTriggers = TriggerOptions.all
        let result = try await useCase.execute(LogUsageRequest(method: "Edible", amount: 25.0, triggers: allTriggers))

        #expect(result.triggers.count == 10)
        #expect(result.triggers.contains("Hungry"))
        #expect(result.triggers.contains("Paraphernalia"))
    }
}
