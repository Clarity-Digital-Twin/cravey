# Phase 6: Polish, Testing & Launch (Weeks 9-16)

**Version:** 2.0 (Complete Implementation Guide)
**Duration:** 8 weeks (Weeks 9-16 of 16-week timeline)
**Dependencies:** Phases 1-5 complete (all MVP features implemented)
**Status:** 📝 Ready for Implementation
**Last Updated:** 2025-11-01

---

## 🎯 Phase Goal

**Shippable Deliverable:** **Production-ready MVP** (Cravey v1.0) live on App Store.

**Features Implemented:**
- Feature 0: Onboarding (WelcomeView + TourView)
- UI/UX Polish (animations, haptics, empty states)
- Performance Optimization (SwiftData, charts, memory)
- Accessibility Compliance (VoiceOver, Dynamic Type, color contrast)
- TestFlight Beta (10-20 external testers)
- App Store Submission & Launch

**Scope Note:** This phase covers **Weeks 9-16** from TECHNICAL_IMPLEMENTATION.md. All 6 MVP features must be complete before starting this phase (craving logging, usage logging, recordings, motivational messages, dashboard, data management).

---

## 📊 What's Already Done (Baseline from Phases 1-5)

✅ **Phase 1 (Week 1): Foundation + Craving Logging**
- Complete craving logging feature (<5 sec target)
- Tab bar shell (Home, Dashboard, Settings)
- Reusable components (IntensitySlider, ChipSelector, etc.)

✅ **Phase 2 (Week 2): Usage Logging**
- Usage logging feature (<10 sec target)
- ROA-specific amounts (Bowls, Vape, Edible, etc.)
- Dual craving + usage tracking in HomeView

✅ **Phase 3 (Weeks 3-4): Onboarding + Data Management**
- Onboarding flow implemented (WelcomeView + TourView shows once on first launch)
- Export data (CSV/JSON)
- Delete all data (atomic)
- SettingsView with data management

✅ **Phase 4 (Weeks 5-6): Recordings**
- Audio + video recording (AVFoundation)
- Recording library with filters
- Playback with Quick Play section
- Swipe-to-delete

✅ **Phase 5 (Weeks 7-8): Dashboard**
- 5 MVP metric cards (Swift Charts)
- Date range filters (7/30/90 days)
- <3 sec dashboard load target
- 6 additional metrics available as DashboardData computed properties

---

## 🛠️ What We're Building (Phase 6)

### Part 1: Onboarding Polish (Week 9, Days 1-2)

**Goal:** Refresh copy, visuals, and haptics so the existing onboarding flow feels production-ready and highlights all 6 features clearly.

#### Files to Modify (2 files)

1. **Update `Presentation/Views/Onboarding/WelcomeView.swift`**
   - Refine headline/tagline copy (consistent with App Store description)
   - Add subtle animation or hero illustration if missing
   - Reinforce privacy message ("100% local, zero tracking")
   - Ensure primary CTA uses new button style + haptics

2. **Update `Presentation/Views/Onboarding/TourView.swift`**
   - Audit slide copy/images (Craving Logging, Usage Tracking, Recordings, Dashboard with 5 metrics, Privacy)
   - Add progress indicator polish (PageTabView dots + accessibility labels)
   - Confirm Skip button, final CTA, and AppStorage flag still work
   - Localize strings where possible; prepare for future translations

---

### Part 2: UI/UX Polish (Week 9, Days 3-5)

**Goal:** App feels premium, responsive, delightful.

#### Files to Modify (Refinements across existing files)

**Animations:**
- Sheet transitions (CravingLogForm, UsageLogForm, RecordingView) - `.presentationDetents([.medium, .large])`
- Button feedback - `.buttonStyle(.borderedProminent)` with `.animation(.spring())`
- List item animations - `.animation(.default, value:)` on state changes
- Chart transitions - Swift Charts built-in animations

**Haptic Feedback:**
- Success vibrations - `UINotificationFeedbackGenerator().notificationOccurred(.success)` after logging
- Slider changes - `UIImpactFeedbackGenerator(style: .light).impactOccurred()` on intensity/amount changes
- Delete confirmations - `UINotificationFeedbackGenerator().notificationOccurred(.warning)`

**Empty State Polish:**
- HomeView empty state: Friendly illustration + "Log your first craving" CTA
- DashboardView empty state: "Log 7 days of data to see insights" with progress bar
- RecordingsLibraryView empty state: "Record your first motivational message"
- Use SF Symbols for icons (`hand.raised.fill`, `chart.bar.fill`, `mic.fill`)

**Error Handling Polish:**
- Toast messages (`.toast()` modifier) - "Craving logged successfully", "Recording saved"
- Retry logic for file I/O errors
- Graceful degradation for chart rendering failures (show placeholder)

---

### Part 3: Performance Optimization (Week 10)

**Goal:** All performance targets met, no memory leaks.

#### SwiftData Query Optimization (Days 1-2)

**Files to Modify:**
- `CravingRepository.swift` - Add predicates for date range filtering
- `UsageRepository.swift` - Add predicates for date range filtering
- `RecordingRepository.swift` - Add fetch limits (e.g., top 10 most-played)

**Optimizations:**
```swift
// Example: Fetch only last 90 days of cravings
let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: Date())!
let predicate = #Predicate<CravingModel> { craving in
    craving.timestamp >= ninetyDaysAgo
}
let descriptor = FetchDescriptor<CravingModel>(predicate: predicate, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
let results = try modelContext.fetch(descriptor)
```

#### Chart Rendering Optimization (Day 3)

**Files to Modify:**
- `DashboardViewModel.swift` - Aggregate data before passing to charts (don't render 1000+ individual points)
- Use `.chartXScale(domain:)` and `.chartYScale(domain:)` to limit rendering

**Example:**
```swift
// Aggregate daily averages instead of individual logs
let dailyAverages = Dictionary(grouping: cravings, by: { Calendar.current.startOfDay(for: $0.timestamp) })
    .mapValues { $0.map(\.intensity).reduce(0.0, +) / Double($0.count) }
    .sorted(by: { $0.key < $1.key })
```

#### Memory Profiling (Day 4)

**Use Xcode Instruments:**
1. **Leaks:** Run Leaks instrument, log 100+ cravings, navigate between tabs - zero leaks expected
2. **Allocations:** Monitor memory growth, ensure <100 MB for 90 days of data
3. **File Handles:** Verify file handles closed after recording playback

**Fix Common Issues:**
- Ensure AVPlayer instances deallocated after playback
- Release large thumbnails from memory when not visible
- Use `@State` (not `@StateObject`) for SwiftUI observation

#### File Storage Optimization (Day 5)

**Files to Modify:**
- `FileStorageManager.swift` - Add cleanup for orphaned files (files with no DB entry)

**Optimizations:**
- Video compression (use `.compressionSettings` on AVAssetExportSession)
- Thumbnail generation at lower resolution (480x360 instead of full 1080p)
- Audio compression (use AAC codec at 128 kbps)

---

### Part 4: Accessibility Audit (Week 11, Days 1-2)

**Goal:** VoiceOver works for all critical flows, Dynamic Type scaling tested.

#### VoiceOver Labels

**Files to Modify (add `.accessibilityLabel()` and `.accessibilityHint()`):**
- `IntensitySlider.swift` - "Craving intensity, \(Int(intensity)) out of 10"
- `ChipSelector.swift` - "Trigger: \(trigger), \(isSelected ? "selected" : "not selected")"
- `CravingLogForm.swift` - "Log Craving button, submits form"
- `RecordingView.swift` - "Play recording, \(recording.title ?? "untitled")"
- `DashboardView.swift` - "Chart showing \(chartTitle)"

**Testing Checklist:**
- [ ] Turn on VoiceOver (Cmd+F5 in Simulator)
- [ ] Navigate through craving log form using swipe gestures
- [ ] Verify all buttons have clear labels
- [ ] Test recordings playback with VoiceOver enabled

#### Dynamic Type Scaling

**Files to Modify (ensure `.font(.body)` instead of `.font(.system(size: 16))`):**
- All views should use `.font(.headline)`, `.font(.body)`, `.font(.caption)` (NOT fixed sizes)
- Test with Settings → Accessibility → Larger Text → XXXL

#### Color Contrast

**Validation:**
- Use Xcode Accessibility Inspector (Xcode → Open Developer Tool → Accessibility Inspector)
- Check contrast ratio ≥4.5:1 for normal text, ≥3:1 for large text
- Test both Light and Dark mode

---

### Part 5: User Testing Iteration (Week 11, Days 3-5)

**Goal:** Validate UX with real users, fix critical issues.

#### Day 3: Internal Testing

**Test Scenarios (Manual Testing Checklist):**
1. **New User Flow:**
   - [ ] Fresh install → onboarding → log first craving → view in list
   - [ ] Time from "Get Started" to first craving logged <90 seconds

2. **Craving Logging:**
   - [ ] Log craving with all fields (triggers, location, notes)
   - [ ] Log minimal craving (intensity only)
   - [ ] Verify <5 sec target (use stopwatch)

3. **Usage Logging:**
   - [ ] Log usage for each ROA (Bowls, Joints, Blunts, Vape, Dab, Edible)
   - [ ] Verify <10 sec target

4. **Recordings:**
   - [ ] Record audio (30 seconds)
   - [ ] Record video (60 seconds)
   - [ ] Play back from Quick Play section
   - [ ] Delete recording (swipe-to-delete)

5. **Dashboard:**
   - [ ] View dashboard with 7+ days of data
   - [ ] Switch date ranges (7/30/90 days)
   - [ ] Verify <3 sec load time

6. **Data Management:**
   - [ ] Export data (CSV/JSON)
   - [ ] Verify export contains all cravings + usage + recordings metadata
   - [ ] Delete all data (confirm atomic deletion)

#### Day 4: External Beta Testing (3-5 Target Users)

**Recruitment:**
- Friends/family who use cannabis and want to quit/reduce
- Provide TestFlight link via email

**Feedback Collection:**
- Google Form with questions:
  1. "How easy was onboarding?" (1-5 scale)
  2. "How fast could you log a craving?" (timed)
  3. "Did you find the dashboard helpful?" (yes/no + why)
  4. "What feature did you use most?" (dropdown)
  5. "Any bugs or confusing UI?" (free text)

#### Day 5: Prioritize & Implement Fixes

**MoSCoW Prioritization:**
- **Must Have:** Critical bugs (crashes, data loss)
- **Should Have:** UX friction (confusing labels, slow performance)
- **Could Have:** Nice-to-have polish (animations, color tweaks)
- **Won't Have:** Feature requests (defer to v1.1)

**Fix Critical Issues:**
- Create GitHub issues for each bug
- Implement fixes for "Must Have" and "Should Have" items
- Regression test all fixes

---

### Part 6: Code Quality & Documentation (Week 12)

**Goal:** Clean Architecture compliance, 80%+ test coverage, thorough documentation.

#### Day 1: Code Review (Clean Architecture Compliance)

**Checklist:**
- [ ] Domain layer has ZERO framework imports (no `import SwiftUI`, `import SwiftData`)
- [ ] All Use Cases are protocol-based (testable)
- [ ] All ViewModels depend on Use Cases (NOT repositories directly)
- [ ] DependencyContainer is the only place dependencies are wired
- [ ] No business logic in Views (only presentation logic)

**Refactoring:**
- Extract any business logic from ViewModels to new Use Cases
- Move any hardcoded constants to dedicated files (e.g., `TriggerOptions.swift`)

#### Day 2: Unit Test Coverage Audit

**Goal:** Achieve 80%+ coverage across all features.

**Run Coverage Report:**
```bash
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -enableCodeCoverage YES \
  | xcbeautify
```

**View Coverage in Xcode:**
1. Open Report Navigator (Cmd+9)
2. Select latest test run
3. Click Coverage tab
4. Sort by % coverage (ascending)

**Fill Coverage Gaps:**
- Write tests for any Use Case with <80% coverage
- Write ViewModel tests for edge cases (error handling, empty states)
- Prioritize critical paths (craving log, usage log, export data)

**Target Test Count (from PHASE_OVERVIEW.md):**
- Phase 1: 9 tests (baseline)
- Phase 2: 14 tests (usage logging)
- Phase 3: 14 tests (onboarding + data management)
- Phase 4: 16 tests (recordings)
- Phase 5: 13 tests (dashboard)
- **Phase 6: 10 tests (onboarding + critical flows)**
- **Total: 76+ tests** (target 80%+ coverage)

#### Day 3: Documentation

**Code Comments:**
- Add inline comments for complex logic (e.g., date range filtering, chart aggregation)
- Document all public protocols with `/// Summary` and `/// Parameters:`

**Update README.md:**
```markdown
# Cravey - Cannabis Cessation Support App

**Status:** 🚀 v1.0 Live on App Store

## Features
- 📝 Craving & Usage Logging (<5 sec target)
- 🎥 Motivational Recordings (audio + video)
- 📊 Dashboard with 5 MVP metrics (Swift Charts)
- 🔒 100% Local (zero cloud sync, zero tracking)

## Installation
1. Download from App Store: [Link]
2. Complete 60-second onboarding
3. Start logging cravings immediately

## Development Setup
See [GETTING_STARTED.md](./docs/GETTING_STARTED.md)

## Architecture
See [ARCHITECTURE.md](./docs/ARCHITECTURE.md)

## Privacy
All data is stored locally using SwiftData. No network calls, no analytics, no tracking.

## Support
- Email: support@craveyapp.com
- FAQ: https://craveyapp.com/faq
```

**Update CHANGELOG.md:**
```markdown
# Changelog

## [1.0.0] - 2025-MM-DD

### Added
- Craving logging with multi-trigger support
- Usage tracking with ROA-specific amounts
- Audio + video recording with Quick Play
- Dashboard with 11 Swift Charts metrics
- Data export (CSV/JSON) and deletion
- Onboarding flow (<60 seconds)

### Performance
- Craving log <5 seconds ✅
- Usage log <10 seconds ✅
- Dashboard load <3 seconds ✅

### Accessibility
- Full VoiceOver support
- Dynamic Type scaling
- WCAG 2.1 AA color contrast
```

#### Day 4: Refactoring (DRY Violations, Naming Consistency)

**DRY Violations to Fix:**
- Duplicate date formatting logic → create `DateFormatters.swift` utility
- Repeated error handling → create `ErrorHandling.swift` with `showToast()` helper
- Duplicate SwiftData fetch logic → create `FetchDescriptorBuilder.swift`

**Naming Consistency:**
- Ensure all Use Cases end with `UseCase` (e.g., `LogCravingUseCase`, NOT `CravingLogger`)
- Ensure all ViewModels end with `ViewModel` (e.g., `CravingLogViewModel`, NOT `CravingFormVM`)
- Ensure all Repositories end with `Repository` (e.g., `CravingRepository`, NOT `CravingStore`)

#### Day 5: Final QA Pass

**Manual Testing (All Critical Flows):**
1. Fresh install → onboarding → log craving → view dashboard (end-to-end)
2. Log 10 cravings → export data → verify CSV/JSON integrity
3. Record 5 videos → play from Quick Play → delete all → verify files deleted
4. Dark mode testing (all screens)
5. Accessibility testing (VoiceOver, Dynamic Type)

**Automated Testing:**
```bash
# Run all tests (unit + integration + UI)
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' | xcbeautify
```

---

### Part 7: TestFlight Setup (Week 13)

**Goal:** First TestFlight build uploaded, internal testing complete.

#### Day 1: Create App Store Connect Record

**Steps:**
1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Click "My Apps" → "+" → "New App"
3. Fill in metadata:
   - **Name:** Cravey
   - **Primary Language:** English (U.S.)
   - **Bundle ID:** com.clarity.cravey
   - **SKU:** cravey-ios-2025
   - **User Access:** Full Access
4. Click "Create"

#### Day 2: Configure TestFlight

**Steps:**
1. In App Store Connect, select Cravey → TestFlight tab
2. Add beta testers:
   - Internal testers (team + close friends) - up to 100
   - External testers (target users) - up to 10,000 (will add Week 14)
3. Create beta tester group: "Internal Testing v1.0"
4. Write release notes:
   ```
   🎉 First beta build! Test all 6 features:
   - Craving & usage logging
   - Motivational recordings
   - Dashboard analytics
   - Data export/delete
   - Onboarding flow

   Please report bugs via TestFlight feedback or email.
   ```

#### Day 3: Upload First TestFlight Build

**Steps:**
1. Archive app in Xcode:
   ```bash
   xcodebuild archive -scheme Cravey \
     -destination 'generic/platform=iOS' \
     -archivePath './build/Cravey.xcarchive' | xcbeautify
   ```

2. Export IPA for TestFlight:
   ```bash
   xcodebuild -exportArchive \
     -archivePath './build/Cravey.xcarchive' \
     -exportPath './build' \
     -exportOptionsPlist ExportOptions.plist
   ```

3. Upload to App Store Connect:
   ```bash
   # Using Xcode Organizer (recommended for first-time)
   # OR using xcrun altool:
   xcrun altool --upload-app \
     --type ios \
     --file './build/Cravey.ipa' \
     --username 'your-apple-id@example.com' \
     --password '@keychain:AC_PASSWORD'
   ```

4. Wait for processing (10-30 minutes)
5. Enable for Internal Testing in App Store Connect

#### Day 4: Internal Testing (Team + Close Friends)

**Test Plan:**
- Invite 5-10 internal testers (team, family, close friends)
- Provide testing guide (Google Doc with scenarios)
- Monitor TestFlight Feedback + email

**Critical Bugs to Fix:**
- Crashes (zero tolerance)
- Data loss (zero tolerance)
- Performance regressions (must meet targets)

#### Day 5: Fix Critical Bugs from TestFlight

**Process:**
1. Triage all bugs (create GitHub issues)
2. Prioritize crashers and data loss bugs
3. Implement fixes
4. Regression test
5. Upload TestFlight build v1.0.1 (if needed)

---

### Part 8: External Beta Testing (Week 14)

**Goal:** 10-20 external testers using app, high-priority feedback implemented.

#### Day 1: Invite External Testers

**Recruitment Channels:**
1. **Reddit:** r/Petioles (cannabis moderation subreddit) - post in "Weekly Check-In" thread
2. **Friends/Family:** Personal outreach to people who use cannabis
3. **Twitter/X:** "Looking for beta testers for new cannabis cessation app (100% private, local-only)"

**TestFlight Invitation Email Template:**
```
Subject: Help test Cravey - Cannabis Cessation Support App (Private Beta)

Hi [Name],

I'm inviting you to beta test Cravey, a privacy-first app that helps people quit or reduce cannabis use. Here's what makes it different:

✅ Track cravings in <5 seconds
✅ Record motivational videos/audio for tough moments
✅ Visualize progress with analytics
✅ 100% local (zero cloud sync, zero tracking)

TestFlight link: [INSERT LINK]

Please test for 3-5 days and share feedback. Your input will shape the final release!

Thanks,
[Your Name]
```

**Target:** 10-20 external testers (quality over quantity)

#### Day 2: Monitor Feedback

**Channels to Monitor:**
1. **TestFlight Feedback:** App Store Connect → TestFlight → Feedback
2. **Email:** Dedicated beta feedback email (beta@craveyapp.com)
3. **Slack Channel:** #beta-testing (if using internal Slack)
4. **Google Form:** Structured feedback survey (sent via email)

**Questions to Ask (Google Form):**
1. How easy was onboarding? (1-5 scale)
2. How long did it take to log your first craving? (dropdown: <30s, 30-60s, >60s)
3. Which feature did you use most? (dropdown: Craving Log, Usage Log, Recordings, Dashboard)
4. Did you encounter any bugs? (free text)
5. What would make you uninstall the app? (free text)
6. Would you recommend this to a friend? (1-5 scale)

#### Day 3: Prioritize Feedback (MoSCoW Method)

**Categorize All Feedback:**
- **Must Have (v1.0):** Crashes, data loss, major UX friction
- **Should Have (v1.0):** Minor UX friction, missing edge cases
- **Could Have (v1.1):** Nice-to-have features, polish
- **Won't Have (Future):** Feature requests outside MVP scope

**Example Prioritization:**
| Feedback | Category | Action |
|----------|----------|--------|
| "App crashes when deleting recording" | Must Have | Fix immediately |
| "Dashboard takes 5+ seconds to load" | Must Have | Optimize queries |
| "Can't edit craving after logging" | Should Have | Add edit feature (defer to v1.1) |
| "Add social sharing" | Won't Have | Violates privacy promise |

#### Day 4: Implement High-Priority Fixes

**Focus on "Must Have" and "Should Have" items:**
1. Create GitHub issues for each fix
2. Implement fixes (pair programming recommended)
3. Write regression tests
4. Test manually with affected scenario

**Example Fix (Dashboard Performance):**
```swift
// Before (slow - fetching all cravings)
let allCravings = try await fetchCravingsUseCase.execute()

// After (fast - date-filtered fetch)
let startDate = selectedDateRange.startDate // e.g., 7 days ago
let cravings = try await fetchCravingsUseCase.execute(from: startDate, to: Date())
```

#### Day 5: Upload TestFlight Build v2

**Steps:**
1. Archive + upload new build (same process as Day 3)
2. Add release notes:
   ```
   🐛 Bug Fixes:
   - Fixed crash when deleting recordings
   - Improved dashboard load time (now <3 seconds)
   - Fixed craving log form validation

   Thanks to all testers for the feedback! 🙏
   ```
3. Notify testers via email about new build
4. Monitor for new feedback (repeat cycle if needed)

---

### Part 9: App Store Assets (Week 15)

**Goal:** All App Store metadata ready for submission.

#### Day 1: Screenshot Generation

**Required Sizes (per Apple guidelines):**
1. **6.7" Display (iPhone 17 Pro Max):** 1290 x 2796 pixels (3 screenshots minimum)
2. **6.1" Display (iPhone 17):** 1179 x 2556 pixels (optional but recommended)
3. **5.5" Display (iPhone 8 Plus):** 1242 x 2208 pixels (for older devices)

**Screenshots to Include (5 total):**
1. **Onboarding Welcome:** Hero screen with value proposition
2. **Craving Log Form:** Showing intensity slider + triggers
3. **Dashboard:** 3-4 metric cards visible
4. **Recordings Library:** Grid of recordings with thumbnails
5. **Privacy Guarantee:** "100% Local Data" messaging

**Tool:** Use Xcode Simulator → Cmd+S to capture screenshots, OR use [App Store Screenshot Generator](https://www.appscreenshots.co/)

**Tip:** Add captions using preview tool (e.g., "Log cravings in <5 seconds" overlay)

#### Day 2: App Store Description

**Title (30 characters max):**
```
Cravey - Cannabis Tracker
```

**Subtitle (30 characters max):**
```
Track cravings, stay motivated
```

**Promotional Text (170 characters, editable without new version):**
```
100% private cannabis cessation support. Log cravings in <5 seconds, record motivational content, visualize progress. All data stays on your device.
```

**Description (4000 characters max):**
```markdown
Cravey is a privacy-first app designed to help you quit or reduce cannabis use. Built for people who value their privacy and want compassionate, non-judgmental support.

✅ TRACK CRAVINGS IN <5 SECONDS
Log cravings with intensity, triggers, location, and notes. No complex forms, just quick logging when you need it most.

✅ MOTIVATIONAL RECORDINGS
Record videos or audio messages to yourself for tough moments. Play them back during cravings for instant support.

✅ VISUALIZE YOUR PROGRESS
See your journey with 5 analytics metrics powered by Swift Charts:
- Weekly summary (total cravings + usage, top trigger)
- Current clean days streak
- Longest abstinence streak
- Average craving intensity trend
- Top 3 triggers

✅ 100% PRIVATE
All data is stored locally on your device. Zero cloud sync, zero analytics, zero tracking. Your journey is yours alone.

✅ TRACK USAGE WITH PRECISION
Log cannabis usage with route-of-administration (ROA) specific amounts:
- Bowls (number of bowls)
- Joints (number of joints)
- Blunts (number of blunts)
- Vape (number of sessions)
- Edibles (milligrams THC)
- Dabs (number of dabs)

✅ DATA EXPORT & MANAGEMENT
Export your data anytime (CSV or JSON format). Delete all data with one tap if needed.

✅ BUILT WITH CARE
Designed using Motivational Interviewing principles - compassionate, non-judgmental language that celebrates progress and normalizes setbacks.

PERFECT FOR:
- People who want to quit cannabis entirely
- People who want to moderate their use
- Anyone tracking their relationship with cannabis

NO JUDGMENT, JUST SUPPORT.
Your journey, your data, your privacy.

Download Cravey today and take the first step toward clarity.
```

**Keywords (100 characters max, comma-separated):**
```
cannabis,weed,quit,cessation,craving,tracker,sobriety,moderation,THC,addiction,support,private,local
```

#### Day 3: Privacy Policy Page

**Requirement:** Apple requires a privacy policy URL for all apps.

**Options:**
1. **Host on GitHub Pages (Free):** Create `privacy-policy.md` in `/docs`, enable GitHub Pages
2. **Host on Custom Domain:** If you have craveyapp.com
3. **In-App Privacy View:** SwiftUI view with privacy policy text (also acceptable)

**Privacy Policy Template:**
```markdown
# Cravey Privacy Policy

**Last Updated:** 2025-MM-DD

## Overview
Cravey is a 100% local-only app. We do not collect, store, or transmit any of your data to external servers.

## Data Collection
- **None.** All data (cravings, usage logs, recordings, analytics) is stored locally on your device using SwiftData.

## Data Sharing
- **None.** We do not share any data with third parties.

## Data Deletion
- You can delete all data at any time via Settings → Delete All Data.
- Uninstalling the app will delete all data permanently.

## Third-Party Services
- **None.** We do not use analytics, advertising, or crash reporting services.

## Contact
If you have questions, email us at: support@craveyapp.com

---

By using Cravey, you acknowledge this privacy policy.
```

#### Day 4: Support Page (FAQ + Contact)

**Create:** `docs/support.md` (host on GitHub Pages or custom domain)

**FAQ Content:**
```markdown
# Cravey Support

## Frequently Asked Questions

### How do I log a craving?
Tap the "+" button in the Home tab → "Log Craving" → Slide intensity → Tap "Save". That's it!

### Is my data private?
Yes! All data is stored locally on your device. We never send your data to any server.

### Can I export my data?
Yes! Go to Settings → Export Data → Choose CSV or JSON format.

### How do I delete all my data?
Go to Settings → Delete All Data → Confirm. This is irreversible.

### Can I edit a craving after logging it?
Not in v1.0 (coming in v1.1). For now, delete and re-log if needed.

### Does this app work offline?
Yes! Cravey is 100% offline (no internet required).

### How do I record a motivational message?
Go to Home tab → Quick Play section → "+" → Choose Audio or Video → Record → Save.

### What are the performance targets?
- Craving log: <5 seconds
- Usage log: <10 seconds
- Dashboard load: <3 seconds

## Contact
- **Email:** support@craveyapp.com
- **Bug Reports:** [GitHub Issues](https://github.com/yourusername/cravey/issues)
```

#### Day 5: Final Asset Review (App Store Guidelines Compliance)

**Checklist:**
- [ ] All screenshots show actual app UI (no mockups)
- [ ] Description doesn't use "best", "first", "#1" (prohibited)
- [ ] No medical claims ("cure addiction") - use "support" instead
- [ ] Privacy policy accessible via URL
- [ ] Support page has contact email
- [ ] App name doesn't include "iOS", "Apple", "iPhone" (prohibited)
- [ ] Keywords don't include competitor names
- [ ] No profanity in description or screenshots

**Reference:** [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

### Part 10: Launch (Week 16)

**Goal:** Cravey v1.0 live on App Store.

#### Day 1 (Monday): Submit to App Store for Review

**Steps:**
1. In App Store Connect, go to Cravey → App Store tab
2. Click "1.0 Prepare for Submission"
3. Fill in all metadata (description, keywords, screenshots, privacy policy, support URL)
4. Set pricing: **Free** (no in-app purchases)
5. Select category: **Health & Fitness**
6. Select content rating:
   - Medical/Treatment Information: None
   - Alcohol, Tobacco, or Drug Use or References: **Infrequent/Mild** (cannabis tracking)
7. Upload build (select build from TestFlight)
8. Answer Export Compliance questions:
   - Does your app use encryption? **No** (SwiftData is local, no network encryption)
9. Click "Submit for Review"

**Expected Review Time:** 1-3 days (sometimes 24 hours)

#### Day 2-4 (Tuesday-Thursday): Address App Review Feedback (If Rejected)

**Common Rejection Reasons:**
1. **Guideline 2.3.1 - Performance - Accurate Metadata:**
   - Fix: Ensure screenshots match actual app (no mockups)

2. **Guideline 5.1.1 - Privacy - Data Collection:**
   - Fix: Update privacy policy to clarify "zero data collection"

3. **Guideline 4.2 - Design - Minimum Functionality:**
   - Fix: Add value beyond basic note-taking (highlight recordings + analytics features)

**If Rejected:**
1. Read rejection message carefully
2. Fix issues in app or metadata
3. Upload new build (if code changes needed) OR update metadata only
4. Reply to App Review team in Resolution Center
5. Resubmit for review

#### Day 5 (Friday): 🚀 LAUNCH

**Once Approved:**
1. App status changes to "Ready for Sale" in App Store Connect
2. Click "Release this version" (or set release date if scheduling)
3. App goes live on App Store within 1-2 hours

**Announcement Plan:**
1. **Twitter/X:**
   ```
   🚀 Cravey v1.0 is now live on the App Store!

   Track cannabis cravings in <5 seconds
   100% private (zero cloud sync)
   Built for people who value their privacy 🔒

   Download: [App Store Link]
   ```

2. **Reddit r/Petioles:**
   ```
   [App Release] Cravey v1.0 - Privacy-First Cannabis Cessation Tracker

   Hey Petioles community! After 16 weeks of development, I'm excited to share Cravey - a 100% local cannabis tracking app. Here's what makes it different:

   ✅ Log cravings in <5 seconds (no complex forms)
   ✅ Record motivational videos/audio for tough moments
   ✅ Visualize progress with 11 analytics metrics
   ✅ 100% private (all data stays on your device)

   App Store: [Link]

   Happy to answer questions! This is a free app with no ads, no tracking, no BS.
   ```

3. **Email to Beta Testers:**
   ```
   Subject: 🎉 Cravey is LIVE on the App Store!

   Hi [Name],

   Thank you for beta testing Cravey! Your feedback shaped the final release.

   Cravey v1.0 is now live: [App Store Link]

   Please leave a review if you found it helpful - it makes a huge difference for visibility!

   Thanks again for your support 🙏

   [Your Name]
   ```

4. **Product Hunt (Optional):**
   - Submit to Product Hunt for visibility
   - Tagline: "Privacy-first cannabis cessation tracker"
   - Features to highlight: Local-only data, <5 sec logging, motivational recordings

---

## 📦 Complete File Checklist (Phase 6)

### Onboarding (2 files - NEW)
- [ ] `Presentation/Views/Onboarding/WelcomeView.swift` (CREATE)
- [ ] `Presentation/Views/Onboarding/TourView.swift` (CREATE)

### UI/UX Polish (Refinements to existing files)
- [ ] Add animations to `CravingLogForm.swift`, `UsageLogForm.swift`, `RecordingView.swift`
- [ ] Add haptic feedback across ViewModels
- [ ] Polish empty states in `HomeView.swift`, `DashboardView.swift`, `RecordingsLibraryView.swift`
- [ ] Add toast messages (create `ToastModifier.swift` helper)

### Performance Optimization (Modify existing files)
- [ ] Optimize SwiftData queries in `CravingRepository.swift`, `UsageRepository.swift`
- [ ] Aggregate chart data in `DashboardViewModel.swift`
- [ ] Add file cleanup to `FileStorageManager.swift`

### Accessibility (Modify existing views)
- [ ] Add `.accessibilityLabel()` to all interactive components
- [ ] Ensure Dynamic Type scaling in all views
- [ ] Validate color contrast (no new files, use Accessibility Inspector)

### Documentation (3 files - UPDATE)
- [ ] `README.md` (UPDATE - add App Store link, features list)
- [ ] `CHANGELOG.md` (CREATE - document v1.0 release)
- [ ] `docs/support.md` (CREATE - FAQ + contact info)
- [ ] `docs/privacy-policy.md` (CREATE - host on GitHub Pages)

### App Store Assets (Non-code)
- [ ] Screenshots (5 images per device size)
- [ ] App Store description (4000 characters)
- [ ] Keywords (100 characters)
- [ ] Privacy policy URL
- [ ] Support URL

### Total Files for Phase 6:
- **2 new files** (WelcomeView, TourView)
- **4 documentation files** (README, CHANGELOG, support, privacy-policy)
- **Refinements to 20+ existing files** (polish, optimization, accessibility)

---

## 🧪 Testing Strategy (Phase 6)

### Unit Tests (0 new - focus on coverage audit)
- No new Use Cases in Phase 6 (onboarding has no business logic)
- **Goal:** Achieve 80%+ coverage across existing tests by filling gaps

### Integration Tests (0 new)
- Existing tests cover critical paths (craving log, usage log, export data)

### UI Tests (10 new - critical flow validation)

**Create:** `CraveyUITests/CriticalFlowsUITests.swift`

1. **Test 1: Onboarding Flow**
   - Launch app → tap "Get Started" → swipe through tour (5 screens) → tap "Start Using Cravey"
   - **Success:** Onboarding completes in <60 seconds

2. **Test 2: Craving Log End-to-End**
   - Tap "+" → "Log Craving" → slide intensity to 7 → tap "Save" → verify craving appears in list
   - **Success:** Craving logged in <5 seconds

3. **Test 3: Usage Log End-to-End**
   - Tap "+" → "Log Usage" → select "Bowls" → enter amount → tap "Save"
   - **Success:** Usage logged in <10 seconds

4. **Test 4: Recording Flow**
   - Tap Quick Play "+" → "Audio" → record 10 seconds → tap "Save" → play back
   - **Success:** Recording saved and playable

5. **Test 5: Dashboard Load Time**
   - Navigate to Dashboard tab with 30+ cravings
   - **Success:** Dashboard loads in <3 seconds

6. **Test 6: Export Data Flow**
   - Settings → Export Data → CSV → Share Sheet opens
   - **Success:** CSV file generated

7. **Test 7: Delete All Data Flow**
   - Settings → Delete All Data → Confirm → verify all data deleted
   - **Success:** All cravings + usage + recordings deleted

8. **Test 8: Dark Mode Toggle**
   - Toggle dark mode → verify all screens render correctly
   - **Success:** No visual regressions

9. **Test 9: VoiceOver Navigation**
   - Enable VoiceOver → navigate craving log form using swipe gestures
   - **Success:** All elements have accessibility labels

10. **Test 10: Large Dataset Performance**
    - Seed 100 cravings + 100 usage logs → navigate between tabs
    - **Success:** No lag, all screens render in <3 seconds

---

## ✅ Success Criteria (Phase 6)

**Onboarding:**
- [ ] Onboarding completes in <60 seconds (median time from user testing)
- [ ] 90%+ of beta testers complete onboarding without confusion

**Performance:**
- [ ] Craving log <5 seconds (verified via UI test)
- [ ] Usage log <10 seconds (verified via UI test)
- [ ] Dashboard load <3 seconds (with 90 days of data)
- [ ] Zero memory leaks (verified via Instruments)

**Accessibility:**
- [ ] VoiceOver works for all critical flows (craving log, usage log, dashboard)
- [ ] Dynamic Type scaling tested at XXXL size
- [ ] Color contrast ratio ≥4.5:1 for all text (WCAG 2.1 AA)

**Testing:**
- [ ] Unit test coverage ≥80% (verified via Xcode coverage report)
- [ ] All 10 UI tests passing
- [ ] Zero crashers in TestFlight (crash-free rate 99.9%+)

**User Feedback:**
- [ ] TestFlight beta feedback positive (4.5+ average rating)
- [ ] Zero "Must Have" bugs remaining
- [ ] <3 "Should Have" bugs remaining (defer to v1.1)

**Launch:**
- [ ] App Store submission approved (no rejections, OR all rejections resolved)
- [ ] Privacy policy published (accessible via URL)
- [ ] Support page published (FAQ + contact email)
- [ ] 🚀 **Cravey v1.0 live on App Store**

---

## 🔄 Week-by-Week Breakdown

### Week 9: Onboarding + UI/UX Polish
- **Mon:** Refine WelcomeView (copy, visuals, haptics)
- **Tue:** Refine TourView (slides, accessibility, localization prep)
- **Wed:** Add animations (sheet transitions, button feedback)
- **Thu:** Add haptic feedback + empty state polish
- **Fri:** Accessibility audit (VoiceOver labels, Dynamic Type)

**Deliverable:** Onboarding flow polished (<60 sec), refined animations/haptics.

---

### Week 10: Performance Optimization
- **Mon:** SwiftData query optimization (predicates, fetch limits)
- **Tue:** Chart rendering optimization (aggregate data)
- **Wed:** Memory profiling (Instruments - Leaks, Allocations)
- **Thu:** File storage optimization (compression, cleanup)
- **Fri:** Network debug verification (zero network calls)

**Deliverable:** All performance targets met (<5s, <10s, <3s).

---

### Week 11: User Testing Iteration
- **Mon:** Internal testing (simulate user scenarios)
- **Tue:** External beta testing (3-5 target users)
- **Wed:** Collect feedback, prioritize fixes (MoSCoW)
- **Thu:** Implement critical fixes
- **Fri:** Regression testing

**Deliverable:** Critical UX issues fixed, beta feedback positive.

---

### Week 12: Code Quality & Documentation
- **Mon:** Code review (Clean Architecture compliance)
- **Tue:** Unit test coverage audit (target 80%+)
- **Wed:** Documentation (README, CHANGELOG, code comments)
- **Thu:** Refactoring (DRY violations, naming consistency)
- **Fri:** Final QA pass (all critical flows)

**Deliverable:** Production-ready codebase (80%+ coverage, documented).

---

### Week 13: TestFlight Setup
- **Mon:** Create App Store Connect record
- **Tue:** Configure TestFlight (beta testers, release notes)
- **Wed:** Upload first TestFlight build
- **Thu:** Internal testing (team + close friends)
- **Fri:** Fix critical bugs from TestFlight

**Deliverable:** TestFlight build uploaded, internal testing complete.

---

### Week 14: External Beta Testing
- **Mon:** Invite 10-20 external testers (Reddit, friends, family)
- **Tue:** Monitor feedback (TestFlight, email, Google Form)
- **Wed:** Prioritize feedback (MoSCoW method)
- **Thu:** Implement high-priority fixes
- **Fri:** Upload TestFlight build v2

**Deliverable:** External beta testing complete, high-priority fixes implemented.

---

### Week 15: App Store Assets
- **Mon:** Screenshot generation (5 screenshots per device size)
- **Tue:** App Store description (title, subtitle, keywords)
- **Wed:** Privacy policy page (GitHub Pages or custom domain)
- **Thu:** Support page (FAQ + contact email)
- **Fri:** Final asset review (App Store guidelines compliance)

**Deliverable:** All App Store metadata ready for submission.

---

### Week 16: Launch
- **Mon:** Submit to App Store for review
- **Tue-Thu:** Address App Review feedback (if rejected)
- **Fri:** 🚀 **LAUNCH** (release to public)

**Deliverable:** Cravey v1.0 live on App Store.

---

## 📋 Phase Completion Checklist

**Before marking Phase 6 complete:**

- [ ] Onboarding implemented (WelcomeView + TourView)
- [ ] All UI/UX polish complete (animations, haptics, empty states)
- [ ] All performance targets met (<5s, <10s, <3s)
- [ ] Accessibility compliance (VoiceOver, Dynamic Type, color contrast)
- [ ] Unit test coverage ≥80%
- [ ] All 10 UI tests passing
- [ ] Zero crashers in TestFlight (crash-free rate 99.9%+)
- [ ] TestFlight beta testing complete (10-20 external testers)
- [ ] All "Must Have" and "Should Have" bugs fixed
- [ ] Privacy policy published (accessible via URL)
- [ ] Support page published (FAQ + contact email)
- [ ] App Store assets uploaded (screenshots, description, keywords)
- [ ] App Store submission approved (no pending rejections)
- [ ] 🚀 **Cravey v1.0 live on App Store**

---

## 🚀 Success Metrics (Post-Launch)

### Week 1 Post-Launch (Monitor Closely)
- **Crash-free rate:** ≥99.5% (via App Store Connect)
- **App Store rating:** ≥4.0 stars (target 4.5+)
- **Reviews mentioning "privacy":** ≥30% of positive reviews
- **Reviews mentioning "easy to use":** ≥50% of positive reviews
- **Uninstall rate:** <10% within first week

### Month 1 Post-Launch
- **Active users:** Track via App Store Connect analytics (no in-app analytics!)
- **Average session length:** 2-5 minutes (indicates engagement)
- **Feature usage:** Dashboard views, recordings created (qualitative feedback)

### Months 2-3 Post-Launch
- **App Store ranking:** Top 50 in Health & Fitness (Free) category
- **User retention:** ≥60% of users still logging after 30 days
- **Positive word-of-mouth:** r/Petioles mentions, Twitter shares

---

## 📚 Reference Materials

**Phase 6 Specific:**
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [App Store Connect Guide](https://developer.apple.com/app-store-connect/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Accessibility Best Practices](https://developer.apple.com/accessibility/)
- [Xcode Instruments User Guide](https://help.apple.com/instruments/)

**Performance Optimization:**
- [SwiftData Performance Best Practices](https://developer.apple.com/videos/play/wwdc2024/10137/)
- [Swift Charts Optimization](https://developer.apple.com/documentation/charts)
- [Memory Management in Swift](https://docs.swift.org/swift-book/LanguageGuide/AutomaticReferenceCounting.html)

**App Store Marketing:**
- [App Store Product Page Best Practices](https://developer.apple.com/app-store/product-page/)
- [App Store Optimization (ASO) Guide](https://www.apptamin.com/blog/app-store-optimization/)

---

**[← Back to Overview](./PHASE_OVERVIEW.md)** | **[← Phase 5 (Dashboard)](./PHASE_5.md)**
