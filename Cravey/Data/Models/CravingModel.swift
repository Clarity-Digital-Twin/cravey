import Foundation
import SwiftData

/// SwiftData persistence model for Craving
/// Data layer only - never exposed to Domain or Presentation
@Model
final class CravingModel {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var intensity: Int
    var triggers: [String]
    var location: String?
    var notes: String?
    var createdAt: Date
    var modifiedAt: Date?

    // Relationship (many-to-one: many cravings can reference one recording)
    @Relationship(deleteRule: .nullify, inverse: \RecordingModel.linkedCravings)
    var recording: RecordingModel?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        intensity: Int,
        triggers: [String] = [],
        location: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.intensity = intensity
        self.triggers = triggers
        self.location = location
        self.notes = notes
        createdAt = Date()
        modifiedAt = nil
        recording = nil
    }
}
