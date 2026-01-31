@testable import Cravey
import Foundation
import Testing

@Suite("UsageListViewModel Tests (Phase 2C)")
@MainActor
struct UsageListViewModelTests {
    // MARK: - Test 1: Fetch Success

    @Test("fetchUsage should populate usageList")
    func fetchSuccess() async {
        let mockUseCase = MockFetchUsageUseCase()
        let viewModel = UsageListViewModel(
            fetchUsageUseCase: mockUseCase,
            deleteUsageUseCase: MockDeleteUsageUseCase()
        )

        await viewModel.fetchUsage()

        #expect(viewModel.usageList.count == 2)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Test 2: Empty State

    @Test("fetchUsage should handle empty list")
    func emptyState() async {
        let mockUseCase = MockFetchUsageUseCase(returnEmpty: true)
        let viewModel = UsageListViewModel(
            fetchUsageUseCase: mockUseCase,
            deleteUsageUseCase: MockDeleteUsageUseCase()
        )

        await viewModel.fetchUsage()

        #expect(viewModel.usageList.isEmpty)
    }

    // MARK: - Test 3: Delete

    @Test("deleteUsage should remove item and call use case")
    func deleteUsageRemovesItem() async throws {
        let fetchUseCase = MockFetchUsageUseCase()
        let deleteUseCase = MockDeleteUsageUseCase()
        let viewModel = UsageListViewModel(
            fetchUsageUseCase: fetchUseCase,
            deleteUsageUseCase: deleteUseCase
        )

        await viewModel.fetchUsage()
        let idToDelete = try #require(viewModel.usageList.first?.id)

        await viewModel.deleteUsage(id: idToDelete)

        #expect(viewModel.usageList.contains { $0.id == idToDelete } == false)
        #expect(await deleteUseCase.executeCallCount == 1)
        #expect(await deleteUseCase.lastDeletedID == idToDelete)
    }

    // MARK: - Test 4: Fetch Failure

    @Test("fetchUsage should preserve error context on failure")
    func fetchFailureShowsLocalizedError() async {
        let mockUseCase = MockFetchUsageUseCase(shouldThrow: true)
        let viewModel = UsageListViewModel(
            fetchUsageUseCase: mockUseCase,
            deleteUsageUseCase: MockDeleteUsageUseCase()
        )

        await viewModel.fetchUsage()

        #expect(viewModel.errorMessage == MockFetchUsageError.fetchFailed.localizedDescription)
    }
}

// MARK: - Mocks

actor MockFetchUsageUseCase: FetchUsageUseCase {
    let returnEmpty: Bool
    let shouldThrow: Bool

    init(returnEmpty: Bool = false, shouldThrow: Bool = false) {
        self.returnEmpty = returnEmpty
        self.shouldThrow = shouldThrow
    }

    func execute() async throws -> [UsageEntity] {
        if shouldThrow { throw MockFetchUsageError.fetchFailed }
        if returnEmpty { return [] }

        let now = TestConstants.fixedEpoch
        return [
            UsageEntity(timestamp: now, method: "Bowls", amount: 2.5),
            UsageEntity(
                timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerHour),
                method: "Edible",
                amount: 25.0
            ),
        ]
    }

    func execute(since _: Date) async throws -> [UsageEntity] {
        try await execute()
    }
}

enum MockFetchUsageError: LocalizedError {
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            "Mock fetch failed"
        }
    }
}

actor MockDeleteUsageUseCase: DeleteUsageUseCase {
    var executeCallCount = 0
    var lastDeletedID: UUID?

    func execute(id: UUID) async throws {
        executeCallCount += 1
        lastDeletedID = id
    }
}
