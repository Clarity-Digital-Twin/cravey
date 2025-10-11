import Foundation

/// Use Case: Fetch cravings with optional filtering/sorting
protocol FetchCravingsUseCase: Sendable {
    func execute() async throws -> [CravingEntity]
    func execute(from startDate: Date, to endDate: Date) async throws -> [CravingEntity]
}

final class DefaultFetchCravingsUseCase: FetchCravingsUseCase {
    private let repository: CravingRepositoryProtocol

    init(repository: CravingRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [CravingEntity] {
        let cravings = try await repository.fetchAll()
        // Business rule: Sort by timestamp descending
        return cravings.sorted { $0.timestamp > $1.timestamp }
    }

    func execute(from startDate: Date, to endDate: Date) async throws -> [CravingEntity] {
        let cravings = try await repository.fetch(from: startDate, to: endDate)
        return cravings.sorted { $0.timestamp > $1.timestamp }
    }
}
