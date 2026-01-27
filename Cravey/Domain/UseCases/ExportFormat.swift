/// Supported formats for exporting user data.
enum ExportFormat: String, CaseIterable, Codable, Sendable {
    case csv
    case json
}
