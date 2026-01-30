import Foundation
import OSLog
import SwiftData

/// ModelContainer setup for SwiftData
/// Data layer - handles persistence configuration
enum ModelContainerSetup {
    private static let logger = Logger(subsystem: "com.cravey", category: "ModelContainerSetup")

    /// Create the production model container
    @MainActor
    static func create() throws -> ModelContainer {
        let schema = Schema([
            CravingModel.self,
            UsageModel.self,
            RecordingModel.self,
            MotivationalMessageModel.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .none // Local-only storage
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
            UsageModel.self,
            RecordingModel.self,
            MotivationalMessageModel.self,
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

    /// Create an in-memory container for UI testing (empty database)
    @MainActor
    static func createUITesting() throws -> ModelContainer {
        let schema = Schema([
            CravingModel.self,
            UsageModel.self,
            RecordingModel.self,
            MotivationalMessageModel.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
    }

    /// Seed default motivational messages
    /// DEBT-036: Failure is non-fatal - app can function without default messages
    /// Errors are logged at warning level since this is recoverable
    @MainActor
    static func seedDefaultMessages(context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<MotivationalMessageModel>()
            let existingMessages = try context.fetch(descriptor)

            guard existingMessages.isEmpty else { return }

            for message in MotivationalMessageEntity.defaultMessages {
                let model = MessageMapper.toModel(message)
                context.insert(model)
            }

            try context.save()
            logger.info("Successfully seeded \(MotivationalMessageEntity.defaultMessages.count) default messages")
        } catch {
            // Warning level because this is recoverable - app works without default messages
            logger.warning("Failed to seed default messages (non-fatal): \(error.localizedDescription)")
        }
    }

    /// Seed preview data for SwiftUI previews
    @MainActor
    private static func seedPreviewData(context: ModelContext) {
        // Sample craving (spec-aligned: no wasManagedSuccessfully field)
        let craving = CravingModel(
            timestamp: Date().addingTimeInterval(-3600),
            intensity: 7,
            triggers: ["Anxious", "Bored"],
            location: "Work",
            notes: "Had a rough meeting"
        )
        context.insert(craving)

        // Sample recording
        let recording = RecordingModel(
            type: RecordingType.audio.rawValue,
            purpose: RecordingPurpose.motivational.rawValue,
            duration: 120,
            filePath: "Recordings/audio_sample.m4a",
            title: "Remember Why You Started",
            notes: "Recorded after 1 week clean"
        )
        context.insert(recording)

        // Sample motivational messages
        for message in MotivationalMessageEntity.defaultMessages {
            context.insert(MessageMapper.toModel(message))
        }

        do {
            try context.save()
        } catch {
            logger.error("Failed to seed preview data: \(error.localizedDescription)")
        }
    }
}
