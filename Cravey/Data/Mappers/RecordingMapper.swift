import Foundation
import os

private let logger = Logger(subsystem: "com.cravey.app", category: "RecordingMapper")

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
        // Parse recording type with fallback logging
        let recordingType: RecordingType
        if let parsed = RecordingType(rawValue: model.recordingType) {
            recordingType = parsed
        } else {
            logger.warning("Invalid recordingType '\(model.recordingType)' for id \(model.id), defaulting to .audio")
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
            createdAt: model.createdAt,
            recordingType: recordingType,
            purpose: purpose,
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
