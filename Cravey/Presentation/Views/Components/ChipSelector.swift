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
                .foregroundStyle(.secondary)

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

/// Single-select chip selector (no Set allocation per render)
/// Use this instead of ChipSelector with multiSelect: false to avoid
/// creating a new Set on every SwiftUI render cycle
struct SingleSelectChipSelector: View {
    let title: String
    let options: [String]
    @Binding var selectedValue: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    ChipButton(
                        title: option,
                        isSelected: selectedValue == option,
                        action: {
                            selectedValue = option
                        }
                    )
                }
            }
        }
    }
}

/// Optional single-select chip selector (allows no selection)
/// Returns nil when nothing is selected
struct OptionalSingleSelectChipSelector: View {
    let title: String
    let options: [String]
    @Binding var selectedValue: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    ChipButton(
                        title: option,
                        isSelected: selectedValue == option,
                        action: {
                            if selectedValue == option {
                                selectedValue = nil // Deselect
                            } else {
                                selectedValue = option
                            }
                        }
                    )
                }
            }
        }
    }
}

/// Individual chip button
/// iOS 18 fix: Use Text + onTapGesture instead of Button to avoid
/// hit-testing issues in custom Layout containers.
/// See BUG_009_CHIP_SELECTOR.md for full analysis.
struct ChipButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    // Track selection changes for haptic feedback
    @State private var selectionTrigger = false

    var body: some View {
        Text(title)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8) // Increased for better tap target
            .background(
                Group {
                    if isSelected {
                        Color.accentColor
                    } else {
                        // iOS 18+ material background for premium glass feel
                        Capsule()
                            .fill(.ultraThinMaterial)
                    }
                }
            )
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .contentShape(Capsule()) // Ensures full capsule area is tappable
            .onTapGesture {
                selectionTrigger.toggle()
                action()
            }
            // iOS 17+ declarative haptics for selection
            .sensoryFeedback(.selection, trigger: selectionTrigger)
    }
}

/// Flow layout that wraps chips to next line
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.maxHeight + spacing }
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
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
            if currentRowWidth + size.width > maxWidth, !rows[rows.count - 1].indices.isEmpty {
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
