# Cravey Project Status

**Last Updated:** 2026-01-31
**Build Gate:** `bash scripts/verify.sh` ✅ (121 unit tests passing; add `--ui` for 22 UI tests)
**App Version:** Pre-release (development)

---

## Executive Summary

Cravey is a privacy-first cannabis tracking and support iOS app (iOS 18+) built with Clean Architecture + MVVM using SwiftUI + SwiftData. Core tracking (cravings + usage), dashboard metrics, a Home motivation card (seeded defaults), and data management (export + delete-all) work end-to-end. Recordings are scaffolded (models + storage exist) but are not yet implemented as an end-user feature.

---

## What's Implemented (Working)

### Core Features

| Feature | Status | Notes |
|---------|--------|-------|
| **Craving Logging** | Working | Full form: intensity, triggers, location, notes, timestamp |
| **Usage Logging** | Working | Full form: ROA picker, amounts, triggers, location, notes |
| **Dashboard** | Working | 5 metric cards, streak tracking, intensity trends |
| **Settings** | Working | Export (CSV/JSON) + delete-all (logs + recordings + custom messages) |
| **Home Screen** | Working | 4-tab structure: Home (dashboard), Log (actions), History (lists), Settings |

### Technical Foundation

| Layer | Files | Status |
|-------|-------|--------|
| **Domain (Entities)** | 7 | CravingEntity, UsageEntity, RecordingEntity, MotivationalMessageEntity, TriggerOptions, UsageMethod, ValidationLimits |
| **Domain (Use Cases)** | 12 | Log/Fetch/Delete (Craving/Usage), Export/DeleteAll, Select/MarkShown (Motivation), plus helpers |
| **Domain (Protocols)** | 4 | CravingRepositoryProtocol, UsageRepositoryProtocol, RecordingRepositoryProtocol, MessageRepositoryProtocol |
| **Data (Models)** | 4 | CravingModel, UsageModel, RecordingModel, MotivationalMessageModel |
| **Data (Mappers)** | 4 | All mappers implemented |
| **Data (Repositories)** | 4 | CravingRepository, UsageRepository, RecordingRepository, MessageRepository (concrete implementations) |
| **Data (Use Cases)** | 1 | SwiftDataDeleteAllUserDataUseCase (DeleteAllUserDataUseCase implementation) |
| **Presentation (ViewModels)** | 7 | CravingLog, CravingList, UsageLog, UsageList, Dashboard, Settings, HomeMotivation |
| **Presentation (Views + Components)** | 16 | Home (dashboard), Log, History, Settings (incl. export flow), Craving/Usage forms+lists, reusable components |
| **Tests** | 37 files | 121 unit tests (Swift Testing) + 22 UI tests (XCTest), all passing |

### Architecture Compliance
- Clean Architecture enforced (Domain has no SwiftUI/SwiftData imports)
- Modern SwiftUI patterns (@Observable, @State, @Environment)
- SwiftData with local-only storage (no CloudKit)
- iOS 18+ targeting

---

## What's NOT Implemented

### Scaffolded Only (Entities/Models/Protocols Exist, Feature Not Implemented)

| Component | What Exists | What's Missing |
|-----------|-------------|----------------|
| **Recordings Feature** | Models + repository + file storage | AVFoundation capture/playback + user-facing UI |
| **Recording Use Cases** | Entity defined | No SaveRecording/FetchRecordings use cases |
| **Recording ViewModels** | - | RecordingViewModel, RecordingLibraryViewModel |
| **Recording Views** | - | RecordingView, RecordingLibraryView, playback UI |
| **AVFoundation** | FileStorageManager exists | No audio/video recording logic |

### Not Started

| Feature | Spec Status | Implementation |
|---------|-------------|----------------|
| **Onboarding** | Spec complete (UX_FLOW_SPEC.md) | WelcomeView, TourView not created |
| **Quick Play (Home)** | Spec complete | Recordings feature not implemented yet |
| **Custom Motivational Messages UI** | Repository + models exist | UI to create/edit/manage messages not implemented |

### Launch Prep (Phase 6)
- TestFlight setup
- App Store assets (screenshots, description)
- Privacy policy page
- Support page

---

## Verification

**Primary gate (must be green):**
```bash
bash scripts/verify.sh
```

**What it checks (summary):**
- `xcodegen generate`
- `swiftformat --lint`
- `swiftlint lint`
- Static invariants (privacy + Clean Architecture boundaries)
- iOS Simulator compile check (uses an installed simulator, prefers `iPhone 17 Pro`)
- Unit tests (`CraveyTests`) on iOS Simulator with code signing disabled
- Optional UI tests (`CraveyUITests`) on iOS Simulator (`bash scripts/verify.sh --ui`)

---

## Documentation Structure

```text
docs/
├── PROJECT_STATUS.md      # This file (status)
├── ARCHITECTURE.md        # Implementation-aligned architecture reference
├── GETTING_STARTED.md     # Setup + workflow
├── master/                # Authoritative product/clinical/data-model specs (SSOT)
├── specs/                 # Active engineering specs
├── future/                # Deferred feature specs (planning only)
├── bugs/                  # Bug tracker (individual bug files)
├── debt/                  # Debt tracker (individual debt files)
└── _archive/              # Historical docs (DO NOT REFERENCE)
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
| 2026-01-30 | Stabilization complete: 0 open debt/bugs, 121 unit tests + 22 UI tests, verification gate updated |
| 2026-01-27 | UI redesign complete: 4-tab structure (Home/Log/History/Settings), 48 tests |
| 2026-01-27 | Refreshed status to match current implementation + verification gate |
| 2025-01-24 | Created PROJECT_STATUS.md, consolidated status docs, archived outdated files |
| 2025-01-05 | Dashboard, Settings, UI/UX Polish completed |
| 2025-01-05 | ChipSelector bug fix, code review findings addressed |
| 2024-11-02 | Usage logging, craving logging convergence complete |
