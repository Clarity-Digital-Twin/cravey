import Foundation
import OSLog
import SwiftData

/// SwiftData implementation of RecordingRepositoryProtocol
final class RecordingRepository: RecordingRepositoryProtocol {
    private static let logger = Logger(subsystem: "com.cravey", category: "RecordingRepository")

    private nonisolated(unsafe) let modelContext: ModelContext
    private let fileStorage: any RecordingFileDeleting

    init(modelContext: ModelContext, fileStorage: any RecordingFileDeleting) {
        self.modelContext = modelContext
        self.fileStorage = fileStorage
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
        // 1. Fetch model to get file paths before deletion
        let (filePath, thumbnailPath) = try await MainActor.run {
            let predicate = #Predicate<RecordingModel> { $0.id == id }
            let descriptor = FetchDescriptor<RecordingModel>(predicate: predicate)
            let models = try modelContext.fetch(descriptor)

            guard let model = models.first else {
                throw RepositoryError.notFound(id: id)
            }

            let paths = (model.filePath, model.thumbnailPath)

            // 2. Delete SwiftData model first (so UI reflects deletion)
            modelContext.delete(model)
            try modelContext.save()

            return paths
        }

        // 3. Delete on-disk files (best-effort - log errors but don't fail)
        // This order ensures user sees deletion even if file cleanup fails.
        // Orphan files will be cleaned up by "delete all data" eventually.
        do {
            try await fileStorage.deleteRecording(at: filePath)
        } catch {
            Self.logger.warning("Failed to delete recording file at \(filePath): \(error.localizedDescription)")
        }

        if let thumbnailPath {
            do {
                try await fileStorage.deleteThumbnail(at: thumbnailPath)
            } catch {
                Self.logger.warning("Failed to delete thumbnail at \(thumbnailPath): \(error.localizedDescription)")
            }
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
