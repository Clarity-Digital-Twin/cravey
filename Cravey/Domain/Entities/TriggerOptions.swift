/// Static trigger options for craving/usage logging.
/// Based on HAALT framework with additional emotional states
/// Source: CLINICAL_CANNABIS_SPEC.md lines 196-198
enum TriggerOptions {
    /// Primary triggers - Row 1: HALT (Hungry, Angry, Lonely, Tired)
    static let primaryHALT: [String] = [
        "Hungry",
        "Angry",
        "Lonely",
        "Tired",
    ]

    /// Primary triggers - Row 2: Additional emotional states
    static let primaryOther: [String] = [
        "Sad",
        "Anxious",
        "Bored",
    ]

    /// All primary triggers (for backwards compat)
    static let primary: [String] = primaryHALT + primaryOther

    /// Secondary triggers (contextual/environmental)
    static let secondary: [String] = [
        "Habit",
        "Social",
        "Paraphernalia",
    ]

    /// All triggers (primary + secondary)
    static let all: [String] = primary + secondary
}
