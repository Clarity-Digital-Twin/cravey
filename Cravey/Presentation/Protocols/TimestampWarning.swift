import Foundation

/// Protocol for ViewModels that handle old timestamp warnings
/// Extracts common timestamp validation logic (DEBT-024)
@MainActor
protocol TimestampWarning: AnyObject {
    var timestamp: Date { get }
    var showTimestampWarning: Bool { get set }
    /// Internal tracking for whether user acknowledged old timestamp
    /// Implementations should mark this @ObservationIgnored
    var hasAcknowledgedOldTimestampInternal: Bool { get set }
    var nowProvider: @Sendable () -> Date { get }
}

extension TimestampWarning {
    /// Check if timestamp is >7 days old (DATA_MODEL_SPEC:117)
    var isTimestampOld: Bool {
        TimestampValidation.isOlderThanWarningThreshold(timestamp: timestamp, now: nowProvider())
    }

    /// Check if the old timestamp warning should be shown
    /// Returns true if timestamp is old AND user hasn't acknowledged it yet
    func shouldShowTimestampWarning() -> Bool {
        isTimestampOld && !hasAcknowledgedOldTimestampInternal
    }

    /// Mark the old timestamp as acknowledged and dismiss the warning
    func acknowledgeOldTimestamp() {
        showTimestampWarning = false
        hasAcknowledgedOldTimestampInternal = true
    }
}
