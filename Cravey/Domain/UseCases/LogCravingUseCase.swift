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

final class DefaultLogCravingUseCase: LogCravingUseCase, Sendable {
    private let repository: CravingRepositoryProtocol
    private let clock: any Clock

    init(repository: CravingRepositoryProtocol, clock: any Clock = SystemClock()) {
        self.repository = repository
        self.clock = clock
    }

    func execute(
        timestamp: Date,
        intensity: Int,
        triggers: [String],
        notes: String?,
        location: String?
    ) async throws -> CravingEntity {
        // Business rules / validation
        guard intensity >= 1, intensity <= 10 else {
            throw CravingError.invalidIntensity
        }

        // Validate timestamp not in future (DEBT-038: uses injected clock)
        guard timestamp <= clock.now() else {
            throw CravingError.futureTimestamp
        }

        // Validate notes length (per DATA_MODEL_SPEC.md:275)
        if let notes, notes.count > ValidationLimits.notesMaxLength {
            throw CravingError.notesTooLong
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
        do {
            try await repository.save(craving)
        } catch let cancellationError as CancellationError {
            throw cancellationError
        } catch {
            throw CravingError.saveFailed(underlying: error.localizedDescription)
        }

        return craving
    }
}

enum CravingError: LocalizedError, Sendable {
    case invalidIntensity
    case futureTimestamp
    case notesTooLong
    case saveFailed(underlying: String)

    var failureReason: String? {
        switch self {
        case let .saveFailed(underlying):
            underlying
        default:
            nil
        }
    }

    var errorDescription: String? {
        switch self {
        case .invalidIntensity:
            "Please choose an intensity between 1 and 10"
        case .futureTimestamp:
            "The timestamp can't be in the future"
        case .notesTooLong:
            "Notes are limited to \(ValidationLimits.notesMaxLength) characters"
        case .saveFailed:
            "We couldn't save your entry. Please try again."
        }
    }
}
