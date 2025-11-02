import SwiftUI

/// Chip selector component (multi-select or single-select)
/// Presentation layer - reusable component
struct ChipSelector: View {
    let title: String
    let options: [String]
    @Binding var selectedValues: Set<String>
    let multiSelect: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    ChipButton(
                        title: option,
                        isSelected: selectedValues.contains(option),
                        action: {
                            toggleSelection(option)
                        }
                    )
                }
            }
        }
    }

    private func toggleSelection(_ option: String) {
        if multiSelect {
            if selectedValues.contains(option) {
                selectedValues.remove(option)
            } else {
                selectedValues.insert(option)
            }
        } else {
            // Single-select: replace selection
            if selectedValues.contains(option) {
                selectedValues.remove(option)
            } else {
                selectedValues = [option]
            }
        }
    }
}

/// Individual chip button
struct ChipButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

/// Flow layout that wraps chips to next line
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.maxHeight + spacing }
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var yPosition = bounds.minY

        for row in rows {
            var xPosition = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: xPosition, y: yPosition), proposal: .unspecified)
                xPosition += size.width + spacing
            }
            yPosition += row.maxHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = [Row()]
        var currentRowWidth: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)

            // Start new row if current row would overflow
            if currentRowWidth + size.width > maxWidth && !rows[rows.count - 1].indices.isEmpty {
                rows.append(Row())
                currentRowWidth = 0
            }

            rows[rows.count - 1].indices.append(index)
            rows[rows.count - 1].maxHeight = max(rows[rows.count - 1].maxHeight, size.height)
            currentRowWidth += size.width + spacing
        }

        return rows
    }

    struct Row {
        var indices: [Int] = []
        var maxHeight: CGFloat = 0
    }
}

#Preview("Multi-Select") {
    @Previewable @State var selectedTriggers: Set<String> = ["Anxious", "Stressed"]

    VStack {
        ChipSelector(
            title: "What triggered this?",
            options: ["Anxious", "Bored", "Stressed", "Social", "Celebratory", "Habit"],
            selectedValues: $selectedTriggers,
            multiSelect: true
        )
        .padding()

        Text("Selected: \(selectedTriggers.sorted().joined(separator: ", "))")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

#Preview("Single-Select") {
    @Previewable @State var selectedLocation: Set<String> = ["Home"]

    VStack {
        ChipSelector(
            title: "Where are you?",
            options: ["Home", "Work", "Social Gathering", "Outdoors", "Vehicle", "Other"],
            selectedValues: $selectedLocation,
            multiSelect: false
        )
        .padding()

        Text("Selected: \(selectedLocation.first ?? "None")")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
