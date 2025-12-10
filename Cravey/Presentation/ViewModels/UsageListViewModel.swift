import Foundation

@Observable
@MainActor
final class UsageListViewModel {
    // Dependencies
    private let fetchUsageUseCase: FetchUsageUseCase

    // State
    var usageList: [UsageEntity] = []
    var isLoading: Bool = false
    var errorMessage: String?

    init(fetchUsageUseCase: FetchUsageUseCase) {
        self.fetchUsageUseCase = fetchUsageUseCase
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
}
