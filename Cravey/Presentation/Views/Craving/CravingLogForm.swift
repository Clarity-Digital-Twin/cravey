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

                    // BUG-004 FIX: Use OptionalSingleSelectChipSelector to avoid Set allocation per render
                    // DEBT-009: Custom binding to handle "Current Location" GPS request
                    OptionalSingleSelectChipSelector(
                        title: "Location",
                        options: LocationOptions.presets,
                        selectedValue: Binding(
                            get: {
                                // Show "📍 Current" chip as selected if we have GPS coords
                                if let loc = viewModel.selectedLocation, LocationOptions.isGPS(loc) {
                                    return LocationOptions.currentLocationKey
                                }
                                return viewModel.selectedLocation
                            },
                            set: { newValue in
                                Task {
                                    await viewModel.handleLocationSelection(newValue)
                                }
                            }
                        )
                    )
                    .overlay {
                        if viewModel.isLoadingLocation {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 8)
                        }
                    }

                    // Show location error inline if present
                    if let locationError = viewModel.locationError {
                        Text(locationError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

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
            // DEBT-009: Location permission denied alert
            .alert("Location Permission Required", isPresented: $viewModel.showLocationPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enable location access in Settings to use Current Location.")
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
