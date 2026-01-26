# Feature Gaps & Incomplete Implementations

**Last Updated:** 2026-01-26
**Status:** Multiple items OPEN

---

## FEAT-001: Onboarding Flow Missing

**Status:** OPEN
**Priority:** CRITICAL
**Spec Reference:** `docs/master/UX_FLOW_SPEC.md`

### Expected (per spec)
1. Welcome screen with app intro
2. Privacy explanation (local-only data)
3. Optional account setup
4. Quick tour of main features
5. First craving/usage prompt

### Current State
- App launches directly to Home
- No welcome screen
- No privacy explanation
- No tour

### Impact
- Users don't understand app purpose
- Privacy commitment not communicated
- First-time user confusion
- Missed opportunity to set expectations

### Files Needed
```
Cravey/Presentation/Views/Onboarding/
├── WelcomeView.swift
├── PrivacyExplainerView.swift
├── TourView.swift
└── OnboardingCoordinator.swift
```

### Implementation Notes
- Use @AppStorage for `hasCompletedOnboarding` flag
- Show on first launch only
- Allow skip but show privacy summary

---

## FEAT-002: Recordings Feature Incomplete

**Status:** OPEN
**Priority:** HIGH
**Spec Reference:** `docs/master/MVP_PRODUCT_SPEC.md`

### Expected (per spec)
- Record motivational videos/audio
- Play recordings during craving moments
- Quick Play from Home tab
- Recording library management

### Current State
- RecordingModel exists (SwiftData)
- RecordingEntity exists (Domain)
- RecordingMapper exists (Data)
- RecordingRepositoryProtocol defined
- **NO concrete RecordingRepository**
- **NO RecordingViewModel**
- **NO Recording UI views**
- **NO AVFoundation integration**

### Missing Components
```
Data Layer:
- Cravey/Data/Repositories/RecordingRepository.swift

Domain Layer:
- SaveRecordingUseCase
- FetchRecordingsUseCase
- DeleteRecordingUseCase
- PlayRecordingUseCase

Presentation Layer:
- RecordingViewModel.swift
- RecordingListView.swift
- RecordingDetailView.swift
- RecordingPlayerView.swift
- RecordingCaptureView.swift

Infrastructure:
- AVFoundation session management
- Audio/Video recorder service
- Thumbnail generation
```

### Blocker
This is the app's core differentiator. Without recordings, Cravey is just a log app.

---

## FEAT-003: Quick Play Button Missing

**Status:** OPEN
**Priority:** HIGH
**Location:** Home tab

### Expected (per spec)
- Prominent "Quick Play" button on Home
- One-tap access to most recent motivational recording
- Visual indicator when recordings available

### Current State
- No Quick Play button
- No indication that recordings exist
- Home shows only logs

### Dependencies
- Requires FEAT-002 (Recordings) to be complete

---

## FEAT-004: GPS/Location Integration Stubbed

**Status:** DEFERRED
**Priority:** LOW
**Location:** `CravingLogForm.swift`, `UsageLogForm.swift`

### Expected (per spec)
- Optional GPS location capture
- Location presets (Home, Work, etc.)
- Location-based insights on Dashboard

### Current State
- Location field exists (text input)
- Preset chips available
- **NO actual GPS integration**
- **NO Core Location permission handling**

### Implementation Notes
- Add Core Location framework
- Request permission only when user taps GPS button
- Store coordinates in entity, display friendly name
- Consider privacy implications (local only, no tracking)

### Decision Needed
Is GPS location a v1 feature or post-launch?

---

## FEAT-005: Motivational Messages Display

**Status:** PARTIAL
**Priority:** MEDIUM
**Location:** `MotivationalMessageModel.swift`

### Expected (per spec)
- Show encouraging messages during craving moments
- Rotate through message library
- Allow user-created messages

### Current State
- Model exists with seeded defaults
- MessageMapper exists
- **NO UI to display messages**
- **NO MessageRepository implementation**
- **NO integration with craving flow**

### Missing
- Show message after logging craving
- Random message on Dashboard
- Message management in Settings

---

## FEAT-006: Data Export Improvements

**Status:** PARTIAL
**Priority:** LOW
**Location:** `SettingsViewModel.swift`

### Current State
- Export to CSV works
- Export to JSON works

### Missing Polish
- Export date range selection
- Export format preview
- Email/Share integration
- Include recordings in export (audio files)

---

## FEAT-007: Dark Mode Verification

**Status:** UNKNOWN
**Priority:** MEDIUM

### Notes
- SwiftUI should handle automatically
- Need to verify all custom colors work in dark mode
- Test intensity color scale in both modes
- Verify contrast ratios meet accessibility guidelines

### Action Needed
- Manual testing in dark mode
- Add dark mode screenshots to tests

---

## FEAT-008: Accessibility Audit

**Status:** NOT STARTED
**Priority:** MEDIUM

### Required Checks
- VoiceOver labels on all interactive elements
- Dynamic Type support
- Minimum tap target sizes (44x44pt)
- Color contrast ratios (WCAG AA)
- Motion reduction support

### Tools
- Xcode Accessibility Inspector
- iOS Settings > Accessibility testing

---

## Implementation Roadmap

### MVP (Must Have)
1. FEAT-001 - Onboarding (Critical for first impression)
2. FEAT-002 - Recordings (Core differentiator)
3. FEAT-003 - Quick Play (Depends on #2)

### v1.1 (Should Have)
1. FEAT-005 - Motivational messages display
2. FEAT-007 - Dark mode verification
3. FEAT-008 - Accessibility audit

### Post-Launch (Nice to Have)
1. FEAT-004 - GPS location
2. FEAT-006 - Export improvements
