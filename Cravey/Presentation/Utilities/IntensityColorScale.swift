import SwiftUI

/// Unified intensity color scale for consistent UX across the app
/// Used by: IntensitySlider, CravingListView
///
/// Scale:
/// - 1-3: Green (Low intensity)
/// - 4-6: Yellow (Moderate intensity)
/// - 7-9: Orange (High intensity)
/// - 10: Red (Severe intensity)
enum IntensityColorScale {
    /// Returns the appropriate color for a given intensity (1-10 scale)
    static func color(for intensity: Int) -> Color {
        switch intensity {
        case 1 ... 3: .green
        case 4 ... 6: .yellow
        case 7 ... 9: .orange
        case 10: .red
        default: .gray
        }
    }
}
