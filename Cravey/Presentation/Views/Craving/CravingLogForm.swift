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
                        options: TriggerOptions.all,
                        selectedValues: $viewModel.selectedTriggers,
                        multiSelect: true
                    )

                    ChipSelector(
                        title: "Where are you?",
                        options: LocationOptions.presets,
                        selectedValues: Binding(
                            get: {
                                viewModel.location.isEmpty ? [] : Set([viewModel.location])
                            },
                            set: {
                                viewModel.location = $0.first ?? ""
                            }
                        ),
                        multiSelect: false
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Notes", text: $viewModel.notes, axis: .vertical)
                            .lineLimit(3 ... 5)

                        HStack {
                            Spacer()
                            Text(viewModel.notesCharacterCount)
                                .font(.caption)
                                .foregroundColor(viewModel.notesExceedsLimit ? .red : .secondary)
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
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.logCraving()
                        }
                    }
                    .disabled(!viewModel.canSubmit)
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("💪 Logged. Every moment of awareness counts.")
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
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var viewModel = DependencyContainer.preview.makeCravingLogViewModel()

    CravingLogForm(viewModel: viewModel)
}
