import Foundation
import SwiftData

/// SwiftData implementation of UsageRepositoryProtocol
final class UsageRepository: UsageRepositoryProtocol {
    private nonisolated(unsafe) let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ usage: UsageEntity) async throws {
        let model = UsageMapper.toModel(usage)
        modelContext.insert(model)
        try modelContext.save()
    }

    func fetchAll() async throws -> [UsageEntity] {
        let descriptor = FetchDescriptor<UsageModel>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { UsageMapper.toEntity($0) }
    }

    func fetch(since date: Date) async throws -> [UsageEntity] {
        let predicate = #Predicate<UsageModel> { usage in
            usage.timestamp >= date
        }
        let descriptor = FetchDescriptor<UsageModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { UsageMapper.toEntity($0) }
    }

    func delete(id: UUID) async throws {
        let predicate = #Predicate<UsageModel> { usage in
            usage.id == id
        }
        let descriptor = FetchDescriptor<UsageModel>(predicate: predicate)
        let models = try modelContext.fetch(descriptor)

        guard let model = models.first else {
            throw UsageRepositoryError.notFound(id: id)
        }

        modelContext.delete(model)
        try modelContext.save()
    }

    func deleteAll() async throws {
        try modelContext.delete(model: UsageModel.self)
        try modelContext.save()
    }
}

enum UsageRepositoryError: Error {
    case notFound(id: UUID)
}
