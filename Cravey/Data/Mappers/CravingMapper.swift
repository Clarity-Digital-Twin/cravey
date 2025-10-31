import Foundation

/// Mapper between CravingEntity (Domain) and CravingModel (Data/SwiftData)
enum CravingMapper {
    /// Convert Domain Entity → SwiftData Model
    static func toModel(_ entity: CravingEntity) -> CravingModel {
        CravingModel(
            id: entity.id,
            timestamp: entity.timestamp,
            intensity: entity.intensity,
            duration: entity.duration,
            triggers: entity.triggers,
            notes: entity.notes,
            location: entity.location,
            managementStrategy: entity.managementStrategy,
            wasManagedSuccessfully: entity.wasManagedSuccessfully
        )
    }

    /// Convert SwiftData Model → Domain Entity
    static func toEntity(_ model: CravingModel) -> CravingEntity {
        CravingEntity(
            id: model.id,
            timestamp: model.timestamp,
            intensity: model.intensity,
            duration: model.duration,
            triggers: model.triggers,
            notes: model.notes,
            location: model.location,
            managementStrategy: model.managementStrategy,
            wasManagedSuccessfully: model.wasManagedSuccessfully
        )
    }
}
