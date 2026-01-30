import Foundation

/// UI timing and layout constants.
/// Single source of truth for UI-related magic numbers.
enum UIConstants {
    /// Duration to display toast/banner messages before auto-dismiss.
    /// Source: UX_FLOW.md line 400
    static let toastDisplayDuration: Duration = .seconds(2)
}
