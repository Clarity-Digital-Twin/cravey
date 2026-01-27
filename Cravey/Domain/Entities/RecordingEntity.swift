import Foundation

/// Domain entity representing an audio/video recording
/// Pure Swift - no framework dependencies
struct RecordingEntity: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: UUID
    let timestamp: Date
    let type: RecordingType
    let purpose: RecordingPurpose
    let duration: TimeInterval
    let filePath: String // Relative path (e.g., "Recordings/video_UUID.mov")
    let thumbnailPath: String? // Relative path (e.g., "Recordings/Thumbnails/video_UUID_thumb.jpg")
    let title: String?
    let notes: String?

    let lastPlayedAt: Date?
    let playCount: Int
    let createdAt: Date
    let modifiedAt: Date?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        type: RecordingType,
        purpose: RecordingPurpose,
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
        self.filePath = filePath
        self.duration = duration
        self.notes = notes
        self.thumbnailPath = thumbnailPath
        self.lastPlayedAt = lastPlayedAt
        self.playCount = playCount
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

enum RecordingType: String, Codable, CaseIterable, Sendable {
    case video
    case audio
    case unknown

    var fileExtension: String {
        switch self {
        case .video:
            "mov"
        case .audio:
            "m4a"
        case .unknown:
            "dat"
        }
    }
}

enum RecordingPurpose: String, Codable, CaseIterable, Sendable {
    case motivational
    case milestone
    case reflection
    case craving
    case unknown
}

// MARK: - Business Logic

extension RecordingEntity {
    var durationFormatted: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func incrementPlayCount(now: Date = Date()) -> RecordingEntity {
        RecordingEntity(
            id: id,
            timestamp: timestamp,
            type: type,
            purpose: purpose,
            duration: duration,
            filePath: filePath,
            thumbnailPath: thumbnailPath,
            title: title,
            notes: notes,
            lastPlayedAt: now,
            playCount: playCount + 1,
            createdAt: createdAt,
            modifiedAt: now
        )
    }
}
