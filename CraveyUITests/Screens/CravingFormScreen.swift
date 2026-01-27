import XCTest

/// Page Object for Craving Log Form (sheet).
/// Tests craving logging flow.
final class CravingFormScreen: BaseScreen {
    // MARK: - Elements

    var navigationTitle: XCUIElement {
        app.navigationBars["Log Craving"]
    }

    var cancelButton: XCUIElement {
        // Try by identifier first, then by "Cancel" label
        let byId = app.buttons["cravingFormCancelButton"]
        if byId.exists { return byId }
        let byLabel = app.buttons["Cancel"]
        if byLabel.exists { return byLabel }
        return app.descendants(matching: .button).matching(identifier: "cravingFormCancelButton").firstMatch
    }

    var saveButton: XCUIElement {
        // Try by identifier first, then by "Save" label
        let byId = app.buttons["cravingFormSaveButton"]
        if byId.exists { return byId }
        let byLabel = app.buttons["Save"]
        if byLabel.exists { return byLabel }
        return app.descendants(matching: .button).matching(identifier: "cravingFormSaveButton").firstMatch
    }

    var intensitySlider: XCUIElement {
        app.sliders.firstMatch
    }

    // Trigger chips (by text)
    func triggerChip(_ name: String) -> XCUIElement {
        app.staticTexts[name]
    }

    // Location chips (by text)
    func locationChip(_ name: String) -> XCUIElement {
        app.staticTexts[name]
    }

    var notesField: XCUIElement {
        app.textFields["Notes"]
    }

    // MARK: - Actions

    func cancel() {
        cancelButton.tap()
    }

    func save() {
        saveButton.tap()
    }

    func setIntensity(_ normalizedValue: CGFloat) {
        guard intensitySlider.exists else { return }
        intensitySlider.adjust(toNormalizedSliderPosition: normalizedValue)
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
        guard notesField.exists else { return }
        notesField.tap()
        notesField.typeText(text)
    }

    // MARK: - Verifications

    func verifyFormLoaded() -> Bool {
        // Primary check: navigation bar
        guard waitForElement(navigationTitle) else { return false }
        // Secondary: look for Save button OR the "Intensity" text (always on form)
        return saveButton.waitForExistence(timeout: 3) ||
            app.staticTexts["Intensity"].waitForExistence(timeout: 3)
    }

    func verifySaveEnabled() -> Bool {
        saveButton.isEnabled
    }

    func verifyFormDismissed(timeout: TimeInterval = 3) -> Bool {
        waitForElementToDisappear(navigationTitle, timeout: timeout)
    }
}
