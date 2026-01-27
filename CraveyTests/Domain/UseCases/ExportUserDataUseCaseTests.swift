@testable import Cravey
import Foundation
import Testing

@Suite("ExportUserDataUseCase Tests")
struct ExportUserDataUseCaseTests {
    @Test("Export includes all user data types and sorts deterministically")
    func exportIncludesAllTypes() async throws {
        let now = Date(timeIntervalSince1970: 1_000_000_000)

        let cravings: [CravingEntity] = [
            CravingEntity(timestamp: now.addingTimeInterval(-50), intensity: 2, triggers: ["Bored"]),
            CravingEntity(timestamp: now.addingTimeInterval(-10), intensity: 9, triggers: ["Anxious"]),
        ]

        let usages: [UsageEntity] = [
            UsageEntity(timestamp: now.addingTimeInterval(-30), method: "Bowls", amount: 1.0),
            UsageEntity(timestamp: now.addingTimeInterval(-5), method: "Edible", amount: 10.0),
        ]

        let recordings: [RecordingEntity] = [
            RecordingEntity(
                timestamp: now.addingTimeInterval(-20),
                type: .audio,
                purpose: .motivational,
                duration: 60,
                filePath: "Recordings/audio_1.m4a",
                title: "A"
            ),
            RecordingEntity(
                timestamp: now.addingTimeInterval(-1),
                type: .video,
                purpose: .reflection,
                duration: 30,
                filePath: "Recordings/video_1.mov",
                title: "B"
            ),
        ]

        let messages: [MotivationalMessageEntity] = [
            MotivationalMessageEntity(content: "B", category: .social, priority: 2),
            MotivationalMessageEntity(content: "A", category: .social, priority: 1),
            MotivationalMessageEntity(content: "C", category: .urge, priority: 1),
        ]

        let useCase = DefaultExportUserDataUseCase(
            cravingRepository: MockCravingRepository(result: cravings),
            usageRepository: MockUsageRepository(result: usages),
            recordingRepository: MockRecordingRepository(result: recordings),
            messageRepository: MockMessageRepository(result: messages)
        )

        let export = try await useCase.execute()

        #expect(export.schemaVersion == UserDataExport.currentSchemaVersion)

        #expect(export.cravings.map(\.timestamp) == cravings.map(\.timestamp).sorted(by: >))
        #expect(export.usages.map(\.timestamp) == usages.map(\.timestamp).sorted(by: >))
        #expect(export.recordings.map(\.timestamp) == recordings.map(\.timestamp).sorted(by: >))

        // Messages sort: category ascending, then priority ascending
        let expectedMessageOrder = messages.sorted {
            if $0.category.rawValue == $1.category.rawValue {
                return $0.priority < $1.priority
            }
            return $0.category.rawValue < $1.category.rawValue
        }
        #expect(export.messages.map(\.id) == expectedMessageOrder.map(\.id))
    }
}

// MARK: - Mocks

actor MockCravingRepository: CravingRepositoryProtocol {
    let result: [CravingEntity]

    init(result: [CravingEntity]) {
        self.result = result
    }

    func save(_: CravingEntity) async throws {}

    func fetchAll() async throws -> [CravingEntity] {
        result
    }

    func fetch(from startDate: Date, to endDate: Date) async throws -> [CravingEntity] {
        result.filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
    }

    func delete(id _: UUID) async throws {}

    func update(_: CravingEntity) async throws {}

    func count() async throws -> Int {
        result.count
    }
}

actor MockUsageRepository: UsageRepositoryProtocol {
    let result: [UsageEntity]

    init(result: [UsageEntity]) {
        self.result = result
    }

    func save(_: UsageEntity) async throws {}

    func fetchAll() async throws -> [UsageEntity] {
        result
    }

    func fetch(since date: Date) async throws -> [UsageEntity] {
        result.filter { $0.timestamp >= date }
    }

    func delete(id _: UUID) async throws {}

    func deleteAll() async throws {}
}

actor MockRecordingRepository: RecordingRepositoryProtocol {
    let result: [RecordingEntity]

    init(result: [RecordingEntity]) {
        self.result = result
    }

    func save(_: RecordingEntity) async throws {}

    func fetchAll() async throws -> [RecordingEntity] {
        result
    }

    func fetch(byPurpose purpose: RecordingPurpose) async throws -> [RecordingEntity] {
        result.filter { $0.purpose == purpose }
    }

    func delete(id _: UUID) async throws {}

    func update(_: RecordingEntity) async throws {}
}

actor MockMessageRepository: MessageRepositoryProtocol {
    let result: [MotivationalMessageEntity]

    init(result: [MotivationalMessageEntity]) {
        self.result = result
    }

    func save(_: MotivationalMessageEntity) async throws {}

    func fetchAll() async throws -> [MotivationalMessageEntity] {
        result
    }

    func fetchActive() async throws -> [MotivationalMessageEntity] {
        result.filter(\.isActive)
    }

    func fetch(byCategory category: MessageCategory) async throws -> [MotivationalMessageEntity] {
        result.filter { $0.isActive && $0.category == category }
    }

    func delete(id _: UUID) async throws {}

    func update(_: MotivationalMessageEntity) async throws {}

    func seedDefaultMessagesIfNeeded() async throws {}
}
