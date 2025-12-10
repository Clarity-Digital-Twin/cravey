import SwiftUI

/// Craving list view - displays all cravings
/// Presentation layer - Clean Architecture
struct CravingListView: View {
    @Bindable var viewModel: CravingListViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else if viewModel.cravings.isEmpty {
                EmptyStatePlaceholder()
            } else {
                // Use LazyVStack instead of List for embedding in ScrollView
                // List has internal scrolling that conflicts with parent ScrollView
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.cravings) { craving in
                        CravingRow(craving: craving)
                            .padding(.horizontal)
                        Divider()
                            .padding(.leading)
                    }
                }
            }
        }
        .task {
            await viewModel.fetchCravings()
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
        switch intensity {
        case 1 ... 3: return .green
        case 4 ... 6: return .yellow
        case 7 ... 8: return .orange
        case 9 ... 10: return .red
        default: return .gray
        }
    }
}

/// Empty state placeholder
struct EmptyStatePlaceholder: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Cravings Logged")
                .font(.headline)

            Text("Tap + to log your first craving")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview("With Cravings") {
    @Previewable @State var viewModel: CravingListViewModel = {
        let container = DependencyContainer.preview
        let listViewModel = CravingListViewModel(fetchCravingsUseCase: container.fetchCravingsUseCase)
        return listViewModel
    }()

    CravingListView(viewModel: viewModel)
}

#Preview("Empty State") {
    EmptyStatePlaceholder()
}
