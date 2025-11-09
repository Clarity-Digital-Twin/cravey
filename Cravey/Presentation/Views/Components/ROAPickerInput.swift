import SwiftUI

/// ROA-aware amount picker that dynamically adjusts range based on selected method
/// Source: CLINICAL_CANNABIS_SPEC.md lines 220-224
struct ROAPickerInput: View {
    /// The currently selected ROA method (e.g., "Bowls", "Vape")
    let selectedMethod: String

    /// The selected amount (binding to parent's state)
    @Binding var amount: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            Text("Amount")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Picker (wheel style for fast selection)
            Picker("Amount", selection: $amount) {
                ForEach(amountOptions, id: \.self) { value in
                    Text(displayText(for: value))
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
            .animation(.easeInOut(duration: 0.1), value: selectedMethod) // Fade animation per UX_FLOW:381
        }
    }

    // MARK: - Private Helpers

    /// Get valid amount options for current method
    /// Uses ROAAmountRange helper from Phase 2A
    private var amountOptions: [Double] {
        ROAAmountRange.range(for: selectedMethod)
    }

    /// Format amount for display in picker
    /// Source: DATA_MODEL_SPEC.md lines 155-165
    private func displayText(for amount: Double) -> String {
        ROAAmountRange.displayAmount(method: selectedMethod, amount: amount)
    }
}

// MARK: - Previews

#Preview("Bowls (10 options)") {
    struct PreviewWrapper: View {
        @State private var amount = 1.0

        var body: some View {
            VStack(spacing: 20) {
                Text("Selected: \(ROAAmountRange.displayAmount(method: "Bowls", amount: amount))")
                    .font(.headline)

                ROAPickerInput(selectedMethod: "Bowls", amount: $amount)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Vape (10 options)") {
    struct PreviewWrapper: View {
        @State private var amount = 1.0

        var body: some View {
            VStack(spacing: 20) {
                Text("Selected: \(ROAAmountRange.displayAmount(method: "Vape", amount: amount))")
                    .font(.headline)

                ROAPickerInput(selectedMethod: "Vape", amount: $amount)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Edible (20 options)") {
    struct PreviewWrapper: View {
        @State private var amount = 5.0

        var body: some View {
            VStack(spacing: 20) {
                Text("Selected: \(ROAAmountRange.displayAmount(method: "Edible", amount: amount))")
                    .font(.headline)

                ROAPickerInput(selectedMethod: "Edible", amount: $amount)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Dynamic Method Switching") {
    struct PreviewWrapper: View {
        @State private var method = "Bowls"
        @State private var amount = 1.0

        var body: some View {
            VStack(spacing: 20) {
                // Method selector
                Picker("Method", selection: $method) {
                    Text("Bowls").tag("Bowls")
                    Text("Vape").tag("Vape")
                    Text("Edible").tag("Edible")
                }
                .pickerStyle(.segmented)
                .onChange(of: method) { _, newMethod in
                    // Reset amount to first valid option when method changes
                    if let firstAmount = ROAAmountRange.range(for: newMethod).first {
                        amount = firstAmount
                    }
                }

                // Amount picker (updates dynamically)
                ROAPickerInput(selectedMethod: method, amount: $amount)

                // Display selected
                Text("Selected: \(ROAAmountRange.displayAmount(method: method, amount: amount))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
