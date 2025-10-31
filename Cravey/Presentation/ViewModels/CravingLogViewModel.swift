import Foundation

/// ViewModel for logging new cravings
/// Presentation layer - prepares data for UI, handles user actions
@Observable
@MainActor
final class CravingLogViewModel {
    // UI State
    var intensity: Double = 5
    var selectedTriggers: Set<String> = []
    var notes: String = ""
    var location: String = ""
    var wasManagedSuccessfully: Bool = false
    var isLoading: Bool = false
    var showSuccessAlert: Bool = false
    var errorMessage: String?

    // Dependencies (injected)
    private let logCravingUseCase: LogCravingUseCase

    init(logCravingUseCase: LogCravingUseCase) {
        self.logCravingUseCase = logCravingUseCase
    }

    // MARK: - Actions

    func logCraving() async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await logCravingUseCase.execute(
                intensity: Int(intensity),
                triggers: Array(selectedTriggers),
                notes: notes.isEmpty ? nil : notes,
                location: location.isEmpty ? nil : location,
                wasManagedSuccessfully: wasManagedSuccessfully
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
        selectedTriggers = []
        notes = ""
        location = ""
        wasManagedSuccessfully = false
    }

    // MARK: - Computed Properties for UI

    var intensityColor: String {
        switch Int(intensity) {
        case 1...3: return "green"
        case 4...6: return "orange"
        case 7...10: return "red"
        default: return "gray"
        }
    }

    var intensityDescription: String {
        switch Int(intensity) {
        case 1...3: return "Mild - Manageable discomfort"
        case 4...6: return "Moderate - Noticeable urge"
        case 7...10: return "Intense - Strong urge"
        default: return ""
        }
    }

    var canSubmit: Bool {
        !isLoading
    }
}
