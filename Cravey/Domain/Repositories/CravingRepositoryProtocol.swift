import Foundation

/// Protocol defining craving data access operations
/// Domain layer - no implementation details
protocol CravingRepositoryProtocol: Sendable {
    /// Save a new craving
    func save(_ craving: CravingEntity) async throws

    /// Fetch all cravings
    func fetchAll() async throws -> [CravingEntity]

    /// Fetch cravings within date range
    func fetch(from startDate: Date, to endDate: Date) async throws -> [CravingEntity]

    /// Delete a craving by ID
    func delete(id: UUID) async throws

    /// Update an existing craving
    func update(_ craving: CravingEntity) async throws

    /// Get craving count
    func count() async throws -> Int
}
