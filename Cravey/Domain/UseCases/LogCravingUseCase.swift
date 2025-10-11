import Foundation

/// Use Case: Log a new craving episode
/// Encapsulates business rules for craving logging
protocol LogCravingUseCase: Sendable {
    func execute(
        intensity: Int,
        trigger: String?,
        notes: String?,
        location: String?,
        wasManagedSuccessfully: Bool
    ) async throws -> CravingEntity
}

final class DefaultLogCravingUseCase: LogCravingUseCase {
    private let repository: CravingRepositoryProtocol

    init(repository: CravingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        intensity: Int,
        trigger: String?,
        notes: String?,
        location: String?,
        wasManagedSuccessfully: Bool
    ) async throws -> CravingEntity {
        // Business rules / validation
        guard intensity >= 1 && intensity <= 10 else {
            throw CravingError.invalidIntensity
        }

        // Create entity
        let craving = CravingEntity(
            intensity: intensity,
            trigger: trigger,
            notes: notes,
            location: location,
            wasManagedSuccessfully: wasManagedSuccessfully
        )

        // Persist via repository
        try await repository.save(craving)

        return craving
    }
}

enum CravingError: LocalizedError {
    case invalidIntensity

    var errorDescription: String? {
        switch self {
        case .invalidIntensity:
            return "Intensity must be between 1 and 10"
        }
    }
}
