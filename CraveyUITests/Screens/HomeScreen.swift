import XCTest

/// Page Object for Home tab (Dashboard).
/// Tests dashboard cards and navigation.
final class HomeScreen: BaseScreen {
    // MARK: - Elements

    /// Navigation bar with "My Recovery" title
    var navigationTitle: XCUIElement {
        app.navigationBars["My Recovery"]
    }

    /// Hero streak card - use descendants query for SwiftUI views
    var heroStreakCard: XCUIElement {
        // SwiftUI views with accessibilityIdentifier can be various types
        // Try multiple query strategies
        app.descendants(matching: .any).matching(identifier: "heroStreakCard").firstMatch
    }

    var todayStatsCard: XCUIElement {
        app.descendants(matching: .any).matching(identifier: "todayStatsCard").firstMatch
    }

    var motivationCard: XCUIElement {
        app.descendants(matching: .any).matching(identifier: "motivationCard").firstMatch
    }

    /// Look for "DAYS" text which is always visible on dashboard
    var daysLabel: XCUIElement {
        app.staticTexts["DAYS"]
    }

    /// Look for "Today" section header
    var todayHeader: XCUIElement {
        app.staticTexts["Today"]
    }

    // MARK: - Verifications

    func verifyDashboardLoaded() -> Bool {
        // Primary check: navigation title
        guard waitForElement(navigationTitle) else { return false }

        // Secondary check: look for dashboard content
        // The "DAYS" label is always visible on the hero card
        return waitForElement(daysLabel, timeout: 3) || waitForElement(todayHeader, timeout: 3)
    }

    func getStreakDays() -> String? {
        // The streak card contains the day count as a large number
        // It's typically the first large static text on the screen
        guard heroStreakCard.exists else { return nil }
        let texts = heroStreakCard.staticTexts
        return texts.element(boundBy: 0).label
    }
}
