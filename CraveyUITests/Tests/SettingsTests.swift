import XCTest

/// Tests for Settings tab flows.
/// Verifies export and delete functionality.
@MainActor
final class SettingsTests: XCTestCase {
    private var app: XCUIApplication!
    private var settingsScreen: SettingsScreen!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()

        settingsScreen = SettingsScreen(app: app)
    }

    // MARK: - Settings Screen Tests

    func testSettingsScreenLoads() throws {
        // Given: App is launched
        // When: User navigates to Settings
        settingsScreen.navigateToSettings()

        // Then: Settings screen should load with both buttons
        XCTAssertTrue(settingsScreen.verifySettingsScreenLoaded(), "Settings should load")
    }

    // MARK: - Export Tests

    func testExportSheetOpens() throws {
        // Given: User is on Settings tab
        settingsScreen.navigateToSettings()
        XCTAssertTrue(settingsScreen.verifySettingsScreenLoaded())

        // When: User taps Export Data
        settingsScreen.tapExportData()

        // Then: Export sheet should appear
        XCTAssertTrue(settingsScreen.verifyExportSheetPresented(), "Export sheet should open")
    }

    func testExportSheetCanBeCancelled() throws {
        // Given: Export sheet is open
        settingsScreen.navigateToSettings()
        settingsScreen.tapExportData()
        XCTAssertTrue(settingsScreen.verifyExportSheetPresented())

        // When: User taps Cancel
        settingsScreen.cancelExport()

        // Then: Should return to Settings screen
        XCTAssertTrue(settingsScreen.verifySettingsScreenLoaded(), "Should return to Settings")
    }

    // MARK: - Delete Tests

    func testDeleteConfirmationAppears() throws {
        // Given: User is on Settings tab
        settingsScreen.navigateToSettings()
        XCTAssertTrue(settingsScreen.verifySettingsScreenLoaded())

        // When: User taps Delete All Data
        settingsScreen.tapDeleteAllData()

        // Then: Confirmation alert should appear
        XCTAssertTrue(settingsScreen.verifyDeleteConfirmationPresented(), "Delete confirmation should appear")
    }

    func testDeleteCanBeCancelled() throws {
        // Given: Delete confirmation is showing
        settingsScreen.navigateToSettings()
        settingsScreen.tapDeleteAllData()
        XCTAssertTrue(settingsScreen.verifyDeleteConfirmationPresented())

        // When: User taps Cancel
        settingsScreen.cancelDelete()

        // Then: Should return to Settings screen
        XCTAssertTrue(settingsScreen.verifySettingsScreenLoaded(), "Should return to Settings")
    }

    // Note: We don't test actual deletion in UI tests to avoid data loss
    // The delete flow is tested in unit/integration tests
}
