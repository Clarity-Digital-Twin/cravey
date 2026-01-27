import SwiftUI

/// Log tab - quick actions for logging cravings and usage.
/// Presentation layer - Clean Architecture
struct LogView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(CravingListViewModel.self) private var cravingListViewModel
    @Environment(UsageListViewModel.self) private var usageListViewModel

    @State private var showCravingSheet = false
    @State private var showUsageSheet = false

    // Fresh form VMs per presentation
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
                        cravingLogViewModel = container.makeCravingLogViewModel()
                        showCravingSheet = true
                    }

                    LogActionCard(
                        title: "Log Usage",
                        subtitle: "Record cannabis consumption",
                        systemImage: "leaf.fill",
                        tint: .green,
                        accessibilityIdentifier: "logUsageButton"
                    ) {
                        usageLogViewModel = container.makeUsageLogViewModel()
                        showUsageSheet = true
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("Log Entry")

            // MARK: - Craving Log Sheet

            .sheet(isPresented: $showCravingSheet) {
                let didSucceed = cravingLogViewModel?.didSucceed ?? false

                cravingLogViewModel = nil

                Task {
                    await cravingListViewModel.fetchCravings()
                }

                if didSucceed {
                    successMessage = "Craving logged"
                    showSuccessToast = true
                }
            } content: {
                if let viewModel = cravingLogViewModel {
                    CravingLogForm(viewModel: viewModel)
                }
            }

            // MARK: - Usage Log Sheet

            .sheet(isPresented: $showUsageSheet) {
                let didSucceed = usageLogViewModel?.didSucceed ?? false

                usageLogViewModel = nil

                Task {
                    await usageListViewModel.fetchUsage()
                }

                if didSucceed {
                    successMessage = "Usage logged"
                    showSuccessToast = true
                }
            } content: {
                if let viewModel = usageLogViewModel {
                    UsageLogForm(viewModel: viewModel)
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
    let action: @MainActor () -> Void

    var body: some View {
        Button {
            action()
        } label: {
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
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

#Preview {
    let container = DependencyContainer.preview

    LogView()
        .environment(container)
        .environment(container.makeCravingListViewModel())
        .environment(container.makeUsageListViewModel())
}
