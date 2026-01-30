@testable import Cravey
import Foundation
import SwiftData
import Testing

/// Phase 2C Integration Tests - Usage Logging ViewModel Integration
/// Tests full chain: Form → ViewModel → UseCase → Repository → SwiftData
/// Source: PHASE_2C.md lines 103-104
@Suite("Usage Log Integration Tests (Phase 2C)")
@MainActor
struct UsageLogIntegrationTests {
    // MARK: - Test 1: End-to-End Usage Log (Form → VM → UC → Repo)

    @Test("Should log usage end-to-end through ViewModel (Form → VM → UC → Repo)")
    func endToEndUsageLogThroughViewModel() async throws {
        // Setup in-memory SwiftData
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        // Create real repository, use case, and ViewModel
        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)
        let viewModel = UsageLogViewModel(logUsageUseCase: useCase)

        // Simulate user filling form (Form → VM)
        viewModel.timestamp = Date()
        viewModel.selectedMethod = "Vape"
        viewModel.amount = 5.0
        viewModel.selectedTriggers = ["Anxious", "Bored"]
        viewModel.selectedLocation = "Home"
        viewModel.notes = "Integration test - full chain validation"

        // Verify form is valid
        #expect(viewModel.canSubmit == true)

        // Execute via ViewModel (VM → UC → Repo → SwiftData)
        await viewModel.logUsage()

        // Verify ViewModel signaled success
        #expect(viewModel.didSucceed == true, "ViewModel should signal success")
        #expect(viewModel.errorMessage == nil, "Should have no error")

        // Verify persisted to SwiftData
        let descriptor = FetchDescriptor<UsageModel>()
        let saved = try context.fetch(descriptor)
        #expect(saved.count == 1, "Should save 1 usage entry")

        let savedUsage = try #require(saved.first)
        #expect(savedUsage.method == "Vape")
        #expect(savedUsage.amount == 5.0)
        // Triggers are stored as Set internally, so order may vary
        #expect(Set(savedUsage.triggers) == Set(["Anxious", "Bored"]))
        #expect(savedUsage.location == "Home")
        #expect(savedUsage.notes == "Integration test - full chain validation")
    }

    // MARK: - Test 2: Fetch and Display Usage from SwiftData

    @Test("Should fetch and display usage through ViewModel (SwiftData → Repo → UC → VM)")
    func fetchAndDisplayUsageThroughViewModel() async throws {
        // Setup in-memory SwiftData with test data
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        // Insert test data directly into SwiftData
        let usage1 = UsageModel(
            timestamp: Date(),
            method: "Bowls",
            amount: 2.5,
            triggers: ["Bored"],
            location: "Out",
            notes: "Test entry 1"
        )
        let usage2 = UsageModel(
            timestamp: Date().addingTimeInterval(-3600),
            method: "Edible",
            amount: 10.0,
            triggers: ["Social"],
            location: "Other",
            notes: "Test entry 2"
        )
        context.insert(usage1)
        context.insert(usage2)
        try context.save()

        // Create real repository, use case, and ViewModel
        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultFetchUsageUseCase(repository: repository)
        let deleteUseCase = DefaultDeleteUsageUseCase(repository: repository)
        let viewModel = UsageListViewModel(fetchUsageUseCase: useCase, deleteUsageUseCase: deleteUseCase)

        // Execute fetch via ViewModel (VM → UC → Repo → SwiftData)
        await viewModel.fetchUsage()

        // Verify ViewModel has data
        #expect(viewModel.usageList.count == 2, "Should fetch 2 usage entries")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)

        // Verify data is correctly mapped and sorted (newest first)
        let first = viewModel.usageList[0]
        #expect(first.method == "Bowls", "Newest entry should be first")
        #expect(first.amount == 2.5)
        #expect(first.triggers == ["Bored"])
        #expect(first.location == "Out")
        #expect(first.notes == "Test entry 1")

        let second = viewModel.usageList[1]
        #expect(second.method == "Edible")
        #expect(second.amount == 10.0)
    }

    // MARK: - Test 3: Error Handling Through ViewModel

    @Test("Should handle invalid data through ViewModel")
    func errorHandlingThroughViewModel() async throws {
        // Setup in-memory SwiftData
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)
        let viewModel = UsageLogViewModel(logUsageUseCase: useCase)

        // Set invalid amount (zero)
        viewModel.selectedMethod = "Bowls"
        viewModel.amount = 0 // Invalid!

        // Verify form validation catches it
        #expect(viewModel.canSubmit == false, "Should reject zero amount")

        // Try to log anyway (simulate user bypassing UI validation)
        viewModel.amount = 0
        await viewModel.logUsage()

        // Should not succeed (canSubmit guards against it)
        #expect(viewModel.didSucceed == false)

        // Verify nothing was saved
        let descriptor = FetchDescriptor<UsageModel>()
        let saved = try context.fetch(descriptor)
        #expect(saved.count == 0, "Should not save invalid data")
    }

    // MARK: - Test 4: Old Timestamp Warning Flow

    @Test("Should handle old timestamp warning flow through ViewModel")
    func oldTimestampWarningFlow() async throws {
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)
        let viewModel = UsageLogViewModel(logUsageUseCase: useCase)

        // Set timestamp to 8 days ago (>7 days)
        let eightDaysAgo = Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date()
        viewModel.timestamp = eightDaysAgo
        viewModel.selectedMethod = "Bowls"
        viewModel.amount = 1.0

        // Verify warning check
        #expect(viewModel.isTimestampOld == true)

        // First attempt to log should trigger warning
        await viewModel.logUsage()

        // Should show warning, NOT save
        #expect(viewModel.showTimestampWarning == true)
        #expect(viewModel.didSucceed == false)

        let descriptor = FetchDescriptor<UsageModel>()
        var saved = try context.fetch(descriptor)
        #expect(saved.count == 0, "Should not save before user confirms")

        // Confirm old timestamp
        await viewModel.confirmOldTimestamp()

        // Now should save successfully
        #expect(viewModel.didSucceed == true)
        saved = try context.fetch(descriptor)
        #expect(saved.count == 1, "Should save after user confirms")
    }

    // MARK: - Test 5: Notes Character Limit Integration

    @Test("Should enforce notes character limit through full stack")
    func notesCharacterLimitIntegration() async throws {
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)
        let viewModel = UsageLogViewModel(logUsageUseCase: useCase)

        // Set notes to 501 characters (should truncate to 500)
        let longNotes = String(repeating: "a", count: 501)
        viewModel.selectedMethod = "Bowls"
        viewModel.amount = 1.0
        viewModel.notes = longNotes

        // ViewModel should enforce limit
        #expect(viewModel.notes.count == 500, "ViewModel should truncate to 500")
        #expect(viewModel.shouldShowNotesCounter == true)

        // Log usage
        await viewModel.logUsage()

        // Verify saved data also has limit enforced
        let descriptor = FetchDescriptor<UsageModel>()
        let saved = try context.fetch(descriptor)
        #expect(saved.count == 1)

        let savedUsage = try #require(saved.first)
        #expect(savedUsage.notes?.count == 500, "Saved notes should be truncated to 500")
    }
}
