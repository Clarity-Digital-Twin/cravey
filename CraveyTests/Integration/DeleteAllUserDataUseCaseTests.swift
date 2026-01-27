@testable import Cravey
import Foundation
import SwiftData
import Testing

@Suite("DeleteAllUserDataUseCase Integration Tests")
struct DeleteAllUserDataUseCaseTests {
    @Test("Deletes cravings/usages/recordings and custom messages, keeps defaults")
    @MainActor
    func deleteAllKeepsDefaultMessages() async throws {
        let schema = Schema([
            CravingModel.self,
            UsageModel.self,
            RecordingModel.self,
            MotivationalMessageModel.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        context.insert(CravingModel(timestamp: Date(), intensity: 5))
        context.insert(UsageModel(timestamp: Date(), method: "Bowls", amount: 1.0))
        context.insert(RecordingModel(type: "audio", purpose: "motivational", duration: 10, filePath: "Recordings/a.m4a"))
        context.insert(MotivationalMessageModel(content: "Default", category: "urge", isCustom: false))
        context.insert(MotivationalMessageModel(content: "Custom", category: "urge", isCustom: true))
        try context.save()

        let useCase = SwiftDataDeleteAllUserDataUseCase(
            modelContext: context,
            stageRecordingFilesDeletion: { nil },
            commitRecordingFilesDeletion: { _ in },
            rollbackRecordingFilesDeletion: { _ in }
        )

        try await useCase.execute()

        #expect(try context.fetchCount(FetchDescriptor<CravingModel>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<UsageModel>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<RecordingModel>()) == 0)

        let messages = try context.fetch(FetchDescriptor<MotivationalMessageModel>())
        #expect(messages.count == 1)
        #expect(messages.first?.isCustom == false)
    }
}
