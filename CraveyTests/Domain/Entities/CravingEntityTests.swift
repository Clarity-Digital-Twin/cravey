@testable import Cravey
import Foundation
import Testing

@Suite("CravingEntity Tests")
struct CravingEntityTests {
    // MARK: - isWithinLast Tests

    @Test("isWithinLast returns true for recent timestamp")
    func isWithinLastTrueForRecent() {
        let now = TestConstants.fixedEpoch
        let craving = CravingEntity(
            timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerHour), // 1 hour ago
            intensity: 5
        )

        #expect(craving.isWithinLast(24, now: now) == true)
    }

    @Test("isWithinLast returns false for old timestamp")
    func isWithinLastFalseForOld() {
        let now = TestConstants.fixedEpoch
        let craving = CravingEntity(
            timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerDay * 2), // 2 days ago
            intensity: 5
        )

        #expect(craving.isWithinLast(24, now: now) == false)
    }

    @Test("isWithinLast boundary - exactly N hours ago is included")
    func isWithinLastBoundaryIncluded() {
        let now = TestConstants.fixedEpoch
        let craving = CravingEntity(
            timestamp: now.addingTimeInterval(-TestConstants.Time.secondsPerDay), // Exactly 24h ago
            intensity: 5
        )

        // >= cutoff means exactly on boundary should be included
        #expect(craving.isWithinLast(24, now: now) == true)
    }

    @Test("isWithinLast just past boundary is excluded")
    func isWithinLastPastBoundaryExcluded() {
        let now = TestConstants.fixedEpoch
        let craving = CravingEntity(
            timestamp: now.addingTimeInterval(-(TestConstants.Time.secondsPerDay + 1)), // 24h + 1s ago
            intensity: 5
        )

        #expect(craving.isWithinLast(24, now: now) == false)
    }

    // MARK: - IntensityLevel Tests

    @Test("intensityLevel low for 1-3")
    func intensityLevelLow() {
        #expect(CravingEntity(timestamp: TestConstants.fixedEpoch, intensity: 1).intensityLevel == .low)
        #expect(CravingEntity(timestamp: TestConstants.fixedEpoch, intensity: 3).intensityLevel == .low)
    }

    @Test("intensityLevel moderate for 4-6")
    func intensityLevelModerate() {
        #expect(CravingEntity(timestamp: TestConstants.fixedEpoch, intensity: 4).intensityLevel == .moderate)
        #expect(CravingEntity(timestamp: TestConstants.fixedEpoch, intensity: 6).intensityLevel == .moderate)
    }

    @Test("intensityLevel high for 7-10")
    func intensityLevelHigh() {
        #expect(CravingEntity(timestamp: TestConstants.fixedEpoch, intensity: 7).intensityLevel == .high)
        #expect(CravingEntity(timestamp: TestConstants.fixedEpoch, intensity: 10).intensityLevel == .high)
    }

    @Test("intensityLevel unknown for out of range")
    func intensityLevelUnknown() {
        #expect(CravingEntity(timestamp: TestConstants.fixedEpoch, intensity: 0).intensityLevel == .unknown)
        #expect(CravingEntity(timestamp: TestConstants.fixedEpoch, intensity: 11).intensityLevel == .unknown)
    }
}
