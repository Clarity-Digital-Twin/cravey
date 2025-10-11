import Foundation
import AVFoundation
#if canImport(UIKit)
import UIKit
#endif

enum StorageError: LocalizedError {
    case directoryCreationFailed
    case fileSaveFailed
    case fileNotFound
    case invalidURL
    case thumbnailGenerationFailed

    var errorDescription: String? {
        switch self {
        case .directoryCreationFailed:
            return "Failed to create storage directory"
        case .fileSaveFailed:
            return "Failed to save file"
        case .fileNotFound:
            return "File not found"
        case .invalidURL:
            return "Invalid file URL"
        case .thumbnailGenerationFailed:
            return "Failed to generate thumbnail"
        }
    }
}

@MainActor
final class FileStorageManager {
    static let shared = FileStorageManager()

    private let fileManager = FileManager.default

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

    private init() {}

    // MARK: - Save Recording

    /// Saves a recording file and returns the relative path
    func saveRecording(from tempURL: URL, recordingType: RecordingType) async throws -> String {
        let recordings = try recordingsDirectory
        let filename = "\(UUID().uuidString).\(recordingType.fileExtension)"
        let destinationURL = recordings.appendingPathComponent(filename)

        try fileManager.copyItem(at: tempURL, to: destinationURL)

        return "Recordings/\(filename)"
    }

    /// Generates and saves a thumbnail for a video recording
    func generateThumbnail(for videoPath: String) async throws -> String? {
        guard let videoURL = absoluteURL(for: videoPath) else {
            throw StorageError.invalidURL
        }

        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 1, preferredTimescale: 60)
        let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)

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
        let filename = "\(UUID().uuidString).jpg"
        let thumbnailURL = thumbnailsDir.appendingPathComponent(filename)

        try imageData.write(to: thumbnailURL)

        return "Recordings/Thumbnails/\(filename)"
    }

    // MARK: - File Access

    /// Converts relative path to absolute URL
    func absoluteURL(for relativePath: String) -> URL? {
        guard let documents = try? fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) else {
            return nil
        }

        return documents.appendingPathComponent(relativePath)
    }

    /// Gets the duration of a recording
    func getDuration(for filePath: String) async throws -> TimeInterval {
        guard let url = absoluteURL(for: filePath) else {
            throw StorageError.invalidURL
        }

        let asset = AVAsset(url: url)
        let duration = try await asset.load(.duration)
        return CMTimeGetSeconds(duration)
    }

    // MARK: - File Deletion

    /// Deletes a recording file
    func deleteRecording(at relativePath: String) throws {
        guard let url = absoluteURL(for: relativePath) else {
            throw StorageError.invalidURL
        }

        guard fileManager.fileExists(atPath: url.path) else {
            throw StorageError.fileNotFound
        }

        try fileManager.removeItem(at: url)
    }

    /// Deletes a thumbnail
    func deleteThumbnail(at relativePath: String?) throws {
        guard let relativePath = relativePath,
              let url = absoluteURL(for: relativePath) else {
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
