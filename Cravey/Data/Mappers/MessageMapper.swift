import Foundation
import OSLog

private let logger = Logger(subsystem: "com.cravey", category: "MessageMapper")

/// Mapper between MotivationalMessageEntity (Domain) and MotivationalMessageModel (Data/SwiftData)
enum MessageMapper {
    /// Convert Domain Entity → SwiftData Model
    static func toModel(_ entity: MotivationalMessageEntity) -> MotivationalMessageModel {
        MotivationalMessageModel(
            id: entity.id,
            content: entity.content,
            category: entity.category.rawValue,
            isCustom: entity.isCustom,
            priority: entity.priority,
            isActive: entity.isActive,
            timesShown: entity.timesShown,
            lastShownAt: entity.lastShownAt,
            createdAt: entity.createdAt,
            modifiedAt: entity.modifiedAt
        )
    }

    /// Convert SwiftData Model → Domain Entity
    static func toEntity(_ model: MotivationalMessageModel) -> MotivationalMessageEntity {
        let category: MessageCategory
        if let parsed = MessageCategory(rawValue: model.category) {
            category = parsed
        } else {
            logger.warning("Invalid category '\(model.category)' for id \(model.id), mapping to .unknown")
            category = .unknown
        }

        return MotivationalMessageEntity(
            id: model.id,
            content: model.content,
            category: category,
            isCustom: model.isCustom,
            priority: model.priority,
            isActive: model.isActive,
            timesShown: model.timesShown,
            lastShownAt: model.lastShownAt,
            createdAt: model.createdAt,
            modifiedAt: model.modifiedAt
        )
    }
}
