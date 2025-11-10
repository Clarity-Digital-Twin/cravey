import SwiftUI

/// Home screen - main entry point for logging cravings/usage
/// Presentation layer - Clean Architecture
struct HomeView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var showCravingLogSheet = false
    @State private var cravingLogViewModel: CravingLogViewModel?
    @State private var showUsageLogSheet = false
    @State private var usageLogViewModel: UsageLogViewModel?
    @State private var cravingRefreshID = UUID()
    @State private var usageRefreshID = UUID()
    @State private var showSuccessToast = false
    @State private var successMessage: String?

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
                .id(cravingRefreshID) // Force refresh when ID changes

                // Usage List
                UsageListView(
                    viewModel: UsageListViewModel(
                        fetchUsageUseCase: container.fetchUsageUseCase
                    )
                )
                .id(usageRefreshID) // Force refresh when ID changes
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Log Craving") {
                            showCravingLogSheet = true
                        }
                        Button("Log Usage") {
                            showUsageLogSheet = true
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
                cravingRefreshID = UUID()
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
            .sheet(isPresented: $showUsageLogSheet) {
                // Detect if success occurred before reset
                let didSucceed = usageLogViewModel?.didSucceed ?? false

                // Reset form state and trigger list refresh when sheet dismisses
                usageLogViewModel = nil
                usageRefreshID = UUID()

                // Show success toast if usage was logged (UX_FLOW:396-405)
                if didSucceed {
                    successMessage = "Usage logged ✓"
                    showSuccessToast = true
                }
            } content: {
                // 2025 Pattern: Deferred ViewModel initialization
                if let viewModel = usageLogViewModel {
                    UsageLogForm(viewModel: viewModel)
                } else {
                    // Placeholder while VM initializes
                    Color.clear
                        .task {
                            usageLogViewModel = container.makeUsageLogViewModel()
                        }
                }
            }
            .overlay(alignment: .top) {
                // Success toast (appears AFTER sheet dismisses per UX_FLOW:396-405)
                if showSuccessToast {
                    VStack {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text(successMessage ?? "Usage logged ✓")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        .padding(.top, 8)

                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(duration: 0.3), value: showSuccessToast)
                    .task {
                        // Auto-dismiss toast after 2s
                        try? await Task.sleep(for: .seconds(2))
                        showSuccessToast = false
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
