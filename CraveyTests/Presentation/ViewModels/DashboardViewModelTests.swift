@testable import Cravey
import Foundation
import Testing

@Suite("DashboardViewModel Tests")
@MainActor
struct DashboardViewModelTests {
    @Test("Streaks and weekly counts are computed deterministically")
    func streaksAndWeeklyCounts() async {
        let now = TestConstants.fixedEpoch

        let cravings: [CravingEntity] = [
            CravingEntity(
                timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerDay * 2),
                intensity: 6,
                triggers: ["Bored"]
            ),
            CravingEntity(
                timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerDay * 3),
                intensity: 8,
                triggers: ["Anxious"]
            ),
            CravingEntity(
                timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerDay * 20),
                intensity: 4,
                triggers: ["Habit"]
            ),
        ]

        let usages: [UsageEntity] = [
            UsageEntity(
                timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerDay * 10),
                method: "Bowls",
                amount: 1.0,
                triggers: ["Bored"]
            ),
            UsageEntity(
                timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerDay * 6),
                method: "Vape",
                amount: 2.0,
                triggers: ["Anxious"]
            ),
            UsageEntity(
                timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerDay),
                method: "Edible",
                amount: 10.0,
                triggers: ["Bored"]
            ),
        ]

        let viewModel = DashboardViewModel(
            fetchCravingsUseCase: MockDashboardFetchCravingsUseCase(result: cravings),
            fetchUsageUseCase: MockDashboardFetchUsageUseCase(result: usages),
            nowProvider: { now }
        )

        await viewModel.loadMetrics()

        #expect(viewModel.currentStreak == 1)
        #expect(viewModel.longestStreak == 5)
        #expect(viewModel.weeklyCravingCount == 2)
        #expect(viewModel.weeklyUsageCount == 2)
        #expect(viewModel.averageIntensity7Day == 7.0)
        #expect(viewModel.averageIntensity30Day == 6.0)

        #expect(viewModel.topTriggers.count == 3)
        #expect(viewModel.topTriggers[0].trigger == "Bored")
        #expect(viewModel.topTriggers[0].count == 3)
        #expect(viewModel.topTriggers[1].trigger == "Anxious")
        #expect(viewModel.topTriggers[1].count == 2)
    }

    @Test("Top triggers do not double-count duplicate triggers in a single entry")
    func topTriggersDeduplicateWithinEntry() async {
        let now = TestConstants.fixedEpoch

        let cravings: [CravingEntity] = [
            CravingEntity(
                timestamp: now,
                intensity: 5,
                triggers: ["Bored", "Bored", "Anxious"]
            ),
        ]

        let usages: [UsageEntity] = [
            UsageEntity(
                timestamp: now,
                method: "Bowls",
                amount: 1.0,
                triggers: ["Bored", "Bored"]
            ),
        ]

        let viewModel = DashboardViewModel(
            fetchCravingsUseCase: MockDashboardFetchCravingsUseCase(result: cravings),
            fetchUsageUseCase: MockDashboardFetchUsageUseCase(result: usages),
            nowProvider: { now }
        )

        await viewModel.loadMetrics()

        #expect(viewModel.topTriggers.count >= 2)
        #expect(viewModel.topTriggers[0].trigger == "Bored")
        #expect(viewModel.topTriggers[0].count == 2) // 1 craving + 1 usage, not 4
        #expect(viewModel.topTriggers[1].trigger == "Anxious")
        #expect(viewModel.topTriggers[1].count == 1)
    }
}

// MARK: - Mocks

actor MockDashboardFetchCravingsUseCase: FetchCravingsUseCase {
    let result: [CravingEntity]

    init(result: [CravingEntity]) {
        self.result = result
    }

    func execute() async throws -> [CravingEntity] {
        result
    }

    func execute(from startDate: Date, to endDate: Date) async throws -> [CravingEntity] {
        result.filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
    }
}

actor MockDashboardFetchUsageUseCase: FetchUsageUseCase {
    let result: [UsageEntity]

    init(result: [UsageEntity]) {
        self.result = result
    }

    func execute() async throws -> [UsageEntity] {
        result
    }

    func execute(since date: Date) async throws -> [UsageEntity] {
        result.filter { $0.timestamp >= date }
    }
}
