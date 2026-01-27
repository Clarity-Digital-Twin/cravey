# UI Redesign Implementation Spec

**Created:** 2026-01-26
**Status:** READY TO IMPLEMENT
**Source:** `docs/brainstorming/HOME_SCREEN_REDESIGN.md`

---

## Overview

Transform the current 3-tab cluttered UI into a clean 4-tab structure:

```
BEFORE (3 tabs):  🏠 Home  📊 Progress  ⚙️ Settings
AFTER (4 tabs):   🏠 Home  📝 Log  📊 History  ⚙️ Settings
```

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

5. **Success Toast**
   - After logging, show success toast (reuse pattern from current HomeView)
   - Toast: "Craving logged" or "Usage logged"

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
- [ ] LogView.swift exists at correct path
- [ ] Two buttons render correctly
- [ ] Tapping "Log Craving" opens CravingLogForm sheet
- [ ] Tapping "Log Usage" opens UsageLogForm sheet
- [ ] Success toast appears after logging
- [ ] Preview works

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
   - Fetch data on appear for selected segment

5. **Empty State**
   - Show appropriate empty state per segment
   - "No cravings logged yet" / "No usage logged yet"

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
- [ ] HistoryView.swift exists at correct path
- [ ] Segmented control toggles between Cravings/Usage
- [ ] CravingListView content displays when Cravings selected
- [ ] UsageListView content displays when Usage selected
- [ ] Swipe-to-delete works
- [ ] Empty states display correctly
- [ ] Preview works

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
   - Calculate from: Date() minus first usage/craving OR user-set quit date

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
- [ ] HomeView no longer contains any List sections
- [ ] HomeView no longer has "+" toolbar button
- [ ] Hero metric displays days abstinent
- [ ] Today's craving/usage counts display
- [ ] Motivational message displays
- [ ] No sheet presentation logic in HomeView
- [ ] Preview works

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
   - DashboardView content merges into HomeView

4. **Default Tab**
   - App launches to Home tab (index 0)

### Acceptance Criteria
- [ ] TabView has exactly 4 tabs: Home, Log, History, Settings
- [ ] Tab icons and labels correct
- [ ] All environment objects properly injected
- [ ] App launches to Home tab
- [ ] Navigation between all tabs works
- [ ] Build succeeds with no warnings

---

## SPEC-05: Cleanup Dead Code

**File:** Multiple files

### Purpose
Remove orphaned code after restructure.

### Requirements

1. **Files to Potentially Remove**
   - Check if `DashboardView.swift` is still needed (content moved to HomeView)
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
- [ ] No dead/orphaned view files
- [ ] No unused imports
- [ ] All tests pass
- [ ] SwiftLint passes
- [ ] Build succeeds

---

## Testing Checklist

After all specs complete:

- [ ] App launches to Home tab with dashboard
- [ ] Home shows hero metric (days abstinent)
- [ ] Home shows today's craving/usage counts
- [ ] Home shows motivational message
- [ ] Log tab shows two buttons
- [ ] Tap "Log Craving" → form sheet opens
- [ ] Submit craving → toast appears → sheet closes
- [ ] Tap "Log Usage" → form sheet opens
- [ ] Submit usage → toast appears → sheet closes
- [ ] History tab shows segmented control
- [ ] Toggle to Cravings → craving list appears
- [ ] Toggle to Usage → usage list appears
- [ ] Swipe to delete works in History
- [ ] Settings tab unchanged, still works
- [ ] Export data works
- [ ] Delete all data works
- [ ] All 42 unit tests pass

---

## File Summary

| Action | File Path |
|--------|-----------|
| **CREATE** | `Cravey/Presentation/Views/Log/LogView.swift` |
| **CREATE** | `Cravey/Presentation/Views/History/HistoryView.swift` |
| **MODIFY** | `Cravey/Presentation/Views/Home/HomeView.swift` |
| **MODIFY** | `Cravey/App/CraveyApp.swift` |
| **REVIEW** | `Cravey/Presentation/Views/Dashboard/DashboardView.swift` |
| **REVIEW** | `Cravey/Presentation/Views/Craving/CravingListView.swift` |
| **REVIEW** | `Cravey/Presentation/Views/Usage/UsageListView.swift` |
