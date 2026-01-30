import Foundation

/// Protocol for list ViewModels with common fetch/delete patterns (DEBT-027)
/// Provides default implementations for standard list operations
@MainActor
protocol ListViewModel: AnyObject {
    associatedtype Entity: Identifiable

    /// The list of items to display
    var items: [Entity] { get set }

    /// Whether a fetch operation is in progress
    var isLoading: Bool { get set }

    /// Error message to display, if any
    var errorMessage: String? { get set }
}

extension ListViewModel {
    /// Perform a fetch operation with loading state management
    func performFetch(_ operation: () async throws -> [Entity]) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            items = try await operation()
        } catch is CancellationError {
            // Cancellation is flow control, not an error to surface
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Perform a delete operation and remove from local list on success
    /// Note: Entity.ID must be Sendable for Swift 6 concurrency safety
    func performDelete<ID: Sendable>(id: ID, operation: @Sendable (ID) async throws -> Void) async
        where Entity.ID == ID
    {
        errorMessage = nil

        do {
            try await operation(id)
            items.removeAll { $0.id == id }
        } catch is CancellationError {
            // Cancellation is flow control, not an error to surface
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
