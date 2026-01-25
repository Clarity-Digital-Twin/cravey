import Foundation
import OSLog

/// Dashboard ViewModel - computes metrics from craving and usage data
/// Presentation layer - Clean Architecture
@Observable
@MainActor
final class DashboardViewModel {
    private static let logger = Logger(subsystem: "com.cravey", category: "DashboardViewModel")

    // MARK: - Dependencies (non-tracked)

    @ObservationIgnored
    private let fetchCravingsUseCase: FetchCravingsUseCase
    @ObservationIgnored
    private let fetchUsageUseCase: FetchUsageUseCase
    @ObservationIgnored
    private let nowProvider: @Sendable () -> Date

    // MARK: - Published State

    var isLoading = true
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var averageIntensity7Day: Double = 0.0
    var averageIntensity30Day: Double = 0.0
    var topTriggers: [(trigger: String, count: Int)] = []
    var weeklyCravingCount: Int = 0
    var weeklyUsageCount: Int = 0
    var errorMessage: String?

    // MARK: - Initialization

    init(
        fetchCravingsUseCase: FetchCravingsUseCase,
        fetchUsageUseCase: FetchUsageUseCase,
        nowProvider: @escaping @Sendable () -> Date = Date.init
    ) {
        self.fetchCravingsUseCase = fetchCravingsUseCase
        self.fetchUsageUseCase = fetchUsageUseCase
        self.nowProvider = nowProvider
    }

    // MARK: - Data Loading

    func loadMetrics() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // Fetch cravings and usages concurrently for better performance
            async let cravingsTask = fetchCravingsUseCase.execute()
            async let usagesTask = fetchUsageUseCase.execute()
            let (cravings, usages) = try await (cravingsTask, usagesTask)

            let now = nowProvider()

            // Streaks (days since last usage; longest gap between usages)
            (currentStreak, longestStreak) = calculateStreaks(usages: usages, now: now)

            // Calculate average intensity (7-day and 30-day)
            let calendar = Calendar.current
            guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now),
                  let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)
            else {
                Self.logger.fault("Calendar date math unexpectedly failed while loading dashboard metrics.")
                errorMessage = "Unable to load dashboard metrics"
                return
            }

            let cravings7Day = cravings.filter { $0.timestamp >= sevenDaysAgo }
            let cravings30Day = cravings.filter { $0.timestamp >= thirtyDaysAgo }

            averageIntensity7Day = calculateAverageIntensity(cravings: cravings7Day)
            averageIntensity30Day = calculateAverageIntensity(cravings: cravings30Day)

            // Calculate top triggers (combined cravings + usage)
            topTriggers = calculateTopTriggers(cravings: cravings, usages: usages, limit: 3)

            // Weekly counts
            weeklyCravingCount = cravings.count { $0.timestamp >= sevenDaysAgo }
            weeklyUsageCount = usages.count { $0.timestamp >= sevenDaysAgo }
        } catch {
            errorMessage = "Unable to load dashboard metrics"
            Self.logger.error("Failed to load dashboard metrics: \(error.localizedDescription)")
        }
    }

    // MARK: - Private Calculations

    private func calculateStreaks(usages: [UsageEntity], now: Date = Date()) -> (current: Int, longest: Int) {
        guard !usages.isEmpty else { return (0, 0) }

        let sortedUsages = usages.sorted { $0.timestamp < $1.timestamp }
        let calendar = Calendar.current
        let lastUsage = sortedUsages[sortedUsages.count - 1]
        let currentDays = max(0, calendar.dateComponents([.day], from: lastUsage.timestamp, to: now).day ?? 0)

        var longestDays = currentDays

        for idx in 0 ..< sortedUsages.count - 1 {
            let current = sortedUsages[idx].timestamp
            let next = sortedUsages[idx + 1].timestamp
            let gap = calendar.dateComponents([.day], from: current, to: next).day ?? 0
            longestDays = max(longestDays, gap)
        }

        return (currentDays, longestDays)
    }

    private func calculateAverageIntensity(cravings: [CravingEntity]) -> Double {
        guard !cravings.isEmpty else { return 0.0 }
        let total = cravings.reduce(0) { $0 + $1.intensity }
        return Double(total) / Double(cravings.count)
    }

    private func calculateTopTriggers(
        cravings: [CravingEntity],
        usages: [UsageEntity],
        limit: Int
    ) -> [(trigger: String, count: Int)] {
        var triggerCounts: [String: Int] = [:]

        for craving in cravings {
            for trigger in craving.triggers {
                triggerCounts[trigger, default: 0] += 1
            }
        }

        for usage in usages {
            for trigger in usage.triggers {
                triggerCounts[trigger, default: 0] += 1
            }
        }

        return triggerCounts
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { (trigger: $0.key, count: $0.value) }
    }
}
