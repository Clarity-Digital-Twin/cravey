import Foundation

/// Protocol for fetching usage history
protocol FetchUsageUseCase: Sendable {
    /// Fetch all usage entries (sorted by timestamp descending)
    func execute() async throws -> [UsageEntity]

    /// Fetch usage entries since a specific date
    func execute(since date: Date) async throws -> [UsageEntity]
}

/// Default implementation
final class DefaultFetchUsageUseCase: FetchUsageUseCase, Sendable {
    private let repository: UsageRepositoryProtocol

    init(repository: UsageRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [UsageEntity] {
        let usages = try await repository.fetchAll()
        // Business rule: Sort by timestamp descending (matches cravings)
        return usages.sorted { $0.timestamp > $1.timestamp }
    }

    func execute(since date: Date) async throws -> [UsageEntity] {
        let usages = try await repository.fetch(since: date)
        // Business rule: Sort by timestamp descending
        return usages.sorted { $0.timestamp > $1.timestamp }
    }
}
