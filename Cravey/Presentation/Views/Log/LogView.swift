import SwiftUI

/// Log tab - quick actions for logging cravings and usage.
/// Presentation layer - Clean Architecture
struct LogView: View {
    @Environment(\.makeCravingLogViewModel) private var makeCravingLogViewModel
    @Environment(\.makeUsageLogViewModel) private var makeUsageLogViewModel
    @Environment(CravingListViewModel.self) private var cravingListViewModel
    @Environment(UsageListViewModel.self) private var usageListViewModel

    // Fresh form VMs per presentation (nil = sheet closed, non-nil = sheet open)
    @State private var cravingLogViewModel: CravingLogViewModel?
    @State private var usageLogViewModel: UsageLogViewModel?

    // Toast state
    @State private var showSuccessToast = false
    @State private var successMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer(minLength: 24)

                Text("What would you like to log?")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 16) {
                    LogActionCard(
                        title: "Log Craving",
                        subtitle: "Track an urge you experienced",
                        systemImage: "brain.head.profile",
                        tint: .purple,
                        accessibilityIdentifier: "logCravingButton"
                    ) {
                        cravingLogViewModel = makeCravingLogViewModel()
                    }

                    LogActionCard(
                        title: "Log Usage",
                        subtitle: "Record cannabis consumption",
                        systemImage: "leaf.fill",
                        tint: .green,
                        accessibilityIdentifier: "logUsageButton"
                    ) {
                        usageLogViewModel = makeUsageLogViewModel()
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("Log Entry")

            // MARK: - Craving Log Sheet

            .sheet(item: $cravingLogViewModel) { viewModel in
                CravingLogForm(viewModel: viewModel)
                    .onDisappear {
                        if viewModel.didSucceed {
                            successMessage = "Craving logged"
                            showSuccessToast = true
                            Task {
                                await cravingListViewModel.fetchCravings()
                            }
                        }
                    }
            }

            // MARK: - Usage Log Sheet

            .sheet(item: $usageLogViewModel) { viewModel in
                UsageLogForm(viewModel: viewModel)
                    .onDisappear {
                        if viewModel.didSucceed {
                            successMessage = "Usage logged"
                            showSuccessToast = true
                            Task {
                                await usageListViewModel.fetchUsage()
                            }
                        }
                    }
            }

            // MARK: - Success Toast

            .overlay(alignment: .top) {
                if showSuccessToast {
                    VStack {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .symbolEffect(.bounce, value: showSuccessToast)

                            Text(successMessage ?? "Logged")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .accessibilityIdentifier("successToast")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        .padding(.top, 8)

                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(duration: 0.3), value: showSuccessToast)
                    .task {
                        do {
                            try await Task.sleep(for: .seconds(2))
                        } catch {
                            // Task cancelled — safe to ignore
                        }
                        showSuccessToast = false
                    }
                }
            }
            .sensoryFeedback(.success, trigger: showSuccessToast)
        }
    }
}

private struct LogActionCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
    let accessibilityIdentifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.system(size: 28))
                    .foregroundStyle(tint)
                    .frame(width: 48, height: 48)
                    .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

#Preview {
    let container = DependencyContainer.preview

    LogView()
        .environment(container)
        .environment(\.makeCravingLogViewModel, container.makeCravingLogViewModel)
        .environment(\.makeUsageLogViewModel, container.makeUsageLogViewModel)
        .environment(container.makeCravingListViewModel())
        .environment(container.makeUsageListViewModel())
}
