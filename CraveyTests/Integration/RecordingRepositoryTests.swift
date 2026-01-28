@testable import Cravey
import Foundation
import SwiftData
import Testing

@Suite("RecordingRepository Integration Tests")
struct RecordingRepositoryTests {
    @MainActor
    private static func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([RecordingModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        return ModelContext(container)
    }

    // MARK: - Test 1: Delete removes model from SwiftData

    @Test("delete(id:) should remove recording from SwiftData")
    @MainActor
    func deleteRemovesModel() async throws {
        let context = try Self.makeInMemoryContext()
        let mockFileStorage = MockFileStorageManager()
        let repository = RecordingRepository(modelContext: context, fileStorage: mockFileStorage)

        // Insert a recording
        let recording = RecordingEntity(
            type: .audio,
            purpose: .motivational,
            duration: 30.0,
            filePath: "Recordings/audio_test.m4a",
            thumbnailPath: nil
        )
        try await repository.save(recording)

        // Verify it exists
        let beforeDelete = try await repository.fetchAll()
        #expect(beforeDelete.count == 1)

        // Delete it
        try await repository.delete(id: recording.id)

        // Verify it's gone
        let afterDelete = try await repository.fetchAll()
        #expect(afterDelete.isEmpty)
    }

    // MARK: - Test 2: Delete calls file storage for recording file

    @Test("delete(id:) should delete recording file from disk")
    @MainActor
    func deleteRemovesRecordingFile() async throws {
        let context = try Self.makeInMemoryContext()
        let mockFileStorage = MockFileStorageManager()
        let repository = RecordingRepository(modelContext: context, fileStorage: mockFileStorage)

        let recording = RecordingEntity(
            type: .audio,
            purpose: .motivational,
            duration: 30.0,
            filePath: "Recordings/audio_test.m4a",
            thumbnailPath: nil
        )
        try await repository.save(recording)

        try await repository.delete(id: recording.id)

        // Verify file storage was called
        let deletedRecordings = await mockFileStorage.deletedRecordingPaths
        #expect(deletedRecordings.contains("Recordings/audio_test.m4a"))
    }

    // MARK: - Test 3: Delete calls file storage for thumbnail

    @Test("delete(id:) should delete thumbnail file from disk")
    @MainActor
    func deleteRemovesThumbnailFile() async throws {
        let context = try Self.makeInMemoryContext()
        let mockFileStorage = MockFileStorageManager()
        let repository = RecordingRepository(modelContext: context, fileStorage: mockFileStorage)

        let recording = RecordingEntity(
            type: .video,
            purpose: .motivational,
            duration: 60.0,
            filePath: "Recordings/video_test.mov",
            thumbnailPath: "Recordings/Thumbnails/video_test_thumb.jpg"
        )
        try await repository.save(recording)

        try await repository.delete(id: recording.id)

        // Verify both files were deleted
        let deletedRecordings = await mockFileStorage.deletedRecordingPaths
        let deletedThumbnails = await mockFileStorage.deletedThumbnailPaths

        #expect(deletedRecordings.contains("Recordings/video_test.mov"))
        #expect(deletedThumbnails.contains("Recordings/Thumbnails/video_test_thumb.jpg"))
    }

    // MARK: - Test 4: Delete succeeds even if file deletion fails

    @Test("delete(id:) should succeed even if file deletion fails")
    @MainActor
    func deleteSucceedsWhenFileDeletionFails() async throws {
        let context = try Self.makeInMemoryContext()
        let mockFileStorage = MockFileStorageManager(shouldThrowOnDelete: true)
        let repository = RecordingRepository(modelContext: context, fileStorage: mockFileStorage)

        let recording = RecordingEntity(
            type: .audio,
            purpose: .motivational,
            duration: 30.0,
            filePath: "Recordings/audio_test.m4a",
            thumbnailPath: nil
        )
        try await repository.save(recording)

        // Delete should NOT throw even though file deletion fails
        try await repository.delete(id: recording.id)

        // Model should still be deleted
        let afterDelete = try await repository.fetchAll()
        #expect(afterDelete.isEmpty)
    }

    // MARK: - Test 5: Delete non-existent recording throws

    @Test("delete(id:) should throw for non-existent recording")
    @MainActor
    func deleteNonExistentThrows() async throws {
        let context = try Self.makeInMemoryContext()
        let mockFileStorage = MockFileStorageManager()
        let repository = RecordingRepository(modelContext: context, fileStorage: mockFileStorage)

        let randomID = UUID()

        do {
            try await repository.delete(id: randomID)
            Issue.record("Should have thrown notFound error")
        } catch let error as RepositoryError {
            // Verify it's a notFound error (can't use == due to associated value)
            if case .notFound = error {
                // Expected
            } else {
                Issue.record("Wrong RepositoryError case: \(error)")
            }
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }
}

// MARK: - Mock FileStorageManager

/// Test mock for RecordingFileDeleting that tracks delete calls
actor MockFileStorageManager: RecordingFileDeleting {
    var deletedRecordingPaths: [String] = []
    var deletedThumbnailPaths: [String] = []
    let shouldThrowOnDelete: Bool

    init(shouldThrowOnDelete: Bool = false) {
        self.shouldThrowOnDelete = shouldThrowOnDelete
    }

    func deleteRecording(at relativePath: String) async throws {
        if shouldThrowOnDelete {
            throw StorageError.fileNotFound
        }
        deletedRecordingPaths.append(relativePath)
    }

    func deleteThumbnail(at relativePath: String?) async throws {
        guard let relativePath else { return }
        if shouldThrowOnDelete {
            throw StorageError.fileNotFound
        }
        deletedThumbnailPaths.append(relativePath)
    }
}
