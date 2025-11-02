import Foundation
import SwiftData

/// SwiftData model for cannabis usage tracking
/// Data layer - persistence schema
@Model
final class UsageModel {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var method: String // ROA: "Bowls", "Vape", "Edible", etc.
    var amount: Double
    var triggers: [String]
    var location: String?
    var notes: String?
    var createdAt: Date
    var modifiedAt: Date?

    init(
        id: UUID = UUID(),
        timestamp: Date,
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
