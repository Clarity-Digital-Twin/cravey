import XCTest

/// Page Object for Log tab.
/// Tests logging craving and usage entry points.
final class LogScreen: BaseScreen {
    // MARK: - Elements

    /// Log Craving button - SwiftUI views with accessibilityIdentifier
    var logCravingButton: XCUIElement {
        // Try buttons first, then fall back to descendants for SwiftUI custom buttons
        let button = app.buttons["logCravingButton"]
        if button.exists { return button }
        return app.descendants(matching: .any).matching(identifier: "logCravingButton").firstMatch
    }

    /// Log Usage button - SwiftUI views with accessibilityIdentifier
    var logUsageButton: XCUIElement {
        let button = app.buttons["logUsageButton"]
        if button.exists { return button }
        return app.descendants(matching: .any).matching(identifier: "logUsageButton").firstMatch
    }

    /// The Log tab no longer has a navigation title (removed for cleaner UX)
    /// This element checks for the "What would you like to log?" prompt instead
    var logPromptText: XCUIElement {
        app.staticTexts["What would you like to log?"]
    }

    /// "Log Craving" text as fallback for button detection
    var logCravingText: XCUIElement {
        app.staticTexts["Log Craving"]
    }

    /// "Log Usage" text as fallback for button detection
    var logUsageText: XCUIElement {
        app.staticTexts["Log Usage"]
    }

    var successToast: XCUIElement {
        // Toast is a SwiftUI container with an explicit accessibility identifier for deterministic matching.
        app.descendants(matching: .any).matching(identifier: "successToast").firstMatch
    }

    // MARK: - Actions

    func tapLogCraving() {
        // Strategy 1: Try button by identifier
        let button = app.buttons["logCravingButton"]
        if button.waitForExistence(timeout: 2) {
            button.tap()
            return
        }

        // Strategy 2: Try descendants with identifier (custom SwiftUI views)
        let descendant = app.descendants(matching: .any).matching(identifier: "logCravingButton").firstMatch
        if descendant.waitForExistence(timeout: 2) {
            descendant.tap()
            return
        }

        // Strategy 3: Find text "Log Craving" and tap it
        let text = app.staticTexts["Log Craving"]
        if text.waitForExistence(timeout: 2) {
            text.tap()
        }
    }

    func tapLogUsage() {
        // Strategy 1: Try button by identifier
        let button = app.buttons["logUsageButton"]
        if button.waitForExistence(timeout: 2) {
            button.tap()
            return
        }

        // Strategy 2: Try descendants with identifier (custom SwiftUI views)
        let descendant = app.descendants(matching: .any).matching(identifier: "logUsageButton").firstMatch
        if descendant.waitForExistence(timeout: 2) {
            descendant.tap()
            return
        }

        // Strategy 3: Find text "Log Usage" and tap it
        let text = app.staticTexts["Log Usage"]
        if text.waitForExistence(timeout: 2) {
            text.tap()
        }
    }

    // MARK: - Verifications

    func verifyLogScreenLoaded() -> Bool {
        // Check for the prompt text or button (no nav title anymore)
        return waitForElement(logPromptText) ||
            logCravingButton.waitForExistence(timeout: 3) ||
            logCravingText.waitForExistence(timeout: 3)
    }

    func verifySuccessToastAppears(timeout: TimeInterval = 3) -> Bool {
        waitForElement(successToast, timeout: timeout)
    }

    func verifySuccessToastDisappears(timeout: TimeInterval = 5) -> Bool {
        waitForElementToDisappear(successToast, timeout: timeout)
    }
}
