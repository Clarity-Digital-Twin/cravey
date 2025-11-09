import Foundation

/// Protocol for fetching usage history
protocol FetchUsageUseCase: Sendable {
    /// Fetch all usage entries (sorted by timestamp descending)
    func execute() async throws -> [UsageEntity]

    /// Fetch usage entries since a specific date
    func execute(since date: Date) async throws -> [UsageEntity]
}

/// Default implementation
final class DefaultFetchUsageUseCase: FetchUsageUseCase {
    private let repository: UsageRepositoryProtocol

    init(repository: UsageRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [UsageEntity] {
        try await repository.fetchAll()
    }

    func execute(since date: Date) async throws -> [UsageEntity] {
        try await repository.fetch(since: date)
    }
}
