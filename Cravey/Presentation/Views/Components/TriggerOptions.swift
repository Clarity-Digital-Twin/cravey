import Foundation

/// Static trigger options for craving logging
/// HAALT Model (evidence-based relapse prevention framework)
/// Source: CLINICAL_CANNABIS_SPEC.md lines 196-198
enum TriggerOptions {
    /// Primary triggers (HAALT framework)
    static let primary: [String] = [
        "Hungry",
        "Angry",
        "Anxious",
        "Lonely",
        "Tired",
        "Sad",
    ]

    /// Secondary triggers (contextual/environmental)
    static let secondary: [String] = [
        "Bored",
        "Social",
        "Habit",
        "Paraphernalia",
    ]

    /// All triggers (primary + secondary)
    static let all: [String] = primary + secondary
}
