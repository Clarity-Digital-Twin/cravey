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
    @State private var homeMotivationViewModel: HomeMotivationViewModel?
    @State private var startupFailure: DependencyContainer.StartupFailure?
    @State private var showStorageAlert: Bool

    init() {
        let result = AppStartupHandler.initialize()
        _dependencyContainer = State(initialValue: result.container)
        _cravingListViewModel = State(initialValue: result.cravingListViewModel)
        _usageListViewModel = State(initialValue: result.usageListViewModel)
        _dashboardViewModel = State(initialValue: result.dashboardViewModel)
        _settingsViewModel = State(initialValue: result.settingsViewModel)
        _homeMotivationViewModel = State(initialValue: result.homeMotivationViewModel)
        _startupFailure = State(initialValue: result.failure)
        _showStorageAlert = State(initialValue: result.showStorageAlert)
    }

    var body: some Scene {
        WindowGroup {
            if let dependencyContainer,
               let cravingListViewModel,
               let usageListViewModel,
               let dashboardViewModel,
               let settingsViewModel,
               let homeMotivationViewModel
            {
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }

                    LogView()
                        .tabItem {
                            Label("Log", systemImage: "plus.circle.fill")
                        }

                    HistoryView()
                        .tabItem {
                            Label("History", systemImage: "clock.fill")
                        }

                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                }
                .environment(dependencyContainer)
                .environment(\.makeCravingLogViewModel, dependencyContainer.makeCravingLogViewModel)
                .environment(\.makeUsageLogViewModel, dependencyContainer.makeUsageLogViewModel)
                .environment(cravingListViewModel)
                .environment(usageListViewModel)
                .environment(dashboardViewModel)
                .environment(settingsViewModel)
                .environment(homeMotivationViewModel)
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
        let result = AppStartupHandler.initialize()
        dependencyContainer = result.container
        cravingListViewModel = result.cravingListViewModel
        usageListViewModel = result.usageListViewModel
        dashboardViewModel = result.dashboardViewModel
        settingsViewModel = result.settingsViewModel
        homeMotivationViewModel = result.homeMotivationViewModel
        startupFailure = result.failure
        showStorageAlert = result.showStorageAlert
    }
}
