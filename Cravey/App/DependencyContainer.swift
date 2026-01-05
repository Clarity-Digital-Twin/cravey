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
    private(set) var recordingRepository: RecordingRepositoryProtocol
    private(set) var messageRepository: MessageRepositoryProtocol
    private(set) var usageRepository: UsageRepositoryProtocol

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
            let recordingRepo = StubRecordingRepository() // Stub until RecordingRepository implemented
            let messageRepo = StubMessageRepository() // Stub until MessageRepository implemented
            let usageRepo = UsageRepository(modelContext: modelContext)

            cravingRepository = cravingRepo
            recordingRepository = recordingRepo
            messageRepository = messageRepo
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

// MARK: - Stub Implementations (Temporary)

/// Stub implementation until RecordingRepository is fully implemented
private struct StubRecordingRepository: RecordingRepositoryProtocol {
    func save(_: RecordingEntity) async throws {
        // TODO: Implement
    }

    func fetchAll() async throws -> [RecordingEntity] {
        []
    }

    func fetch(byPurpose _: RecordingPurpose) async throws -> [RecordingEntity] {
        []
    }

    func delete(id _: UUID) async throws {
        // TODO: Implement
    }

    func update(_: RecordingEntity) async throws {
        // TODO: Implement
    }
}

/// Stub implementation until MessageRepository is fully implemented
private struct StubMessageRepository: MessageRepositoryProtocol {
    func save(_: MotivationalMessageEntity) async throws {
        // TODO: Implement
    }

    func fetchActive() async throws -> [MotivationalMessageEntity] {
        []
    }

    func fetch(byCategory _: MessageCategory) async throws -> [MotivationalMessageEntity] {
        []
    }

    func delete(id _: UUID) async throws {
        // TODO: Implement
    }

    func update(_: MotivationalMessageEntity) async throws {
        // TODO: Implement
    }

    func seedDefaultMessagesIfNeeded() async throws {
        // TODO: Implement
    }
}
