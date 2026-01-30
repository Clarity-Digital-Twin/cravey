/// Use Case: Mark a motivational message as shown
/// Updates timesShown counter and lastShownAt timestamp
protocol MarkMessageShownUseCase: Sendable {
    func execute(_ message: MotivationalMessageEntity) async throws
}

final class DefaultMarkMessageShownUseCase: MarkMessageShownUseCase, Sendable {
    private let repository: MessageRepositoryProtocol
    private let clock: any Clock

    init(repository: MessageRepositoryProtocol, clock: any Clock = SystemClock()) {
        self.repository = repository
        self.clock = clock
    }

    func execute(_ message: MotivationalMessageEntity) async throws {
        let now = clock.now()
        let updatedMessage = message.markAsShown(now: now)
        try await repository.update(updatedMessage)
    }
}
