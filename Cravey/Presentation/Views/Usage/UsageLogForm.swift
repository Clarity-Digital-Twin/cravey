import SwiftUI

/// Usage logging form (Phase 2C)
/// Sheet-based form for logging cannabis use episodes
/// Source: PHASE_2C.md lines 275-481
struct UsageLogForm: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: UsageLogViewModel

    // MARK: - ROA Methods

    private let methods = ["Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible"]

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Timestamp Section

                Section {
                    TimestampPicker(title: nil, date: $viewModel.timestamp)
                } header: {
                    Text("When")
                }

                // MARK: - Method/Amount Section

                Section {
                    // Method selector (radio button chips per UX_FLOW:363)
                    // BUG-003 FIX: Use SingleSelectChipSelector to avoid Set allocation per render
                    SingleSelectChipSelector(
                        title: "Method (ROA)",
                        options: methods,
                        selectedValue: $viewModel.selectedMethod
                    )

                    // Amount picker (ROA-aware)
                    ROAPickerInput(selectedMethod: viewModel.selectedMethod, amount: $viewModel.amount)
                } header: {
                    Text("What & How Much")
                }

                // MARK: - Triggers Section (Optional)

                Section {
                    ChipSelector(
                        title: "Triggers",
                        groups: [
                            .init(title: "Primary", options: TriggerOptions.primary),
                            .init(title: "Secondary", options: TriggerOptions.secondary),
                        ],
                        selectedValues: $viewModel.selectedTriggers,
                        multiSelect: true
                    )
                } header: {
                    Text("Triggers (Optional)")
                } footer: {
                    Text("Select all that apply")
                        .font(.caption)
                }

                // MARK: - Location Section (Optional)

                Section {
                    locationSelector
                } header: {
                    Text("Location (Optional)")
                }

                // MARK: - Notes Section (Optional)

                Section {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)

                    // Character counter (shows at 400+ chars)
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
                } header: {
                    Text("Notes (Optional)")
                } footer: {
                    Text("Any additional context or observations")
                        .font(.caption)
                }
            }
            .navigationTitle("Log Usage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier("usageFormCancelButton")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.logUsage()
                        }
                    }
                    .disabled(!viewModel.canSubmit || viewModel.isLoading)
                    .accessibilityIdentifier("usageFormSaveButton")
                }
            }

            // MARK: - Alerts & Toasts

            .alert("Old Timestamp", isPresented: $viewModel.showTimestampWarning) {
                Button("Cancel", role: .cancel) {
                    viewModel.showTimestampWarning = false
                }
                Button("Save Anyway") {
                    Task {
                        await viewModel.confirmOldTimestamp()
                    }
                }
            } message: {
                Text("This timestamp is more than 7 days old. Are you sure you want to continue?")
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

    // MARK: - Location Selector (Single-Select)

    @ViewBuilder
    private var locationSelector: some View {
        // BUG-003 FIX: Use OptionalSingleSelectChipSelector to avoid Set allocation per render
        // DEBT-009: Custom binding to handle "Current Location" GPS request
        VStack(alignment: .leading, spacing: 8) {
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
        }
    }
}

// MARK: - Previews

#Preview("Empty Form") {
    @Previewable @State var viewModel = UsageLogViewModel(
        logUsageUseCase: PreviewMockLogUsageUseCase()
    )

    UsageLogForm(viewModel: viewModel)
}

#Preview("Filled Form") {
    @Previewable @State var viewModel = UsageLogViewModel(
        logUsageUseCase: PreviewMockLogUsageUseCase()
    )

    viewModel.selectedMethod = "Vape"
    viewModel.amount = 5.0
    viewModel.selectedTriggers = ["Anxious", "Bored"]
    viewModel.selectedLocation = "Home"
    viewModel.notes = "Sample notes for preview"

    return UsageLogForm(viewModel: viewModel)
}

// MARK: - Preview Mock

actor PreviewMockLogUsageUseCase: LogUsageUseCase {
    func execute(_ request: LogUsageRequest) async throws -> UsageEntity {
        // Simulate network delay
        try await Task.sleep(for: .milliseconds(500))

        return UsageEntity(
            timestamp: request.timestamp,
            method: request.method,
            amount: request.amount,
            triggers: request.triggers,
            location: request.location,
            notes: request.notes
        )
    }
}
