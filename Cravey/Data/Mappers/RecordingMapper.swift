import Foundation

/// Mapper between RecordingEntity (Domain) and RecordingModel (Data/SwiftData)
enum RecordingMapper {
    /// Convert Domain Entity → SwiftData Model
    static func toModel(_ entity: RecordingEntity) -> RecordingModel {
        RecordingModel(
            id: entity.id,
            createdAt: entity.createdAt,
            recordingType: entity.recordingType.rawValue,
            purpose: entity.purpose.rawValue,
            title: entity.title,
            fileURL: entity.fileURL,
            duration: entity.duration,
            notes: entity.notes,
            thumbnailURL: entity.thumbnailURL,
            lastPlayedAt: entity.lastPlayedAt,
            playCount: entity.playCount
        )
    }

    /// Convert SwiftData Model → Domain Entity
    static func toEntity(_ model: RecordingModel) -> RecordingEntity {
        RecordingEntity(
            id: model.id,
            createdAt: model.createdAt,
            recordingType: RecordingType(rawValue: model.recordingType) ?? .audio,
            purpose: RecordingPurpose(rawValue: model.purpose) ?? .motivational,
            title: model.title,
            fileURL: model.fileURL,
            duration: model.duration,
            notes: model.notes,
            thumbnailURL: model.thumbnailURL,
            lastPlayedAt: model.lastPlayedAt,
            playCount: model.playCount
        )
    }
}
