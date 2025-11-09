import Foundation

/// Protocol for usage data operations (dependency inversion principle)
protocol UsageRepositoryProtocol: Sendable {
    /// Save a usage entity to persistent storage
    func save(_ usage: UsageEntity) async throws

    /// Fetch all usage entries (sorted by timestamp descending)
    func fetchAll() async throws -> [UsageEntity]

    /// Fetch usage entries since a specific date
    func fetch(since date: Date) async throws -> [UsageEntity]

    /// Delete a specific usage entry by ID
    func delete(id: UUID) async throws

    /// Delete all usage entries (PHASE_3: Data Management)
    func deleteAll() async throws
}
