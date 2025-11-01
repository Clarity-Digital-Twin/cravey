# Phase 3: Recordings (Weeks 5-6)

**Version:** 1.0
**Duration:** 2 weeks (Weeks 5-6 of 16-week timeline)
**Dependencies:** Weeks 1-4 complete (Craving/Usage logging, Onboarding, Data Management)
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

**Purpose:** Business logic for saving recording metadata + file path validation.

```swift
import Foundation

/// Use case for saving a recording with metadata validation
protocol SaveRecordingUseCase: Sendable {
    func execute(
        type: String,
        purpose: String,
        duration: TimeInterval,
        filePath: String,
        thumbnailPath: String?,
        title: String?,
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
        type: String,
        purpose: String,
        duration: TimeInterval,
        filePath: String,
        thumbnailPath: String?,
        title: String?,
        notes: String?
    ) async throws -> RecordingEntity {
        // Validation: type must be "audio" or "video"
        guard type == "audio" || type == "video" else {
            throw RecordingError.invalidType
        }

        // Validation: duration must be ≤120 seconds
        guard duration > 0 && duration <= 120 else {
            throw RecordingError.invalidDuration
        }

        // Validation: purpose must be valid category
        let validPurposes = ["motivational", "milestone", "reflection", "craving"]
        guard validPurposes.contains(purpose) else {
            throw RecordingError.invalidPurpose
        }

        // Create entity
        let recording = RecordingEntity(
            id: UUID(),
            timestamp: Date(),
            type: type,
            purpose: purpose,
            duration: duration,
            filePath: filePath,
            thumbnailPath: thumbnailPath,
            title: title,
            notes: notes,
            playCount: 0,
            lastPlayedAt: nil
        )

        // Save to repository
        try await repository.save(recording)

        return recording
    }
}

enum RecordingError: Error {
    case invalidType
    case invalidDuration
    case invalidPurpose
    case fileNotFound
    case saveFailed
}
```

**Why This Code:**
- Type validation prevents invalid "audio"/"video" strings
- Duration validation enforces 2-minute max (MVP requirement)
- Purpose validation ensures category consistency
- Returns RecordingEntity for ViewModel use

---

### Step 2: Create FetchRecordingsUseCase (Domain Layer)

**File:** `Cravey/Domain/UseCases/FetchRecordingsUseCase.swift`

```swift
import Foundation

/// Use case for fetching recordings with optional filters
protocol FetchRecordingsUseCase: Sendable {
    func execute(type: String?) async throws -> [RecordingEntity]
    func fetchTopPlayed(limit: Int) async throws -> [RecordingEntity]
}

actor DefaultFetchRecordingsUseCase: FetchRecordingsUseCase {
    private let repository: RecordingRepositoryProtocol

    init(repository: RecordingRepositoryProtocol) {
        self.repository = repository
    }

    /// Fetch all recordings, optionally filtered by type
    func execute(type: String? = nil) async throws -> [RecordingEntity] {
        if let type = type {
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
- `execute(type:)` enables filtering by audio/video
- `fetchTopPlayed(limit:)` powers Quick Play section (Home tab)
- Sorting by playCount prioritizes user's favorite recordings

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
        // Increment play count and update timestamp
        var updatedRecording = recording
        updatedRecording.playCount += 1
        updatedRecording.lastPlayedAt = Date()

        // Save updated entity
        try await repository.update(updatedRecording)

        return updatedRecording
    }
}
```

**Why This Code:**
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
    func execute(recording: RecordingEntity) async throws
}

actor DefaultDeleteRecordingUseCase: DeleteRecordingUseCase {
    private let repository: RecordingRepositoryProtocol

    init(repository: RecordingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(recording: RecordingEntity) async throws {
        // Delete from repository (handles file deletion + DB removal)
        try await repository.delete(recording)
    }
}
```

**Why This Code:**
- Single responsibility: coordinate deletion
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
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map(RecordingMapper.toEntity)
    }

    // MARK: - Fetch by Type

    func fetch(byType type: String) async throws -> [RecordingEntity] {
        let descriptor = FetchDescriptor<RecordingModel>(
            predicate: #Predicate { $0.type == type },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
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
        existingModel.modifiedAt = Date()

        try modelContext.save()
    }

    // MARK: - Delete

    func delete(_ recording: RecordingEntity) async throws {
        // 1. Delete file from disk
        try fileManager.deleteRecording(
            filePath: recording.filePath,
            thumbnailPath: recording.thumbnailPath
        )

        // 2. Delete from database
        let descriptor = FetchDescriptor<RecordingModel>(
            predicate: #Predicate { $0.id == recording.id }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            throw RecordingError.fileNotFound
        }

        modelContext.delete(model)
        try modelContext.save()
    }
}
```

**Why This Code:**
- `nonisolated(unsafe)` for Swift 6 ModelContext access
- FileStorageManager handles file I/O (separation of concerns)
- `update()` only modifies mutable fields (playCount, lastPlayedAt, title, notes)
- `delete()` removes both file AND database entry (atomic operation)

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
    var currentFilePath: String?
    var error: String?

    // AVFoundation
    private var audioRecorder: AVAudioRecorder?
    private var recordingTimer: Timer?

    // MARK: - Recording

    func startRecording(recordingID: UUID) throws {
        // 1. Request microphone permission
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            guard granted else {
                Task { @MainActor in
                    self?.error = "Microphone access denied"
                }
                return
            }
        }

        // 2. Configure audio session
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default)
        try session.setActive(true)

        // 3. Generate file path
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
        currentFilePath = "Recordings/\(fileName)"
        duration = 0

        // 7. Start timer for duration tracking
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let recorder = self?.audioRecorder else { return }
                self?.duration = recorder.currentTime

                // Auto-stop at 120 seconds
                if self?.duration ?? 0 >= 120 {
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
        if let filePath = currentFilePath {
            let fileURL = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )[0].appendingPathComponent(filePath)
            try? FileManager.default.removeItem(at: fileURL)
        }

        currentFilePath = nil
        duration = 0
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
                currentFilePath = nil
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
- Permission handling for microphone access
- Auto-stop at 120 seconds (MVP requirement)
- Timer tracks duration for UI display
- Relative file path (consistent with RecordingModel)
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
    var currentFilePath: String?
    var currentThumbnailPath: String?
    var error: String?
    var previewLayer: AVCaptureVideoPreviewLayer?

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
        currentFilePath = "Recordings/\(fileName)"
        duration = 0
        recordingStartTime = Date()

        // Start timer for duration tracking
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let startTime = self?.recordingStartTime else { return }
                self?.duration = Date().timeIntervalSince(startTime)

                // Auto-stop at 120 seconds
                if self?.duration ?? 0 >= 120 {
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
        if let filePath = currentFilePath {
            let fileURL = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )[0].appendingPathComponent(filePath)
            try? FileManager.default.removeItem(at: fileURL)
        }

        currentFilePath = nil
        currentThumbnailPath = nil
        duration = 0
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
                currentThumbnailPath = "Recordings/Thumbnails/\(thumbnailFileName)"
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
                currentFilePath = nil
                return
            }

            // Generate thumbnail
            if let filePath = currentFilePath {
                let recordingID = UUID(uuidString: filePath.components(separatedBy: "_")[1].replacingOccurrences(of: ".mov", with: "")) ?? UUID()
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
- Auto-stop at 120 seconds (MVP requirement)
- Thumbnail generation at 1-second mark (preview images for library)
- Delegate pattern for completion handling

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
            let typeFilter = selectedFilter == .all ? nil : selectedFilter.rawValue
            recordings = try await fetchUseCase.execute(type: typeFilter)
        } catch {
            self.error = "Failed to load recordings: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func deleteRecording(_ recording: RecordingEntity) async {
        do {
            try await deleteUseCase.execute(recording: recording)
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
    private let recordingID = UUID()

    init(saveUseCase: SaveRecordingUseCase) {
        self.saveUseCase = saveUseCase
    }

    // MARK: - Actions

    func startRecording() {
        do {
            try coordinator.startRecording(recordingID: recordingID)
            isRecording = coordinator.isRecording
        } catch {
            self.error = "Failed to start recording: \(error.localizedDescription)"
        }
    }

    func stopRecording() {
        coordinator.stopRecording()
        isRecording = false
        duration = coordinator.duration
        showSaveDialog = true
    }

    func cancelRecording() {
        coordinator.cancelRecording()
        isRecording = false
        duration = 0
        error = nil
    }

    func saveRecording() async -> Bool {
        guard let filePath = coordinator.currentFilePath else {
            error = "No recording to save"
            return false
        }

        do {
            _ = try await saveUseCase.execute(
                type: "audio",
                purpose: selectedPurpose.rawValue,
                duration: duration,
                filePath: filePath,
                thumbnailPath: nil,
                title: title.isEmpty ? nil : title,
                notes: notes.isEmpty ? nil : notes
            )
            return true
        } catch {
            self.error = "Failed to save recording: \(error.localizedDescription)"
            return false
        }
    }
}

enum RecordingPurpose: String, CaseIterable {
    case motivational = "motivational"
    case milestone = "milestone"
    case reflection = "reflection"
    case craving = "craving"

    var displayName: String {
        switch self {
        case .motivational: return "Motivational"
        case .milestone: return "Milestone"
        case .reflection: return "Reflection"
        case .craving: return "During Craving"
        }
    }

    var description: String {
        switch self {
        case .motivational: return "Why you're taking a break"
        case .milestone: return "Celebrate progress (e.g., 30 days)"
        case .reflection: return "How you're feeling today"
        case .craving: return "Record during a craving moment"
        }
    }
}
```

**Why This Code:**
- Wraps coordinator state for SwiftUI
- Save dialog flow (title, notes, purpose)
- Purpose categorization (motivational, milestone, etc.)
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
    private let recordingID = UUID()

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
        coordinator.startRecording(recordingID: recordingID)
        isRecording = coordinator.isRecording
    }

    func stopRecording() {
        coordinator.stopRecording()
        isRecording = false
        duration = coordinator.duration
        showSaveDialog = true
    }

    func cancelRecording() {
        coordinator.cancelRecording()
        isRecording = false
        duration = 0
        error = nil
    }

    func saveRecording() async -> Bool {
        guard let filePath = coordinator.currentFilePath else {
            error = "No recording to save"
            return false
        }

        do {
            _ = try await saveUseCase.execute(
                type: "video",
                purpose: selectedPurpose.rawValue,
                duration: duration,
                filePath: filePath,
                thumbnailPath: coordinator.currentThumbnailPath,
                title: title.isEmpty ? nil : title,
                notes: notes.isEmpty ? nil : notes
            )
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
- Camera lifecycle management (setup/teardown)
- Includes thumbnailPath for video
- Async camera setup for permission handling

---

### Step 11: Create RecordingsLibraryView (Presentation Layer)

**File:** `Cravey/Presentation/Views/Recordings/RecordingsLibraryView.swift`

**Purpose:** Main Recordings tab UI with filter, list, and playback.

```swift
import SwiftUI

struct RecordingsLibraryView: View {
    @State private var viewModel: RecordingLibraryViewModel
    @State private var showRecordingMode = false

    var body: some View {
        NavigationStack {
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
                    recordingsList
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
                await viewModel.loadRecordings()
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

    private var recordingsList: some View {
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
            if recording.type == "video" {
                VideoPlayerView(recording: recording)
            } else {
                AudioPlayerView(recording: recording)
            }
        } label: {
            HStack(spacing: 12) {
                // Thumbnail or icon
                if let thumbnailPath = recording.thumbnailPath {
                    AsyncImage(url: thumbnailURL) { image in
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
                        Image(systemName: recording.type == "video" ? "video.fill" : "waveform")
                            .foregroundStyle(.blue)
                    }
                    .frame(width: 60, height: 60)
                }

                // Metadata
                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.title ?? "Untitled Recording")
                        .font(.headline)

                    HStack(spacing: 8) {
                        Label(formatDuration(recording.duration), systemImage: "clock")
                        Label("\(recording.playCount)", systemImage: "play.fill")
                        Text(recording.purpose.capitalized)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }

    private var thumbnailURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(recording.thumbnailPath ?? "")
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
    @Environment(\.saveRecordingUseCase) private var saveUseCase
    @State private var viewModel: AudioRecordingViewModel

    init() {
        // DI via @Environment happens after init, so we use placeholder
        _viewModel = State(initialValue: AudioRecordingViewModel(
            saveUseCase: PlaceholderSaveRecordingUseCase()
        ))
    }

    var body: some View {
        NavigationStack {
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
                            viewModel.startRecording()
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
            .onAppear {
                // Inject dependency from environment
                viewModel = AudioRecordingViewModel(saveUseCase: saveUseCase)
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
    @Environment(\.saveRecordingUseCase) private var saveUseCase
    @State private var viewModel: VideoRecordingViewModel

    init() {
        _viewModel = State(initialValue: VideoRecordingViewModel(
            saveUseCase: PlaceholderSaveRecordingUseCase()
        ))
    }

    var body: some View {
        NavigationStack {
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
            .task {
                viewModel = VideoRecordingViewModel(saveUseCase: saveUseCase)
                await viewModel.setupCamera()
            }
            .onDisappear {
                viewModel.teardownCamera()
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
                            VStack(alignment: .leading) {
                                Text(purpose.displayName)
                                Text(purpose.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(purpose)
                        }
                    }

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
    @State private var viewModel: QuickPlayViewModel

    var body: some View {
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
        .task {
            await viewModel.loadTopRecordings()
        }
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
            if recording.type == "video" {
                VideoPlayerView(recording: recording)
            } else {
                AudioPlayerView(recording: recording)
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                // Thumbnail
                if let thumbnailPath = recording.thumbnailPath {
                    AsyncImage(url: thumbnailURL) { image in
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
                Text(recording.title ?? "Untitled")
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

    private var thumbnailURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(recording.thumbnailPath ?? "")
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
    @Environment(\.playRecordingUseCase) private var playUseCase
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
                Text(recording.title ?? "Untitled Recording")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(recording.purpose.capitalized)
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
                        _ = try? await playUseCase.execute(recording: recording)
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
            .appendingPathComponent(recording.filePath)

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
    @Environment(\.playRecordingUseCase) private var playUseCase
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
                                _ = try? await playUseCase.execute(recording: recording)
                            }
                        }
                    }
            } else {
                ProgressView("Loading video...")
            }
        }
        .navigationTitle(recording.title ?? "Untitled")
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
            .appendingPathComponent(recording.filePath)

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
if let fetchRecordingsUseCase = container.fetchRecordingsUseCase {
    QuickPlaySection(
        viewModel: QuickPlayViewModel(fetchUseCase: fetchRecordingsUseCase)
    )
}
```

**Why This Code:**
- Integrates recordings into Home tab
- Shows most-played recordings (user's favorites)
- Increases recording discoverability and usage

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

**Before marking Phase 3 complete:**

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
- [ ] Phase 3 marked complete in CHECKPOINT_STATUS.md

---

## 🚀 What's Next

After Phase 3 completion:

1. **Weeks 7-8: Dashboard** - Visualize craving/usage data with Swift Charts
2. **Weeks 9-12: Polish & Testing** - UI/UX refinement, accessibility, performance
3. **Weeks 13-16: Launch Prep** - TestFlight, App Store submission

---

**[← Phase 2 (Week 2)](./PHASE_2.md)** | **[Phase Overview →](./PHASE_OVERVIEW.md)**

**Status:** 📝 Ready for Implementation - Week 5 starts with Step 1 (SaveRecordingUseCase)
