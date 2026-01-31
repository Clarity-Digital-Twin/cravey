import Foundation

/// Domain entity representing a craving episode
/// Domain layer - no UI framework dependencies
struct CravingEntity: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: UUID
    let timestamp: Date
    let intensity: Int // 1-10 scale
    let triggers: [String]
    let location: String?
    let notes: String?
    let createdAt: Date
    let modifiedAt: Date?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        intensity: Int,
        triggers: [String] = [],
        location: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        modifiedAt: Date? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.intensity = intensity
        self.triggers = triggers
        self.location = location
        self.notes = notes
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

// MARK: - Business Logic (Domain)

extension CravingEntity {
    var intensityLevel: IntensityLevel {
        switch intensity {
        case 1 ... 3: .low
        case 4 ... 6: .moderate
        case 7 ... 10: .high
        default: .unknown
        }
    }

    enum IntensityLevel: String {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case unknown = "Unknown"
    }

    /// Check if craving occurred within the last N hours
    /// DEBT-038: Requires explicit `now` parameter for testability
    func isWithinLast(_ hours: Int, now: Date) -> Bool {
        let cutoff = now.addingTimeInterval(-Double(hours) * 3600)
        return timestamp >= cutoff
    }
}
