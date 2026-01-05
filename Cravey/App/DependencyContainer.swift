import Foundation
import SwiftData

/// Dependency Injection Container
/// App layer - composes all dependencies following Clean Architecture
@Observable
@MainActor
final class DependencyContainer {
    // MARK: - Infrastructure (Data Layer)

    let modelContainer: ModelContainer
    let modelContext: ModelContext
    let fileStorage: FileStorageManager

    // MARK: - Repositories (Data Layer)

    private(set) var cravingRepository: CravingRepositoryProtocol
    private(set) var usageRepository: UsageRepositoryProtocol
    // Note: RecordingRepository and MessageRepository will be added in Phase 4

    // MARK: - Use Cases (Domain Layer)

    private(set) var logCravingUseCase: LogCravingUseCase
    private(set) var fetchCravingsUseCase: FetchCravingsUseCase
    private(set) var logUsageUseCase: LogUsageUseCase
    private(set) var fetchUsageUseCase: FetchUsageUseCase

    // MARK: - View Models (Presentation Layer)

    func makeCravingLogViewModel() -> CravingLogViewModel {
        CravingLogViewModel(logCravingUseCase: logCravingUseCase)
    }

    func makeUsageLogViewModel() -> UsageLogViewModel {
        UsageLogViewModel(logUsageUseCase: logUsageUseCase)
    }

    func makeUsageListViewModel() -> UsageListViewModel {
        UsageListViewModel(fetchUsageUseCase: fetchUsageUseCase)
    }

    func makeCravingListViewModel() -> CravingListViewModel {
        CravingListViewModel(fetchCravingsUseCase: fetchCravingsUseCase)
    }

    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            fetchCravingsUseCase: fetchCravingsUseCase,
            fetchUsageUseCase: fetchUsageUseCase
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(modelContext: modelContext)
    }

    // MARK: - Initialization

    init(isPreview: Bool = false) {
        // Check for UI testing mode
        let isUITesting = ProcessInfo.processInfo.arguments.contains("--uitesting")

        do {
            // Initialize infrastructure
            if isUITesting {
                modelContainer = try ModelContainerSetup.createUITesting()
            } else if isPreview {
                modelContainer = try ModelContainerSetup.createPreview()
            } else {
                modelContainer = try ModelContainerSetup.create()
            }
            modelContext = ModelContext(modelContainer)
            fileStorage = FileStorageManager.shared

            // Initialize repositories
            let cravingRepo = CravingRepository(modelContext: modelContext)
            let usageRepo = UsageRepository(modelContext: modelContext)

            cravingRepository = cravingRepo
            usageRepository = usageRepo

            // Initialize use cases
            logCravingUseCase = DefaultLogCravingUseCase(repository: cravingRepo)
            fetchCravingsUseCase = DefaultFetchCravingsUseCase(repository: cravingRepo)
            logUsageUseCase = DefaultLogUsageUseCase(repository: usageRepo)
            fetchUsageUseCase = DefaultFetchUsageUseCase(repository: usageRepo)

            // Seed default data if needed (skip for UI testing)
            if !isPreview, !isUITesting {
                ModelContainerSetup.seedDefaultMessages(context: modelContext)
            }
        } catch {
            fatalError("Failed to initialize DependencyContainer: \(error)")
        }
    }
}

// MARK: - Preview Container

extension DependencyContainer {
    static var preview: DependencyContainer {
        DependencyContainer(isPreview: true)
    }
}
