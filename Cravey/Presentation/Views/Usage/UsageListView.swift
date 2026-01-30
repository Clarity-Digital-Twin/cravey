import SwiftUI

/// Usage history list view (Phase 2C)
/// Displays all logged usage entries
/// Source: PHASE_2C.md lines 482-592
struct UsageListView: View {
    @Bindable var viewModel: UsageListViewModel

    @State private var usageToDelete: UsageEntity?
    @State private var deleteHapticTrigger = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if viewModel.usageList.isEmpty {
                emptyStateView
            } else {
                usageListView
            }
        }
        .task {
            await viewModel.fetchUsage()
        }
        .animation(.default, value: viewModel.usageList)
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .sensoryFeedback(.warning, trigger: deleteHapticTrigger)
        .confirmationDialog(
            "Delete Usage Log?",
            isPresented: Binding(
                get: { usageToDelete != nil },
                set: { if !$0 { usageToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                guard let usageToDelete else { return }
                self.usageToDelete = nil
                Task {
                    await viewModel.deleteUsage(id: usageToDelete.id)
                }
            }
            Button("Cancel", role: .cancel) {
                usageToDelete = nil
            }
        } message: {
            Text("This cannot be undone.")
        }
    }

    // MARK: - Loading View

    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading usage history...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .listRowBackground(Color.clear)
    }

    // MARK: - Empty State View

    @ViewBuilder
    private var emptyStateView: some View {
        UsageEmptyStateView()
            .listRowBackground(Color.clear)
    }

    // MARK: - Usage List View

    @ViewBuilder
    private var usageListView: some View {
        ForEach(viewModel.usageList) { usage in
            UsageRowView(usage: usage)
                .accessibilityIdentifier("usageEntryRow")
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        deleteHapticTrigger.toggle()
                        usageToDelete = usage
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
    }
}

/// Empty state for usage list with animated symbol
private struct UsageEmptyStateView: View {
    @State private var animateSymbol = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                // iOS 17+ symbol effect - gentle pulse to draw attention
                .symbolEffect(.pulse, options: .repeating.speed(0.5), value: animateSymbol)

            Text("No Usage Logged")
                .font(.headline)

            Text("Your usage history will appear here once you start logging.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .onAppear {
            animateSymbol = true
        }
    }
}

// MARK: - Usage Row View

/// Individual row for usage entry
/// Displays timestamp, method, amount, and optional metadata
struct UsageRowView: View {
    let usage: UsageEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Method + Amount
            HStack {
                Text(usage.method)
                    .font(.headline)

                Spacer()

                Text(ROAAmountRange.displayAmount(method: usage.method, amount: usage.amount))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Timestamp
            Text(usage.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Optional metadata (triggers, location, notes)
            if !usage.triggers.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text(usage.triggers.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let location = usage.location {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                    Text(LocationOptions.displayLocation(location))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let notes = usage.notes, !notes.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "note.text")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Previews

#Preview("Empty State") {
    @Previewable @State var viewModel = UsageListViewModel(
        fetchUsageUseCase: PreviewMockFetchUsageUseCase(returnEmpty: true),
        deleteUsageUseCase: PreviewMockDeleteUsageUseCase()
    )

    UsageListView(viewModel: viewModel)
}

#Preview("Loading State") {
    @Previewable @State var viewModel = UsageListViewModel(
        fetchUsageUseCase: PreviewMockFetchUsageUseCase(simulateLoading: true),
        deleteUsageUseCase: PreviewMockDeleteUsageUseCase()
    )

    UsageListView(viewModel: viewModel)
}

#Preview("Populated List") {
    @Previewable @State var viewModel = UsageListViewModel(
        fetchUsageUseCase: PreviewMockFetchUsageUseCase(),
        deleteUsageUseCase: PreviewMockDeleteUsageUseCase()
    )

    UsageListView(viewModel: viewModel)
}

#Preview("Usage Row - Full Metadata") {
    UsageRowView(usage: UsageEntity(
        id: UUID(),
        timestamp: Date(),
        method: "Vape",
        amount: 5.0,
        triggers: ["Anxious", "Bored"],
        location: "Home",
        notes: "Felt stressed after work meeting. Needed to relax."
    ))
    .padding()
}

#Preview("Usage Row - Minimal") {
    UsageRowView(usage: UsageEntity(
        timestamp: Date(),
        method: "Bowls",
        amount: 2.5
    ))
    .padding()
}

// MARK: - Preview Mock

actor PreviewMockFetchUsageUseCase: FetchUsageUseCase {
    let returnEmpty: Bool
    let simulateLoading: Bool

    init(returnEmpty: Bool = false, simulateLoading: Bool = false) {
        self.returnEmpty = returnEmpty
        self.simulateLoading = simulateLoading
    }

    func execute() async throws -> [UsageEntity] {
        if simulateLoading {
            try await Task.sleep(for: .seconds(2)) // Simulate loading for preview
        }

        if returnEmpty { return [] }

        return [
            UsageEntity(
                timestamp: Date(),
                method: "Vape",
                amount: 5.0,
                triggers: ["Anxious", "Bored"],
                location: "Home",
                notes: "Felt anxious after work. Needed to decompress."
            ),
            UsageEntity(
                timestamp: Date().addingTimeInterval(-3600),
                method: "Bowls",
                amount: 2.5,
                triggers: ["Bored"],
                location: "Outside",
                notes: nil
            ),
            UsageEntity(
                timestamp: Date().addingTimeInterval(-7200),
                method: "Edible",
                amount: 25.0,
                triggers: ["Social"],
                location: "Social",
                notes: "At friend's party. Everyone was partaking."
            ),
            UsageEntity(
                timestamp: Date().addingTimeInterval(-86400),
                method: "Dab",
                amount: 2.0,
                triggers: ["Habit"],
                location: "Home",
                notes: nil
            ),
        ]
    }

    func execute(since _: Date) async throws -> [UsageEntity] {
        try await execute()
    }
}

actor PreviewMockDeleteUsageUseCase: DeleteUsageUseCase {
    func execute(id _: UUID) async throws {}
}
