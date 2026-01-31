import SwiftUI

/// Chip selector component (multi-select or single-select)
/// Presentation layer - reusable component
struct ChipSelector: View {
    struct Group: Identifiable {
        let title: String?
        let options: [String]

        var id: String {
            "\(title ?? "ungrouped"):\(options.joined(separator: "|"))"
        }
    }

    let title: String?
    let groups: [Group]
    @Binding var selectedValues: Set<String>
    let multiSelect: Bool

    init(title: String?, options: [String], selectedValues: Binding<Set<String>>, multiSelect: Bool) {
        self.title = title
        groups = [Group(title: nil, options: options)]
        _selectedValues = selectedValues
        self.multiSelect = multiSelect
    }

    init(title: String?, groups: [Group], selectedValues: Binding<Set<String>>, multiSelect: Bool) {
        self.title = title
        self.groups = groups
        _selectedValues = selectedValues
        self.multiSelect = multiSelect
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                ForEach(groups) { group in
                    if let groupTitle = group.title {
                        Text(groupTitle)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    FlowLayout(spacing: 8) {
                        ForEach(group.options, id: \.self) { option in
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
    let title: String?
    let options: [String]
    @Binding var selectedValue: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

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
    let title: String?
    let options: [String]
    @Binding var selectedValue: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

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
/// See docs/_archive/specs/BUG_009_CHIP_SELECTOR_FIXED_2025-01-05.md for full analysis.
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
            .padding(.vertical, 12) // Ensures ≥44pt tap target (Apple HIG requirement)
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
        let height =
            rows.reduce(0) { $0 + $1.maxHeight }
                + max(0, CGFloat(rows.count - 1)) * spacing

        let width = proposal.width ?? {
            let total = subviews.reduce(0) { $0 + $1.sizeThatFits(.unspecified).width }
            return total + max(0, CGFloat(subviews.count - 1)) * spacing
        }()

        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var yPosition = bounds.minY

        for (rowIndex, row) in rows.enumerated() {
            // Calculate row width for centering
            var rowWidth: CGFloat = 0
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                rowWidth += size.width
            }
            rowWidth += CGFloat(max(0, row.indices.count - 1)) * spacing

            // Center the row
            var xPosition = bounds.minX + (bounds.width - rowWidth) / 2

            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: xPosition, y: yPosition), proposal: .unspecified)
                xPosition += size.width + spacing
            }
            yPosition += row.maxHeight
            if rowIndex < rows.count - 1 {
                yPosition += spacing
            }
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = [Row()]
        var currentRowWidth: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)

            // Start new row if current row would overflow
            if let lastRow = rows.last, currentRowWidth + size.width > maxWidth, !lastRow.indices.isEmpty {
                rows.append(Row())
                currentRowWidth = 0
            }

            // Safely update last row
            if let lastIndex = rows.indices.last {
                rows[lastIndex].indices.append(index)
                rows[lastIndex].maxHeight = max(rows[lastIndex].maxHeight, size.height)
            }
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
    @Previewable @State var selectedTriggers: Set<String> = ["Anxious", "Bored"]

    VStack {
        ChipSelector(
            title: "Triggers",
            options: TriggerOptions.all,
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
            title: "Location",
            options: LocationOptions.presets,
            selectedValues: $selectedLocation,
            multiSelect: false
        )
        .padding()

        Text("Selected: \(selectedLocation.first ?? "None")")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
