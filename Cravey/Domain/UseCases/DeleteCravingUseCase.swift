import Foundation

/// Use Case: Delete a craving by ID
protocol DeleteCravingUseCase: Sendable {
    func execute(id: UUID) async throws
}

final class DefaultDeleteCravingUseCase: DeleteCravingUseCase {
    private let repository: CravingRepositoryProtocol

    init(repository: CravingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
