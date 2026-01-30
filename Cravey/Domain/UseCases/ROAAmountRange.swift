/// ROA (Route of Administration) amount range validation
/// Source: DATA_MODEL_SPEC.md lines 140-153
/// DEBT-041: Delegates to UsageMethod enum for validation logic
enum ROAAmountRange {
    /// Valid ROA method names (case-sensitive)
    /// Source: CLINICAL_CANNABIS_SPEC.md lines 220-224
    static let validMethods: [String] = UsageMethod.allCases.map(\.rawValue)

    /// Get valid amount range for a given ROA method
    /// Returns empty array if method is invalid
    static func range(for method: String) -> [Double] {
        guard let usageMethod = UsageMethod(rawValue: method) else {
            return []
        }
        return usageMethod.amountRange
    }

    /// Check if amount is valid for given method
    static func isValid(method: String, amount: Double) -> Bool {
        guard let usageMethod = UsageMethod(rawValue: method) else {
            return false
        }
        return usageMethod.isValidAmount(amount)
    }

    /// Format amount for display (e.g., "2.5 bowls", "10mg")
    static func displayAmount(method: String, amount: Double) -> String {
        guard let usageMethod = UsageMethod(rawValue: method) else {
            return "\(amount)"
        }
        return usageMethod.formatAmount(amount)
    }
}
