/// Single source of truth for ROA (Route of Administration) methods
/// DEBT-041: Replaces stringly-typed method in UsageEntity
/// Maintains backward compatibility by storing rawValue as String in SwiftData
enum UsageMethod: String, CaseIterable, Codable, Sendable {
    case bowls = "Bowls"
    case joints = "Joints"
    case blunts = "Blunts"
    case vape = "Vape"
    case dab = "Dab"
    case edible = "Edible"

    /// Valid amount options for this method
    /// Source: DATA_MODEL_SPEC.md lines 140-153
    var amountRange: [Double] {
        switch self {
        case .bowls, .joints, .blunts:
            Array(stride(from: 0.5, through: 5.0, by: 0.5))
        case .vape:
            Array(1 ... 10).map { Double($0) }
        case .dab:
            Array(1 ... 5).map { Double($0) }
        case .edible:
            Array(stride(from: 5.0, through: 100.0, by: 5.0))
        }
    }

    /// Check if an amount is valid for this method
    func isValidAmount(_ amount: Double) -> Bool {
        amountRange.contains(amount)
    }

    /// Format amount for display (e.g., "2.5 bowls", "10mg")
    func formatAmount(_ amount: Double) -> String {
        switch self {
        case .bowls: "\(formatDecimal(amount)) bowls"
        case .joints: "\(formatDecimal(amount)) joints"
        case .blunts: "\(formatDecimal(amount)) blunts"
        case .vape: "\(Int(amount)) pulls"
        case .dab: "\(Int(amount)) dabs"
        case .edible: "\(Int(amount))mg"
        }
    }

    /// Format decimal: 1.0 → "1", 2.5 → "2.5"
    private func formatDecimal(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(value))"
            : "\(value)"
    }
}
