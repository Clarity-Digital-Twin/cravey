import XCTest

/// Page Object for History tab.
/// Tests craving and usage history lists.
final class HistoryScreen: BaseScreen {
    // MARK: - Elements

    var navigationTitle: XCUIElement {
        app.navigationBars["History"]
    }

    var segmentPicker: XCUIElement {
        app.segmentedControls["historySegmentPicker"]
    }

    var cravingsSegment: XCUIElement {
        segmentPicker.buttons["Cravings"]
    }

    var usageSegment: XCUIElement {
        segmentPicker.buttons["Usage"]
    }

    var emptyStateCravings: XCUIElement {
        app.staticTexts["No Cravings Logged"]
    }

    var emptyStateUsage: XCUIElement {
        app.staticTexts["No Usage Logged"]
    }

    // MARK: - Actions

    func selectCravingsSegment() {
        cravingsSegment.tap()
    }

    func selectUsageSegment() {
        usageSegment.tap()
    }

    // MARK: - Verifications

    func verifyHistoryScreenLoaded() -> Bool {
        waitForElement(navigationTitle)
    }

    func verifyCravingsSegmentSelected() -> Bool {
        cravingsSegment.isSelected
    }

    func verifyUsageSegmentSelected() -> Bool {
        usageSegment.isSelected
    }

    func verifyCravingsEmptyState() -> Bool {
        waitForElement(emptyStateCravings, timeout: 3)
    }

    func verifyUsageEmptyState() -> Bool {
        waitForElement(emptyStateUsage, timeout: 3)
    }

    private var cravingEntryRow: XCUIElement {
        app.descendants(matching: .any).matching(identifier: "cravingEntryRow").firstMatch
    }

    private var usageEntryRow: XCUIElement {
        app.descendants(matching: .any).matching(identifier: "usageEntryRow").firstMatch
    }

    func waitForCravingEntry(timeout: TimeInterval = 3) -> Bool {
        cravingEntryRow.waitForExistence(timeout: timeout)
    }

    func waitForUsageEntry(timeout: TimeInterval = 3) -> Bool {
        usageEntryRow.waitForExistence(timeout: timeout)
    }

    func hasCravingEntries() -> Bool {
        app.descendants(matching: .any).matching(identifier: "cravingEntryRow").count > 0
    }

    func hasUsageEntries() -> Bool {
        app.descendants(matching: .any).matching(identifier: "usageEntryRow").count > 0
    }
}
