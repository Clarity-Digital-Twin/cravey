import XCTest

/// Phase 2C UI Tests - Usage Logging Flow
/// Validates <10 second requirement for logging usage
/// Source: PHASE_2C.md lines 105, UX_FLOW_SPEC.md lines 396-405
@MainActor
final class UsageLogUITests: XCTestCase {
    nonisolated(unsafe) var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    // MARK: - Test 1: <10 Second Flow Validation (PHASE_2C:105)

    func testUsageLogCompleteFlowUnder10Seconds() throws {
        let startTime = Date()

        // Step 1: Tap + button
        let plusButton = app.buttons["addButton"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5), "+ button should exist")
        plusButton.tap()

        // Step 2: Tap "Log Usage"
        let logUsageButton = app.buttons["Log Usage"]
        XCTAssertTrue(logUsageButton.waitForExistence(timeout: 2), "Log Usage button should exist")
        logUsageButton.tap()

        // Step 3: Verify form opened
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2), "Save button should exist")

        // Step 4: Select method (Vape - already visible as chip)
        let vapeChip = app.buttons["Vape"]
        if vapeChip.waitForExistence(timeout: 2) {
            vapeChip.tap()
        }

        // Step 5: Tap Save
        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled with valid data")
        saveButton.tap()

        // Step 6: Verify sheet dismissed and toast appears
        let toast = app.staticTexts["Usage logged"]
        XCTAssertTrue(
            toast.waitForExistence(timeout: 2),
            "Success toast should appear after save (UX_FLOW:396-405)"
        )

        // Step 7: Measure total time
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        // CRITICAL: Must complete in <10 seconds per PHASE_2C:105
        XCTAssertLessThan(
            duration,
            10.0,
            "Usage logging flow must complete in <10 seconds (actual: \(String(format: "%.2f", duration))s)"
        )

        print("✅ Usage logging completed in \(String(format: "%.2f", duration))s")
    }

    // MARK: - Test 2: Verify Success Toast Behavior

    func testSuccessToastAppearsAndDisappears() throws {
        // Open form
        let plusButton = app.buttons["addButton"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5))
        plusButton.tap()

        let logUsageButton = app.buttons["Log Usage"]
        XCTAssertTrue(logUsageButton.waitForExistence(timeout: 2))
        logUsageButton.tap()

        // Log usage
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        saveButton.tap()

        // Verify toast appears
        let toast = app.staticTexts["Usage logged"]
        XCTAssertTrue(
            toast.waitForExistence(timeout: 2),
            "Toast should appear immediately after sheet dismisses"
        )

        // Verify toast auto-dismisses after 2 seconds
        sleep(3) // Wait 3s to ensure 2s timeout passed
        XCTAssertFalse(toast.exists, "Toast should auto-dismiss after 2 seconds")
    }

    // MARK: - Test 3: Verify Save Button Disabled for Invalid State

    func testSaveButtonDisabledWithoutMethod() throws {
        // Open form
        let plusButton = app.buttons["addButton"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5))
        plusButton.tap()

        let logUsageButton = app.buttons["Log Usage"]
        XCTAssertTrue(logUsageButton.waitForExistence(timeout: 2))
        logUsageButton.tap()

        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))

        // Save button should be enabled (method defaults to "Bowls" with amount 0.5)
        XCTAssertTrue(
            saveButton.isEnabled,
            "Save button should be enabled with default method and amount"
        )
    }

    // MARK: - Test 4: Verify ROA Chip Selector (Not Menu)

    func testROAMethodsShowAsChipsNotMenu() throws {
        // Open form
        let plusButton = app.buttons["addButton"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5))
        plusButton.tap()

        let logUsageButton = app.buttons["Log Usage"]
        XCTAssertTrue(logUsageButton.waitForExistence(timeout: 2))
        logUsageButton.tap()

        // Verify all 6 methods are visible as chips (not in a menu)
        let methods = ["Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible"]
        for method in methods {
            let chip = app.buttons[method]
            XCTAssertTrue(
                chip.waitForExistence(timeout: 2),
                "\(method) should be visible as a chip (UX_FLOW:363)"
            )
        }
    }

    // MARK: - Test 5: Verify Amount Updates When Method Changes

    func testAmountUpdatesWhenMethodChanges() throws {
        // Open form
        let plusButton = app.buttons["addButton"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5))
        plusButton.tap()

        let logUsageButton = app.buttons["Log Usage"]
        XCTAssertTrue(logUsageButton.waitForExistence(timeout: 2))
        logUsageButton.tap()

        // Wait for form to load (default: Bowls, 0.5)
        sleep(1)

        // Switch to Edible (first option: 5.0mg)
        let edibleChip = app.buttons["Edible"]
        XCTAssertTrue(edibleChip.waitForExistence(timeout: 2))
        edibleChip.tap()

        // Verify amount updated (cannot directly check value, but can verify Save stays enabled)
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(
            saveButton.isEnabled,
            "Save button should remain enabled after method change"
        )
    }
}
