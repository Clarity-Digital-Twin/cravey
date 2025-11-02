import SwiftUI

/// Home screen - main entry point for logging cravings/usage
/// Presentation layer - Clean Architecture
struct HomeView: View {
    @Environment(DependencyContainer.self) private var container

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("🌿 Cravey")
                    .font(.largeTitle.bold())

                Text("Track your journey to clarity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                // TODO: Quick Play section (Phase 4 - Recordings)
                // TODO: Craving list (Phase 1, Day 3)
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Log Craving") {
                            // TODO: Open CravingLogForm sheet
                        }
                        Button("Log Usage") {
                            // TODO: Open UsageLogForm sheet (Phase 2)
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(DependencyContainer.preview)
}
