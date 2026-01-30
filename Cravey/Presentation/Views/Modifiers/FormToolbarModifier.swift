import SwiftUI

/// Standard form toolbar with Cancel/Save buttons (DEBT-031)
/// Reduces duplicate toolbar code across form views
struct FormToolbarModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    let canSubmit: Bool
    let isLoading: Bool
    let cancelAccessibilityId: String
    let saveAccessibilityId: String
    let onSave: @MainActor () async -> Void

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier(cancelAccessibilityId)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await onSave()
                        }
                    }
                    .disabled(!canSubmit || isLoading)
                    .accessibilityIdentifier(saveAccessibilityId)
                }
            }
    }
}

extension View {
    /// Adds standard form toolbar with Cancel and Save buttons
    func formToolbar(
        canSubmit: Bool,
        isLoading: Bool,
        cancelAccessibilityId: String = "formCancelButton",
        saveAccessibilityId: String = "formSaveButton",
        onSave: @escaping @MainActor () async -> Void
    ) -> some View {
        modifier(FormToolbarModifier(
            canSubmit: canSubmit,
            isLoading: isLoading,
            cancelAccessibilityId: cancelAccessibilityId,
            saveAccessibilityId: saveAccessibilityId,
            onSave: onSave
        ))
    }
}
