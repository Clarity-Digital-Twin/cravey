# Home Screen Redesign - DECISION

**Created:** 2026-01-26
**Status:** DECIDED - Ready to Implement

---

## The Decision: 4-Tab Structure

```
┌─────────┬─────────┬─────────┬─────────┐
│ 🏠      │ 📝      │ 📊      │ ⚙️      │
│ Home    │ Log     │ History │ Settings│
└─────────┴─────────┴─────────┴─────────┘
```

| Tab | Purpose |
|-----|---------|
| **Home** | Dashboard with hero metric, motivation, today's stats. NO lists. |
| **Log** | Two big buttons: "Log Craving" and "Log Usage". Opens form sheets. |
| **History** | Segmented control [Cravings \| Usage] + list of entries. |
| **Settings** | Export data, delete all data, app info. |

**Future-proofed:** When Recordings feature ships, add 5th tab: 🎬 Recordings

---

## Why This Structure

1. **Cravings and Usage are separated** - toggle in History tab
2. **Home is clean** - no cluttered lists, just status + encouragement
3. **One-tap logging** - Log tab is always visible
4. **Matches industry standard** - I Am Sober, Calm, Headspace use this pattern
5. **Room to grow** - 4 tabs now, 5 with Recordings later

---

## Current State (What We're Fixing)

```
┌─────────────────────────────────┐
│           Home                  │ ← Generic title
│  + (hidden menu)                │ ← 2 taps to log = bad
│                                 │
│  Recent Cravings                │
│  [craving cards mixed in]       │ ← Cluttered
│                                 │
│  Recent Usage                   │
│  [usage cards mixed in]         │ ← Confusing
│                                 │
│ 🏠 Home  📊 Progress  ⚙️ Settings│ ← 3 tabs
└─────────────────────────────────┘
```

**Problems:**
- Cravings + Usage mixed on same screen
- No hero metric (days abstinent)
- "+" hidden behind menu
- No emotional support/motivation

---

## Screen 1: HOME TAB (Dashboard Only)

```
┌─────────────────────────────────┐
│       My Recovery               │
│                                 │
│   ┌───────────────────────┐     │
│   │                       │     │
│   │       12              │     │ ← BIG number
│   │      DAYS             │     │
│   │    abstinent          │     │
│   │                       │     │
│   │   Since Jan 14, 2026  │     │
│   └───────────────────────┘     │
│                                 │
│   Today                         │
│   ┌───────────┬───────────┐     │
│   │     2     │     0     │     │
│   │ cravings  │   uses    │     │ ← Tappable → go to History
│   └───────────┴───────────┘     │
│                                 │
│   ┌─────────────────────────┐   │
│   │  💪 "Every urge you     │   │
│   │     resist makes you    │   │ ← Motivational message
│   │     stronger"           │   │
│   └─────────────────────────┘   │
│                                 │
│ ═══════════════════════════════ │
│ 🏠      📝       📊       ⚙️    │
│ Home    Log    History Settings │
└─────────────────────────────────┘
```

**What's on this screen:**
- Hero metric (days abstinent)
- Start date
- Today's craving + usage counts
- Motivational message (rotates daily)

**What's NOT on this screen:**
- ❌ No craving list
- ❌ No usage list
- ❌ No forms

---

## Screen 2: LOG TAB (Action Buttons)

```
┌─────────────────────────────────┐
│         Log Entry               │
│                                 │
│                                 │
│   What would you like to log?   │
│                                 │
│   ┌─────────────────────────┐   │
│   │                         │   │
│   │    🧠 Log Craving       │   │ ← Tappable button
│   │                         │   │
│   │    Track an urge you    │   │
│   │    experienced          │   │
│   │                         │   │
│   └─────────────────────────┘   │
│                                 │
│   ┌─────────────────────────┐   │
│   │                         │   │
│   │    🌿 Log Usage         │   │ ← Tappable button
│   │                         │   │
│   │    Record cannabis      │   │
│   │    consumption          │   │
│   │                         │   │
│   └─────────────────────────┘   │
│                                 │
│ ═══════════════════════════════ │
│ 🏠      📝       📊       ⚙️    │
│ Home    Log    History Settings │
└─────────────────────────────────┘
```

**Tap "Log Craving"** → CravingLogForm opens as sheet
**Tap "Log Usage"** → UsageLogForm opens as sheet

---

## Screen 3: HISTORY TAB (Segmented Lists)

### Cravings Selected:
```
┌─────────────────────────────────┐
│           History               │
│                                 │
│   ┌───────────┬───────────┐     │
│   │ Cravings  │   Usage   │     │ ← Segmented control
│   │  (sel)    │           │     │
│   └───────────┴───────────┘     │
│                                 │
│   ┌─────────────────────────┐   │
│   │ 🟡 5    2 hours ago     │   │ ← Intensity + time
│   │    Sad, Bored           │   │ ← Triggers
│   │    📍 Home              │   │ ← Location
│   └─────────────────────────┘   │
│   ┌─────────────────────────┐   │
│   │ 🟠 7    Yesterday       │   │
│   │    Stressed, Hungry     │   │
│   └─────────────────────────┘   │
│   ┌─────────────────────────┐   │
│   │ 🟢 3    2 days ago      │   │
│   │    Bored                │   │
│   └─────────────────────────┘   │
│                                 │
│ ═══════════════════════════════ │
│ 🏠      📝       📊       ⚙️    │
│ Home    Log    History Settings │
└─────────────────────────────────┘
```

### Usage Selected:
```
┌─────────────────────────────────┐
│           History               │
│                                 │
│   ┌───────────┬───────────┐     │
│   │ Cravings  │   Usage   │     │
│   │           │   (sel)   │     │ ← Usage selected
│   └───────────┴───────────┘     │
│                                 │
│   ┌─────────────────────────┐   │
│   │ 🌿 Bowls    0.5 bowls   │   │ ← Method + amount
│   │    Yesterday 6:30 PM    │   │
│   │    Sad · 📍 Home        │   │
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

**Swipe left** → Delete
**Tap row** → Edit (future)

---

## Screen 4: SETTINGS TAB (Unchanged)

```
┌─────────────────────────────────┐
│           Settings              │
│                                 │
│   Data                          │
│   ┌─────────────────────────┐   │
│   │ 📤 Export Data          │   │
│   └─────────────────────────┘   │
│   ┌─────────────────────────┐   │
│   │ 🗑️ Delete All Data      │   │
│   └─────────────────────────┘   │
│                                 │
│   About                         │
│   ┌─────────────────────────┐   │
│   │ ℹ️ Version 1.0.0        │   │
│   └─────────────────────────┘   │
│                                 │
│ ═══════════════════════════════ │
│ 🏠      📝       📊       ⚙️    │
│ Home    Log    History Settings │
└─────────────────────────────────┘
```

---

## Navigation Flow

```
                    APP LAUNCH
                        │
                        ▼
                   HOME TAB
              (Dashboard view)
                        │
    ┌───────────────────┼───────────────────┐
    │                   │                   │
    ▼                   ▼                   ▼
 LOG TAB           HISTORY TAB        SETTINGS TAB
    │                   │
    │           ┌───────┴───────┐
    │           ▼               ▼
    │      [Cravings]       [Usage]
    │       segment          segment
    │           │               │
    │           ▼               ▼
    │      Craving List    Usage List
    │
    ├─── "Log Craving" button
    │           │
    │           ▼
    │    CravingLogForm (sheet)
    │           │
    │           ▼
    │    Submit → Toast → Stay on Log
    │
    └─── "Log Usage" button
                │
                ▼
         UsageLogForm (sheet)
                │
                ▼
         Submit → Toast → Stay on Log
```

---

## Summary Table

| Action | Where | How |
|--------|-------|-----|
| See my status | Home tab | Automatic on launch |
| Log a craving | Log tab → "Log Craving" | 2 taps total |
| Log usage | Log tab → "Log Usage" | 2 taps total |
| View craving history | History tab → "Cravings" segment | 2 taps total |
| View usage history | History tab → "Usage" segment | 2 taps total |
| Export data | Settings tab → Export | 2 taps total |

---

## Files to Change

| File | Change |
|------|--------|
| `CraveyApp.swift` | Replace 3-tab with 4-tab TabView |
| `HomeView.swift` | Remove lists, make pure dashboard |
| `LogView.swift` | **NEW** - Two big buttons |
| `HistoryView.swift` | **NEW** - Segmented control + list |
| `DashboardView.swift` | Merge into HomeView or keep as child |
| `CravingListView.swift` | Embed in HistoryView |
| `UsageListView.swift` | Embed in HistoryView |

---

## References

- [I Am Sober App](https://screensdesign.com/showcase/i-am-sober) - ~$200K/month, similar tab structure
- [Mobbin Home Screen Patterns](https://mobbin.com/explore/mobile/screens/home) - 2026 UI trends
