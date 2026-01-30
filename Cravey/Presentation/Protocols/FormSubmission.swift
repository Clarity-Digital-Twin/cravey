import Foundation

/// Protocol for ViewModels that handle form submission state
/// Extracts common loading/error/success pattern (DEBT-022)
@MainActor
protocol FormSubmission: AnyObject {
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
    var didSucceed: Bool { get set }
}

extension FormSubmission {
    /// Execute an async operation with loading state management
    /// Sets isLoading=true before, isLoading=false after, handles errors
    func withLoadingState<T>(_ operation: () async throws -> T) async throws -> T {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            return try await operation()
        } catch let cancellationError as CancellationError {
            // Cancellation is flow control, not an error to surface
            throw cancellationError
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// Mark the form submission as successful
    /// Used to trigger sheet dismissal and success feedback
    func markSuccess() {
        didSucceed = true
    }

    /// Handle an error by setting the error message
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
    }
}
