import SwiftUI

/// Craving list view - displays all cravings
/// Presentation layer - Clean Architecture
struct CravingListView: View {
    @Bindable var viewModel: CravingListViewModel

    @State private var cravingToDelete: CravingEntity?
    @State private var deleteHapticTrigger = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .listRowBackground(Color.clear)
            } else if viewModel.cravings.isEmpty {
                EmptyStatePlaceholder()
                    .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.cravings) { craving in
                    CravingRow(craving: craving)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteHapticTrigger.toggle()
                                cravingToDelete = craving
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .task {
            await viewModel.fetchCravings()
        }
        .animation(.default, value: viewModel.cravings)
        .sensoryFeedback(.warning, trigger: deleteHapticTrigger)
        .confirmationDialog(
            "Delete Craving?",
            isPresented: Binding(
                get: { cravingToDelete != nil },
                set: { if !$0 { cravingToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                guard let cravingToDelete else { return }
                Task {
                    await viewModel.deleteCraving(id: cravingToDelete.id)
                    self.cravingToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                cravingToDelete = nil
            }
        } message: {
            Text("This cannot be undone.")
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

/// Individual craving row component
struct CravingRow: View {
    let craving: CravingEntity

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Intensity Badge
            ZStack {
                Circle()
                    .fill(intensityColor(for: craving.intensity))
                    .frame(width: 40, height: 40)

                Text("\(craving.intensity)")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(craving.timestamp, style: .relative)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if !craving.triggers.isEmpty {
                    Text(craving.triggers.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let notes = craving.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func intensityColor(for intensity: Int) -> Color {
        IntensityColorScale.color(for: intensity)
    }
}

/// Empty state placeholder with animated symbol
struct EmptyStatePlaceholder: View {
    // Trigger symbol animation on appear
    @State private var animateSymbol = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                // iOS 17+ symbol effect - gentle pulse to draw attention
                .symbolEffect(.pulse, options: .repeating.speed(0.5), value: animateSymbol)

            Text("No Cravings Logged")
                .font(.headline)

            Text("Tap + to log your first craving")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .onAppear {
            animateSymbol = true
        }
    }
}

#Preview("With Cravings") {
    @Previewable @State var viewModel: CravingListViewModel = {
        let container = DependencyContainer.preview
        let listViewModel = CravingListViewModel(
            fetchCravingsUseCase: container.fetchCravingsUseCase,
            deleteCravingUseCase: container.deleteCravingUseCase
        )
        return listViewModel
    }()

    CravingListView(viewModel: viewModel)
}

#Preview("Empty State") {
    EmptyStatePlaceholder()
}
