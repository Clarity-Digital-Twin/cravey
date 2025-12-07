import Foundation
import UIKit // For UINotificationFeedbackGenerator (UX_FLOW:396-405)

/// ViewModel for logging new cravings
/// Presentation layer - prepares data for UI, handles user actions
/// Source: CLINICAL_CANNABIS_SPEC.md lines 185-211, MVP_PRODUCT_SPEC.md lines 119-139
@Observable
@MainActor
final class CravingLogViewModel {
    // UI State (matches spec fields exactly)
    var intensity: Double = 5
    var timestamp: Date = .init() // REQUIRED: Auto "now", editable (CLINICAL_CANNABIS_SPEC.md:193)
    var selectedTriggers: Set<String> = []
    var notes: String = ""
    var location: String = ""
    var isLoading: Bool = false
    var didSucceed: Bool = false // Signal success to parent (UX_FLOW:396-405) - toast, not alert
    var errorMessage: String?
    var showTimestampWarning: Bool = false

    // Private state for timestamp confirmation flow
    @ObservationIgnored
    private var hasAcknowledgedOldTimestamp: Bool = false

    // Dependencies (injected)
    private let logCravingUseCase: LogCravingUseCase

    init(logCravingUseCase: LogCravingUseCase) {
        self.logCravingUseCase = logCravingUseCase
    }

    // MARK: - Actions

    func logCraving() async {
        // Check for old timestamp warning (only if not already acknowledged)
        if isTimestampOld, !hasAcknowledgedOldTimestamp {
            showTimestampWarning = true
            return // Wait for user to confirm
        }

        // Validate notes length (500 char limit per DATA_MODEL_SPEC.md:275)
        if notes.count > 500 {
            errorMessage = "Notes cannot exceed 500 characters"
            return
        }

        guard canSubmit else { return }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await logCravingUseCase.execute(
                timestamp: timestamp,
                intensity: Int(intensity),
                triggers: Array(selectedTriggers),
                notes: notes.isEmpty ? nil : notes,
                location: location.isEmpty ? nil : location
            )

            // Trigger haptic + signal success (UX_FLOW:396-405)
            triggerSuccessFeedback()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func confirmOldTimestamp() async {
        // User confirmed they want to log old timestamp
        showTimestampWarning = false
        hasAcknowledgedOldTimestamp = true // Mark as acknowledged to prevent re-triggering
        await logCraving() // Reuse existing logic - no duplication
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

    func resetForm() {
        intensity = 5
        timestamp = Date()
        selectedTriggers = []
        notes = ""
        location = ""
        hasAcknowledgedOldTimestamp = false
        didSucceed = false
    }

    // MARK: - Computed Properties for UI

    /// Check if timestamp is >7 days old (DATA_MODEL_SPEC:117)
    var isTimestampOld: Bool {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return timestamp < sevenDaysAgo
    }

    var intensityColor: String {
        switch Int(intensity) {
        case 1 ... 3: return "green"
        case 4 ... 6: return "orange"
        case 7 ... 10: return "red"
        default: return "gray"
        }
    }

    var intensityDescription: String {
        switch Int(intensity) {
        case 1 ... 3: return "Mild - Manageable discomfort"
        case 4 ... 6: return "Moderate - Noticeable urge"
        case 7 ... 10: return "Intense - Strong urge"
        default: return ""
        }
    }

    var canSubmit: Bool {
        !isLoading
    }

    var notesCharacterCount: String {
        "\(notes.count)/500"
    }

    var notesExceedsLimit: Bool {
        notes.count > 500
    }
}
