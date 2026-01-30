import Observation
import SwiftUI

/// Combined form alerts modifier for error and timestamp warning (DEBT-025)
/// Reduces duplicate alert code across CravingLogForm and UsageLogForm
struct FormAlertsModifier<ViewModel: AnyObject & FormSubmission & TimestampWarning & Observable>: ViewModifier {
    @Bindable var viewModel: ViewModel
    let entityName: String
    let confirmButtonTitle: String
    let onTimestampConfirm: () async -> Void

    func body(content: Content) -> some View {
        content
            .alert("Old Timestamp", isPresented: $viewModel.showTimestampWarning) {
                Button("Cancel", role: .cancel) {
                    viewModel.showTimestampWarning = false
                }
                Button(confirmButtonTitle) {
                    Task {
                        await onTimestampConfirm()
                    }
                }
            } message: {
                Text("This \(entityName) is more than 7 days old. Are you sure you want to log it?")
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
    }
}

extension View {
    /// Adds standard form alerts (error alert + timestamp warning)
    func formAlerts<ViewModel: AnyObject & FormSubmission & TimestampWarning & Observable>(
        viewModel: ViewModel,
        entityName: String,
        confirmButtonTitle: String = "Continue Anyway",
        onTimestampConfirm: @escaping () async -> Void
    ) -> some View {
        modifier(FormAlertsModifier(
            viewModel: viewModel,
            entityName: entityName,
            confirmButtonTitle: confirmButtonTitle,
            onTimestampConfirm: onTimestampConfirm
        ))
    }
}
