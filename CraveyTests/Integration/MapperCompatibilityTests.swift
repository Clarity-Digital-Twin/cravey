@testable import Cravey
import Testing

@Suite("Mapper Compatibility Tests")
struct MapperCompatibilityTests {
    @Test("RecordingMapper maps unknown persisted strings to .unknown")
    func recordingMapperUnknownValues() {
        let model = RecordingModel(
            type: "not-a-real-type",
            purpose: "not-a-real-purpose",
            duration: 0,
            filePath: "Recordings/unknown.dat"
        )

        let entity = RecordingMapper.toEntity(model)

        #expect(entity.type == .unknown)
        #expect(entity.purpose == .unknown)
    }

    @Test("MessageMapper maps unknown persisted strings to .unknown")
    func messageMapperUnknownValues() {
        let model = MotivationalMessageModel(
            content: "Test",
            category: "not-a-real-category"
        )

        let entity = MessageMapper.toEntity(model)

        #expect(entity.category == .unknown)
    }
}
