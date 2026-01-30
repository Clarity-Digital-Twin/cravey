import SwiftUI

/// Craving logging form (sheet presentation)
/// Presentation layer - Clean Architecture
struct CravingLogForm: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: CravingLogViewModel

    var body: some View {
        NavigationStack {
            Form {
                // REQUIRED SECTION (CLINICAL_CANNABIS_SPEC.md:187-193)
                Section {
                    TimestampPicker(date: $viewModel.timestamp)
                        .accessibilityLabel("Timestamp")

                    IntensitySlider(value: $viewModel.intensity)
                        .accessibilityLabel("Intensity")
                }

                // OPTIONAL SECTION
                Section("Details (Optional)") {
                    ChipSelector(
                        title: "Triggers",
                        groups: [
                            .init(title: "Primary", options: TriggerOptions.primary),
                            .init(title: "Secondary", options: TriggerOptions.secondary),
                        ],
                        selectedValues: $viewModel.selectedTriggers,
                        multiSelect: true
                    )

                    // DEBT-026: Extracted to reusable LocationSelector component
                    LocationSelector(viewModel: viewModel)

                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Notes", text: $viewModel.notes, axis: .vertical)
                            .lineLimit(3 ... 5)

                        // BUG-006 FIX: Only show counter at 400+ chars (matches UsageLogForm)
                        if viewModel.shouldShowNotesCounter {
                            HStack {
                                Spacer()
                                Text("\(viewModel.notesCharacterCount)/\(ValidationLimits.notesMaxLength)")
                                    .font(.caption)
                                    .foregroundStyle(
                                        viewModel.notesCharacterCount == ValidationLimits.notesMaxLength
                                            ? .red : .secondary
                                    )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Craving")
            .navigationBarTitleDisplayMode(.inline)
            .formToolbar(
                canSubmit: viewModel.canSubmit,
                isLoading: viewModel.isLoading,
                cancelAccessibilityId: "cravingFormCancelButton",
                saveAccessibilityId: "cravingFormSaveButton"
            ) {
                await viewModel.logCraving()
            }
            .formAlerts(viewModel: viewModel, entityName: "craving") {
                await viewModel.confirmOldTimestamp()
            }
            .locationPermissionAlert(isPresented: $viewModel.showLocationPermissionAlert)
            .onChange(of: viewModel.didSucceed) { _, didSucceed in
                // Dismiss immediately on success (UX_FLOW:400 - sheet dismisses in 0.3s)
                // Toast will be shown by parent (HomeView)
                if didSucceed {
                    dismiss()
                }
            }
            .interactiveDismissDisabled(viewModel.isLoading)
            .disabled(viewModel.isLoading)
            // iOS 17+ declarative haptics (replaces legacy UINotificationFeedbackGenerator)
            .sensoryFeedback(.success, trigger: viewModel.didSucceed)
        }
    }
}

#Preview {
    @Previewable @State var viewModel = DependencyContainer.preview.makeCravingLogViewModel()

    CravingLogForm(viewModel: viewModel)
}
