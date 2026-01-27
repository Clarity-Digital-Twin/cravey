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
                        ?? "We couldn't access your local data yet."
                    let recovery = dependencyContainer.initializationError?.recoverySuggestion
                        ?? "Your entries may not be saved after you close the app."
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
