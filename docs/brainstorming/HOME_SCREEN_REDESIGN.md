# Home Screen Redesign Brainstorming

**Created:** 2026-01-26
**Status:** DRAFT - Options for Discussion

## Current State Analysis

### What We Have Now
```
┌─────────────────────────────────┐
│           Home                  │ ← Generic title
│  ┌─────────────────────────┐    │
│  │ + (menu: Log Craving/   │    │ ← Hidden behind menu
│  │    Log Usage)           │    │
│  └─────────────────────────┘    │
│                                 │
│  Recent Cravings               │
│  ┌─────────────────────────┐    │
│  │ 5  2 hr, 1 min          │    │ ← Intensity badge + time
│  │    Sad                   │    │ ← One trigger shown
│  └─────────────────────────┘    │
│                                 │
│  Recent Usage                  │
│  ┌─────────────────────────┐    │
│  │ Bowls        0.5 bowls  │    │
│  │ Jan 26, 2026 at 6:30 PM │    │ ← Different date format!
│  │ ⚡ Sad                   │    │
│  │ 📍 Home                  │    │
│  └─────────────────────────┘    │
│                                 │
│ ═══════════════════════════════ │
│ 🏠 Home  📊 Progress  ⚙️ Settings│
└─────────────────────────────────┘
```

### Problems Identified

1. **Cluttered mixed content** - Cravings and usage in one list is confusing
2. **No clear primary action** - "+" is hidden in a menu (2 taps to log)
3. **Inconsistent card design** - Craving cards ≠ Usage cards
4. **No hero metric** - What's the user's current status at a glance?
5. **Generic title** - "Home" says nothing; "Cannabis Logs" is clinical
6. **No emotional support** - Pure data, no encouragement
7. **Missing context** - How long since last craving? Last usage?

---

## Research: What Successful Apps Do

### I Am Sober (4.8★, 1M+ downloads)
- **Hero metric**: Giant sobriety counter (days/hours/minutes) front and center
- **Daily ritual**: Morning pledge, evening review
- **Craving log**: Separate "Log Urge" button with guided mindfulness
- **Tab bar**: Today | Milestones | Community | Progress | Settings
- **Emotional tone**: Compassionate, celebrates progress, no shame

### Grounded (Cannabis-specific)
- **Hero metric**: Days abstinent counter with withdrawal timeline
- **Journal**: Separate from stats
- **Progress**: Visual timeline of what to expect during detox

### Key Pattern: Separate Concerns
**All successful apps separate:**
1. Dashboard/Status (hero metric, current state)
2. Logging (quick action, one-tap access)
3. History/Review (list view, patterns)
4. Progress/Stats (charts, milestones)

---

## Option A: Tab-Based Separation (Recommended)

### Concept
Split craving and usage into their own dedicated tabs. Home becomes a dashboard with hero metric.

### Wireframe
```
┌─────────────────────────────────┐
│         My Recovery             │
│                                 │
│   ┌───────────────────────┐     │
│   │                       │     │
│   │     12 DAYS           │     │ ← Hero metric
│   │     abstinent         │     │
│   │                       │     │
│   │   23h since craving   │     │ ← Secondary context
│   └───────────────────────┘     │
│                                 │
│   Today                         │
│   ┌───────┐    ┌───────┐        │
│   │ 2     │    │ 0     │        │
│   │cravings│    │ uses  │        │ ← Quick stats
│   └───────┘    └───────┘        │
│                                 │
│   ┌─────────────────────────┐   │
│   │ 💪 "Every urge resisted │   │ ← Motivational message
│   │    is a victory"        │   │
│   └─────────────────────────┘   │
│                                 │
│ ═══════════════════════════════ │
│ 🏠    📝    📈    📊    ⚙️      │
│ Home  Log  Cravings Usage Settings│
└─────────────────────────────────┘
```

### Tab Structure
| Tab | Purpose | Screens |
|-----|---------|---------|
| **Home** | Dashboard, hero metric, today's summary | DashboardView (redesigned) |
| **Log** | Quick logging (sheet picker) | CravingLogForm, UsageLogForm |
| **Cravings** | Craving history list | CravingListView |
| **Usage** | Usage history list | UsageListView |
| **Settings** | Export, delete, preferences | SettingsView |

### Pros
- Clear separation of concerns
- One-tap access to log anything
- Dedicated space for each data type
- Room for hero metric
- Matches user mental model

### Cons
- 5 tabs (borderline crowded)
- More navigation structure changes
- Progress tab merged into Home

---

## Option B: Floating Action Button (FAB)

### Concept
Keep current structure but add prominent FAB for logging. Separate lists into sub-tabs.

### Wireframe
```
┌─────────────────────────────────┐
│         My Recovery             │
│                                 │
│   ┌───────────────────────┐     │
│   │     12 DAYS           │     │ ← Hero metric
│   │     abstinent         │     │
│   └───────────────────────┘     │
│                                 │
│   ┌─────────┬─────────┐         │
│   │ Cravings│  Usage  │         │ ← Segmented control
│   └─────────┴─────────┘         │
│                                 │
│   [Selected tab's list here]    │
│   ┌─────────────────────────┐   │
│   │ 5  2 hr ago             │   │
│   │    Sad                  │   │
│   └─────────────────────────┘   │
│   ┌─────────────────────────┐   │
│   │ 3  Yesterday            │   │
│   │    Bored, Stressed      │   │
│   └─────────────────────────┘   │
│                                 │
│                        ┌───┐    │
│                        │ + │    │ ← FAB (always visible)
│                        └───┘    │
│ ═══════════════════════════════ │
│ 🏠 Home  📊 Progress  ⚙️ Settings│
└─────────────────────────────────┘
```

### Pros
- Minimal structural change
- FAB is discoverable (one tap to log)
- Segmented control separates lists
- Keeps 3-tab simplicity

### Cons
- Still mixing concerns on one screen
- Segmented control adds cognitive load
- FAB can overlap content

---

## Option C: Dashboard + Quick Actions (Hybrid)

### Concept
Home is pure dashboard. Cravings/Usage accessible via quick action cards or swipe.

### Wireframe
```
┌─────────────────────────────────┐
│         My Recovery             │
│                                 │
│   ┌───────────────────────┐     │
│   │     12 DAYS           │     │
│   │     abstinent         │     │
│   │   ──────────────────  │     │ ← Progress bar to goal
│   └───────────────────────┘     │
│                                 │
│   ┌─────────────┬─────────────┐ │
│   │ + Log       │ + Log       │ │ ← Quick action cards
│   │   Craving   │   Usage     │ │
│   └─────────────┴─────────────┘ │
│                                 │
│   Recent Activity               │
│   ┌─────────────────────────┐   │
│   │ 🟡 Craving (5) - 2h ago │   │ ← Unified activity feed
│   │ 🟢 Usage - Yesterday    │   │
│   │ 🟡 Craving (3) - 2 days │   │
│   └─────────────────────────┘   │
│                                 │
│   View All Cravings →           │
│   View All Usage →              │
│                                 │
│ ═══════════════════════════════ │
│ 🏠 Home  📊 Progress  ⚙️ Settings│
└─────────────────────────────────┘
```

### Pros
- Dashboard-first approach
- Quick actions prominent
- Unified activity feed tells story
- Keeps 3-tab simplicity
- Links to full lists

### Cons
- Activity feed mixes types (could confuse)
- Requires designing unified activity card
- "View All" is extra navigation

---

## Option D: Radical Simplicity (Crisis-Focused)

### Concept
For users in crisis, show ONLY what matters: big button to log craving, immediate support.

### Wireframe
```
┌─────────────────────────────────┐
│                                 │
│                                 │
│   ┌───────────────────────┐     │
│   │                       │     │
│   │  Having a craving?    │     │
│   │                       │     │
│   │  ┌─────────────────┐  │     │
│   │  │   LOG CRAVING   │  │     │ ← Giant primary CTA
│   │  └─────────────────┘  │     │
│   │                       │     │
│   │  or                   │     │
│   │                       │     │
│   │  ┌─────────────────┐  │     │
│   │  │   Log Usage     │  │     │ ← Secondary CTA
│   │  └─────────────────┘  │     │
│   │                       │     │
│   └───────────────────────┘     │
│                                 │
│   ┌─────────────────────────┐   │
│   │ 💪 12 days abstinent    │   │ ← Small status bar
│   │    2 cravings today     │   │
│   └─────────────────────────┘   │
│                                 │
│ ═══════════════════════════════ │
│ 🏠 Home  📊 Progress  ⚙️ Settings│
└─────────────────────────────────┘
```

### Pros
- Crisis-optimized (large tap targets)
- Zero cognitive load
- Immediate action
- Stats de-emphasized (less triggering)

### Cons
- No history visible on home
- Requires tapping to see past entries
- May feel empty/sparse

---

## The Core Question: Where Does Each Thing Live?

### Current (Confused)
```
HOME SCREEN = Everything mixed together
├── Recent Cravings list
├── Recent Usage list
└── + button (hidden menu)
```

### Option A: 5 Tabs (Full Separation)
```
TAB BAR
├── 🏠 Home      → Dashboard only (hero metric, motivation, today's stats)
├── 📝 Log       → Picker sheet: "Log Craving" or "Log Usage" buttons
├── 🧠 Cravings  → Full craving history list (scroll, filter, search)
├── 🌿 Usage     → Full usage history list (scroll, filter, search)
└── ⚙️ Settings  → Export, delete, preferences
```

**Flow Example:**
```
User opens app
    → Sees dashboard: "12 days abstinent, 2 cravings today"
    → Taps 📝 Log tab
    → Sees two big buttons: [Log Craving] [Log Usage]
    → Taps "Log Craving"
    → Form sheet opens
    → Submits
    → Back to Log tab (or auto-navigate to Cravings tab)
```

### Option A-Alt: 4 Tabs (Cleaner)
```
TAB BAR
├── 🏠 Home      → Dashboard (hero metric, motivation)
├── 📝 Log       → Picker: [Log Craving] [Log Usage]
├── 📊 History   → Segmented control: [Cravings | Usage] + list below
└── ⚙️ Settings  → Export, delete, preferences
```

**Why 4 might be better:**
- Less crowded tab bar
- Cravings and Usage are related (both are "history")
- Segmented control is a common iOS pattern

### Option B: 3 Tabs + FAB (Minimal Change)
```
TAB BAR
├── 🏠 Home      → Hero metric + segmented [Cravings|Usage] list
├── 📊 Progress  → Charts, streaks, patterns
└── ⚙️ Settings  → Export, delete

FLOATING ACTION BUTTON (always visible)
└── + → Picker sheet: [Log Craving] [Log Usage]
```

**Home screen contains:**
```
┌─────────────────────────────────┐
│ Hero Metric: 12 days abstinent  │
├─────────────────────────────────┤
│ [Cravings] [Usage]  ← segmented │
├─────────────────────────────────┤
│ List of selected type           │
│ - Item 1                        │
│ - Item 2                        │
│ - Item 3                        │
└─────────────────────────────────┘
         [+] ← FAB bottom-right
```

---

## Decision Matrix

| Question | Option A (5 tabs) | Option A-Alt (4 tabs) | Option B (3 tabs + FAB) |
|----------|-------------------|----------------------|-------------------------|
| **Are cravings/usage on same screen?** | ❌ No, separate tabs | ❌ No, but same tab with toggle | ✅ Yes, with toggle |
| **How many taps to log?** | 2 (tab → button) | 2 (tab → button) | 1 (FAB → button) |
| **How many taps to view cravings?** | 1 (tap tab) | 2 (tab → toggle) | 2 (already home → toggle) |
| **Room for future Recordings tab?** | ✅ Yes, add 6th tab | ✅ Yes, add 5th tab | ⚠️ Tight, would need 4th |
| **Complexity to implement** | Medium | Medium | Low |
| **Matches I Am Sober pattern?** | ✅ Yes | ✅ Yes | ❌ No |

---

## My Recommendation

**Go with Option A-Alt (4 tabs):**

```
┌─────────┬─────────┬─────────┬─────────┐
│ 🏠      │ 📝      │ 📊      │ ⚙️      │
│ Home    │ Log     │ History │ Settings│
└─────────┴─────────┴─────────┴─────────┘
```

**Why:**
1. Clean 4-tab structure (room to add Recordings later = 5 tabs)
2. Home is JUST dashboard (no lists cluttering it)
3. Log tab = one tap to see logging options
4. History keeps cravings/usage together but separated via toggle
5. Matches iOS conventions

**Screen contents:**

| Tab | What User Sees |
|-----|----------------|
| **Home** | Hero metric (days abstinent), today's craving/usage count, motivational message, maybe "Watch a Recording" button (future) |
| **Log** | Two big buttons: "Log Craving" and "Log Usage". Tapping either opens the form sheet. |
| **History** | Segmented control [Cravings \| Usage] at top, list of entries below. Swipe to delete. Tap to edit. |
| **Settings** | Export data, delete all data, app info |

---

## EXPLICIT Screen-by-Screen Wireframes (Option A-Alt: 4 Tabs)

### Screen 1: HOME TAB (Dashboard Only - NO Lists)

```
┌─────────────────────────────────┐
│ ←  My Recovery            ⚙️    │  ← Nav bar (optional settings shortcut)
│                                 │
│   ┌───────────────────────┐     │
│   │                       │     │
│   │       12              │     │  ← BIG number
│   │      DAYS             │     │
│   │    abstinent          │     │  ← Label
│   │                       │     │
│   │   Since Jan 14, 2026  │     │  ← Start date
│   └───────────────────────┘     │
│                                 │
│   Today's Activity              │  ← Section header
│   ┌───────────┬───────────┐     │
│   │     2     │     0     │     │
│   │ cravings  │   uses    │     │  ← Quick stats (tap to go to History)
│   └───────────┴───────────┘     │
│                                 │
│   ┌─────────────────────────┐   │
│   │  💪 "Every urge you     │   │
│   │     resist makes you    │   │  ← Motivational message (rotates)
│   │     stronger"           │   │
│   └─────────────────────────┘   │
│                                 │
│   ┌─────────────────────────┐   │
│   │  🎬 Watch a Recording   │   │  ← FUTURE: Quick access to recordings
│   └─────────────────────────┘   │
│                                 │
│ ═══════════════════════════════ │
│ 🏠      📝       📊       ⚙️    │
│ Home    Log    History Settings │  ← Tab bar (Home selected)
└─────────────────────────────────┘
```

**What's NOT on Home:**
- ❌ No craving list
- ❌ No usage list
- ❌ No forms
- ❌ No clutter

---

### Screen 2: LOG TAB (Action Buttons Only)

```
┌─────────────────────────────────┐
│           Log Entry             │  ← Simple title
│                                 │
│                                 │
│                                 │
│   What would you like to log?   │  ← Prompt
│                                 │
│   ┌─────────────────────────┐   │
│   │                         │   │
│   │    🧠 Log Craving       │   │  ← BIG tappable button
│   │                         │   │
│   │    Track an urge you    │   │
│   │    resisted             │   │  ← Helper text
│   │                         │   │
│   └─────────────────────────┘   │
│                                 │
│   ┌─────────────────────────┐   │
│   │                         │   │
│   │    🌿 Log Usage         │   │  ← BIG tappable button
│   │                         │   │
│   │    Record cannabis      │   │
│   │    consumption          │   │  ← Helper text
│   │                         │   │
│   └─────────────────────────┘   │
│                                 │
│                                 │
│ ═══════════════════════════════ │
│ 🏠      📝       📊       ⚙️    │
│ Home    Log    History Settings │  ← Tab bar (Log selected)
└─────────────────────────────────┘
```

**Tap "Log Craving" → Opens CravingLogForm as sheet**
**Tap "Log Usage" → Opens UsageLogForm as sheet**

---

### Screen 3: HISTORY TAB (Segmented Lists)

```
┌─────────────────────────────────┐
│           History               │
│                                 │
│   ┌───────────┬───────────┐     │
│   │ Cravings  │   Usage   │     │  ← Segmented control (toggle)
│   │  (sel)    │           │     │
│   └───────────┴───────────┘     │
│                                 │
│   ┌─────────────────────────┐   │
│   │ 🟡 5    2 hours ago     │   │  ← Intensity badge + relative time
│   │    Sad, Bored           │   │  ← Triggers
│   │    📍 Home              │   │  ← Location (optional)
│   └─────────────────────────┘   │
│   ┌─────────────────────────┐   │
│   │ 🟠 7    Yesterday       │   │
│   │    Stressed, Hungry     │   │
│   │    📍 Work              │   │
│   └─────────────────────────┘   │
│   ┌─────────────────────────┐   │
│   │ 🟢 3    2 days ago      │   │
│   │    Bored                │   │
│   └─────────────────────────┘   │
│                                 │
│   [Load more...]                │
│                                 │
│ ═══════════════════════════════ │
│ 🏠      📝       📊       ⚙️    │
│ Home    Log    History Settings │  ← Tab bar (History selected)
└─────────────────────────────────┘
```

**Toggle to "Usage":**

```
┌─────────────────────────────────┐
│           History               │
│                                 │
│   ┌───────────┬───────────┐     │
│   │ Cravings  │   Usage   │     │
│   │           │   (sel)   │     │  ← Usage selected
│   └───────────┴───────────┘     │
│                                 │
│   ┌─────────────────────────┐   │
│   │ 🌿 Bowls    0.5 bowls   │   │  ← Method + amount
│   │    Yesterday 6:30 PM    │   │  ← Timestamp
│   │    Sad                  │   │  ← Triggers
│   │    📍 Home              │   │  ← Location
│   └─────────────────────────┘   │
│   ┌─────────────────────────┐   │
│   │ 🌿 Vape     3 hits      │   │
│   │    Jan 24, 2026         │   │
│   │    Bored, Anxious       │   │
│   └─────────────────────────┘   │
│                                 │
│ ═══════════════════════════════ │
│ 🏠      📝       📊       ⚙️    │
│ Home    Log    History Settings │
└─────────────────────────────────┘
```

**Swipe left on any row → Delete**
**Tap any row → Edit sheet (future)**

---

### Screen 4: SETTINGS TAB (Unchanged)

```
┌─────────────────────────────────┐
│           Settings              │
│                                 │
│   Data                          │
│   ┌─────────────────────────┐   │
│   │ 📤 Export Data          │   │  ← Exports JSON
│   └─────────────────────────┘   │
│   ┌─────────────────────────┐   │
│   │ 🗑️ Delete All Data      │   │  ← Confirmation required
│   └─────────────────────────┘   │
│                                 │
│   About                         │
│   ┌─────────────────────────┐   │
│   │ ℹ️ Version 1.0.0        │   │
│   └─────────────────────────┘   │
│                                 │
│                                 │
│                                 │
│                                 │
│                                 │
│                                 │
│ ═══════════════════════════════ │
│ 🏠      📝       📊       ⚙️    │
│ Home    Log    History Settings │  ← Tab bar (Settings selected)
└─────────────────────────────────┘
```

---

## Navigation Flow Diagram

```
                    APP LAUNCH
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│                         TAB BAR                                 │
├─────────────┬─────────────┬─────────────┬─────────────────────┤
│             │             │             │                      │
│   🏠 HOME   │   📝 LOG    │  📊 HISTORY │   ⚙️ SETTINGS        │
│             │             │             │                      │
│  Dashboard  │  2 Buttons  │  Segmented  │   Export/Delete     │
│  - Hero     │  - Craving  │  [Crav|Use] │                      │
│  - Stats    │  - Usage    │  + List     │                      │
│  - Motiv.   │             │             │                      │
│             │      │      │             │                      │
└─────────────┴──────┼──────┴─────────────┴─────────────────────┘
                     │
         ┌───────────┴───────────┐
         │                       │
         ▼                       ▼
   ┌───────────┐           ┌───────────┐
   │  Craving  │           │   Usage   │
   │   Form    │           │   Form    │
   │  (Sheet)  │           │  (Sheet)  │
   └───────────┘           └───────────┘
         │                       │
         └───────────┬───────────┘
                     │
                     ▼
              Success Toast
              "Craving logged" or "Usage logged"
                     │
                     ▼
              Stay on Log tab (or navigate to History?)
```

---

## Summary: The Split is CLEAN

| Data Type | Where to LOG it | Where to VIEW it |
|-----------|-----------------|------------------|
| **Cravings** | Log tab → "Log Craving" button → Sheet | History tab → "Cravings" segment |
| **Usage** | Log tab → "Log Usage" button → Sheet | History tab → "Usage" segment |

**Home tab shows NEITHER list.** It's just your status + motivation.

---

## Recommendation: Option A (Tab-Based)

### Why Tab-Based Wins

1. **Clear mental model**: "I want to see my cravings" → tap Cravings tab
2. **Scales with features**: Future recordings get their own tab
3. **Industry standard**: I Am Sober, Calm, Headspace all use this pattern
4. **One-tap logging**: Dedicated Log tab = fastest path
5. **Room for dashboard**: Home becomes motivational hub

### Proposed Tab Structure

```
┌───────┬───────┬───────┬───────┬───────┐
│ 🏠    │ 📝    │ 🧠    │ 🌿    │ ⚙️    │
│ Home  │ Log   │Cravings│ Usage │Settings│
└───────┴───────┴───────┴───────┴───────┘
```

**Alternative 4-tab version (cleaner):**
```
┌─────────┬─────────┬─────────┬─────────┐
│ 🏠      │ 📝      │ 📊      │ ⚙️      │
│ Home    │ Log     │ History │ Settings│
└─────────┴─────────┴─────────┴─────────┘
```
Where History has a segmented control: [Cravings | Usage]

---

## Implementation Complexity

| Option | Files Changed | Complexity | Risk |
|--------|---------------|------------|------|
| **A (Tabs)** | 5-8 | Medium | Low |
| **B (FAB)** | 2-3 | Low | Low |
| **C (Hybrid)** | 4-6 | Medium | Medium |
| **D (Crisis)** | 3-4 | Low | Medium (UX untested) |

---

## Next Steps

1. **User decision**: Which option resonates?
2. **Prototype**: Low-fi Figma or SwiftUI preview
3. **Implement**: Start with tab structure, then refine

---

## References

- [I Am Sober App Showcase](https://screensdesign.com/showcase/i-am-sober) - Screen design patterns
- [Mobbin Home Screen Patterns](https://mobbin.com/explore/mobile/screens/home) - 2026 UI trends
- [Addiction Recovery App Development](https://topflightapps.com/ideas/addiction-recovery-app-development/) - Feature best practices
- [Mobile App UX Design Trends 2026](https://www.designstudiouiux.com/blog/mobile-app-ui-ux-design-trends/) - Current design patterns
