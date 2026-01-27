import SwiftUI

/// Home tab - dashboard-only overview (no lists, no logging).
/// Presentation layer - Clean Architecture
struct HomeView: View {
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    @Environment(HomeMotivationViewModel.self) private var motivationViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                if dashboardViewModel.isLoading {
                    ProgressView("Loading…")
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .padding()
                } else {
                    LazyVStack(spacing: 16) {
                        HeroStreakCard(
                            daysAbstinent: dashboardViewModel.currentStreak,
                            sinceDate: dashboardViewModel.mostRecentUsageDate
                        )
                        .accessibilityIdentifier("heroStreakCard")

                        TodayStatsCard(
                            cravingCount: dashboardViewModel.todayCravingCount,
                            usageCount: dashboardViewModel.todayUsageCount
                        )
                        .accessibilityIdentifier("todayStatsCard")

                        MotivationCard(message: motivationViewModel.currentMessage)
                            .accessibilityIdentifier("motivationCard")
                            .task {
                                // Mark as shown once when card appears
                                await motivationViewModel.markMessageShown()
                            }

                        if let errorMessage = dashboardViewModel.errorMessage {
                            Text(
                                errorMessage.isEmpty
                                    ? "We couldn't load your dashboard. Please try again."
                                    : errorMessage
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Recovery")
            .task {
                // Load dashboard metrics and motivation message concurrently
                async let dashboardTask: () = dashboardViewModel.loadMetrics()
                async let motivationTask: () = motivationViewModel.loadMessage()
                _ = await (dashboardTask, motivationTask)
            }
            .refreshable {
                await dashboardViewModel.loadMetrics()
            }
        }
    }
}

#Preview {
    let container = DependencyContainer.preview

    HomeView()
        .environment(container.makeDashboardViewModel())
        .environment(container.makeHomeMotivationViewModel())
        .environment(container)
}

private struct HeroStreakCard: View {
    let daysAbstinent: Int
    let sinceDate: Date?

    var body: some View {
        VStack(spacing: 8) {
            Text("\(daysAbstinent)")
                .font(.system(size: 64, weight: .bold, design: .rounded))

            Text("DAYS")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .tracking(1)

            Text("abstinent")
                .font(.title3.weight(.semibold))

            Text(sinceText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var sinceText: String {
        guard let sinceDate else {
            return "Start by logging a usage entry"
        }
        let date = sinceDate.formatted(date: .abbreviated, time: .omitted)
        return "Since \(date)"
    }
}

private struct TodayStatsCard: View {
    let cravingCount: Int
    let usageCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.headline)

            HStack(spacing: 12) {
                StatCard(
                    value: "\(cravingCount)",
                    label: "cravings",
                    tint: .yellow
                )

                StatCard(
                    value: "\(usageCount)",
                    label: "uses",
                    tint: usageCount > 0 ? .orange : .green
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct StatCard: View {
    let value: String
    let label: String
    let tint: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title.bold())
                .foregroundStyle(tint)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct MotivationCard: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("💪")
                .font(.title2)

            Text("“\(message)”")
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
