@testable import Cravey
import Foundation
import Testing

@Suite("MarkMessageShownUseCase Tests")
struct MarkMessageShownUseCaseTests {
    // MARK: - Test 1: Increments timesShown

    @Test("execute should increment timesShown")
    func incrementsTimesShown() async throws {
        let mockRepo = MarkMessageMockRepository()
        let message = MotivationalMessageEntity(
            content: "Test message",
            category: .urge,
            timesShown: 5
        )
        await mockRepo.addMessage(message)

        let useCase = DefaultMarkMessageShownUseCase(repository: mockRepo)
        try await useCase.execute(message)

        let updated = await mockRepo.getUpdatedMessage(id: message.id)
        #expect(updated?.timesShown == 6)
    }

    // MARK: - Test 2: Sets lastShownAt

    @Test("execute should set lastShownAt to current time")
    func setsLastShownAt() async throws {
        let mockRepo = MarkMessageMockRepository()
        let message = MotivationalMessageEntity(
            content: "Test message",
            category: .anxiety,
            timesShown: 0,
            lastShownAt: nil
        )
        await mockRepo.addMessage(message)

        let beforeExecution = Date()
        let useCase = DefaultMarkMessageShownUseCase(repository: mockRepo)
        try await useCase.execute(message)
        let afterExecution = Date()

        let updated = await mockRepo.getUpdatedMessage(id: message.id)
        #expect(updated?.lastShownAt != nil)
        #expect(updated!.lastShownAt! >= beforeExecution)
        #expect(updated!.lastShownAt! <= afterExecution)
    }

    // MARK: - Test 3: Calls repository update

    @Test("execute should call repository update")
    func callsRepositoryUpdate() async throws {
        let mockRepo = MarkMessageMockRepository()
        let message = MotivationalMessageEntity(
            content: "Test message",
            category: .boredom
        )
        await mockRepo.addMessage(message)

        let useCase = DefaultMarkMessageShownUseCase(repository: mockRepo)
        try await useCase.execute(message)

        let updateCalled = await mockRepo.updateCalled
        #expect(updateCalled == true)
    }
}

// MARK: - Mock Repository (specific to MarkMessageShown tests)

actor MarkMessageMockRepository: MessageRepositoryProtocol {
    private var messages: [UUID: MotivationalMessageEntity] = [:]
    var updateCalled = false

    func addMessage(_ message: MotivationalMessageEntity) {
        messages[message.id] = message
    }

    func getUpdatedMessage(id: UUID) -> MotivationalMessageEntity? {
        messages[id]
    }

    func save(_ message: MotivationalMessageEntity) async throws {
        messages[message.id] = message
    }

    func fetchAll() async throws -> [MotivationalMessageEntity] {
        Array(messages.values)
    }

    func fetchActive() async throws -> [MotivationalMessageEntity] {
        messages.values.filter(\.isActive)
    }

    func fetch(byCategory category: MessageCategory) async throws -> [MotivationalMessageEntity] {
        messages.values.filter { $0.category == category && $0.isActive }
    }

    func delete(id: UUID) async throws {
        messages.removeValue(forKey: id)
    }

    func update(_ message: MotivationalMessageEntity) async throws {
        updateCalled = true
        messages[message.id] = message
    }

    func seedDefaultMessagesIfNeeded() async throws {
        // No-op for tests
    }
}
