import Foundation
import SwiftData

/// SwiftData persistence model for MotivationalMessage
/// Data layer only - never exposed to Domain or Presentation
@Model
final class MotivationalMessageModel {
    @Attribute(.unique) var id: UUID
    var content: String
    var category: String // Store as String for SwiftData ("urge", "anxiety", ...)

    var isCustom: Bool = false
    var priority: Int = 0
    var timesShown: Int = 0
    var lastShownAt: Date?
    var isActive: Bool = true

    var createdAt: Date = Date()
    var modifiedAt: Date?

    init(
        id: UUID = UUID(),
        content: String,
        category: String,
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
