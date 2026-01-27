import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    var onComplete: (@MainActor @Sendable (Bool) -> Void)?

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, completed, _, _ in
            guard let onComplete else { return }
            Task { @MainActor in
                onComplete(completed)
            }
        }
        return controller
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
