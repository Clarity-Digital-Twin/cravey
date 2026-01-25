import XCTest

/// UI tests for Cravey app
/// End-to-end tests that interact with the actual UI
@MainActor
final class CraveyUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchesAndShowsEmptyState() throws {
        // Given: App is launched
        app = launchCraveyApp()

        // Then: Main tab bar is visible
        let homeTab = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 5))

        // And: Empty state message is visible
        let emptyStateMessage = app.staticTexts["No Cravings Logged"]
        XCTAssertTrue(emptyStateMessage.waitForExistence(timeout: 2))

        // And: Plus button is visible
        let plusButton = app.buttons["addButton"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 2))
    }

    func testLogCravingFlow() throws {
        // Given: App is launched
        app = launchCraveyApp()

        // When: User taps + button
        let plusButton = app.buttons["addButton"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5))
        plusButton.tap()

        // And: User taps "Log Craving"
        let logCravingButton = app.buttons["Log Craving"]
        XCTAssertTrue(logCravingButton.waitForExistence(timeout: 2))
        logCravingButton.tap()

        // Then: Craving log form is visible
        let formTitle = app.navigationBars["Log Craving"]
        XCTAssertTrue(formTitle.waitForExistence(timeout: 2))

        // And: Save button is disabled initially (would need validation to enable)
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.exists)

        // When: User adjusts intensity
        let slider = app.sliders.firstMatch
        if slider.exists {
            slider.adjust(toNormalizedSliderPosition: 0.7)
        }

        // And: User taps Save
        saveButton.tap()

        // Then: Success toast should appear (sheet dismisses, toast shows in HomeView)
        let toast = app.staticTexts["Craving logged"]
        XCTAssertTrue(toast.waitForExistence(timeout: 5))

        // Then: Form should dismiss and list should show craving (empty state gone)
        XCTAssertTrue(emptyStateGone(timeout: 2))
    }

    private func emptyStateGone(timeout: TimeInterval) -> Bool {
        let emptyState = app.staticTexts["No Cravings Logged"]
        // Wait for empty state to disappear (inverse of waitForExistence)
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: emptyState)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}
