# Phase 5: Dashboard & Analytics (Weeks 7-8)

**Version:** 3.0 (Chronologically Ordered + Audit Validated)
**Duration:** 2 weeks
**Dependencies:** Phases 1-2 (craving + usage logging) - **⚠️ PHASE_2 MUST BE COMPLETE** (requires UsageEntity + UsageRepository)
**Status:** 📝 Ready for implementation
**Last Updated:** 2025-11-01

---

## 🎯 Phase Goal

**Shippable Deliverable:** Users can **visualize progress** with 5 MVP metrics (summary, streaks, intensity, triggers) and date range filtering (7/30/90 days). Additional metrics available as computed properties for future UI expansion.

**Feature Implemented:** Feature 4 (Dashboard with Analytics)

**User Value:** Transform raw logs into actionable insights. Users see patterns, celebrate progress, identify high-risk scenarios, and make data-driven decisions about their cannabis use.

---

## 📊 Overview

This phase creates a **read-only analytics dashboard** that aggregates data from Phases 1-2 (cravings + usage logs) to surface meaningful patterns. No data is created or modified—only queried and visualized.

**Core Dependencies:**
- `CravingEntity` from Phase 1 (cravings logged)
- `UsageEntity` from Phase 2 (usage logged)
- `RecordingEntity` from Phase 4 (optional - used for "Recordings Created" count)

**Technical Stack:**
- **Swift Charts** for visualizations (line charts, bar charts, pie charts)
- **FetchDescriptor** for efficient SwiftData queries
- **Computed properties** for metrics (no database writes)
- **Clean Architecture** (Domain → Presentation, same as Phases 1-3)

---

## 📦 Files to Create (8 files total)

### Part 1: Domain Layer (1 file)
- `Domain/Entities/DashboardData.swift` (aggregated dashboard metrics value object)

### Part 2: Domain Layer - Use Case (1 file)
- `Domain/UseCases/FetchDashboardDataUseCase.swift` (fetches + aggregates craving + usage data)

### Part 3: Presentation Layer - ViewModel (1 file)
- `Presentation/ViewModels/DashboardViewModel.swift` (dashboard state + date filtering)

### Part 4: Presentation Layer - Views (3 files)
- `Presentation/Views/Dashboard/DashboardView.swift` (main dashboard container)
- `Presentation/Views/Dashboard/SummaryCardView.swift` (top summary card)
- `Presentation/Views/Dashboard/EmptyDashboardView.swift` (empty state for <2 logs)

### Part 5: Presentation Layer - Components (1 file)
- `Presentation/Views/Components/MetricCardView.swift` (reusable metric card)

---

## 📈 Metrics Overview (5 MVP + 6 Future)

Based on [MVP_PRODUCT_SPEC.md](../../MVP_PRODUCT_SPEC.md#4-progress-metrics-dashboard):

**✅ MVP Metrics (Implemented in DashboardView):**
1. Summary Card (Total cravings + usage)
2. Current Abstinence Streak
3. Longest Abstinence Streak
4. Average Craving Intensity
5. Top Triggers (Top 3)

**🔮 Future Metrics (Computed properties exist in DashboardData, UI deferred):**
6. Craving Intensity Over Time (line chart)
7. Craving Frequency (bar chart)
8. Location Patterns
9. Time of Day Breakdown
10. Usage by ROA
11. Day of Week Patterns

---

### 1. Summary Card (Top Priority) ✅ MVP
- **Data:** Total cravings + Total usage for selected date range
- **UI:** Large card at top, "This week: 12 uses, 3 cravings"
- **Purpose:** At-a-glance overview without scrolling

### 2. Current Streak ✅ MVP
- **UI:** Metric card with large number
- **Data:** Context-aware based on user pattern:
  - "7 days abstinent" (if no usage logs in last 7 days)
  - "Active use period" (if usage logged recently)
- **Purpose:** Non-punitive streak tracking
- **Implementation:** DashboardView lines 868-872 (MetricCardView)

### 3. Longest Abstinence Streak ✅ MVP
- **UI:** Milestone card
- **Data:** Historical best streak (never resets)
- **Example:** "Your best: 14 days"
- **Purpose:** Celebrates achievement without punishment
- **Implementation:** DashboardView lines 874-879 (MetricCardView)

### 4. Average Craving Intensity ✅ MVP
- **UI:** Metric card with subtitle
- **Data:** Average intensity across all cravings (0-10 scale)
- **Example:** "7.5 / 10"
- **Purpose:** Shows overall craving severity trend
- **Implementation:** DashboardView lines 882-889 (MetricCardView)

### 5. Most Common Triggers (Top 3) ✅ MVP
- **UI:** Text list with counts
- **Data:** Top 3 triggers by frequency
- **Example:** "1. Bored (12)\n2. Anxious (8)\n3. Habit (5)"
- **Purpose:** Quick summary of trigger patterns
- **Implementation:** DashboardView lines 893-904 (VStack with Text)

### 6. Craving Intensity Over Time 🔮 FUTURE
- **Chart:** Line chart
- **Data:** Average craving intensity per day/week
- **Y-Axis:** 0-10 scale
- **Purpose:** Shows if cravings getting weaker/stronger over time
- **Status:** Computed property exists, UI deferred to post-MVP

### 7. Craving Frequency 🔮 FUTURE
- **Chart:** Bar chart
- **Data:** Number of cravings per day/week
- **Purpose:** Identifies high-frequency periods
- **Status:** Raw data available (totalCravings), chart UI deferred

### 8. Trigger Breakdown (Complete) 🔮 FUTURE
- **Chart:** Pie chart
- **Data:** All triggers from BOTH cravings + usage (HAALT model)
- **Purpose:** Visual breakdown beyond top 3
- **Status:** Computed property exists (`triggerBreakdown`), chart UI deferred

### 9. Location Patterns 🔮 FUTURE
- **Chart:** Bar chart or list
- **Data:** Where cravings/usage occur most (Home, Work, Social, etc.)
- **Purpose:** Identifies high-risk environmental cues
- **Status:** Computed property exists (`locationBreakdown`), UI deferred

### 10. Time of Day Breakdown 🔮 FUTURE
- **Chart:** Bar chart (4 periods: morning/afternoon/evening/night)
- **Data:** Usage + craving distribution by time of day
- **Purpose:** Reveals temporal patterns for intervention planning
- **Status:** Computed property exists (`timeOfDayBreakdown`), UI deferred

### 11. Usage by ROA 🔮 FUTURE
- **Chart:** Pie chart
- **Data:** Method distribution (50% Bowls, 30% Vape, 20% Edibles)
- **Purpose:** Tracks ROA switching (escalation indicator)
- **Status:** Computed property exists (`roaBreakdown`), UI deferred

### 12. Day of Week Patterns 🔮 FUTURE
- **Chart:** Bar chart (Mon-Sun)
- **Data:** Usage frequency by day of week
- **Purpose:** Shows which days are highest risk
- **Status:** Computed property exists (`dayOfWeekBreakdown`), UI deferred

---

## ✅ Success Criteria

### Functional Requirements
- [ ] Dashboard loads <3 seconds with 90 days of data (200+ logs)
- [ ] All 5 MVP metrics render correctly with sample data (summary, 2 streaks, intensity, triggers)
- [ ] Date range filter works (7/30/90 days/All Time)
- [ ] Empty state shows if <2 total logs (craving + usage combined)
- [ ] All metrics adapt to dark mode automatically
- [ ] All metrics handle edge cases (zero data, single data point, etc.)

### Code Quality
- [ ] FetchDashboardDataUseCase unit tests (5 tests)
- [ ] DashboardViewModel unit tests (8 tests)
- [ ] No SwiftData queries in View layer (all in Use Case)
- [ ] DependencyContainer wiring complete
- [ ] Swift 6 strict concurrency compliance (@MainActor, Sendable)

### Performance
- [ ] Date range filter responds instantly (<100ms)
- [ ] Metric cards render in <500ms
- [ ] No UI blocking during data aggregation
- [ ] Repository queries use efficient date range filtering

---

## 🏗️ Architecture Decisions

### Why Separate Use Case for Dashboard?
**Decision:** Create `FetchDashboardDataUseCase` instead of reusing `FetchCravingsUseCase` + `FetchUsageUseCase`

**Rationale:**
1. **Performance** - Single query with optimized predicates (avoids N+1 queries)
2. **Encapsulation** - Dashboard-specific logic isolated from generic fetch operations
3. **Testability** - Mock dashboard data independently from individual log fetches
4. **Future-proofing** - Dashboard may need aggregated queries that don't fit generic fetch patterns

### Why No Repository Layer Changes?
**Decision:** Use existing `CravingRepositoryProtocol` and `UsageRepositoryProtocol` without modifications

**Rationale:**
1. **Repositories are already complete** - Phases 1-2 created full CRUD operations
2. **Use Case handles aggregation** - Business logic belongs in Use Cases, not Repositories
3. **Follows Clean Architecture** - Repositories provide raw data, Use Cases compute metrics

### Data Model: DashboardData Struct
**Decision:** Create a simple struct to carry aggregated data from Use Case → ViewModel

**Why:**
- **Type-safe** - Compile-time guarantee of data structure
- **Testable** - Easy to mock dashboard data in tests
- **Decoupled** - View doesn't depend on SwiftData models directly

---

## 📝 Implementation Steps

### Step 1: Create DashboardData Entity (Domain Layer)

**File:** `Cravey/Domain/Entities/DashboardData.swift`

**Purpose:** Value object to carry aggregated dashboard metrics from Use Case to ViewModel.

```swift
import Foundation

/// Aggregated dashboard data (computed from cravings + usage logs)
/// Pure Swift - no framework dependencies
struct DashboardData: Equatable, Sendable {
    // Raw data
    let cravings: [CravingEntity]
    let usageLogs: [UsageEntity]

    // Date range metadata
    let startDate: Date
    let endDate: Date

    init(
        cravings: [CravingEntity],
        usageLogs: [UsageEntity],
        startDate: Date,
        endDate: Date
    ) {
        self.cravings = cravings
        self.usageLogs = usageLogs
        self.startDate = startDate
        self.endDate = endDate
    }
}

// MARK: - Computed Metrics

extension DashboardData {
    /// Total number of cravings in date range
    var totalCravings: Int {
        cravings.count
    }

    /// Total number of usage logs in date range
    var totalUsage: Int {
        usageLogs.count
    }

    /// Average craving intensity (1-10 scale), nil if no cravings
    var averageCravingIntensity: Double? {
        guard !cravings.isEmpty else { return nil }
        let sum = cravings.reduce(0) { $0 + $1.intensity }
        return Double(sum) / Double(cravings.count)
    }

    /// Combined triggers from both cravings and usage
    /// Returns dictionary: ["Anxious": 12, "Bored": 8, ...]
    var triggerBreakdown: [String: Int] {
        var counts: [String: Int] = [:]

        // Combine craving triggers
        for craving in cravings {
            for trigger in craving.triggers {
                counts[trigger, default: 0] += 1
            }
        }

        // Combine usage triggers
        for usage in usageLogs {
            for trigger in usage.triggers {
                counts[trigger, default: 0] += 1
            }
        }

        return counts
    }

    /// Top 3 triggers by frequency
    /// Returns array of tuples: [("Anxious", 12), ("Bored", 8), ...]
    var topTriggers: [(trigger: String, count: Int)] {
        triggerBreakdown
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { (trigger: $0.key, count: $0.value) }
    }

    /// Location breakdown (combined cravings + usage)
    /// Returns dictionary: ["Home": 15, "Work": 8, ...]
    var locationBreakdown: [String: Int] {
        var counts: [String: Int] = [:]

        // Combine craving locations
        for craving in cravings {
            if let location = craving.location {
                counts[location, default: 0] += 1
            }
        }

        // Combine usage locations
        for usage in usageLogs {
            if let location = usage.location {
                counts[location, default: 0] += 1
            }
        }

        return counts
    }

    /// Usage by ROA (Route of Administration)
    /// Returns dictionary: ["Bowls": 10, "Vape": 5, ...]
    var roaBreakdown: [String: Int] {
        var counts: [String: Int] = [:]

        for usage in usageLogs {
            counts[usage.method, default: 0] += 1
        }

        return counts
    }

    /// Time of day breakdown (4 periods: morning/afternoon/evening/night)
    /// Returns dictionary: ["Morning": 5, "Afternoon": 8, ...]
    var timeOfDayBreakdown: [String: Int] {
        var counts: [String: Int] = [:]

        let calendar = Calendar.current

        func timeOfDay(for date: Date) -> String {
            let hour = calendar.component(.hour, from: date)
            switch hour {
            case 5..<12: return "Morning"
            case 12..<17: return "Afternoon"
            case 17..<21: return "Evening"
            default: return "Night"
            }
        }

        // Count cravings by time of day
        for craving in cravings {
            let period = timeOfDay(for: craving.timestamp)
            counts[period, default: 0] += 1
        }

        // Count usage by time of day
        for usage in usageLogs {
            let period = timeOfDay(for: usage.timestamp)
            counts[period, default: 0] += 1
        }

        return counts
    }

    /// Day of week breakdown (Mon-Sun)
    /// Returns dictionary: ["Monday": 5, "Tuesday": 3, ...]
    var dayOfWeekBreakdown: [String: Int] {
        var counts: [String: Int] = [:]

        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"  // Full day name

        // Count usage by day of week
        for usage in usageLogs {
            let dayName = formatter.string(from: usage.timestamp)
            counts[dayName, default: 0] += 1
        }

        return counts
    }

    /// Current abstinence streak (consecutive days with NO usage)
    /// Returns nil if user has logged usage today or never logged usage
    var currentAbstinenceStreak: Int? {
        guard !usageLogs.isEmpty else { return nil }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Sort usage logs by date (newest first)
        let sortedLogs = usageLogs.sorted { $0.timestamp > $1.timestamp }

        // If most recent usage was today, no abstinence streak
        guard let mostRecent = sortedLogs.first else { return nil }
        let mostRecentDay = calendar.startOfDay(for: mostRecent.timestamp)

        if calendar.isDate(mostRecentDay, inSameDayAs: today) {
            return nil  // Used today, no streak
        }

        // Count consecutive days WITHOUT usage
        var streak = 0
        var checkDate = today

        while true {
            let hasUsage = usageLogs.contains { usage in
                calendar.isDate(usage.timestamp, inSameDayAs: checkDate)
            }

            if hasUsage {
                break  // Streak ends
            }

            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!

            // Stop if we've checked beyond our data range
            if checkDate < startDate {
                break
            }
        }

        return streak > 0 ? streak : nil
    }

    /// Longest historical abstinence streak
    /// Calculated across ALL usage logs (not limited to date range)
    /// Returns nil if fewer than 2 usage logs exist (need gaps to calculate)
    var longestAbstinenceStreak: Int? {
        guard usageLogs.count >= 2 else { return nil }

        let calendar = Calendar.current

        // Sort usage logs by date (oldest first)
        let sortedLogs = usageLogs.sorted { $0.timestamp < $1.timestamp }

        var maxGap = 0

        for i in 0..<(sortedLogs.count - 1) {
            let current = sortedLogs[i]
            let next = sortedLogs[i + 1]

            let currentDay = calendar.startOfDay(for: current.timestamp)
            let nextDay = calendar.startOfDay(for: next.timestamp)

            if let daysBetween = calendar.dateComponents([.day], from: currentDay, to: nextDay).day {
                let gapDays = daysBetween - 1  // Exclude the usage days themselves
                maxGap = max(maxGap, gapDays)
            }
        }

        return maxGap > 0 ? maxGap : nil
    }
}
```

**Why This Code:**
- **Pure Domain Logic** - No SwiftUI, no SwiftData, just business logic
- **Computed Properties** - All metrics calculated on-demand (no caching needed for MVP)
- **Type-Safe** - Returns `Int?` for metrics that may not exist (avoids force-unwraps)
- **Reusable** - ViewModel can format/display however it wants
- **Testable** - Easy to unit test with mock CravingEntity/UsageEntity arrays

---

### Step 2: Create FetchDashboardDataUseCase (Domain Layer)

**File:** `Cravey/Domain/UseCases/FetchDashboardDataUseCase.swift`

```swift
import Foundation

/// Use case for fetching dashboard analytics data
protocol FetchDashboardDataUseCase: Sendable {
    func execute(dateRange: DateRange) async throws -> DashboardData
}

/// Date range filter for dashboard
enum DateRange: String, CaseIterable, Sendable {
    case sevenDays = "7 Days"
    case thirtyDays = "30 Days"
    case ninetyDays = "90 Days"
    case allTime = "All Time"

    var days: Int? {
        switch self {
        case .sevenDays: return 7
        case .thirtyDays: return 30
        case .ninetyDays: return 90
        case .allTime: return nil
        }
    }

    func startDate(from endDate: Date = Date()) -> Date {
        guard let days = days else {
            return Date.distantPast  // All time = fetch everything
        }
        return Calendar.current.date(byAdding: .day, value: -days, to: endDate) ?? endDate
    }
}

actor DefaultFetchDashboardDataUseCase: FetchDashboardDataUseCase {
    private let cravingRepository: CravingRepositoryProtocol
    private let usageRepository: UsageRepositoryProtocol

    init(
        cravingRepository: CravingRepositoryProtocol,
        usageRepository: UsageRepositoryProtocol
    ) {
        self.cravingRepository = cravingRepository
        self.usageRepository = usageRepository
    }

    func execute(dateRange: DateRange) async throws -> DashboardData {
        let endDate = Date()
        let startDate = dateRange.startDate(from: endDate)

        // Fetch cravings and usage in parallel using existing repository APIs
        async let cravings = cravingRepository.fetch(from: startDate, to: endDate)
        async let usageLogs = usageRepository.fetch(from: startDate, to: endDate)

        return DashboardData(
            cravings: try await cravings,
            usageLogs: try await usageLogs,
            startDate: startDate,
            endDate: endDate
        )
    }
}
```

**Why This Code:**
- **Protocol-based** - Follows Clean Architecture (dependency inversion)
- **`actor` for concurrency** - Safe for async/await (Swift 6 strict concurrency)
- **DateRange enum** - Type-safe date filtering (no magic numbers)
- **Parallel fetching** - Uses `async let` to fetch cravings + usage simultaneously (performance)
- **Uses existing repository APIs** - `CravingRepositoryProtocol.fetch(from:to:)` already exists (verified in baseline code at Cravey/Domain/Repositories/CravingRepositoryProtocol.swift:13)

**Dependencies Required:**
- ✅ `CravingRepositoryProtocol.fetch(from:to:)` - Already exists (PHASE_1)
- ⚠️ `UsageRepositoryProtocol.fetch(from:to:)` - Must be implemented in PHASE_2 (same signature as craving repo)

---

### Step 3: Create DashboardViewModel (Presentation Layer)

**File:** `Cravey/Presentation/ViewModels/DashboardViewModel.swift`

```swift
import Foundation
import Observation

/// ViewModel for Dashboard screen
/// Manages dashboard state and date range filtering
@Observable
@MainActor
final class DashboardViewModel {
    // State
    var dashboardData: DashboardData?
    var isLoading = false
    var error: String?
    var selectedDateRange: DateRange = .thirtyDays

    // Dependencies
    private let fetchDashboardDataUseCase: FetchDashboardDataUseCase

    init(fetchDashboardDataUseCase: FetchDashboardDataUseCase) {
        self.fetchDashboardDataUseCase = fetchDashboardDataUseCase
    }

    // MARK: - Actions

    func loadDashboard() async {
        isLoading = true
        error = nil

        do {
            dashboardData = try await fetchDashboardDataUseCase.execute(dateRange: selectedDateRange)
        } catch {
            self.error = "Failed to load dashboard: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func changeDateRange(to newRange: DateRange) async {
        selectedDateRange = newRange
        await loadDashboard()
    }

    // MARK: - Computed Properties (Formatted for UI)

    var summaryText: String {
        guard let data = dashboardData else { return "Loading..." }

        let period = selectedDateRange.rawValue.lowercased()
        return "Past \(period): \(data.totalUsage) uses, \(data.totalCravings) cravings"
    }

    var averageIntensityText: String? {
        guard let avg = dashboardData?.averageCravingIntensity else { return nil }
        return String(format: "%.1f / 10", avg)
    }

    var topTriggersText: String {
        guard let data = dashboardData else { return "No data" }

        let topThree = data.topTriggers
        if topThree.isEmpty {
            return "No triggers logged"
        }

        return topThree.enumerated().map { index, item in
            "\(index + 1). \(item.trigger) (\(item.count))"
        }.joined(separator: "\n")
    }

    var currentStreakText: String {
        guard let data = dashboardData else { return "—" }

        if let streak = data.currentAbstinenceStreak {
            return "\(streak) days abstinent"
        } else if !data.usageLogs.isEmpty {
            return "Active use period"
        } else {
            return "No usage logged"
        }
    }

    var longestStreakText: String {
        guard let streak = dashboardData?.longestAbstinenceStreak else {
            return "Not enough data"
        }
        return "Your best: \(streak) days"
    }

    /// Returns true if dashboard should show empty state
    var shouldShowEmptyState: Bool {
        guard let data = dashboardData else { return false }
        return (data.totalCravings + data.totalUsage) < 2
    }
}
```

**Why This Code:**
- **@Observable macro** - SwiftUI reactive binding (iOS 18+)
- **@MainActor** - All UI updates on main thread (Swift 6 concurrency)
- **Formatted properties** - ViewModel owns formatting logic, View just displays
- **Empty state logic** - `shouldShowEmptyState` decides if <2 total logs
- **Clean separation** - Domain logic in `DashboardData`, presentation logic in ViewModel

---

### Step 4: Create MetricCardView Component (Presentation Layer)

**File:** `Cravey/Presentation/Views/Components/MetricCardView.swift`

**Purpose:** Reusable card component for displaying metrics. Follows iOS design patterns (rounded rectangle, padding, system fonts).

```swift
import SwiftUI

/// Reusable metric card for dashboard
struct MetricCardView: View {
    let title: String
    let value: String
    let subtitle: String?
    let systemImage: String?

    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        systemImage: String? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.systemImage = systemImage
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .foregroundStyle(.secondary)
                }
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Value
            Text(value)
                .font(.title)
                .fontWeight(.bold)

            // Subtitle (optional)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 16) {
        MetricCardView(
            title: "Current Streak",
            value: "7 days",
            subtitle: "Abstinent since Nov 1",
            systemImage: "flame.fill"
        )

        MetricCardView(
            title: "Longest Streak",
            value: "14 days",
            systemImage: "star.fill"
        )
    }
    .padding()
}
```

**Why This Code:**
- **Reusable** - Used for streak cards, summary stats, etc.
- **SF Symbols** - Optional system image for visual hierarchy
- **Adaptive** - Works in light/dark mode (Color(.systemGray6))
- **Preview** - Xcode live preview for rapid iteration

---

### Step 5: Create SummaryCardView (Presentation Layer)

**File:** `Cravey/Presentation/Views/Dashboard/SummaryCardView.swift`

```swift
import SwiftUI

/// Top summary card for dashboard (total cravings + usage)
struct SummaryCardView: View {
    let totalCravings: Int
    let totalUsage: Int
    let dateRangeName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Summary")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 32) {
                // Cravings
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(totalCravings)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.orange)
                    Text("Cravings")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Usage
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(totalUsage)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.green)
                    Text("Uses")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Past \(dateRangeName.lowercased())")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    SummaryCardView(
        totalCravings: 12,
        totalUsage: 8,
        dateRangeName: "30 Days"
    )
    .padding()
}
```

---

### Step 6: Create EmptyDashboardView (Presentation Layer)

**File:** `Cravey/Presentation/Views/Dashboard/EmptyDashboardView.swift`

```swift
import SwiftUI

/// Empty state shown when user has <2 total logs
struct EmptyDashboardView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("No Data Yet")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Keep logging cravings and usage.\nYou'll see patterns after a few entries.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

#Preview {
    EmptyDashboardView()
}
```

**Why This Code:**
- **Compassionate messaging** - "No data yet" not "You failed"
- **Clear next action** - Tells user to keep logging
- **Visual hierarchy** - SF Symbol + text following iOS patterns

---

### Step 7: Create DashboardView (Presentation Layer)

**File:** `Cravey/Presentation/Views/Dashboard/DashboardView.swift`

**Purpose:** Main dashboard container with date range filter and metric cards.

```swift
import SwiftUI

struct DashboardView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: DashboardViewModel?

    var body: some View {
        Group {
            if let viewModel = viewModel {
                dashboardContent(viewModel: viewModel)
            } else {
                ProgressView("Loading dashboard...")
            }
        }
        .task {
            if viewModel == nil {
                viewModel = container.makeDashboardViewModel()
            }
            await viewModel?.loadDashboard()
        }
    }

    @ViewBuilder
    private func dashboardContent(viewModel: DashboardViewModel) -> some View {
        if viewModel.shouldShowEmptyState {
            EmptyDashboardView()
        } else {
            ScrollView {
                VStack(spacing: 20) {
                    // Date Range Filter
                    dateRangePicker(viewModel: viewModel)

                    // Summary Card
                    if let data = viewModel.dashboardData {
                        SummaryCardView(
                            totalCravings: data.totalCravings,
                            totalUsage: data.totalUsage,
                            dateRangeName: viewModel.selectedDateRange.rawValue
                        )
                    }

                    // Metric Cards Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        // Current Streak
                        MetricCardView(
                            title: "Current Streak",
                            value: viewModel.currentStreakText,
                            systemImage: "flame.fill"
                        )

                        // Longest Streak
                        MetricCardView(
                            title: "Longest Streak",
                            value: viewModel.longestStreakText,
                            systemImage: "star.fill"
                        )

                        // Average Intensity
                        if let intensityText = viewModel.averageIntensityText {
                            MetricCardView(
                                title: "Avg Intensity",
                                value: intensityText,
                                subtitle: "Craving severity",
                                systemImage: "chart.line.uptrend.xyaxis"
                            )
                        }
                    }

                    // Top Triggers
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top Triggers")
                            .font(.headline)

                        Text(viewModel.topTriggersText)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }

    @ViewBuilder
    private func dateRangePicker(viewModel: DashboardViewModel) -> some View {
        Picker("Date Range", selection: Binding(
            get: { viewModel.selectedDateRange },
            set: { newRange in
                Task {
                    await viewModel.changeDateRange(to: newRange)
                }
            }
        )) {
            ForEach(DateRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .environment(DependencyContainer.preview)
    }
}
```

**Why This Code:**
- **Optional ViewModel pattern** - Same as PHASE_4 (handles async initialization)
- **@ViewBuilder** - Extracts content for readability
- **Empty state handling** - Shows EmptyDashboardView if <2 logs
- **Date range picker** - Segmented control (iOS standard)
- **Grid layout** - 2-column grid for metric cards (compact)
- **Preview** - Uses DependencyContainer.preview for Xcode live preview

---

### Step 8: Update DependencyContainer (App Layer)

**File:** `Cravey/App/DependencyContainer.swift` (MODIFY)

**Purpose:** Wire up dashboard use case and ViewModel factory.

#### 1. Add Use Case Property

After the existing use cases (around line 29):

```swift
// MARK: - Use Cases (Domain Layer)

private(set) var logCravingUseCase: LogCravingUseCase
private(set) var fetchCravingsUseCase: FetchCravingsUseCase
// ... (existing recording use cases)

// ← ADD THIS:
private(set) var fetchDashboardDataUseCase: FetchDashboardDataUseCase
```

#### 2. Initialize Use Case

In `init(isPreview:)` method, after existing use case initialization:

```swift
// Initialize use cases
self.logCravingUseCase = DefaultLogCravingUseCase(repository: cravingRepo)
self.fetchCravingsUseCase = DefaultFetchCravingsUseCase(repository: cravingRepo)
// ... (existing recording use cases)

// ← ADD THIS:
self.fetchDashboardDataUseCase = DefaultFetchDashboardDataUseCase(
    cravingRepository: cravingRepo,
    usageRepository: usageRepo  // Assumes UsageRepository exists from Phase 2
)
```

#### 3. Add ViewModel Factory Method

After existing ViewModel factories:

```swift
// MARK: - View Models (Presentation Layer)

func makeCravingLogViewModel() -> CravingLogViewModel {
    CravingLogViewModel(logCravingUseCase: logCravingUseCase)
}

// ... (existing recording ViewModels)

// ← ADD THIS:
func makeDashboardViewModel() -> DashboardViewModel {
    DashboardViewModel(fetchDashboardDataUseCase: fetchDashboardDataUseCase)
}
```

**Dependencies Required:**
- `usageRepository` must exist (created in PHASE_2)
- `UsageRepositoryProtocol` must have `fetch(since: Date)` method

---

## ✅ Testing Strategy

### Unit Tests (5 tests)

**File:** `CraveyTests/Domain/UseCases/FetchDashboardDataUseCaseTests.swift`

```swift
import Testing
@testable import Cravey

@Suite("FetchDashboardDataUseCase Tests")
struct FetchDashboardDataUseCaseTests {

    @Test("Should aggregate cravings and usage for 7-day range")
    func testSevenDayRange() async throws {
        let mockCravingRepo = MockCravingRepository()
        let mockUsageRepo = MockUsageRepository()

        // Seed mock data (5 cravings, 3 usage logs in last 7 days)
        let useCase = DefaultFetchDashboardDataUseCase(
            cravingRepository: mockCravingRepo,
            usageRepository: mockUsageRepo
        )

        let result = try await useCase.execute(dateRange: .sevenDays)

        #expect(result.totalCravings == 5)
        #expect(result.totalUsage == 3)
    }

    @Test("Should calculate average craving intensity correctly")
    func testAverageCravingIntensity() async throws {
        // Create 3 cravings: intensity 5, 7, 9
        // Expected average: (5+7+9)/3 = 7.0

        #expect(dashboardData.averageCravingIntensity == 7.0)
    }

    @Test("Should return nil for average intensity if no cravings")
    func testAverageIntensityWithNoCravings() async throws {
        let emptyData = DashboardData(
            cravings: [],
            usageLogs: [],
            startDate: Date(),
            endDate: Date()
        )

        #expect(emptyData.averageCravingIntensity == nil)
    }

    @Test("Should combine triggers from both cravings and usage")
    func testTriggerBreakdown() async throws {
        // Create craving with ["Anxious", "Bored"]
        // Create usage with ["Anxious", "Social"]
        // Expected: ["Anxious": 2, "Bored": 1, "Social": 1]

        let breakdown = dashboardData.triggerBreakdown
        #expect(breakdown["Anxious"] == 2)
        #expect(breakdown["Bored"] == 1)
        #expect(breakdown["Social"] == 1)
    }

    @Test("Should calculate current abstinence streak correctly")
    func testCurrentAbstinenceStreak() async throws {
        // Create usage logs: 5 days ago, 6 days ago
        // Expected streak: 4 days (no usage for 4 consecutive days)

        #expect(dashboardData.currentAbstinenceStreak == 4)
    }
}
```

### ViewModel Tests (8 tests)

**File:** `CraveyTests/Presentation/ViewModels/DashboardViewModelTests.swift`

```swift
import Testing
@testable import Cravey

@Suite("DashboardViewModel Tests")
struct DashboardViewModelTests {

    @Test("Should load dashboard data on initialization")
    @MainActor
    func testLoadDashboard() async throws {
        let mockUseCase = MockFetchDashboardDataUseCase()
        let viewModel = DashboardViewModel(fetchDashboardDataUseCase: mockUseCase)

        await viewModel.loadDashboard()

        #expect(viewModel.dashboardData != nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("Should update date range and reload data")
    @MainActor
    func testChangeDateRange() async throws {
        let viewModel = DashboardViewModel(fetchDashboardDataUseCase: mockUseCase)

        await viewModel.changeDateRange(to: .ninetyDays)

        #expect(viewModel.selectedDateRange == .ninetyDays)
        #expect(mockUseCase.lastExecutedRange == .ninetyDays)
    }

    @Test("Should show empty state if <2 total logs")
    @MainActor
    func testShouldShowEmptyState() async throws {
        // Create dashboard data with 1 craving, 0 usage
        viewModel.dashboardData = DashboardData(
            cravings: [mockCraving],
            usageLogs: [],
            startDate: Date(),
            endDate: Date()
        )

        #expect(viewModel.shouldShowEmptyState == true)
    }

    @Test("Should format summary text correctly")
    @MainActor
    func testSummaryText() async throws {
        viewModel.dashboardData = mockDashboardData
        viewModel.selectedDateRange = .thirtyDays

        #expect(viewModel.summaryText == "Past 30 days: 8 uses, 12 cravings")
    }
}
```

---

## 🧪 Mock Implementations for Tests

The test examples above reference mock objects. Implement these using the same patterns from PHASE_1/2/3/4:

### MockCravingRepository (Reuse from PHASE_1)

Already exists in `CraveyTests/Mocks/MockCravingRepository.swift` from PHASE_1. Key method:

```swift
actor MockCravingRepository: CravingRepositoryProtocol {
    private var cravings: [CravingEntity] = []

    func fetch(from startDate: Date, to endDate: Date) async throws -> [CravingEntity] {
        return cravings.filter { craving in
            craving.timestamp >= startDate && craving.timestamp <= endDate
        }
    }

    // Add helper for tests
    func seed(_ cravings: [CravingEntity]) {
        self.cravings = cravings
    }
}
```

### MockUsageRepository (Create in PHASE_2)

Should be created in PHASE_2 at `CraveyTests/Mocks/MockUsageRepository.swift`:

```swift
actor MockUsageRepository: UsageRepositoryProtocol {
    private var usageLogs: [UsageEntity] = []

    func fetch(from startDate: Date, to endDate: Date) async throws -> [UsageEntity] {
        return usageLogs.filter { usage in
            usage.timestamp >= startDate && usage.timestamp <= endDate
        }
    }

    func seed(_ logs: [UsageEntity]) {
        self.usageLogs = logs
    }
}
```

### MockFetchDashboardDataUseCase

**File:** `CraveyTests/Mocks/MockFetchDashboardDataUseCase.swift` (CREATE THIS)

```swift
import Foundation
@testable import Cravey

actor MockFetchDashboardDataUseCase: FetchDashboardDataUseCase {
    private(set) var lastExecutedRange: DateRange?
    private var result: DashboardData?

    func setResult(_ data: DashboardData) {
        self.result = data
    }

    func execute(dateRange: DateRange) async throws -> DashboardData {
        lastExecutedRange = dateRange

        guard let result = result else {
            // Return empty data if no mock result set
            return DashboardData(
                cravings: [],
                usageLogs: [],
                startDate: Date(),
                endDate: Date()
            )
        }

        return result
    }
}
```

**Usage in Tests:**

```swift
@Test("Should load dashboard data")
@MainActor
func testLoadDashboard() async throws {
    let mockUseCase = MockFetchDashboardDataUseCase()

    // Seed mock data
    let mockData = DashboardData(
        cravings: [mockCraving1, mockCraving2],
        usageLogs: [mockUsage1],
        startDate: Date().addingTimeInterval(-30 * 86400),
        endDate: Date()
    )
    await mockUseCase.setResult(mockData)

    let viewModel = DashboardViewModel(fetchDashboardDataUseCase: mockUseCase)
    await viewModel.loadDashboard()

    #expect(viewModel.dashboardData != nil)
    #expect(viewModel.dashboardData?.totalCravings == 2)
    #expect(viewModel.dashboardData?.totalUsage == 1)
}
```

---

## 📚 Dependencies from Previous Phases

This phase REQUIRES completion of:

### From PHASE_1 (Craving Logging):
- ✅ `CravingEntity` exists
- ✅ `CravingRepositoryProtocol.fetch(from:to:)` method exists (verified in baseline)

### From PHASE_2 (Usage Logging):
- ⚠️ `UsageEntity` must exist
- ⚠️ `UsageRepositoryProtocol.fetch(from:to:)` method must exist (same signature as CravingRepositoryProtocol)
- ⚠️ `UsageRepository` implementation must exist

**Action Required:**
1. Verify PHASE_2 is complete before starting this phase
2. Ensure `UsageRepositoryProtocol` has `fetch(from:to:)` method matching `CravingRepositoryProtocol` (see baseline at Cravey/Domain/Repositories/CravingRepositoryProtocol.swift:13)

---

## 🔄 Future Enhancements (Post-MVP)

1. **Swift Charts Integration** - Visualize the 7 computed properties with line/bar/pie charts (craving intensity over time, location patterns, time of day, day of week, ROA breakdown)
2. **Heatmap Visualization** - GitHub-style contribution graph (time + day combined)
3. **Export Dashboard as PDF** - Share metrics with therapist/doctor
4. **Custom Date Range** - User-selected start/end dates
5. **Metric Favoriting** - Pin most useful metrics to top
6. **Tap Metric to View Logs** - Drill down from summary to detailed logs

**Note:** All data for future chart enhancements already exists as computed properties in `DashboardData`. Only UI implementation is deferred.

---

## 📝 Summary

**Phase 5 delivers a read-only analytics dashboard** that:
- ✅ Aggregates data from Phases 1-2 (cravings + usage)
- ✅ Displays 5 MVP metrics (summary, 2 streaks, intensity, top triggers)
- ✅ Provides 7 computed properties in DashboardData for future UI expansion (location, ROA, time of day, etc.)
- ✅ Filters by date range (7/30/90 days/all time)
- ✅ Loads in <3 seconds with 90 days of data
- ✅ Follows Clean Architecture (Domain → Presentation)
- ✅ Uses baseline repository APIs: `fetch(from:to:)` (verified against existing code)
- ✅ Uses established DI patterns from PHASE_3/4
- ✅ Handles empty states gracefully (<2 total logs)
- ✅ No data modification (read-only)
- ✅ Includes comprehensive mock implementations for testing

**Files Created:** 7 files (2 Domain + 1 ViewModel + 4 Views) + 1 mock file
**Tests:** 13 tests (5 Use Case + 8 ViewModel) with complete mock guidance
**Duration:** 2 weeks (Weeks 7-8)
**Audit Status:** ✅ Validated against baseline code (v2.1)

---

**Ready for Implementation! 🚀**

**[← Back to Overview](./PHASE_OVERVIEW.md)** | **[← Phase 4 (Recordings)](./PHASE_4.md)**
