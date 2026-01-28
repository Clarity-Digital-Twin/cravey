@testable import Cravey
import Foundation
import Testing

@Suite("CravingListViewModel Tests")
@MainActor
struct CravingListViewModelTests {
    // MARK: - Test 1: Fetch Success

    @Test("fetchCravings should populate cravings list")
    func fetchSuccess() async {
        let mockFetchUseCase = MockFetchCravingsUseCase()
        let viewModel = CravingListViewModel(
            fetchCravingsUseCase: mockFetchUseCase,
            deleteCravingUseCase: MockDeleteCravingUseCase()
        )

        await viewModel.fetchCravings()

        #expect(viewModel.cravings.count == 2)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    // MARK: - Test 2: Empty State

    @Test("fetchCravings should handle empty list")
    func emptyState() async {
        let mockFetchUseCase = MockFetchCravingsUseCase(returnEmpty: true)
        let viewModel = CravingListViewModel(
            fetchCravingsUseCase: mockFetchUseCase,
            deleteCravingUseCase: MockDeleteCravingUseCase()
        )

        await viewModel.fetchCravings()

        #expect(viewModel.cravings.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Test 3: Delete

    @Test("deleteCraving should remove item and call use case")
    func deleteCravingRemovesItem() async throws {
        let fetchUseCase = MockFetchCravingsUseCase()
        let deleteUseCase = MockDeleteCravingUseCase()
        let viewModel = CravingListViewModel(
            fetchCravingsUseCase: fetchUseCase,
            deleteCravingUseCase: deleteUseCase
        )

        await viewModel.fetchCravings()
        let idToDelete = try #require(viewModel.cravings.first?.id)

        await viewModel.deleteCraving(id: idToDelete)

        #expect(viewModel.cravings.contains { $0.id == idToDelete } == false)
        #expect(await deleteUseCase.executeCallCount == 1)
        #expect(await deleteUseCase.lastDeletedID == idToDelete)
    }

    // MARK: - Test 4: Fetch Failure

    @Test("fetchCravings should preserve error context on failure")
    func fetchFailureShowsLocalizedError() async {
        let mockFetchUseCase = MockFetchCravingsUseCase(shouldThrow: true)
        let viewModel = CravingListViewModel(
            fetchCravingsUseCase: mockFetchUseCase,
            deleteCravingUseCase: MockDeleteCravingUseCase()
        )

        await viewModel.fetchCravings()

        #expect(viewModel.errorMessage == MockFetchCravingsError.fetchFailed.localizedDescription)
        #expect(viewModel.isLoading == false)
    }

    // MARK: - Test 5: Delete Failure

    @Test("deleteCraving should show error on failure")
    func deleteFailureShowsError() async throws {
        let fetchUseCase = MockFetchCravingsUseCase()
        let deleteUseCase = MockDeleteCravingUseCase(shouldThrow: true)
        let viewModel = CravingListViewModel(
            fetchCravingsUseCase: fetchUseCase,
            deleteCravingUseCase: deleteUseCase
        )

        await viewModel.fetchCravings()
        let originalCount = viewModel.cravings.count
        let idToDelete = try #require(viewModel.cravings.first?.id)

        await viewModel.deleteCraving(id: idToDelete)

        // Item should NOT be removed on failure
        #expect(viewModel.cravings.count == originalCount)
        #expect(viewModel.errorMessage == MockDeleteCravingError.deleteFailed.localizedDescription)
    }
}

// MARK: - Mocks

actor MockFetchCravingsUseCase: FetchCravingsUseCase {
    let returnEmpty: Bool
    let shouldThrow: Bool

    init(returnEmpty: Bool = false, shouldThrow: Bool = false) {
        self.returnEmpty = returnEmpty
        self.shouldThrow = shouldThrow
    }

    func execute() async throws -> [CravingEntity] {
        if shouldThrow { throw MockFetchCravingsError.fetchFailed }
        if returnEmpty { return [] }

        return [
            CravingEntity(timestamp: Date(), intensity: 7, triggers: ["Anxious"]),
            CravingEntity(timestamp: Date().addingTimeInterval(-3600), intensity: 4, triggers: ["Bored"]),
        ]
    }

    func execute(from _: Date, to _: Date) async throws -> [CravingEntity] {
        try await execute()
    }
}

enum MockFetchCravingsError: LocalizedError {
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            "Mock fetch failed"
        }
    }
}

actor MockDeleteCravingUseCase: DeleteCravingUseCase {
    var executeCallCount = 0
    var lastDeletedID: UUID?
    let shouldThrow: Bool

    init(shouldThrow: Bool = false) {
        self.shouldThrow = shouldThrow
    }

    func execute(id: UUID) async throws {
        if shouldThrow { throw MockDeleteCravingError.deleteFailed }
        executeCallCount += 1
        lastDeletedID = id
    }
}

enum MockDeleteCravingError: LocalizedError {
    case deleteFailed

    var errorDescription: String? {
        switch self {
        case .deleteFailed:
            "Mock delete failed"
        }
    }
}
