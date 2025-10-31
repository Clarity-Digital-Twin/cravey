# Cravey Data Model Specification

**Version:** 1.0
**Last Updated:** 2025-10-29
**Status:** ✅ Complete - SwiftData Models Defined

---

## 🎯 Purpose

This document defines the **exact SwiftData model schemas** for all persistent data in Cravey. These are copy-paste ready Swift code examples that implement the requirements from:
- MVP_PRODUCT_SPEC.md (features & requirements)
- CLINICAL_CANNABIS_SPEC.md (tracking requirements)
- UX_FLOW_SPEC.md (all fields needed for 19 screens)

**Tech Stack:**
- SwiftData (iOS 18+)
- Swift 6.2 with strict concurrency
- Local-only storage (CloudKit `.none`)

---

## 📐 Design Principles (2025 Best Practices)

### 1. **Simple Types Over Complex Encodings**
- Use `String`, `Double`, `Int`, `Date`, `UUID`, `[String]`
- Avoid custom `Codable` structs (SwiftData migration pain)
- Store raw data, handle display logic in ViewModels

### 2. **Arrays for Multi-Select, Strings for Single-Select**
- Multi-select triggers → `[String]` (native SwiftData support)
- Single-select location → `String?` (optional)

### 3. **Implied Units (Not Stored)**
- `amount: Double` without separate `amountUnit` field
- Unit derived from context (method, ROA type)
- Display logic in ViewModel, not Model

### 4. **Timestamps for Sync & Audit**
- `createdAt: Date` - When record was created
- `modifiedAt: Date?` - When record was last edited
- Enables future features (undo, sync, version history)

### 5. **Relationships with Clear Delete Rules**
- Optional relationships (`?`) for flexibility
- `.nullify` delete rules (preserve data integrity)
- Document cascading behavior explicitly

---

## 🗄️ Data Models

### 1. UsageModel

**Purpose:** Tracks individual cannabis usage sessions.

**File Location:** `Cravey/Data/Models/UsageModel.swift`

**Source Requirements:**
- MVP_PRODUCT_SPEC.md: Feature #2 (Cannabis Usage Logging)
- CLINICAL_CANNABIS_SPEC.md: ROA tracking validation
- UX_FLOW_SPEC.md: Flow 4 (Log Usage screen)

**Model Definition:**

```swift
import SwiftData
import Foundation

@Model
final class UsageModel {
    // Unique identifier
    @Attribute(.unique) var id: UUID

    // Core fields (REQUIRED in UI)
    var timestamp: Date              // When they used (auto "now", editable)
    var method: String              // ROA: "Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible"
    var amount: Double              // Numeric quantity (context-aware per method)

    // Optional fields (below divider in UI)
    var triggers: [String]          // HAALT multi-select: ["Anxious", "Bored", "Habit"]
    var location: String?           // GPS coordinate OR preset ("Home", "Work", "Car")
    var notes: String?              // Freeform text (500 char limit enforced in UI)

    // Metadata (automatic)
    var createdAt: Date             // Record creation timestamp
    var modifiedAt: Date?           // Last edit timestamp

    // Initializer
    init(
        id: UUID = UUID(),
        timestamp: Date,
        method: String,
        amount: Double,
        triggers: [String] = [],
        location: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.method = method
        self.amount = amount
        self.triggers = triggers
        self.location = location
        self.notes = notes
        self.createdAt = Date()
        self.modifiedAt = nil
    }
}
```

**Field Details:**

| Field | Type | Required | Validation | Notes |
|-------|------|----------|------------|-------|
| `id` | `UUID` | Yes | Unique | Auto-generated |
| `timestamp` | `Date` | Yes | Any past date | Warning if >7 days old (UI only) |
| `method` | `String` | Yes | One of 6 ROAs | "Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible" |
| `amount` | `Double` | Yes | >0 | Range validated by method (see Amount Ranges) |
| `triggers` | `[String]` | No | HAALT set | Empty array if none selected |
| `location` | `String?` | No | GPS or preset | Nil if not provided |
| `notes` | `String?` | No | ≤500 chars | Enforced in UI, not database |
| `createdAt` | `Date` | Yes | Auto | Set on init |
| `modifiedAt` | `Date?` | No | Auto | Set when edited |

**Amount Ranges (by Method):**

```swift
// Display logic lives in ViewModel, not Model
// Model stores raw Double, UI validates ranges

enum ROAAmountRange {
    case bowls          // 0.5 → 5.0 (increment 0.5, 10 options)
    case joints         // 0.5 → 5.0 (increment 0.5, 10 options)
    case blunts         // 0.5 → 5.0 (increment 0.5, 10 options)
    case vape           // 1 → 10 pulls (increment 1, 10 options)
    case dab            // 1 → 5 dabs (increment 1, 5 options)
    case edible         // 5mg → 100mg (increment 5mg, 20 options)

    static func range(for method: String) -> [Double] {
        switch method {
        case "Bowls", "Joints", "Blunts":
            return stride(from: 0.5, through: 5.0, by: 0.5).map { $0 }
        case "Vape":
            return Array(1...10).map { Double($0) }
        case "Dab":
            return Array(1...5).map { Double($0) }
        case "Edible":
            return stride(from: 5.0, through: 100.0, by: 5.0).map { $0 }
        default:
            return []
        }
    }

    static func displayAmount(method: String, amount: Double) -> String {
        switch method {
        case "Bowls": return "\(amount) bowls"
        case "Joints": return "\(amount) joints"
        case "Blunts": return "\(amount) blunts"
        case "Vape": return "\(Int(amount)) pulls"
        case "Dab": return "\(Int(amount)) dabs"
        case "Edible": return "\(Int(amount))mg"
        default: return "\(amount)"
        }
    }
}
```

**Trigger Options (HAALT Model):**

```swift
// Used for both UsageModel and CravingModel

struct TriggerOptions {
    static let primary = [
        "Hungry",
        "Angry",
        "Anxious",
        "Lonely",
        "Tired",
        "Sad"
    ]

    static let secondary = [
        "Bored",
        "Social",
        "Habit",
        "Paraphernalia"
    ]

    static let all = primary + secondary
}
```

**Location Options:**

```swift
struct LocationOptions {
    static let presets = [
        "Home",
        "Work",
        "Social",
        "Outside",
        "Car"
    ]

    // GPS stored as "lat,long" string
    static func formatGPS(latitude: Double, longitude: Double) -> String {
        return "\(latitude),\(longitude)"
    }

    static func isGPS(_ location: String) -> Bool {
        return location.contains(",")
    }

    static func displayLocation(_ location: String?) -> String {
        guard let loc = location else { return "Unknown" }
        return isGPS(loc) ? "Current Location" : loc
    }
}
```

**Query Examples:**

```swift
// Fetch all usage in last 7 days
let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
let descriptor = FetchDescriptor<UsageModel>(
    predicate: #Predicate { $0.timestamp >= sevenDaysAgo },
    sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
)
let recentUsage = try modelContext.fetch(descriptor)

// Find all vape usage
let vapeDescriptor = FetchDescriptor<UsageModel>(
    predicate: #Predicate { $0.method == "Vape" }
)

// Find all usage triggered by anxiety
let anxietyDescriptor = FetchDescriptor<UsageModel>(
    predicate: #Predicate { $0.triggers.contains("Anxious") }
)
```

---

### 2. CravingModel

**Purpose:** Tracks individual craving episodes (independent of usage).

**File Location:** `Cravey/Data/Models/CravingModel.swift`

**Source Requirements:**
- MVP_PRODUCT_SPEC.md: Feature #1 (Craving Logging)
- UX_FLOW_SPEC.md: Flow 3 (Log Craving screen)

**Model Definition:**

```swift
import SwiftData
import Foundation

@Model
final class CravingModel {
    // Unique identifier
    @Attribute(.unique) var id: UUID

    // Core fields (REQUIRED in UI)
    var timestamp: Date              // When craving occurred (auto "now", editable)
    var intensity: Int               // Scale 1-10

    // Optional fields (below divider in UI)
    var triggers: [String]           // HAALT multi-select (same as UsageModel)
    var location: String?            // GPS coordinate OR preset (same as UsageModel)
    var notes: String?               // Freeform text (500 char limit)

    // Metadata
    var createdAt: Date
    var modifiedAt: Date?

    // Relationship (optional - craving can link to a motivational recording)
    @Relationship(deleteRule: .nullify, inverse: \RecordingModel.linkedCravings)
    var recording: RecordingModel?

    // Initializer
    init(
        id: UUID = UUID(),
        timestamp: Date,
        intensity: Int,
        triggers: [String] = [],
        location: String? = nil,
        notes: String? = nil,
        recording: RecordingModel? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.intensity = intensity
        self.triggers = triggers
        self.location = location
        self.notes = notes
        self.createdAt = Date()
        self.modifiedAt = nil
        self.recording = recording
    }
}
```

**Field Details:**

| Field | Type | Required | Validation | Notes |
|-------|------|----------|------------|-------|
| `id` | `UUID` | Yes | Unique | Auto-generated |
| `timestamp` | `Date` | Yes | Any past date | Warning if >7 days old (UI only) |
| `intensity` | `Int` | Yes | 1-10 | Slider in UI |
| `triggers` | `[String]` | No | HAALT set | Same options as UsageModel |
| `location` | `String?` | No | GPS or preset | Same format as UsageModel |
| `notes` | `String?` | No | ≤500 chars | Enforced in UI |
| `createdAt` | `Date` | Yes | Auto | Set on init |
| `modifiedAt` | `Date?` | No | Auto | Set when edited |
| `recording` | `RecordingModel?` | No | Nullable | Optional link to motivational video |

**Intensity Scale (Display Logic):**

```swift
enum CravingIntensity {
    case mild           // 1-3: Manageable, background
    case moderate       // 4-6: Uncomfortable, requires coping
    case strong         // 7-9: Urgent, high risk
    case overwhelming   // 10: Crisis

    static func category(for intensity: Int) -> CravingIntensity {
        switch intensity {
        case 1...3: return .mild
        case 4...6: return .moderate
        case 7...9: return .strong
        case 10: return .overwhelming
        default: return .mild
        }
    }

    static func description(for intensity: Int) -> String {
        switch category(for: intensity) {
        case .mild: return "Mild (manageable)"
        case .moderate: return "Moderate (uncomfortable)"
        case .strong: return "Strong (urgent)"
        case .overwhelming: return "Overwhelming (crisis)"
        }
    }

    static func color(for intensity: Int) -> String {
        // Return SwiftUI color name
        switch category(for: intensity) {
        case .mild: return "green"
        case .moderate: return "yellow"
        case .strong: return "orange"
        case .overwhelming: return "red"
        }
    }
}
```

**Key Difference from UsageModel:**
- NO `method` or `amount` fields (cravings are about urge, not consumption)
- Includes `intensity` scale (1-10 slider)
- Optional link to `RecordingModel` (many-to-one relationship)

**Query Examples:**

```swift
// Average craving intensity for last 30 days
let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
let descriptor = FetchDescriptor<CravingModel>(
    predicate: #Predicate { $0.timestamp >= thirtyDaysAgo }
)
let cravings = try modelContext.fetch(descriptor)
let avgIntensity = cravings.map(\.intensity).reduce(0, +) / cravings.count

// Find high-intensity cravings (7-10)
let highIntensityDescriptor = FetchDescriptor<CravingModel>(
    predicate: #Predicate { $0.intensity >= 7 }
)
```

---

### 3. RecordingModel

**Purpose:** Stores metadata for video/audio motivational recordings (files stored separately).

**File Location:** `Cravey/Data/Models/RecordingModel.swift`

**Source Requirements:**
- MVP_PRODUCT_SPEC.md: Feature #3 (Pre-Recorded Motivational Content)
- UX_FLOW_SPEC.md: Flow 5 (Recordings Tab - 10 screens)

**Model Definition:**

```swift
import SwiftData
import Foundation

@Model
final class RecordingModel {
    // Unique identifier
    @Attribute(.unique) var id: UUID

    // Core metadata
    var timestamp: Date              // When recording was created
    var type: String                 // "video" or "audio"
    var purpose: String              // "motivational", "milestone", "reflection", "craving"
    var duration: TimeInterval       // Length in seconds (from AVAsset)

    // File paths (relative to Documents directory)
    var filePath: String             // e.g., "Recordings/video_UUID.mov"
    var thumbnailPath: String?       // e.g., "Recordings/Thumbnails/video_UUID_thumb.jpg"

    // User metadata
    var title: String?               // User-provided title
    var notes: String?               // User-provided notes

    // Usage tracking
    var playCount: Int               // How many times played
    var lastPlayedAt: Date?          // When last played

    // Metadata
    var createdAt: Date
    var modifiedAt: Date?

    // Relationship (one-to-many: one recording can be linked from many cravings)
    @Relationship(deleteRule: .nullify)
    var linkedCravings: [CravingModel]?

    // Initializer
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        type: String,
        purpose: String,
        duration: TimeInterval,
        filePath: String,
        thumbnailPath: String? = nil,
        title: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.purpose = purpose
        self.duration = duration
        self.filePath = filePath
        self.thumbnailPath = thumbnailPath
        self.title = title
        self.notes = notes
        self.playCount = 0
        self.lastPlayedAt = nil
        self.createdAt = Date()
        self.modifiedAt = nil
        self.linkedCravings = []
    }
}
```

**Field Details:**

| Field | Type | Required | Validation | Notes |
|-------|------|----------|------------|-------|
| `id` | `UUID` | Yes | Unique | Auto-generated |
| `timestamp` | `Date` | Yes | Auto | When recorded |
| `type` | `String` | Yes | "video"/"audio" | Enum-like validation |
| `purpose` | `String` | Yes | Category | "motivational", "milestone", "reflection", "craving" |
| `duration` | `TimeInterval` | Yes | ≤120 sec | Max 2 minutes (enforced in recording UI) |
| `filePath` | `String` | Yes | Valid path | Relative to Documents/Recordings/ |
| `thumbnailPath` | `String?` | No | Valid path | Video only (nil for audio) |
| `title` | `String?` | No | — | User-provided |
| `notes` | `String?` | No | — | User-provided |
| `playCount` | `Int` | Yes | ≥0 | Incremented on playback |
| `lastPlayedAt` | `Date?` | No | Auto | Updated on playback |
| `createdAt` | `Date` | Yes | Auto | Set on init |
| `modifiedAt` | `Date?` | No | Auto | Set when edited |
| `linkedCravings` | `[CravingModel]?` | No | Nullable | Inverse relationship |

**File Storage Structure:**

```
~/Library/Application Support/[BundleID]/
└── Recordings/
    ├── video_[UUID].mov          // Video files
    ├── audio_[UUID].m4a          // Audio files
    └── Thumbnails/
        └── video_[UUID]_thumb.jpg  // Video thumbnails
```

**Recording Type & Purpose Options:**

```swift
enum RecordingType: String {
    case video = "video"
    case audio = "audio"
}

enum RecordingPurpose: String {
    case motivational = "motivational"   // "Why I'm taking a break"
    case milestone = "milestone"         // "30 days sober"
    case reflection = "reflection"       // "How I'm feeling today"
    case craving = "craving"            // Recorded during a craving moment
}
```

**File Management Helper:**

```swift
// This logic lives in FileStorageManager (not in Model)

struct FileStorageManager {
    static let shared = FileStorageManager()

    private let recordingsDirectory = "Recordings"
    private let thumbnailsDirectory = "Recordings/Thumbnails"

    func generateFilePath(id: UUID, type: RecordingType) -> String {
        let ext = type == .video ? "mov" : "m4a"
        return "\(recordingsDirectory)/\(type.rawValue)_\(id.uuidString).\(ext)"
    }

    func generateThumbnailPath(id: UUID) -> String {
        return "\(thumbnailsDirectory)/video_\(id.uuidString)_thumb.jpg"
    }

    func deleteRecording(filePath: String, thumbnailPath: String?) throws {
        let fileURL = documentsURL.appendingPathComponent(filePath)
        try FileManager.default.removeItem(at: fileURL)

        if let thumbPath = thumbnailPath {
            let thumbURL = documentsURL.appendingPathComponent(thumbPath)
            try? FileManager.default.removeItem(at: thumbURL)
        }
    }

    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
```

**Delete Behavior (from Appendix B):**

1. **Delete Recording (from Recordings tab):**
   - Delete file from disk (`.mov`/`.m4a` + thumbnail)
   - Delete RecordingModel from database
   - Linked CravingModels remain intact (relationship set to nil via `.nullify`)

2. **Delete Craving (that links to Recording):**
   - Delete CravingModel from database
   - Recording remains intact (not deleted)
   - Recording still accessible in Recordings tab

3. **Delete All Data:**
   - Delete ALL RecordingModel entries
   - Delete ALL files from Recordings directory
   - Cascading delete to all CravingModel entries

**Query Examples:**

```swift
// Fetch all video recordings sorted by most recent
let videoDescriptor = FetchDescriptor<RecordingModel>(
    predicate: #Predicate { $0.type == "video" },
    sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
)

// Find most played recordings
let mostPlayedDescriptor = FetchDescriptor<RecordingModel>(
    sortBy: [SortDescriptor(\.playCount, order: .reverse)]
)

// Find recordings by purpose
let motivationalDescriptor = FetchDescriptor<RecordingModel>(
    predicate: #Predicate { $0.purpose == "motivational" }
)
```

---

### 4. MotivationalMessageModel

**Purpose:** Stores pre-populated and user-created motivational messages.

**File Location:** `Cravey/Data/Models/MotivationalMessageModel.swift`

**Source Requirements:**
- MVP_PRODUCT_SPEC.md: Feature #3 (Pre-Recorded Motivational Content - text messages)
- UX_FLOW_SPEC.md: Flow 2 (Home Tab - motivational messages)

**Model Definition:**

```swift
import SwiftData
import Foundation

@Model
final class MotivationalMessageModel {
    // Unique identifier
    @Attribute(.unique) var id: UUID

    // Content
    var content: String              // The motivational message text
    var category: String             // "urge", "anxiety", "boredom", "social", "celebration"

    // Metadata
    var isCustom: Bool               // User-created (true) vs default (false)
    var priority: Int                // Display order (lower = higher priority)
    var timesShown: Int              // How many times displayed
    var lastShownAt: Date?           // When last shown
    var isActive: Bool               // User can deactivate messages

    // Timestamps
    var createdAt: Date
    var modifiedAt: Date?

    // Initializer
    init(
        id: UUID = UUID(),
        content: String,
        category: String,
        isCustom: Bool = false,
        priority: Int = 0,
        isActive: Bool = true
    ) {
        self.id = id
        self.content = content
        self.category = category
        self.isCustom = isCustom
        self.priority = priority
        self.timesShown = 0
        self.lastShownAt = nil
        self.isActive = isActive
        self.createdAt = Date()
        self.modifiedAt = nil
    }
}
```

**Field Details:**

| Field | Type | Required | Validation | Notes |
|-------|------|----------|------------|-------|
| `id` | `UUID` | Yes | Unique | Auto-generated |
| `content` | `String` | Yes | Non-empty | Message text |
| `category` | `String` | Yes | See categories | Message context |
| `isCustom` | `Bool` | Yes | — | false = default, true = user-created |
| `priority` | `Int` | Yes | ≥0 | Lower number = higher priority |
| `timesShown` | `Int` | Yes | ≥0 | Incremented when displayed |
| `lastShownAt` | `Date?` | No | Auto | Updated when shown |
| `isActive` | `Bool` | Yes | — | User can hide messages |
| `createdAt` | `Date` | Yes | Auto | Set on init |
| `modifiedAt` | `Date?` | No | Auto | Set when edited |

**Category Options:**

```swift
enum MessageCategory: String, CaseIterable {
    case urge = "urge"               // "You've resisted before. You can do it again."
    case anxiety = "anxiety"         // "This feeling is temporary. Breathe."
    case boredom = "boredom"         // "Boredom isn't an emergency. Find something else."
    case social = "social"           // "You can have fun without using."
    case celebration = "celebration" // "You're making progress. Keep going."
}
```

**Default Messages (Seeded on First Launch):**

```swift
// This logic lives in a seed data function (not in Model)

extension MotivationalMessageModel {
    static func defaultMessages() -> [MotivationalMessageModel] {
        [
            // Urge category
            MotivationalMessageModel(
                content: "You've resisted before. You can do it again. 💪",
                category: "urge",
                priority: 1
            ),
            MotivationalMessageModel(
                content: "This craving will pass. They always do.",
                category: "urge",
                priority: 2
            ),
            MotivationalMessageModel(
                content: "Every moment of resistance is progress.",
                category: "urge",
                priority: 3
            ),

            // Anxiety category
            MotivationalMessageModel(
                content: "This feeling is temporary. Breathe through it.",
                category: "anxiety",
                priority: 1
            ),
            MotivationalMessageModel(
                content: "Anxiety is uncomfortable, but you're safe. 🫂",
                category: "anxiety",
                priority: 2
            ),

            // Boredom category
            MotivationalMessageModel(
                content: "Boredom isn't an emergency. Find something else.",
                category: "boredom",
                priority: 1
            ),
            MotivationalMessageModel(
                content: "This is just boredom, not a need. You've got this.",
                category: "boredom",
                priority: 2
            ),

            // Social category
            MotivationalMessageModel(
                content: "You can have fun without using. You've done it before.",
                category: "social",
                priority: 1
            ),
            MotivationalMessageModel(
                content: "Real friends support your choices. 🤝",
                category: "social",
                priority: 2
            ),

            // Celebration category
            MotivationalMessageModel(
                content: "You're making progress. Every day counts. 🎉",
                category: "celebration",
                priority: 1
            ),
            MotivationalMessageModel(
                content: "Look how far you've come. Keep going.",
                category: "celebration",
                priority: 2
            )
        ]
    }
}
```

**Message Selection Logic (in ViewModel):**

```swift
// Smart message selection based on context

func selectMessage(for triggers: [String]?, context: String = "urge") -> MotivationalMessageModel? {
    // 1. Filter active messages by category
    let category = determineCategory(triggers: triggers, context: context)
    let descriptor = FetchDescriptor<MotivationalMessageModel>(
        predicate: #Predicate {
            $0.isActive == true && $0.category == category
        },
        sortBy: [SortDescriptor(\.priority, order: .forward)]
    )

    let messages = try? modelContext.fetch(descriptor)

    // 2. Prioritize least-shown messages (round-robin)
    return messages?.min(by: { $0.timesShown < $1.timesShown })
}

func determineCategory(triggers: [String]?, context: String) -> String {
    guard let triggers = triggers, !triggers.isEmpty else {
        return context  // Default to provided context
    }

    // Map trigger to message category
    if triggers.contains("Anxious") { return "anxiety" }
    if triggers.contains("Bored") { return "boredom" }
    if triggers.contains("Social") { return "social" }
    return "urge"  // Fallback
}
```

**Query Examples:**

```swift
// Fetch active messages for a category
let urgeDescriptor = FetchDescriptor<MotivationalMessageModel>(
    predicate: #Predicate {
        $0.isActive == true && $0.category == "urge"
    },
    sortBy: [SortDescriptor(\.priority)]
)

// Find user-created messages
let customDescriptor = FetchDescriptor<MotivationalMessageModel>(
    predicate: #Predicate { $0.isCustom == true }
)

// Find least-shown messages (for rotation)
let leastShownDescriptor = FetchDescriptor<MotivationalMessageModel>(
    predicate: #Predicate { $0.isActive == true },
    sortBy: [SortDescriptor(\.timesShown, order: .forward)]
)
```

---

## 🔗 Relationships Between Models

### Relationship Diagram

```
CravingModel ←──────┐
    ↓               │ (many-to-one, optional)
    │               │
    └→ RecordingModel
            ↑
            │ (one-to-many)
            │
    linkedCravings: [CravingModel]?

UsageModel (INDEPENDENT - no relationship to Craving or Recording)

MotivationalMessageModel (INDEPENDENT - standalone content)
```

### Relationship Rules

1. **CravingModel ↔ RecordingModel**
   - Type: Many-to-one (many cravings can reference one recording)
   - Optional: Yes (craving can exist without recording link)
   - Delete rule: `.nullify` (preserve data integrity)
   - Inverse: `RecordingModel.linkedCravings`

2. **UsageModel (Independent)**
   - No relationship to CravingModel (per clinical validation)
   - No relationship to RecordingModel
   - Standalone tracking

3. **MotivationalMessageModel (Independent)**
   - No relationships to other models
   - Standalone content library

### SwiftData Relationship Implementation

```swift
// In CravingModel:
@Relationship(deleteRule: .nullify, inverse: \RecordingModel.linkedCravings)
var recording: RecordingModel?

// In RecordingModel:
@Relationship(deleteRule: .nullify)
var linkedCravings: [CravingModel]?
```

**What `.nullify` Means:**
- When you delete a `RecordingModel`, all `CravingModel.recording` references become `nil`
- When you delete a `CravingModel`, the `RecordingModel` is not affected
- No cascading deletes (preserves data)

---

## 🗄️ ModelContainer Setup

**File Location:** `Cravey/Data/Storage/ModelContainerSetup.swift`

**Configuration:**

```swift
import SwiftData
import Foundation

@MainActor
func createModelContainer() throws -> ModelContainer {
    let schema = Schema([
        UsageModel.self,
        CravingModel.self,
        RecordingModel.self,
        MotivationalMessageModel.self
    ])

    let configuration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false,      // Persist to disk
        allowsSave: true,                 // Enable saves
        cloudKitDatabase: .none           // ⚠️ CRITICAL: No iCloud sync
    )

    let container = try ModelContainer(
        for: schema,
        configurations: [configuration]
    )

    // Seed default motivational messages on first launch
    seedDefaultMessagesIfNeeded(container: container)

    return container
}

// Seed default messages
private func seedDefaultMessagesIfNeeded(container: ModelContainer) {
    let context = ModelContext(container)

    // Check if messages already exist
    let descriptor = FetchDescriptor<MotivationalMessageModel>(
        predicate: #Predicate { $0.isCustom == false }
    )

    let existingMessages = (try? context.fetch(descriptor)) ?? []

    guard existingMessages.isEmpty else {
        print("✅ Default messages already seeded")
        return
    }

    // Insert default messages
    let defaultMessages = MotivationalMessageModel.defaultMessages()
    for message in defaultMessages {
        context.insert(message)
    }

    do {
        try context.save()
        print("✅ Seeded \(defaultMessages.count) default messages")
    } catch {
        print("❌ Failed to seed messages: \(error)")
    }
}
```

**Usage in App Entry Point:**

```swift
// Cravey/App/CraveyApp.swift

import SwiftUI
import SwiftData

@main
struct CraveyApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            self.modelContainer = try createModelContainer()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
```

---

## 🚀 Performance Considerations

### Query Optimization

**1. Use Predicates for Filtering (Not Array Filtering)**

❌ **Bad (Loads everything into memory):**
```swift
let allUsage = try modelContext.fetch(FetchDescriptor<UsageModel>())
let filteredUsage = allUsage.filter { $0.method == "Vape" }
```

✅ **Good (Filters at database level):**
```swift
let descriptor = FetchDescriptor<UsageModel>(
    predicate: #Predicate { $0.method == "Vape" }
)
let vapeUsage = try modelContext.fetch(descriptor)
```

**2. Limit Results for Charts (Don't Fetch All Data)**

```swift
// Dashboard shows last 90 days - don't fetch older data
let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: Date())!
let descriptor = FetchDescriptor<UsageModel>(
    predicate: #Predicate { $0.timestamp >= ninetyDaysAgo },
    sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
)
```

**3. Use `fetchLimit` for Lists**

```swift
// Recordings library - paginate results
var descriptor = FetchDescriptor<RecordingModel>(
    sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
)
descriptor.fetchLimit = 20  // Load 20 at a time
```

### Performance Targets (from MVP spec)

- **Craving log:** <5 seconds (UI response, not query time)
- **Usage log:** <10 seconds (UI response, not query time)
- **Chart rendering:** <2 seconds for 90 days of data
- **Dashboard load:** <3 seconds for all metrics

### Indexing Strategy

SwiftData auto-indexes:
- `@Attribute(.unique)` fields (like `id`)
- Relationship foreign keys

Manual indexes NOT needed for MVP (premature optimization).

---

## 🧪 Testing Data Models

### Unit Test Example

```swift
import Testing
import SwiftData
@testable import Cravey

@Test("UsageModel stores and retrieves correctly")
func testUsageModelPersistence() async throws {
    // 1. Create in-memory container
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
        for: UsageModel.self,
        configurations: config
    )
    let context = ModelContext(container)

    // 2. Create test data
    let usage = UsageModel(
        timestamp: Date(),
        method: "Vape",
        amount: 5.0,
        triggers: ["Anxious", "Bored"],
        location: "Home",
        notes: "Test note"
    )

    // 3. Save
    context.insert(usage)
    try context.save()

    // 4. Fetch and verify
    let descriptor = FetchDescriptor<UsageModel>()
    let results = try context.fetch(descriptor)

    #expect(results.count == 1)
    #expect(results[0].method == "Vape")
    #expect(results[0].amount == 5.0)
    #expect(results[0].triggers.contains("Anxious"))
}
```

---

## 📦 Migration Strategy

### Lightweight Migrations (SwiftData Automatic)

SwiftData handles these automatically:
- Adding new optional fields
- Renaming fields (with `@Attribute(.originalName:)`)
- Adding new models

**Example: Adding a field post-MVP**

```swift
@Model
final class UsageModel {
    // ... existing fields ...

    // Add new optional field (no migration code needed)
    var mood: String?  // NEW in v1.1
}
```

### Heavy Migrations (Manual Code Required)

SwiftData does NOT auto-migrate:
- Changing field types (`String` → `Int`)
- Removing required fields
- Changing relationships

**If you need to change field types, use this pattern:**

```swift
// 1. Add new field with new name
var amountV2: Int?  // New version

// 2. Migrate in background
func migrateAmountField() {
    if let oldAmount = amount {  // Old Double field
        self.amountV2 = Int(oldAmount)  // Convert to Int
    }
}

// 3. Deprecate old field in next version
// @available(*, deprecated, message: "Use amountV2")
// var amount: Double
```

**For MVP: Avoid breaking changes.** Design models to be additive-only.

---

## ✅ Validation Checklist

**Before implementation, verify:**

- [ ] All 19 UX screens have required fields mapped
- [ ] ROA amount ranges match CLINICAL_CANNABIS_SPEC.md
- [ ] HAALT triggers match MVP_PRODUCT_SPEC.md Appendix A
- [ ] Location options match MVP_PRODUCT_SPEC.md Appendix A
- [ ] Delete rules match MVP_PRODUCT_SPEC.md Appendix B
- [ ] CloudKit configuration is `.none` (privacy requirement)
- [ ] File paths are relative (not absolute)
- [ ] Relationships use `.nullify` (preserve data integrity)
- [ ] All timestamps use `Date` (not `TimeInterval` or `String`)
- [ ] Array fields use `[String]` (not comma-separated strings)

---

## 🚀 Next Steps

1. **Implement models** in `Cravey/Data/Models/` (copy-paste this spec)
2. **Test models** in unit tests (`CraveyTests/Data/Models/`)
3. **Create repositories** (`CravingRepository`, `UsageRepository`, etc.)
4. **Create mappers** (Entity ↔ Model conversion)
5. **Update DependencyContainer** with real implementations
6. **Build ViewModels** that use these models
7. **Build Views** (19 screens from UX_FLOW_SPEC.md)

**Next Spec to Create:** `TECHNICAL_IMPLEMENTATION.md` (map features to code)

---

**Status:** ✅ DATA_MODEL_SPEC.md Complete - Ready for Implementation 🔥
