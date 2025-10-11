import Foundation

/// Domain entity representing an audio/video recording
/// Pure Swift - no framework dependencies
struct RecordingEntity: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let createdAt: Date
    let recordingType: RecordingType
    let purpose: RecordingPurpose
    let title: String
    let notes: String?
    let fileURL: String  // Relative path
    let duration: TimeInterval
    let thumbnailURL: String?
    let lastPlayedAt: Date?
    let playCount: Int

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        recordingType: RecordingType,
        purpose: RecordingPurpose,
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

enum RecordingType: String, Codable, CaseIterable {
    case video = "Video"
    case audio = "Audio"

    var fileExtension: String {
        switch self {
        case .video: return "mov"
        case .audio: return "m4a"
        }
    }
}

enum RecordingPurpose: String, Codable, CaseIterable {
    case motivational = "Motivational"
    case cravingMoment = "Craving Moment"
    case reflection = "Reflection"
    case milestone = "Milestone"
}

// MARK: - Business Logic
extension RecordingEntity {
    var durationFormatted: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func incrementPlayCount() -> RecordingEntity {
        RecordingEntity(
            id: id,
            createdAt: createdAt,
            recordingType: recordingType,
            purpose: purpose,
            title: title,
            fileURL: fileURL,
            duration: duration,
            notes: notes,
            thumbnailURL: thumbnailURL,
            lastPlayedAt: Date(),
            playCount: playCount + 1
        )
    }
}
