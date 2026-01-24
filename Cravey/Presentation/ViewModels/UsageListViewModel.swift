import Foundation

@Observable
@MainActor
final class UsageListViewModel {
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

    /// Fetch all usage entries
    func fetchUsage() async {
        isLoading = true
        errorMessage = nil

        do {
            usageList = try await fetchUsageUseCase.execute()
        } catch {
            errorMessage = "Failed to load usage history"
        }

        isLoading = false
    }

    func deleteUsage(id: UUID) async {
        errorMessage = nil

        do {
            try await deleteUsageUseCase.execute(id: id)
            usageList.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
