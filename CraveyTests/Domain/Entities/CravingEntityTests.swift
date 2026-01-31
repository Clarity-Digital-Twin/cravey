@testable import Cravey
import Foundation
import Testing

@Suite("CravingEntity Tests")
struct CravingEntityTests {
    // MARK: - isWithinLast Tests

    @Test("isWithinLast returns true for recent timestamp")
    func isWithinLastTrueForRecent() {
        let now = Date(timeIntervalSince1970: 1_000_000_000)
        let craving = CravingEntity(
            timestamp: now.addingTimeInterval(-3600), // 1 hour ago
            intensity: 5
        )

        #expect(craving.isWithinLast(24, now: now) == true)
    }

    @Test("isWithinLast returns false for old timestamp")
    func isWithinLastFalseForOld() {
        let now = Date(timeIntervalSince1970: 1_000_000_000)
        let craving = CravingEntity(
            timestamp: now.addingTimeInterval(-86400 * 2), // 2 days ago
            intensity: 5
        )

        #expect(craving.isWithinLast(24, now: now) == false)
    }

    @Test("isWithinLast boundary - exactly N hours ago is included")
    func isWithinLastBoundaryIncluded() {
        let now = Date(timeIntervalSince1970: 1_000_000_000)
        let craving = CravingEntity(
            timestamp: now.addingTimeInterval(-24 * 3600), // Exactly 24h ago
            intensity: 5
        )

        // >= cutoff means exactly on boundary should be included
        #expect(craving.isWithinLast(24, now: now) == true)
    }

    @Test("isWithinLast just past boundary is excluded")
    func isWithinLastPastBoundaryExcluded() {
        let now = Date(timeIntervalSince1970: 1_000_000_000)
        let craving = CravingEntity(
            timestamp: now.addingTimeInterval(-24 * 3600 - 1), // 24h + 1s ago
            intensity: 5
        )

        #expect(craving.isWithinLast(24, now: now) == false)
    }

    // MARK: - IntensityLevel Tests

    @Test("intensityLevel low for 1-3")
    func intensityLevelLow() {
        #expect(CravingEntity(timestamp: Date(), intensity: 1).intensityLevel == .low)
        #expect(CravingEntity(timestamp: Date(), intensity: 3).intensityLevel == .low)
    }

    @Test("intensityLevel moderate for 4-6")
    func intensityLevelModerate() {
        #expect(CravingEntity(timestamp: Date(), intensity: 4).intensityLevel == .moderate)
        #expect(CravingEntity(timestamp: Date(), intensity: 6).intensityLevel == .moderate)
    }

    @Test("intensityLevel high for 7-10")
    func intensityLevelHigh() {
        #expect(CravingEntity(timestamp: Date(), intensity: 7).intensityLevel == .high)
        #expect(CravingEntity(timestamp: Date(), intensity: 10).intensityLevel == .high)
    }

    @Test("intensityLevel unknown for out of range")
    func intensityLevelUnknown() {
        #expect(CravingEntity(timestamp: Date(), intensity: 0).intensityLevel == .unknown)
        #expect(CravingEntity(timestamp: Date(), intensity: 11).intensityLevel == .unknown)
    }
}
