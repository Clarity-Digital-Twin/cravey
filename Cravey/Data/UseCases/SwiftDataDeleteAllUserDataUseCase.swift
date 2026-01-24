import Foundation
import SwiftData

/// SwiftData-backed implementation of DeleteAllUserDataUseCase.
///
/// Deletes:
/// - All SwiftData models (cravings, usage, recordings, messages)
/// - Any on-disk recording files/thumbnails
final class SwiftDataDeleteAllUserDataUseCase: DeleteAllUserDataUseCase {
    private nonisolated(unsafe) let modelContext: ModelContext
    private let fileStorage: FileStorageManager

    init(modelContext: ModelContext, fileStorage: FileStorageManager) {
        self.modelContext = modelContext
        self.fileStorage = fileStorage
    }

    func execute() async throws {
        try await MainActor.run {
            // Delete on-disk recordings first (privacy: avoid orphaned media files)
            try fileStorage.deleteAllRecordings()

            try modelContext.delete(model: CravingModel.self)
            try modelContext.delete(model: UsageModel.self)
            try modelContext.delete(model: RecordingModel.self)
            try modelContext.delete(model: MotivationalMessageModel.self)
            try modelContext.save()
        }
    }
}
