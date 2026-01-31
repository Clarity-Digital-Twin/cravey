@testable import Cravey
import Foundation
import Testing

@Suite("SelectMotivationalMessageUseCase Tests")
struct SelectMotivationalMessageUseCaseTests {
    // MARK: - Test 1: Returns a message when repository has active messages

    @Test("execute should return a message when active messages exist")
    func returnsMessage() async throws {
        let mockRepo = MockMessageRepository()
        let message = MotivationalMessageEntity(
            content: "Test message",
            category: .urge,
            isActive: true,
            timesShown: 0
        )
        await mockRepo.addMessage(message)

        let useCase = DefaultSelectMotivationalMessageUseCase(repository: mockRepo)
        let result = try await useCase.execute()

        #expect(result != nil)
        #expect(result?.content == "Test message")
    }

    // MARK: - Test 2: Returns nil when no active messages

    @Test("execute should return nil when no active messages exist")
    func returnsNilWhenEmpty() async throws {
        let mockRepo = MockMessageRepository()
        // No messages added

        let useCase = DefaultSelectMotivationalMessageUseCase(repository: mockRepo)
        let result = try await useCase.execute()

        #expect(result == nil)
    }

    // NOTE: Test for seeding removed (DEBT-045).
    // Seeding is now handled at app startup, not by the use case.

    // MARK: - Test 3: Prefers less-shown messages

    @Test("execute should prefer messages that have been shown fewer times")
    func prefersLessShownMessages() async throws {
        let mockRepo = MockMessageRepository()

        // Add a message shown 10 times
        let shownMany = MotivationalMessageEntity(
            content: "Shown many times",
            category: .urge,
            isActive: true,
            timesShown: 10
        )
        await mockRepo.addMessage(shownMany)

        // Add a message shown 0 times
        let shownNone = MotivationalMessageEntity(
            content: "Never shown",
            category: .anxiety,
            isActive: true,
            timesShown: 0
        )
        await mockRepo.addMessage(shownNone)

        let useCase = DefaultSelectMotivationalMessageUseCase(repository: mockRepo)
        let result = try await useCase.execute()

        // Should pick the one with fewer views
        #expect(result?.content == "Never shown")
    }
}

// MARK: - Mock Repository

actor MockMessageRepository: MessageRepositoryProtocol {
    private var messages: [MotivationalMessageEntity] = []

    func addMessage(_ message: MotivationalMessageEntity) {
        messages.append(message)
    }

    func save(_ message: MotivationalMessageEntity) async throws {
        messages.append(message)
    }

    func fetchAll() async throws -> [MotivationalMessageEntity] {
        messages
    }

    func fetchActive() async throws -> [MotivationalMessageEntity] {
        messages.filter(\.isActive)
    }

    func fetch(byCategory category: MessageCategory) async throws -> [MotivationalMessageEntity] {
        messages.filter { $0.category == category && $0.isActive }
    }

    func delete(id: UUID) async throws {
        messages.removeAll { $0.id == id }
    }

    func update(_ message: MotivationalMessageEntity) async throws {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index] = message
        }
    }

    // NOTE: seedDefaultMessagesIfNeeded() removed from protocol (DEBT-045).
    // Seeding is now handled at app startup.
}
