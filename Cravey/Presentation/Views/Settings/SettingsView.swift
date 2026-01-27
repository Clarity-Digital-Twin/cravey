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
    @State private var showExportFlow = false

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
                    showExportFlow = true
                } label: {
                    HStack {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityIdentifier("exportDataButton")
                .sheet(isPresented: $showExportFlow) {
                    ExportDataSheet(viewModel: viewModel)
                }

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
                recordings, and any custom motivational messages. This action cannot be undone.
                """
            )
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .overlay(alignment: .top) {
            VStack {
                SuccessBanner(
                    systemImage: "checkmark.circle.fill",
                    text: "Data exported",
                    isPresented: $viewModel.exportSuccess
                )

                SuccessBanner(
                    systemImage: "trash.circle.fill",
                    text: "All data deleted",
                    isPresented: $viewModel.deleteSuccess
                )

                Spacer()
            }
        }
        // iOS 17+ declarative haptics for success/error states
        .sensoryFeedback(.success, trigger: viewModel.deleteSuccess)
        .sensoryFeedback(.success, trigger: viewModel.exportSuccess)
        .sensoryFeedback(.error, trigger: viewModel.showError)
    }
}

private struct SuccessBanner: View {
    let systemImage: String
    let text: String
    @Binding var isPresented: Bool

    var body: some View {
        if isPresented {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(.green)
                    .symbolEffect(.bounce, value: isPresented)
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.spring(duration: 0.3), value: isPresented)
            .task {
                do {
                    try await Task.sleep(for: .seconds(2))
                } catch {
                    // Task cancelled — safe to ignore
                }
                isPresented = false
            }
        }
    }
}

#Preview {
    let container = DependencyContainer.preview

    SettingsView()
        .environment(container.makeSettingsViewModel())
        .environment(container)
}
