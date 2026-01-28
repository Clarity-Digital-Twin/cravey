import Foundation
import OSLog

/// ViewModel for the Home motivation card
/// Fetches messages from repository and tracks when shown
/// Presentation layer - Clean Architecture
@Observable
@MainActor
final class HomeMotivationViewModel {
    private static let logger = Logger(subsystem: "com.cravey", category: "HomeMotivationViewModel")

    // MARK: - Dependencies (non-tracked)

    @ObservationIgnored
    private let selectMessageUseCase: SelectMotivationalMessageUseCase
    @ObservationIgnored
    private let markShownUseCase: MarkMessageShownUseCase

    // MARK: - Published State

    var currentMessage: String = ""
    var isLoading = false
    var errorMessage: String?

    // MARK: - Private State

    @ObservationIgnored
    private var currentEntity: MotivationalMessageEntity?
    @ObservationIgnored
    private var hasMarkedShown = false

    // MARK: - Initialization

    init(
        selectMessageUseCase: SelectMotivationalMessageUseCase,
        markShownUseCase: MarkMessageShownUseCase
    ) {
        self.selectMessageUseCase = selectMessageUseCase
        self.markShownUseCase = markShownUseCase
    }

    // MARK: - Actions

    /// Loads a motivational message from the repository
    func loadMessage() async {
        // Skip if already loaded
        guard currentMessage.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            if let message = try await selectMessageUseCase.execute() {
                currentEntity = message
                currentMessage = message.content
            } else {
                // Fallback to a static default if repository is empty
                currentMessage = "You're making progress. Every day counts."
            }
        } catch is CancellationError {
            // Task cancellation is flow control, not an error
            return
        } catch {
            Self.logger.error("Failed to load motivation message: \(error.localizedDescription)")
            errorMessage = "Unable to load message"
            // Use fallback
            currentMessage = "You're making progress. Every day counts."
        }
    }

    /// Marks the current message as shown (increments counter, updates timestamp)
    /// Should be called once when the message becomes visible
    func markMessageShown() async {
        guard let entity = currentEntity, !hasMarkedShown else { return }

        hasMarkedShown = true

        do {
            try await markShownUseCase.execute(entity)
        } catch {
            // Non-critical - just log
            Self.logger.warning("Failed to mark message as shown: \(error.localizedDescription)")
        }
    }
}
