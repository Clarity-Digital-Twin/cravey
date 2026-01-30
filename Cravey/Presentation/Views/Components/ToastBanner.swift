import SwiftUI

/// Reusable success/info toast banner with auto-dismiss
/// DEBT-042: Extracted from LogView and SettingsView
struct ToastBanner: View {
    let systemImage: String
    let text: String
    @Binding var isPresented: Bool
    var duration: Duration = UIConstants.toastDisplayDuration
    var accessibilityId: String?

    var body: some View {
        if isPresented {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: isPresented)
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.spring(duration: 0.3), value: isPresented)
            .accessibilityIdentifier(accessibilityId ?? "toastBanner")
            .task {
                do {
                    try await Task.sleep(for: duration)
                } catch {
                    // Task cancelled - view dismissed early
                }
                isPresented = false
            }
        }
    }
}

#Preview("Success Toast") {
    @Previewable @State var showToast = true

    VStack {
        ToastBanner(
            systemImage: "checkmark.circle.fill",
            text: "Craving logged",
            isPresented: $showToast,
            accessibilityId: "successToast"
        )
        Spacer()

        Button("Show Toast") {
            showToast = true
        }
    }
}
