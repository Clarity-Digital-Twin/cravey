@testable import Cravey
import Foundation
import SwiftData
import Testing

/// Integration tests for MessageRepository
/// Tests seeding and update semantics (DEBT-047)
@Suite("MessageRepository Integration Tests")
struct MessageRepositoryIntegrationTests {
    // MARK: - Seeding Tests (via ModelContainerSetup)

    @Test("seedDefaultMessages seeds when empty")
    @MainActor
    func seedsWhenEmpty() async throws {
        // Setup: In-memory SwiftData container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: MotivationalMessageModel.self,
            configurations: config
        )
        let context = ModelContext(container)

        // Precondition: No messages exist
        let initialCount = try context.fetchCount(FetchDescriptor<MotivationalMessageModel>())
        #expect(initialCount == 0)

        // When: Seed default messages
        ModelContainerSetup.seedDefaultMessages(context: context)

        // Then: Default messages were inserted
        let finalCount = try context.fetchCount(FetchDescriptor<MotivationalMessageModel>())
        #expect(finalCount > 0, "Expected default messages to be seeded")

        // Verify messages have expected properties
        let messages = try context.fetch(FetchDescriptor<MotivationalMessageModel>())
        for message in messages {
            #expect(message.isCustom == false, "Default messages should have isCustom = false")
            #expect(message.isActive == true, "Default messages should be active")
        }
    }

    @Test("seedDefaultMessages does NOT seed when non-empty")
    @MainActor
    func doesNotSeedWhenNonEmpty() async throws {
        // Setup: In-memory SwiftData container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: MotivationalMessageModel.self,
            configurations: config
        )
        let context = ModelContext(container)

        // Pre-insert a custom message
        let existingMessage = MotivationalMessageModel(
            content: "Existing custom message",
            category: "urge",
            isCustom: true,
            priority: 1,
            isActive: true
        )
        context.insert(existingMessage)
        try context.save()

        let initialCount = try context.fetchCount(FetchDescriptor<MotivationalMessageModel>())
        #expect(initialCount == 1)

        // When: Try to seed default messages
        ModelContainerSetup.seedDefaultMessages(context: context)

        // Then: No new messages added (seeding skipped)
        let finalCount = try context.fetchCount(FetchDescriptor<MotivationalMessageModel>())
        #expect(finalCount == 1, "Expected seeding to be skipped when messages exist")

        // Verify the existing message is still there
        let messages = try context.fetch(FetchDescriptor<MotivationalMessageModel>())
        #expect(messages[0].content == "Existing custom message")
        #expect(messages[0].isCustom == true)
    }

    // MARK: - Update Tests

    @Test("update preserves modifiedAt from entity")
    @MainActor
    func updatePreservesModifiedAt() async throws {
        // Setup: In-memory SwiftData container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: MotivationalMessageModel.self,
            configurations: config
        )
        let context = ModelContext(container)

        let repository = MessageRepository(modelContext: context)
        let now = TestConstants.fixedEpoch

        // Insert a message
        let originalEntity = MotivationalMessageEntity(
            content: "Original content",
            category: .urge,
            isCustom: false,
            priority: 1,
            isActive: true,
            timesShown: 0,
            lastShownAt: nil,
            createdAt: now,
            modifiedAt: nil
        )
        try await repository.save(originalEntity)

        // Create updated entity with specific modifiedAt
        let specificModifiedAt = Date(timeIntervalSince1970: 1_000_000)
        let updatedEntity = MotivationalMessageEntity(
            id: originalEntity.id,
            content: "Updated content",
            category: .urge,
            isCustom: false,
            priority: 1,
            isActive: true,
            timesShown: 5,
            lastShownAt: now,
            createdAt: originalEntity.createdAt,
            modifiedAt: specificModifiedAt
        )

        // When: Update via repository
        try await repository.update(updatedEntity)

        // Then: Fetch and verify modifiedAt was preserved
        let fetched = try await repository.fetchAll()
        #expect(fetched.count == 1)
        #expect(fetched[0].content == "Updated content")
        #expect(fetched[0].timesShown == 5)

        // The key assertion: modifiedAt should be what we passed, not overwritten
        #expect(fetched[0].modifiedAt != nil)
        #expect(abs(fetched[0].modifiedAt!.timeIntervalSince(specificModifiedAt)) < 1.0,
                "modifiedAt should be preserved from entity, not overwritten by repository")
    }

    @Test("update uses fallback Date() when modifiedAt is nil")
    @MainActor
    func updateUsesFallbackWhenModifiedAtNil() async throws {
        // Setup
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: MotivationalMessageModel.self,
            configurations: config
        )
        let context = ModelContext(container)

        let repository = MessageRepository(modelContext: context)

        // Insert a message
        let originalEntity = MotivationalMessageEntity(
            content: "Original",
            category: .anxiety,
            isCustom: false,
            priority: 1,
            isActive: true
        )
        try await repository.save(originalEntity)

        // Update with nil modifiedAt
        let beforeUpdate = Date()
        let updatedEntity = MotivationalMessageEntity(
            id: originalEntity.id,
            content: "Updated",
            category: .anxiety,
            isCustom: false,
            priority: 2,
            isActive: true,
            timesShown: 1,
            lastShownAt: nil,
            createdAt: originalEntity.createdAt,
            modifiedAt: nil // Explicit nil
        )

        try await repository.update(updatedEntity)
        let afterUpdate = Date()

        // Then: modifiedAt should be set to approximately now (fallback)
        let fetched = try await repository.fetchAll()
        #expect(fetched.count == 1)
        #expect(fetched[0].modifiedAt != nil)
        #expect(fetched[0].modifiedAt! >= beforeUpdate)
        #expect(fetched[0].modifiedAt! <= afterUpdate)
    }
}
