import Foundation

/// Settings ViewModel - handles data export and deletion
/// Presentation layer - Clean Architecture
@Observable
@MainActor
final class SettingsViewModel {
    // MARK: - Dependencies

    @ObservationIgnored
    private let exportUserDataUseCase: ExportUserDataUseCase

    @ObservationIgnored
    private let deleteAllUserDataUseCase: DeleteAllUserDataUseCase

    @ObservationIgnored
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter
    }()

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

    init(exportUserDataUseCase: ExportUserDataUseCase, deleteAllUserDataUseCase: DeleteAllUserDataUseCase) {
        self.exportUserDataUseCase = exportUserDataUseCase
        self.deleteAllUserDataUseCase = deleteAllUserDataUseCase
    }

    // MARK: - Export

    func exportData() async {
        isExporting = true
        defer { isExporting = false }

        do {
            let exportData = try await exportUserDataUseCase.execute()

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
            try await deleteAllUserDataUseCase.execute()

            deleteSuccess = true
        } catch {
            errorMessage = "Failed to delete data: \(error.localizedDescription)"
            showError = true
        }
    }

    // MARK: - Helpers

    private func formattedDate() -> String {
        dateFormatter.string(from: Date())
    }
}
