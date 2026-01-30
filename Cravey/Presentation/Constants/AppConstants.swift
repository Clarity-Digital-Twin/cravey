import Foundation

/// Presentation-layer constants (UI defaults, form values)
/// DEBT-040: Infrastructure constants moved to App/Constants/InfrastructureConstants.swift
enum AppConstants {
    /// Default values for form fields
    enum FormDefaults {
        /// Default usage amount for new entries (matches first valid option for "Bowls")
        static let usageAmount: Double = 0.5
    }
}
