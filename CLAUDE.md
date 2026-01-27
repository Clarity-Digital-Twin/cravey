# Cravey App - AI Agent Development Context

**Last Updated:** 2026-01-27
**Current Status:** See `docs/PROJECT_STATUS.md` for authoritative status
**Parity:** `AGENTS.md` and `CLAUDE.md` are redundant copies and must be kept in sync.

## Project Overview
Cravey is a **cannabis cessation support iOS app** (iOS 18+) built with Clean Architecture + MVVM using modern SwiftUI and SwiftData. The app helps users track cravings, record motivational videos/audio, and access supportive content during vulnerable moments.

## Core Principles
1. **Privacy-First**: All data is local-only. No cloud sync, no analytics, no tracking. SwiftData with `.none` CloudKit configuration.
2. **Clean Architecture**: Pure Domain layer, isolated Data layer, framework-independent business logic following Robert C. Martin principles.
3. **iOS-Only (Initial Release)**: Focused on iOS 18+. macOS support planned for future.
4. **Motivational Interviewing**: Self-compassion, progress tracking, non-judgmental language.
5. **Simplicity**: Clear UI for users in crisis moments.

---

## Tech Stack (Latest Stable - Oct 2025)

### Core
- **Swift 6.2** with strict concurrency
- **SwiftUI** for declarative UI (iOS 18+)
- **SwiftData** for persistence (@Model macro)
- **AVFoundation** for audio/video recording (TODO)
- **XcodeGen 2.44.1** for project file generation

### Development Tools
- **Xcode 26.0.1** (Build 17A400)
- **xcbeautify 2.30.1** - Pretty xcodebuild output
- **swiftlint 0.61.0** - Code style linting
- **swiftformat 0.58.3** - Code formatting
- **gh 2.81.0** - GitHub CLI

---

## SwiftUI & SwiftData 2025 Best Practices

This project follows the latest Apple conventions for iOS 18+ development:

### SwiftUI Modern Patterns

**1. @Observable (NOT ObservableObject)**
```swift
// ✅ Modern (2025)
@Observable
@MainActor
final class CravingLogViewModel {
    var intensity: Double = 5.0
    var notes: String = ""
    // No @Published needed!
}

// ❌ Legacy (pre-iOS 17)
class CravingLogViewModel: ObservableObject {
    @Published var intensity: Double = 5.0
    @Published var notes: String = ""
}
```

**2. @State for Objects (NOT @StateObject)**
```swift
// ✅ Modern (2025)
struct ContentView: View {
    @State private var viewModel = CravingLogViewModel()
    // ...
}

// ❌ Legacy
struct ContentView: View {
    @StateObject private var viewModel = CravingLogViewModel()
}
```

**3. @Environment(Type.self) for DI (NOT @EnvironmentObject)**
```swift
// ✅ Modern (2025)
struct ContentView: View {
    @Environment(DependencyContainer.self) private var container
}

// ❌ Legacy
struct ContentView: View {
    @EnvironmentObject var container: DependencyContainer
}
```

**4. @Bindable for Two-Way Bindings**
```swift
// ✅ Use @Bindable when you need bindings to @Observable properties
struct EditView: View {
    @Bindable var book: Book  // NOT @ObservedObject!

    var body: some View {
        TextField("Title", text: $book.title)
    }
}
```

**5. Deferred Initialization for Expensive Objects**
```swift
// ✅ Prevents recreating ViewModels on every view update
struct HomeView: View {
    @State private var viewModel: CravingLogViewModel?

    var body: some View {
        if let viewModel {
            ContentView(viewModel: viewModel)
        } else {
            Color.clear.task {
                viewModel = makeViewModel()
            }
        }
    }
}
```

**6. @ObservationIgnored for Non-Tracked Properties**
```swift
// ✅ Exclude properties from observation tracking
@Observable
@MainActor
final class CravingLogViewModel {
    var intensity: Double = 5.0  // Tracked

    @ObservationIgnored
    private let dateFormatter = DateFormatter()  // NOT tracked
}
```

**When to use:** Formatters, caches, dependencies - anything that shouldn't trigger view updates.

**7. @Previewable for Preview-Specific State**
```swift
// ✅ Create state inside #Preview blocks
#Preview("Craving Log") {
    @Previewable @State var viewModel = CravingLogViewModel(
        logCravingUseCase: MockLogCravingUseCase()
    )
    CravingLogForm(viewModel: viewModel)
}
```

### SwiftData Modern Patterns

**1. @Model Macro (SwiftData persistence model)**
```swift
// ✅ Modern (2025)
@Model
final class CravingModel {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var intensity: Int
    // SwiftData model (reference type). Keep it out of Domain/Presentation.
}
```

**2. @Attribute for Constraints**
```swift
@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID  // Uniqueness constraint
    @Attribute(.unique) var email: String
    var name: String
}
```

**3. @Relationship with Delete Rules**
```swift
@Model
final class CravingModel {
    @Relationship(deleteRule: .nullify, inverse: \RecordingModel.linkedCravings)
    var recording: RecordingModel?
}

@Model
final class RecordingModel {
    @Relationship(deleteRule: .nullify)
    var linkedCravings: [CravingModel] = []
}
```

**4. @Transient for Non-Persisted Properties**
```swift
@Model
final class RecordingModel {
    var filePath: String

    @Transient
    var isDownloading: Bool = false  // Not saved to database
}
```

**5. ModelContext from Environment**
```swift
// ✅ For simple apps without Clean Architecture
@Environment(\.modelContext) private var modelContext

func saveData() {
    modelContext.insert(newModel)
    try? modelContext.save()
}

// ✅ For Clean Architecture (our approach)
@Environment(DependencyContainer.self) private var container
let repository = container.cravingRepository  // Keeps Domain pure
```

**6. @ModelActor for Concurrent SwiftData Access**
```swift
// ✅ Recommended for concurrent writes
@ModelActor
actor DataHandler {
    func saveCraving(_ craving: CravingModel) {
        modelContext.insert(craving)
        try? modelContext.save()
    }
}
```

**Why @ModelActor:** Thread-safe, no `nonisolated(unsafe)` needed. Our repositories use `nonisolated(unsafe)` for Clean Architecture compatibility.

**7. @Query for Direct SwiftData Access**
```swift
// ✅ SwiftUI-native (simple apps)
struct CravingListView: View {
    @Query(sort: \CravingModel.timestamp, order: .reverse)
    private var cravings: [CravingModel]
}
```

**Why We DON'T Use @Query:** Violates Clean Architecture (couples UI to Data layer). We use repositories + use cases for testability and framework independence.

### Why We Use DependencyContainer

While `@Environment(\.modelContext)` is valid for simple apps, we use **Clean Architecture**:
- ✅ Domain layer stays framework-independent (no SwiftData imports)
- ✅ Repository pattern enables mocking/testing
- ✅ Use cases are pure business logic
- ✅ Works seamlessly with @Observable (no migration needed)

**For detailed examples, see:** [PHASE_1 Best Practices](./docs/phases/PHASE_1.md#-swiftui--swiftdata-2025-best-practices)

---

## Architecture (Clean Architecture + MVVM)

### Layer Structure
```
Cravey/
├── App/                         # Composition Root (DI)
│   ├── CraveyApp.swift         # @main entry point
│   └── DependencyContainer.swift
├── Domain/                      # Pure Swift (NO frameworks)
│   ├── Entities/               # Business models
│   │   ├── CravingEntity.swift
│   │   ├── UsageEntity.swift
│   │   ├── RecordingEntity.swift
│   │   └── MotivationalMessageEntity.swift
│   ├── UseCases/               # Business logic
│   │   ├── LogCravingUseCase.swift
│   │   ├── FetchCravingsUseCase.swift
│   │   ├── LogUsageUseCase.swift
│   │   └── FetchUsageUseCase.swift
│   └── Repositories/           # Protocols ONLY
│       ├── CravingRepositoryProtocol.swift
│       ├── UsageRepositoryProtocol.swift
│       ├── RecordingRepositoryProtocol.swift
│       └── MessageRepositoryProtocol.swift
├── Data/                        # Persistence + Storage
│   ├── Models/                 # SwiftData @Model
│   │   ├── CravingModel.swift
│   │   ├── UsageModel.swift
│   │   ├── RecordingModel.swift
│   │   └── MotivationalMessageModel.swift
│   ├── Repositories/           # Concrete implementations
│   │   ├── CravingRepository.swift  # ✅ Implemented
│   │   └── UsageRepository.swift    # ✅ Implemented
│   ├── Mappers/                # Entity ↔ Model conversion
│   │   ├── CravingMapper.swift
│   │   ├── UsageMapper.swift
│   │   ├── RecordingMapper.swift
│   │   └── MessageMapper.swift
│   └── Storage/                # File I/O + ModelContainer
│       ├── FileStorageManager.swift
│       └── ModelContainerSetup.swift
└── Presentation/                # UI Layer
    ├── ViewModels/              # @Observable state
    │   ├── CravingLogViewModel.swift
    │   ├── CravingListViewModel.swift
    │   ├── UsageLogViewModel.swift
    │   ├── UsageListViewModel.swift
    │   ├── DashboardViewModel.swift
    │   └── SettingsViewModel.swift
    └── Views/                   # SwiftUI
        ├── Home/HomeView.swift
        ├── Craving/CravingLogForm.swift, CravingListView.swift
        ├── Usage/UsageLogForm.swift, UsageListView.swift
        ├── Dashboard/DashboardView.swift
        ├── Settings/SettingsView.swift
        └── Components/ChipSelector, IntensitySlider, etc.

CraveyTests/                     # Unit Tests (32 passing)
├── Domain/UseCases/
├── Integration/
└── Presentation/ViewModels/

CraveyUITests/                   # UI Tests (disabled - Swift 6 concurrency)
```

### Dependency Flow (Clean Architecture Rules)
```
Presentation → Domain ← Data
     ↓           ↓        ↓
  Views    Use Cases  Repos
     ↓           ↓        ↓
ViewModels   Entities  Models
```

**Key Rules:**
- Domain layer = Pure Swift (NO SwiftUI/SwiftData imports)
- Data layer implements Domain protocols
- Presentation depends ONLY on Domain (via Use Cases)
- DependencyContainer wires everything together

---

## Essential Terminal Commands

### First-Time Setup
```bash
# 1. Install all CLI tools
./setup-tools.sh

# 2. Generate Xcode project from project.yml
xcodegen generate

# 3. Open in Xcode
open Cravey.xcodeproj
```

### Daily Development
```bash
# Build from terminal
xcodebuild -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build | xcbeautify

# Run unit tests only (fast)
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests | xcbeautify

# Run all tests (slower, includes UI tests)
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' | xcbeautify

# Format code (run before commit)
swiftformat .

# Lint code
swiftlint

# Auto-fix linting issues
swiftlint --fix

# Clean build
xcodebuild clean -scheme Cravey

# List available simulators
xcrun simctl list devices available | grep iPhone

# Regenerate Xcode project (if project.yml changes)
xcodegen generate
```

### Git Workflow
```bash
# Stage changes
git add .

# Commit with proper message
git commit -m "Your message"

# Push to main
git push origin main

# View repo on GitHub
gh repo view clarity-digital-twin/cravey --web

# Create PR (when working on branches)
gh pr create --title "Title" --body "Description"
```

---

## Data Models (SwiftData)

### CravingModel (@Model)
**File:** `Cravey/Data/Models/CravingModel.swift`

Tracks individual craving episodes:
- `id: UUID` - Unique identifier
- `timestamp: Date` - When craving occurred (user-editable)
- `intensity: Int` - Scale 1-10
- `triggers: [String]` - HAALT triggers (multi-select)
- `location: String?` - Where it happened (preset or GPS)
- `notes: String?` - User notes (500 char limit)
- `createdAt: Date` - Auto-set on creation
- `modifiedAt: Date?` - Set on update

### UsageModel (@Model)
**File:** `Cravey/Data/Models/UsageModel.swift`

Tracks cannabis usage:
- `id: UUID` - Unique identifier
- `timestamp: Date` - When usage occurred
- `method: String` - ROA (Bowls, Joints, Vape, etc.)
- `amount: Double` - Amount consumed
- `triggers: [String]` - HAALT triggers
- `location: String?` - Where it happened
- `notes: String?` - User notes (500 char limit)
- `createdAt: Date` - Auto-set on creation
- `modifiedAt: Date?` - Set on update

### RecordingModel (@Model)
**File:** `Cravey/Data/Models/RecordingModel.swift`

Stores video/audio recordings:
- `id: UUID`
- `timestamp: Date`
- `type: String` - "video" or "audio"
- `purpose: String` - "motivational", "craving", "reflection", "milestone"
- `duration: TimeInterval`
- `filePath: String` - Relative path to file (NOT stored in database)
- `thumbnailPath: String?` - For videos
- `title: String?`
- `notes: String?`
- `playCount: Int`
- `lastPlayedAt: Date?`
- `craving: CravingModel?` - @Relationship (many-to-one, optional)

### MotivationalMessageModel (@Model)
**File:** `Cravey/Data/Models/MotivationalMessageModel.swift`

Pre-populated and user-created messages:
- `id: UUID`
- `content: String`
- `category: String` - "urge", "anxiety", "boredom", "social", "celebration"
- `isCustom: Bool` - User-created vs default
- `priority: Int` - Display order
- `timesShown: Int`
- `lastShownAt: Date?`
- `isActive: Bool`

---

## File Storage Implementation

### Recording Storage
**File:** `Cravey/Data/Storage/FileStorageManager.swift`

```
~/Documents/
  └── Recordings/
      ├── video_UUID.mov
      ├── audio_UUID.m4a
      └── Thumbnails/
          └── video_UUID_thumb.jpg
```

**Important:**
- File paths stored as **relative strings** in SwiftData
- `DependencyContainer.fileStorage` provides file I/O (injectable `FileStorageManager`)
- Delete file AND database entry together
- Use `nonisolated(unsafe)` for ModelContext in Swift 6 strict concurrency

### SwiftData Configuration
**File:** `Cravey/Data/Storage/ModelContainerSetup.swift`

```swift
ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    allowsSave: true,
    cloudKitDatabase: .none  // ⚠️ CRITICAL: Local only
)
```

---

## Implementation Status

> **See `docs/PROJECT_STATUS.md` for detailed current status.**

### ✅ Working Features
- **Craving Logging** - Full form with intensity, triggers, location, notes, timestamp
- **Usage Logging** - Full form with ROA picker, amounts, triggers, location, notes
- **Dashboard** - 5 metric cards, streak tracking, intensity trends
- **Settings** - Export (CSV/JSON) + delete-all (logs + recordings + custom messages)
- **Home Screen** - Lists cravings + usage with swipe actions

### ✅ Technical Foundation
- Clean Architecture folder structure
- Domain layer (5 entities, 10 use case files, 4 protocols)
- Data layer (4 models, 4 mappers, 4 repositories: Craving, Usage, Recording, Message, plus 1 SwiftData-backed DeleteAllUserData use case)
- DependencyContainer with DI
- 6 ViewModels (CravingLog, CravingList, UsageLog, UsageList, Dashboard, Settings)
- 10+ SwiftUI Views with reusable components
- Unit tests (42 Swift Testing tests passing in `CraveyTests`)
- XcodeGen configuration

### 🚧 TODO (Not Implemented)
- **Recording Views** - AVFoundation integration, recording/playback UI
- **Onboarding** - WelcomeView, TourView not created
- **UI Tests** - Scaffolding exists; not part of the automated convergence gate

---

## Adding New Features (Step-by-Step)

### Example: Implement RecordingRepository

1. **Create Repository Implementation**
   ```swift
   // Cravey/Data/Repositories/RecordingRepository.swift
   final class RecordingRepository: RecordingRepositoryProtocol {
       nonisolated(unsafe) private let modelContext: ModelContext

       init(modelContext: ModelContext) {
           self.modelContext = modelContext
       }

       func save(_ recording: RecordingEntity) async throws {
           let model = RecordingMapper.toModel(recording)
           modelContext.insert(model)
           try modelContext.save()
       }
       // ... implement other protocol methods
   }
   ```

2. **Update DependencyContainer**
   ```swift
   // Replace stub in Cravey/App/DependencyContainer.swift
   let recordingRepo = RecordingRepository(modelContext: modelContext)
   self.recordingRepository = recordingRepo
   ```

3. **Create Use Case**
   ```swift
   // Cravey/Domain/UseCases/SaveRecordingUseCase.swift
   protocol SaveRecordingUseCase: Sendable {
       func execute(...) async throws -> RecordingEntity
   }
   ```

4. **Create ViewModel**
   ```swift
   // Cravey/Presentation/ViewModels/RecordingViewModel.swift
   @Observable
   @MainActor
   final class RecordingViewModel {
       private let saveRecordingUseCase: SaveRecordingUseCase
       // ...
   }
   ```

5. **Create View**
   ```swift
   // Cravey/Presentation/Views/RecordingView.swift
   struct RecordingView: View {
       @State private var viewModel: RecordingViewModel
       // ...
   }
   ```

6. **Write Tests**
   ```swift
   // CraveyTests/Domain/UseCases/SaveRecordingUseCaseTests.swift
   // CraveyTests/Presentation/ViewModels/RecordingViewModelTests.swift
   ```

---

## Testing Strategy

### Unit Tests (Fast)
**Run:** `xcodebuild test -scheme Cravey -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:CraveyTests | xcbeautify`

- Test Domain Use Cases with mock repositories
- Test ViewModels with mock use cases
- Use `actor` for mock implementations (Swift 6 concurrency)
- Testing framework: Swift Testing (`import Testing`, `@Test` macro)

**Example:**
```swift
@Test("Should save valid craving")
func testLogValidCraving() async throws {
    let mockRepo = MockCravingRepository()
    let useCase = DefaultLogCravingUseCase(repository: mockRepo)

    let result = try await useCase.execute(intensity: 5, ...)

    #expect(result.intensity == 5)
    let count = try await mockRepo.count()
    #expect(count == 1)
}
```

### UI Tests (Slow)
**Run:** `xcodebuild test -scheme Cravey -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:CraveyUITests | xcbeautify`

- Currently disabled due to Swift 6 strict concurrency
- Will test end-to-end user flows when re-enabled

---

## Common Development Tasks

### Add a New Property to Entity
1. Add to `Domain/Entities/XEntity.swift`
2. Add to `Data/Models/XModel.swift`
3. Update mapper in `Data/Mappers/XMapper.swift`
4. SwiftData handles lightweight migrations automatically
5. Update relevant views/ViewModels

### Debug SwiftData Issues
```swift
// Check database location
print(modelContainer.configurations.first?.url)

// Query manually
let descriptor = FetchDescriptor<CravingModel>()
let results = try modelContext.fetch(descriptor)
print("Found \(results.count) cravings")
```

### Handle Swift 6 Concurrency
- Use `nonisolated(unsafe)` for ModelContext in repositories
- Mark ViewModels with `@MainActor`
- Use `actor` for test mocks
- Don't use `lazy var` with `@Observable`

---

## Privacy & Sensitive UX Considerations

⚠️ **This app deals with addiction recovery. Keep in mind:**

- **Users may be in crisis** → Keep UI simple, large tap targets, clear CTAs
- **Privacy is critical** → Never add cloud features, no analytics
- **Be compassionate** → Language should be supportive, not judgmental
- **Focus on progress** → Celebrate wins, normalize setbacks
- **Don't gamify excessively** → This isn't a fitness app, avoid harsh streaks

**Language Guidelines:**
- ✅ "You're doing great"
- ✅ "Every moment of resistance is progress"
- ✅ "Setbacks are part of the journey"
- ❌ "You failed"
- ❌ "Streak broken"
- ❌ "Try harder"

---

## XcodeGen Workflow

**Source of Truth:** `project.yml` (committed to git)
**Generated (Not Committed):** `Cravey.xcodeproj` (gitignored)

### When to Regenerate
- After modifying `project.yml`
- After cloning fresh repo
- After adding new files/folders
- When Xcode project gets corrupted

```bash
xcodegen generate
```

### project.yml Key Settings
```yaml
name: Cravey
options:
  deploymentTarget:
    iOS: 18.0
settings:
  SWIFT_VERSION: "6.0"
  SWIFT_STRICT_CONCURRENCY: "complete"
```

---

## Documentation Files

- **docs/PROJECT_STATUS.md** - **Single source of truth for current status**
- **docs/ARCHITECTURE.md** - Deep dive into Clean Architecture implementation
- **docs/GETTING_STARTED.md** - Quick 5-minute setup guide
- **docs/master/** - Authoritative product/clinical/data-model specs (SSOT)
- **docs/specs/** - Active engineering specs
- **docs/bugs/** - Bug tracker
- **docs/debt/** - Technical debt tracker
- **AGENTS.md / CLAUDE.md** - Development context (redundant copies; keep in sync)
- **README.md** - Public-facing project overview
- **docs/_archive/** - Historical docs (do not reference)

---

## Context7 MCP Integration

**Configured in:** `.mcp.json` (gitignored, local only)

**Usage:**
```
"use context7 to fetch latest SwiftUI documentation"
"use context7 to get SwiftData best practices"
```

**Available Resources:**
- `/mongodb/docs`
- SwiftUI docs (via website fetching)
- SwiftData docs (via website fetching)

---

## Next Development Priorities

> **See `docs/PROJECT_STATUS.md` for prioritized backlog.**

Options after stabilization:

### Option A: Quick Wins
1. **Onboarding** - WelcomeView + TourView (improves first-launch)

### Option B: Core Differentiator
1. **Recordings Feature** - AVFoundation, RecordingRepository, UI
   - Audio recording first (simpler)
   - Video recording second (complex)
   - Recording library UI

### Option C: Launch Prep
1. **TestFlight** - Beta testing
2. **App Store assets** - Screenshots, description

---

## Quick Reference Commands

```bash
# Full rebuild + test
xcodegen generate && \
xcodebuild -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build test | xcbeautify

# Format + Lint + Test
swiftformat . && \
swiftlint && \
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests | xcbeautify

# Commit + Push
git add . && \
git commit -m "Your message" && \
git push origin main
```

---

**🔥 Keep this file updated as architecture evolves! 🔥**
