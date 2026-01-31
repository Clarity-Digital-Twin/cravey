import SwiftUI

/// Usage logging form (Phase 2C)
/// Sheet-based form for logging cannabis use episodes
/// Source: PHASE_2C.md lines 275-481
struct UsageLogForm: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: UsageLogViewModel

    // MARK: - ROA Methods (DEBT-041: uses UsageMethod enum)

    private let methods = UsageMethod.allCases.map(\.rawValue)

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

                // MARK: - Triggers Section

                Section {
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
                } header: {
                    Text("Triggers")
                }

                // MARK: - Location Section

                Section {
                    LocationSelector(viewModel: viewModel, showTitle: false)
                } header: {
                    Text("Location")
                }

                // MARK: - Notes Section

                Section("Notes") {
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
                }
            }
            .navigationTitle("Log Usage")
            .navigationBarTitleDisplayMode(.inline)
            .formToolbar(
                canSubmit: viewModel.canSubmit,
                isLoading: viewModel.isLoading,
                cancelAccessibilityId: "usageFormCancelButton",
                saveAccessibilityId: "usageFormSaveButton"
            ) {
                await viewModel.logUsage()
            }
            .formAlerts(
                viewModel: viewModel,
                entityName: "usage entry",
                confirmButtonTitle: "Save Anyway"
            ) {
                await viewModel.confirmOldTimestamp()
            }
            .locationPermissionAlert(isPresented: $viewModel.showLocationPermissionAlert)
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
