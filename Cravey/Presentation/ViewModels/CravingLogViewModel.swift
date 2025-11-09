import Foundation

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
    var showSuccessAlert: Bool = false
    var errorMessage: String?
    var showTimestampWarning: Bool = false

    // Dependencies (injected)
    private let logCravingUseCase: LogCravingUseCase

    init(logCravingUseCase: LogCravingUseCase) {
        self.logCravingUseCase = logCravingUseCase
    }

    // MARK: - Actions

    func logCraving() async {
        isLoading = true
        errorMessage = nil

        // Validate notes length (500 char limit per DATA_MODEL_SPEC.md:275)
        if notes.count > 500 {
            errorMessage = "Notes cannot exceed 500 characters"
            isLoading = false
            return
        }

        // Check if timestamp is >7 days old (CLINICAL_CANNABIS_SPEC.md:193)
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        if timestamp < sevenDaysAgo {
            showTimestampWarning = true
            isLoading = false
            return
        }

        do {
            _ = try await logCravingUseCase.execute(
                timestamp: timestamp,
                intensity: Int(intensity),
                triggers: Array(selectedTriggers),
                notes: notes.isEmpty ? nil : notes,
                location: location.isEmpty ? nil : location
            )

            showSuccessAlert = true
            resetForm()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func confirmOldTimestamp() async {
        // User confirmed they want to log old timestamp
        showTimestampWarning = false

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

            showSuccessAlert = true
            resetForm()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func resetForm() {
        intensity = 5
        timestamp = Date()
        selectedTriggers = []
        notes = ""
        location = ""
    }

    // MARK: - Computed Properties for UI

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
