import Foundation

/// Use Case: Mark a motivational message as shown
/// Updates timesShown counter and lastShownAt timestamp
protocol MarkMessageShownUseCase: Sendable {
    func execute(_ message: MotivationalMessageEntity) async throws
}

final class DefaultMarkMessageShownUseCase: MarkMessageShownUseCase, Sendable {
    private let repository: MessageRepositoryProtocol

    init(repository: MessageRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ message: MotivationalMessageEntity) async throws {
        let updatedMessage = message.markAsShown()
        try await repository.update(updatedMessage)
    }
}
