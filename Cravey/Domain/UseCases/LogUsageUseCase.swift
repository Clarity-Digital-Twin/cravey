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

        // Validate amount range for method
        guard ROAAmountRange.isValid(method: request.method, amount: request.amount) else {
            throw UsageError.amountOutOfRange
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
            throw UsageError.saveFailed
        }

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
