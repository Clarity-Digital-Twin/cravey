@testable import Cravey
import Foundation
import Testing

/// Integration tests for FileStorageManager
/// Tests file operations, storage limits, and cleanup (DEBT-047)
///
/// NOTE: These tests use a temp directory to avoid polluting the real Documents directory.
/// FileStorageManager uses .documentDirectory internally, so we test via the public API
/// and clean up after each test.
@Suite("FileStorageManager Tests")
struct FileStorageManagerTests {
    // MARK: - Storage Limit Tests

    @Test("saveRecording throws storageLimitExceeded when limit is exceeded")
    func storageLimitEnforced() async throws {
        // Setup: Very small storage limit (100 bytes)
        let storage = FileStorageManager(
            fileManager: .default,
            maxTotalRecordingBytes: 100
        )

        // Create a temp file larger than the limit
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("test_large_\(UUID().uuidString).m4a")
        let largeData = Data(repeating: 0x42, count: 200) // 200 bytes > 100 limit
        try largeData.write(to: tempFile)

        defer {
            try? FileManager.default.removeItem(at: tempFile)
        }

        // When/Then: Should throw storageLimitExceeded
        do {
            _ = try await storage.saveRecording(from: tempFile, recordingType: .audio)
            Issue.record("Expected storageLimitExceeded error but succeeded")
        } catch StorageError.storageLimitExceeded {
            // Expected
        } catch {
            Issue.record("Expected storageLimitExceeded but got: \(error)")
        }
    }

    @Test("saveRecording succeeds when within limit")
    func saveWithinLimitSucceeds() async throws {
        // Setup: Generous limit
        let storage = FileStorageManager(
            fileManager: .default,
            maxTotalRecordingBytes: 10_000_000 // 10 MB
        )

        // Create a small temp file
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("test_small_\(UUID().uuidString).m4a")
        let smallData = Data(repeating: 0x42, count: 100) // 100 bytes
        try smallData.write(to: tempFile)

        // When: Save the recording
        let relativePath = try await storage.saveRecording(from: tempFile, recordingType: .audio)

        // Then: Returns valid relative path
        #expect(relativePath.hasPrefix("Recordings/"))
        #expect(relativePath.hasSuffix(".m4a"))

        // Cleanup: Delete the saved file
        try await storage.deleteRecording(at: relativePath)

        // Verify cleanup worked (idempotent delete shouldn't throw)
        try await storage.deleteRecording(at: relativePath)
    }

    // MARK: - Atomic Replace Tests

    @Test("saveRecording replaces existing file atomically")
    func atomicReplaceOnConflict() async throws {
        let storage = FileStorageManager(
            fileManager: .default,
            maxTotalRecordingBytes: 10_000_000
        )

        let testId = UUID()
        let tempDir = FileManager.default.temporaryDirectory

        // Create first temp file with content "AAA"
        let tempFile1 = tempDir.appendingPathComponent("test1_\(UUID().uuidString).m4a")
        try Data(repeating: 0x41, count: 50).write(to: tempFile1) // 'A' bytes

        // Save first file
        let relativePath = try await storage.saveRecording(
            from: tempFile1,
            recordingType: .audio,
            id: testId
        )

        // Create second temp file with content "BBB"
        let tempFile2 = tempDir.appendingPathComponent("test2_\(UUID().uuidString).m4a")
        try Data(repeating: 0x42, count: 75).write(to: tempFile2) // 'B' bytes

        // When: Save second file with SAME id (triggers replace)
        let relativePath2 = try await storage.saveRecording(
            from: tempFile2,
            recordingType: .audio,
            id: testId
        )

        // Then: Paths should be the same (same ID)
        #expect(relativePath == relativePath2)

        // Verify the new content is there (75 bytes of 'B')
        if let absoluteURL = await storage.absoluteURL(for: relativePath) {
            let finalData = try Data(contentsOf: absoluteURL)
            #expect(finalData.count == 75)
            #expect(finalData[0] == 0x42) // 'B'
        }

        // Cleanup
        try await storage.deleteRecording(at: relativePath)
    }

    // MARK: - Idempotent Delete Tests

    @Test("deleteRecording is idempotent (no-op for non-existent file)")
    func deleteIsIdempotent() async throws {
        let storage = FileStorageManager(
            fileManager: .default,
            maxTotalRecordingBytes: 10_000_000
        )

        // Delete a file that doesn't exist - should not throw
        try await storage.deleteRecording(at: "Recordings/nonexistent_\(UUID().uuidString).m4a")

        // Call it again - still should not throw
        try await storage.deleteRecording(at: "Recordings/nonexistent_\(UUID().uuidString).m4a")
    }

    @Test("deleteRecording handles invalid paths gracefully")
    func deleteHandlesInvalidPath() async throws {
        let storage = FileStorageManager(
            fileManager: .default,
            maxTotalRecordingBytes: 10_000_000
        )

        // Empty path
        try await storage.deleteRecording(at: "")

        // Path with no directory
        try await storage.deleteRecording(at: "orphan.m4a")
    }

    // MARK: - Temp File Cleanup Tests

    @Test("saveRecording cleans up temp file on success")
    func tempFileCleanedUpOnSuccess() async throws {
        let storage = FileStorageManager(
            fileManager: .default,
            maxTotalRecordingBytes: 10_000_000
        )

        // Create a temp file
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("cleanup_test_\(UUID().uuidString).m4a")
        try Data(repeating: 0x42, count: 100).write(to: tempFile)

        // Verify temp file exists
        #expect(FileManager.default.fileExists(atPath: tempFile.path))

        // When: Save the recording (move should remove temp)
        let relativePath = try await storage.saveRecording(from: tempFile, recordingType: .audio)

        // Then: Temp file should be gone (moved, not copied)
        #expect(!FileManager.default.fileExists(atPath: tempFile.path),
               "Temp file should be removed after successful save")

        // Cleanup
        try await storage.deleteRecording(at: relativePath)
    }

    // MARK: - Storage Calculation Tests

    @Test("getTotalStorageUsed calculates correctly")
    func storageCalculation() async throws {
        let storage = FileStorageManager(
            fileManager: .default,
            maxTotalRecordingBytes: 10_000_000
        )

        // Get baseline
        let baseline = try await storage.getTotalStorageUsed()

        // Add a file
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("storage_test_\(UUID().uuidString).m4a")
        let testData = Data(repeating: 0x42, count: 1000) // 1000 bytes
        try testData.write(to: tempFile)

        let relativePath = try await storage.saveRecording(from: tempFile, recordingType: .audio)

        // Check storage increased
        let afterSave = try await storage.getTotalStorageUsed()
        #expect(afterSave >= baseline + 1000, "Storage should increase by at least file size")

        // Delete and verify storage decreased
        try await storage.deleteRecording(at: relativePath)
        let afterDelete = try await storage.getTotalStorageUsed()
        #expect(afterDelete < afterSave, "Storage should decrease after deletion")
    }
}
