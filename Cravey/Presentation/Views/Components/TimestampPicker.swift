import SwiftUI

/// Timestamp picker component (date + time, no future dates)
/// Presentation layer - reusable component
struct TimestampPicker: View {
    @Binding var date: Date
    let title: String?

    init(title: String? = "When did this happen?", date: Binding<Date>) {
        self.title = title
        _date = date
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            if let title {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            HStack {
                Spacer(minLength: 0)

                DatePicker(
                    "",
                    selection: $date,
                    in: ...Date(), // Can't pick future dates
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .accessibilityLabel(title ?? "Timestamp")

                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    @Previewable @State var timestamp = Date()

    VStack {
        TimestampPicker(date: $timestamp)
            .padding()

        Text("Selected: \(timestamp.formatted())")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
