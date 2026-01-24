import SwiftUI

/// Settings screen - app configuration with export and delete functionality
/// Presentation layer - Clean Architecture
struct SettingsView: View {
    @Environment(SettingsViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            SettingsContentView(viewModel: viewModel)
        }
    }
}

// MARK: - Settings Content View

private struct SettingsContentView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("\(viewModel.appVersion) (\(viewModel.buildNumber))")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Data") {
                Button {
                    Task {
                        await viewModel.exportData()
                    }
                } label: {
                    HStack {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                        Spacer()
                        if viewModel.isExporting {
                            ProgressView()
                        }
                    }
                }
                .disabled(viewModel.isExporting)
                .accessibilityIdentifier("exportDataButton")

                Button(role: .destructive) {
                    viewModel.showDeleteConfirmation = true
                } label: {
                    HStack {
                        Label("Delete All Data", systemImage: "trash")
                        Spacer()
                        if viewModel.isDeleting {
                            ProgressView()
                        }
                    }
                }
                .disabled(viewModel.isDeleting)
                .accessibilityIdentifier("deleteAllDataButton")
            }

            Section("Privacy") {
                Label {
                    Text("All data is stored locally on your device")
                } icon: {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(.green)
                }

                Label {
                    Text("No data is ever sent to external servers")
                } icon: {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.blue)
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $viewModel.showExportSheet) {
            if let url = viewModel.exportURL {
                ShareSheet(items: [url])
            }
        }
        // iOS 17+ declarative haptics for export success
        .sensoryFeedback(.success, trigger: viewModel.showExportSheet)
        .confirmationDialog(
            "Delete All Data?",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Everything", role: .destructive) {
                Task {
                    await viewModel.deleteAllData()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                """
                This will permanently delete all your cravings, usage logs, \
                recordings, and motivational messages. This action cannot be undone.
                """
            )
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .alert("Data Deleted", isPresented: $viewModel.deleteSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("All your data has been permanently deleted.")
        }
        // iOS 17+ declarative haptics for success/error states
        .sensoryFeedback(.success, trigger: viewModel.deleteSuccess)
        .sensoryFeedback(.error, trigger: viewModel.showError)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}

#Preview {
    let container = DependencyContainer.preview

    SettingsView()
        .environment(container.makeSettingsViewModel())
        .environment(container)
}
