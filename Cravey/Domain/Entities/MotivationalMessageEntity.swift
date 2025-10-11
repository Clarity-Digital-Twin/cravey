import Foundation

/// Domain entity representing a motivational message
/// Pure Swift - no framework dependencies
struct MotivationalMessageEntity: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let createdAt: Date
    let category: MessageCategory
    let content: String
    let isActive: Bool
    let isUserCreated: Bool
    let displayPriority: Int
    let timesShown: Int
    let lastShownAt: Date?
    let wasHelpful: Bool?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        category: MessageCategory,
        content: String,
        isActive: Bool = true,
        isUserCreated: Bool = false,
        displayPriority: Int = 5,
        timesShown: Int = 0,
        lastShownAt: Date? = nil,
        wasHelpful: Bool? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.category = category
        self.content = content
        self.isActive = isActive
        self.isUserCreated = isUserCreated
        self.displayPriority = displayPriority
        self.timesShown = timesShown
        self.lastShownAt = lastShownAt
        self.wasHelpful = wasHelpful
    }
}

enum MessageCategory: String, Codable, CaseIterable {
    case urgeManagement = "Urge Management"
    case selfCompassion = "Self-Compassion"
    case progressReminder = "Progress Reminder"
    case healthBenefits = "Health Benefits"
    case copingStrategies = "Coping Strategies"
    case personalReason = "Personal Reason"
}

// MARK: - Business Logic
extension MotivationalMessageEntity {
    func markAsShown() -> MotivationalMessageEntity {
        MotivationalMessageEntity(
            id: id,
            createdAt: createdAt,
            category: category,
            content: content,
            isActive: isActive,
            isUserCreated: isUserCreated,
            displayPriority: displayPriority,
            timesShown: timesShown + 1,
            lastShownAt: Date(),
            wasHelpful: wasHelpful
        )
    }

    func withFeedback(_ helpful: Bool) -> MotivationalMessageEntity {
        MotivationalMessageEntity(
            id: id,
            createdAt: createdAt,
            category: category,
            content: content,
            isActive: isActive,
            isUserCreated: isUserCreated,
            displayPriority: displayPriority,
            timesShown: timesShown,
            lastShownAt: lastShownAt,
            wasHelpful: helpful
        )
    }

    static var defaultMessages: [MotivationalMessageEntity] {
        [
            MotivationalMessageEntity(
                category: .urgeManagement,
                content: "This craving will pass in 10-15 minutes. You've got this.",
                displayPriority: 10
            ),
            MotivationalMessageEntity(
                category: .urgeManagement,
                content: "Ride the wave. Cravings peak and then subside. You're stronger than this urge.",
                displayPriority: 10
            ),
            MotivationalMessageEntity(
                category: .selfCompassion,
                content: "Be kind to yourself. Recovery is a journey, not a destination.",
                displayPriority: 8
            ),
            MotivationalMessageEntity(
                category: .healthBenefits,
                content: "Your body is healing. Your mind is clearing. Keep going.",
                displayPriority: 7
            ),
            MotivationalMessageEntity(
                category: .copingStrategies,
                content: "Try: Deep breathing, call a friend, go for a walk, listen to your recording.",
                displayPriority: 9
            ),
            MotivationalMessageEntity(
                category: .progressReminder,
                content: "Look how far you've come. Don't let one moment erase all your progress.",
                displayPriority: 9
            )
        ]
    }
}
