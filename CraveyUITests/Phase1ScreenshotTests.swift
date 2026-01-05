import XCTest

@MainActor
final class Phase1ScreenshotTests: XCTestCase {
    nonisolated(unsafe) var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testCaptureAllPhase1Screens() throws {
        // Screenshot 1: Empty home state (already captured)
        sleep(1)
        takeScreenshot(named: "02_home_tab_bar")

        // Screenshot 2: Tap + button to show menu
        let plusButton = app.buttons["addButton"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5), "+ button should exist")
        plusButton.tap()
        sleep(1)
        takeScreenshot(named: "03_plus_menu")

        // Screenshot 3: Tap "Log Craving" to open form
        let logCravingButton = app.buttons["Log Craving"]
        XCTAssertTrue(logCravingButton.waitForExistence(timeout: 2), "Log Craving button should exist")
        logCravingButton.tap()
        sleep(1)
        takeScreenshot(named: "04_craving_form_empty")

        // Screenshot 4: Interact with intensity slider
        let slider = app.sliders.firstMatch
        XCTAssertTrue(slider.waitForExistence(timeout: 2), "Intensity slider should exist")
        slider.adjust(toNormalizedSliderPosition: 0.7) // Set to 7/10
        sleep(1)
        takeScreenshot(named: "05_craving_form_intensity_7")

        // Screenshot 5: Select triggers
        let anxiousChip = app.buttons["Anxious"]
        if anxiousChip.exists {
            anxiousChip.tap()
        }
        let boredChip = app.buttons["Bored"]
        if boredChip.exists {
            boredChip.tap()
        }
        sleep(1)
        takeScreenshot(named: "06_craving_form_with_triggers")

        // Screenshot 6: Select location
        let homeChip = app.buttons["Home"]
        if homeChip.exists {
            homeChip.tap()
        }
        sleep(1)
        takeScreenshot(named: "07_craving_form_with_location")

        // Screenshot 7: Add notes (scroll to notes field first)
        let notesField = app.textFields["Notes"]
        if notesField.exists {
            notesField.tap()
            notesField.typeText("First test craving - Phase 1 demo")
        }
        sleep(1)
        takeScreenshot(named: "08_craving_form_complete")

        // Screenshot 8: Tap Save
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.exists, "Save button should exist")
        saveButton.tap()

        // Wait for success alert
        let successAlert = app.alerts["Success"]
        XCTAssertTrue(successAlert.waitForExistence(timeout: 5), "Success alert should appear")
        sleep(1)
        takeScreenshot(named: "09_success_alert")

        // Screenshot 9: Dismiss alert
        let okButton = successAlert.buttons["OK"]
        okButton.tap()

        // Wait for list to refresh
        sleep(2)
        takeScreenshot(named: "10_home_with_craving")

        // Screenshot 10: Log another craving with different intensity
        app.buttons["addButton"].tap()
        sleep(1)
        app.buttons["Log Craving"].tap()
        sleep(1)

        let slider2 = app.sliders.firstMatch
        slider2.adjust(toNormalizedSliderPosition: 0.3) // Intensity 3

        let stressedChip = app.buttons["Stressed"]
        if stressedChip.exists {
            stressedChip.tap()
        }

        app.buttons["Save"].tap()
        sleep(1)

        let alert2 = app.alerts["Success"]
        if alert2.waitForExistence(timeout: 3) {
            alert2.buttons["OK"].tap()
        }

        sleep(2)
        takeScreenshot(named: "11_home_with_multiple_cravings")

        // Screenshot 11: Test pull-to-refresh
        let firstCell = app.cells.firstMatch
        if firstCell.exists {
            firstCell.swipeDown()
            sleep(2)
            takeScreenshot(named: "12_pull_to_refresh")
        }

        // Screenshot 12: Check Dashboard tab
        app.tabBars.buttons["Progress"].tap()
        sleep(1)
        takeScreenshot(named: "13_dashboard_tab")

        // Screenshot 13: Check Settings tab
        app.tabBars.buttons["Settings"].tap()
        sleep(1)
        takeScreenshot(named: "14_settings_tab")

        // Back to Home
        app.tabBars.buttons["Home"].tap()
        sleep(1)
        takeScreenshot(named: "15_final_home_view")
    }

    func takeScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        // Note: Screenshots are automatically saved to test results bundle
        // Manual file saving removed (homeDirectoryForCurrentUser unavailable on iOS)
        // Access screenshots via: Product > Show Result Bundle in Xcode
    }
}
