# Cravey App - AI Agent Development Context

**Last Updated:** 2025-10-11

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
│   │   ├── RecordingEntity.swift
│   │   └── MotivationalMessageEntity.swift
│   ├── UseCases/               # Business logic
│   │   ├── LogCravingUseCase.swift
│   │   └── FetchCravingsUseCase.swift
│   └── Repositories/           # Protocols ONLY
│       ├── CravingRepositoryProtocol.swift
│       ├── RecordingRepositoryProtocol.swift
│       └── MessageRepositoryProtocol.swift
├── Data/                        # Persistence + Storage
│   ├── Models/                 # SwiftData @Model
│   │   ├── CravingModel.swift
│   │   ├── RecordingModel.swift
│   │   └── MotivationalMessageModel.swift
│   ├── Repositories/           # Concrete implementations
│   │   └── CravingRepository.swift  # ✅ Implemented
│   ├── Mappers/                # Entity ↔ Model conversion
│   │   ├── CravingMapper.swift
│   │   ├── RecordingMapper.swift
│   │   └── MessageMapper.swift
│   └── Storage/                # File I/O + ModelContainer
│       ├── FileStorageManager.swift
│       └── ModelContainerSetup.swift
└── Presentation/                # UI Layer
    ├── ViewModels/              # @Observable state
    │   └── CravingLogViewModel.swift  # ✅ Implemented
    └── Views/                   # SwiftUI (TODO)
        └── (Placeholder ContentView)

CraveyTests/                     # Unit Tests
├── Domain/UseCases/
│   └── LogCravingUseCaseTests.swift  # ✅ 2/2 passing
└── Presentation/ViewModels/
    └── CravingLogViewModelTests.swift  # ✅ 2/2 passing

CraveyUITests/                   # UI Tests (TODO)
    └── CraveyUITests.swift
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
- `timestamp: Date` - When craving occurred
- `intensity: Int` - Scale 1-10
- `duration: Int?` - How long (minutes)
- `trigger: String?` - What caused it
- `notes: String?` - User notes
- `location: String?` - Where it happened
- `managementStrategy: String?` - How they coped
- `wasManagedSuccessfully: Bool` - Outcome
- `recordings: [RecordingModel]` - @Relationship (one-to-many)

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
- `FileStorageManager.shared` handles all file I/O
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

### ✅ Complete (Ready for Reference)
- Clean Architecture folder structure
- Domain layer (all entities, protocols, 2 use cases)
- Data layer (all models, CravingRepository, all mappers)
- DependencyContainer with DI
- CravingLogViewModel
- Unit tests (4/4 passing)
- Terminal build/test workflow
- XcodeGen configuration

### 🚧 TODO (Stub Implementations)
- **RecordingRepository** - Protocol exists, stub implementation in DI
- **MessageRepository** - Protocol exists, stub implementation in DI
- **SwiftUI Views** - Currently placeholder ContentView
- **AVFoundation Integration** - Recording/playback logic
- **UI Tests** - Scaffolding exists, temporarily disabled (Swift 6 concurrency)

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

- **ARCHITECTURE.md** - Deep dive into Clean Architecture implementation
- **GETTING_STARTED.md** - Quick 5-minute setup guide
- **PROJECT_SETUP.md** - Xcode project creation instructions
- **CLAUDE.md** - This file (development context)
- **README.md** - Public-facing project overview

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

1. **Implement RecordingRepository & MessageRepository** (follow CravingRepository pattern)
2. **Build AVFoundation recording logic** (audio/video capture + playback)
3. **Create real SwiftUI Views** (replace placeholder)
4. **Add more Use Cases** (FetchRecordings, SaveMessage, etc.)
5. **Analytics Dashboard** (Swift Charts for progress visualization)
6. **Enhanced Motivational Content** (smart message selection)

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
