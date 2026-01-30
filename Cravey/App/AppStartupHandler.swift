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

        // MARK: - View Model Computed Properties

        var cravingListViewModel: CravingListViewModel? {
            container?.makeCravingListViewModel()
        }

        var usageListViewModel: UsageListViewModel? {
            container?.makeUsageListViewModel()
        }

        var dashboardViewModel: DashboardViewModel? {
            container?.makeDashboardViewModel()
        }

        var settingsViewModel: SettingsViewModel? {
            container?.makeSettingsViewModel()
        }

        var homeMotivationViewModel: HomeMotivationViewModel? {
            container?.makeHomeMotivationViewModel()
        }

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
                showStorageAlert: container.initializationError != nil
            )
        } catch let error as DependencyContainer.StartupFailure {
            return Result(
                container: nil,
                failure: error,
                showStorageAlert: false
            )
        } catch {
            return Result(
                container: nil,
                failure: DependencyContainer.StartupFailure(
                    persistentErrorDescription: error.localizedDescription,
                    inMemoryErrorDescription: error.localizedDescription
                ),
                showStorageAlert: false
            )
        }
    }
}
