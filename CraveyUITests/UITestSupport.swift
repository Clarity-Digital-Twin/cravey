import XCTest

extension XCTestCase {
    @MainActor
    func launchCraveyApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        return app
    }
}
