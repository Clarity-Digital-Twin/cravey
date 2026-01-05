import Foundation
import UIKit // For UINotificationFeedbackGenerator

@Observable
@MainActor
final class UsageLogViewModel {
    // Dependencies
    private let logUsageUseCase: LogUsageUseCase

    // Form fields (required)
    var timestamp: Date = .init()
    var selectedMethod: String = "Bowls" {
        didSet {
            // Auto-update amount to first valid option when method changes
            updateAmountForMethod()
        }
    }

    var amount: Double = 0.5 // Default to first valid option for Bowls (DATA_MODEL_SPEC:166)

    // Form fields (optional)
    var selectedTriggers: Set<String> = []
    var selectedLocation: String?
    var notes: String = "" {
        didSet {
            // Enforce 500 char limit (DATA_MODEL_SPEC:122, UX_FLOW:391)
            if notes.count > 500 {
                notes = String(notes.prefix(500))
            }
        }
    }

    // UI state
    var didSucceed: Bool = false // Signal success to parent (UX_FLOW:396-405)
    var showTimestampWarning: Bool = false // >7 days warning (DATA_MODEL_SPEC:117)
    var errorMessage: String?
    var isLoading: Bool = false

    // Private state for timestamp confirmation flow
    @ObservationIgnored
    private var hasAcknowledgedOldTimestamp: Bool = false

    init(logUsageUseCase: LogUsageUseCase) {
        self.logUsageUseCase = logUsageUseCase
    }

    /// Validate form can be submitted
    var canSubmit: Bool {
        !selectedMethod.isEmpty && amount > 0
    }

    /// Character count for notes (show counter at 400+ chars)
    var notesCharacterCount: Int {
        notes.count
    }

    /// Show notes character counter (at 400+ chars per UX_FLOW:391)
    var shouldShowNotesCounter: Bool {
        notes.count >= 400
    }

    /// Check if timestamp is >7 days old (DATA_MODEL_SPEC:117)
    var isTimestampOld: Bool {
        guard let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            return false // Fail-safe: treat as not old if calculation fails
        }
        return timestamp < sevenDaysAgo
    }

    /// Log usage via use case
    func logUsage() async {
        // Check for old timestamp warning (only if not already acknowledged)
        if isTimestampOld, !hasAcknowledgedOldTimestamp {
            showTimestampWarning = true
            return // Wait for user to confirm
        }

        guard canSubmit else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false } // Ensures cleanup regardless of exit path

        do {
            _ = try await logUsageUseCase.execute(
                timestamp: timestamp,
                method: selectedMethod,
                amount: amount,
                triggers: Array(selectedTriggers),
                location: selectedLocation,
                notes: notes.isEmpty ? nil : notes
            )

            // Trigger haptic + toast + reset form (UX_FLOW:396-405)
            triggerSuccessFeedback()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Confirm old timestamp and proceed with logging
    func confirmOldTimestamp() async {
        showTimestampWarning = false
        hasAcknowledgedOldTimestamp = true // Mark as acknowledged to prevent re-triggering
        await logUsage() // Proceed with save
    }

    /// Trigger success feedback (haptic + signal success per UX_FLOW:396-405)
    private func triggerSuccessFeedback() {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Signal success to parent (form will dismiss, parent shows toast)
        didSucceed = true

        // Note: Form reset happens when sheet reopens (HomeView sets VM to nil)
    }

    /// Reset amount to first valid option when method changes
    /// Called automatically via didSet on selectedMethod
    func updateAmountForMethod() {
        let validAmounts = ROAAmountRange.range(for: selectedMethod)
        if let firstAmount = validAmounts.first {
            amount = firstAmount
        }
    }

    /// Reset form to defaults (called when form reopens)
    func resetForm() {
        timestamp = Date()
        selectedMethod = "Bowls"
        amount = 0.5 // First valid option for Bowls
        selectedTriggers = []
        selectedLocation = nil
        notes = ""
        showTimestampWarning = false
        hasAcknowledgedOldTimestamp = false
        didSucceed = false
    }
}
