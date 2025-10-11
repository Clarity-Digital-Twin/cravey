import SwiftUI
import SwiftData

/// Main app entry point
/// Clean Architecture: Composition Root
@main
struct CraveyApp: App {
    @State private var dependencyContainer = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            // TODO: Create proper ContentView in Presentation layer
            PlaceholderContentView()
                .environment(dependencyContainer)
        }

        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}

// MARK: - Placeholder View (temporary)

struct PlaceholderContentView: View {
    @Environment(DependencyContainer.self) private var container

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                Text("Cravey")
                    .font(.largeTitle.bold())

                Text("Clean Architecture + MVVM")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("Boilerplate Setup Complete")
                    .font(.subheadline)
                    .foregroundStyle(.green)

                Divider()
                    .padding()

                VStack(alignment: .leading, spacing: 8) {
                    Label("✅ Domain Layer (Entities, Use Cases, Protocols)", systemImage: "cube")
                    Label("✅ Data Layer (Models, Repositories, Storage)", systemImage: "cylinder")
                    Label("✅ Presentation Layer (ViewModels, Views)", systemImage: "eye")
                    Label("✅ App Layer (DI Container)", systemImage: "app")
                }
                .font(.caption)

                Spacer()

                Text("Next: Implement remaining repositories & views")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Cravey Setup")
        }
    }
}

// MARK: - Settings View (macOS)

#if os(macOS)
struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            PrivacySettingsView()
                .tabItem {
                    Label("Privacy", systemImage: "lock")
                }
        }
        .frame(width: 500, height: 400)
    }
}

struct GeneralSettingsView: View {
    var body: some View {
        Form {
            Section {
                Text("General settings coming soon...")
            }
        }
        .padding()
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        Form {
            Section {
                Label {
                    Text("All data is stored locally on your device")
                } icon: {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(.green)
                }
            } header: {
                Text("Privacy Features")
            }
        }
        .padding()
    }
}
#endif

// MARK: - Preview

#Preview {
    PlaceholderContentView()
        .environment(DependencyContainer.preview)
}
