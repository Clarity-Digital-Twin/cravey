import Foundation

/// Export payload for sharing/backup (JSON-encodable).
struct UserDataExport: Codable, Sendable {
    let exportDate: Date
    let cravings: [CravingEntity]
    let usages: [UsageEntity]
}

/// Use Case: Export all user data as a value object suitable for JSON encoding.
protocol ExportUserDataUseCase: Sendable {
    func execute() async throws -> UserDataExport
}

final class DefaultExportUserDataUseCase: ExportUserDataUseCase {
    private let cravingRepository: CravingRepositoryProtocol
    private let usageRepository: UsageRepositoryProtocol

    init(cravingRepository: CravingRepositoryProtocol, usageRepository: UsageRepositoryProtocol) {
        self.cravingRepository = cravingRepository
        self.usageRepository = usageRepository
    }

    func execute() async throws -> UserDataExport {
        async let cravingsTask = cravingRepository.fetchAll()
        async let usagesTask = usageRepository.fetchAll()
        let (cravings, usages) = try await (cravingsTask, usagesTask)

        return UserDataExport(
            exportDate: Date(),
            cravings: cravings.sorted { $0.timestamp > $1.timestamp },
            usages: usages.sorted { $0.timestamp > $1.timestamp }
        )
    }
}
