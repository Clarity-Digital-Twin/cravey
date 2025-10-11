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

    // MARK: - Use Cases (Domain Layer)

    private(set) var logCravingUseCase: LogCravingUseCase
    private(set) var fetchCravingsUseCase: FetchCravingsUseCase

    // MARK: - View Models (Presentation Layer)

    func makeCravingLogViewModel() -> CravingLogViewModel {
        CravingLogViewModel(logCravingUseCase: logCravingUseCase)
    }

    // TODO: Add more ViewModel factories as needed

    // MARK: - Initialization

    init(isPreview: Bool = false) {
        do {
            // Initialize infrastructure
            self.modelContainer = if isPreview {
                try ModelContainerSetup.createPreview()
            } else {
                try ModelContainerSetup.create()
            }
            self.modelContext = ModelContext(modelContainer)
            self.fileStorage = FileStorageManager.shared

            // Initialize repositories
            let cravingRepo = CravingRepository(modelContext: modelContext)
            let recordingRepo = StubRecordingRepository() // TODO: Implement RecordingRepository
            let messageRepo = StubMessageRepository() // TODO: Implement MessageRepository

            self.cravingRepository = cravingRepo
            self.recordingRepository = recordingRepo
            self.messageRepository = messageRepo

            // Initialize use cases
            self.logCravingUseCase = DefaultLogCravingUseCase(repository: cravingRepo)
            self.fetchCravingsUseCase = DefaultFetchCravingsUseCase(repository: cravingRepo)

            // Seed default data if needed
            if !isPreview {
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
    func save(_ recording: RecordingEntity) async throws {
        // TODO: Implement
    }

    func fetchAll() async throws -> [RecordingEntity] {
        return []
    }

    func fetch(byPurpose purpose: RecordingPurpose) async throws -> [RecordingEntity] {
        return []
    }

    func delete(id: UUID) async throws {
        // TODO: Implement
    }

    func update(_ recording: RecordingEntity) async throws {
        // TODO: Implement
    }
}

/// Stub implementation until MessageRepository is fully implemented
private struct StubMessageRepository: MessageRepositoryProtocol {
    func save(_ message: MotivationalMessageEntity) async throws {
        // TODO: Implement
    }

    func fetchActive() async throws -> [MotivationalMessageEntity] {
        return []
    }

    func fetch(byCategory category: MessageCategory) async throws -> [MotivationalMessageEntity] {
        return []
    }

    func delete(id: UUID) async throws {
        // TODO: Implement
    }

    func update(_ message: MotivationalMessageEntity) async throws {
        // TODO: Implement
    }

    func seedDefaultMessagesIfNeeded() async throws {
        // TODO: Implement
    }
}
