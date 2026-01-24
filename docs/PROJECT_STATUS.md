# Cravey Project Status

**Last Updated:** 2025-01-24
**Build Status:** Passing (32 tests, 0 failures)
**App Version:** Pre-release (development)

---

## Executive Summary

Cravey is a cannabis cessation support iOS app (~60% complete). Core logging features work end-to-end. The codebase follows Clean Architecture with modern SwiftUI patterns. Documentation has been consolidated and outdated files archived.

---

## What's Implemented (Working)

### Core Features
| Feature | Status | Notes |
|---------|--------|-------|
| **Craving Logging** | Working | Full form: intensity, triggers, location, notes, timestamp |
| **Usage Logging** | Working | Full form: ROA picker, amounts, triggers, location, notes |
| **Dashboard** | Working | 5 metric cards, streak tracking, intensity trends |
| **Settings** | Working | Export data (CSV/JSON), delete all data |
| **Home Screen** | Working | Lists cravings + usage with swipe actions |

### Technical Foundation
| Layer | Files | Status |
|-------|-------|--------|
| **Domain (Entities)** | 4 | CravingEntity, UsageEntity, RecordingEntity, MotivationalMessageEntity |
| **Domain (Use Cases)** | 4 | LogCraving, FetchCravings, LogUsage, FetchUsage |
| **Domain (Protocols)** | 4 | CravingRepositoryProtocol, UsageRepositoryProtocol, RecordingRepositoryProtocol, MessageRepositoryProtocol |
| **Data (Models)** | 4 | CravingModel, UsageModel, RecordingModel, MotivationalMessageModel |
| **Data (Mappers)** | 4 | All mappers implemented |
| **Data (Repositories)** | 2 | CravingRepository, UsageRepository (concrete implementations) |
| **Presentation (ViewModels)** | 6 | CravingLog, CravingList, UsageLog, UsageList, Dashboard, Settings |
| **Presentation (Views)** | 10+ | Home, Craving forms/list, Usage forms/list, Dashboard, Settings, Components |
| **Tests** | 9 files | 32 unit tests, all passing |

### Architecture Compliance
- Clean Architecture enforced (Domain has no framework imports)
- Modern SwiftUI patterns (@Observable, @State, @Environment)
- SwiftData with local-only storage (no CloudKit)
- iOS 18+ targeting

---

## What's NOT Implemented

### Scaffolded Only (Protocols/Entities Exist, No Implementation)

| Component | What Exists | What's Missing |
|-----------|-------------|----------------|
| **RecordingRepository** | Protocol defined | No concrete implementation |
| **MessageRepository** | Protocol defined | No concrete implementation |
| **Recording Use Cases** | Entity defined | No SaveRecording/FetchRecordings use cases |
| **Recording ViewModels** | - | RecordingViewModel, RecordingLibraryViewModel |
| **Recording Views** | - | RecordingView, RecordingLibraryView, playback UI |
| **AVFoundation** | FileStorageManager exists | No audio/video recording logic |

### Not Started

| Feature | Spec Status | Implementation |
|---------|-------------|----------------|
| **Onboarding** | Spec complete (UX_FLOW_SPEC.md) | WelcomeView, TourView not created |
| **Quick Play (Home)** | Spec complete | Placeholder TODO in HomeView |
| **UI Tests** | Files exist | Disabled due to Swift 6 concurrency issues |

### Launch Prep (Phase 6)
- TestFlight setup
- App Store assets (screenshots, description)
- Privacy policy page
- Support page

---

## Test Suite

```
Test Suite 'All tests' passed
- Craving Log Integration Tests: 3/3
- CravingLogViewModel Tests: 2/2
- IntensitySlider Tests: 2/2
- LogCravingUseCase Tests: 2/2
- ROAPickerInput Tests: 5/5
- Usage Data Layer Integration Tests: 6/6
- UsageListViewModel Tests: 2/2
- Usage Log Integration Tests: 5/5
- UsageLogViewModel Tests: 5/5

Total: 32 tests passing
Build warnings: 16 (SwiftLint style only - trailing commas, TODOs)
```

---

## Documentation Structure

```
docs/
├── PROJECT_STATUS.md      # THIS FILE - Single source of truth
├── ARCHITECTURE.md        # Quick architecture reference
├── GETTING_STARTED.md     # 5-minute setup guide
├── PROJECT_SETUP.md       # Xcode project creation
├── BUG_SPEC_AUTHORITATIVE.md  # Known bug specifications
├── MVP_PRODUCT_SPEC.md    # Product vision & features
├── CLINICAL_CANNABIS_SPEC.md  # Domain requirements
├── UX_FLOW_SPEC.md        # Screen designs (19 screens)
├── DATA_MODEL_SPEC.md     # SwiftData schemas
├── TECHNICAL_IMPLEMENTATION.md  # Architecture & implementation
├── specs/
│   ├── PHASE_3.md         # Onboarding spec (not started)
│   ├── PHASE_4.md         # Recordings spec (not started)
│   └── PHASE_6.md         # Launch prep spec
└── _archive/              # Historical docs (DO NOT REFERENCE)
    ├── CHECKPOINT_STATUS.md
    ├── PHASE_OVERVIEW.md
    ├── CONVERGENCE_STRATEGY.md
    └── specs/...
```

---

## Prioritized Backlog

### Immediate (Stabilization Complete)
The app is now stable. Next steps depend on priorities:

### Option A: Quick Wins
1. **Onboarding** - WelcomeView + TourView (improves first-launch experience)
2. **Home screen polish** - Better title, any remaining swipe-to-delete issues

### Option B: Core Differentiator
1. **Recordings Feature** - AVFoundation integration (larger effort, core value prop)
   - Audio recording first (simpler)
   - Video recording second (complex)
   - Recording library UI
   - Quick Play on Home screen

### Option C: Launch Prep
1. **TestFlight** - Get beta testers
2. **App Store assets** - Screenshots, description
3. **Legal** - Privacy policy, support page

---

## Development Commands

```bash
# Build
xcodebuild -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build | xcbeautify

# Test (unit only)
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests | xcbeautify

# Format code
swiftformat .

# Lint
swiftlint
```

---

## Reference Files

- **CLAUDE.md** - Development context for AI assistants
- **AGENTS.md** - Multi-agent coordination
- **project.yml** - XcodeGen configuration

---

## Change Log

| Date | Change |
|------|--------|
| 2025-01-24 | Created PROJECT_STATUS.md, consolidated status docs, archived outdated files |
| 2025-01-05 | Dashboard, Settings, UI/UX Polish completed |
| 2025-01-05 | ChipSelector bug fix, code review findings addressed |
| 2024-11-02 | Usage logging, craving logging convergence complete |
