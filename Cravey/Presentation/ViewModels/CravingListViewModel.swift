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
    private let deleteCravingUseCase: DeleteCravingUseCase

    init(fetchCravingsUseCase: FetchCravingsUseCase, deleteCravingUseCase: DeleteCravingUseCase) {
        self.fetchCravingsUseCase = fetchCravingsUseCase
        self.deleteCravingUseCase = deleteCravingUseCase
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

    func deleteCraving(id: UUID) async {
        errorMessage = nil

        do {
            try await deleteCravingUseCase.execute(id: id)
            cravings.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
