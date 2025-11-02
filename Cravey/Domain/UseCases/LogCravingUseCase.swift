import Foundation

/// Use Case: Log a new craving episode
/// Encapsulates business rules for craving logging
/// Source: DATA_MODEL_SPEC.md lines 260-305, CLINICAL_CANNABIS_SPEC.md lines 185-211
protocol LogCravingUseCase: Sendable {
    func execute(
        timestamp: Date,
        intensity: Int,
        triggers: [String],
        notes: String?,
        location: String?
    ) async throws -> CravingEntity
}

final class DefaultLogCravingUseCase: LogCravingUseCase {
    private let repository: CravingRepositoryProtocol

    init(repository: CravingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        timestamp: Date,
        intensity: Int,
        triggers: [String],
        notes: String?,
        location: String?
    ) async throws -> CravingEntity {
        // Business rules / validation
        guard intensity >= 1 && intensity <= 10 else {
            throw CravingError.invalidIntensity
        }

        // Validate timestamp not in future
        guard timestamp <= Date() else {
            throw CravingError.futureTimestamp
        }

        // Create entity with explicit timestamp
        let craving = CravingEntity(
            timestamp: timestamp,
            intensity: intensity,
            triggers: triggers,
            location: location,
            notes: notes
        )

        // Persist via repository
        try await repository.save(craving)

        return craving
    }
}

enum CravingError: LocalizedError {
    case invalidIntensity
    case futureTimestamp

    var errorDescription: String? {
        switch self {
        case .invalidIntensity:
            return "Intensity must be between 1 and 10"
        case .futureTimestamp:
            return "Timestamp cannot be in the future"
        }
    }
}
