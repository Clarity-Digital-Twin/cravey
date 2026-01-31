@testable import Cravey
import Foundation
import Testing

@Suite("FetchCravingsUseCase Tests")
struct FetchCravingsUseCaseTests {
    @Test("execute returns all cravings sorted by timestamp descending")
    func fetchAllSortedDescending() async throws {
        let mockRepo = FetchCravingsMockRepository()
        let now = TestConstants.fixedEpoch

        let older = CravingEntity(timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerHour), intensity: 3)
        let newer = CravingEntity(timestamp: now, intensity: 7)
        await mockRepo.addCraving(older)
        await mockRepo.addCraving(newer)

        let useCase = DefaultFetchCravingsUseCase(repository: mockRepo)
        let result = try await useCase.execute()

        #expect(result.count == 2)
        #expect(result[0].id == newer.id, "Newest should be first")
        #expect(result[1].id == older.id, "Oldest should be last")
    }

    @Test("execute with date range filters correctly")
    func fetchByDateRangeFilters() async throws {
        let mockRepo = FetchCravingsMockRepository()
        let now = TestConstants.fixedEpoch

        let inRange = CravingEntity(timestamp: now, intensity: 5)
        let outOfRange = CravingEntity(
            timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerDay * 10),
            intensity: 3
        ) // 10 days ago
        await mockRepo.addCraving(inRange)
        await mockRepo.addCraving(outOfRange)

        let useCase = DefaultFetchCravingsUseCase(repository: mockRepo)
        let startDate = now.addingTimeInterval(-TestConstants.Time.secondsPerDay) // 1 day ago
        let endDate = now.addingTimeInterval(TestConstants.Time.secondsPerDay) // 1 day from now
        let result = try await useCase.execute(from: startDate, to: endDate)

        #expect(result.count == 1)
        #expect(result[0].id == inRange.id)
    }

    @Test("execute returns empty array when no cravings")
    func fetchReturnsEmptyWhenNone() async throws {
        let mockRepo = FetchCravingsMockRepository()
        let useCase = DefaultFetchCravingsUseCase(repository: mockRepo)

        let result = try await useCase.execute()

        #expect(result.isEmpty)
    }

    @Test("execute with date range returns empty when no matches")
    func fetchByDateRangeReturnsEmptyWhenNoMatches() async throws {
        let mockRepo = FetchCravingsMockRepository()
        let now = TestConstants.fixedEpoch

        let outOfRange = CravingEntity(
            timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerDay * 30),
            intensity: 5
        ) // 30 days ago
        await mockRepo.addCraving(outOfRange)

        let useCase = DefaultFetchCravingsUseCase(repository: mockRepo)
        let startDate = now.addingTimeInterval(-TestConstants.Time.secondsPerDay) // 1 day ago
        let endDate = now
        let result = try await useCase.execute(from: startDate, to: endDate)

        #expect(result.isEmpty)
    }
}

// MARK: - Mock Repository

actor FetchCravingsMockRepository: CravingRepositoryProtocol {
    private var cravings: [CravingEntity] = []

    func addCraving(_ craving: CravingEntity) {
        cravings.append(craving)
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
        cravings.removeAll { $0.id == id }
    }

    func update(_ craving: CravingEntity) async throws {
        if let index = cravings.firstIndex(where: { $0.id == craving.id }) {
            cravings[index] = craving
        }
    }

    func count() async throws -> Int {
        cravings.count
    }
}
