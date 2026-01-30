import Foundation

/// Centralized application constants
/// Single source of truth for magic numbers (DEBT-034)
enum AppConstants {
    /// Location service configuration
    enum Location {
        /// Timeout for GPS location requests (seconds)
        static let requestTimeout: TimeInterval = 10.0
        /// Maximum retries when waiting for authorization status
        static let maxAuthRetries: Int = 10
    }

    /// Default values for form fields
    enum FormDefaults {
        /// Default usage amount for new entries (matches first valid option for "Bowls")
        static let usageAmount: Double = 0.5
    }

    /// Storage limits
    enum Storage {
        /// Maximum total bytes for all recordings (500 MB)
        static let maxRecordingBytes: Int64 = 500_000_000
    }
}
