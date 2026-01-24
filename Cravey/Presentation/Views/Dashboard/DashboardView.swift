import SwiftUI

/// Dashboard screen - progress visualization with 5 MVP metric cards
/// Presentation layer - Clean Architecture
struct DashboardView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: DashboardViewModel?

    var body: some View {
        NavigationStack {
            ScrollView {
                if let viewModel {
                    if viewModel.isLoading {
                        ProgressView("Loading metrics...")
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        LazyVStack(spacing: 16) {
                            // Card 1: Current Streak
                            MetricCard(
                                title: "Current Streak",
                                value: "\(viewModel.currentStreak)",
                                unit: "days clean",
                                icon: "flame.fill",
                                color: .orange
                            )
                            .accessibilityIdentifier("currentStreakCard")

                            // Card 2: Longest Streak
                            MetricCard(
                                title: "Longest Streak",
                                value: "\(viewModel.longestStreak)",
                                unit: "days (all-time)",
                                icon: "trophy.fill",
                                color: .yellow
                            )
                            .accessibilityIdentifier("longestStreakCard")

                            // Card 3: Average Intensity
                            IntensityTrendCard(
                                sevenDayAvg: viewModel.averageIntensity7Day,
                                thirtyDayAvg: viewModel.averageIntensity30Day
                            )
                            .accessibilityIdentifier("intensityTrendCard")

                            // Card 4: Top Triggers
                            TopTriggersCard(triggers: viewModel.topTriggers)
                                .accessibilityIdentifier("topTriggersCard")

                            // Card 5: Weekly Summary
                            WeeklySummaryCard(
                                cravingCount: viewModel.weeklyCravingCount,
                                usageCount: viewModel.weeklyUsageCount
                            )
                            .accessibilityIdentifier("weeklySummaryCard")
                        }
                        .padding()
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .task {
                            viewModel = container.makeDashboardViewModel()
                            await viewModel?.loadMetrics()
                        }
                }
            }
            .navigationTitle("Progress")
            .refreshable {
                await viewModel?.loadMetrics()
            }
        }
    }
}

// MARK: - Metric Card Component

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    // Track appearance for symbol animation
    @State private var didAppear = false
    // Respect reduced motion accessibility setting
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        // Capture @Environment value before Sendable closure (Swift 6 fix)
        let isReduceMotion = reduceMotion

        HStack {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(color)
                .frame(width: 60)
                // iOS 17+ symbol effect - bounce on appear (auto-respects reduce motion)
                .symbolEffect(.bounce, value: didAppear)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.largeTitle.bold())

                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        // iOS 18+ scroll transition (disabled when reduce motion enabled)
        .scrollTransition { content, phase in
            content
                .opacity(isReduceMotion ? 1 : (phase.isIdentity ? 1 : 0.3))
                .scaleEffect(isReduceMotion ? 1 : (phase.isIdentity ? 1 : 0.9))
        }
        .onAppear {
            didAppear = true
        }
    }
}

// MARK: - Intensity Trend Card

struct IntensityTrendCard: View {
    let sevenDayAvg: Double
    let thirtyDayAvg: Double

    @State private var didAppear = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        // Capture @Environment value before Sendable closure (Swift 6 fix)
        let isReduceMotion = reduceMotion

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(.blue)
                    .symbolEffect(.bounce, value: didAppear)
                Text("Craving Intensity")
                    .font(.headline)
            }

            HStack(spacing: 24) {
                VStack(alignment: .leading) {
                    Text("7-Day Avg")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f", sevenDayAvg))
                        .font(.title2.bold())
                        .foregroundStyle(intensityColor(sevenDayAvg))
                }

                VStack(alignment: .leading) {
                    Text("30-Day Avg")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f", thirtyDayAvg))
                        .font(.title2.bold())
                        .foregroundStyle(intensityColor(thirtyDayAvg))
                }

                Spacer()

                // Trend indicator
                if sevenDayAvg < thirtyDayAvg {
                    Label("Improving", systemImage: "arrow.down.right")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else if sevenDayAvg > thirtyDayAvg {
                    Label("Increasing", systemImage: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else {
                    Label("Stable", systemImage: "arrow.right")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .scrollTransition { content, phase in
            content
                .opacity(isReduceMotion ? 1 : (phase.isIdentity ? 1 : 0.3))
                .scaleEffect(isReduceMotion ? 1 : (phase.isIdentity ? 1 : 0.9))
        }
        .onAppear {
            didAppear = true
        }
    }

    private func intensityColor(_ intensity: Double) -> Color {
        IntensityColorScale.color(for: intensity)
    }
}

// MARK: - Top Triggers Card

struct TopTriggersCard: View {
    let triggers: [(trigger: String, count: Int)]

    @State private var didAppear = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        // Capture @Environment value before Sendable closure (Swift 6 fix)
        let isReduceMotion = reduceMotion

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.purple)
                    .symbolEffect(.bounce, value: didAppear)
                Text("Top Triggers")
                    .font(.headline)
            }

            if triggers.isEmpty {
                Text("No triggers logged yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                ForEach(triggers, id: \.trigger) { item in
                    HStack {
                        Text(item.trigger)
                            .font(.subheadline)

                        Spacer()

                        Text("\(item.count)")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .scrollTransition { content, phase in
            content
                .opacity(isReduceMotion ? 1 : (phase.isIdentity ? 1 : 0.3))
                .scaleEffect(isReduceMotion ? 1 : (phase.isIdentity ? 1 : 0.9))
        }
        .onAppear {
            didAppear = true
        }
    }
}

// MARK: - Weekly Summary Card

struct WeeklySummaryCard: View {
    let cravingCount: Int
    let usageCount: Int

    @State private var didAppear = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        // Capture @Environment value before Sendable closure (Swift 6 fix)
        let isReduceMotion = reduceMotion

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.teal)
                    .symbolEffect(.bounce, value: didAppear)
                Text("This Week")
                    .font(.headline)
            }

            HStack(spacing: 32) {
                VStack {
                    Text("\(cravingCount)")
                        .font(.title.bold())
                    Text("Cravings")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack {
                    Text("\(usageCount)")
                        .font(.title.bold())
                        .foregroundStyle(usageCount > 0 ? .orange : .green)
                    Text("Uses")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Encouragement based on data
                if usageCount == 0 {
                    Text("Great week!")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                } else {
                    Text("Keep going!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .scrollTransition { content, phase in
            content
                .opacity(isReduceMotion ? 1 : (phase.isIdentity ? 1 : 0.3))
                .scaleEffect(isReduceMotion ? 1 : (phase.isIdentity ? 1 : 0.9))
        }
        .onAppear {
            didAppear = true
        }
    }
}

#Preview {
    DashboardView()
        .environment(DependencyContainer.preview)
}
