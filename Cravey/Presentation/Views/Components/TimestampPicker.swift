import SwiftUI

/// Timestamp picker component (date + time, no future dates)
/// Presentation layer - reusable component
struct TimestampPicker: View {
    @Binding var date: Date

    var body: some View {
        DatePicker(
            "When did this happen?",
            selection: $date,
            in: ...Date(),  // Can't pick future dates
            displayedComponents: [.date, .hourAndMinute]
        )
        .datePickerStyle(.compact)
    }
}

#Preview {
    @Previewable @State var timestamp: Date = Date()

    VStack {
        TimestampPicker(date: $timestamp)
            .padding()

        Text("Selected: \(timestamp.formatted())")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
