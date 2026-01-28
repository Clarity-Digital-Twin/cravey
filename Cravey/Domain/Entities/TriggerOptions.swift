import Foundation

/// Static trigger options for craving/usage logging.
/// HAALT Model (evidence-based relapse prevention framework)
/// Source: CLINICAL_CANNABIS_SPEC.md lines 196-198
enum TriggerOptions {
    /// Primary triggers (emotional states)
    static let primary: [String] = [
        "Hungry",
        "Angry",
        "Lonely",
        "Tired",
        "Anxious",
        "Bored",
        "Sad",
    ]

    /// Secondary triggers (contextual/environmental)
    static let secondary: [String] = [
        "Social",
        "Habit",
        "Paraphernalia",
    ]

    /// All triggers (primary + secondary)
    static let all: [String] = primary + secondary
}
