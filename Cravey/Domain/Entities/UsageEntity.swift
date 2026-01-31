import Foundation

/// Domain entity for usage tracking (no UI framework dependencies)
/// Source: DATA_MODEL_SPEC.md lines 75-124
struct UsageEntity: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: UUID
    let timestamp: Date
    let method: String // ROA: must be one of ["Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible"]
    let amount: Double // Must be >0, range validated by method
    let triggers: [String] // HAALT triggers (0-10 items, validated in use case)
    let location: String? // GPS "lat,long" OR preset name
    let notes: String? // ≤500 chars (enforced in UI, not here)
    let createdAt: Date
    let modifiedAt: Date?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        method: String,
        amount: Double,
        triggers: [String] = [],
        location: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        modifiedAt: Date? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.method = method
        self.amount = amount
        self.triggers = triggers
        self.location = location
        self.notes = notes
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}
