import Foundation

enum UserDataExportFileBuilder {
    private static let csvHeader = [
        "record_type",
        "id",
        "timestamp",
        "created_at",
        "modified_at",
        "craving_intensity",
        "craving_triggers",
        "craving_location",
        "craving_notes",
        "usage_method",
        "usage_amount",
        "usage_triggers",
        "usage_location",
        "usage_notes",
        "recording_type",
        "recording_purpose",
        "recording_duration_seconds",
        "recording_file_path",
        "recording_thumbnail_path",
        "recording_title",
        "recording_notes",
        "recording_play_count",
        "recording_last_played_at",
        "message_content",
        "message_category",
        "message_is_custom",
        "message_priority",
        "message_is_active",
        "message_times_shown",
        "message_last_shown_at",
    ]

    private enum CSVColumn: Int {
        case recordType = 0
        case id
        case timestamp
        case createdAt
        case modifiedAt
        case cravingIntensity
        case cravingTriggers
        case cravingLocation
        case cravingNotes
        case usageMethod
        case usageAmount
        case usageTriggers
        case usageLocation
        case usageNotes
        case recordingType
        case recordingPurpose
        case recordingDurationSeconds
        case recordingFilePath
        case recordingThumbnailPath
        case recordingTitle
        case recordingNotes
        case recordingPlayCount
        case recordingLastPlayedAt
        case messageContent
        case messageCategory
        case messageIsCustom
        case messagePriority
        case messageIsActive
        case messageTimesShown
        case messageLastShownAt
    }

    enum ExportFileBuilderError: LocalizedError, Sendable {
        case utf8EncodingFailed

        var errorDescription: String? {
            switch self {
            case .utf8EncodingFailed:
                "We couldn’t create the export file. Please try again."
            }
        }
    }

    static func makeFileData(export: UserDataExport, format: ExportFormat) throws -> Data {
        switch format {
        case .json:
            try makeJSONData(export: export)
        case .csv:
            try makeCSVData(export: export)
        }
    }

    static func fileExtension(for format: ExportFormat) -> String {
        format.rawValue
    }

    static func makeCSVString(export: UserDataExport) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var rows: [[String]] = [csvHeader]
        rows.append(contentsOf: export.cravings.map { cravingCSVRow(craving: $0, formatter: formatter) })
        rows.append(contentsOf: export.usages.map { usageCSVRow(usage: $0, formatter: formatter) })
        rows.append(contentsOf: export.recordings.map { recordingCSVRow(recording: $0, formatter: formatter) })
        rows.append(contentsOf: export.messages.map { messageCSVRow(message: $0, formatter: formatter) })

        return rows.map { $0.map(csvEscape).joined(separator: ",") }.joined(separator: "\n") + "\n"
    }

    private static func makeJSONData(export: UserDataExport) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(export)
    }

    private static func makeCSVData(export: UserDataExport) throws -> Data {
        let csvString = makeCSVString(export: export)
        guard let data = csvString.data(using: .utf8) else {
            throw ExportFileBuilderError.utf8EncodingFailed
        }
        return data
    }

    private static func cravingCSVRow(craving: CravingEntity, formatter: ISO8601DateFormatter) -> [String] {
        var row = emptyCSVRow()
        row[CSVColumn.recordType.rawValue] = "craving"
        row[CSVColumn.id.rawValue] = craving.id.uuidString
        row[CSVColumn.timestamp.rawValue] = formatter.string(from: craving.timestamp)
        row[CSVColumn.createdAt.rawValue] = formatter.string(from: craving.createdAt)
        row[CSVColumn.modifiedAt.rawValue] = craving.modifiedAt.map(formatter.string(from:)) ?? ""
        row[CSVColumn.cravingIntensity.rawValue] = String(craving.intensity)
        row[CSVColumn.cravingTriggers.rawValue] = craving.triggers.joined(separator: "; ")
        row[CSVColumn.cravingLocation.rawValue] = craving.location ?? ""
        row[CSVColumn.cravingNotes.rawValue] = craving.notes ?? ""
        return row
    }

    private static func usageCSVRow(usage: UsageEntity, formatter: ISO8601DateFormatter) -> [String] {
        var row = emptyCSVRow()
        row[CSVColumn.recordType.rawValue] = "usage"
        row[CSVColumn.id.rawValue] = usage.id.uuidString
        row[CSVColumn.timestamp.rawValue] = formatter.string(from: usage.timestamp)
        row[CSVColumn.createdAt.rawValue] = formatter.string(from: usage.createdAt)
        row[CSVColumn.modifiedAt.rawValue] = usage.modifiedAt.map(formatter.string(from:)) ?? ""
        row[CSVColumn.usageMethod.rawValue] = usage.method
        row[CSVColumn.usageAmount.rawValue] = String(usage.amount)
        row[CSVColumn.usageTriggers.rawValue] = usage.triggers.joined(separator: "; ")
        row[CSVColumn.usageLocation.rawValue] = usage.location ?? ""
        row[CSVColumn.usageNotes.rawValue] = usage.notes ?? ""
        return row
    }

    private static func recordingCSVRow(recording: RecordingEntity, formatter: ISO8601DateFormatter) -> [String] {
        var row = emptyCSVRow()
        row[CSVColumn.recordType.rawValue] = "recording"
        row[CSVColumn.id.rawValue] = recording.id.uuidString
        row[CSVColumn.timestamp.rawValue] = formatter.string(from: recording.timestamp)
        row[CSVColumn.createdAt.rawValue] = formatter.string(from: recording.createdAt)
        row[CSVColumn.modifiedAt.rawValue] = recording.modifiedAt.map(formatter.string(from:)) ?? ""
        row[CSVColumn.recordingType.rawValue] = recording.type.rawValue
        row[CSVColumn.recordingPurpose.rawValue] = recording.purpose.rawValue
        row[CSVColumn.recordingDurationSeconds.rawValue] = String(recording.duration)
        row[CSVColumn.recordingFilePath.rawValue] = recording.filePath
        row[CSVColumn.recordingThumbnailPath.rawValue] = recording.thumbnailPath ?? ""
        row[CSVColumn.recordingTitle.rawValue] = recording.title ?? ""
        row[CSVColumn.recordingNotes.rawValue] = recording.notes ?? ""
        row[CSVColumn.recordingPlayCount.rawValue] = String(recording.playCount)
        row[CSVColumn.recordingLastPlayedAt.rawValue] = recording.lastPlayedAt.map(formatter.string(from:)) ?? ""
        return row
    }

    private static func messageCSVRow(message: MotivationalMessageEntity, formatter: ISO8601DateFormatter) -> [String] {
        var row = emptyCSVRow()
        row[CSVColumn.recordType.rawValue] = "message"
        row[CSVColumn.id.rawValue] = message.id.uuidString
        row[CSVColumn.createdAt.rawValue] = formatter.string(from: message.createdAt)
        row[CSVColumn.modifiedAt.rawValue] = message.modifiedAt.map(formatter.string(from:)) ?? ""
        row[CSVColumn.messageContent.rawValue] = message.content
        row[CSVColumn.messageCategory.rawValue] = message.category.rawValue
        row[CSVColumn.messageIsCustom.rawValue] = String(message.isCustom)
        row[CSVColumn.messagePriority.rawValue] = String(message.priority)
        row[CSVColumn.messageIsActive.rawValue] = String(message.isActive)
        row[CSVColumn.messageTimesShown.rawValue] = String(message.timesShown)
        row[CSVColumn.messageLastShownAt.rawValue] = message.lastShownAt.map(formatter.string(from:)) ?? ""
        return row
    }

    private static func emptyCSVRow() -> [String] {
        Array(repeating: "", count: csvHeader.count)
    }

    private static func csvEscape(_ rawValue: String) -> String {
        guard rawValue.contains(where: { $0 == "," || $0 == "\"" || $0 == "\n" || $0 == "\r" }) else {
            return rawValue
        }

        let escaped = rawValue.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
}
