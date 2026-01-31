import Foundation
import OSLog

/// Settings ViewModel - handles data export and deletion
/// Presentation layer - Clean Architecture
@Observable
@MainActor
final class SettingsViewModel {
    private static let logger = Logger(subsystem: "com.cravey", category: "SettingsViewModel")

    // MARK: - Dependencies

    @ObservationIgnored
    private let exportUserDataUseCase: ExportUserDataUseCase

    @ObservationIgnored
    private let deleteAllUserDataUseCase: DeleteAllUserDataUseCase

    @ObservationIgnored
    @MainActor
    private static let exportFileDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter
    }()

    // MARK: - Published State

    var isExporting = false
    var isDeleting = false
    var showDeleteConfirmation = false
    var showShareSheet = false
    var exportURL: URL?
    var errorMessage: String?
    var showError = false
    var deleteSuccess = false
    var exportSuccess = false

    // MARK: - App Info

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
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

    func exportData(format: ExportFormat) async {
        isExporting = true
        exportSuccess = false
        defer { isExporting = false }

        do {
            let exportData = try await exportUserDataUseCase.execute()
            let fileData = try UserDataExportFileBuilder.makeFileData(export: exportData, format: format)

            // Write to temp file
            let tempDir = FileManager.default.temporaryDirectory
            let fileExtension = UserDataExportFileBuilder.fileExtension(for: format)
            let fileName = "cravey_export_\(formattedDate()).\(fileExtension)"
            let fileURL = tempDir.appendingPathComponent(fileName)
            try fileData.write(to: fileURL)

            exportURL = fileURL
            showShareSheet = true
        } catch {
            Self.logger.error("Failed to export data: \(error.localizedDescription)")
            errorMessage = "We couldn’t export your data. Please try again."
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
            Self.logger.error("Failed to delete all data: \(error.localizedDescription)")
            errorMessage = "We couldn’t delete your data. Please try again."
            showError = true
        }
    }

    // MARK: - Helpers

    private func formattedDate() -> String {
        Self.exportFileDateFormatter.string(from: Date())
    }

    func handleExportShareCompletion(completed: Bool) {
        showShareSheet = false
        exportURL = nil
        exportSuccess = completed
    }
}
