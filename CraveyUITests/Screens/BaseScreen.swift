import XCTest

/// Base screen providing common functionality for all page objects.
/// Page Object Pattern - encapsulates UI element queries for maintainability.
@MainActor
class BaseScreen {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Tab Navigation

    var homeTab: XCUIElement { app.tabBars.buttons["Home"] }
    var logTab: XCUIElement { app.tabBars.buttons["Log"] }
    var historyTab: XCUIElement { app.tabBars.buttons["History"] }
    var settingsTab: XCUIElement { app.tabBars.buttons["Settings"] }

    func navigateToHome() {
        homeTab.tap()
    }

    func navigateToLog() {
        logTab.tap()
    }

    func navigateToHistory() {
        historyTab.tap()
    }

    func navigateToSettings() {
        settingsTab.tap()
    }

    // MARK: - Wait Helpers

    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        element.waitForExistence(timeout: timeout)
    }

    func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}
