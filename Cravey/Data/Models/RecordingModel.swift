import Foundation
import SwiftData

/// SwiftData persistence model for Recording
/// Data layer only - never exposed to Domain or Presentation
@Model
final class RecordingModel {
    var id: UUID
    var createdAt: Date
    var recordingType: String  // Store as String for SwiftData
    var purpose: String
    var title: String
    var notes: String?
    var fileURL: String
    var duration: TimeInterval
    var thumbnailURL: String?
    var lastPlayedAt: Date?
    var playCount: Int

    // Relationships
    var craving: CravingModel?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        recordingType: String,
        purpose: String,
        title: String,
        fileURL: String,
        duration: TimeInterval = 0,
        notes: String? = nil,
        thumbnailURL: String? = nil,
        lastPlayedAt: Date? = nil,
        playCount: Int = 0
    ) {
        self.id = id
        self.createdAt = createdAt
        self.recordingType = recordingType
        self.purpose = purpose
        self.title = title
        self.fileURL = fileURL
        self.duration = duration
        self.notes = notes
        self.thumbnailURL = thumbnailURL
        self.lastPlayedAt = lastPlayedAt
        self.playCount = playCount
    }
}
