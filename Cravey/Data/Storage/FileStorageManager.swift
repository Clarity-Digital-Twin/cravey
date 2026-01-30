import AVFoundation
import Foundation
import OSLog
#if canImport(UIKit)
    import UIKit
#endif

enum StorageError: LocalizedError {
    case directoryCreationFailed
    case fileSaveFailed
    case fileNotFound
    case invalidURL
    case thumbnailGenerationFailed
    case storageLimitExceeded

    var errorDescription: String? {
        switch self {
        case .directoryCreationFailed:
            "Failed to create storage directory"
        case .fileSaveFailed:
            "Failed to save file"
        case .fileNotFound:
            "File not found"
        case .invalidURL:
            "Invalid file URL"
        case .thumbnailGenerationFailed:
            "Failed to generate thumbnail"
        case .storageLimitExceeded:
            "Not enough storage available to save this recording"
        }
    }
}

/// Protocol for file deletion operations (enables testing with mocks)
protocol RecordingFileDeleting: Sendable {
    func deleteRecording(at relativePath: String) async throws
    func deleteThumbnail(at relativePath: String?) async throws
}

actor FileStorageManager: RecordingFileDeleting {
    private static let logger = Logger(subsystem: "com.cravey", category: "FileStorageManager")

    private let fileManager: FileManager
    private let maxTotalRecordingBytes: Int64

    init(
        fileManager: FileManager = .default,
        maxTotalRecordingBytes: Int64
    ) {
        self.fileManager = fileManager
        self.maxTotalRecordingBytes = maxTotalRecordingBytes
    }

    // Storage directories
    private var recordingsDirectory: URL {
        get throws {
            let documents = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let recordingsDir = documents.appendingPathComponent("Recordings", isDirectory: true)

            if !fileManager.fileExists(atPath: recordingsDir.path) {
                try fileManager.createDirectory(
                    at: recordingsDir,
                    withIntermediateDirectories: true
                )
            }

            return recordingsDir
        }
    }

    private var thumbnailsDirectory: URL {
        get throws {
            let recordings = try recordingsDirectory
            let thumbnailsDir = recordings.appendingPathComponent("Thumbnails", isDirectory: true)

            if !fileManager.fileExists(atPath: thumbnailsDir.path) {
                try fileManager.createDirectory(
                    at: thumbnailsDir,
                    withIntermediateDirectories: true
                )
            }

            return thumbnailsDir
        }
    }

    // MARK: - Save Recording

    /// Saves a recording file and returns the relative path
    /// DEBT-043: Now cleans up temp file after successful save
    func saveRecording(from tempURL: URL, recordingType: RecordingType, id: UUID = UUID()) async throws -> String {
        let tempAttributes = try fileManager.attributesOfItem(atPath: tempURL.path)
        let tempFileSize = (tempAttributes[.size] as? Int64) ?? 0

        let currentUsage = try getTotalStorageUsed()
        guard currentUsage + tempFileSize <= maxTotalRecordingBytes else {
            throw StorageError.storageLimitExceeded
        }

        let recordings = try recordingsDirectory
        let filename = "\(recordingType.rawValue)_\(id.uuidString).\(recordingType.fileExtension)"
        let destinationURL = recordings.appendingPathComponent(filename)

        // Prefer move (atomic, faster) over copy
        do {
            try fileManager.moveItem(at: tempURL, to: destinationURL)
        } catch CocoaError.fileWriteFileExists {
            // Destination exists - replace atomically to avoid data loss if move fails
            _ = try fileManager.replaceItemAt(destinationURL, withItemAt: tempURL, backupItemName: nil)
        } catch {
            // Move failed for other reason - fall back to copy + cleanup
            try fileManager.copyItem(at: tempURL, to: destinationURL)
            try? fileManager.removeItem(at: tempURL) // Best-effort cleanup
        }

        return "Recordings/\(filename)"
    }

    /// Generates and saves a thumbnail for a video recording
    func generateThumbnail(for videoPath: String) async throws -> String? {
        guard let videoURL = absoluteURL(for: videoPath) else {
            throw StorageError.invalidURL
        }

        let asset = AVURLAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 1, preferredTimescale: 60)
        let (cgImage, _) = try await imageGenerator.image(at: time)

        #if canImport(UIKit)
            let image = UIImage(cgImage: cgImage)
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw StorageError.thumbnailGenerationFailed
            }
        #else
            // macOS - would use NSImage
            throw StorageError.thumbnailGenerationFailed
        #endif

        let thumbnailsDir = try thumbnailsDirectory
        let baseName = URL(fileURLWithPath: videoPath).deletingPathExtension().lastPathComponent
        let safeBaseName = baseName.isEmpty ? UUID().uuidString : baseName
        let filename = "\(safeBaseName)_thumb.jpg"
        let thumbnailURL = thumbnailsDir.appendingPathComponent(filename)

        try imageData.write(to: thumbnailURL)

        return "Recordings/Thumbnails/\(filename)"
    }

    // MARK: - File Access

    /// Converts relative path to absolute URL
    func absoluteURL(for relativePath: String) -> URL? {
        do {
            let documents = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )

            return documents.appendingPathComponent(relativePath)
        } catch {
            Self.logger.error("Failed to resolve Documents directory: \(error.localizedDescription)")
            return nil
        }
    }

    /// Gets the duration of a recording
    func getDuration(for filePath: String) async throws -> TimeInterval {
        guard let url = absoluteURL(for: filePath) else {
            throw StorageError.invalidURL
        }

        let asset = AVURLAsset(url: url)
        let duration = try await asset.load(.duration)
        return CMTimeGetSeconds(duration)
    }

    // MARK: - File Deletion

    /// Deletes a recording file
    /// Marked async to match RecordingFileDeleting protocol requirement
    /// DEBT-043: Made idempotent (matches deleteThumbnail behavior)
    func deleteRecording(at relativePath: String) async throws {
        guard let url = absoluteURL(for: relativePath) else {
            return // Invalid path = no-op (idempotent)
        }

        guard fileManager.fileExists(atPath: url.path) else {
            return // Already deleted = no-op (idempotent)
        }

        try fileManager.removeItem(at: url)
    }

    /// Deletes a thumbnail
    /// Marked async to match RecordingFileDeleting protocol requirement
    func deleteThumbnail(at relativePath: String?) async throws {
        guard let relativePath,
              let url = absoluteURL(for: relativePath)
        else {
            return // No thumbnail to delete
        }

        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }

    // MARK: - Storage Info

    /// Gets total size of all recordings in bytes
    func getTotalStorageUsed() throws -> Int64 {
        let recordings = try recordingsDirectory
        var totalSize: Int64 = 0

        if let enumerator = fileManager.enumerator(
            at: recordings,
            includingPropertiesForKeys: [.fileSizeKey]
        ) {
            for case let fileURL as URL in enumerator {
                let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                if let fileSize = attributes[.size] as? Int64 {
                    totalSize += fileSize
                }
            }
        }

        return totalSize
    }

    /// Formats bytes to human-readable string
    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
