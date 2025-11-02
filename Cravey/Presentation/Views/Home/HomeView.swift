import SwiftUI

/// Home screen - main entry point for logging cravings/usage
/// Presentation layer - Clean Architecture
struct HomeView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var showCravingLogSheet = false
    @State private var cravingLogViewModel: CravingLogViewModel?
    @State private var refreshID = UUID()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // TODO: Quick Play section (Phase 4 - Recordings)

                // Craving List
                CravingListView(
                    viewModel: CravingListViewModel(
                        fetchCravingsUseCase: container.fetchCravingsUseCase
                    )
                )
                .id(refreshID) // Force refresh when ID changes
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Log Craving") {
                            showCravingLogSheet = true
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
            .sheet(isPresented: $showCravingLogSheet) {
                // Reset form state and trigger list refresh when sheet dismisses
                cravingLogViewModel = nil
                refreshID = UUID()
            } content: {
                // 2025 Pattern: Deferred ViewModel initialization
                if let viewModel = cravingLogViewModel {
                    CravingLogForm(viewModel: viewModel)
                } else {
                    // Placeholder while VM initializes
                    Color.clear
                        .task {
                            cravingLogViewModel = container.makeCravingLogViewModel()
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
