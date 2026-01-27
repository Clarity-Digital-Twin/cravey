import Foundation

enum TimestampValidation {
    static let warningThresholdDays = 7

    static func isOlderThanWarningThreshold(timestamp: Date, now: Date) -> Bool {
        guard let thresholdDate = Calendar.current.date(byAdding: .day, value: -warningThresholdDays, to: now) else {
            return false
        }

        return timestamp < thresholdDate
    }
}
