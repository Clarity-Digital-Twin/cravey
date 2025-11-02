# Phase 4: Recordings (Weeks 5-6)

**Version:** 2.0 (Chronologically Ordered)
**Duration:** 2 weeks (Weeks 5-6 of 16-week timeline)
**Dependencies:** Phases 1-3 complete (Craving/Usage logging, Onboarding, Data Management)
**Status:** 📝 Ready for Implementation

---

## 🎯 Phase Goal

**Shippable Deliverable:** Users can **record motivational content** (audio + video), play it back during cravings, and access Top 3 recordings from Home tab.

**Feature Implemented:** Feature 3 (Pre-Recorded Motivational Content - Recordings)

**Week 5 Focus:** Audio + Video Recording (AVFoundation integration, file storage, metadata)
**Week 6 Focus:** Playback, Library UI, Quick Play section (Home tab integration)

---

## 📋 What's Already Done (Baseline from Weeks 1-4)

### Domain Layer
- ✅ `RecordingEntity.swift` - Domain model (created in baseline)
- ✅ `RecordingRepositoryProtocol.swift` - Repository interface

### Data Layer
- ✅ `RecordingModel.swift` - SwiftData @Model (created in baseline)
- ✅ `RecordingMapper.swift` - Entity ↔ Model conversion
- ⚠️ `RecordingRepository.swift` - **STUB ONLY** (will replace with real implementation)

### Presentation Layer
- ✅ `FileStorageManager.swift` - File I/O helper (used for recording files)
- ✅ `HomeView.swift` - Exists (will add Quick Play section)

### DependencyContainer
- ✅ `RecordingRepository` injected (currently stub pattern)
- ✅ `@Environment` setup for repository access

**Key Components Already Available:**
- SwiftData ModelContainer with RecordingModel schema
- File storage infrastructure (Documents/Recordings/ directory)
- Clean Architecture DI pattern via @Environment

---

## 📦 Complete File Checklist (18 files total)

### Part 1: Domain Layer (4 use case files)
- [ ] `Domain/UseCases/SaveRecordingUseCase.swift` (CREATE - save recording + metadata)
- [ ] `Domain/UseCases/FetchRecordingsUseCase.swift` (CREATE - fetch with filters)
- [ ] `Domain/UseCases/PlayRecordingUseCase.swift` (CREATE - increment play count)
- [ ] `Domain/UseCases/DeleteRecordingUseCase.swift` (CREATE - delete file + DB entry)

### Part 2: Data Layer (1 repository file)
- [ ] `Data/Repositories/RecordingRepository.swift` (REPLACE STUB - real SwiftData implementation)

### Part 3: Presentation Layer - Coordinators (2 files)
- [ ] `Presentation/Coordinators/AudioRecordingCoordinator.swift` (CREATE - AVAudioRecorder wrapper)
- [ ] `Presentation/Coordinators/VideoRecordingCoordinator.swift` (CREATE - AVCaptureSession wrapper)

### Part 4: Presentation Layer - ViewModels (3 files)
- [ ] `Presentation/ViewModels/RecordingLibraryViewModel.swift` (CREATE - library state)
- [ ] `Presentation/ViewModels/AudioRecordingViewModel.swift` (CREATE - audio recording state)
- [ ] `Presentation/ViewModels/VideoRecordingViewModel.swift` (CREATE - video recording state)

### Part 5: Presentation Layer - Views (7 files)
- [ ] `Presentation/Views/Recordings/RecordingsLibraryView.swift` (CREATE - main library UI)
- [ ] `Presentation/Views/Recordings/RecordingModeView.swift` (CREATE - choose audio/video)
- [ ] `Presentation/Views/Recordings/AudioRecordingView.swift` (CREATE - audio recording UI)
- [ ] `Presentation/Views/Recordings/VideoRecordingView.swift` (CREATE - video recording UI)
- [ ] `Presentation/Views/Recordings/AudioPlayerView.swift` (CREATE - audio playback)
- [ ] `Presentation/Views/Recordings/VideoPlayerView.swift` (CREATE - video playback with AVKit)
- [ ] `Presentation/Views/Home/QuickPlaySection.swift` (CREATE - Top 3 recordings section for HomeView)

### Part 6: Modified Files (1 file)
- [ ] `Presentation/Views/HomeView.swift` (MODIFY - add Quick Play section)

---

## 🧪 Test Plan (16 tests total)

### Unit Tests (10 tests across 6 files)

**Domain Layer (4 tests):**
1. `SaveRecordingUseCaseTests.swift` (2 tests)
   - Test: Save recording with valid metadata
   - Test: Reject invalid duration (>120 sec)

2. `FetchRecordingsUseCaseTests.swift` (2 tests)
   - Test: Fetch all recordings sorted by timestamp
   - Test: Filter by type (video/audio)

**Presentation Layer (6 tests):**
3. `AudioRecordingCoordinatorTests.swift` (2 tests)
   - Test: Start/stop recording creates file
   - Test: Recording duration calculated correctly

4. `VideoRecordingCoordinatorTests.swift` (2 tests)
   - Test: Video recording creates .mov file
   - Test: Thumbnail generated for video

5. `RecordingLibraryViewModelTests.swift` (2 tests)
   - Test: Fetch recordings populates state
   - Test: Delete recording removes from list

### Integration Tests (4 tests in 2 files)

6. `RecordingIntegrationTests.swift` (2 tests)
   - Test: End-to-end audio recording → save → fetch
   - Test: End-to-end video recording → save → fetch

7. `PlaybackIntegrationTests.swift` (2 tests)
   - Test: Play recording increments playCount
   - Test: Quick Play section shows Top 3 by playCount

### UI Tests (2 tests in 1 file)

8. `RecordingUITests.swift` (2 tests)
   - Test: Record audio flow (tap record → stop → save → appears in library)
   - Test: Quick Play section appears on Home tab with recordings

**Total: 10 unit + 4 integration + 2 UI = 16 tests**

---

## 🚀 Implementation Steps (Week 5: Recording, Week 6: Playback)

---

## WEEK 5: Audio + Video Recording

### Step 1: Create SaveRecordingUseCase (Domain Layer)

**File:** `Cravey/Domain/UseCases/SaveRecordingUseCase.swift`

**Purpose:** Business logic for saving recording metadata + file URL validation.

```swift
import Foundation

/// Use case for saving a recording with metadata validation
protocol SaveRecordingUseCase: Sendable {
    func execute(
        recordingType: RecordingType,
        purpose: RecordingPurpose,
        duration: TimeInterval,
        fileURL: String,
        thumbnailURL: String?,
        title: String,
        notes: String?
    ) async throws -> RecordingEntity
}

/// Default implementation with validation
actor DefaultSaveRecordingUseCase: SaveRecordingUseCase {
    private let repository: RecordingRepositoryProtocol

    init(repository: RecordingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        recordingType: RecordingType,
        purpose: RecordingPurpose,
        duration: TimeInterval,
        fileURL: String,
        thumbnailURL: String?,
        title: String,
        notes: String?
    ) async throws -> RecordingEntity {
        // Validation: duration must be ≤120 seconds
        guard duration > 0 && duration <= 120 else {
            throw RecordingError.invalidDuration
        }

        // Create entity (enums are already validated by type system)
        let recording = RecordingEntity(
            id: UUID(),
            createdAt: Date(),
            recordingType: recordingType,
            purpose: purpose,
            title: title,
            fileURL: fileURL,
            duration: duration,
            notes: notes,
            thumbnailURL: thumbnailURL,
            lastPlayedAt: nil,
            playCount: 0
        )

        // Save to repository
        try await repository.save(recording)

        return recording
    }
}

enum RecordingError: Error {
    case invalidDuration
    case fileNotFound
    case saveFailed
    case permissionDenied
}
```

**Why This Code:**
- Uses `RecordingType` and `RecordingPurpose` enums (type-safe, matches baseline)
- Duration validation enforces 2-minute max (MVP requirement)
- Property names match `RecordingEntity.swift:8-14` (fileURL, thumbnailURL, recordingType)
- Enum validation handled by Swift's type system (no manual string checks)
- Returns RecordingEntity for ViewModel use

---

### Step 2: Create FetchRecordingsUseCase (Domain Layer)

**File:** `Cravey/Domain/UseCases/FetchRecordingsUseCase.swift`

```swift
import Foundation

/// Use case for fetching recordings with optional filters
protocol FetchRecordingsUseCase: Sendable {
    func execute(recordingType: RecordingType?) async throws -> [RecordingEntity]
    func fetchTopPlayed(limit: Int) async throws -> [RecordingEntity]
}

actor DefaultFetchRecordingsUseCase: FetchRecordingsUseCase {
    private let repository: RecordingRepositoryProtocol

    init(repository: RecordingRepositoryProtocol) {
        self.repository = repository
    }

    /// Fetch all recordings, optionally filtered by type
    func execute(recordingType: RecordingType? = nil) async throws -> [RecordingEntity] {
        if let type = recordingType {
            return try await repository.fetch(byType: type)
        } else {
            return try await repository.fetchAll()
        }
    }

    /// Fetch most-played recordings (for Quick Play section)
    func fetchTopPlayed(limit: Int = 3) async throws -> [RecordingEntity] {
        let allRecordings = try await repository.fetchAll()
        return Array(allRecordings
            .sorted { $0.playCount > $1.playCount }
            .prefix(limit))
    }
}
```

**Why This Code:**
- Uses `RecordingType` enum (not String) for type-safe filtering
- `execute(recordingType:)` enables filtering by audio/video
- `fetchTopPlayed(limit:)` powers Quick Play section (Home tab)
- Sorting by playCount prioritizes user's favorite recordings

**Note:** This requires adding `fetch(byType:)` to `RecordingRepositoryProtocol` (see Step 2a below).

---

### Step 2a: Extend RecordingRepositoryProtocol (Domain Layer)

**File:** `Cravey/Domain/Repositories/RecordingRepositoryProtocol.swift` (MODIFY)

**Add this method to the existing protocol:**

```swift
/// Fetch recordings by type (audio or video)
func fetch(byType recordingType: RecordingType) async throws -> [RecordingEntity]
```

**Why:** The baseline protocol has `fetch(byPurpose:)` but the UI needs to filter by type (All/Videos/Audio). This extends the protocol to support both filtering strategies.

⚠️ **IMPORTANT - Compilation Fix Required:**
After adding this method to the protocol, the `StubRecordingRepository` in `DependencyContainer.swift` (lines 81-101) will fail to compile. You MUST immediately add the stub implementation:

```swift
func fetch(byType recordingType: RecordingType) async throws -> [RecordingEntity] {
    return []
}
```

See **Step 5a, Section 5** for complete instructions on updating the stub.

**Updated Protocol (after modification):**

```swift
import Foundation

protocol RecordingRepositoryProtocol: Sendable {
    func save(_ recording: RecordingEntity) async throws
    func fetchAll() async throws -> [RecordingEntity]
    func fetch(byPurpose purpose: RecordingPurpose) async throws -> [RecordingEntity]
    func fetch(byType recordingType: RecordingType) async throws -> [RecordingEntity]  // ← NEW
    func delete(id: UUID) async throws
    func update(_ recording: RecordingEntity) async throws
}
```

---

### Step 3: Create PlayRecordingUseCase (Domain Layer)

**File:** `Cravey/Domain/UseCases/PlayRecordingUseCase.swift`

```swift
import Foundation

/// Use case for incrementing play count when recording is played
protocol PlayRecordingUseCase: Sendable {
    func execute(recording: RecordingEntity) async throws -> RecordingEntity
}

actor DefaultPlayRecordingUseCase: PlayRecordingUseCase {
    private let repository: RecordingRepositoryProtocol

    init(repository: RecordingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(recording: RecordingEntity) async throws -> RecordingEntity {
        // Increment play count and update timestamp (using RecordingEntity business logic)
        let updatedRecording = recording.incrementPlayCount()

        // Save updated entity
        try await repository.update(updatedRecording)

        return updatedRecording
    }
}
```

**Why This Code:**
- Uses `RecordingEntity.incrementPlayCount()` method (RecordingEntity.swift:72) for business logic
- Tracks usage analytics (which recordings help most)
- Powers Quick Play ranking (most-played recordings shown first)
- Updates lastPlayedAt for future "recently played" features

---

### Step 4: Create DeleteRecordingUseCase (Domain Layer)

**File:** `Cravey/Domain/UseCases/DeleteRecordingUseCase.swift`

```swift
import Foundation

/// Use case for deleting recording (file + database entry)
protocol DeleteRecordingUseCase: Sendable {
    func execute(id: UUID) async throws
}

actor DefaultDeleteRecordingUseCase: DeleteRecordingUseCase {
    private let repository: RecordingRepositoryProtocol

    init(repository: RecordingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: UUID) async throws {
        // Delete from repository (handles file deletion + DB removal)
        try await repository.delete(id: id)
    }
}
```

**Why This Code:**
- Single responsibility: coordinate deletion
- Uses `delete(id:)` signature from RecordingRepositoryProtocol.swift:16
- Repository handles both file I/O and database operations
- Atomic delete (both file and DB entry removed together)

---

### Step 5: Implement RecordingRepository (Data Layer)

**File:** `Cravey/Data/Repositories/RecordingRepository.swift` (REPLACE STUB)

```swift
import Foundation
import SwiftData

/// Real implementation of RecordingRepositoryProtocol using SwiftData
final class RecordingRepository: RecordingRepositoryProtocol {
    nonisolated(unsafe) private let modelContext: ModelContext
    private let fileManager: FileStorageManager

    init(modelContext: ModelContext, fileManager: FileStorageManager = .shared) {
        self.modelContext = modelContext
        self.fileManager = fileManager
    }

    // MARK: - Save

    func save(_ recording: RecordingEntity) async throws {
        let model = RecordingMapper.toModel(recording)
        modelContext.insert(model)
        try modelContext.save()
    }

    // MARK: - Fetch All

    func fetchAll() async throws -> [RecordingEntity] {
        let descriptor = FetchDescriptor<RecordingModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map(RecordingMapper.toEntity)
    }

    // MARK: - Fetch by Type

    func fetch(byType recordingType: RecordingType) async throws -> [RecordingEntity] {
        let descriptor = FetchDescriptor<RecordingModel>(
            predicate: #Predicate { $0.recordingType == recordingType.rawValue },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map(RecordingMapper.toEntity)
    }

    // MARK: - Fetch by Purpose (existing baseline method)

    func fetch(byPurpose purpose: RecordingPurpose) async throws -> [RecordingEntity] {
        let descriptor = FetchDescriptor<RecordingModel>(
            predicate: #Predicate { $0.purpose == purpose.rawValue },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map(RecordingMapper.toEntity)
    }

    // MARK: - Update

    func update(_ recording: RecordingEntity) async throws {
        // Fetch existing model
        let descriptor = FetchDescriptor<RecordingModel>(
            predicate: #Predicate { $0.id == recording.id }
        )
        guard let existingModel = try modelContext.fetch(descriptor).first else {
            throw RecordingError.fileNotFound
        }

        // Update fields (SwiftData tracks changes automatically)
        existingModel.playCount = recording.playCount
        existingModel.lastPlayedAt = recording.lastPlayedAt
        existingModel.title = recording.title
        existingModel.notes = recording.notes

        try modelContext.save()
    }

    // MARK: - Delete

    func delete(id: UUID) async throws {
        // 1. Fetch the recording to get file paths
        let descriptor = FetchDescriptor<RecordingModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            throw RecordingError.fileNotFound
        }

        // 2. Delete files from disk
        try fileManager.deleteRecording(at: model.fileURL)
        try fileManager.deleteThumbnail(at: model.thumbnailURL)

        // 3. Delete from database
        modelContext.delete(model)
        try modelContext.save()
    }
}
```

**Why This Code:**
- `nonisolated(unsafe)` for Swift 6 ModelContext access
- Uses `createdAt` property (RecordingModel.swift:9) not `timestamp`
- `fetch(byType:)` uses `RecordingType` enum and matches on `recordingType` property
- `fetch(byPurpose:)` included (baseline protocol method)
- `delete(id:)` signature matches RecordingRepositoryProtocol.swift:16
- Uses `fileURL` and `thumbnailURL` properties (RecordingEntity.swift:12,14)
- FileStorageManager handles file I/O (separation of concerns)
- Atomic delete (file + DB) with proper error handling

---

### Step 5a: Update DependencyContainer (App Layer)

**File:** `Cravey/App/DependencyContainer.swift` (MODIFY)

**Purpose:** Wire up all new use cases, replace stub repository, add ViewModel factory methods.

**Required Changes:**

#### 1. Add Use Case Properties

Add these properties after the existing use cases (after line 24):

```swift
// MARK: - Use Cases (Domain Layer)

private(set) var logCravingUseCase: LogCravingUseCase
private(set) var fetchCravingsUseCase: FetchCravingsUseCase

// ← ADD THESE NEW USE CASES:
private(set) var saveRecordingUseCase: SaveRecordingUseCase
private(set) var fetchRecordingsUseCase: FetchRecordingsUseCase
private(set) var playRecordingUseCase: PlayRecordingUseCase
private(set) var deleteRecordingUseCase: DeleteRecordingUseCase
```

#### 2. Replace StubRecordingRepository with Real Implementation

In the `init(isPreview:)` method, replace line 49:

```swift
// BEFORE:
let recordingRepo = StubRecordingRepository() // TODO: Implement RecordingRepository

// AFTER:
let recordingRepo = RecordingRepository(
    modelContext: modelContext,
    fileManager: fileStorage
)
```

#### 3. Initialize New Use Cases

After the existing use case initialization (after line 58), add:

```swift
// Initialize use cases
self.logCravingUseCase = DefaultLogCravingUseCase(repository: cravingRepo)
self.fetchCravingsUseCase = DefaultFetchCravingsUseCase(repository: cravingRepo)

// ← ADD THESE:
self.saveRecordingUseCase = DefaultSaveRecordingUseCase(repository: recordingRepo)
self.fetchRecordingsUseCase = DefaultFetchRecordingsUseCase(repository: recordingRepo)
self.playRecordingUseCase = DefaultPlayRecordingUseCase(repository: recordingRepo)
self.deleteRecordingUseCase = DefaultDeleteRecordingUseCase(repository: recordingRepo)
```

#### 4. Add ViewModel Factory Methods

After `makeCravingLogViewModel()` (after line 30), add:

```swift
func makeCravingLogViewModel() -> CravingLogViewModel {
    CravingLogViewModel(logCravingUseCase: logCravingUseCase)
}

// ← ADD THESE NEW FACTORIES:

func makeRecordingLibraryViewModel() -> RecordingLibraryViewModel {
    RecordingLibraryViewModel(
        fetchUseCase: fetchRecordingsUseCase,
        deleteUseCase: deleteRecordingUseCase
    )
}

func makeAudioRecordingViewModel() -> AudioRecordingViewModel {
    AudioRecordingViewModel(saveUseCase: saveRecordingUseCase)
}

func makeVideoRecordingViewModel() -> VideoRecordingViewModel {
    VideoRecordingViewModel(saveUseCase: saveRecordingUseCase)
}

func makeQuickPlayViewModel() -> QuickPlayViewModel {
    QuickPlayViewModel(fetchUseCase: fetchRecordingsUseCase)
}
```

#### 5. Update StubRecordingRepository (Temporary Compilation Fix)

**IMPORTANT:** After adding `fetch(byType:)` to the protocol in Step 2a, the stub will break compilation. Add this method to `StubRecordingRepository` (around line 92):

```swift
private struct StubRecordingRepository: RecordingRepositoryProtocol {
    func save(_ recording: RecordingEntity) async throws { }
    func fetchAll() async throws -> [RecordingEntity] { return [] }
    func fetch(byPurpose purpose: RecordingPurpose) async throws -> [RecordingEntity] { return [] }

    // ← ADD THIS METHOD:
    func fetch(byType recordingType: RecordingType) async throws -> [RecordingEntity] {
        return []
    }

    func delete(id: UUID) async throws { }
    func update(_ recording: RecordingEntity) async throws { }
}
```

**Note:** This stub update should be done immediately after Step 2a to maintain compilation. Once you complete Step 5, replace the stub entirely as shown in change #2 above.

**Complete Updated DependencyContainer:**

<details>
<summary>Click to see full file (after all changes)</summary>

```swift
import Foundation
import SwiftData

@Observable
@MainActor
final class DependencyContainer {
    // MARK: - Infrastructure (Data Layer)

    let modelContainer: ModelContainer
    let modelContext: ModelContext
    let fileStorage: FileStorageManager

    // MARK: - Repositories (Data Layer)

    private(set) var cravingRepository: CravingRepositoryProtocol
    private(set) var recordingRepository: RecordingRepositoryProtocol
    private(set) var messageRepository: MessageRepositoryProtocol

    // MARK: - Use Cases (Domain Layer)

    private(set) var logCravingUseCase: LogCravingUseCase
    private(set) var fetchCravingsUseCase: FetchCravingsUseCase
    private(set) var saveRecordingUseCase: SaveRecordingUseCase
    private(set) var fetchRecordingsUseCase: FetchRecordingsUseCase
    private(set) var playRecordingUseCase: PlayRecordingUseCase
    private(set) var deleteRecordingUseCase: DeleteRecordingUseCase

    // MARK: - View Models (Presentation Layer)

    func makeCravingLogViewModel() -> CravingLogViewModel {
        CravingLogViewModel(logCravingUseCase: logCravingUseCase)
    }

    func makeRecordingLibraryViewModel() -> RecordingLibraryViewModel {
        RecordingLibraryViewModel(
            fetchUseCase: fetchRecordingsUseCase,
            deleteUseCase: deleteRecordingUseCase
        )
    }

    func makeAudioRecordingViewModel() -> AudioRecordingViewModel {
        AudioRecordingViewModel(saveUseCase: saveRecordingUseCase)
    }

    func makeVideoRecordingViewModel() -> VideoRecordingViewModel {
        VideoRecordingViewModel(saveUseCase: saveRecordingUseCase)
    }

    func makeQuickPlayViewModel() -> QuickPlayViewModel {
        QuickPlayViewModel(fetchUseCase: fetchRecordingsUseCase)
    }

    // MARK: - Initialization

    init(isPreview: Bool = false) {
        do {
            self.modelContainer = if isPreview {
                try ModelContainerSetup.createPreview()
            } else {
                try ModelContainerSetup.create()
            }
            self.modelContext = ModelContext(modelContainer)
            self.fileStorage = FileStorageManager.shared

            // Initialize repositories
            let cravingRepo = CravingRepository(modelContext: modelContext)
            let recordingRepo = RecordingRepository(
                modelContext: modelContext,
                fileManager: fileStorage
            )
            let messageRepo = StubMessageRepository()

            self.cravingRepository = cravingRepo
            self.recordingRepository = recordingRepo
            self.messageRepository = messageRepo

            // Initialize use cases
            self.logCravingUseCase = DefaultLogCravingUseCase(repository: cravingRepo)
            self.fetchCravingsUseCase = DefaultFetchCravingsUseCase(repository: cravingRepo)
            self.saveRecordingUseCase = DefaultSaveRecordingUseCase(repository: recordingRepo)
            self.fetchRecordingsUseCase = DefaultFetchRecordingsUseCase(repository: recordingRepo)
            self.playRecordingUseCase = DefaultPlayRecordingUseCase(repository: recordingRepo)
            self.deleteRecordingUseCase = DefaultDeleteRecordingUseCase(repository: recordingRepo)

            if !isPreview {
                ModelContainerSetup.seedDefaultMessages(context: modelContext)
            }
        } catch {
            fatalError("Failed to initialize DependencyContainer: \(error)")
        }
    }
}

// MARK: - Preview Container

extension DependencyContainer {
    static var preview: DependencyContainer {
        DependencyContainer(isPreview: true)
    }
}

// MARK: - Stub Implementations (Temporary)

private struct StubMessageRepository: MessageRepositoryProtocol {
    func save(_ message: MotivationalMessageEntity) async throws { }
    func fetchActive() async throws -> [MotivationalMessageEntity] { return [] }
    func fetch(byCategory category: MessageCategory) async throws -> [MotivationalMessageEntity] { return [] }
    func delete(id: UUID) async throws { }
    func update(_ message: MotivationalMessageEntity) async throws { }
    func seedDefaultMessagesIfNeeded() async throws { }
}
```
</details>

**Why This Section:**
- **Compilation Safety:** Step 2a breaks the stub - this section tells implementers exactly when/how to fix it
- **Factory Pattern:** Documents all required ViewModel factories referenced throughout Steps 11-19
- **Clean DI:** Follows established pattern from PHASE_1.md and PHASE_2.md
- **Complete Picture:** Shows full container after all changes (expandable section for reference)

---

### Step 6: Create AudioRecordingCoordinator (Presentation Layer)

**File:** `Cravey/Presentation/Coordinators/AudioRecordingCoordinator.swift`

**Purpose:** Wraps AVAudioRecorder with @Observable state for SwiftUI.

```swift
import Foundation
import AVFoundation
import Observation

/// Coordinator for audio recording using AVAudioRecorder
@Observable
@MainActor
final class AudioRecordingCoordinator: NSObject {
    // State
    var isRecording = false
    var duration: TimeInterval = 0
    var currentFileURL: String?  // ← Relative path (matches baseline naming)
    var error: String?
    var didAutoStop = false  // ← Flag to notify ViewModel of forced stop

    // AVFoundation
    private var audioRecorder: AVAudioRecorder?
    private var recordingTimer: Timer?

    // MARK: - Recording

    func startRecording(recordingID: UUID) async throws {
        // 1. Request microphone permission (closure-based API, wrapped in continuation)
        let granted = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        guard granted else {
            throw RecordingError.permissionDenied
        }

        // 2. Configure audio session
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default)
        try session.setActive(true)

        // 3. Generate file URL
        let fileName = "audio_\(recordingID.uuidString).m4a"
        let recordingsDir = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("Recordings")

        // Create directory if needed
        try FileManager.default.createDirectory(
            at: recordingsDir,
            withIntermediateDirectories: true
        )

        let fileURL = recordingsDir.appendingPathComponent(fileName)

        // 4. Configure recorder settings
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        // 5. Start recording
        audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.record()

        // 6. Update state
        isRecording = true
        currentFileURL = "Recordings/\(fileName)"  // ← Store relative path
        duration = 0
        didAutoStop = false

        // 7. Start timer for duration tracking
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let recorder = self?.audioRecorder else { return }
                self?.duration = recorder.currentTime

                // Auto-stop at 120 seconds (notify ViewModel via didAutoStop flag)
                if self?.duration ?? 0 >= 120 {
                    self?.didAutoStop = true
                    self?.stopRecording()
                }
            }
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecording = false

        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    func cancelRecording() {
        stopRecording()

        // Delete file
        if let fileURL = currentFileURL {
            let fullURL = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )[0].appendingPathComponent(fileURL)
            try? FileManager.default.removeItem(at: fullURL)
        }

        currentFileURL = nil
        duration = 0
        didAutoStop = false
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioRecordingCoordinator: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(
        _ recorder: AVAudioRecorder,
        successfully flag: Bool
    ) {
        Task { @MainActor in
            if !flag {
                error = "Recording failed"
                currentFileURL = nil
            }
        }
    }

    nonisolated func audioRecorderEncodeErrorDidOccur(
        _ recorder: AVAudioRecorder,
        error: Error?
    ) {
        Task { @MainActor in
            self.error = error?.localizedDescription ?? "Encoding error"
        }
    }
}
```

**Why This Code:**
- `@Observable` enables SwiftUI state updates
- **CRITICAL:** Uses `async/await` for permission request (MUST await before configuring audio session)
- `currentFileURL` property matches baseline naming (not `filePath`)
- `didAutoStop` flag notifies ViewModel when 120s auto-stop occurs (triggers save sheet UX)
- Auto-stop at 120 seconds (MVP requirement)
- Timer tracks duration for UI display
- Relative file URL stored (consistent with RecordingEntity.fileURL)
- Delegate pattern for error handling

---

### Step 7: Create VideoRecordingCoordinator (Presentation Layer)

**File:** `Cravey/Presentation/Coordinators/VideoRecordingCoordinator.swift`

**Purpose:** Wraps AVCaptureSession for video recording + thumbnail generation.

```swift
import Foundation
import AVFoundation
import UIKit
import Observation

/// Coordinator for video recording using AVCaptureSession
@Observable
@MainActor
final class VideoRecordingCoordinator: NSObject {
    // State
    var isRecording = false
    var duration: TimeInterval = 0
    var currentFileURL: String?  // ← Relative path (matches baseline naming)
    var currentThumbnailURL: String?  // ← Relative path (matches baseline naming)
    var error: String?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var didAutoStop = false  // ← Flag to notify ViewModel of forced stop

    // AVFoundation
    private var captureSession: AVCaptureSession?
    private var movieOutput: AVCaptureMovieFileOutput?
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?

    // MARK: - Setup

    func setupCamera() async throws {
        // Request camera permission
        let status = await AVCaptureDevice.requestAccess(for: .video)
        guard status else {
            error = "Camera access denied"
            return
        }

        // Create capture session
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .high

        // Add video input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: camera) else {
            error = "Camera not available"
            return
        }

        guard session.canAddInput(videoInput) else {
            error = "Cannot add video input"
            return
        }
        session.addInput(videoInput)

        // Add audio input
        if let microphone = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: microphone),
           session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }

        // Add movie output
        let output = AVCaptureMovieFileOutput()
        guard session.canAddOutput(output) else {
            error = "Cannot add movie output"
            return
        }
        session.addOutput(output)

        session.commitConfiguration()

        // Create preview layer
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill

        // Update state
        captureSession = session
        movieOutput = output
        previewLayer = preview

        // Start session
        session.startRunning()
    }

    // MARK: - Recording

    func startRecording(recordingID: UUID) {
        guard let output = movieOutput else {
            error = "Camera not ready"
            return
        }

        // Generate file path
        let fileName = "video_\(recordingID.uuidString).mov"
        let recordingsDir = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("Recordings")

        // Create directory if needed
        try? FileManager.default.createDirectory(
            at: recordingsDir,
            withIntermediateDirectories: true
        )

        let fileURL = recordingsDir.appendingPathComponent(fileName)

        // Start recording
        output.startRecording(to: fileURL, recordingDelegate: self)

        // Update state
        isRecording = true
        currentFileURL = "Recordings/\(fileName)"
        duration = 0
        recordingStartTime = Date()
        didAutoStop = false

        // Start timer for duration tracking
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let startTime = self?.recordingStartTime else { return }
                self?.duration = Date().timeIntervalSince(startTime)

                // Auto-stop at 120 seconds (notify ViewModel via didAutoStop flag)
                if self?.duration ?? 0 >= 120 {
                    self?.didAutoStop = true
                    self?.stopRecording()
                }
            }
        }
    }

    func stopRecording() {
        movieOutput?.stopRecording()
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecording = false
    }

    func cancelRecording() {
        stopRecording()

        // Delete file
        if let fileURL = currentFileURL {
            let fullURL = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )[0].appendingPathComponent(fileURL)
            try? FileManager.default.removeItem(at: fullURL)
        }

        currentFileURL = nil
        currentThumbnailURL = nil
        duration = 0
        didAutoStop = false
    }

    func stopCamera() {
        captureSession?.stopRunning()
        captureSession = nil
        movieOutput = nil
        previewLayer = nil
    }

    // MARK: - Thumbnail Generation

    private func generateThumbnail(for videoURL: URL, recordingID: UUID) async {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        do {
            // Generate image at 1 second mark
            let time = CMTime(seconds: 1, preferredTimescale: 60)
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)

            // Save thumbnail to disk
            let thumbnailDir = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )[0].appendingPathComponent("Recordings/Thumbnails")

            try? FileManager.default.createDirectory(
                at: thumbnailDir,
                withIntermediateDirectories: true
            )

            let thumbnailFileName = "video_\(recordingID.uuidString)_thumb.jpg"
            let thumbnailURL = thumbnailDir.appendingPathComponent(thumbnailFileName)

            if let jpegData = thumbnail.jpegData(compressionQuality: 0.8) {
                try jpegData.write(to: thumbnailURL)
                currentThumbnailURL = "Recordings/Thumbnails/\(thumbnailFileName)"
            }
        } catch {
            print("Thumbnail generation failed: \(error)")
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension VideoRecordingCoordinator: AVCaptureFileOutputRecordingDelegate {
    nonisolated func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        Task { @MainActor in
            if let error = error {
                self.error = error.localizedDescription
                currentFileURL = nil
                return
            }

            // Generate thumbnail
            if let fileURL = currentFileURL {
                let recordingID = UUID(uuidString: fileURL.components(separatedBy: "_")[1].replacingOccurrences(of: ".mov", with: "")) ?? UUID()
                await generateThumbnail(for: outputFileURL, recordingID: recordingID)
            }
        }
    }
}
```

**Why This Code:**
- Front camera default (users record themselves)
- Audio + video inputs for full recordings
- AVCaptureMovieFileOutput for .mov files
- `currentFileURL` and `currentThumbnailURL` properties match baseline naming (not `filePath`/`thumbnailPath`)
- `didAutoStop` flag notifies ViewModel when 120s auto-stop occurs (triggers save sheet UX)
- Auto-stop at 120 seconds (MVP requirement)
- Thumbnail generation at 1-second mark (preview images for library)
- Delegate pattern for completion handling
- Permission already uses async/await (setupCamera is async)

---

### Step 8: Create RecordingLibraryViewModel (Presentation Layer)

**File:** `Cravey/Presentation/ViewModels/RecordingLibraryViewModel.swift`

```swift
import Foundation
import Observation

/// ViewModel for Recordings Library screen
@Observable
@MainActor
final class RecordingLibraryViewModel {
    // State
    var recordings: [RecordingEntity] = []
    var isLoading = false
    var error: String?
    var selectedFilter: RecordingFilter = .all

    // Dependencies
    private let fetchUseCase: FetchRecordingsUseCase
    private let deleteUseCase: DeleteRecordingUseCase

    init(
        fetchUseCase: FetchRecordingsUseCase,
        deleteUseCase: DeleteRecordingUseCase
    ) {
        self.fetchUseCase = fetchUseCase
        self.deleteUseCase = deleteUseCase
    }

    // MARK: - Actions

    func loadRecordings() async {
        isLoading = true
        error = nil

        do {
            // Convert filter to RecordingType enum
            let typeFilter: RecordingType? = {
                switch selectedFilter {
                case .all: return nil
                case .video: return .video
                case .audio: return .audio
                }
            }()
            recordings = try await fetchUseCase.execute(recordingType: typeFilter)
        } catch {
            self.error = "Failed to load recordings: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func deleteRecording(_ recording: RecordingEntity) async {
        do {
            try await deleteUseCase.execute(id: recording.id)  // ← Use id parameter
            recordings.removeAll { $0.id == recording.id }
        } catch {
            self.error = "Failed to delete recording: \(error.localizedDescription)"
        }
    }

    func filterChanged(to filter: RecordingFilter) async {
        selectedFilter = filter
        await loadRecordings()
    }
}

enum RecordingFilter: String, CaseIterable {
    case all = "all"
    case video = "video"
    case audio = "audio"

    var displayName: String {
        switch self {
        case .all: return "All"
        case .video: return "Videos"
        case .audio: return "Audio"
        }
    }
}
```

**Why This Code:**
- `@Observable` for SwiftUI reactivity
- Filter state (`all`, `video`, `audio`)
- Async/await for use case calls
- Error handling with user-facing messages

---

## WEEK 6: Playback + Library UI + Quick Play

### Step 9: Create AudioRecordingViewModel (Presentation Layer)

**File:** `Cravey/Presentation/ViewModels/AudioRecordingViewModel.swift`

```swift
import Foundation
import Observation

/// ViewModel for audio recording flow
@Observable
@MainActor
final class AudioRecordingViewModel {
    // State
    var isRecording = false
    var duration: TimeInterval = 0
    var error: String?
    var showSaveDialog = false
    var title: String = ""
    var notes: String = ""
    var selectedPurpose: RecordingPurpose = .motivational

    // Coordinator
    let coordinator = AudioRecordingCoordinator()

    // Dependencies
    private let saveUseCase: SaveRecordingUseCase
    private var currentRecordingID: UUID?  // ← Generate fresh UUID per recording

    init(saveUseCase: SaveRecordingUseCase) {
        self.saveUseCase = saveUseCase
    }

    // MARK: - Actions

    func startRecording() async {
        // Generate new UUID for THIS recording session
        currentRecordingID = UUID()

        do {
            try await coordinator.startRecording(recordingID: currentRecordingID!)
            isRecording = coordinator.isRecording
        } catch {
            self.error = "Failed to start recording: \(error.localizedDescription)"
            currentRecordingID = nil
        }
    }

    func stopRecording() {
        coordinator.stopRecording()
        isRecording = false
        duration = coordinator.duration

        // Check if auto-stopped (120s limit reached)
        if coordinator.didAutoStop {
            showSaveDialog = true  // Still show save dialog on forced stop
        } else {
            showSaveDialog = true
        }
    }

    func cancelRecording() {
        coordinator.cancelRecording()
        isRecording = false
        duration = 0
        error = nil
        currentRecordingID = nil  // ← Clear UUID after cancel
    }

    func saveRecording() async -> Bool {
        guard let fileURL = coordinator.currentFileURL else {
            error = "No recording to save"
            return false
        }

        do {
            _ = try await saveUseCase.execute(
                recordingType: .audio,  // ← RecordingType enum
                purpose: selectedPurpose,  // ← RecordingPurpose enum (already correct type)
                duration: duration,
                fileURL: fileURL,  // ← Correct property name
                thumbnailURL: nil,  // ← Correct property name
                title: title.isEmpty ? "Audio Recording" : title,  // ← Required parameter
                notes: notes.isEmpty ? nil : notes
            )

            // Clear UUID after successful save
            currentRecordingID = nil
            return true
        } catch {
            self.error = "Failed to save recording: \(error.localizedDescription)"
            return false
        }
    }
}

// Note: RecordingPurpose enum is defined in Domain/Entities/RecordingEntity.swift
// This is just a reference for the ViewModel's selectedPurpose property
// Actual enum case: .cravingMoment (not .craving)
```

**Why This Code:**
- Wraps coordinator state for SwiftUI
- **CRITICAL FIX:** `currentRecordingID` generates fresh UUID per recording (prevents file collisions)
- `startRecording()` is `async` to await coordinator permission handling
- `stopRecording()` checks `coordinator.didAutoStop` flag (auto-stop UX)
- Save uses `recordingType: .audio` enum (not String)
- Save uses `fileURL`/`thumbnailURL` properties (matches baseline)
- RecordingPurpose enum is imported from Domain layer (use `.cravingMoment` not `.craving`)
- Returns Bool from saveRecording() for navigation control

---

### Step 10: Create VideoRecordingViewModel (Presentation Layer)

**File:** `Cravey/Presentation/ViewModels/VideoRecordingViewModel.swift`

```swift
import Foundation
import Observation

/// ViewModel for video recording flow
@Observable
@MainActor
final class VideoRecordingViewModel {
    // State
    var isRecording = false
    var duration: TimeInterval = 0
    var error: String?
    var showSaveDialog = false
    var title: String = ""
    var notes: String = ""
    var selectedPurpose: RecordingPurpose = .motivational
    var isCameraReady = false

    // Coordinator
    let coordinator = VideoRecordingCoordinator()

    // Dependencies
    private let saveUseCase: SaveRecordingUseCase
    private var currentRecordingID: UUID?  // ← Generate fresh UUID per recording

    init(saveUseCase: SaveRecordingUseCase) {
        self.saveUseCase = saveUseCase
    }

    // MARK: - Lifecycle

    func setupCamera() async {
        do {
            try await coordinator.setupCamera()
            isCameraReady = coordinator.previewLayer != nil
        } catch {
            self.error = "Failed to setup camera: \(error.localizedDescription)"
        }
    }

    func teardownCamera() {
        coordinator.stopCamera()
        isCameraReady = false
    }

    // MARK: - Actions

    func startRecording() {
        // Generate new UUID for THIS recording session
        currentRecordingID = UUID()
        coordinator.startRecording(recordingID: currentRecordingID!)
        isRecording = coordinator.isRecording
    }

    func stopRecording() {
        coordinator.stopRecording()
        isRecording = false
        duration = coordinator.duration

        // Check if auto-stopped (120s limit reached)
        if coordinator.didAutoStop {
            showSaveDialog = true  // Still show save dialog on forced stop
        } else {
            showSaveDialog = true
        }
    }

    func cancelRecording() {
        coordinator.cancelRecording()
        isRecording = false
        duration = 0
        error = nil
        currentRecordingID = nil  // ← Clear UUID after cancel
    }

    func saveRecording() async -> Bool {
        guard let fileURL = coordinator.currentFileURL else {
            error = "No recording to save"
            return false
        }

        do {
            _ = try await saveUseCase.execute(
                recordingType: .video,  // ← RecordingType enum
                purpose: selectedPurpose,  // ← RecordingPurpose enum
                duration: duration,
                fileURL: fileURL,  // ← Correct property name
                thumbnailURL: coordinator.currentThumbnailURL,  // ← Correct property name
                title: title.isEmpty ? "Video Recording" : title,  // ← Required parameter
                notes: notes.isEmpty ? nil : notes
            )

            // Clear UUID after successful save
            currentRecordingID = nil
            return true
        } catch {
            self.error = "Failed to save recording: \(error.localizedDescription)"
            return false
        }
    }
}
```

**Why This Code:**
- Identical pattern to AudioRecordingViewModel (consistency)
- **CRITICAL FIX:** `currentRecordingID` generates fresh UUID per recording (prevents file collisions)
- `stopRecording()` checks `coordinator.didAutoStop` flag (auto-stop UX)
- Save uses `recordingType: .video` enum (not String)
- Save uses `fileURL`/`thumbnailURL` properties (matches baseline)
- Camera lifecycle management (setup/teardown)
- Async camera setup for permission handling

---

### Step 11: Create RecordingsLibraryView (Presentation Layer)

**File:** `Cravey/Presentation/Views/Recordings/RecordingsLibraryView.swift`

**Purpose:** Main Recordings tab UI with filter, list, and playback.

```swift
import SwiftUI

struct RecordingsLibraryView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: RecordingLibraryViewModel?
    @State private var showRecordingMode = false

    init() {
        // ViewModel will be created in .task using container factory method
    }

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    VStack(spacing: 0) {
                        // Filter Picker
                        Picker("Filter", selection: Binding(
                            get: { viewModel.selectedFilter },
                            set: { filter in
                                Task {
                                    await viewModel.filterChanged(to: filter)
                                }
                            }
                        )) {
                            ForEach(RecordingFilter.allCases, id: \.self) { filter in
                                Text(filter.displayName).tag(filter)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()

                        // Recordings List
                        if viewModel.isLoading {
                            ProgressView("Loading recordings...")
                                .frame(maxHeight: .infinity)
                        } else if viewModel.recordings.isEmpty {
                            emptyState
                        } else {
                            recordingsList(viewModel: viewModel)
                        }
                    }
                    .alert("Error", isPresented: Binding(
                        get: { viewModel.error != nil },
                        set: { if !$0 { viewModel.error = nil } }
                    )) {
                        Button("OK") { viewModel.error = nil }
                    } message: {
                        Text(viewModel.error ?? "")
                    }
                } else {
                    ProgressView("Initializing...")
                }
            }
            .navigationTitle("Recordings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showRecordingMode = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showRecordingMode) {
                RecordingModeView()
            }
            .task {
                // Initialize ViewModel from container
                if viewModel == nil {
                    viewModel = container.makeRecordingLibraryViewModel()
                }
                await viewModel?.loadRecordings()
            }
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "video.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Recordings Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Tap + to record your first motivational message")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                showRecordingMode = true
            } label: {
                Label("Record Now", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .frame(maxHeight: .infinity)
    }

    private func recordingsList(viewModel: RecordingLibraryViewModel) -> some View {
        List {
            ForEach(viewModel.recordings, id: \.id) { recording in
                RecordingRow(recording: recording)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteRecording(recording)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Recording Row

struct RecordingRow: View {
    let recording: RecordingEntity

    var body: some View {
        NavigationLink {
            if recording.recordingType == .video {
                VideoPlayerView(recording: recording)
            } else {
                AudioPlayerView(recording: recording)
            }
        } label: {
            HStack(spacing: 12) {
                // Thumbnail or icon
                if let thumbnailURL = recording.thumbnailURL {
                    AsyncImage(url: thumbnailFullURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.2))
                        Image(systemName: recording.recordingType == .video ? "video.fill" : "waveform")
                            .foregroundStyle(.blue)
                    }
                    .frame(width: 60, height: 60)
                }

                // Metadata
                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.title)  // ← title is required in baseline
                        .font(.headline)

                    HStack(spacing: 8) {
                        Label(formatDuration(recording.duration), systemImage: "clock")
                        Label("\(recording.playCount)", systemImage: "play.fill")
                        Text(recording.purpose.rawValue.capitalized)  // ← purpose is enum
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }

    private var thumbnailFullURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(recording.thumbnailURL ?? "")
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
```

**Why This Code:**
- Segmented picker for filter (All/Videos/Audio)
- Empty state with CTA for first recording
- Swipe-to-delete pattern (iOS standard)
- Thumbnail display for videos
- Navigation to player views

---

### Step 12: Create RecordingModeView (Presentation Layer)

**File:** `Cravey/Presentation/Views/Recordings/RecordingModeView.swift`

```swift
import SwiftUI

struct RecordingModeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAudioRecording = false
    @State private var showVideoRecording = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("What would you like to record?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)

                VStack(spacing: 24) {
                    // Audio Option
                    Button {
                        showAudioRecording = true
                    } label: {
                        RecordingModeCard(
                            icon: "waveform",
                            title: "Audio Recording",
                            description: "Record your voice (up to 2 minutes)"
                        )
                    }
                    .buttonStyle(.plain)

                    // Video Option
                    Button {
                        showVideoRecording = true
                    } label: {
                        RecordingModeCard(
                            icon: "video.fill",
                            title: "Video Recording",
                            description: "Record yourself (up to 2 minutes)"
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("New Recording")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showAudioRecording) {
                AudioRecordingView()
            }
            .fullScreenCover(isPresented: $showVideoRecording) {
                VideoRecordingView()
            }
        }
    }
}

struct RecordingModeCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 60, height: 60)
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        )
    }
}
```

**Why This Code:**
- Modal sheet presentation from library
- Clear choice between audio/video
- Card-based UI pattern (clean, modern)
- Full-screen cover for recording views (immersive)

---

### Step 13: Create AudioRecordingView (Presentation Layer)

**File:** `Cravey/Presentation/Views/Recordings/AudioRecordingView.swift`

```swift
import SwiftUI

struct AudioRecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: AudioRecordingViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    audioRecordingContent(viewModel: viewModel)
                } else {
                    ProgressView("Initializing...")
                }
            }
            .task {
                if viewModel == nil {
                    viewModel = container.makeAudioRecordingViewModel()
                }
            }
        }
    }

    @ViewBuilder
    private func audioRecordingContent(viewModel: AudioRecordingViewModel) -> some View {
        VStack(spacing: 32) {
                // Waveform visualization (placeholder)
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 200, height: 200)

                    Image(systemName: viewModel.isRecording ? "waveform" : "mic.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                        .symbolEffect(.pulse, isActive: viewModel.isRecording)
                }
                .padding(.top, 60)

                // Duration
                Text(formatDuration(viewModel.coordinator.duration))
                    .font(.system(size: 48, weight: .semibold, design: .rounded))
                    .monospacedDigit()

                Text(viewModel.isRecording ? "Recording..." : "Ready to record")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                // Controls
                HStack(spacing: 40) {
                    // Cancel button
                    if viewModel.isRecording {
                        Button {
                            viewModel.cancelRecording()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.red)
                        }
                    }

                    // Record/Stop button
                    Button {
                        if viewModel.isRecording {
                            viewModel.stopRecording()
                        } else {
                            Task {
                                await viewModel.startRecording()  // ← Async method
                            }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(viewModel.isRecording ? Color.red : Color.blue)
                                .frame(width: 80, height: 80)

                            if viewModel.isRecording {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white)
                                    .frame(width: 30, height: 30)
                            } else {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                }
                .padding(.bottom, 60)
            }
            .navigationTitle("Audio Recording")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.cancelRecording()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showSaveDialog) {
                SaveRecordingSheet(
                    title: $viewModel.title,
                    notes: $viewModel.notes,
                    purpose: $viewModel.selectedPurpose,
                    duration: viewModel.duration
                ) {
                    Task {
                        let success = await viewModel.saveRecording()
                        if success {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error ?? "")
            }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
```

**Why This Code:**
- Waveform icon with pulse animation (visual feedback)
- Large duration display (easy to see while recording)
- Red circle = stop (standard iOS pattern)
- Blue circle = start (standard iOS pattern)
- Save sheet appears after stopping

---

### Step 14: Create VideoRecordingView (Presentation Layer)

**File:** `Cravey/Presentation/Views/Recordings/VideoRecordingView.swift`

```swift
import SwiftUI
import AVFoundation

struct VideoRecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: VideoRecordingViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    videoRecordingContent(viewModel: viewModel)
                } else {
                    Color.black.ignoresSafeArea()
                    ProgressView("Initializing camera...")
                }
            }
            .task {
                if viewModel == nil {
                    viewModel = container.makeVideoRecordingViewModel()
                }
                await viewModel?.setupCamera()
            }
            .onDisappear {
                viewModel?.teardownCamera()
            }
        }
    }

    @ViewBuilder
    private func videoRecordingContent(viewModel: VideoRecordingViewModel) -> some View {
        ZStack {
            // Camera preview
            if viewModel.isCameraReady, let previewLayer = viewModel.coordinator.previewLayer {
                CameraPreview(previewLayer: previewLayer)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
                ProgressView("Loading camera...")
            }

                // Overlay UI
                VStack {
                    // Top bar with duration
                    if viewModel.isRecording {
                        HStack {
                            Circle()
                                .fill(.red)
                                .frame(width: 12, height: 12)
                            Text(formatDuration(viewModel.coordinator.duration))
                                .font(.headline)
                                .monospacedDigit()
                            Spacer()
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                    }

                    Spacer()

                    // Bottom controls
                    HStack(spacing: 40) {
                        // Cancel button
                        if viewModel.isRecording {
                            Button {
                                viewModel.cancelRecording()
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.white)
                            }
                        }

                        // Record/Stop button
                        Button {
                            if viewModel.isRecording {
                                viewModel.stopRecording()
                            } else {
                                viewModel.startRecording()
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(viewModel.isRecording ? Color.red : Color.white)
                                    .frame(width: 80, height: 80)

                                if viewModel.isRecording {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.white)
                                        .frame(width: 30, height: 30)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
            .navigationTitle("Video Recording")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.cancelRecording()
                        viewModel.teardownCamera()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showSaveDialog) {
                SaveRecordingSheet(
                    title: $viewModel.title,
                    notes: $viewModel.notes,
                    purpose: $viewModel.selectedPurpose,
                    duration: viewModel.duration
                ) {
                    Task {
                        let success = await viewModel.saveRecording()
                        if success {
                            viewModel.teardownCamera()
                            dismiss()
                        }
                    }
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error ?? "")
            }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Camera Preview (UIViewRepresentable)

struct CameraPreview: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        previewLayer.frame = uiView.bounds
    }
}
```

**Why This Code:**
- Full-screen camera preview (immersive)
- Recording indicator (red dot + duration)
- White/red button toggle (standard iOS pattern)
- Camera lifecycle tied to view lifecycle

---

### Step 15: Create SaveRecordingSheet (Shared Component)

**File:** `Cravey/Presentation/Views/Recordings/SaveRecordingSheet.swift`

```swift
import SwiftUI

struct SaveRecordingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var title: String
    @Binding var notes: String
    @Binding var purpose: RecordingPurpose
    let duration: TimeInterval
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title (optional)", text: $title)

                    Picker("Purpose", selection: $purpose) {
                        ForEach(RecordingPurpose.allCases, id: \.self) { purpose in
                            Text(purpose.rawValue)
                                .tag(purpose)
                        }
                    }
                    .pickerStyle(.menu)

                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }

                Section {
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(formatDuration(duration))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Save Recording")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                }
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
```

**Why This Code:**
- Uses `RecordingPurpose` enum from Domain layer (RecordingEntity.swift)
- **IMPORTANT:** RecordingPurpose has `.cravingMoment` case (not `.craving`)
- Form-based UI (iOS standard for data entry)
- Optional title and notes
- Purpose picker with descriptions
- Duration display (read-only, calculated from recording)

---

### Step 16: Create QuickPlaySection (Home Tab Integration)

**File:** `Cravey/Presentation/Views/Home/QuickPlaySection.swift`

```swift
import SwiftUI

struct QuickPlaySection: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: QuickPlayViewModel?

    var body: some View {
        Group {
            if let viewModel = viewModel {
                quickPlayContent(viewModel: viewModel)
            } else {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = container.makeQuickPlayViewModel()
            }
            await viewModel?.loadTopRecordings()
        }
    }

    @ViewBuilder
    private func quickPlayContent(viewModel: QuickPlayViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Quick Play")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                NavigationLink {
                    RecordingsLibraryView()
                } label: {
                    Text("See All")
                        .font(.subheadline)
                }
            }

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
            } else if viewModel.topRecordings.isEmpty {
                emptyState
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.topRecordings, id: \.id) { recording in
                            RecordingCard(recording: recording)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "video.badge.plus")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No recordings yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            NavigationLink {
                RecordingModeView()
            } label: {
                Text("Create First Recording")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
    }
}

struct RecordingCard: View {
    let recording: RecordingEntity

    var body: some View {
        NavigationLink {
            if recording.recordingType == .video {
                VideoPlayerView(recording: recording)
            } else {
                AudioPlayerView(recording: recording)
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                // Thumbnail
                if let thumbnailURL = recording.thumbnailURL {
                    AsyncImage(url: thumbnailFullURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 140, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.2))
                        Image(systemName: "waveform")
                            .font(.largeTitle)
                            .foregroundStyle(.blue)
                    }
                    .frame(width: 140, height: 100)
                }

                // Metadata
                Text(recording.title)  // ← title is required
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                HStack {
                    Label("\(recording.playCount)", systemImage: "play.fill")
                    Spacer()
                    Text(formatDuration(recording.duration))
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .frame(width: 140)
        }
        .buttonStyle(.plain)
    }

    private var thumbnailFullURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(recording.thumbnailURL ?? "")
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

@Observable
@MainActor
final class QuickPlayViewModel {
    var topRecordings: [RecordingEntity] = []
    var isLoading = false

    private let fetchUseCase: FetchRecordingsUseCase

    init(fetchUseCase: FetchRecordingsUseCase) {
        self.fetchUseCase = fetchUseCase
    }

    func loadTopRecordings() async {
        isLoading = true
        do {
            topRecordings = try await fetchUseCase.fetchTopPlayed(limit: 3)
        } catch {
            print("Failed to load top recordings: \(error)")
        }
        isLoading = false
    }
}
```

**Why This Code:**
- Horizontal scroll for Top 3 recordings
- Large thumbnails (easy tap targets)
- Play count badge (shows most-used recordings)
- Empty state with CTA to create first recording
- Direct navigation to player views

---

### Step 17: Create AudioPlayerView (Presentation Layer)

**File:** `Cravey/Presentation/Views/Recordings/AudioPlayerView.swift`

```swift
import SwiftUI
import AVKit

struct AudioPlayerView: View {
    @Environment(DependencyContainer.self) private var container
    let recording: RecordingEntity

    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var timeObserver: Any?

    var body: some View {
        VStack(spacing: 32) {
            // Waveform visualization
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 200, height: 200)

                Image(systemName: "waveform")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                    .symbolEffect(.pulse, isActive: isPlaying)
            }
            .padding(.top, 60)

            // Metadata
            VStack(spacing: 8) {
                Text(recording.title)  // ← title is required
                    .font(.title2)
                    .fontWeight(.bold)

                Text(recording.purpose.rawValue.capitalized)  // ← purpose is enum
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Progress bar
            VStack(spacing: 8) {
                Slider(
                    value: Binding(
                        get: { currentTime },
                        set: { newValue in
                            player?.seek(to: CMTime(seconds: newValue, preferredTimescale: 600))
                        }
                    ),
                    in: 0...recording.duration
                )

                HStack {
                    Text(formatTime(currentTime))
                    Spacer()
                    Text(formatTime(recording.duration))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            // Play/Pause button
            Button {
                if isPlaying {
                    player?.pause()
                } else {
                    player?.play()
                    // Increment play count on first play
                    Task {
                        _ = try? await container.playRecordingUseCase.execute(recording: recording)
                    }
                }
                isPlaying.toggle()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 80, height: 80)

                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                }
            }

            Spacer()
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            if let observer = timeObserver {
                player?.removeTimeObserver(observer)
            }
            player?.pause()
        }
    }

    private func setupPlayer() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(recording.fileURL)  // ← Correct property name

        player = AVPlayer(url: url)

        // Observe playback time
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            currentTime = time.seconds
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
```

**Why This Code:**
- AVPlayer for audio playback (native iOS framework)
- Waveform icon with pulse animation (visual feedback)
- Scrubber slider for seeking
- Play count increment on playback

---

### Step 18: Create VideoPlayerView (Presentation Layer)

**File:** `Cravey/Presentation/Views/Recordings/VideoPlayerView.swift`

```swift
import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @Environment(DependencyContainer.self) private var container
    let recording: RecordingEntity

    @State private var player: AVPlayer?
    @State private var hasPlayed = false

    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .onAppear {
                        // Increment play count
                        if !hasPlayed {
                            hasPlayed = true
                            Task {
                                _ = try? await container.playRecordingUseCase.execute(recording: recording)
                            }
                        }
                    }
            } else {
                ProgressView("Loading video...")
            }
        }
        .navigationTitle(recording.title)  // ← title is required
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
        }
    }

    private func setupPlayer() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(recording.fileURL)  // ← Correct property name

        player = AVPlayer(url: url)
    }
}
```

**Why This Code:**
- Native VideoPlayer (AVKit) with built-in controls
- Full-screen playback
- Play count increment on first view
- Pause on disappear (cleanup)

---

### Step 19: Update HomeView with Quick Play Section

**File:** `Cravey/Presentation/Views/HomeView.swift` (MODIFY)

**Add this section after the "Log Usage" card:**

```swift
// Quick Play Section (Top 3 Recordings)
QuickPlaySection()
```

**Why This Code:**
- Integrates recordings into Home tab
- Shows most-played recordings (user's favorites)
- Increases recording discoverability and usage
- QuickPlaySection handles its own DI via @Environment(DependencyContainer.self)

---

## ✅ Success Criteria & Validation

### Feature Checklist
- [ ] Audio recording works (AVAudioRecorder)
- [ ] Video recording works (AVCaptureSession + front camera)
- [ ] Recordings saved with metadata (type, purpose, duration, title, notes)
- [ ] Audio playback works (AVPlayer)
- [ ] Video playback works (VideoPlayer from AVKit)
- [ ] Thumbnails generated for videos (1-second mark)
- [ ] Quick Play section shows Top 3 recordings on Home tab
- [ ] Play count increments on playback
- [ ] Recordings library shows all recordings with filter (All/Videos/Audio)
- [ ] Swipe-to-delete works in library
- [ ] Files deleted when recording deleted (atomic operation)

### Performance Targets
- [ ] Recording starts in <1 second (permission granted)
- [ ] Auto-stop at 120 seconds (enforced)
- [ ] Playback starts in <1 second (local file)
- [ ] Library loads in <2 seconds (up to 100 recordings)

### Test Validation
- [ ] All 10 unit tests passing
- [ ] All 4 integration tests passing
- [ ] All 2 UI tests passing
- [ ] Build succeeds with zero warnings
- [ ] SwiftLint violations <10 warnings

---

## 📝 Completion Checklist

**Before marking Phase 4 complete:**

### Code
- [ ] All 18 files created/modified
- [ ] RecordingRepository stub replaced with real implementation
- [ ] DependencyContainer updated with real RecordingRepository
- [ ] All use cases injected via @Environment

### Tests
- [ ] All 16 tests written and passing
- [ ] Recording → save → fetch integration test passing
- [ ] Playback integration test passing
- [ ] UI test for recording flow passing

### Quality
- [ ] Build succeeds with zero warnings
- [ ] SwiftLint violations <10 warnings
- [ ] Code reviewed (Clean Architecture compliance)
- [ ] Dependency Rule verified (Domain → Data → Presentation)

### Manual Testing
- [ ] Audio recording tested on device
- [ ] Video recording tested on device (front camera)
- [ ] Thumbnail generation verified
- [ ] Playback tested (audio + video)
- [ ] Quick Play section appears on Home tab
- [ ] Delete recording removes file + DB entry

### Documentation
- [ ] Inline comments added for complex logic
- [ ] Git commit pushed (feature branch)
- [ ] Phase 4 marked complete in CHECKPOINT_STATUS.md

---

## 🚀 What's Next

After Phase 4 completion:

1. **Weeks 7-8: Dashboard** - Visualize craving/usage data with Swift Charts
2. **Weeks 9-12: Polish & Testing** - UI/UX refinement, accessibility, performance
3. **Weeks 13-16: Launch Prep** - TestFlight, App Store submission

---

**[← Back to Overview](./PHASE_OVERVIEW.md)** | **[← Phase 3 (Onboarding+Data)](./PHASE_3.md)** | **[Phase 5 (Dashboard) →](./PHASE_5.md)**

**Status:** 📝 Ready for Implementation - Week 5 starts with Step 1 (SaveRecordingUseCase)
