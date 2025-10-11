import Foundation

/// Protocol defining motivational message data access operations
/// Domain layer - no implementation details
protocol MessageRepositoryProtocol: Sendable {
    /// Save a new message
    func save(_ message: MotivationalMessageEntity) async throws

    /// Fetch all active messages
    func fetchActive() async throws -> [MotivationalMessageEntity]

    /// Fetch messages by category
    func fetch(byCategory category: MessageCategory) async throws -> [MotivationalMessageEntity]

    /// Delete a message by ID
    func delete(id: UUID) async throws

    /// Update an existing message
    func update(_ message: MotivationalMessageEntity) async throws

    /// Seed default messages if none exist
    func seedDefaultMessagesIfNeeded() async throws
}
