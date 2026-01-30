import Foundation

/// Handles app startup initialization (DEBT-033)
/// Single source of truth for DependencyContainer initialization logic
@MainActor
enum AppStartupHandler {
    /// Result of startup initialization
    @MainActor
    struct Result {
        let container: DependencyContainer?
        let failure: DependencyContainer.StartupFailure?
        let showStorageAlert: Bool

        let cravingListViewModel: CravingListViewModel?
        let usageListViewModel: UsageListViewModel?
        let dashboardViewModel: DashboardViewModel?
        let settingsViewModel: SettingsViewModel?
        let homeMotivationViewModel: HomeMotivationViewModel?

        /// Whether the app is ready to display main content
        var isReady: Bool {
            container != nil
        }
    }

    /// Initialize the app with proper error handling
    /// Returns a Result containing all initialized components or failure info
    static func initialize() -> Result {
        do {
            let container = try DependencyContainer()
            return Result(
                container: container,
                failure: nil,
                showStorageAlert: container.initializationError != nil,
                cravingListViewModel: container.makeCravingListViewModel(),
                usageListViewModel: container.makeUsageListViewModel(),
                dashboardViewModel: container.makeDashboardViewModel(),
                settingsViewModel: container.makeSettingsViewModel(),
                homeMotivationViewModel: container.makeHomeMotivationViewModel()
            )
        } catch let error as DependencyContainer.StartupFailure {
            return Result(
                container: nil,
                failure: error,
                showStorageAlert: false,
                cravingListViewModel: nil,
                usageListViewModel: nil,
                dashboardViewModel: nil,
                settingsViewModel: nil,
                homeMotivationViewModel: nil
            )
        } catch {
            return Result(
                container: nil,
                failure: DependencyContainer.StartupFailure(
                    persistentErrorDescription: error.localizedDescription,
                    inMemoryErrorDescription: error.localizedDescription
                ),
                showStorageAlert: false,
                cravingListViewModel: nil,
                usageListViewModel: nil,
                dashboardViewModel: nil,
                settingsViewModel: nil,
                homeMotivationViewModel: nil
            )
        }
    }
}
