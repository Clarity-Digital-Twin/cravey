# Phase 3: Recordings

**Version:** 1.0 (Placeholder)
**Duration:** 2 weeks
**Dependencies:** Phase 1 (uses FileStorageManager)
**Status:** ⏳ Pending (starts after Phase 2 complete)

---

## 🎯 Phase Goal

**Shippable Deliverable:** Users can **record motivational content** (audio/video) and play it back during cravings.

**Feature Implemented:** Feature 3 (Recordings)

---

## 📦 Files to Create (13 files)

### Domain Layer (4 files)
- `Domain/UseCases/SaveRecordingUseCase.swift`
- `Domain/UseCases/FetchRecordingsUseCase.swift`
- `Domain/UseCases/PlayRecordingUseCase.swift`
- `Domain/UseCases/DeleteRecordingUseCase.swift`

### Data Layer (1 file)
- `Data/Repositories/RecordingRepository.swift` (stub → real)

### Presentation Layer (9 files)
- `Presentation/ViewModels/RecordingViewModel.swift`
- `Presentation/Views/Recordings/RecordingsLibraryView.swift`
- `Presentation/Views/Recordings/RecordingModeView.swift`
- `Presentation/Views/Recordings/AudioRecordingView.swift`
- `Presentation/Views/Recordings/VideoRecordingView.swift`
- `Presentation/Views/Recordings/RecordingPreviewView.swift`
- `Presentation/Views/Recordings/AudioPlayerView.swift`
- `Presentation/Views/Recordings/VideoPlayerView.swift`
- `Presentation/Views/Recordings/AudioRecordingCoordinator.swift`
- `Presentation/Views/Recordings/VideoRecordingCoordinator.swift`

---

## ✅ Success Criteria

- [ ] Audio recording works (AVAudioRecorder)
- [ ] Video recording works (AVCaptureSession)
- [ ] Recordings saved with metadata (title, purpose, duration)
- [ ] Playback works (audio + video)
- [ ] Quick Play section shows Top 3 recordings (Home tab)
- [ ] All tests passing (15 unit + 5 integration + 3 UI)

---

**Full implementation details will be added after Phase 2 completion.**

**[← Back to Overview](./PHASE_OVERVIEW.md)** | **[Phase 2 →](./PHASE_2.md)**
