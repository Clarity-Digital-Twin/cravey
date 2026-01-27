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
                        title: "What triggered this?",
                        groups: [
                            .init(title: "Primary (HAALT)", options: TriggerOptions.primary),
                            .init(title: "Secondary", options: TriggerOptions.secondary),
                        ],
                        selectedValues: $viewModel.selectedTriggers,
                        multiSelect: true
                    )

                    // BUG-004 FIX: Use OptionalSingleSelectChipSelector to avoid Set allocation per render
                    OptionalSingleSelectChipSelector(
                        title: "Where are you?",
                        options: LocationOptions.presets,
                        selectedValue: $viewModel.selectedLocation
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Notes", text: $viewModel.notes, axis: .vertical)
                            .lineLimit(3 ... 5)

                        // BUG-006 FIX: Only show counter at 400+ chars (matches UsageLogForm)
                        if viewModel.shouldShowNotesCounter {
                            HStack {
                                Spacer()
                                Text("\(viewModel.notesCharacterCount)/500")
                                    .font(.caption)
                                    .foregroundStyle(viewModel.notesCharacterCount == 500 ? .red : .secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Log Craving")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier("cravingFormCancelButton")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.logCraving()
                        }
                    }
                    .disabled(!viewModel.canSubmit || viewModel.isLoading)
                    .accessibilityIdentifier("cravingFormSaveButton")
                }
            }
            .alert("Old Timestamp", isPresented: $viewModel.showTimestampWarning) {
                Button("Cancel", role: .cancel) {
                    viewModel.showTimestampWarning = false
                }
                Button("Continue Anyway") {
                    Task {
                        await viewModel.confirmOldTimestamp()
                    }
                }
            } message: {
                Text("This craving is more than 7 days old. Are you sure you want to log it?")
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
