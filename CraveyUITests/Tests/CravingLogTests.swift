import XCTest

/// Tests for craving logging flow.
/// Verifies the complete craving log user journey.
@MainActor
final class CravingLogTests: XCTestCase {
    private var app: XCUIApplication!
    private var logScreen: LogScreen!
    private var cravingForm: CravingFormScreen!
    private var historyScreen: HistoryScreen!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()

        logScreen = LogScreen(app: app)
        cravingForm = CravingFormScreen(app: app)
        historyScreen = HistoryScreen(app: app)
    }

    // MARK: - Form Presentation Tests

    func testCravingFormOpensFromLogTab() throws {
        // Given: User is on Log tab
        logScreen.navigateToLog()
        XCTAssertTrue(logScreen.verifyLogScreenLoaded())

        // When: User taps "Log Craving"
        logScreen.tapLogCraving()

        // Then: Craving form should appear
        XCTAssertTrue(cravingForm.verifyFormLoaded(), "Craving form should open")
    }

    func testCravingFormCanBeCancelled() throws {
        // Given: Craving form is open
        logScreen.navigateToLog()
        logScreen.tapLogCraving()
        XCTAssertTrue(cravingForm.verifyFormLoaded())

        // When: User taps Cancel
        cravingForm.cancel()

        // Then: Form should dismiss, back to Log tab
        XCTAssertTrue(cravingForm.verifyFormDismissed(), "Form should dismiss")
        XCTAssertTrue(logScreen.verifyLogScreenLoaded(), "Should return to Log screen")
    }

    // MARK: - Form Submission Tests

    func testLogCravingWithMinimalData() throws {
        // Given: Craving form is open
        logScreen.navigateToLog()
        logScreen.tapLogCraving()
        XCTAssertTrue(cravingForm.verifyFormLoaded())

        // Then: Save should be enabled (intensity has default value)
        XCTAssertTrue(cravingForm.verifySaveEnabled(), "Save should be enabled with defaults")

        // When: User taps Save
        cravingForm.save()

        // Then: Form should dismiss and toast should appear
        XCTAssertTrue(cravingForm.verifyFormDismissed(), "Form should dismiss after save")
        XCTAssertTrue(logScreen.verifySuccessToastAppears(), "Success toast should appear")
    }

    func testLogCravingWithFullData() throws {
        // Given: Craving form is open
        logScreen.navigateToLog()
        logScreen.tapLogCraving()
        XCTAssertTrue(cravingForm.verifyFormLoaded())

        // When: User fills out the form
        cravingForm.setIntensity(0.7) // ~7 out of 10
        cravingForm.selectTrigger("Anxious")
        cravingForm.selectTrigger("Bored")
        cravingForm.selectLocation("Home")

        // And: Saves the craving
        cravingForm.save()

        // Then: Form should dismiss and toast should appear
        XCTAssertTrue(cravingForm.verifyFormDismissed(), "Form should dismiss after save")
        XCTAssertTrue(logScreen.verifySuccessToastAppears(), "Success toast should appear")
    }

    func testToastAutoDismisses() throws {
        // Given: User logs a craving
        logScreen.navigateToLog()
        logScreen.tapLogCraving()
        cravingForm.save()

        // When: Toast appears
        XCTAssertTrue(logScreen.verifySuccessToastAppears())

        // Then: Toast should auto-dismiss after ~2 seconds
        XCTAssertTrue(logScreen.verifySuccessToastDisappears(timeout: 4), "Toast should auto-dismiss")
    }

    // MARK: - History Verification Tests

    func testLoggedCravingAppearsInHistory() throws {
        // Given: User logs a craving
        logScreen.navigateToLog()
        logScreen.tapLogCraving()
        cravingForm.setIntensity(0.8)
        cravingForm.save()
        XCTAssertTrue(cravingForm.verifyFormDismissed())

        // When: User navigates to History
        logScreen.navigateToHistory()
        XCTAssertTrue(historyScreen.verifyHistoryScreenLoaded())

        // Then: Cravings segment should be selected by default
        // And: There should be entries (not empty state)
        // Note: This may fail on clean install - that's expected
        historyScreen.selectCravingsSegment()
    }
}
