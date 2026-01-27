import SwiftUI

/// History tab - browse cravings and usage logs.
/// Presentation layer - Clean Architecture
struct HistoryView: View {
    enum HistorySegment: String, CaseIterable, Identifiable {
        case cravings = "Cravings"
        case usage = "Usage"

        var id: Self { self }
    }

    @Environment(CravingListViewModel.self) private var cravingListViewModel
    @Environment(UsageListViewModel.self) private var usageListViewModel

    @State private var selectedSegment: HistorySegment = .cravings

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("History Type", selection: $selectedSegment) {
                        ForEach(HistorySegment.allCases) { segment in
                            Text(segment.rawValue)
                                .tag(segment)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("historySegmentPicker")
                }

                Section {
                    switch selectedSegment {
                    case .cravings:
                        CravingListView(viewModel: cravingListViewModel)
                    case .usage:
                        UsageListView(viewModel: usageListViewModel)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("History")
        }
    }
}

#Preview {
    let container = DependencyContainer.preview

    HistoryView()
        .environment(container)
        .environment(container.makeCravingListViewModel())
        .environment(container.makeUsageListViewModel())
}
