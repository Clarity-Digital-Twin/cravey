import Foundation

/// Static location presets for craving logging
/// Source: CLINICAL_CANNABIS_SPEC.md lines 200-201, DATA_MODEL_SPEC.md lines 199-205
enum LocationOptions {
    static let presets: [String] = [
        "Home",
        "Work",
        "Social",
        "Outside",
        "Car",
    ]

    /// Check if location string is GPS coordinate
    static func isGPS(_ location: String) -> Bool {
        location.contains(",")
    }

    /// Display-friendly location name
    static func displayLocation(_ location: String?) -> String {
        guard let loc = location else { return "Unknown" }
        return isGPS(loc) ? "Current Location" : loc
    }
}
