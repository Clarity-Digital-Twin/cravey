import Foundation

/// Protocol for logging usage (dependency inversion)
protocol LogUsageUseCase: Sendable {
    func execute(
        timestamp: Date,
        method: String,
        amount: Double,
        triggers: [String],
        location: String?,
        notes: String?
    ) async throws -> UsageEntity
}

/// Default implementation with validation
final class DefaultLogUsageUseCase: LogUsageUseCase {
    private let repository: UsageRepositoryProtocol

    init(repository: UsageRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        timestamp: Date = Date(),
        method: String,
        amount: Double,
        triggers: [String] = [],
        location: String? = nil,
        notes: String? = nil
    ) async throws -> UsageEntity {
        // Validate method (must be one of 6 ROAs)
        guard ROAAmountRange.validMethods.contains(method) else {
            throw UsageError.invalidMethod
        }

        // Validate amount (must be >0)
        guard amount > 0 else {
            throw UsageError.invalidAmount
        }

        // Validate amount range for method
        guard ROAAmountRange.isValid(method: method, amount: amount) else {
            throw UsageError.amountOutOfRange
        }

        // Create entity
        let entity = UsageEntity(
            timestamp: timestamp,
            method: method,
            amount: amount,
            triggers: triggers,
            location: location,
            notes: notes
        )

        // Save to repository
        try await repository.save(entity)

        return entity
    }
}

/// Usage-specific errors
enum UsageError: LocalizedError {
    case invalidMethod
    case invalidAmount
    case amountOutOfRange
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .invalidMethod:
            "Invalid method. Must be one of: Bowls, Joints, Blunts, Vape, Dab, Edible"
        case .invalidAmount:
            "Amount must be greater than zero"
        case .amountOutOfRange:
            "Amount is outside valid range for this method"
        case .saveFailed:
            "Failed to save usage"
        }
    }
}
