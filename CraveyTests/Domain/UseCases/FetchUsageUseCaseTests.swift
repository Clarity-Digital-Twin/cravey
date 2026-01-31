@testable import Cravey
import Foundation
import Testing

@Suite("FetchUsageUseCase Tests")
struct FetchUsageUseCaseTests {
    @Test("execute returns all usages")
    func fetchAllUsages() async throws {
        let mockRepo = FetchUsageMockRepository()
        let now = TestConstants.fixedEpoch

        let usage1 = UsageEntity(
            timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerHour),
            method: "Bowls",
            amount: 1.0
        )
        let usage2 = UsageEntity(timestamp: now, method: "Vape", amount: 3.0)
        await mockRepo.addUsage(usage1)
        await mockRepo.addUsage(usage2)

        let useCase = DefaultFetchUsageUseCase(repository: mockRepo)
        let result = try await useCase.execute()

        #expect(result.count == 2)
    }

    @Test("execute with since date filters correctly")
    func fetchSinceDateFilters() async throws {
        let mockRepo = FetchUsageMockRepository()
        let now = TestConstants.fixedEpoch

        let recent = UsageEntity(timestamp: now, method: "Bowls", amount: 1.0)
        let old = UsageEntity(
            timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerDay * 10),
            method: "Vape",
            amount: 3.0
        )
        await mockRepo.addUsage(recent)
        await mockRepo.addUsage(old)

        let useCase = DefaultFetchUsageUseCase(repository: mockRepo)
        let sinceDate = now.addingTimeInterval(-TestConstants.Time.secondsPerDay) // 1 day ago
        let result = try await useCase.execute(since: sinceDate)

        #expect(result.count == 1)
        #expect(result[0].id == recent.id)
    }

    @Test("execute returns empty array when no usages")
    func fetchReturnsEmptyWhenNone() async throws {
        let mockRepo = FetchUsageMockRepository()
        let useCase = DefaultFetchUsageUseCase(repository: mockRepo)

        let result = try await useCase.execute()

        #expect(result.isEmpty)
    }

    @Test("execute with since date returns empty when no matches")
    func fetchSinceDateReturnsEmptyWhenNoMatches() async throws {
        let mockRepo = FetchUsageMockRepository()
        let now = TestConstants.fixedEpoch

        let old = UsageEntity(
            timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerDay * 30),
            method: "Edible",
            amount: 10.0
        )
        await mockRepo.addUsage(old)

        let useCase = DefaultFetchUsageUseCase(repository: mockRepo)
        let sinceDate = now.addingTimeInterval(-TestConstants.Time.secondsPerDay) // 1 day ago
        let result = try await useCase.execute(since: sinceDate)

        #expect(result.isEmpty)
    }
}

// MARK: - Mock Repository

actor FetchUsageMockRepository: UsageRepositoryProtocol {
    private var usages: [UsageEntity] = []

    func addUsage(_ usage: UsageEntity) {
        usages.append(usage)
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
        usages.removeAll { $0.id == id }
    }

    func deleteAll() async throws {
        usages.removeAll()
    }
}
