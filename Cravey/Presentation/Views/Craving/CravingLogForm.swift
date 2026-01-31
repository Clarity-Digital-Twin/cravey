import SwiftUI

/// Craving logging form (sheet presentation)
/// Presentation layer - Clean Architecture
struct CravingLogForm: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: CravingLogViewModel

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Required Section (timestamp + intensity)

                Section {
                    TimestampPicker(date: $viewModel.timestamp)
                        .accessibilityLabel("Timestamp")

                    IntensitySlider(value: $viewModel.intensity)
                        .accessibilityLabel("Intensity")
                }

                // MARK: - Triggers Section

                Section("Triggers") {
                    ChipSelector(
                        title: nil,
                        groups: [
                            .init(title: "Primary", options: TriggerOptions.primaryHALT),
                            .init(title: nil, options: TriggerOptions.primaryOther),
                            .init(title: "Secondary", options: TriggerOptions.secondary),
                        ],
                        selectedValues: $viewModel.selectedTriggers,
                        multiSelect: true
                    )
                }

                // MARK: - Location Section

                Section("Location") {
                    LocationSelector(viewModel: viewModel, showTitle: false)
                }

                // MARK: - Notes Section

                Section("Notes") {
                    TextField("", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3 ... 5)

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
