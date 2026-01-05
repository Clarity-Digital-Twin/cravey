import SwiftUI

/// Intensity slider component (1-10 scale with emoji feedback)
/// Presentation layer - reusable component
struct IntensitySlider: View {
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Intensity")
                    .font(.headline)
                Spacer()
                Text(Self.emoji(for: Int(value)))
                    .font(.title)
            }

            HStack {
                Text("1")
                    .foregroundColor(.secondary)
                    .font(.caption)
                Slider(value: $value, in: 1 ... 10, step: 1)
                Text("10")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }

            Text(Self.formatLabel(for: Int(value)))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Testable Static Methods

    /// Format intensity label with description
    static func formatLabel(for intensity: Int) -> String {
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
    static func emoji(for intensity: Int) -> String {
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
