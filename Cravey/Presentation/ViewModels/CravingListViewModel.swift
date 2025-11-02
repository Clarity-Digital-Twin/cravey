import Foundation

/// ViewModel for craving list display
/// Presentation layer - Clean Architecture
@Observable
@MainActor
final class CravingListViewModel {
    var cravings: [CravingEntity] = []
    var isLoading = false
    var errorMessage: String?

    private let fetchCravingsUseCase: FetchCravingsUseCase

    init(fetchCravingsUseCase: FetchCravingsUseCase) {
        self.fetchCravingsUseCase = fetchCravingsUseCase
    }

    func fetchCravings() async {
        isLoading = true
        errorMessage = nil

        do {
            cravings = try await fetchCravingsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
