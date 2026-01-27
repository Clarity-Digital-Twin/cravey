import Foundation
import SwiftData

/// SwiftData implementation of RecordingRepositoryProtocol
final class RecordingRepository: RecordingRepositoryProtocol {
    private nonisolated(unsafe) let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ recording: RecordingEntity) async throws {
        try await MainActor.run {
            let model = RecordingMapper.toModel(recording)
            modelContext.insert(model)
            try modelContext.save()
        }
    }

    func fetchAll() async throws -> [RecordingEntity] {
        try await MainActor.run {
            let descriptor = FetchDescriptor<RecordingModel>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let models = try modelContext.fetch(descriptor)
            return models.map { RecordingMapper.toEntity($0) }
        }
    }

    func fetch(byPurpose purpose: RecordingPurpose) async throws -> [RecordingEntity] {
        try await MainActor.run {
            let predicate = #Predicate<RecordingModel> { $0.purpose == purpose.rawValue }
            let descriptor = FetchDescriptor<RecordingModel>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let models = try modelContext.fetch(descriptor)
            return models.map { RecordingMapper.toEntity($0) }
        }
    }

    func delete(id: UUID) async throws {
        try await MainActor.run {
            let predicate = #Predicate<RecordingModel> { $0.id == id }
            let descriptor = FetchDescriptor<RecordingModel>(predicate: predicate)
            let models = try modelContext.fetch(descriptor)

            guard let model = models.first else {
                throw RepositoryError.notFound(id: id)
            }

            modelContext.delete(model)
            try modelContext.save()
        }
    }

    func update(_ recording: RecordingEntity) async throws {
        try await MainActor.run {
            let predicate = #Predicate<RecordingModel> { $0.id == recording.id }
            let descriptor = FetchDescriptor<RecordingModel>(predicate: predicate)

            guard let model = try modelContext.fetch(descriptor).first else {
                throw RepositoryError.notFound(id: recording.id)
            }

            model.timestamp = recording.timestamp
            model.type = recording.type.rawValue
            model.purpose = recording.purpose.rawValue
            model.duration = recording.duration
            model.filePath = recording.filePath
            model.thumbnailPath = recording.thumbnailPath
            model.title = recording.title
            model.notes = recording.notes
            model.lastPlayedAt = recording.lastPlayedAt
            model.playCount = recording.playCount
            model.modifiedAt = Date()

            try modelContext.save()
        }
    }
}
