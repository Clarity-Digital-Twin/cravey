# UI Redesign Implementation Spec

**Created:** 2026-01-26
**Status:** ✅ IMPLEMENTED (2026-01-27)
**Source:** `docs/brainstorming/HOME_SCREEN_REDESIGN.md`

---

## Overview

Transform the current 3-tab cluttered UI into a clean 4-tab structure:

```
BEFORE (current): 🏠 Home  📊 Progress  🎬 Recordings  ⚙️ Settings
AFTER (4 tabs):   🏠 Home  📝 Log  📊 History  ⚙️ Settings
```

**Note:** The Recordings feature is not implemented yet (AVFoundation + UI). This redesign removes the Recordings tab for now; it can return later as a 5th tab when the feature ships.

---

## Implementation Order

| Spec | Description | Depends On |
|------|-------------|------------|
| **SPEC-01** | Create LogView (new file) | None |
| **SPEC-02** | Create HistoryView (new file) | None |
| **SPEC-03** | Refactor HomeView to dashboard-only | None |
| **SPEC-04** | Update CraveyApp tab structure | SPEC-01, SPEC-02, SPEC-03 |
| **SPEC-05** | Cleanup dead code | SPEC-04 |

**Parallel work:** SPEC-01, SPEC-02, SPEC-03 can be done in parallel.
**Sequential:** SPEC-04 requires all previous specs. SPEC-05 is cleanup.

---

## SPEC-01: Create LogView

**File:** `Cravey/Presentation/Views/Log/LogView.swift` (NEW)

### Purpose
A simple view with two big buttons: "Log Craving" and "Log Usage".

### Requirements

1. **Layout**
   - Navigation title: "Log Entry"
   - Centered content with two large tappable cards
   - Prompt text: "What would you like to log?"

2. **Log Craving Button**
   - Icon: 🧠 (or SF Symbol `brain.head.profile`)
   - Title: "Log Craving"
   - Subtitle: "Track an urge you experienced"
   - Tap → present `CravingLogForm` as sheet

3. **Log Usage Button**
   - Icon: 🌿 (or SF Symbol `leaf.fill`)
   - Title: "Log Usage"
   - Subtitle: "Record cannabis consumption"
   - Tap → present `UsageLogForm` as sheet

4. **State Management**
   - `@State private var showCravingSheet = false`
   - `@State private var showUsageSheet = false`
   - `@State private var cravingLogViewModel: CravingLogViewModel?`
   - `@State private var usageLogViewModel: UsageLogViewModel?`

5. **Dependency Injection**
   - Use `@Environment(DependencyContainer.self)` to create fresh log ViewModels per sheet presentation.
   - Use `@Environment(CravingListViewModel.self)` and `@Environment(UsageListViewModel.self)` to refresh History data after a successful save.

6. **Success Toast**
   - After the sheet dismisses, show success toast (reuse pattern from current HomeView / UX_FLOW:396-405)
   - Toast: "Craving logged" or "Usage logged"
   - Implementation detail: read `viewModel.didSucceed` in the sheet `onDismiss` before resetting the stored ViewModel, then trigger the toast.

### Wireframe
```
┌─────────────────────────────────┐
│         Log Entry               │
│                                 │
│   What would you like to log?   │
│                                 │
│   ┌─────────────────────────┐   │
│   │    🧠 Log Craving       │   │
│   │    Track an urge you    │   │
│   │    experienced          │   │
│   └─────────────────────────┘   │
│                                 │
│   ┌─────────────────────────┐   │
│   │    🌿 Log Usage         │   │
│   │    Record cannabis      │   │
│   │    consumption          │   │
│   └─────────────────────────┘   │
└─────────────────────────────────┘
```

### Acceptance Criteria
- [x] LogView.swift exists at correct path
- [x] Two buttons render correctly
- [x] Tapping "Log Craving" opens CravingLogForm sheet
- [x] Tapping "Log Usage" opens UsageLogForm sheet
- [x] Success toast appears after logging
- [x] Preview works

---

## SPEC-02: Create HistoryView

**File:** `Cravey/Presentation/Views/History/HistoryView.swift` (NEW)

### Purpose
A view with a segmented control to toggle between Cravings and Usage lists.

### Requirements

1. **Layout**
   - Navigation title: "History"
   - Segmented control at top: [Cravings | Usage]
   - List below showing selected type

2. **Segmented Control**
   - Two segments: "Cravings" and "Usage"
   - Default selection: "Cravings"
   - `@State private var selectedSegment: HistorySegment = .cravings`

3. **List Content**
   - When "Cravings" selected: embed existing `CravingListView`
   - When "Usage" selected: embed existing `UsageListView`
   - Swipe-to-delete works (already implemented in list views)

4. **ViewModels**
   - Receive `CravingListViewModel` from environment
   - Receive `UsageListViewModel` from environment
   - Switching segments should fetch data for that segment at least once
     - OK to rely on existing `.task { await viewModel.fetch…() }` behavior inside the embedded list views.

5. **Empty State**
   - Show appropriate empty state per segment
   - "No cravings logged yet" / "No usage logged yet"
   - Ensure empty-state copy does not reference the old "+" button (logging now lives in the Log tab).

### Wireframe
```
┌─────────────────────────────────┐
│           History               │
│                                 │
│   ┌───────────┬───────────┐     │
│   │ Cravings  │   Usage   │     │
│   │  (sel)    │           │     │
│   └───────────┴───────────┘     │
│                                 │
│   [CravingListView content]     │
│   or                            │
│   [UsageListView content]       │
└─────────────────────────────────┘
```

### Acceptance Criteria
- [x] HistoryView.swift exists at correct path
- [x] Segmented control toggles between Cravings/Usage
- [x] CravingListView content displays when Cravings selected
- [x] UsageListView content displays when Usage selected
- [x] Swipe-to-delete works
- [x] Empty states display correctly
- [x] Preview works

---

## SPEC-03: Refactor HomeView to Dashboard-Only

**File:** `Cravey/Presentation/Views/Home/HomeView.swift` (MODIFY)

### Purpose
Strip HomeView down to a pure dashboard. Remove all lists and logging logic.

### Requirements

1. **Remove**
   - Remove `Section("Recent Cravings")` and CravingListView
   - Remove `Section("Recent Usage")` and UsageListView
   - Remove toolbar "+" menu button
   - Remove all sheet presentation logic for logging
   - Remove `cravingLogViewModel` and `usageLogViewModel` state
   - Remove success toast logic (moves to LogView)

2. **Keep/Add**
   - Navigation title: "My Recovery"
   - Hero metric card (days abstinent) - use existing DashboardView content or inline
   - Today's stats: craving count, usage count (tappable → could navigate to History)
   - Motivational message card

3. **Hero Metric**
   - Large number showing days abstinent
   - "DAYS abstinent" label
   - "Since [start date]" subtitle
   - Calculate from: `DashboardViewModel.currentStreak` (days since most recent usage entry)
   - "Since" displays the date of the most recent usage entry
   - If no usage entries exist, show `0` days and a supportive subtitle like "Start by logging a usage entry"

4. **Today's Stats**
   - Two small cards side-by-side
   - Left: "[N] cravings" (today's count)
   - Right: "[N] uses" (today's count)

5. **Motivational Message**
   - Card with encouraging text
   - Rotate daily or randomly from a list
   - Examples: "Every urge you resist makes you stronger"

### Wireframe
```
┌─────────────────────────────────┐
│       My Recovery               │
│                                 │
│   ┌───────────────────────┐     │
│   │       12              │     │
│   │      DAYS             │     │
│   │    abstinent          │     │
│   │   Since Jan 14, 2026  │     │
│   └───────────────────────┘     │
│                                 │
│   Today                         │
│   ┌───────────┬───────────┐     │
│   │     2     │     0     │     │
│   │ cravings  │   uses    │     │
│   └───────────┴───────────┘     │
│                                 │
│   ┌─────────────────────────┐   │
│   │  💪 "Every urge you     │   │
│   │     resist makes you    │   │
│   │     stronger"           │   │
│   └─────────────────────────┘   │
└─────────────────────────────────┘
```

### Acceptance Criteria
- [x] HomeView no longer contains any List sections
- [x] HomeView no longer has "+" toolbar button
- [x] Hero metric displays days abstinent
- [x] Today's craving/usage counts display
- [x] Motivational message displays
- [x] No sheet presentation logic in HomeView
- [x] Preview works

---

## SPEC-04: Update CraveyApp Tab Structure

**File:** `Cravey/App/CraveyApp.swift` (MODIFY)

### Purpose
Change from 3-tab to 4-tab structure.

### Requirements

1. **Tab Bar Structure**
   ```swift
   TabView {
       HomeView()
           .tabItem {
               Label("Home", systemImage: "house.fill")
           }

       LogView()
           .tabItem {
               Label("Log", systemImage: "plus.circle.fill")
           }

       HistoryView()
           .tabItem {
               Label("History", systemImage: "clock.fill")
           }

       SettingsView()
           .tabItem {
               Label("Settings", systemImage: "gearshape.fill")
           }
   }
   ```

2. **Environment Injection**
   - Inject `DependencyContainer` at TabView level
   - Inject `CravingListViewModel` for HistoryView
   - Inject `UsageListViewModel` for HistoryView
   - Inject `DashboardViewModel` for HomeView (if needed)

3. **Remove**
   - Remove old "Progress" tab (DashboardView standalone)
   - Remove Recordings tab (feature deferred)
   - DashboardView content merges into HomeView (or HomeView replaces it entirely)

4. **Default Tab**
   - App launches to Home tab (index 0)

### Acceptance Criteria
- [x] TabView has exactly 4 tabs: Home, Log, History, Settings
- [x] Tab icons and labels correct
- [x] All environment objects properly injected
- [x] App launches to Home tab
- [x] Navigation between all tabs works
- [x] Build succeeds with no warnings

---

## SPEC-05: Cleanup Dead Code

**File:** Multiple files

### Purpose
Remove orphaned code after restructure.

### Requirements

1. **Files to Potentially Remove**
   - Check if `DashboardView.swift` is still needed (content moved to HomeView)
   - Check if `RecordingsView.swift` is still needed (tab removed)
   - Remove any unused view files

2. **Code to Remove**
   - Old 3-tab references
   - Unused imports
   - Dead ViewModel instantiation

3. **Verify**
   - All tests still pass
   - No compiler warnings
   - No unused file warnings from SwiftLint

### Acceptance Criteria
- [x] No dead/orphaned view files
- [x] No unused imports
- [x] All tests pass
- [x] SwiftLint passes
- [x] Build succeeds

---

## Testing Checklist

After all specs complete:

- [x] App launches to Home tab with dashboard
- [x] Home shows hero metric (days abstinent)
- [x] Home shows today's craving/usage counts
- [x] Home shows motivational message
- [x] Log tab shows two buttons
- [x] Tap "Log Craving" → form sheet opens
- [x] Submit craving → toast appears → sheet closes
- [x] Tap "Log Usage" → form sheet opens
- [x] Submit usage → toast appears → sheet closes
- [x] History tab shows segmented control
- [x] Toggle to Cravings → craving list appears
- [x] Toggle to Usage → usage list appears
- [x] Swipe to delete works in History
- [x] Settings tab unchanged, still works
- [x] Export data works
- [x] Delete all data works
- [x] All 48 unit tests pass

---

## File Summary

| Action | File Path | Status |
|--------|-----------|--------|
| **CREATE** | `Cravey/Presentation/Views/Log/LogView.swift` | ✅ Done |
| **CREATE** | `Cravey/Presentation/Views/History/HistoryView.swift` | ✅ Done |
| **MODIFY** | `Cravey/Presentation/Views/Home/HomeView.swift` | ✅ Done |
| **MODIFY** | `Cravey/App/CraveyApp.swift` | ✅ Done |
| **DELETE** | `Cravey/Presentation/Views/Dashboard/DashboardView.swift` | ✅ Removed |
| **KEEP** | `Cravey/Presentation/Views/Craving/CravingListView.swift` | ✅ Embedded in HistoryView |
| **KEEP** | `Cravey/Presentation/Views/Usage/UsageListView.swift` | ✅ Embedded in HistoryView |
