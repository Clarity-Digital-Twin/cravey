import Foundation
import SwiftData

/// SwiftData persistence model for Recording
/// Data layer only - never exposed to Domain or Presentation
@Model
final class RecordingModel {
    @Attribute(.unique) var id: UUID
    var timestamp: Date = Date()
    var type: String = "audio" // Store as String for SwiftData ("video" or "audio")
    var purpose: String = "motivational"
    var duration: TimeInterval = 0
    var filePath: String = "" // Relative path
    var thumbnailPath: String?
    var title: String?
    var notes: String?
    var playCount: Int = 0
    var lastPlayedAt: Date?
    var createdAt: Date = Date()
    var modifiedAt: Date?

    // Relationship (one-to-many: one recording can be linked from many cravings)
    @Relationship(deleteRule: .nullify)
    var linkedCravings: [CravingModel] = []

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        type: String,
        purpose: String,
        duration: TimeInterval,
        filePath: String,
        thumbnailPath: String? = nil,
        title: String? = nil,
        notes: String? = nil,
        lastPlayedAt: Date? = nil,
        playCount: Int = 0,
        createdAt: Date = Date(),
        modifiedAt: Date? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.purpose = purpose
        self.title = title
        self.duration = duration
        self.filePath = filePath
        self.notes = notes
        self.lastPlayedAt = lastPlayedAt
        self.playCount = playCount
        self.thumbnailPath = thumbnailPath
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}
