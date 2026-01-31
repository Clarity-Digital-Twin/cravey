@testable import Cravey
import Foundation

/// Test-specific constants that extend production constants.
/// Eliminates magic numbers in test files per Clean Code principles.
enum TestConstants {
    /// Time intervals for date arithmetic in tests
    enum Time {
        static let secondsPerMinute: TimeInterval = 60
        static let secondsPerHour: TimeInterval = 3600
        static let secondsPerDay: TimeInterval = 86400
        static let hoursPerDay = 24
    }

    /// Fixed epoch for deterministic date testing.
    /// Using Sept 9, 2001 00:46:40 UTC (arbitrary but stable).
    static let fixedEpoch = Date(timeIntervalSince1970: 1_000_000_000)

    /// Notes length constants derived from production ValidationLimits
    enum Notes {
        /// One character over the max (for rejection tests)
        static var overMaxLength: Int { ValidationLimits.notesMaxLength + 1 }

        /// Exactly at max (for acceptance tests)
        static var atMaxLength: Int { ValidationLimits.notesMaxLength }
    }
}

/// Reusable FixedClock for deterministic time testing.
/// Conforms to the Clock protocol from Domain layer.
struct FixedClock: Clock, Sendable {
    let fixedNow: Date
    let calendar: Calendar

    init(fixedNow: Date = TestConstants.fixedEpoch, calendar: Calendar = Calendar(identifier: .gregorian)) {
        self.fixedNow = fixedNow
        self.calendar = calendar
    }

    func now() -> Date { fixedNow }
}
