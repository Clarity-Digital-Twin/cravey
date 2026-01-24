import Foundation
import SwiftData

/// Concrete implementation of CravingRepositoryProtocol using SwiftData
final class CravingRepository: CravingRepositoryProtocol {
    private nonisolated(unsafe) let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ craving: CravingEntity) async throws {
        try await MainActor.run {
            let model = CravingMapper.toModel(craving)
            modelContext.insert(model)
            try modelContext.save()
        }
    }

    func fetchAll() async throws -> [CravingEntity] {
        try await MainActor.run {
            let descriptor = FetchDescriptor<CravingModel>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let models = try modelContext.fetch(descriptor)
            return models.map { CravingMapper.toEntity($0) }
        }
    }

    func fetch(from startDate: Date, to endDate: Date) async throws -> [CravingEntity] {
        try await MainActor.run {
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
    }

    func delete(id: UUID) async throws {
        try await MainActor.run {
            let predicate = #Predicate<CravingModel> { $0.id == id }
            try modelContext.delete(model: CravingModel.self, where: predicate)
            try modelContext.save()
        }
    }

    func update(_ craving: CravingEntity) async throws {
        try await MainActor.run {
            let predicate = #Predicate<CravingModel> { $0.id == craving.id }
            let descriptor = FetchDescriptor<CravingModel>(predicate: predicate)

            guard let model = try modelContext.fetch(descriptor).first else {
                throw RepositoryError.notFound(id: craving.id)
            }

            // Update model properties
            model.timestamp = craving.timestamp
            model.intensity = craving.intensity
            model.triggers = craving.triggers
            model.notes = craving.notes
            model.location = craving.location
            model.modifiedAt = Date()

            try modelContext.save()
        }
    }

    func count() async throws -> Int {
        try await MainActor.run {
            let descriptor = FetchDescriptor<CravingModel>()
            return try modelContext.fetchCount(descriptor)
        }
    }
}
