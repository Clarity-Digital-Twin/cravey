import SwiftUI

/// Generic empty state view with animated symbol (DEBT-030)
/// Replaces duplicated empty state UI in list views
struct EmptyStateView: View {
    let symbolName: String
    let title: String
    let message: String

    @State private var animateSymbol = false

    init(
        symbolName: String = "leaf.circle",
        title: String,
        message: String
    ) {
        self.symbolName = symbolName
        self.title = title
        self.message = message
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: symbolName)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                // iOS 17+ symbol effect - gentle pulse to draw attention
                .symbolEffect(.pulse, options: .repeating.speed(0.5), value: animateSymbol)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .onAppear {
            animateSymbol = true
        }
    }
}

#Preview("No Cravings") {
    EmptyStateView(
        title: "No Cravings Logged",
        message: "Go to the Log tab to log your first craving"
    )
}

#Preview("No Usage") {
    EmptyStateView(
        title: "No Usage Logged",
        message: "Your usage history will appear here once you start logging."
    )
}
