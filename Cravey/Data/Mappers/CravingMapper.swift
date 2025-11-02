import Foundation

/// Mapper between CravingEntity (Domain) and CravingModel (Data/SwiftData)
/// Source: DATA_MODEL_SPEC.md lines 260-305
enum CravingMapper {
    /// Convert Domain Entity → SwiftData Model
    static func toModel(_ entity: CravingEntity) -> CravingModel {
        CravingModel(
            id: entity.id,
            timestamp: entity.timestamp,
            intensity: entity.intensity,
            triggers: entity.triggers,
            location: entity.location,
            notes: entity.notes
        )
    }

    /// Convert SwiftData Model → Domain Entity
    static func toEntity(_ model: CravingModel) -> CravingEntity {
        CravingEntity(
            id: model.id,
            timestamp: model.timestamp,
            intensity: model.intensity,
            triggers: model.triggers,
            location: model.location,
            notes: model.notes,
            createdAt: model.createdAt,
            modifiedAt: model.modifiedAt
        )
    }
}
