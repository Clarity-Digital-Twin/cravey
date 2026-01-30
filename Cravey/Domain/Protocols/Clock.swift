import Foundation

/// Domain protocol for time abstraction (enables deterministic testing)
/// DEBT-038: Removes direct Date() and Calendar.current usage from use cases
protocol Clock: Sendable {
    /// Current time
    func now() -> Date

    /// Calendar for date computations
    var calendar: Calendar { get }
}

/// Production clock using system time
struct SystemClock: Clock, Sendable {
    func now() -> Date { Date() }
    var calendar: Calendar { Calendar.current }
}
