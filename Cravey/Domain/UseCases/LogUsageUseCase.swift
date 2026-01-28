import Foundation

/// Protocol for logging usage (dependency inversion)
protocol LogUsageUseCase: Sendable {
    func execute(_ request: LogUsageRequest) async throws -> UsageEntity
}

/// Request object for logging usage (reduces parameter count, improves call-site clarity)
struct LogUsageRequest: Sendable, Equatable {
    let timestamp: Date
    let method: String
    let amount: Double
    let triggers: [String]
    let location: String?
    let notes: String?

    init(
        timestamp: Date = Date(),
        method: String,
        amount: Double,
        triggers: [String] = [],
        location: String? = nil,
        notes: String? = nil
    ) {
        self.timestamp = timestamp
        self.method = method
        self.amount = amount
        self.triggers = triggers
        self.location = location
        self.notes = notes
    }
}

/// Default implementation with validation
final class DefaultLogUsageUseCase: LogUsageUseCase, Sendable {
    private let repository: UsageRepositoryProtocol

    init(repository: UsageRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ request: LogUsageRequest) async throws -> UsageEntity {
        // Validate method (must be one of 6 ROAs)
        guard ROAAmountRange.validMethods.contains(request.method) else {
            throw UsageError.invalidMethod
        }

        // Validate amount (must be >0)
        guard request.amount > 0 else {
            throw UsageError.invalidAmount
        }

        // Validate timestamp not in future
        guard request.timestamp <= Date() else {
            throw UsageError.futureTimestamp
        }

        // Validate amount range for method
        guard ROAAmountRange.isValid(method: request.method, amount: request.amount) else {
            throw UsageError.amountOutOfRange
        }

        // Validate notes length (per DATA_MODEL_SPEC.md:122)
        if let notes = request.notes, notes.count > ValidationLimits.notesMaxLength {
            throw UsageError.notesTooLong
        }

        // Create entity
        let entity = UsageEntity(
            timestamp: request.timestamp,
            method: request.method,
            amount: request.amount,
            triggers: request.triggers,
            location: request.location,
            notes: request.notes
        )

        // Save to repository
        do {
            try await repository.save(entity)
        } catch let cancellationError as CancellationError {
            throw cancellationError
        } catch {
            throw UsageError.saveFailed(underlying: error.localizedDescription)
        }

        return entity
    }
}

/// Usage-specific errors
enum UsageError: LocalizedError, Sendable {
    case invalidMethod
    case invalidAmount
    case futureTimestamp
    case amountOutOfRange
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
        case .invalidMethod:
            "Please select a valid method (Bowls, Joints, Blunts, Vape, Dab, or Edible)"
        case .invalidAmount:
            "Please enter an amount greater than zero"
        case .futureTimestamp:
            "The timestamp can't be in the future"
        case .amountOutOfRange:
            "Please choose an amount within the valid range for this method"
        case .notesTooLong:
            "Notes are limited to 500 characters"
        case .saveFailed:
            "We couldn't save your entry. Please try again."
        }
    }
}
