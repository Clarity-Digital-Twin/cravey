import Foundation

/// Mapper between MotivationalMessageEntity (Domain) and MotivationalMessageModel (Data/SwiftData)
enum MessageMapper {
    /// Convert Domain Entity → SwiftData Model
    static func toModel(_ entity: MotivationalMessageEntity) -> MotivationalMessageModel {
        MotivationalMessageModel(
            id: entity.id,
            createdAt: entity.createdAt,
            category: entity.category.rawValue,
            content: entity.content,
            isActive: entity.isActive,
            isUserCreated: entity.isUserCreated,
            displayPriority: entity.displayPriority,
            timesShown: entity.timesShown,
            lastShownAt: entity.lastShownAt,
            wasHelpful: entity.wasHelpful
        )
    }

    /// Convert SwiftData Model → Domain Entity
    static func toEntity(_ model: MotivationalMessageModel) -> MotivationalMessageEntity {
        MotivationalMessageEntity(
            id: model.id,
            createdAt: model.createdAt,
            category: MessageCategory(rawValue: model.category) ?? .personalReason,
            content: model.content,
            isActive: model.isActive,
            isUserCreated: model.isUserCreated,
            displayPriority: model.displayPriority,
            timesShown: model.timesShown,
            lastShownAt: model.lastShownAt,
            wasHelpful: model.wasHelpful
        )
    }
}
