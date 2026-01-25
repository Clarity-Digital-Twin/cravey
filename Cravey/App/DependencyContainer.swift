import Foundation
import OSLog
import SwiftData

/// Dependency Injection Container
/// App layer - composes all dependencies following Clean Architecture
@Observable
@MainActor
final class DependencyContainer {
    enum StorageMode: String, Sendable {
        case persistent
        case inMemoryFallback
    }

    struct StartupFailure: LocalizedError, Sendable {
        let persistentErrorDescription: String
        let inMemoryErrorDescription: String

        var errorDescription: String? {
            "Cravey couldn’t start because its local database is unavailable."
        }

        var recoverySuggestion: String? {
            "Try restarting your device. If the issue persists, you may need to delete the app’s local data "
                + "from iOS Settings."
        }
    }

    struct InitializationError: LocalizedError, Sendable {
        let underlying: Error
        let storageMode: StorageMode

        var errorDescription: String? {
            switch storageMode {
            case .persistent:
                "Cravey couldn’t open its local database. You can continue in a temporary mode, "
                    + "but your data may not persist after closing the app."
            case .inMemoryFallback:
                "Cravey is running in a temporary mode. Your data may not persist after closing the app."
            }
        }

        var recoverySuggestion: String? {
            "If this keeps happening, try restarting your device. If the issue persists, you may need to "
                + "delete the app’s local data from iOS Settings."
        }
    }

    private static let logger = Logger(subsystem: "com.cravey", category: "DependencyContainer")

    private struct Wiring {
        let modelContainer: ModelContainer
        let modelContext: ModelContext
        let fileStorage: FileStorageManager
        let cravingRepository: CravingRepositoryProtocol
        let usageRepository: UsageRepositoryProtocol
        let logCravingUseCase: LogCravingUseCase
        let fetchCravingsUseCase: FetchCravingsUseCase
        let deleteCravingUseCase: DeleteCravingUseCase
        let logUsageUseCase: LogUsageUseCase
        let fetchUsageUseCase: FetchUsageUseCase
        let deleteUsageUseCase: DeleteUsageUseCase
        let exportUserDataUseCase: ExportUserDataUseCase
        let deleteAllUserDataUseCase: DeleteAllUserDataUseCase
    }

    // MARK: - Infrastructure (Data Layer)

    let modelContainer: ModelContainer
    let modelContext: ModelContext
    let fileStorage: FileStorageManager

    private(set) var storageMode: StorageMode = .persistent
    private(set) var initializationError: InitializationError?

    // MARK: - Repositories (Data Layer)

    private(set) var cravingRepository: CravingRepositoryProtocol
    private(set) var usageRepository: UsageRepositoryProtocol
    // Note: RecordingRepository and MessageRepository will be added in Phase 4

    // MARK: - Use Cases (Domain Layer)

    private(set) var logCravingUseCase: LogCravingUseCase
    private(set) var fetchCravingsUseCase: FetchCravingsUseCase
    private(set) var deleteCravingUseCase: DeleteCravingUseCase
    private(set) var logUsageUseCase: LogUsageUseCase
    private(set) var fetchUsageUseCase: FetchUsageUseCase
    private(set) var deleteUsageUseCase: DeleteUsageUseCase
    private(set) var exportUserDataUseCase: ExportUserDataUseCase
    private(set) var deleteAllUserDataUseCase: DeleteAllUserDataUseCase

    // MARK: - View Models (Presentation Layer)

    func makeCravingLogViewModel() -> CravingLogViewModel {
        CravingLogViewModel(logCravingUseCase: logCravingUseCase)
    }

    func makeUsageLogViewModel() -> UsageLogViewModel {
        UsageLogViewModel(logUsageUseCase: logUsageUseCase)
    }

    func makeUsageListViewModel() -> UsageListViewModel {
        UsageListViewModel(
            fetchUsageUseCase: fetchUsageUseCase,
            deleteUsageUseCase: deleteUsageUseCase
        )
    }

    func makeCravingListViewModel() -> CravingListViewModel {
        CravingListViewModel(
            fetchCravingsUseCase: fetchCravingsUseCase,
            deleteCravingUseCase: deleteCravingUseCase
        )
    }

    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            fetchCravingsUseCase: fetchCravingsUseCase,
            fetchUsageUseCase: fetchUsageUseCase
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            exportUserDataUseCase: exportUserDataUseCase,
            deleteAllUserDataUseCase: deleteAllUserDataUseCase
        )
    }

    // MARK: - Initialization

    private static func makeWiring(modelContainer: ModelContainer) -> Wiring {
        let modelContext = ModelContext(modelContainer)
        let fileStorage = FileStorageManager.shared

        let cravingRepo = CravingRepository(modelContext: modelContext)
        let usageRepo = UsageRepository(modelContext: modelContext)

        return Wiring(
            modelContainer: modelContainer,
            modelContext: modelContext,
            fileStorage: fileStorage,
            cravingRepository: cravingRepo,
            usageRepository: usageRepo,
            logCravingUseCase: DefaultLogCravingUseCase(repository: cravingRepo),
            fetchCravingsUseCase: DefaultFetchCravingsUseCase(repository: cravingRepo),
            deleteCravingUseCase: DefaultDeleteCravingUseCase(repository: cravingRepo),
            logUsageUseCase: DefaultLogUsageUseCase(repository: usageRepo),
            fetchUsageUseCase: DefaultFetchUsageUseCase(repository: usageRepo),
            deleteUsageUseCase: DefaultDeleteUsageUseCase(repository: usageRepo),
            exportUserDataUseCase: DefaultExportUserDataUseCase(
                cravingRepository: cravingRepo,
                usageRepository: usageRepo
            ),
            deleteAllUserDataUseCase: SwiftDataDeleteAllUserDataUseCase(
                modelContext: modelContext
            )
        )
    }

    private init(wiring: Wiring, storageMode: StorageMode, initializationError: InitializationError?) {
        modelContainer = wiring.modelContainer
        modelContext = wiring.modelContext
        fileStorage = wiring.fileStorage

        cravingRepository = wiring.cravingRepository
        usageRepository = wiring.usageRepository

        logCravingUseCase = wiring.logCravingUseCase
        fetchCravingsUseCase = wiring.fetchCravingsUseCase
        deleteCravingUseCase = wiring.deleteCravingUseCase

        logUsageUseCase = wiring.logUsageUseCase
        fetchUsageUseCase = wiring.fetchUsageUseCase
        deleteUsageUseCase = wiring.deleteUsageUseCase

        exportUserDataUseCase = wiring.exportUserDataUseCase
        deleteAllUserDataUseCase = wiring.deleteAllUserDataUseCase

        self.storageMode = storageMode
        self.initializationError = initializationError
    }

    convenience init(
        isPreview: Bool = false,
        arguments: [String] = ProcessInfo.processInfo.arguments,
        makePersistentContainer: @MainActor () throws -> ModelContainer = { try ModelContainerSetup.create() },
        makePreviewContainer: @MainActor () throws -> ModelContainer = { try ModelContainerSetup.createPreview() },
        makeInMemoryContainer: @MainActor () throws -> ModelContainer = { try ModelContainerSetup.createUITesting() }
    ) throws {
        // Check for UI testing mode
        let isUITesting = arguments.contains("--uitesting")

        let normalStorageMode: StorageMode = isPreview || isUITesting ? .inMemoryFallback : .persistent

        do {
            // Initialize infrastructure
            let container = if isUITesting {
                try makeInMemoryContainer()
            } else if isPreview {
                try makePreviewContainer()
            } else {
                try makePersistentContainer()
            }
            let wiring = Self.makeWiring(modelContainer: container)
            self.init(wiring: wiring, storageMode: normalStorageMode, initializationError: nil)

            // Seed default data if needed (skip for UI testing)
            if !isPreview, !isUITesting {
                ModelContainerSetup.seedDefaultMessages(context: modelContext)
            }
        } catch {
            Self.logger.error(
                """
                Failed to initialize persistent storage. Falling back to in-memory.
                Error: \(error.localizedDescription)
                """
            )

            let initError = InitializationError(underlying: error, storageMode: .persistent)

            do {
                let container = try makeInMemoryContainer()
                let wiring = Self.makeWiring(modelContainer: container)
                self.init(wiring: wiring, storageMode: .inMemoryFallback, initializationError: initError)

                // Ensure default messages exist even in fallback mode (skip for UI testing).
                if !isUITesting {
                    ModelContainerSetup.seedDefaultMessages(context: modelContext)
                }
            } catch {
                Self.logger.fault(
                    "Failed to initialize in-memory fallback storage. Error: \(error.localizedDescription)"
                )

                throw StartupFailure(
                    persistentErrorDescription: initError.underlying.localizedDescription,
                    inMemoryErrorDescription: error.localizedDescription
                )
            }
        }
    }
}

// MARK: - Preview Container

extension DependencyContainer {
    static var preview: DependencyContainer {
        do {
            return try DependencyContainer(isPreview: true)
        } catch {
            logger.fault("Failed to create preview DependencyContainer: \(error.localizedDescription)")

            do {
                let container = try ModelContainerSetup.createUITesting()
                let wiring = makeWiring(modelContainer: container)
                return DependencyContainer(
                    wiring: wiring,
                    storageMode: .inMemoryFallback,
                    initializationError: nil
                )
            } catch {
                preconditionFailure("Failed to create preview DependencyContainer: \(error.localizedDescription)")
            }
        }
    }
}
