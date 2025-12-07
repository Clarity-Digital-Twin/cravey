import Foundation

/// Shared error type for all repository implementations
/// Data layer - used by CravingRepository, UsageRepository, etc.
enum RepositoryError: LocalizedError {
    case notFound(id: UUID? = nil)
    case saveFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    case deleteFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case let .notFound(id):
            if let id {
                return "Item not found with ID: \(id.uuidString)"
            }
            return "Item not found"
        case let .saveFailed(underlying):
            return "Failed to save: \(underlying.localizedDescription)"
        case let .fetchFailed(underlying):
            return "Failed to fetch: \(underlying.localizedDescription)"
        case let .deleteFailed(underlying):
            return "Failed to delete: \(underlying.localizedDescription)"
        }
    }
}
