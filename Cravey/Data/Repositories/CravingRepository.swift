import Foundation
import SwiftData

/// Concrete implementation of CravingRepositoryProtocol using SwiftData
final class CravingRepository: CravingRepositoryProtocol {
    nonisolated(unsafe) private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ craving: CravingEntity) async throws {
        let model = CravingMapper.toModel(craving)
        modelContext.insert(model)
        try modelContext.save()
    }

    func fetchAll() async throws -> [CravingEntity] {
        let descriptor = FetchDescriptor<CravingModel>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { CravingMapper.toEntity($0) }
    }

    func fetch(from startDate: Date, to endDate: Date) async throws -> [CravingEntity] {
        let predicate = #Predicate<CravingModel> { model in
            model.timestamp >= startDate && model.timestamp <= endDate
        }
        let descriptor = FetchDescriptor<CravingModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { CravingMapper.toEntity($0) }
    }

    func delete(id: UUID) async throws {
        let predicate = #Predicate<CravingModel> { $0.id == id }
        try modelContext.delete(model: CravingModel.self, where: predicate)
        try modelContext.save()
    }

    func update(_ craving: CravingEntity) async throws {
        let predicate = #Predicate<CravingModel> { $0.id == craving.id }
        let descriptor = FetchDescriptor<CravingModel>(predicate: predicate)

        guard let model = try modelContext.fetch(descriptor).first else {
            throw RepositoryError.notFound
        }

        // Update model properties
        model.timestamp = craving.timestamp
        model.intensity = craving.intensity
        model.duration = craving.duration
        model.trigger = craving.trigger
        model.notes = craving.notes
        model.location = craving.location
        model.managementStrategy = craving.managementStrategy
        model.wasManagedSuccessfully = craving.wasManagedSuccessfully

        try modelContext.save()
    }

    func count() async throws -> Int {
        let descriptor = FetchDescriptor<CravingModel>()
        return try modelContext.fetchCount(descriptor)
    }
}

enum RepositoryError: LocalizedError {
    case notFound

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Item not found"
        }
    }
}
