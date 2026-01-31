import Foundation

/// Protocol defining motivational message data access operations
/// Domain layer - no implementation details
protocol MessageRepositoryProtocol: Sendable {
    /// Save a new message
    func save(_ message: MotivationalMessageEntity) async throws

    /// Fetch all messages (active + inactive)
    func fetchAll() async throws -> [MotivationalMessageEntity]

    /// Fetch all active messages
    func fetchActive() async throws -> [MotivationalMessageEntity]

    /// Fetch messages by category
    func fetch(byCategory category: MessageCategory) async throws -> [MotivationalMessageEntity]

    /// Delete a message by ID
    func delete(id: UUID) async throws

    /// Update an existing message
    func update(_ message: MotivationalMessageEntity) async throws

    // NOTE: Seeding is handled at app startup (App layer), not in Domain.
    // See DEBT-045 resolution.
}
