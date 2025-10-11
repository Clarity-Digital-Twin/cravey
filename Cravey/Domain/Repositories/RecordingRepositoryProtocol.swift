import Foundation

/// Protocol defining recording data access operations
/// Domain layer - no implementation details
protocol RecordingRepositoryProtocol: Sendable {
    /// Save a new recording
    func save(_ recording: RecordingEntity) async throws

    /// Fetch all recordings
    func fetchAll() async throws -> [RecordingEntity]

    /// Fetch recordings by purpose
    func fetch(byPurpose purpose: RecordingPurpose) async throws -> [RecordingEntity]

    /// Delete a recording by ID
    func delete(id: UUID) async throws

    /// Update an existing recording (e.g., play count)
    func update(_ recording: RecordingEntity) async throws
}
