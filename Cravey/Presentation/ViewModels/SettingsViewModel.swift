import Foundation
import SwiftData

/// Settings ViewModel - handles data export and deletion
/// Presentation layer - Clean Architecture
@Observable
@MainActor
final class SettingsViewModel {
    // MARK: - Dependencies

    private let modelContext: ModelContext

    // MARK: - Published State

    var isExporting = false
    var isDeleting = false
    var showDeleteConfirmation = false
    var showExportSheet = false
    var exportURL: URL?
    var errorMessage: String?
    var showError = false
    var deleteSuccess = false

    // MARK: - App Info

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Export

    func exportData() async {
        isExporting = true
        defer { isExporting = false }

        do {
            // Fetch all cravings
            let cravingDescriptor = FetchDescriptor<CravingModel>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let cravings = try modelContext.fetch(cravingDescriptor)

            // Fetch all usages
            let usageDescriptor = FetchDescriptor<UsageModel>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let usages = try modelContext.fetch(usageDescriptor)

            // Create export data
            let exportData = ExportData(
                exportDate: Date(),
                cravings: cravings.map { CravingExport(from: $0) },
                usages: usages.map { UsageExport(from: $0) }
            )

            // Encode to JSON
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let jsonData = try encoder.encode(exportData)

            // Write to temp file
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "cravey-export-\(formattedDate()).json"
            let fileURL = tempDir.appendingPathComponent(fileName)
            try jsonData.write(to: fileURL)

            exportURL = fileURL
            showExportSheet = true
        } catch {
            errorMessage = "Failed to export data: \(error.localizedDescription)"
            showError = true
        }
    }

    // MARK: - Delete All Data

    func deleteAllData() async {
        isDeleting = true
        defer { isDeleting = false }

        do {
            // Delete all cravings
            try modelContext.delete(model: CravingModel.self)

            // Delete all usages
            try modelContext.delete(model: UsageModel.self)

            // Save context
            try modelContext.save()

            deleteSuccess = true
        } catch {
            errorMessage = "Failed to delete data: \(error.localizedDescription)"
            showError = true
        }
    }

    // MARK: - Helpers

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter.string(from: Date())
    }
}

// MARK: - Export Data Structures

struct ExportData: Codable {
    let exportDate: Date
    let cravings: [CravingExport]
    let usages: [UsageExport]
}

struct CravingExport: Codable {
    let id: UUID
    let timestamp: Date
    let intensity: Int
    let triggers: [String]
    let location: String?
    let notes: String?

    init(from model: CravingModel) {
        id = model.id
        timestamp = model.timestamp
        intensity = model.intensity
        triggers = model.triggers
        location = model.location
        notes = model.notes
    }
}

struct UsageExport: Codable {
    let id: UUID
    let timestamp: Date
    let method: String
    let amount: Double
    let triggers: [String]
    let location: String?
    let notes: String?

    init(from model: UsageModel) {
        id = model.id
        timestamp = model.timestamp
        method = model.method
        amount = model.amount
        triggers = model.triggers
        location = model.location
        notes = model.notes
    }
}
