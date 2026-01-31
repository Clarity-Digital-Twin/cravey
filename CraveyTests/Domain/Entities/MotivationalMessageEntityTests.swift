@testable import Cravey
import Foundation
import Testing

@Suite("MotivationalMessageEntity Tests")
struct MotivationalMessageEntityTests {
    // MARK: - markAsShown Tests

    @Test("markAsShown increments timesShown")
    func markAsShownIncrementsCount() {
        let now = TestConstants.fixedEpoch
        let message = MotivationalMessageEntity(
            content: "Test message",
            category: .urge,
            timesShown: 5
        )

        let updated = message.markAsShown(now: now)

        #expect(updated.timesShown == 6)
    }

    @Test("markAsShown sets lastShownAt")
    func markAsShownSetsLastShownAt() {
        let now = TestConstants.fixedEpoch
        let message = MotivationalMessageEntity(
            content: "Test message",
            category: .anxiety,
            lastShownAt: nil
        )

        let updated = message.markAsShown(now: now)

        #expect(updated.lastShownAt == now)
    }

    @Test("markAsShown sets modifiedAt")
    func markAsShownSetsModifiedAt() {
        let now = TestConstants.fixedEpoch
        let message = MotivationalMessageEntity(
            content: "Test message",
            category: .boredom
        )

        let updated = message.markAsShown(now: now)

        #expect(updated.modifiedAt == now)
    }

    @Test("markAsShown preserves other properties")
    func markAsShownPreservesOtherProperties() {
        let now = TestConstants.fixedEpoch
        let originalCreatedAt = now.addingTimeInterval(-TestConstants.Time.secondsPerDay)
        let message = MotivationalMessageEntity(
            content: "Original content",
            category: .social,
            isCustom: true,
            priority: 5,
            isActive: true,
            createdAt: originalCreatedAt
        )

        let updated = message.markAsShown(now: now)

        #expect(updated.id == message.id)
        #expect(updated.content == "Original content")
        #expect(updated.category == .social)
        #expect(updated.isCustom == true)
        #expect(updated.priority == 5)
        #expect(updated.isActive == true)
        #expect(updated.createdAt == originalCreatedAt)
    }

    // MARK: - MessageCategory Tests

    @Test("MessageCategory has all expected cases")
    func messageCategoryHasAllCases() {
        let allCases = MessageCategory.allCases
        #expect(allCases.contains(.urge))
        #expect(allCases.contains(.anxiety))
        #expect(allCases.contains(.boredom))
        #expect(allCases.contains(.social))
        #expect(allCases.contains(.celebration))
        #expect(allCases.contains(.unknown))
        #expect(allCases.count == 6)
    }

    @Test("MessageCategory rawValues match expected strings")
    func messageCategoryRawValues() {
        #expect(MessageCategory.urge.rawValue == "urge")
        #expect(MessageCategory.anxiety.rawValue == "anxiety")
        #expect(MessageCategory.boredom.rawValue == "boredom")
        #expect(MessageCategory.social.rawValue == "social")
        #expect(MessageCategory.celebration.rawValue == "celebration")
        #expect(MessageCategory.unknown.rawValue == "unknown")
    }

    // MARK: - Default Messages Tests

    @Test("defaultMessages contains messages for all main categories")
    func defaultMessagesCoversCategories() {
        let defaults = MotivationalMessageEntity.defaultMessages
        let categories = Set(defaults.map(\.category))

        #expect(categories.contains(.urge))
        #expect(categories.contains(.anxiety))
        #expect(categories.contains(.boredom))
        #expect(categories.contains(.social))
        #expect(categories.contains(.celebration))
    }

    @Test("defaultMessages are not custom")
    func defaultMessagesAreNotCustom() {
        let defaults = MotivationalMessageEntity.defaultMessages

        for message in defaults {
            #expect(message.isCustom == false, "Default message should not be custom: \(message.content)")
        }
    }

    @Test("defaultMessages have unique IDs")
    func defaultMessagesHaveUniqueIds() {
        let defaults = MotivationalMessageEntity.defaultMessages
        let ids = defaults.map(\.id)
        let uniqueIds = Set(ids)

        #expect(ids.count == uniqueIds.count, "All default messages should have unique IDs")
    }
}
