import Foundation

/// Use Case: Select a motivational message from the repository
/// Business rule: Prefer messages that have been shown fewer times
protocol SelectMotivationalMessageUseCase: Sendable {
    func execute() async throws -> MotivationalMessageEntity?
}

final class DefaultSelectMotivationalMessageUseCase: SelectMotivationalMessageUseCase, Sendable {
    private let repository: MessageRepositoryProtocol
    private let clock: any Clock

    init(repository: MessageRepositoryProtocol, clock: any Clock = SystemClock()) {
        self.repository = repository
        self.clock = clock
    }

    func execute() async throws -> MotivationalMessageEntity? {
        // Ensure default messages are seeded
        try await repository.seedDefaultMessagesIfNeeded()

        let messages = try await repository.fetchActive()

        guard !messages.isEmpty else { return nil }

        // Business rule: Weight selection toward less-shown messages
        // Find the minimum timesShown value
        let minShown = messages.map(\.timesShown).min() ?? 0

        // Get all messages that have been shown the minimum number of times
        let leastShownMessages = messages.filter { $0.timesShown == minShown }

        // Pick one deterministically based on day of year (consistent within a day)
        // DEBT-038: uses injected clock for testability
        let dayOfYear = clock.calendar.ordinality(of: .day, in: .year, for: clock.now()) ?? 0
        let index = dayOfYear % leastShownMessages.count

        return leastShownMessages[index]
    }
}
