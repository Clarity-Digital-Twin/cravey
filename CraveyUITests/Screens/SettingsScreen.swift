import XCTest

/// Page Object for Settings tab.
/// Tests export and delete flows.
@MainActor
final class SettingsScreen: BaseScreen {
    // MARK: - Elements

    var navigationTitle: XCUIElement {
        app.navigationBars["Settings"]
    }

    var exportDataButton: XCUIElement {
        // SwiftUI List buttons - try identifier first, then descendants
        let byId = app.buttons["exportDataButton"]
        if byId.exists { return byId }
        return app.descendants(matching: .any).matching(identifier: "exportDataButton").firstMatch
    }

    var deleteAllDataButton: XCUIElement {
        let byId = app.buttons["deleteAllDataButton"]
        if byId.exists { return byId }
        return app.descendants(matching: .any).matching(identifier: "deleteAllDataButton").firstMatch
    }

    // Export sheet elements
    var exportFormatPicker: XCUIElement {
        app.pickers["exportFormatPicker"]
    }

    var exportConfirmButton: XCUIElement {
        app.buttons["exportConfirmButton"]
    }

    var exportCancelButton: XCUIElement {
        app.buttons["exportCancelButton"]
    }

    // Delete confirmation dialog (shown as action sheet, not alert)
    var deleteConfirmationSheet: XCUIElement {
        // On iOS, confirmationDialog shows as action sheet
        app.sheets.firstMatch
    }

    var deleteConfirmButton: XCUIElement {
        // Try sheets first, then buttons directly
        let sheetButton = app.sheets.buttons["Delete Everything"]
        if sheetButton.exists { return sheetButton }
        return app.buttons["Delete Everything"]
    }

    var deleteCancelButton: XCUIElement {
        // Try sheets first, then buttons directly
        let sheetButton = app.sheets.buttons["Cancel"]
        if sheetButton.exists { return sheetButton }
        return app.buttons["Cancel"]
    }

    // MARK: - Actions

    func tapExportData() {
        exportDataButton.tap()
    }

    func tapDeleteAllData() {
        deleteAllDataButton.tap()
    }

    func confirmExport() {
        exportConfirmButton.tap()
    }

    func cancelExport() {
        exportCancelButton.tap()
    }

    func confirmDelete() {
        deleteConfirmButton.tap()
    }

    func cancelDelete() {
        // Wait for the Cancel button to appear
        if deleteCancelButton.waitForExistence(timeout: 3) {
            deleteCancelButton.tap()
        }
    }

    // MARK: - Verifications

    func verifySettingsScreenLoaded() -> Bool {
        waitForElement(navigationTitle) &&
            waitForElement(exportDataButton) &&
            waitForElement(deleteAllDataButton)
    }

    func verifyExportSheetPresented() -> Bool {
        waitForElement(exportConfirmButton, timeout: 3)
    }

    func verifyDeleteConfirmationPresented() -> Bool {
        // confirmationDialog shows as action sheet
        waitForElement(deleteConfirmationSheet, timeout: 3) ||
            deleteConfirmButton.waitForExistence(timeout: 3)
    }
}
