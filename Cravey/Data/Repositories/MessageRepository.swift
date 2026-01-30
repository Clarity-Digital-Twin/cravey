import Foundation
import SwiftData

/// SwiftData implementation of MessageRepositoryProtocol
final class MessageRepository: MessageRepositoryProtocol {
    private nonisolated(unsafe) let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ message: MotivationalMessageEntity) async throws {
        try await MainActor.run {
            let model = MessageMapper.toModel(message)
            modelContext.insert(model)
            try modelContext.save()
        }
    }

    func fetchAll() async throws -> [MotivationalMessageEntity] {
        try await MainActor.run {
            let descriptor = FetchDescriptor<MotivationalMessageModel>(
                sortBy: [SortDescriptor(\.category), SortDescriptor(\.priority)]
            )
            let models = try modelContext.fetch(descriptor)
            return models.map { MessageMapper.toEntity($0) }
        }
    }

    func fetchActive() async throws -> [MotivationalMessageEntity] {
        try await MainActor.run {
            let predicate = #Predicate<MotivationalMessageModel> { $0.isActive == true }
            let descriptor = FetchDescriptor<MotivationalMessageModel>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.category), SortDescriptor(\.priority)]
            )
            let models = try modelContext.fetch(descriptor)
            return models.map { MessageMapper.toEntity($0) }
        }
    }

    func fetch(byCategory category: MessageCategory) async throws -> [MotivationalMessageEntity] {
        try await MainActor.run {
            let predicate = #Predicate<MotivationalMessageModel> {
                $0.category == category.rawValue && $0.isActive == true
            }
            let descriptor = FetchDescriptor<MotivationalMessageModel>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.priority)]
            )
            let models = try modelContext.fetch(descriptor)
            return models.map { MessageMapper.toEntity($0) }
        }
    }

    func delete(id: UUID) async throws {
        try await MainActor.run {
            let predicate = #Predicate<MotivationalMessageModel> { $0.id == id }
            let descriptor = FetchDescriptor<MotivationalMessageModel>(predicate: predicate)
            let models = try modelContext.fetch(descriptor)

            guard let model = models.first else {
                throw RepositoryError.notFound(id: id)
            }

            modelContext.delete(model)
            try modelContext.save()
        }
    }

    func update(_ message: MotivationalMessageEntity) async throws {
        try await MainActor.run {
            let predicate = #Predicate<MotivationalMessageModel> { $0.id == message.id }
            let descriptor = FetchDescriptor<MotivationalMessageModel>(predicate: predicate)

            guard let model = try modelContext.fetch(descriptor).first else {
                throw RepositoryError.notFound(id: message.id)
            }

            model.content = message.content
            model.category = message.category.rawValue
            model.isCustom = message.isCustom
            model.priority = message.priority
            model.isActive = message.isActive
            model.timesShown = message.timesShown
            model.lastShownAt = message.lastShownAt
            model.modifiedAt = message.modifiedAt ?? Date()

            try modelContext.save()
        }
    }

    func seedDefaultMessagesIfNeeded() async throws {
        try await MainActor.run {
            let descriptor = FetchDescriptor<MotivationalMessageModel>()
            let count = try modelContext.fetchCount(descriptor)

            guard count == 0 else { return }

            for message in MotivationalMessageEntity.defaultMessages {
                modelContext.insert(MessageMapper.toModel(message))
            }

            try modelContext.save()
        }
    }
}
