import XCTest

/// Page Object for Log tab.
/// Tests logging craving and usage entry points.
@MainActor
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

    var navigationTitle: XCUIElement {
        app.navigationBars["Log Entry"]
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
        // Toast contains either "Craving logged" or "Usage logged"
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'logged'")).firstMatch
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
        guard waitForElement(navigationTitle) else { return false }
        // Check for either button or text label
        return logCravingButton.waitForExistence(timeout: 3) ||
               logCravingText.waitForExistence(timeout: 3)
    }

    func verifySuccessToastAppears(timeout: TimeInterval = 3) -> Bool {
        waitForElement(successToast, timeout: timeout)
    }

    func verifySuccessToastDisappears(timeout: TimeInterval = 5) -> Bool {
        waitForElementToDisappear(successToast, timeout: timeout)
    }
}
