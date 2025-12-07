import SwiftUI

/// Home screen - main entry point for logging cravings/usage
/// Presentation layer - Clean Architecture
struct HomeView: View {
    @Environment(DependencyContainer.self) private var container

    // Sheet state
    @State private var showCravingLogSheet = false
    @State private var showUsageLogSheet = false

    // Log form ViewModels (deferred initialization pattern)
    @State private var cravingLogViewModel: CravingLogViewModel?
    @State private var usageLogViewModel: UsageLogViewModel?

    // List ViewModels (deferred initialization - not created inline)
    @State private var cravingListViewModel: CravingListViewModel?
    @State private var usageListViewModel: UsageListViewModel?

    // Toast state
    @State private var showSuccessToast = false
    @State private var successMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // TODO: Quick Play section (Phase 4 - Recordings)

                // Craving List (with deferred VM initialization)
                if let viewModel = cravingListViewModel {
                    CravingListView(viewModel: viewModel)
                } else {
                    ProgressView()
                        .task {
                            cravingListViewModel = container.makeCravingListViewModel()
                        }
                }

                // Usage List (with deferred VM initialization)
                if let viewModel = usageListViewModel {
                    UsageListView(viewModel: viewModel)
                } else {
                    ProgressView()
                        .task {
                            usageListViewModel = container.makeUsageListViewModel()
                        }
                }
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
            // MARK: - Craving Log Sheet
            .sheet(isPresented: $showCravingLogSheet) {
                // Detect if success occurred before reset
                let didSucceed = cravingLogViewModel?.didSucceed ?? false

                // Reset form state when sheet dismisses
                cravingLogViewModel = nil

                // Refresh list after logging
                Task {
                    await cravingListViewModel?.fetchCravings()
                }

                // Show success toast if craving was logged (UX_FLOW:396-405)
                if didSucceed {
                    successMessage = "Craving logged"
                    showSuccessToast = true
                }
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
            // MARK: - Usage Log Sheet
            .sheet(isPresented: $showUsageLogSheet) {
                // Detect if success occurred before reset
                let didSucceed = usageLogViewModel?.didSucceed ?? false

                // Reset form state when sheet dismisses
                usageLogViewModel = nil

                // Refresh list after logging
                Task {
                    await usageListViewModel?.fetchUsage()
                }

                // Show success toast if usage was logged (UX_FLOW:396-405)
                if didSucceed {
                    successMessage = "Usage logged"
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
            // MARK: - Success Toast
            .overlay(alignment: .top) {
                // Success toast (appears AFTER sheet dismisses per UX_FLOW:396-405)
                if showSuccessToast {
                    VStack {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text(successMessage ?? "Logged")
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
