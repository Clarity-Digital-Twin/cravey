import SwiftUI

struct AppUnavailableView: View {
    let error: DependencyContainer.StartupFailure?
    let onRetry: (@MainActor () -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Cravey can’t start")
                .font(.title2.bold())

            Text(error?.errorDescription ?? "Cravey couldn’t open its local database.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Text(error?.recoverySuggestion ?? "Try restarting your device and try again.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            #if DEBUG
                if let error {
                    DisclosureGroup("Technical Details") {
                        Text(
                            """
                            Persistent: \(error.persistentErrorDescription)
                            In-Memory: \(error.inMemoryErrorDescription)
                            """
                        )
                        .font(.footnote.monospaced())
                        .textSelection(.enabled)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                    }
                    .padding(.top, 8)
                }
            #endif

            if let onRetry {
                Button("Try Again") {
                    onRetry()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
                .accessibilityIdentifier("appUnavailableRetryButton")
            }
        }
        .padding()
        .accessibilityIdentifier("appUnavailableView")
    }
}

#Preview {
    AppUnavailableView(
        error: DependencyContainer.StartupFailure(
            persistentErrorDescription: "Disk full",
            inMemoryErrorDescription: "Schema invalid"
        ),
        onRetry: nil
    )
}
