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
}

// MARK: - Mocks

actor MockFetchUsageUseCase: FetchUsageUseCase {
    let returnEmpty: Bool

    init(returnEmpty: Bool = false) {
        self.returnEmpty = returnEmpty
    }

    func execute() async throws -> [UsageEntity] {
        if returnEmpty { return [] }

        return [
            UsageEntity(timestamp: Date(), method: "Bowls", amount: 2.5),
            UsageEntity(timestamp: Date().addingTimeInterval(-3600), method: "Edible", amount: 25.0),
        ]
    }

    func execute(since _: Date) async throws -> [UsageEntity] {
        try await execute()
    }
}

actor MockDeleteUsageUseCase: DeleteUsageUseCase {
    func execute(id _: UUID) async throws {}
}
