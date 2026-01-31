import Foundation

/// Static location presets for craving logging
/// Source: CLINICAL_CANNABIS_SPEC.md lines 200-201, DATA_MODEL_SPEC.md lines 199-205
enum LocationOptions {
    /// Special key for "Current Location" GPS option
    static let currentLocationKey = "📍 Current"

    /// Location presets - Row 1: Primary locations
    static let presetsRow1: [String] = [
        currentLocationKey,
        "Home",
        "Work",
    ]

    /// Location presets - Row 2: Other locations
    static let presetsRow2: [String] = [
        "Out",
        "Other",
    ]

    /// All location presets (for backwards compat)
    static let presets: [String] = presetsRow1 + presetsRow2

    /// Check if selection is the "Current Location" chip
    static func isCurrentLocationChip(_ value: String) -> Bool {
        value == currentLocationKey
    }

    /// Format GPS coordinates as comma-separated string
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
