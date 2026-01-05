import Foundation

/// Dashboard ViewModel - computes metrics from craving and usage data
/// Presentation layer - Clean Architecture
@Observable
@MainActor
final class DashboardViewModel {
    // MARK: - Dependencies

    private let fetchCravingsUseCase: FetchCravingsUseCase
    private let fetchUsageUseCase: FetchUsageUseCase

    // MARK: - Published State

    var isLoading = false
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var averageIntensity7Day: Double = 0.0
    var averageIntensity30Day: Double = 0.0
    var topTriggers: [(trigger: String, count: Int)] = []
    var weeklyCravingCount: Int = 0
    var weeklyUsageCount: Int = 0

    // MARK: - Initialization

    init(fetchCravingsUseCase: FetchCravingsUseCase, fetchUsageUseCase: FetchUsageUseCase) {
        self.fetchCravingsUseCase = fetchCravingsUseCase
        self.fetchUsageUseCase = fetchUsageUseCase
    }

    // MARK: - Data Loading

    func loadMetrics() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let cravings = try await fetchCravingsUseCase.execute()
            let usages = try await fetchUsageUseCase.execute()

            // Calculate current streak (days since last usage)
            currentStreak = calculateCurrentStreak(usages: usages)

            // Calculate longest streak
            longestStreak = calculateLongestStreak(usages: usages)

            // Calculate average intensity (7-day and 30-day)
            let now = Date()
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now

            let cravings7Day = cravings.filter { $0.timestamp >= sevenDaysAgo }
            let cravings30Day = cravings.filter { $0.timestamp >= thirtyDaysAgo }

            averageIntensity7Day = calculateAverageIntensity(cravings: cravings7Day)
            averageIntensity30Day = calculateAverageIntensity(cravings: cravings30Day)

            // Calculate top triggers
            topTriggers = calculateTopTriggers(cravings: cravings, limit: 3)

            // Weekly counts
            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
            weeklyCravingCount = cravings.count { $0.timestamp >= oneWeekAgo }
            weeklyUsageCount = usages.count { $0.timestamp >= oneWeekAgo }
        } catch {
            print("[DashboardViewModel] Failed to load metrics: \(error)")
        }
    }

    // MARK: - Private Calculations

    private func calculateCurrentStreak(usages: [UsageEntity]) -> Int {
        guard let lastUsage = usages.sorted(by: { $0.timestamp > $1.timestamp }).first else {
            // No usage logged = infinite streak from app install
            return Calendar.current.dateComponents([.day], from: Date(), to: Date()).day ?? 0
        }

        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: lastUsage.timestamp, to: Date()).day ?? 0
        return max(0, days)
    }

    private func calculateLongestStreak(usages: [UsageEntity]) -> Int {
        let sortedUsages = usages.sorted { $0.timestamp < $1.timestamp }

        guard !sortedUsages.isEmpty else {
            return currentStreak // If no usage, current streak is the longest
        }

        var longestDays = 0
        let calendar = Calendar.current

        // Check gap from app start (first log) to first usage
        // For simplicity, use gap between consecutive usages

        for idx in 0 ..< sortedUsages.count - 1 {
            let current = sortedUsages[idx].timestamp
            let next = sortedUsages[idx + 1].timestamp
            let gap = calendar.dateComponents([.day], from: current, to: next).day ?? 0
            longestDays = max(longestDays, gap)
        }

        // Also check current streak (from last usage to now)
        longestDays = max(longestDays, currentStreak)

        return longestDays
    }

    private func calculateAverageIntensity(cravings: [CravingEntity]) -> Double {
        guard !cravings.isEmpty else { return 0.0 }
        let total = cravings.reduce(0) { $0 + $1.intensity }
        return Double(total) / Double(cravings.count)
    }

    private func calculateTopTriggers(cravings: [CravingEntity], limit: Int) -> [(trigger: String, count: Int)] {
        var triggerCounts: [String: Int] = [:]

        for craving in cravings {
            for trigger in craving.triggers {
                triggerCounts[trigger, default: 0] += 1
            }
        }

        return triggerCounts
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { (trigger: $0.key, count: $0.value) }
    }
}
