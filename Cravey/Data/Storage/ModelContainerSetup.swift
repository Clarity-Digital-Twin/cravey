import Foundation
import SwiftData

/// ModelContainer setup for SwiftData
/// Data layer - handles persistence configuration
enum ModelContainerSetup {
    /// Create the production model container
    @MainActor
    static func create() throws -> ModelContainer {
        let schema = Schema([
            CravingModel.self,
            RecordingModel.self,
            MotivationalMessageModel.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .none  // Local-only storage
        )

        return try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
    }

    /// Create an in-memory container for previews/tests
    @MainActor
    static func createPreview() throws -> ModelContainer {
        let schema = Schema([
            CravingModel.self,
            RecordingModel.self,
            MotivationalMessageModel.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )

        // Seed preview data
        let context = ModelContext(container)
        seedPreviewData(context: context)

        return container
    }

    /// Seed default motivational messages
    @MainActor
    static func seedDefaultMessages(context: ModelContext) {
        let descriptor = FetchDescriptor<MotivationalMessageModel>()
        let existingMessages = (try? context.fetch(descriptor)) ?? []

        guard existingMessages.isEmpty else { return }

        for message in MotivationalMessageEntity.defaultMessages {
            let model = MessageMapper.toModel(message)
            context.insert(model)
        }

        try? context.save()
    }

    /// Seed preview data for SwiftUI previews
    @MainActor
    private static func seedPreviewData(context: ModelContext) {
        // Sample craving
        let craving = CravingModel(
            timestamp: Date().addingTimeInterval(-3600),
            intensity: 7,
            triggers: ["Anxious", "Bored"],
            notes: "Had a rough meeting",
            wasManagedSuccessfully: true
        )
        context.insert(craving)

        // Sample recording
        let recording = RecordingModel(
            recordingType: RecordingType.audio.rawValue,
            purpose: RecordingPurpose.motivational.rawValue,
            title: "Remember Why You Started",
            fileURL: "Recordings/sample.m4a",
            duration: 120,
            notes: "Recorded after 1 week clean"
        )
        context.insert(recording)

        // Sample motivational messages
        for message in MotivationalMessageEntity.defaultMessages {
            context.insert(MessageMapper.toModel(message))
        }

        try? context.save()
    }
}
