import Foundation

/// Static trigger options for craving/usage logging.
/// Based on HAALT framework with additional emotional states
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
