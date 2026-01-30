import Foundation

@Observable
@MainActor
final class UsageListViewModel: ListViewModel {
    typealias Entity = UsageEntity

    // Dependencies
    @ObservationIgnored
    private let fetchUsageUseCase: FetchUsageUseCase

    @ObservationIgnored
    private let deleteUsageUseCase: DeleteUsageUseCase

    // State
    var usageList: [UsageEntity] = []
    var isLoading: Bool = true
    var errorMessage: String?

    init(fetchUsageUseCase: FetchUsageUseCase, deleteUsageUseCase: DeleteUsageUseCase) {
        self.fetchUsageUseCase = fetchUsageUseCase
        self.deleteUsageUseCase = deleteUsageUseCase
    }

    var items: [UsageEntity] {
        get { usageList }
        set { usageList = newValue }
    }

    /// Fetch all usage entries
    func fetchUsage() async {
        await performFetch {
            try await fetchUsageUseCase.execute()
        }
    }

    func deleteUsage(id: UUID) async {
        await performDelete(id: id) { id in
            try await deleteUsageUseCase.execute(id: id)
        }
    }
}
