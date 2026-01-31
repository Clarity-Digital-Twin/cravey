@testable import Cravey
import Foundation
import Testing

@Suite("DeleteUsageUseCase Tests")
struct DeleteUsageUseCaseTests {
    @Test("execute deletes existing usage")
    func deleteExistingUsage() async throws {
        let mockRepo = DeleteUsageMockRepository()
        let usage = UsageEntity(timestamp: Date(), method: "Bowls", amount: 1.0)
        await mockRepo.addUsage(usage)

        let useCase = DefaultDeleteUsageUseCase(repository: mockRepo)
        try await useCase.execute(id: usage.id)

        let remaining = await mockRepo.getUsages()
        #expect(remaining.isEmpty)
    }

    @Test("execute calls repository delete with correct ID")
    func deleteCallsRepositoryWithCorrectId() async throws {
        let mockRepo = DeleteUsageMockRepository()
        let usage = UsageEntity(timestamp: Date(), method: "Vape", amount: 5.0)
        await mockRepo.addUsage(usage)

        let useCase = DefaultDeleteUsageUseCase(repository: mockRepo)
        try await useCase.execute(id: usage.id)

        let lastDeletedId = await mockRepo.lastDeletedId
        #expect(lastDeletedId == usage.id)
    }

    @Test("execute propagates repository errors")
    func deletePropagatesErrors() async {
        let mockRepo = DeleteUsageMockRepository(shouldThrow: true)

        let useCase = DefaultDeleteUsageUseCase(repository: mockRepo)

        await #expect(throws: (any Error).self) {
            try await useCase.execute(id: UUID())
        }
    }
}

// MARK: - Mock Repository

actor DeleteUsageMockRepository: UsageRepositoryProtocol {
    private var usages: [UsageEntity] = []
    private(set) var lastDeletedId: UUID?
    private let shouldThrow: Bool

    init(shouldThrow: Bool = false) {
        self.shouldThrow = shouldThrow
    }

    func addUsage(_ usage: UsageEntity) {
        usages.append(usage)
    }

    func getUsages() -> [UsageEntity] {
        usages
    }

    func save(_ usage: UsageEntity) async throws {
        usages.append(usage)
    }

    func fetchAll() async throws -> [UsageEntity] {
        usages
    }

    func fetch(since date: Date) async throws -> [UsageEntity] {
        usages.filter { $0.timestamp >= date }
    }

    func delete(id: UUID) async throws {
        if shouldThrow {
            throw MockUsageDeleteError.deleteFailed
        }
        lastDeletedId = id
        usages.removeAll { $0.id == id }
    }

    func deleteAll() async throws {
        usages.removeAll()
    }
}

enum MockUsageDeleteError: Error {
    case deleteFailed
}
