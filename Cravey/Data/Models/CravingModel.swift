import Foundation
import SwiftData

/// SwiftData persistence model for Craving
/// Data layer only - never exposed to Domain or Presentation
@Model
final class CravingModel {
    var id: UUID
    var timestamp: Date
    var intensity: Int
    var duration: TimeInterval?
    var triggers: [String]
    var notes: String?
    var location: String?
    var managementStrategy: String?
    var wasManagedSuccessfully: Bool

    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \RecordingModel.craving)
    var recordings: [RecordingModel]

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        intensity: Int,
        duration: TimeInterval? = nil,
        triggers: [String] = [],
        notes: String? = nil,
        location: String? = nil,
        managementStrategy: String? = nil,
        wasManagedSuccessfully: Bool = false
    ) {
        self.id = id
        self.timestamp = timestamp
        self.intensity = intensity
        self.duration = duration
        self.triggers = triggers
        self.notes = notes
        self.location = location
        self.managementStrategy = managementStrategy
        self.wasManagedSuccessfully = wasManagedSuccessfully
        self.recordings = []
    }
}
