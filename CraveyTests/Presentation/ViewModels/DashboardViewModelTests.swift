@testable import Cravey
import Foundation
import Testing

@Suite("DashboardViewModel Tests")
@MainActor
struct DashboardViewModelTests {
    @Test("Streaks and weekly counts are computed deterministically")
    func streaksAndWeeklyCounts() async {
        let now = Date(timeIntervalSince1970: 1_000_000_000)

        let cravings: [CravingEntity] = [
            CravingEntity(timestamp: now.addingTimeInterval(-2 * 86400), intensity: 6, triggers: ["Bored"]),
            CravingEntity(timestamp: now.addingTimeInterval(-3 * 86400), intensity: 8, triggers: ["Anxious"]),
            CravingEntity(timestamp: now.addingTimeInterval(-20 * 86400), intensity: 4, triggers: ["Habit"]),
        ]

        let usages: [UsageEntity] = [
            UsageEntity(timestamp: now.addingTimeInterval(-10 * 86400), method: "Bowls", amount: 1.0),
            UsageEntity(timestamp: now.addingTimeInterval(-6 * 86400), method: "Vape", amount: 2.0),
            UsageEntity(timestamp: now.addingTimeInterval(-1 * 86400), method: "Edible", amount: 10.0),
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

    func execute(from _: Date, to _: Date) async throws -> [CravingEntity] {
        result
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

    func execute(since _: Date) async throws -> [UsageEntity] {
        result
    }
}
