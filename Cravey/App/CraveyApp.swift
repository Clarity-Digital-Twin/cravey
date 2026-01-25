import SwiftData
import SwiftUI

/// Main app entry point
/// Clean Architecture: Composition Root
@main
struct CraveyApp: App {
    @State private var dependencyContainer: DependencyContainer?
    @State private var cravingListViewModel: CravingListViewModel?
    @State private var usageListViewModel: UsageListViewModel?
    @State private var dashboardViewModel: DashboardViewModel?
    @State private var settingsViewModel: SettingsViewModel?
    @State private var startupFailure: DependencyContainer.StartupFailure?
    @State private var showStorageAlert: Bool

    init() {
        do {
            let container = try DependencyContainer()

            _dependencyContainer = State(initialValue: container)
            _cravingListViewModel = State(initialValue: container.makeCravingListViewModel())
            _usageListViewModel = State(initialValue: container.makeUsageListViewModel())
            _dashboardViewModel = State(initialValue: container.makeDashboardViewModel())
            _settingsViewModel = State(initialValue: container.makeSettingsViewModel())
            _startupFailure = State(initialValue: nil)
            _showStorageAlert = State(initialValue: container.initializationError != nil)
        } catch let error as DependencyContainer.StartupFailure {
            _dependencyContainer = State(initialValue: nil)
            _cravingListViewModel = State(initialValue: nil)
            _usageListViewModel = State(initialValue: nil)
            _dashboardViewModel = State(initialValue: nil)
            _settingsViewModel = State(initialValue: nil)
            _startupFailure = State(initialValue: error)
            _showStorageAlert = State(initialValue: false)
        } catch {
            _dependencyContainer = State(initialValue: nil)
            _cravingListViewModel = State(initialValue: nil)
            _usageListViewModel = State(initialValue: nil)
            _dashboardViewModel = State(initialValue: nil)
            _settingsViewModel = State(initialValue: nil)
            _startupFailure = State(
                initialValue: DependencyContainer.StartupFailure(
                    persistentErrorDescription: error.localizedDescription,
                    inMemoryErrorDescription: error.localizedDescription
                )
            )
            _showStorageAlert = State(initialValue: false)
        }
    }

    var body: some Scene {
        WindowGroup {
            if let dependencyContainer,
               let cravingListViewModel,
               let usageListViewModel,
               let dashboardViewModel,
               let settingsViewModel
            {
                TabView {
                    HomeView()
                        .environment(cravingListViewModel)
                        .environment(usageListViewModel)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }

                    DashboardView()
                        .environment(dashboardViewModel)
                        .tabItem {
                            Label("Progress", systemImage: "chart.bar.fill")
                        }

                    RecordingsView()
                        .tabItem {
                            Label("Recordings", systemImage: "play.rectangle.fill")
                        }

                    SettingsView()
                        .environment(settingsViewModel)
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                }
                .environment(dependencyContainer)
                .alert("Storage Unavailable", isPresented: $showStorageAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    let description = dependencyContainer.initializationError?.errorDescription
                        ?? "Cravey couldn’t open its local database."
                    let recovery = dependencyContainer.initializationError?.recoverySuggestion
                        ?? "Your data may not persist after closing the app."
                    Text("\(description)\n\n\(recovery)")
                }
                .modelContainer(dependencyContainer.modelContainer)
            } else {
                AppUnavailableView(
                    error: startupFailure,
                    onRetry: retryStartup
                )
            }
        }

        #if os(macOS)
            Settings {
                MacOSSettingsView()
            }
        #endif
    }

    @MainActor
    private func retryStartup() {
        do {
            let container = try DependencyContainer()
            dependencyContainer = container
            cravingListViewModel = container.makeCravingListViewModel()
            usageListViewModel = container.makeUsageListViewModel()
            dashboardViewModel = container.makeDashboardViewModel()
            settingsViewModel = container.makeSettingsViewModel()
            startupFailure = nil
            showStorageAlert = container.initializationError != nil
        } catch let error as DependencyContainer.StartupFailure {
            dependencyContainer = nil
            cravingListViewModel = nil
            usageListViewModel = nil
            dashboardViewModel = nil
            settingsViewModel = nil
            startupFailure = error
            showStorageAlert = false
        } catch {
            dependencyContainer = nil
            cravingListViewModel = nil
            usageListViewModel = nil
            dashboardViewModel = nil
            settingsViewModel = nil
            startupFailure = DependencyContainer.StartupFailure(
                persistentErrorDescription: error.localizedDescription,
                inMemoryErrorDescription: error.localizedDescription
            )
            showStorageAlert = false
        }
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
    struct MacOSSettingsView: View {
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
