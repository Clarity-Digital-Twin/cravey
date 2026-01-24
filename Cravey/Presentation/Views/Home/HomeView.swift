import SwiftUI

/// Home screen - main entry point for logging cravings/usage
/// Presentation layer - Clean Architecture
struct HomeView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(CravingListViewModel.self) private var cravingListViewModel
    @Environment(UsageListViewModel.self) private var usageListViewModel

    // Sheet state
    @State private var showCravingLogSheet = false
    @State private var showUsageLogSheet = false

    // Log form ViewModels (fresh per presentation)
    @State private var cravingLogViewModel: CravingLogViewModel?
    @State private var usageLogViewModel: UsageLogViewModel?

    // Toast state
    @State private var showSuccessToast = false
    @State private var successMessage: String?

    var body: some View {
        NavigationStack {
            List {
                // PHASE_4: Quick Play section (Recordings)

                Section("Recent Cravings") {
                    CravingListView(viewModel: cravingListViewModel)
                }

                Section("Recent Usage") {
                    UsageListView(viewModel: usageListViewModel)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Cannabis Logs")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Log Craving") {
                            cravingLogViewModel = container.makeCravingLogViewModel()
                            showCravingLogSheet = true
                        }
                        Button("Log Usage") {
                            usageLogViewModel = container.makeUsageLogViewModel()
                            showUsageLogSheet = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .accessibilityIdentifier("addButton")
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
                    await cravingListViewModel.fetchCravings()
                }

                // Show success toast if craving was logged (UX_FLOW:396-405)
                if didSucceed {
                    successMessage = "Craving logged"
                    showSuccessToast = true
                }
            } content: {
                if let viewModel = cravingLogViewModel { CravingLogForm(viewModel: viewModel) }
            }

            // MARK: - Usage Log Sheet

            .sheet(isPresented: $showUsageLogSheet) {
                // Detect if success occurred before reset
                let didSucceed = usageLogViewModel?.didSucceed ?? false

                // Reset form state when sheet dismisses
                usageLogViewModel = nil

                // Refresh list after logging
                Task {
                    await usageListViewModel.fetchUsage()
                }

                // Show success toast if usage was logged (UX_FLOW:396-405)
                if didSucceed {
                    successMessage = "Usage logged"
                    showSuccessToast = true
                }
            } content: {
                if let viewModel = usageLogViewModel { UsageLogForm(viewModel: viewModel) }
            }

            // MARK: - Success Toast

            .overlay(alignment: .top) {
                // Success toast (appears AFTER sheet dismisses per UX_FLOW:396-405)
                if showSuccessToast {
                    VStack {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                // iOS 17+ symbol effect - bounce on appear
                                .symbolEffect(.bounce, value: showSuccessToast)
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
                        do {
                            try await Task.sleep(for: .seconds(2))
                        } catch {
                            // Task cancelled (e.g., view disappeared) — safe to ignore
                        }
                        showSuccessToast = false
                    }
                }
            }
            // iOS 17+ declarative haptics for success toast
            .sensoryFeedback(.success, trigger: showSuccessToast)
        }
    }
}

#Preview {
    let container = DependencyContainer.preview

    HomeView()
        .environment(container)
        .environment(container.makeCravingListViewModel())
        .environment(container.makeUsageListViewModel())
}
