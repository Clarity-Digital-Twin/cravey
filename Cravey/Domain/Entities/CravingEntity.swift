import Foundation

/// Domain entity representing a craving episode
/// Pure Swift - no framework dependencies
struct CravingEntity: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let timestamp: Date
    let intensity: Int  // 1-10 scale
    let duration: TimeInterval?
    let triggers: [String]
    let notes: String?
    let location: String?
    let managementStrategy: String?
    let wasManagedSuccessfully: Bool

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        intensity: Int,
        duration: TimeInterval? = nil,
        triggers: [String] = [],
        notes: String? = nil,
        location: String? = nil,
        managementStrategy: String? = nil,
        wasManagedSuccessfully: Bool = false
    ) {
        self.id = id
        self.timestamp = timestamp
        self.intensity = intensity
        self.duration = duration
        self.triggers = triggers
        self.notes = notes
        self.location = location
        self.managementStrategy = managementStrategy
        self.wasManagedSuccessfully = wasManagedSuccessfully
    }
}

// MARK: - Business Logic (Domain)
extension CravingEntity {
    var intensityLevel: IntensityLevel {
        switch intensity {
        case 1...3: return .low
        case 4...6: return .moderate
        case 7...10: return .high
        default: return .unknown
        }
    }

    enum IntensityLevel: String {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case unknown = "Unknown"
    }

    func isWithinLast(_ hours: Int) -> Bool {
        let cutoff = Date().addingTimeInterval(-Double(hours) * 3600)
        return timestamp >= cutoff
    }
}
