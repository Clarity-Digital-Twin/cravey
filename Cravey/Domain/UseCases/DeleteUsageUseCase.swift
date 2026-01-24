import Foundation

/// Use Case: Delete a usage log by ID
protocol DeleteUsageUseCase: Sendable {
    func execute(id: UUID) async throws
}

final class DefaultDeleteUsageUseCase: DeleteUsageUseCase {
    private let repository: UsageRepositoryProtocol

    init(repository: UsageRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
