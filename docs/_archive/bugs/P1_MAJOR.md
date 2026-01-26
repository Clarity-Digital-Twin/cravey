# P1 - Major Bugs

**Status:** ACTIVE
**Last Updated:** 2026-01-25

Features not working as specified, significant issues that affect user experience.

---

## BUG-003: ModelContext Thread Safety (nonisolated unsafe)

**Files:**
- `Cravey/Data/Repositories/CravingRepository.swift`
- `Cravey/Data/Repositories/UsageRepository.swift`
**Verify:** `rg -n "MainActor\\.run" Cravey/Data/Repositories/CravingRepository.swift Cravey/Data/Repositories/UsageRepository.swift`

### Problem
```swift
private nonisolated(unsafe) let modelContext: ModelContext
```

Using `nonisolated(unsafe)` is a workaround for Clean Architecture compatibility, but it bypasses Swift's concurrency safety checks.

### Impact
- Potential data races if accessed from multiple threads
- SwiftData runtime warnings: "Unbinding from the main queue"
- Could cause crashes or data corruption under heavy load

### Current Mitigation
All repository access goes through `@MainActor` ViewModels, so in practice it's main-thread only.

### Status
✅ **FIXED (Mitigated)** (2026-01-24)

### Fix Implemented
- All SwiftData reads/writes are wrapped in `MainActor.run { ... }`, ensuring the `ModelContext` is only touched on the main actor.
- `nonisolated(unsafe)` remains confined to storing the reference, but the unsafe access pattern is removed from call sites.

### Acceptance Criteria
- [x] SwiftData access is MainActor-isolated
- [x] No background-thread `ModelContext` access paths

---

## BUG-004: Silently Swallowed Errors in ModelContainerSetup

**File:** `Cravey/Data/Storage/ModelContainerSetup.swift`
**Verify:** `rg -n \"Failed to seed default messages\" Cravey/Data/Storage/ModelContainerSetup.swift`

### Status
✅ **FIXED** (2026-01-24)

### Problem
```swift
let existingMessages = (try? context.fetch(descriptor)) ?? []  // Silent fail

} catch {
    print("[ModelContainerSetup] Failed to seed default messages: \(error)")  // Logged but ignored
}
```

### Impact
- If default motivational messages fail to load, user sees empty list
- No indication to user that something went wrong
- Hard to debug in production

### Fix
```swift
// Option 1: Propagate error
func seedDefaultMessages(context: ModelContext) throws {
    // ...
    let existingMessages = try context.fetch(descriptor)
    // ...
}

// Option 2: Log properly and surface to user
} catch {
    Logger.error("Failed to seed messages: \(error)")
    // Set flag so UI can show "Some features unavailable"
}
```

### Acceptance Criteria
- [x] Errors are logged via OSLog
- [x] No `try?` swallowing fetch errors in seeding

---

## BUG-005: LogUsageUseCase - 6 Parameter Function

**File:** `Cravey/Domain/UseCases/LogUsageUseCase.swift`
**Verify:** `rg -n \"struct LogUsageRequest\" Cravey/Domain/UseCases/LogUsageUseCase.swift`

### Status
✅ **FIXED** (2026-01-24)

### Problem
```swift
func execute(
    timestamp: Date,
    method: String,
    amount: Double,
    triggers: [String],
    location: String?,
    notes: String?
) async throws -> UsageEntity
```

6 parameters violates SwiftLint rule and makes function hard to test/maintain.

### Impact
- SwiftLint warning
- Hard to remember parameter order
- Easy to make mistakes when calling

### Fix
Create a parameter object:
```swift
struct LogUsageRequest {
    let timestamp: Date
    let method: String
    let amount: Double
    let triggers: [String]
    let location: String?
    let notes: String?
}

func execute(_ request: LogUsageRequest) async throws -> UsageEntity
```

### Acceptance Criteria
- [x] Parameter object exists (`LogUsageRequest`)
- [x] Use case signature uses request object

---

## BUG-006: Task.sleep Error Ignored in HomeView

**File:** `Cravey/Presentation/Views/Home/HomeView.swift`
**Verify:** `rg -n \"Task\\.sleep\" Cravey/Presentation/Views/Home/HomeView.swift`

### Problem
```swift
try? await Task.sleep(for: .seconds(2))
showSuccessToast = false
```

### Impact
Low - if sleep fails, toast just disappears immediately. Not critical.

### Fix
```swift
do {
    try await Task.sleep(for: .seconds(2))
} catch {
    // Task was cancelled, that's fine
}
showSuccessToast = false
```

### Priority
Low - but should fix for consistency.

### Status
✅ **FIXED** (2026-01-24)

---

## BUG-012: “Delete All Data” Does Not Delete Recordings/Messages (UI Claim Mismatch)

**Files:**
- `Cravey/Presentation/ViewModels/SettingsViewModel.swift`
- `Cravey/Data/UseCases/SwiftDataDeleteAllUserDataUseCase.swift`
**Verify:** `rg -n \"delete\\(model: RecordingModel\\.self\\)|deleteAllRecordings\\(\" Cravey/Data/UseCases/SwiftDataDeleteAllUserDataUseCase.swift Cravey/Data/Storage/FileStorageManager.swift`

### Status
✅ **FIXED** (2026-01-24)

### Problem
Settings UI states it will delete “cravings, usage logs, and recordings”, but the implementation deletes only:
- `CravingModel`
- `UsageModel`

It does **not** delete:
- `RecordingModel` entries (if/when present)
- recording files in `FileStorageManager` storage
- seeded `MotivationalMessageModel` entries

### Impact
- User expectation mismatch for a destructive action.
- Potential privacy issue if users believe recordings are removed when they are not.

### Fix
- Expand deletion to include all stored models and any on-disk recording files.
- Ensure Settings copy matches actual behavior.

### Acceptance Criteria
- [x] Deletes all SwiftData models (cravings/usages/recordings/messages)
- [x] Deletes on-disk recording directory
- [x] Settings copy matches behavior

---

## BUG-013: Recordings Tab Missing (Spec Drift)

**File:** `Cravey/App/CraveyApp.swift`
**Verify:** `rg -n \"RecordingsView\\(\" Cravey/App/CraveyApp.swift`

### Status
✅ **FIXED** (2026-01-24)

### Problem
Master UX spec defines a 4-tab layout including a **Recordings** tab, but the app currently ships only:
- Home
- Progress
- Settings

### Impact
- MVP feature gap (Recordings feature is not accessible).
- Blocks implementation of “Quick Play” on Home.

### Fix
- Add the Recordings tab and minimal placeholder view, or explicitly mark as deferred and remove dependent UX copy.

### Acceptance Criteria
- [x] Tab bar includes a Recordings tab
- [x] Recordings tab is wired to a concrete view (placeholder)

---

## BUG-015: First Launch & Onboarding Not Implemented (Spec Gap)

**File:** `Cravey/App/CraveyApp.swift`
**Spec:** `docs/master/UX_FLOW_SPEC.md` (Flow 1), `docs/master/MVP_PRODUCT_SPEC.md` (Feature 0)
**Verify:** `rg -n "TabView\\s*\\{" Cravey/App/CraveyApp.swift`

### Problem
Master specs require a first-launch onboarding flow (welcome + optional tour + permission education). The current app
launches directly into the main tab UI with no onboarding gate.

### Impact
- Spec non-compliance (MVP feature gap)
- Weaker privacy trust-building and expectation setting

### Status
🔴 **OPEN** (2026-01-25)

### Acceptance Criteria
- [ ] First launch shows Welcome screen before TabView
- [ ] Returning launches skip onboarding
- [ ] UI test asserts onboarding appears only once

---

## BUG-016: Home Tab UI Does Not Match UX Flow (Primary Actions + Quick Play)

**File:** `Cravey/Presentation/Views/Home/HomeView.swift`
**Spec:** `docs/master/UX_FLOW_SPEC.md` (Flow 2: Home Tab)
**Verify:** `rg -n "Menu\\s*\\{" Cravey/Presentation/Views/Home/HomeView.swift`

### Problem
UX spec defines Home as a “Daily Hub” with:
- Full-width **Log Craving** and **Log Usage** primary action buttons
- A **Quick Play** section for top 3 recordings + a “Record New” CTA

Current implementation uses a `+` toolbar menu and a `List` of recent logs, and Quick Play is not implemented.

### Impact
- UX_FLOW_SPEC mismatch for MVP
- Harder “crisis-mode” usability (primary actions are less prominent)
- Recordings feature (Quick Play) is blocked by Home design mismatch

### Status
🔴 **OPEN** (2026-01-25)

### Acceptance Criteria
- [ ] Home shows primary actions as buttons (not a toolbar menu)
- [ ] Quick Play shows top 3 recordings (by playCount DESC) when recordings exist
- [ ] Empty-state tip + deep-link to Recordings tab when none exist
- [ ] UI tests validate Home primary actions + Quick Play behavior

---

## BUG-017: Progress Dashboard Missing Date Filter + Chart-Based Metrics (Spec Gap)

**File:** `Cravey/Presentation/Views/Dashboard/DashboardView.swift`
**Spec:** `docs/master/UX_FLOW_SPEC.md` (Flow 6), `docs/master/MVP_PRODUCT_SPEC.md` (Feature 4)
**Verify:** `rg -n "refreshable|ScrollView" Cravey/Presentation/Views/Dashboard/DashboardView.swift`

### Problem
Specs require:
- Sticky date filter chips: **7D / 30D / 90D / All**
- Chart-based dashboard (Swift Charts) for trends + trigger breakdown
- Contextual summary copy (“You’re building awareness! 💪”)

Current Dashboard is a static set of metric cards with no date filter and no charts.

### Impact
- Spec non-compliance (MVP feature gap)
- Reduced clarity/insight vs planned “patterns over time” experience

### Status
🔴 **OPEN** (2026-01-25)

### Acceptance Criteria
- [ ] Sticky date filter implemented and drives all metrics
- [ ] Craving intensity trend is rendered as a line chart
- [ ] Trigger breakdown matches spec (top triggers across cravings + usage)
- [ ] UI tests cover filter switching + empty states

---

## BUG-018: Recordings Feature Stubbed (No Recording/Playback UI)

**File:** `Cravey/Presentation/Views/Recordings/RecordingsView.swift`
**Spec:** `docs/master/UX_FLOW_SPEC.md` (Flow 5), `docs/master/MVP_PRODUCT_SPEC.md` (Feature 3)
**Verify:** `rg -n "Your motivational audio/video messages will live here" Cravey/Presentation/Views/Recordings/RecordingsView.swift`

### Problem
Recordings are an MVP feature (record + playback + deletion). Current implementation is a placeholder screen only.

### Impact
- MVP feature gap (major)
- Home “Quick Play” cannot be implemented end-to-end
- Missing permission flows (camera/mic), AVFoundation capture/playback, and library management

### Status
🔴 **OPEN** (2026-01-25)

### Acceptance Criteria
- [ ] Record audio/video to local storage (Documents/Recordings)
- [ ] Playback works reliably and updates playCount/lastPlayedAt
- [ ] Delete is atomic (DB + file)
- [ ] UI tests cover record/play/delete happy path (where feasible)

---

## Summary

| Bug ID | Description | Status | Priority |
|--------|-------------|--------|----------|
| BUG-003 | SwiftData thread safety | ✅ FIXED | High |
| BUG-004 | Swallowed errors in seed data | ✅ FIXED | High |
| BUG-005 | 6 param function violation | ✅ FIXED | Medium |
| BUG-006 | Task.sleep error ignored | ✅ FIXED | Low |
| BUG-012 | Delete All Data incomplete | ✅ FIXED | High |
| BUG-013 | Recordings tab missing | ✅ FIXED | Medium |
| BUG-015 | Onboarding flow missing | 🔴 OPEN | High |
| BUG-016 | Home tab UX mismatch | 🔴 OPEN | High |
| BUG-017 | Dashboard spec gap (filter + charts) | 🔴 OPEN | High |
| BUG-018 | Recordings feature stubbed | 🔴 OPEN | High |
