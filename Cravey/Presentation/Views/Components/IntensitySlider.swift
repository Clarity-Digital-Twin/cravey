import SwiftUI

/// Intensity slider component (1-10 scale with emoji feedback)
/// Presentation layer - reusable component
struct IntensitySlider: View {
    @Binding var value: Double

    // Track value changes for haptic feedback
    @State private var hapticTrigger = false
    // Respect reduced motion accessibility setting
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Intensity")
                    .font(.headline)
                Spacer()
                Text(Self.emoji(for: Int(value)))
                    .font(.title)
                    // iOS 17+ symbol-like content transition for smooth emoji swap
                    // (disabled when reduce motion enabled)
                    .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: Int(value))
            }

            HStack {
                Text("1")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                Slider(value: $value, in: 1 ... 10, step: 1)
                    // iOS 15+ gradient tint for visual intensity indication
                    .tint(intensityColor(for: Int(value)))
                Text("10")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }

            Text(Self.formatLabel(for: Int(value)))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
        // iOS 17+ declarative haptics on value change
        .sensoryFeedback(.selection, trigger: hapticTrigger)
        .onChange(of: Int(value)) { oldValue, newValue in
            if oldValue != newValue {
                hapticTrigger.toggle()
            }
        }
    }

    /// Returns intensity-appropriate color using unified scale
    private func intensityColor(for intensity: Int) -> Color {
        IntensityColorScale.color(for: intensity)
    }

    // MARK: - Testable Static Methods

    /// Format intensity label with description
    nonisolated static func formatLabel(for intensity: Int) -> String {
        switch intensity {
        case 1 ... 2:
            "\(intensity) - Very Mild"
        case 3 ... 4:
            "\(intensity) - Mild"
        case 5 ... 6:
            "\(intensity) - Moderate"
        case 7 ... 8:
            "\(intensity) - Strong"
        case 9 ... 10:
            "\(intensity) - Overwhelming"
        default:
            "\(intensity)"
        }
    }

    /// Get emoji for intensity level
    nonisolated static func emoji(for intensity: Int) -> String {
        switch intensity {
        case 1 ... 2:
            "😌"
        case 3 ... 4:
            "🙂"
        case 5 ... 6:
            "😐"
        case 7 ... 8:
            "😟"
        case 9 ... 10:
            "😫"
        default:
            "😐"
        }
    }
}

#Preview {
    @Previewable @State var intensity: Double = 5

    VStack {
        IntensitySlider(value: $intensity)
            .padding()

        Text("Current value: \(Int(intensity))")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
