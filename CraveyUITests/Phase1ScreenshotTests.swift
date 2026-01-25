import XCTest

@MainActor
final class Phase1ScreenshotTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchApp() {
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func testCaptureAllPhase1Screens() throws {
        launchApp()
        captureHomeAndPlusMenu()
        captureCravingFlowScreens()
        capturePostSaveAndTabs()
    }

    private func captureHomeAndPlusMenu() {
        takeScreenshot(named: "02_home_tab_bar")

        let plusButton = app.buttons["addButton"]
        XCTAssertTrue(plusButton.waitForExistence(timeout: 5), "+ button should exist")
        plusButton.tap()
        takeScreenshot(named: "03_plus_menu")
    }

    private func captureCravingFlowScreens() {
        let logCravingButton = app.buttons["Log Craving"]
        XCTAssertTrue(logCravingButton.waitForExistence(timeout: 2), "Log Craving button should exist")
        logCravingButton.tap()
        takeScreenshot(named: "04_craving_form_empty")

        let slider = app.sliders.firstMatch
        XCTAssertTrue(slider.waitForExistence(timeout: 2), "Intensity slider should exist")
        slider.adjust(toNormalizedSliderPosition: 0.7) // Set to 7/10
        takeScreenshot(named: "05_craving_form_intensity_7")

        // Select triggers (chips are Text views with onTapGesture)
        if app.staticTexts["Anxious"].exists { app.staticTexts["Anxious"].tap() }
        if app.staticTexts["Bored"].exists { app.staticTexts["Bored"].tap() }
        takeScreenshot(named: "06_craving_form_with_triggers")

        // Select location (use unambiguous label)
        if app.staticTexts["Work"].waitForExistence(timeout: 2) {
            app.staticTexts["Work"].tap()
        }
        takeScreenshot(named: "07_craving_form_with_location")

        let notesField = app.textFields["Notes"]
        if notesField.exists {
            notesField.tap()
            notesField.typeText("First test craving - Phase 1 demo")
        }
        takeScreenshot(named: "08_craving_form_complete")

        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.exists, "Save button should exist")
        saveButton.tap()
    }

    private func capturePostSaveAndTabs() {
        let toast = app.staticTexts["Craving logged"]
        XCTAssertTrue(toast.waitForExistence(timeout: 5), "Success toast should appear")
        takeScreenshot(named: "09_success_toast")

        takeScreenshot(named: "10_home_with_craving")

        // Log another craving with different intensity
        app.buttons["addButton"].tap()
        app.buttons["Log Craving"].tap()

        let slider2 = app.sliders.firstMatch
        slider2.adjust(toNormalizedSliderPosition: 0.3) // Intensity 3

        if app.staticTexts["Habit"].exists { app.staticTexts["Habit"].tap() }
        app.buttons["Save"].tap()

        XCTAssertTrue(
            app.staticTexts["Craving logged"].waitForExistence(timeout: 3),
            "Success toast should appear after second craving save"
        )
        takeScreenshot(named: "11_home_with_multiple_cravings")

        // Test pull-to-refresh
        let firstCell = app.cells.firstMatch
        if firstCell.exists {
            firstCell.swipeDown()
            takeScreenshot(named: "12_pull_to_refresh")
        }

        // Dashboard tab
        app.tabBars.buttons["Progress"].tap()
        takeScreenshot(named: "13_dashboard_tab")

        // Settings tab
        app.tabBars.buttons["Settings"].tap()
        takeScreenshot(named: "14_settings_tab")

        // Back to Home
        app.tabBars.buttons["Home"].tap()
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
