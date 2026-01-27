import XCTest

/// Tests for usage logging flow.
/// Verifies the complete usage log user journey.
@MainActor
final class UsageLogTests: XCTestCase {
    private var app: XCUIApplication!
    private var logScreen: LogScreen!
    private var usageForm: UsageFormScreen!
    private var historyScreen: HistoryScreen!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()

        logScreen = LogScreen(app: app)
        usageForm = UsageFormScreen(app: app)
        historyScreen = HistoryScreen(app: app)
    }

    // MARK: - Form Presentation Tests

    func testUsageFormOpensFromLogTab() throws {
        // Given: User is on Log tab
        logScreen.navigateToLog()
        XCTAssertTrue(logScreen.verifyLogScreenLoaded())

        // When: User taps "Log Usage"
        logScreen.tapLogUsage()

        // Then: Usage form should appear
        XCTAssertTrue(usageForm.verifyFormLoaded(), "Usage form should open")
    }

    func testUsageFormCanBeCancelled() throws {
        // Given: Usage form is open
        logScreen.navigateToLog()
        logScreen.tapLogUsage()
        XCTAssertTrue(usageForm.verifyFormLoaded())

        // When: User taps Cancel
        usageForm.cancel()

        // Then: Form should dismiss, back to Log tab
        XCTAssertTrue(usageForm.verifyFormDismissed(), "Form should dismiss")
        XCTAssertTrue(logScreen.verifyLogScreenLoaded(), "Should return to Log screen")
    }

    // MARK: - ROA Method Tests

    func testAllROAMethodsVisible() throws {
        // Given: Usage form is open
        logScreen.navigateToLog()
        logScreen.tapLogUsage()
        XCTAssertTrue(usageForm.verifyFormLoaded())

        // Then: All 6 ROA methods should be visible as chips
        XCTAssertTrue(usageForm.verifyMethodChipsVisible(), "All ROA methods should be visible")
    }

    func testSaveEnabledWithDefaultMethod() throws {
        // Given: Usage form is open (defaults to Bowls, 0.5)
        logScreen.navigateToLog()
        logScreen.tapLogUsage()
        XCTAssertTrue(usageForm.verifyFormLoaded())

        // Then: Save should be enabled with default values
        XCTAssertTrue(usageForm.verifySaveEnabled(), "Save should be enabled with defaults")
    }

    // MARK: - Form Submission Tests

    func testLogUsageWithMinimalData() throws {
        // Given: Usage form is open
        logScreen.navigateToLog()
        logScreen.tapLogUsage()
        XCTAssertTrue(usageForm.verifyFormLoaded())

        // When: User taps Save (using defaults)
        usageForm.save()

        // Then: Form should dismiss and toast should appear
        XCTAssertTrue(usageForm.verifyFormDismissed(), "Form should dismiss after save")
        XCTAssertTrue(logScreen.verifySuccessToastAppears(), "Success toast should appear")
    }

    func testLogUsageWithDifferentMethod() throws {
        // Given: Usage form is open
        logScreen.navigateToLog()
        logScreen.tapLogUsage()
        XCTAssertTrue(usageForm.verifyFormLoaded())

        // When: User selects Vape method
        usageForm.selectMethod("Vape")

        // And: Saves
        usageForm.save()

        // Then: Form should dismiss and toast should appear
        XCTAssertTrue(usageForm.verifyFormDismissed(), "Form should dismiss after save")
        XCTAssertTrue(logScreen.verifySuccessToastAppears(), "Success toast should appear")
    }

    func testLogUsageWithFullData() throws {
        // Given: Usage form is open
        logScreen.navigateToLog()
        logScreen.tapLogUsage()
        XCTAssertTrue(usageForm.verifyFormLoaded())

        // When: User fills out the form
        usageForm.selectMethod("Edible")
        usageForm.selectTrigger("Anxious")
        usageForm.selectLocation("Home")

        // And: Saves
        usageForm.save()

        // Then: Form should dismiss and toast should appear
        XCTAssertTrue(usageForm.verifyFormDismissed(), "Form should dismiss after save")
        XCTAssertTrue(logScreen.verifySuccessToastAppears(), "Success toast should appear")
    }

    // MARK: - Performance Test

    func testUsageLogFlowUnder10Seconds() throws {
        // Spec requirement: <10 seconds to log usage
        let startTime = Date()

        // Given: User navigates to Log tab
        logScreen.navigateToLog()

        // When: User taps Log Usage
        logScreen.tapLogUsage()
        XCTAssertTrue(usageForm.verifyFormLoaded())

        // And: Saves with defaults
        usageForm.save()

        // Then: Toast should appear
        XCTAssertTrue(logScreen.verifySuccessToastAppears())

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        // Allow 12s in simulator (real device target is <10s)
        XCTAssertLessThan(duration, 12.0, "Usage log flow should complete in <12s (simulator), actual: \(duration)s")
    }
}
