import Foundation
import SwiftData

/// SwiftData-backed implementation of DeleteAllUserDataUseCase.
///
/// Deletes:
/// - All SwiftData models (cravings, usage, recordings)
/// - All custom motivational messages (defaults are kept)
/// - Any on-disk recording files/thumbnails (Documents/Recordings/)
final class SwiftDataDeleteAllUserDataUseCase: DeleteAllUserDataUseCase, Sendable {
    enum DeleteAllUserDataError: LocalizedError, Sendable {
        case prepareFileDeletionFailed(underlying: Error)
        case databaseDeletionFailed(underlying: Error)
        case rollbackFileDeletionFailed(underlying: Error)
        case fileDeletionFailed(underlying: Error)

        var errorDescription: String? {
            switch self {
            case .prepareFileDeletionFailed:
                "We couldn’t start deleting your recordings. Please try again."
            case .databaseDeletionFailed:
                "We couldn’t delete your saved data. Please try again."
            case .rollbackFileDeletionFailed:
                "We couldn’t fully restore your recordings after a failed delete. Please try again."
            case .fileDeletionFailed:
                "Some recording files couldn’t be deleted yet. Please try again."
            }
        }
    }

    private nonisolated(unsafe) let modelContext: ModelContext
    private let stageRecordingFilesDeletion: @Sendable () throws -> StagedRecordingsDeletion?
    private let commitRecordingFilesDeletion: @Sendable (StagedRecordingsDeletion?) throws -> Void
    private let rollbackRecordingFilesDeletion: @Sendable (StagedRecordingsDeletion?) throws -> Void

    init(
        modelContext: ModelContext,
        stageRecordingFilesDeletion: @escaping @Sendable () throws -> StagedRecordingsDeletion? = Self
            .stageRecordingsDirectoryForDeletion,
        commitRecordingFilesDeletion: @escaping @Sendable (StagedRecordingsDeletion?) throws -> Void = Self
            .commitStagedRecordingsDeletion,
        rollbackRecordingFilesDeletion: @escaping @Sendable (StagedRecordingsDeletion?) throws -> Void = Self
            .rollbackStagedRecordingsDeletion
    ) {
        self.modelContext = modelContext
        self.stageRecordingFilesDeletion = stageRecordingFilesDeletion
        self.commitRecordingFilesDeletion = commitRecordingFilesDeletion
        self.rollbackRecordingFilesDeletion = rollbackRecordingFilesDeletion
    }

    func execute() async throws {
        // Stage file deletion first, but keep it reversible until SwiftData deletion succeeds.
        // This avoids leaving the app in a confusing partial state if database deletion fails.
        let stagedDeletion: StagedRecordingsDeletion?
        do {
            stagedDeletion = try await Task.detached(priority: .utility) {
                try stageRecordingFilesDeletion()
            }.value
        } catch {
            throw DeleteAllUserDataError.prepareFileDeletionFailed(underlying: error)
        }

        do {
            try await MainActor.run {
                do {
                    try modelContext.delete(model: CravingModel.self)
                    try modelContext.delete(model: UsageModel.self)
                    try modelContext.delete(model: RecordingModel.self)

                    let customMessagesPredicate = #Predicate<MotivationalMessageModel> { $0.isCustom == true }
                    try modelContext.delete(model: MotivationalMessageModel.self, where: customMessagesPredicate)

                    try modelContext.save()
                } catch {
                    modelContext.rollback()
                    throw error
                }
            }
        } catch {
            do {
                try await Task.detached(priority: .utility) {
                    try rollbackRecordingFilesDeletion(stagedDeletion)
                }.value
            } catch {
                throw DeleteAllUserDataError.rollbackFileDeletionFailed(underlying: error)
            }

            throw DeleteAllUserDataError.databaseDeletionFailed(underlying: error)
        }

        do {
            try await Task.detached(priority: .utility) {
                try commitRecordingFilesDeletion(stagedDeletion)
            }.value
        } catch {
            throw DeleteAllUserDataError.fileDeletionFailed(underlying: error)
        }
    }

    private struct StagedRecordingsDeletion: Sendable {
        let recordingsDirectory: URL
        let stagedDirectory: URL
    }

    private static func stageRecordingsDirectoryForDeletion() throws -> StagedRecordingsDeletion? {
        let fileManager = FileManager.default
        let documents = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )

        // Best-effort cleanup of any previously-staged deletions (e.g. if a prior attempt failed mid-way).
        let stagedPrefix = "Recordings.__delete_pending__"
        let existingItems = (try? fileManager.contentsOfDirectory(at: documents, includingPropertiesForKeys: nil)) ?? []
        for url in existingItems where url.lastPathComponent.hasPrefix(stagedPrefix) {
            try? fileManager.removeItem(at: url)
        }

        let recordingsDir = documents.appendingPathComponent("Recordings", isDirectory: true)
        guard fileManager.fileExists(atPath: recordingsDir.path) else { return nil }

        let stagedDir = documents.appendingPathComponent("\(stagedPrefix)\(UUID().uuidString)", isDirectory: true)
        try fileManager.moveItem(at: recordingsDir, to: stagedDir)

        return StagedRecordingsDeletion(recordingsDirectory: recordingsDir, stagedDirectory: stagedDir)
    }

    private static func commitStagedRecordingsDeletion(_ stagedDeletion: StagedRecordingsDeletion?) throws {
        guard let stagedDeletion else { return }

        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: stagedDeletion.stagedDirectory.path) else { return }

        try fileManager.removeItem(at: stagedDeletion.stagedDirectory)
    }

    private static func rollbackStagedRecordingsDeletion(_ stagedDeletion: StagedRecordingsDeletion?) throws {
        guard let stagedDeletion else { return }

        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: stagedDeletion.stagedDirectory.path) else { return }

        if fileManager.fileExists(atPath: stagedDeletion.recordingsDirectory.path) {
            try fileManager.removeItem(at: stagedDeletion.recordingsDirectory)
        }

        try fileManager.moveItem(at: stagedDeletion.stagedDirectory, to: stagedDeletion.recordingsDirectory)
    }
}
}
