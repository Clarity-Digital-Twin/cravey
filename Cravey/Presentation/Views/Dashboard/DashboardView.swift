import SwiftUI

/// Dashboard screen - progress visualization
/// Presentation layer - Clean Architecture
struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Dashboard")
                    .font(.largeTitle)

                Text("Coming in Phase 5 (Weeks 7-8)")
                    .foregroundColor(.secondary)

                Spacer()

                // TODO: Add 5 MVP metric cards (Phase 5)
                // - Weekly summary (top triggers, total logs)
                // - Current clean days streak
                // - Longest abstinence streak (all-time)
                // - Average craving intensity trend (7/30/90 days)
                // - Top 3 triggers (pie chart)
            }
            .navigationTitle("Progress")
        }
    }
}

#Preview {
    DashboardView()
}
