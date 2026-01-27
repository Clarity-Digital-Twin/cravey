@testable import Cravey
import Foundation
import Testing

@Suite("UserDataExportFileBuilder Tests")
struct UserDataExportFileBuilderTests {
    @Test("CSV export contains header and one row per record")
    func csvIncludesAllRecords() throws {
        let now = Date(timeIntervalSince1970: 1_000_000_000)

        let export = UserDataExport(
            schemaVersion: UserDataExport.currentSchemaVersion,
            exportDate: now,
            cravings: [
                CravingEntity(timestamp: now, intensity: 5, triggers: ["Bored"], location: "Home", notes: "Note"),
            ],
            usages: [
                UsageEntity(timestamp: now, method: "Bowls", amount: 1.0, triggers: ["Anxious"]),
                UsageEntity(timestamp: now, method: "Edible", amount: 10.0),
            ],
            recordings: [
                RecordingEntity(
                    timestamp: now,
                    type: .audio,
                    purpose: .motivational,
                    duration: 30,
                    filePath: "Recordings/audio_1.m4a",
                    title: "Title"
                ),
            ],
            messages: [
                MotivationalMessageEntity(content: "Hello, world", category: .urge, isCustom: true),
            ]
        )

        let csv = UserDataExportFileBuilder.makeCSVString(export: export)
        let lines = csv.split(separator: "\n", omittingEmptySubsequences: true)

        // 1 header + (1 craving + 2 usage + 1 recording + 1 message) rows
        #expect(lines.count == 1 + 1 + 2 + 1 + 1)

        let header = String(lines[0])
        #expect(header.contains("record_type"))
        #expect(header.contains("craving_intensity"))
        #expect(header.contains("usage_method"))
        #expect(header.contains("recording_type"))
        #expect(header.contains("message_content"))
    }

    @Test("JSON export round-trips UserDataExport")
    func jsonRoundTrip() throws {
        let now = Date(timeIntervalSince1970: 1_000_000_000)

        let export = UserDataExport(
            schemaVersion: UserDataExport.currentSchemaVersion,
            exportDate: now,
            cravings: [CravingEntity(timestamp: now, intensity: 5)],
            usages: [UsageEntity(timestamp: now, method: "Bowls", amount: 1.0)],
            recordings: [],
            messages: []
        )

        let jsonData = try UserDataExportFileBuilder.makeFileData(export: export, format: .json)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(UserDataExport.self, from: jsonData)

        #expect(decoded.schemaVersion == export.schemaVersion)
        #expect(decoded.cravings.count == export.cravings.count)
        #expect(decoded.usages.count == export.usages.count)
    }
}

