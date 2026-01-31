@testable import Cravey
import Foundation
import Testing

@Suite("RecordingEntity Tests")
struct RecordingEntityTests {
    // MARK: - durationFormatted Tests

    @Test("durationFormatted shows minutes and seconds")
    func durationFormattedBasic() {
        let recording = RecordingEntity(
            type: .audio,
            purpose: .motivational,
            duration: 125, // 2:05
            filePath: "test.m4a"
        )

        #expect(recording.durationFormatted == "2:05")
    }

    @Test("durationFormatted handles zero")
    func durationFormattedZero() {
        let recording = RecordingEntity(
            type: .audio,
            purpose: .motivational,
            duration: 0,
            filePath: "test.m4a"
        )

        #expect(recording.durationFormatted == "0:00")
    }

    @Test("durationFormatted handles seconds only")
    func durationFormattedSecondsOnly() {
        let recording = RecordingEntity(
            type: .audio,
            purpose: .motivational,
            duration: 45,
            filePath: "test.m4a"
        )

        #expect(recording.durationFormatted == "0:45")
    }

    @Test("durationFormatted handles exact minutes")
    func durationFormattedExactMinutes() {
        let recording = RecordingEntity(
            type: .audio,
            purpose: .motivational,
            duration: 180, // 3:00
            filePath: "test.m4a"
        )

        #expect(recording.durationFormatted == "3:00")
    }

    @Test("durationFormatted pads seconds with zero")
    func durationFormattedPadsSeconds() {
        let recording = RecordingEntity(
            type: .audio,
            purpose: .motivational,
            duration: 63, // 1:03
            filePath: "test.m4a"
        )

        #expect(recording.durationFormatted == "1:03")
    }

    // MARK: - incrementPlayCount Tests

    @Test("incrementPlayCount increases playCount by 1")
    func incrementPlayCountIncrements() {
        let now = TestConstants.fixedEpoch
        let recording = RecordingEntity(
            type: .video,
            purpose: .reflection,
            duration: 60,
            filePath: "test.mov",
            playCount: 5
        )

        let updated = recording.incrementPlayCount(now: now)

        #expect(updated.playCount == 6)
    }

    @Test("incrementPlayCount sets lastPlayedAt")
    func incrementPlayCountSetsLastPlayedAt() {
        let now = TestConstants.fixedEpoch
        let recording = RecordingEntity(
            type: .video,
            purpose: .milestone,
            duration: 60,
            filePath: "test.mov",
            lastPlayedAt: nil
        )

        let updated = recording.incrementPlayCount(now: now)

        #expect(updated.lastPlayedAt == now)
    }

    @Test("incrementPlayCount sets modifiedAt")
    func incrementPlayCountSetsModifiedAt() {
        let now = TestConstants.fixedEpoch
        let recording = RecordingEntity(
            type: .audio,
            purpose: .craving,
            duration: 30,
            filePath: "test.m4a"
        )

        let updated = recording.incrementPlayCount(now: now)

        #expect(updated.modifiedAt == now)
    }

    @Test("incrementPlayCount preserves other properties")
    func incrementPlayCountPreservesOtherProperties() {
        let now = TestConstants.fixedEpoch
        let originalCreatedAt = now.addingTimeInterval(-TestConstants.Time.secondsPerDay)
        let recording = RecordingEntity(
            type: .video,
            purpose: .motivational,
            duration: 120,
            filePath: "Recordings/video_test.mov",
            thumbnailPath: "Recordings/Thumbnails/video_test_thumb.jpg",
            title: "My Motivation",
            notes: "Important video",
            createdAt: originalCreatedAt
        )

        let updated = recording.incrementPlayCount(now: now)

        #expect(updated.id == recording.id)
        #expect(updated.timestamp == recording.timestamp)
        #expect(updated.type == .video)
        #expect(updated.purpose == .motivational)
        #expect(updated.duration == 120)
        #expect(updated.filePath == "Recordings/video_test.mov")
        #expect(updated.thumbnailPath == "Recordings/Thumbnails/video_test_thumb.jpg")
        #expect(updated.title == "My Motivation")
        #expect(updated.notes == "Important video")
        #expect(updated.createdAt == originalCreatedAt)
    }

    // MARK: - RecordingType Tests

    @Test("RecordingType fileExtension returns correct values")
    func recordingTypeFileExtensions() {
        #expect(RecordingType.video.fileExtension == "mov")
        #expect(RecordingType.audio.fileExtension == "m4a")
        #expect(RecordingType.unknown.fileExtension == "dat")
    }

    @Test("RecordingType has all expected cases")
    func recordingTypeHasAllCases() {
        let allCases = RecordingType.allCases
        #expect(allCases.contains(.video))
        #expect(allCases.contains(.audio))
        #expect(allCases.contains(.unknown))
        #expect(allCases.count == 3)
    }

    // MARK: - RecordingPurpose Tests

    @Test("RecordingPurpose has all expected cases")
    func recordingPurposeHasAllCases() {
        let allCases = RecordingPurpose.allCases
        #expect(allCases.contains(.motivational))
        #expect(allCases.contains(.milestone))
        #expect(allCases.contains(.reflection))
        #expect(allCases.contains(.craving))
        #expect(allCases.contains(.unknown))
        #expect(allCases.count == 5)
    }

    @Test("RecordingPurpose rawValues match expected strings")
    func recordingPurposeRawValues() {
        #expect(RecordingPurpose.motivational.rawValue == "motivational")
        #expect(RecordingPurpose.milestone.rawValue == "milestone")
        #expect(RecordingPurpose.reflection.rawValue == "reflection")
        #expect(RecordingPurpose.craving.rawValue == "craving")
        #expect(RecordingPurpose.unknown.rawValue == "unknown")
    }
}
