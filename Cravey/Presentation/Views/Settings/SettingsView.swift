import SwiftUI

/// Settings screen - app configuration
/// Presentation layer - Clean Architecture
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0 (Phase 1)")
                            .foregroundColor(.secondary)
                    }
                }

                Section("Data") {
                    // TODO: Implement in Phase 3 (Weeks 3-4)
                    Text("Export Data")
                        .foregroundColor(.secondary)
                    Text("Delete All Data")
                        .foregroundColor(.secondary)
                }

                Section("Privacy") {
                    Label {
                        Text("All data is stored locally on your device")
                    } icon: {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
