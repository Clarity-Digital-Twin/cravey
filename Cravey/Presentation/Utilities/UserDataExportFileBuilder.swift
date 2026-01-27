import Foundation

enum UserDataExportFileBuilder {
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
        let header = [
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

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var rows: [[String]] = [header]

        for craving in export.cravings {
            rows.append([
                "craving",
                craving.id.uuidString,
                formatter.string(from: craving.timestamp),
                formatter.string(from: craving.createdAt),
                craving.modifiedAt.map(formatter.string(from:)) ?? "",
                String(craving.intensity),
                craving.triggers.joined(separator: "; "),
                craving.location ?? "",
                craving.notes ?? "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
            ])
        }

        for usage in export.usages {
            rows.append([
                "usage",
                usage.id.uuidString,
                formatter.string(from: usage.timestamp),
                formatter.string(from: usage.createdAt),
                usage.modifiedAt.map(formatter.string(from:)) ?? "",
                "",
                "",
                "",
                "",
                usage.method,
                String(usage.amount),
                usage.triggers.joined(separator: "; "),
                usage.location ?? "",
                usage.notes ?? "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
            ])
        }

        for recording in export.recordings {
            rows.append([
                "recording",
                recording.id.uuidString,
                formatter.string(from: recording.timestamp),
                formatter.string(from: recording.createdAt),
                recording.modifiedAt.map(formatter.string(from:)) ?? "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                recording.type.rawValue,
                recording.purpose.rawValue,
                String(recording.duration),
                recording.filePath,
                recording.thumbnailPath ?? "",
                recording.title ?? "",
                recording.notes ?? "",
                String(recording.playCount),
                recording.lastPlayedAt.map(formatter.string(from:)) ?? "",
                "",
                "",
                "",
                "",
                "",
                "",
            ])
        }

        for message in export.messages {
            rows.append([
                "message",
                message.id.uuidString,
                "",
                formatter.string(from: message.createdAt),
                message.modifiedAt.map(formatter.string(from:)) ?? "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                message.content,
                message.category.rawValue,
                String(message.isCustom),
                String(message.priority),
                String(message.isActive),
                String(message.timesShown),
                message.lastShownAt.map(formatter.string(from:)) ?? "",
            ])
        }

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

    private static func csvEscape(_ rawValue: String) -> String {
        guard rawValue.contains(where: { $0 == "," || $0 == "\"" || $0 == "\n" || $0 == "\r" }) else {
            return rawValue
        }

        let escaped = rawValue.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
}
