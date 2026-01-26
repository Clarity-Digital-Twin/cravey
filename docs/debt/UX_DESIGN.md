# UX & Design Debt

**Last Updated:** 2026-01-26
**Status:** Multiple items OPEN

---

## UX-001: Home Screen Title Lacks Context

**Status:** OPEN
**Priority:** HIGH
**Location:** `Cravey/Presentation/Views/Home/HomeView.swift`

### Current Implementation
```
Title: "Home"
```

### Problem
- "Home" is generic and uninformative
- Doesn't tell users what the app is for
- No branding or emotional connection
- Users in crisis need immediate clarity

### Screenshots
![Home Screen](../screenshots/home-current.png)

### Recommended Options

**Option A: App-branded**
```
Title: "Cravey"
Subtitle: "Your journey, tracked"
```

**Option B: Action-oriented**
```
Title: "Today"
Subtitle: Shows today's stats or encouragement
```

**Option C: Supportive**
```
Title: "Your Progress"
```

**Option D: Minimal**
- Remove title entirely, let content speak
- Use navigation bar for app identity

### Decision Needed
Dr. Ray to decide based on user research and brand goals.

---

## UX-002: Craving Timestamp Shows Awkward Format

**Status:** OPEN
**Priority:** HIGH
**Location:** `Cravey/Presentation/Views/Home/HomeView.swift`, `CravingRow.swift`

### Current Implementation
```
55 min, 37 sec
```

### Problem
- Precision to the second is unnecessary and distracting
- Creates anxiety about exact timing
- Not how users think about time
- Looks like a timer, not a log entry

### Screenshots
![Timestamp Format](../screenshots/timestamp-current.png)

### Recommended Options

**Option A: Relative (Natural Language)**
```
"Just now"           (< 1 min)
"5 minutes ago"      (< 1 hour)
"2 hours ago"        (< 24 hours)
"Yesterday at 3pm"   (< 48 hours)
"Jan 25 at 3pm"      (older)
```

**Option B: Simplified Relative**
```
"< 1 hr ago"
"2 hrs ago"
"Yesterday"
"Jan 25"
```

**Option C: Time-based (if within 24hrs)**
```
"Today at 6:30 PM"
"Yesterday at 3:00 PM"
"Jan 25, 2026"
```

### Implementation Notes
- Use `RelativeDateTimeFormatter` or custom logic
- Already using `Date` - just need to format differently
- Consider user setting for format preference

### Files to Update
- `Cravey/Presentation/Views/Components/CravingRow.swift`
- `Cravey/Presentation/Views/Components/UsageRow.swift`
- Possibly create shared `TimeFormatter` utility

---

## UX-003: Craving + Usage Logging on Same Screen

**Status:** OPEN
**Priority:** MEDIUM
**Location:** `HomeView.swift` - FAB menu

### Current Implementation
- Single FAB (+) button opens menu
- Menu shows "Log Craving" and "Log Usage"
- Both lists shown vertically on Home

### Problem
- Home screen feels cluttered with both lists
- Conceptually different actions (urge vs action)
- Users may confuse which to use
- Visual hierarchy unclear

### Screenshots
![FAB Menu](../screenshots/fab-menu.png)
![Home Lists](../screenshots/home-lists.png)

### Recommended Options

**Option A: Tab-based separation**
```
Home Tab → Recent Activity (both, but summarized)
Craving Tab → Full craving management
Usage Tab → Full usage management
```

**Option B: Segmented Control**
```
Home screen header: [Cravings | Usage | Both]
Shows filtered list based on selection
```

**Option C: Keep current, improve hierarchy**
```
- Make sections collapsible
- Add section dividers with icons
- Different background colors per section
```

**Option D: Timeline view**
```
Single chronological list mixing both types
Visual indicators (icon, color) distinguish type
```

### Decision Needed
- User research: Do users log cravings and usage separately?
- Is the distinction important for clinical tracking?
- What do competing apps do?

---

## UX-004: No Visual Feedback When Logging Succeeds

**Status:** OPEN
**Priority:** MEDIUM
**Location:** `CravingLogForm.swift`, `UsageLogForm.swift`

### Current Implementation
- Form dismisses after successful save
- Toast appears (sometimes)
- Race condition may cause toast to not appear

### Problem
- User uncertainty: "Did it save?"
- No confirmation of what was logged
- Toast unreliable (see BUG audit)

### Recommended Fix
1. Fix the race condition (see code audit)
2. Show brief confirmation overlay before dismissing:
   ```
   ✓ Craving logged
   Intensity: 5 | Triggers: Sad
   ```
3. Optional: Haptic feedback on success

---

## UX-005: Progress Screen Metric Cards Lack Explanation

**Status:** OPEN
**Priority:** LOW
**Location:** `DashboardView.swift`

### Current Implementation
```
Current Streak: 0 days clean
Craving Intensity: 5.0 (7-Day Avg)
```

### Problem
- New users don't understand what metrics mean
- No tooltips or help text
- "Stable" indicator not explained

### Recommended Fix
- Add (i) info button on each card
- Tap shows modal explaining the metric
- Example: "Current Streak measures consecutive days without logging any cannabis use."

---

## UX-006: Usage Row Redundant Text

**Status:** OPEN
**Priority:** LOW
**Location:** `UsageRow.swift`

### Current Implementation
```
Bowls        0.5 bowls
```

### Problem
- "bowls" appears twice (method name and unit)
- Redundant information

### Recommended Options

**Option A: Show only amount**
```
Bowls        0.5
```

**Option B: Show unit only once**
```
0.5 bowls
Jan 26, 2026 at 6:30 PM
```

**Option C: Icon + amount**
```
🥣 0.5 bowls
```

---

## UX-007: Empty States Need Personality

**Status:** OPEN
**Priority:** LOW
**Location:** Various empty state views

### Current Implementation
```
No Usage Logged
Your usage history will appear here once you start logging.
```

### Problem
- Clinical, impersonal tone
- Doesn't encourage first action
- Missed opportunity for onboarding

### Recommended Copy

**For first-time users:**
```
Ready to track your journey?
Tap + to log your first entry. Every step counts.
```

**For returning users with no recent entries:**
```
All clear!
Nothing logged recently. Keep going strong.
```

---

## Implementation Priority

### Phase 1 (Before Beta)
1. UX-002 - Fix timestamp format
2. UX-004 - Fix success feedback

### Phase 2 (Before Public)
1. UX-001 - Home screen title
2. UX-003 - Craving/Usage separation

### Phase 3 (Post-Launch)
1. UX-005 - Metric explanations
2. UX-006 - Usage row cleanup
3. UX-007 - Empty state personality
