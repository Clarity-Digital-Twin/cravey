import Foundation

/// ROA (Route of Administration) amount range validation
/// Source: DATA_MODEL_SPEC.md lines 140-153
enum ROAAmountRange {
    /// Valid ROA method names (case-sensitive)
    /// Source: CLINICAL_CANNABIS_SPEC.md lines 220-224
    static let validMethods = ["Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible"]

    /// Get valid amount range for a given ROA method
    /// Returns empty array if method is invalid
    static func range(for method: String) -> [Double] {
        switch method {
        case "Bowls", "Joints", "Blunts":
            return stride(from: 0.5, through: 5.0, by: 0.5).map { $0 }
        case "Vape":
            return Array(1 ... 10).map { Double($0) }
        case "Dab":
            return Array(1 ... 5).map { Double($0) }
        case "Edible":
            return stride(from: 5.0, through: 100.0, by: 5.0).map { $0 }
        default:
            return []
        }
    }

    /// Check if amount is valid for given method
    static func isValid(method: String, amount: Double) -> Bool {
        range(for: method).contains(amount)
    }

    /// Format amount for display (e.g., "2.5 bowls", "10mg")
    static func displayAmount(method: String, amount: Double) -> String {
        switch method {
        case "Bowls": return formatDecimal(amount) + " bowls"
        case "Joints": return formatDecimal(amount) + " joints"
        case "Blunts": return formatDecimal(amount) + " blunts"
        case "Vape": return "\(Int(amount)) pulls"
        case "Dab": return "\(Int(amount)) dabs"
        case "Edible": return "\(Int(amount))mg"
        default: return "\(amount)"
        }
    }

    /// Format decimal: 1.0 → "1", 2.5 → "2.5"
    private static func formatDecimal(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(value))"
            : "\(value)"
    }
}
