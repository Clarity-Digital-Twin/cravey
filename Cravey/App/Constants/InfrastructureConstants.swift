import Foundation

/// Infrastructure-level constants (App/Data layer concerns)
/// DEBT-040: Moved from Presentation/AppConstants to proper layer
enum InfrastructureConstants {
    /// Location service configuration
    enum Location {
        /// Timeout for GPS location requests (seconds)
        static let requestTimeout: TimeInterval = 10.0
    }

    /// Storage limits
    enum Storage {
        /// Maximum total bytes for all recordings (500 MB)
        static let maxRecordingBytes: Int64 = 500_000_000
    }
}
