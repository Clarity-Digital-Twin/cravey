import Foundation

/// ViewModel for craving list display
/// Presentation layer - Clean Architecture
@Observable
@MainActor
final class CravingListViewModel {
    var cravings: [CravingEntity] = []
    var isLoading = true
    var errorMessage: String?

    @ObservationIgnored
    private let fetchCravingsUseCase: FetchCravingsUseCase

    @ObservationIgnored
    private let deleteCravingUseCase: DeleteCravingUseCase

    init(fetchCravingsUseCase: FetchCravingsUseCase, deleteCravingUseCase: DeleteCravingUseCase) {
        self.fetchCravingsUseCase = fetchCravingsUseCase
        self.deleteCravingUseCase = deleteCravingUseCase
    }

    func fetchCravings() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            cravings = try await fetchCravingsUseCase.execute()
        } catch is CancellationError {
            // Cancellation is flow control, not an error to surface
            return
        } catch {
            errorMessage = error.localizedDescription
        }
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
