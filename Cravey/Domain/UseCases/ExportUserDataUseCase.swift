import Foundation

/// Export payload for sharing/backup (JSON-encodable).
struct UserDataExport: Codable, Sendable {
    static let currentSchemaVersion: Int = 1

    let schemaVersion: Int
    let exportDate: Date
    let cravings: [CravingEntity]
    let usages: [UsageEntity]
    let recordings: [RecordingEntity]
    let messages: [MotivationalMessageEntity]
}

/// Use Case: Export all user data as a value object suitable for JSON encoding.
protocol ExportUserDataUseCase: Sendable {
    func execute() async throws -> UserDataExport
}

final class DefaultExportUserDataUseCase: ExportUserDataUseCase, Sendable {
    private let cravingRepository: CravingRepositoryProtocol
    private let usageRepository: UsageRepositoryProtocol
    private let recordingRepository: RecordingRepositoryProtocol
    private let messageRepository: MessageRepositoryProtocol
    private let clock: any Clock

    init(
        cravingRepository: CravingRepositoryProtocol,
        usageRepository: UsageRepositoryProtocol,
        recordingRepository: RecordingRepositoryProtocol,
        messageRepository: MessageRepositoryProtocol,
        clock: any Clock = SystemClock()
    ) {
        self.cravingRepository = cravingRepository
        self.usageRepository = usageRepository
        self.recordingRepository = recordingRepository
        self.messageRepository = messageRepository
        self.clock = clock
    }

    func execute() async throws -> UserDataExport {
        async let cravingsTask = cravingRepository.fetchAll()
        async let usagesTask = usageRepository.fetchAll()
        async let recordingsTask = recordingRepository.fetchAll()
        async let messagesTask = messageRepository.fetchAll()

        let (cravings, usages, recordings, messages) = try await (
            cravingsTask,
            usagesTask,
            recordingsTask,
            messagesTask
        )

        return UserDataExport(
            schemaVersion: UserDataExport.currentSchemaVersion,
            exportDate: clock.now(),
            cravings: cravings.sorted { $0.timestamp > $1.timestamp },
            usages: usages.sorted { $0.timestamp > $1.timestamp },
            recordings: recordings.sorted { $0.timestamp > $1.timestamp },
            messages: messages.sorted {
                if $0.category.rawValue == $1.category.rawValue {
                    return $0.priority < $1.priority
                }
                return $0.category.rawValue < $1.category.rawValue
            }
        )
    }
}
