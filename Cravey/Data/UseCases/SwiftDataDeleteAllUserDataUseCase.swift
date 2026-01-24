import Foundation
import SwiftData

/// SwiftData-backed implementation of DeleteAllUserDataUseCase.
///
/// Deletes:
/// - All SwiftData models (cravings, usage, recordings, messages)
/// - Any on-disk recording files/thumbnails
final class SwiftDataDeleteAllUserDataUseCase: DeleteAllUserDataUseCase, Sendable {
    private nonisolated(unsafe) let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func execute() async throws {
        // Delete on-disk recordings first (privacy: avoid orphaned media files).
        // Run file I/O off the main actor to avoid UI stalls for large libraries.
        try await Task.detached(priority: .utility) {
            try FileStorageManager.deleteAllRecordings()
        }.value

        try await MainActor.run {
            try modelContext.delete(model: CravingModel.self)
            try modelContext.delete(model: UsageModel.self)
            try modelContext.delete(model: RecordingModel.self)
            try modelContext.delete(model: MotivationalMessageModel.self)
            try modelContext.save()
        }
    }
}
