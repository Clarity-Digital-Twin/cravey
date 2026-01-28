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
            "We couldn't access your local data right now."
        }

        var recoverySuggestion: String? {
            "Please try again in a moment. If this continues, restarting your device can help."
        }
    }

    struct InitializationError: LocalizedError, Sendable {
        let underlying: Error
        let storageMode: StorageMode

        var errorDescription: String? {
            switch storageMode {
            case .persistent:
                "We couldn't access your local data, so Cravey is running in a temporary mode. "
                    + "Your entries may not be saved after you close the app."
            case .inMemoryFallback:
                "Cravey is running in a temporary mode. Your entries may not be saved after you close the app."
            }
        }

        var recoverySuggestion: String? {
            "If this keeps happening, restarting your device can help."
        }
    }

    private static let logger = Logger(subsystem: "com.cravey", category: "DependencyContainer")

    private struct Wiring {
        let modelContainer: ModelContainer
        let modelContext: ModelContext
        let fileStorage: FileStorageManager
        let locationService: LocationServiceProtocol
        let cravingRepository: CravingRepositoryProtocol
        let usageRepository: UsageRepositoryProtocol
        let recordingRepository: RecordingRepositoryProtocol
        let messageRepository: MessageRepositoryProtocol
        let logCravingUseCase: LogCravingUseCase
        let fetchCravingsUseCase: FetchCravingsUseCase
        let deleteCravingUseCase: DeleteCravingUseCase
        let logUsageUseCase: LogUsageUseCase
        let fetchUsageUseCase: FetchUsageUseCase
        let deleteUsageUseCase: DeleteUsageUseCase
        let exportUserDataUseCase: ExportUserDataUseCase
        let deleteAllUserDataUseCase: DeleteAllUserDataUseCase
        let selectMotivationalMessageUseCase: SelectMotivationalMessageUseCase
        let markMessageShownUseCase: MarkMessageShownUseCase
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
    private(set) var recordingRepository: RecordingRepositoryProtocol
    private(set) var messageRepository: MessageRepositoryProtocol

    // MARK: - Services

    private(set) var locationService: LocationServiceProtocol

    // MARK: - Use Cases (Domain Layer)

    private(set) var logCravingUseCase: LogCravingUseCase
    private(set) var fetchCravingsUseCase: FetchCravingsUseCase
    private(set) var deleteCravingUseCase: DeleteCravingUseCase
    private(set) var logUsageUseCase: LogUsageUseCase
    private(set) var fetchUsageUseCase: FetchUsageUseCase
    private(set) var deleteUsageUseCase: DeleteUsageUseCase
    private(set) var exportUserDataUseCase: ExportUserDataUseCase
    private(set) var deleteAllUserDataUseCase: DeleteAllUserDataUseCase
    private(set) var selectMotivationalMessageUseCase: SelectMotivationalMessageUseCase
    private(set) var markMessageShownUseCase: MarkMessageShownUseCase

    // MARK: - View Models (Presentation Layer)

    func makeCravingLogViewModel() -> CravingLogViewModel {
        CravingLogViewModel(
            logCravingUseCase: logCravingUseCase,
            locationService: locationService
        )
    }

    func makeUsageLogViewModel() -> UsageLogViewModel {
        UsageLogViewModel(
            logUsageUseCase: logUsageUseCase,
            locationService: locationService
        )
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

    func makeHomeMotivationViewModel() -> HomeMotivationViewModel {
        HomeMotivationViewModel(
            selectMessageUseCase: selectMotivationalMessageUseCase,
            markShownUseCase: markMessageShownUseCase
        )
    }

    // MARK: - Initialization

    private static func makeWiring(modelContainer: ModelContainer) -> Wiring {
        let modelContext = ModelContext(modelContainer)
        let fileStorage = FileStorageManager()
        let locationService = LocationService()

        let cravingRepo = CravingRepository(modelContext: modelContext)
        let usageRepo = UsageRepository(modelContext: modelContext)
        let recordingRepo = RecordingRepository(modelContext: modelContext, fileStorage: fileStorage)
        let messageRepo = MessageRepository(modelContext: modelContext)

        return Wiring(
            modelContainer: modelContainer,
            modelContext: modelContext,
            fileStorage: fileStorage,
            locationService: locationService,
            cravingRepository: cravingRepo,
            usageRepository: usageRepo,
            recordingRepository: recordingRepo,
            messageRepository: messageRepo,
            logCravingUseCase: DefaultLogCravingUseCase(repository: cravingRepo),
            fetchCravingsUseCase: DefaultFetchCravingsUseCase(repository: cravingRepo),
            deleteCravingUseCase: DefaultDeleteCravingUseCase(repository: cravingRepo),
            logUsageUseCase: DefaultLogUsageUseCase(repository: usageRepo),
            fetchUsageUseCase: DefaultFetchUsageUseCase(repository: usageRepo),
            deleteUsageUseCase: DefaultDeleteUsageUseCase(repository: usageRepo),
            exportUserDataUseCase: DefaultExportUserDataUseCase(
                cravingRepository: cravingRepo,
                usageRepository: usageRepo,
                recordingRepository: recordingRepo,
                messageRepository: messageRepo
            ),
            deleteAllUserDataUseCase: SwiftDataDeleteAllUserDataUseCase(
                modelContext: modelContext
            ),
            selectMotivationalMessageUseCase: DefaultSelectMotivationalMessageUseCase(
                repository: messageRepo
            ),
            markMessageShownUseCase: DefaultMarkMessageShownUseCase(
                repository: messageRepo
            )
        )
    }

    private init(wiring: Wiring, storageMode: StorageMode, initializationError: InitializationError?) {
        modelContainer = wiring.modelContainer
        modelContext = wiring.modelContext
        fileStorage = wiring.fileStorage
        locationService = wiring.locationService

        cravingRepository = wiring.cravingRepository
        usageRepository = wiring.usageRepository
        recordingRepository = wiring.recordingRepository
        messageRepository = wiring.messageRepository

        logCravingUseCase = wiring.logCravingUseCase
        fetchCravingsUseCase = wiring.fetchCravingsUseCase
        deleteCravingUseCase = wiring.deleteCravingUseCase

        logUsageUseCase = wiring.logUsageUseCase
        fetchUsageUseCase = wiring.fetchUsageUseCase
        deleteUsageUseCase = wiring.deleteUsageUseCase

        exportUserDataUseCase = wiring.exportUserDataUseCase
        deleteAllUserDataUseCase = wiring.deleteAllUserDataUseCase
        selectMotivationalMessageUseCase = wiring.selectMotivationalMessageUseCase
        markMessageShownUseCase = wiring.markMessageShownUseCase

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
