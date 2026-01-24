import Foundation

/// Domain entity representing a motivational message
/// Pure Swift - no framework dependencies
struct MotivationalMessageEntity: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: UUID
    let content: String
    let category: MessageCategory

    let isCustom: Bool
    let priority: Int
    let timesShown: Int
    let lastShownAt: Date?
    let isActive: Bool

    let createdAt: Date
    let modifiedAt: Date?

    init(
        id: UUID = UUID(),
        content: String,
        category: MessageCategory,
        isCustom: Bool = false,
        priority: Int = 0,
        isActive: Bool = true,
        timesShown: Int = 0,
        lastShownAt: Date? = nil,
        createdAt: Date = Date(),
        modifiedAt: Date? = nil
    ) {
        self.id = id
        self.content = content
        self.category = category
        self.isCustom = isCustom
        self.priority = priority
        self.isActive = isActive
        self.timesShown = timesShown
        self.lastShownAt = lastShownAt
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

enum MessageCategory: String, Codable, CaseIterable, Sendable {
    case urge
    case anxiety
    case boredom
    case social
    case celebration
}

// MARK: - Business Logic

extension MotivationalMessageEntity {
    func markAsShown(now: Date = Date()) -> MotivationalMessageEntity {
        MotivationalMessageEntity(
            id: id,
            content: content,
            category: category,
            isCustom: isCustom,
            priority: priority,
            isActive: isActive,
            timesShown: timesShown + 1,
            lastShownAt: now,
            createdAt: createdAt,
            modifiedAt: now
        )
    }

    static var defaultMessages: [MotivationalMessageEntity] {
        [
            MotivationalMessageEntity(
                content: "You’ve resisted before. You can do it again.",
                category: .urge,
                priority: 1
            ),
            MotivationalMessageEntity(
                content: "This craving will pass. They always do.",
                category: .urge,
                priority: 2
            ),
            MotivationalMessageEntity(
                content: "Every moment of resistance is progress.",
                category: .urge,
                priority: 3
            ),
            MotivationalMessageEntity(
                content: "This feeling is temporary. Breathe through it.",
                category: .anxiety,
                priority: 1
            ),
            MotivationalMessageEntity(
                content: "Anxiety is uncomfortable, and you’re safe.",
                category: .anxiety,
                priority: 2
            ),
            MotivationalMessageEntity(
                content: "Boredom isn’t an emergency. Find something else to do for 10 minutes.",
                category: .boredom,
                priority: 1
            ),
            MotivationalMessageEntity(
                content: "This is just boredom, not a need. You’ve got this.",
                category: .boredom,
                priority: 2
            ),
            MotivationalMessageEntity(
                content: "You can have fun without using. You’ve done it before.",
                category: .social,
                priority: 1
            ),
            MotivationalMessageEntity(
                content: "Real friends support your choices.",
                category: .social,
                priority: 2
            ),
            MotivationalMessageEntity(
                content: "You’re making progress. Every day counts.",
                category: .celebration,
                priority: 1
            ),
            MotivationalMessageEntity(
                content: "Look how far you’ve come. Keep going.",
                category: .celebration,
                priority: 2
            ),
        ]
    }
}
