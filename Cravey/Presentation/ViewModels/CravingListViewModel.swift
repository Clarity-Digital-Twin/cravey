import Foundation

/// ViewModel for craving list display
/// Presentation layer - Clean Architecture
@Observable
@MainActor
final class CravingListViewModel: ListViewModel {
    typealias Entity = CravingEntity

    var cravings: [CravingEntity] = []
    var isLoading: Bool = true
    var errorMessage: String?

    @ObservationIgnored
    private let fetchCravingsUseCase: FetchCravingsUseCase

    @ObservationIgnored
    private let deleteCravingUseCase: DeleteCravingUseCase

    init(fetchCravingsUseCase: FetchCravingsUseCase, deleteCravingUseCase: DeleteCravingUseCase) {
        self.fetchCravingsUseCase = fetchCravingsUseCase
        self.deleteCravingUseCase = deleteCravingUseCase
    }

    var items: [CravingEntity] {
        get { cravings }
        set { cravings = newValue }
    }

    func fetchCravings() async {
        await performFetch {
            try await fetchCravingsUseCase.execute()
        }
    }

    func deleteCraving(id: UUID) async {
        await performDelete(id: id) { id in
            try await deleteCravingUseCase.execute(id: id)
        }
    }
}
