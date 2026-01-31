@testable import Cravey
import Foundation
import Testing

@Suite("DeleteCravingUseCase Tests")
struct DeleteCravingUseCaseTests {
    @Test("execute deletes existing craving")
    func deleteExistingCraving() async throws {
        let mockRepo = DeleteCravingMockRepository()
        let craving = CravingEntity(timestamp: Date(), intensity: 5)
        await mockRepo.addCraving(craving)

        let useCase = DefaultDeleteCravingUseCase(repository: mockRepo)
        try await useCase.execute(id: craving.id)

        let remaining = await mockRepo.getCravings()
        #expect(remaining.isEmpty)
    }

    @Test("execute calls repository delete with correct ID")
    func deleteCallsRepositoryWithCorrectId() async throws {
        let mockRepo = DeleteCravingMockRepository()
        let craving = CravingEntity(timestamp: Date(), intensity: 5)
        await mockRepo.addCraving(craving)

        let useCase = DefaultDeleteCravingUseCase(repository: mockRepo)
        try await useCase.execute(id: craving.id)

        let lastDeletedId = await mockRepo.lastDeletedId
        #expect(lastDeletedId == craving.id)
    }

    @Test("execute propagates repository errors")
    func deletePropagatesErrors() async {
        let mockRepo = DeleteCravingMockRepository(shouldThrow: true)

        let useCase = DefaultDeleteCravingUseCase(repository: mockRepo)

        await #expect(throws: (any Error).self) {
            try await useCase.execute(id: UUID())
        }
    }
}

// MARK: - Mock Repository

actor DeleteCravingMockRepository: CravingRepositoryProtocol {
    private var cravings: [CravingEntity] = []
    private(set) var lastDeletedId: UUID?
    private let shouldThrow: Bool

    init(shouldThrow: Bool = false) {
        self.shouldThrow = shouldThrow
    }

    func addCraving(_ craving: CravingEntity) {
        cravings.append(craving)
    }

    func getCravings() -> [CravingEntity] {
        cravings
    }

    func save(_ craving: CravingEntity) async throws {
        cravings.append(craving)
    }

    func fetchAll() async throws -> [CravingEntity] {
        cravings
    }

    func fetch(from startDate: Date, to endDate: Date) async throws -> [CravingEntity] {
        cravings.filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
    }

    func delete(id: UUID) async throws {
        if shouldThrow {
            throw MockDeleteError.deleteFailed
        }
        lastDeletedId = id
        cravings.removeAll { $0.id == id }
    }

    func update(_: CravingEntity) async throws {}

    func count() async throws -> Int {
        cravings.count
    }
}

enum MockDeleteError: Error {
    case deleteFailed
}
