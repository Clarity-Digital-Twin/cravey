import SwiftUI

/// Export data flow (UX_FLOW_SPEC Screen 7.2)
struct ExportDataSheet: View {
    @Bindable var viewModel: SettingsViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat: ExportFormat = .csv

    var body: some View {
        NavigationStack {
            Form {
                Section("Choose format") {
                    Picker("Format", selection: $selectedFormat) {
                        Text("CSV").tag(ExportFormat.csv)
                        Text("JSON").tag(ExportFormat.json)
                    }
                    .pickerStyle(.inline)
                    .accessibilityIdentifier("exportFormatPicker")
                }

                Section {
                    Button {
                        Task {
                            await viewModel.exportData(format: selectedFormat)
                        }
                    } label: {
                        HStack {
                            Text("Export")
                            Spacer()
                            if viewModel.isExporting {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(viewModel.isExporting)
                    .accessibilityIdentifier("exportConfirmButton")
                }

                Section {
                    Text(
                        """
                        Export includes your cravings, usage logs, recordings (metadata only), \
                        and motivational messages. Recording files are not included.
                        """
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Export Data")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityIdentifier("exportCancelButton")
                }
            }
            .interactiveDismissDisabled(viewModel.isExporting)
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let url = viewModel.exportURL {
                ShareSheet(items: [url]) { completed in
                    viewModel.handleExportShareCompletion(completed: completed)
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    let container = DependencyContainer.preview
    ExportDataSheet(viewModel: container.makeSettingsViewModel())
}
