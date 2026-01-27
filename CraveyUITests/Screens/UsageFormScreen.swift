import XCTest

/// Page Object for Usage Log Form (sheet).
/// Tests usage logging flow.
final class UsageFormScreen: BaseScreen {
    // MARK: - Elements

    var navigationTitle: XCUIElement {
        app.navigationBars["Log Usage"]
    }

    var cancelButton: XCUIElement {
        // Try by identifier first, then by "Cancel" label
        let byId = app.buttons["usageFormCancelButton"]
        if byId.exists { return byId }
        let byLabel = app.buttons["Cancel"]
        if byLabel.exists { return byLabel }
        return app.descendants(matching: .button).matching(identifier: "usageFormCancelButton").firstMatch
    }

    var saveButton: XCUIElement {
        // Try by identifier first, then by "Save" label
        let byId = app.buttons["usageFormSaveButton"]
        if byId.exists { return byId }
        let byLabel = app.buttons["Save"]
        if byLabel.exists { return byLabel }
        return app.descendants(matching: .button).matching(identifier: "usageFormSaveButton").firstMatch
    }

    // ROA method chips (by text)
    func methodChip(_ name: String) -> XCUIElement {
        app.staticTexts[name]
    }

    // Amount picker
    var amountPicker: XCUIElement {
        app.pickers.firstMatch
    }

    // Trigger chips (by text)
    func triggerChip(_ name: String) -> XCUIElement {
        app.staticTexts[name]
    }

    // Location chips (by text)
    func locationChip(_ name: String) -> XCUIElement {
        app.staticTexts[name]
    }

    var notesEditor: XCUIElement {
        app.textViews.firstMatch
    }

    // MARK: - Actions

    func cancel() {
        cancelButton.tap()
    }

    func save() {
        saveButton.tap()
    }

    func selectMethod(_ name: String) {
        let chip = methodChip(name)
        if chip.waitForExistence(timeout: 2) {
            chip.tap()
        }
    }

    func selectTrigger(_ name: String) {
        let chip = triggerChip(name)
        if chip.waitForExistence(timeout: 2) {
            chip.tap()
        }
    }

    func selectLocation(_ name: String) {
        let chip = locationChip(name)
        if chip.waitForExistence(timeout: 2) {
            chip.tap()
        }
    }

    func enterNotes(_ text: String) {
        guard notesEditor.exists else { return }
        notesEditor.tap()
        notesEditor.typeText(text)
    }

    // MARK: - Verifications

    func verifyFormLoaded() -> Bool {
        // Primary check: navigation bar
        guard waitForElement(navigationTitle) else { return false }
        // Secondary: look for Save button OR the "Method" text (always on form)
        return saveButton.waitForExistence(timeout: 3) ||
            app.staticTexts["Method"].waitForExistence(timeout: 3)
    }

    func verifySaveEnabled() -> Bool {
        saveButton.isEnabled
    }

    func verifyMethodChipsVisible() -> Bool {
        let methods = ["Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible"]
        return methods.allSatisfy { methodChip($0).waitForExistence(timeout: 2) }
    }

    func verifyFormDismissed(timeout: TimeInterval = 3) -> Bool {
        waitForElementToDisappear(navigationTitle, timeout: timeout)
    }
}
