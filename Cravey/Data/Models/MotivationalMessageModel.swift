import Foundation
import SwiftData

/// SwiftData persistence model for MotivationalMessage
/// Data layer only - never exposed to Domain or Presentation
@Model
final class MotivationalMessageModel {
    var id: UUID
    var createdAt: Date
    var category: String  // Store as String for SwiftData
    var content: String
    var isActive: Bool
    var isUserCreated: Bool
    var displayPriority: Int
    var timesShown: Int
    var lastShownAt: Date?
    var wasHelpful: Bool?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        category: String,
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
