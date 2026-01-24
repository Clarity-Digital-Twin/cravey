import Foundation
import os

private let logger = Logger(subsystem: "com.cravey.app", category: "RecordingMapper")

/// Mapper between RecordingEntity (Domain) and RecordingModel (Data/SwiftData)
enum RecordingMapper {
    /// Convert Domain Entity → SwiftData Model
    static func toModel(_ entity: RecordingEntity) -> RecordingModel {
        RecordingModel(
            id: entity.id,
            timestamp: entity.timestamp,
            type: entity.type.rawValue,
            purpose: entity.purpose.rawValue,
            duration: entity.duration,
            filePath: entity.filePath,
            thumbnailPath: entity.thumbnailPath,
            title: entity.title,
            notes: entity.notes,
            lastPlayedAt: entity.lastPlayedAt,
            playCount: entity.playCount,
            createdAt: entity.createdAt,
            modifiedAt: entity.modifiedAt
        )
    }

    /// Convert SwiftData Model → Domain Entity
    static func toEntity(_ model: RecordingModel) -> RecordingEntity {
        // Parse recording type with fallback logging
        let recordingType: RecordingType
        if let parsed = RecordingType(rawValue: model.type) {
            recordingType = parsed
        } else {
            logger.warning("Invalid recording type '\(model.type)' for id \(model.id), defaulting to .audio")
            recordingType = .audio
        }

        // Parse purpose with fallback logging
        let purpose: RecordingPurpose
        if let parsed = RecordingPurpose(rawValue: model.purpose) {
            purpose = parsed
        } else {
            logger.warning("Invalid purpose '\(model.purpose)' for id \(model.id), defaulting to .motivational")
            purpose = .motivational
        }

        return RecordingEntity(
            id: model.id,
            timestamp: model.timestamp,
            type: recordingType,
            purpose: purpose,
            duration: model.duration,
            filePath: model.filePath,
            thumbnailPath: model.thumbnailPath,
            title: model.title,
            notes: model.notes,
            lastPlayedAt: model.lastPlayedAt,
            playCount: model.playCount,
            createdAt: model.createdAt,
            modifiedAt: model.modifiedAt
        )
    }
}
