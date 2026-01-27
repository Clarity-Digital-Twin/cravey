import XCTest

/// Tests for basic app launch and navigation.
/// Verifies the 4-tab structure loads correctly.
final class AppLaunchTests: XCTestCase {
    private var app: XCUIApplication!
    private var homeScreen: HomeScreen!
    private var logScreen: LogScreen!
    private var historyScreen: HistoryScreen!
    private var settingsScreen: SettingsScreen!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = launchCraveyApp()

        // Initialize page objects
        homeScreen = HomeScreen(app: app)
        logScreen = LogScreen(app: app)
        historyScreen = HistoryScreen(app: app)
        settingsScreen = SettingsScreen(app: app)
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        homeScreen = nil
        logScreen = nil
        historyScreen = nil
        settingsScreen = nil
        try super.tearDownWithError()
    }

    // MARK: - Launch Tests

    func testAppLaunchesWithHomeTab() throws {
        // Given: App is launched
        // Then: Home tab should be visible with dashboard
        XCTAssertTrue(homeScreen.verifyDashboardLoaded(), "Dashboard should load on app launch")
    }

    func testAllTabsAccessible() throws {
        // Given: App is launched on Home tab
        XCTAssertTrue(homeScreen.verifyDashboardLoaded())

        // When: Navigate to Log tab
        homeScreen.navigateToLog()
        // Then: Log screen should load
        XCTAssertTrue(logScreen.verifyLogScreenLoaded(), "Log screen should load")

        // When: Navigate to History tab
        logScreen.navigateToHistory()
        // Then: History screen should load
        XCTAssertTrue(historyScreen.verifyHistoryScreenLoaded(), "History screen should load")

        // When: Navigate to Settings tab
        historyScreen.navigateToSettings()
        // Then: Settings screen should load
        XCTAssertTrue(settingsScreen.verifySettingsScreenLoaded(), "Settings screen should load")

        // When: Navigate back to Home tab
        settingsScreen.navigateToHome()
        // Then: Home screen should load again
        XCTAssertTrue(homeScreen.verifyDashboardLoaded(), "Home screen should load again")
    }

    func testTabBarPersistsAcrossNavigation() throws {
        // Given: App is launched
        // Then: All tab bar buttons should be visible
        XCTAssertTrue(homeScreen.homeTab.waitForExistence(timeout: 5), "Home tab should exist")
        XCTAssertTrue(homeScreen.logTab.waitForExistence(timeout: 5), "Log tab should exist")
        XCTAssertTrue(homeScreen.historyTab.waitForExistence(timeout: 5), "History tab should exist")
        XCTAssertTrue(homeScreen.settingsTab.waitForExistence(timeout: 5), "Settings tab should exist")
    }
}
