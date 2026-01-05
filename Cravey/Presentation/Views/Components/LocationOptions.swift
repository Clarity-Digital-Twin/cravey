import Foundation

/// Static location presets for craving logging
/// Source: CLINICAL_CANNABIS_SPEC.md lines 200-201, DATA_MODEL_SPEC.md lines 199-205
enum LocationOptions {
    /// Location presets (note: "Current Location" is placeholder for Phase 2 GPS integration)
    static let presets: [String] = [
        "Current Location", // TODO: Phase 2 - Wire CoreLocation GPS detection
        "Home",
        "Work",
        "Social",
        "Outside",
        "Car",
    ]

    /// Format GPS coordinates as string (lat,long)
    static func formatGPS(latitude: Double, longitude: Double) -> String {
        "\(latitude),\(longitude)"
    }

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
