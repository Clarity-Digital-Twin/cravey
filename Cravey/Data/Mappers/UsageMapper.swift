import Foundation

/// Maps between UsageEntity (Domain) and UsageModel (SwiftData)
enum UsageMapper {
    /// Convert Domain entity to SwiftData model
    static func toModel(_ entity: UsageEntity) -> UsageModel {
        UsageModel(
            id: entity.id,
            timestamp: entity.timestamp,
            method: entity.method,
            amount: entity.amount,
            triggers: entity.triggers,
            location: entity.location,
            notes: entity.notes,
            createdAt: entity.createdAt,
            modifiedAt: entity.modifiedAt
        )
    }

    /// Convert SwiftData model to Domain entity
    static func toEntity(_ model: UsageModel) -> UsageEntity {
        UsageEntity(
            id: model.id,
            timestamp: model.timestamp,
            method: model.method,
            amount: model.amount,
            triggers: model.triggers,
            location: model.location,
            notes: model.notes,
            createdAt: model.createdAt,
            modifiedAt: model.modifiedAt
        )
    }
}
