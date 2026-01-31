@testable import Cravey
import Foundation
import Testing

@Suite("SettingsViewModel Tests")
@MainActor
struct SettingsViewModelTests {
    // MARK: - Export Tests

    @Test("exportData should set exportURL and showShareSheet on success")
    func exportSuccess() async {
        let mockExportUseCase = MockExportUserDataUseCase()
        let viewModel = SettingsViewModel(
            exportUserDataUseCase: mockExportUseCase,
            deleteAllUserDataUseCase: MockDeleteAllUserDataUseCase()
        )

        await viewModel.exportData(format: .json)

        #expect(viewModel.exportURL != nil)
        #expect(viewModel.showShareSheet == true)
        #expect(viewModel.isExporting == false)
        #expect(viewModel.showError == false)
    }

    @Test("exportData should show error on failure")
    func exportFailure() async {
        let mockExportUseCase = MockExportUserDataUseCase(shouldThrow: true)
        let viewModel = SettingsViewModel(
            exportUserDataUseCase: mockExportUseCase,
            deleteAllUserDataUseCase: MockDeleteAllUserDataUseCase()
        )

        await viewModel.exportData(format: .json)

        #expect(viewModel.exportURL == nil)
        #expect(viewModel.showShareSheet == false)
        #expect(viewModel.showError == true)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isExporting == false)
    }

    @Test("exportData should work for CSV format")
    func exportCSV() async {
        let mockExportUseCase = MockExportUserDataUseCase()
        let viewModel = SettingsViewModel(
            exportUserDataUseCase: mockExportUseCase,
            deleteAllUserDataUseCase: MockDeleteAllUserDataUseCase()
        )

        await viewModel.exportData(format: .csv)

        #expect(viewModel.exportURL != nil)
        #expect(viewModel.exportURL?.pathExtension == "csv")
    }

    // MARK: - Delete Tests

    @Test("deleteAllData should set deleteSuccess on success")
    func deleteSuccess() async {
        let mockDeleteUseCase = MockDeleteAllUserDataUseCase()
        let viewModel = SettingsViewModel(
            exportUserDataUseCase: MockExportUserDataUseCase(),
            deleteAllUserDataUseCase: mockDeleteUseCase
        )

        await viewModel.deleteAllData()

        #expect(viewModel.deleteSuccess == true)
        #expect(viewModel.isDeleting == false)
        #expect(viewModel.showError == false)
        #expect(await mockDeleteUseCase.executeCallCount == 1)
    }

    @Test("deleteAllData should show error on failure")
    func deleteFailure() async {
        let mockDeleteUseCase = MockDeleteAllUserDataUseCase(shouldThrow: true)
        let viewModel = SettingsViewModel(
            exportUserDataUseCase: MockExportUserDataUseCase(),
            deleteAllUserDataUseCase: mockDeleteUseCase
        )

        await viewModel.deleteAllData()

        #expect(viewModel.deleteSuccess == false)
        #expect(viewModel.showError == true)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isDeleting == false)
    }

    // MARK: - Share Sheet Completion

    @Test("handleExportShareCompletion should reset state on completion")
    func shareCompletionResetsState() async {
        let viewModel = SettingsViewModel(
            exportUserDataUseCase: MockExportUserDataUseCase(),
            deleteAllUserDataUseCase: MockDeleteAllUserDataUseCase()
        )

        // Simulate export happened
        await viewModel.exportData(format: .json)
        #expect(viewModel.showShareSheet == true)
        #expect(viewModel.exportURL != nil)

        // User completed share
        viewModel.handleExportShareCompletion(completed: true)

        #expect(viewModel.showShareSheet == false)
        #expect(viewModel.exportURL == nil)
        #expect(viewModel.exportSuccess == true)
    }

    @Test("handleExportShareCompletion should handle cancellation")
    func shareCompletionHandlesCancellation() async {
        let viewModel = SettingsViewModel(
            exportUserDataUseCase: MockExportUserDataUseCase(),
            deleteAllUserDataUseCase: MockDeleteAllUserDataUseCase()
        )

        await viewModel.exportData(format: .json)

        // User cancelled share
        viewModel.handleExportShareCompletion(completed: false)

        #expect(viewModel.showShareSheet == false)
        #expect(viewModel.exportURL == nil)
        #expect(viewModel.exportSuccess == false)
    }

    // MARK: - App Info

    @Test("appVersion returns bundle version or fallback")
    func appVersionReturnsValue() {
        let viewModel = SettingsViewModel(
            exportUserDataUseCase: MockExportUserDataUseCase(),
            deleteAllUserDataUseCase: MockDeleteAllUserDataUseCase()
        )

        // In test environment, bundle info may not be available
        #expect(viewModel.appVersion.isEmpty == false)
    }
}

// MARK: - Mocks

actor MockExportUserDataUseCase: ExportUserDataUseCase {
    let shouldThrow: Bool

    init(shouldThrow: Bool = false) {
        self.shouldThrow = shouldThrow
    }

    func execute() async throws -> UserDataExport {
        if shouldThrow { throw MockExportError.exportFailed }

        let now = TestConstants.fixedEpoch
        return UserDataExport(
            schemaVersion: UserDataExport.currentSchemaVersion,
            exportDate: now,
            cravings: [
                CravingEntity(timestamp: now, intensity: 5, triggers: ["Stressed"]),
            ],
            usages: [
                UsageEntity(timestamp: now, method: "Bowls", amount: 1.0),
            ],
            recordings: [],
            messages: []
        )
    }
}

enum MockExportError: LocalizedError {
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .exportFailed:
            "Mock export failed"
        }
    }
}

actor MockDeleteAllUserDataUseCase: DeleteAllUserDataUseCase {
    var executeCallCount = 0
    let shouldThrow: Bool

    init(shouldThrow: Bool = false) {
        self.shouldThrow = shouldThrow
    }

    func execute() async throws {
        if shouldThrow { throw MockDeleteAllError.deleteFailed }
        executeCallCount += 1
    }
}

enum MockDeleteAllError: LocalizedError {
    case deleteFailed

    var errorDescription: String? {
        switch self {
        case .deleteFailed:
            "Mock delete all failed"
        }
    }
}
