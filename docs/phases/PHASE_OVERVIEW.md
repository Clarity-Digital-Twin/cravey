# Cravey Implementation Phases - Overview

**Version:** 1.0
**Last Updated:** 2025-10-31
**Status:** 🚀 READY TO START PHASE 1

---

## 🎯 Phase Strategy

This document breaks down the **TECHNICAL_IMPLEMENTATION.md** into **modular, week-by-week phases** aligned with the 16-week master timeline. Each documented phase:

✅ Can be **tested independently** (unit + integration + UI tests)
✅ Produces a **shippable deliverable** (users can do something new)
✅ Follows **TDD workflow** (write tests → implement → validate)
✅ Validates **Clean Architecture** compliance (Dependency Rule)

---

## 📦 Phase Breakdown (4 Phases, 16 Weeks Total)

### Phase 1: Foundation + Craving Logging ⏱️ 1 week (Week 1)
**Dependencies:** None (baseline code exists)
**Shippable:** Users can launch app, log cravings, view craving history
**Features:** Feature 1 (Craving Logging - complete)
**Files Created:** 17 files (2 foundation + 1 app + 3 tabs + 5 components + 3 views/VMs + 3 test files)
**Tests:** 6 unit tests (4 baseline + 2 new), 2 integration tests, 1 UI test (9 total)

**Key Deliverables:**
- UsageModel created (data model only, UI in Week 2)
- Empty tab bar shell (Home, Dashboard, Settings)
- CravingLogForm (full implementation)
- CravingListView (read-only list)
- Reusable components (IntensitySlider, ChipSelector, etc.)
- <5 sec craving log validated

**Note:** This phase covers **Week 1 only**. Usage Logging (Week 2), Recordings (Weeks 5-6), Dashboard (Week 8), and other features are in subsequent phases per TECHNICAL_IMPLEMENTATION.md master timeline.

---

### Week 2: Usage Logging ⏱️ 1 week (Week 2 of 16-week plan)
**Dependencies:** Phase 1 (reuses ChipSelector, TimestampPicker, TriggerOptions, LocationOptions)
**Shippable:** Users can log both cravings AND usage with ROA-specific amounts
**Features:** Feature 2 (Usage Logging - complete)
**Files Created:** 13 files (4 domain + 2 data + 5 presentation + 2 modified)
**Tests:** 10 unit tests, 2 integration tests, 2 UI tests (14 total)

**Key Deliverables:**
- UsageEntity + UsageRepositoryProtocol (Domain layer)
- UsageRepository implementation (replaces stub pattern from Phase 1)
- LogUsageUseCase + FetchUsageUseCase
- ROAPickerInput component (ROA-aware amounts: Bowls, Vape, Edible, etc.)
- UsageLogForm + UsageListView
- Dual craving + usage tracking in HomeView
- <10 sec usage logging validated

**Note:** See [PHASE_2.md](./PHASE_2.md) for detailed Week 2 implementation guide.

---

### Weeks 3-4: Onboarding + Data Management ⏱️ 2 weeks
**Dependencies:** Weeks 1-2 (craving + usage logging complete)
**Shippable:** Users can onboard, export/delete data, manage app settings
**Features:** Feature 0 (Onboarding) + Feature 5 (Data Management)
**Status:** ✅ **Documented** (PHASE_3.md)

**Key Deliverables:**
- WelcomeView + TourView (onboarding flow in <60 seconds)
- ExportDataUseCase (CSV/JSON generation)
- DeleteAllDataUseCase (atomic deletion)
- SettingsView with export/delete flows
- Tab bar with Settings tab

**Note:** See [PHASE_3.md](./PHASE_3.md) for detailed Weeks 3-4 implementation guide.

---

### Weeks 5-6: Recordings ⏱️ 2 weeks
**Dependencies:** Weeks 1-4 (craving + usage logging, onboarding, data management)
**Shippable:** Users can record motivational content (audio + video) and play it back during cravings
**Features:** Feature 3 (Pre-Recorded Motivational Content - Recordings)
**Status:** ✅ **Documented** (PHASE_4.md)

**Key Deliverables:**
- AudioRecordingCoordinator (AVAudioRecorder with 120-sec auto-stop)
- VideoRecordingCoordinator (AVCaptureSession with front camera)
- Recording library with filter (All/Videos/Audio)
- Audio/video playback (AVPlayer + VideoPlayer)
- Quick Play section (Home tab) - Top 3 most-played recordings
- Thumbnail generation for videos (1-second mark)
- Swipe-to-delete with atomic file deletion
- Purpose categorization (motivational, milestone, reflection, craving)

**Note:** See [PHASE_4.md](./PHASE_4.md) for detailed Weeks 5-6 implementation guide.

---

### Weeks 7-8: Dashboard ⏱️ 2 weeks
**Dependencies:** Weeks 1-2 (craving + usage logging) - Recordings optional
**Shippable:** Users can visualize progress with 5 MVP metric cards and date range filters
**Features:** Feature 4 (Dashboard with Swift Charts)
**Status:** ✅ **Documented** (PHASE_5.md)

**Key Deliverables:**
- FetchDashboardDataUseCase (aggregates craving + usage data)
- 11 metric cards (Swift Charts):
  - Total cravings logged
  - Average craving intensity
  - Craving frequency (7/30/90 days)
  - Most common triggers
  - Total usage logged
  - Usage frequency by ROA
  - Clean days streak
  - Progress over time (line chart)
  - Craving vs. usage correlation
  - Success rate (cravings resisted)
  - Weekly summary
- Date range filter (7/30/90 days)
- <3 sec dashboard load time validated

---

### Weeks 9-12: Polish & Testing ⏱️ 4 weeks (Weeks 9-12)
**Dependencies:** Weeks 1-8 (all features exist)
**Shippable:** Production-ready MVP (polished, tested, performant)
**Features:** UI/UX Polish + Performance Optimization + User Testing
**Files Created:** Refinements to existing files (no new files)
**Tests:** Achieve 80%+ unit test coverage across all features

**Key Deliverables:**
- UI/UX polish (animations, haptics, empty states, error handling)
- Performance optimization (SwiftData queries, chart rendering, memory profiling)
- Accessibility audit (VoiceOver labels, Dynamic Type scaling, color contrast)
- User testing iteration (internal + external beta, feedback implementation)
- Code quality & documentation (Clean Architecture compliance, refactoring)

---

### Weeks 13-16: Launch Prep ⏱️ 4 weeks (Weeks 13-16)
**Dependencies:** Weeks 9-12 (production-ready MVP)
**Shippable:** Cravey v1.0 live on App Store
**Features:** TestFlight Beta + App Store Submission
**Files Created:** 2 onboarding views
**Tests:** 5 UI tests (critical flows)

**Key Deliverables:**
- TestFlight setup (App Store Connect record, beta builds, internal testing)
- External beta testing (10-20 testers, feedback prioritization, fixes)
- App Store assets (screenshots, description, privacy policy, support page)
- App Store submission & review
- 🚀 **LAUNCH** (release to public)

---

## 🗓️ Timeline Summary

| Phase | Duration | Cumulative | Status | Description |
|-------|----------|------------|--------|-------------|
| PHASE_1 (Week 1) | 1 week | Week 1 | ✅ **Documented** | Foundation + Craving Logging |
| PHASE_2 (Week 2) | 1 week | Week 2 | ✅ **Documented** | Usage Logging |
| PHASE_3 (Weeks 3-4) | 2 weeks | Weeks 3-4 | ✅ **Documented** | Onboarding + Data Management |
| PHASE_4 (Weeks 5-6) | 2 weeks | Weeks 5-6 | ✅ **Documented** | Recordings |
| PHASE_5 (Weeks 7-8) | 2 weeks | Weeks 7-8 | ✅ **Documented** | Dashboard |
| Weeks 9-12 | 4 weeks | Weeks 9-12 | ⏳ Pending | Polish & Testing |
| Weeks 13-16 | 4 weeks | Weeks 13-16 | ⏳ Pending | Launch Prep |

**Total Timeline:** 16 weeks to MVP launch (aligned with TECHNICAL_IMPLEMENTATION.md master spec)

**Documentation Status:**
- ✅ **PHASE_1 (Week 1):** Complete and ready to implement
- ✅ **PHASE_2 (Week 2):** Complete and ready to implement
- ✅ **PHASE_3 (Weeks 3-4):** Complete and ready to implement (Onboarding + Data Management)
- ✅ **PHASE_4 (Weeks 5-6):** Complete and ready to implement (Recordings)
- ✅ **PHASE_5 (Weeks 7-8):** Complete and ready to implement (Dashboard)
- ⏳ **Weeks 9-16:** To be documented as needed

---

## 📊 Test Coverage Goals (Per Phase)

| Phase | Unit Tests | Integration Tests | UI Tests | Total | Notes |
|-------|------------|-------------------|----------|-------|-------|
| PHASE_1 (Week 1) | 6 | 2 | 1 | 9 | Craving logging only (4 baseline + 2 new) |
| PHASE_2 (Week 2) | 10 | 2 | 2 | 14 | Usage logging |
| PHASE_3 (Weeks 3-4) | 8 | 4 | 2 | 14 | Onboarding + data management |
| PHASE_4 (Weeks 5-6) | 10 | 4 | 2 | 16 | Recordings |
| PHASE_5 (Weeks 7-8) | 5 | 0 | 8 | 13 | Dashboard (5 use case + 8 ViewModel tests) |
| Weeks 9-12 | Achieve 80%+ | — | — | — | Coverage target |
| Weeks 13-16 | 0 | 0 | 5 | 5 | Critical flow tests |
| **TOTAL** | **26+** | **8+** | **10+** | **44+** | Target: 80% coverage |

**Coverage Strategy:**
- **PHASE_1 (Week 1):** Baseline test patterns established (9 tests total: 4 baseline + 5 new for craving logging)
- **PHASE_2 (Week 2):** Usage logging tests (14 tests)
- **PHASE_3 (Weeks 3-4):** Onboarding + data management tests (14 tests)
- **PHASE_4 (Weeks 5-6):** Recording tests (16 tests including AVFoundation coordinators)
- **PHASE_5 (Weeks 7-8):** Dashboard tests (13 tests)
- **Weeks 9-12:** Comprehensive coverage audit and gap-filling to reach 80%+

---

## 🔄 TDD Workflow (Every Phase)

```
1. Write Test (RED) ❌
   - Unit test for use case
   - ViewModel test with mock use case
   - UI test for critical flow

2. Implement Minimal Code (GREEN) ✅
   - Domain layer (Entity, Use Case, Protocol)
   - Data layer (Model, Mapper, Repository)
   - Presentation layer (ViewModel, View)

3. Refactor (CLEAN) 🧹
   - Extract helpers
   - Improve naming
   - Add documentation
   - Verify tests still pass

4. Commit (ATOMIC) 📦
   - Small, focused commits
   - Commit message format: "[Phase X] Add feature Y"
   - Push to feature branch
```

---

## ✅ Phase Completion Checklist (Template)

**Before marking a phase complete:**

- [ ] All tests passing (unit + integration + UI)
- [ ] Build succeeds with zero warnings
- [ ] SwiftLint violations <10 warnings
- [ ] Code reviewed (Clean Architecture compliance)
- [ ] Manual testing complete (success criteria validated)
- [ ] Documentation updated (inline comments + README if needed)
- [ ] Git commit pushed (feature branch)
- [ ] Phase deliverable shippable (users can use new feature)

---

## 🚀 Phase Navigation

- **[PHASE_1: Foundation + Craving Logging (Week 1)](./PHASE_1.md)** ← START HERE (✅ Complete documentation)
- **[PHASE_2: Usage Logging (Week 2)](./PHASE_2.md)** (✅ Complete documentation)
- **[PHASE_3: Onboarding + Data Management (Weeks 3-4)](./PHASE_3.md)** (✅ Complete documentation)
- **[PHASE_4: Recordings (Weeks 5-6)](./PHASE_4.md)** (✅ Complete documentation)
- **[PHASE_5: Dashboard (Weeks 7-8)](./PHASE_5.md)** (✅ Complete documentation)
- [Weeks 9-12: Polish & Testing] (⏳ To be documented)
- [Weeks 13-16: Launch Prep] (⏳ To be documented)

---

## 📚 Reference Documents

- **[TECHNICAL_IMPLEMENTATION.md](../TECHNICAL_IMPLEMENTATION.md)** - Master spec (all 6 features)
- **[CHECKPOINT_STATUS.md](../CHECKPOINT_STATUS.md)** - Project progress tracker
- **[MVP_PRODUCT_SPEC.md](../MVP_PRODUCT_SPEC.md)** - Feature requirements
- **[UX_FLOW_SPEC.md](../UX_FLOW_SPEC.md)** - Screen flows (19 screens)
- **[DATA_MODEL_SPEC.md](../DATA_MODEL_SPEC.md)** - SwiftData schemas

---

**Next Step:** Read **[PHASE_1.md](./PHASE_1.md)** for detailed implementation plan.
