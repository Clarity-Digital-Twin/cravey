import SwiftUI

/// Unified intensity color scale for consistent UX across the app
/// Used by: IntensitySlider, CravingListView, DashboardView
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

    /// Returns the appropriate color for a given intensity average (Double)
    /// Used for dashboard metrics where averages may be fractional
    static func color(for intensity: Double) -> Color {
        switch intensity {
        case ..<4: .green
        case 4 ..< 7: .yellow
        case 7 ..< 10: .orange
        default: .red
        }
    }
}
