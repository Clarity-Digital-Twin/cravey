import Foundation

/// Validation constants used across Domain and Presentation layers.
/// Single source of truth for validation limits.
enum ValidationLimits {
    /// Maximum characters allowed in notes fields.
    /// Source: DATA_MODEL_SPEC.md lines 122, 275
    static let notesMaxLength = 500

    /// Character count threshold for showing the notes counter.
    /// Counter appears when user approaches the limit.
    /// Source: UX_FLOW.md line 391
    static let notesCounterThreshold = 400
}
