import XCTest

/// Shared utilities for UI testing.
/// Launch configuration and common helpers.

extension XCTestCase {
    /// Launch app configured for UI testing
    @MainActor
    func launchCraveyApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        return app
    }
}

// MARK: - Screenshot Helpers

extension XCTestCase {
    /// Take a screenshot and attach to test results
    func takeScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
