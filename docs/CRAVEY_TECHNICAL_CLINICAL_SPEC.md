# Cravey: Technical & Clinical Specification for Web Rebuild

**Purpose:** This document is a complete reference for rebuilding the Cravey iOS app as a web application. It covers every screen, every data field, every validation rule, and every clinical rationale so that an engineer with zero medical background can reproduce this app accurately.

**What is Cravey?** A cannabis cessation support app. Users track cravings (urges to use) and actual usage episodes. The app calculates sobriety streaks, surfaces motivational messages, and lets users export their data. All data is local-only (no cloud, no analytics, no tracking). The user base is people in active recovery from Cannabis Use Disorder (CUD), a recognized condition in the DSM-5.

**Why privacy matters:** People recovering from substance use face stigma, potential employment consequences, and legal risk depending on jurisdiction. The app stores everything locally with zero telemetry. The web rebuild must maintain this standard.

---

## Table of Contents

1. [App Navigation Structure](#1-app-navigation-structure)
2. [Home Screen (Dashboard)](#2-home-screen-dashboard)
3. [Log Screen](#3-log-screen)
4. [Log Craving Flow](#4-log-craving-flow)
5. [Log Usage Flow](#5-log-usage-flow)
6. [History Screen](#6-history-screen)
7. [Settings Screen](#7-settings-screen)
8. [Data Model (Complete Schema)](#8-data-model-complete-schema)
9. [Enums & Constants Reference](#9-enums--constants-reference)
10. [Motivational Messages (Full List)](#10-motivational-messages-full-list)
11. [Planned but Unfinished Features](#11-planned-but-unfinished-features)

---

## 1. App Navigation Structure

The app uses a tab bar with four tabs:

| Tab | Label | Icon | Screen |
|-----|-------|------|--------|
| 1 | Home | `house.fill` | Dashboard with streak, today's stats, motivational quote |
| 2 | Log | `plus.circle.fill` | Two action cards: "Log Craving" and "Log Usage" |
| 3 | History | `clock.fill` | Segmented list of past cravings and usage entries |
| 4 | Settings | `gearshape.fill` | Export data, delete data, privacy info, version |

---

## 2. Home Screen (Dashboard)

The home screen is the first thing a user sees. It provides at-a-glance recovery metrics and encouragement.

### 2a. Hero Streak Card

**What it shows:** A large number representing days since the user's last cannabis use.

- **Calculation:** Take the most recent `UsageEntity.timestamp` across all usage records. Compute `Calendar.dateComponents([.day], from: lastUsage.timestamp, to: now).day`. If no usage has ever been logged, show `0` with the message "Start by logging a usage entry."
- **Display:** Large bold number (64pt equivalent), "DAYS" label underneath, "since last use" text, and the formatted date of last use.
- **Clinical rationale:** The sobriety counter is the most psychologically important metric. In addiction medicine, tracking consecutive abstinent days reinforces the user's sense of progress and makes relapse feel more costly ("I don't want to break my 47-day streak"). However, the app deliberately avoids punitive language if the streak resets. A reset is just a new starting point.

### 2b. Today's Stats Card

**What it shows:** Two side-by-side mini-cards for the current calendar day:

| Stat | Label | Color Logic |
|------|-------|-------------|
| Craving count today | "cravings" | Yellow tint |
| Usage count today | "uses" | Orange if > 0, Green if 0 |

- **Calculation:** Filter cravings and usages where `timestamp >= startOfDay(now)` and `timestamp < startOfDay(now + 1 day)`.
- **Clinical rationale:** Daily counts give users immediate feedback. Seeing "0 uses" in green reinforces abstinence. If usage count > 0, the orange color is not punitive but gently informational. Craving count is always yellow because cravings are expected and normal during recovery; logging them is a positive behavior, not a failure.

### 2c. Motivational Quote Card

**What it shows:** A single motivational message with a fist emoji icon.

- **Selection algorithm:** The system selects the least-shown active message. If multiple messages are tied for fewest shows, it picks deterministically based on day-of-year (`dayOfYear % tiedMessages.count`). This ensures the same message appears all day but rotates daily.
- **Messages are seeded on first launch** from a hardcoded list of 11 defaults (see [Section 10](#10-motivational-messages-full-list)). Users cannot currently add custom messages through the UI, but the data model supports it.
- **Clinical rationale:** Motivational interviewing research shows that brief, compassionate affirmations during vulnerable moments can reduce relapse. The messages are category-tagged (urge, anxiety, boredom, social, celebration) to eventually support context-aware delivery, though currently all active messages are in the rotation regardless of category.

### 2d. Additional Dashboard Metrics (Computed but Not All Displayed)

The `DashboardViewModel` computes more metrics than are currently shown in the UI. These are available for future dashboard cards:

| Metric | Computation | Currently Displayed? |
|--------|------------|---------------------|
| `currentStreak` | Days since last usage | Yes (hero card) |
| `longestStreak` | Largest gap between any two consecutive usages | No |
| `todayCravingCount` | Cravings today | Yes |
| `todayUsageCount` | Usages today | Yes |
| `averageIntensity7Day` | Mean craving intensity over past 7 days | No |
| `averageIntensity30Day` | Mean craving intensity over past 30 days | No |
| `topTriggers` | Top 3 triggers by frequency (cravings + usages combined) | No |
| `weeklyCravingCount` | Cravings in past 7 days | No |
| `weeklyUsageCount` | Usages in past 7 days | No |

---

## 3. Log Screen

The log screen is a simple routing page with two action cards:

1. **"Log Craving"** - Icon: `brain.head.profile` (purple). Subtitle: "Track an urge you experienced." Opens the Craving Log Form as a modal sheet.
2. **"Log Usage"** - Icon: `leaf.fill` (green). Subtitle: "Record cannabis consumption." Opens the Usage Log Form as a modal sheet.

On successful submission, a toast banner appears: "Craving logged" or "Usage logged" with a checkmark icon, auto-dismissing after 2 seconds.

---

## 4. Log Craving Flow

A craving is an urge to use cannabis that the user experienced, whether or not they actually used. Logging cravings is clinically significant even (especially) when the user resisted the urge.

### Form Fields

#### 4a. Timestamp

| Property | Value |
|----------|-------|
| Control | Date + time picker |
| Default | Current date/time |
| Validation | Cannot be in the future |
| Warning | If > 7 days old, shows confirmation dialog: "This craving is more than 7 days old. Are you sure you want to log it?" |

**Clinical rationale:** Users sometimes want to retroactively log cravings they didn't record in the moment (e.g., they were in a social situation). The 7-day warning prevents accidental data entry errors but allows intentional backdating.

#### 4b. Intensity

| Property | Value |
|----------|-------|
| Control | Slider, step = 1 |
| Range | 1 to 10 |
| Default | 5 |
| Display | Numeric value + emoji + text label |

**Emoji and label mapping:**

| Range | Emoji | Label |
|-------|-------|-------|
| 1-2 | `😌` | Very Mild |
| 3-4 | `🙂` | Mild |
| 5-6 | `😐` | Moderate |
| 7-8 | `😟` | Strong |
| 9-10 | `😫` | Overwhelming |

**Color mapping (used in list views):**

| Range | Color |
|-------|-------|
| 1-3 | Green |
| 4-6 | Yellow |
| 7-9 | Orange |
| 10 | Red |

**Clinical rationale:** Intensity tracking on a 1-10 scale is standard in cognitive behavioral therapy (CBT) for substance use. It helps users recognize patterns (e.g., "my cravings are always 8+ when I'm tired") and provides clinicians with objective trend data. The emoji feedback makes an abstract number feel concrete and reduces the cognitive load of self-assessment during a craving.

#### 4c. Triggers (Multi-Select Chips)

Triggers are organized into three groups displayed as tappable chips:

**Group 1 - Primary HALT triggers:**
| Chip | Clinical Meaning |
|------|-----------------|
| Hungry | Physical hunger lowers self-regulation. Blood sugar drops make impulsive decisions more likely. |
| Angry | Anger is a high-arousal state that people commonly self-medicate with cannabis. |
| Lonely | Social isolation is one of the strongest predictors of relapse across all substance use disorders. |
| Tired | Fatigue depletes willpower (ego depletion theory). Sleep-deprived users are significantly more relapse-prone. |

**Group 2 - Additional emotional triggers:**
| Chip | Clinical Meaning |
|------|-----------------|
| Sad | Depressed mood. Cannabis is commonly used to numb sadness. |
| Anxious | Anxiety disorders have high comorbidity with CUD. Cannabis initially reduces anxiety but worsens it long-term. |
| Bored | Boredom is the most commonly reported trigger for cannabis use, especially in chronic daily users. |

**Group 3 - Contextual/environmental triggers:**
| Chip | Clinical Meaning |
|------|-----------------|
| Habit | Automatic behavior, not driven by emotion. Example: "I always smoke after dinner." Identifying habitual use is key to breaking the automaticity. |
| Social | Peer pressure or social situations where others are using. Social triggers require specific coping strategies. |
| Paraphernalia | Seeing pipes, papers, lighters, etc. Environmental cues are powerful relapse triggers (classical conditioning). Recommending disposal of paraphernalia is standard treatment advice. |

**Clinical rationale:** The HALT framework (Hungry, Angry, Lonely, Tired) comes from addiction medicine and 12-step programs. It gives users a simple mental checklist when a craving hits: "Am I actually craving, or am I just hungry/tired?" The extended triggers (Sad, Anxious, Bored, Habit, Social, Paraphernalia) cover the most common cannabis-specific triggers identified in clinical literature. Multi-select is important because cravings are often multi-causal (e.g., "Tired + Social" at a late-night party).

#### 4d. Location (Optional, Single-Select Chips)

| Chip | Behavior |
|------|----------|
| `📍 Current` | Requests GPS permission, stores latitude/longitude as `"lat,lon"` string |
| Home | Stores the string `"Home"` |
| Work | Stores the string `"Work"` |
| Out | Stores the string `"Out"` |
| Other | Stores the string `"Other"` |

- User can deselect (location is optional).
- If GPS is denied, shows an alert with a link to device Settings.
- GPS has a 10-second timeout.

**Clinical rationale:** Location tracking helps identify environmental patterns. If a user notices most of their high-intensity cravings happen "at Home" on weekday evenings, a therapist can work on restructuring that specific time/place combination. GPS coordinates are stored for users who want granular data, but preset labels cover 90%+ of use cases.

#### 4e. Notes (Optional, Free Text)

| Property | Value |
|----------|-------|
| Control | Multi-line text input (3-5 lines visible) |
| Max length | 500 characters |
| Character counter | Appears at 400+ characters, shows `"{count}/500"` |
| Counter color | Turns red when at limit |

**Clinical rationale:** Free-text notes let users capture context that structured fields can't, such as specific thoughts ("I kept thinking one hit wouldn't hurt"), situations ("my roommate was smoking in the next room"), or coping strategies they tried ("I went for a walk and it helped").

#### 4f. Submission

- **Save button:** Disabled while loading. Triggers haptic success feedback on save.
- **Cancel button:** Dismisses the form sheet.
- **Validation errors** show as alerts (intensity out of range, future timestamp, notes too long).
- **Form auto-dismisses** on successful save.

---

## 5. Log Usage Flow

A usage entry records that the user actually consumed cannabis. This is not a failure event; it's clinical data. The app's tone around usage logging is neutral and supportive.

### Form Fields

#### 5a. Timestamp

Same behavior as craving timestamp. Default: now. Cannot be future. 7-day-old warning.

#### 5b. Consumption Method (ROA - Route of Administration)

Single-select chips. The user must pick exactly one:

| Method | Display Name | What It Is |
|--------|-------------|------------|
| `Bowls` | Bowls | Smoking from a pipe or bong. Most common consumption method. |
| `Joints` | Joints | Cannabis rolled in paper. Standard joint. |
| `Blunts` | Blunts | Cannabis rolled in a tobacco/hemp wrap. Higher quantity per session than joints. |
| `Vape` | Vape | Vaporizer pen or device. Increasingly common, especially among younger users. |
| `Dab` | Dab | Concentrated cannabis extract (wax, shatter, budder). Much higher THC potency (60-90% vs 15-25% for flower). |
| `Edible` | Edible | Cannabis-infused food or drink. Delayed onset (30-120 min), longer duration, harder to dose. |

**Clinical rationale:** Route of administration is critical clinical data for several reasons:

1. **Potency varies dramatically.** A single dab may deliver 3-5x the THC of a bowl. Edibles at 100mg are a very different clinical picture than a 5mg gummy. Without knowing the method, raw "amount" numbers are meaningless.
2. **Health risk profiles differ.** Smoking (bowls, joints, blunts) carries respiratory risks. Vaping has its own pulmonary concerns. Edibles pose overdose risk from delayed onset (users consume more thinking "it's not working"). Dabs have the highest acute intoxication risk.
3. **Onset and duration affect treatment.** Smoked cannabis hits in minutes and lasts 1-3 hours. Edibles take 30-120 minutes and last 4-8 hours. This affects scheduling of therapy sessions, coping strategy timing, and understanding the user's intoxication window.
4. **Reduction strategies are method-specific.** A therapist might recommend switching from dabs to flower as a harm reduction step, or reducing edible dosage in 5mg increments.

#### 5c. Amount (Method-Dependent Picker)

The amount picker is a wheel-style control that changes its options based on the selected method:

| Method | Unit | Options | Step | Min | Max |
|--------|------|---------|------|-----|-----|
| Bowls | bowls | 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0 | 0.5 | 0.5 | 5.0 |
| Joints | joints | 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0 | 0.5 | 0.5 | 5.0 |
| Blunts | blunts | 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0 | 0.5 | 0.5 | 5.0 |
| Vape | pulls | 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 | 1 | 1 | 10 |
| Dab | dabs | 1, 2, 3, 4, 5 | 1 | 1 | 5 |
| Edible | mg | 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100 | 5 | 5 | 100 |

**Display format examples:** "2.5 bowls", "10 pulls", "3 dabs", "50mg"

**Default:** When the user switches methods, the amount resets to the first valid option for that method (e.g., switching to Edible resets to 5mg). The overall form default amount is 0.5 (first option for Bowls, the default method).

**Clinical rationale:** These ranges are calibrated to realistic single-session consumption:

- **Bowls/Joints/Blunts:** Half-increments because users commonly share or partially consume. 5 is a reasonable upper bound for a single session.
- **Vape:** Counted in "pulls" (inhalations). 10 is a generous upper bound for a session.
- **Dab:** Dabs are extremely concentrated. Even heavy users rarely exceed 3-5 in a session.
- **Edible:** Measured in milligrams of THC. 5mg is a standard recreational dose in legal markets. 100mg is the typical maximum for a single product package. The 5mg step matches standard dosing increments on product labels.

#### 5d. Triggers

Identical to craving triggers (same chips, same multi-select behavior, same clinical rationale). Tracking triggers on usage events allows cross-referencing: "When I'm Bored + Lonely, I don't just crave, I actually use."

#### 5e. Location

Identical to craving location.

#### 5f. Notes

Identical to craving notes (500 char limit, counter at 400+).

#### 5g. Submission

Same behavior as craving form (loading state, haptic feedback, auto-dismiss on success).

**Validation rules:**
- Method must be a valid `UsageMethod` enum value
- Amount must be > 0
- Amount must be within the valid range for the selected method
- Timestamp cannot be in the future
- Notes cannot exceed 500 characters

---

## 6. History Screen

### 6a. Navigation

A segmented control at the top with two tabs: **"Cravings"** and **"Usage"**. Defaults to Cravings.

### 6b. Craving List

**Sorting:** Newest first (by timestamp, descending).

**Each row shows:**
- **Intensity badge:** Circular badge (40x40) with the intensity number, colored by the intensity scale (green/yellow/orange/red).
- **Timestamp:** Abbreviated date + time (e.g., "Feb 14, 2:30 PM").
- **Triggers:** Comma-separated list (if any).
- **Notes:** First 2 lines of notes text (if any), truncated with ellipsis.

**Empty state:** Leaf icon with pulsing animation, "No Cravings Logged", "Go to the Log tab to log your first craving."

**Deletion:** Swipe left to reveal a red "Delete" button. Confirmation dialog: "Delete Craving?" / "This cannot be undone." with Delete (destructive) and Cancel buttons. Haptic warning feedback on delete.

**No edit functionality exists.** Users cannot edit existing entries (only delete).

### 6c. Usage List

**Sorting:** Newest first (by timestamp, descending).

**Each row shows:**
- **Method name** (headline weight) and **formatted amount** (e.g., "2.5 bowls") on the same line.
- **Timestamp:** Abbreviated date + time.
- **Triggers** (if any): Lightning bolt icon + comma-separated list.
- **Location** (if any): Pin icon + location display (preset name or "Current Location" for GPS).
- **Notes** (if any): Notepad icon + first 2 lines, truncated.

**Empty state:** Leaf icon, "No Usage Logged", "Your usage history will appear here once you start logging."

**Deletion:** Same swipe-to-delete pattern with confirmation.

**No filtering or search exists.** The lists are currently unfiltered, unsearchable, and unpaginated.

---

## 7. Settings Screen

### 7a. About Section

- **Version:** Displays `"{appVersion} ({buildNumber})"` (e.g., "0.1.0 (1)"). Read from the app bundle.

### 7b. Data Section

**Export Data:**
- Opens a sheet with a format picker: **CSV** or **JSON**.
- Export includes: all cravings, all usage logs, all recording metadata, and all motivational messages.
- Recording files (audio/video) are NOT included in the export, only their metadata.
- On export, a native share sheet appears for saving/sending the file.
- Filename format: `cravey-export-{yyyy-MM-dd-HHmmss}.{csv|json}`
- The export payload includes a `schemaVersion: 1` field for future migration compatibility.

**Delete All Data:**
- Button labeled "Delete All Data" with a trash icon.
- Confirmation dialog: "Delete All Data?" / "This will permanently delete all your cravings, usage logs, recordings, and any custom motivational messages. This action cannot be undone."
- Buttons: "Delete Everything" (destructive red) and "Cancel".
- On success, shows toast: "All data deleted".

### 7c. Privacy Section

Two static labels (not interactive):
1. Checkmark shield icon (green): "All data is stored locally on your device"
2. Lock icon (blue): "No data is ever sent to external servers"

---

## 8. Data Model (Complete Schema)

### 8a. CravingEntity / CravingModel

| Field | Type | Required | Default | Validation | Persisted |
|-------|------|----------|---------|-----------|-----------|
| `id` | UUID | Yes | Auto-generated | Unique | Yes |
| `timestamp` | Date | Yes | Now | Not in future | Yes |
| `intensity` | Int | Yes | 5 (form default) | 1-10 inclusive | Yes |
| `triggers` | [String] | No | `[]` | Values from TriggerOptions | Yes |
| `location` | String? | No | `nil` | Preset name or "lat,lon" | Yes |
| `notes` | String? | No | `nil` | Max 500 chars | Yes |
| `createdAt` | Date | Yes | Now | Auto-set | Yes |
| `modifiedAt` | Date? | No | `nil` | Set on update | Yes |

**Relationships:** Optional many-to-one relationship to `RecordingModel` (not yet used in UI).

**Computed properties on the entity:**
- `intensityLevel` - Categorizes as `.low` (1-3), `.moderate` (4-6), `.high` (7-10), or `.unknown`
- `isWithinLast(_ hours: Int, now: Date)` - Check recency

### 8b. UsageEntity / UsageModel

| Field | Type | Required | Default | Validation | Persisted |
|-------|------|----------|---------|-----------|-----------|
| `id` | UUID | Yes | Auto-generated | Unique | Yes |
| `timestamp` | Date | Yes | Now | Not in future | Yes |
| `method` | String | Yes | "Bowls" (form default) | Must match UsageMethod enum | Yes |
| `amount` | Double | Yes | 0.5 (form default) | > 0, must be in method's valid range | Yes |
| `triggers` | [String] | No | `[]` | Values from TriggerOptions | Yes |
| `location` | String? | No | `nil` | Preset name or "lat,lon" | Yes |
| `notes` | String? | No | `nil` | Max 500 chars | Yes |
| `createdAt` | Date | Yes | Now | Auto-set | Yes |
| `modifiedAt` | Date? | No | `nil` | Set on update | Yes |

### 8c. RecordingEntity / RecordingModel

| Field | Type | Required | Default | Validation | Persisted |
|-------|------|----------|---------|-----------|-----------|
| `id` | UUID | Yes | Auto-generated | Unique | Yes |
| `timestamp` | Date | Yes | Now | - | Yes |
| `type` | String (enum) | Yes | "audio" | "video" or "audio" | Yes |
| `purpose` | String (enum) | Yes | "motivational" | See RecordingPurpose enum | Yes |
| `duration` | TimeInterval | Yes | 0 | - | Yes |
| `filePath` | String | Yes | "" | Relative path | Yes |
| `thumbnailPath` | String? | No | `nil` | For video thumbnails | Yes |
| `title` | String? | No | `nil` | - | Yes |
| `notes` | String? | No | `nil` | - | Yes |
| `playCount` | Int | No | 0 | Incremented on play | Yes |
| `lastPlayedAt` | Date? | No | `nil` | Set on play | Yes |
| `createdAt` | Date | Yes | Now | Auto-set | Yes |
| `modifiedAt` | Date? | No | `nil` | Set on update | Yes |

**Relationships:** One-to-many with `CravingModel` (a recording can be linked to multiple cravings).

**Note:** This model is fully scaffolded in the data layer but has NO UI yet.

### 8d. MotivationalMessageEntity / MotivationalMessageModel

| Field | Type | Required | Default | Validation | Persisted |
|-------|------|----------|---------|-----------|-----------|
| `id` | UUID | Yes | Auto-generated | Unique | Yes |
| `content` | String | Yes | - | - | Yes |
| `category` | String (enum) | Yes | - | See MessageCategory enum | Yes |
| `isCustom` | Bool | No | `false` | Default = system message | Yes |
| `priority` | Int | No | 0 | Display ordering within category | Yes |
| `timesShown` | Int | No | 0 | Incremented each time displayed | Yes |
| `lastShownAt` | Date? | No | `nil` | Set when displayed | Yes |
| `isActive` | Bool | No | `true` | Inactive messages excluded from rotation | Yes |
| `createdAt` | Date | Yes | Now | Auto-set | Yes |
| `modifiedAt` | Date? | No | `nil` | Set on update | Yes |

---

## 9. Enums & Constants Reference

### 9a. UsageMethod

```
Bowls    -> amountRange: [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0]  -> unit: "bowls"
Joints   -> amountRange: [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0]  -> unit: "joints"
Blunts   -> amountRange: [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0]  -> unit: "blunts"
Vape     -> amountRange: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]                       -> unit: "pulls"
Dab      -> amountRange: [1, 2, 3, 4, 5]                                        -> unit: "dabs"
Edible   -> amountRange: [5, 10, 15, 20, ..., 95, 100] (step 5)                 -> unit: "mg"
```

### 9b. TriggerOptions

```
Primary HALT:    ["Hungry", "Angry", "Lonely", "Tired"]
Primary Other:   ["Sad", "Anxious", "Bored"]
Secondary:       ["Habit", "Social", "Paraphernalia"]
All triggers:    Primary HALT + Primary Other + Secondary (10 total)
```

### 9c. LocationOptions

```
Row 1:  ["📍 Current", "Home", "Work"]
Row 2:  ["Out", "Other"]
```

- `📍 Current` triggers a GPS request and stores `"latitude,longitude"`.
- All others store the label string directly (e.g., `"Home"`).
- Selection is optional (user can deselect).

### 9d. MessageCategory

```
urge         - Messages for when the user is actively craving
anxiety      - Messages for anxiety-driven urges
boredom      - Messages for boredom-driven urges
social       - Messages for social pressure situations
celebration  - Messages celebrating progress
unknown      - Fallback category
```

### 9e. RecordingType

```
video    - Video recording (file extension: .mov)
audio    - Audio recording (file extension: .m4a)
unknown  - Fallback
```

### 9f. RecordingPurpose

```
motivational  - Pre-recorded self-encouragement ("future you talking to present you")
milestone     - Recording made to celebrate a sobriety milestone
reflection    - General journaling/reflection recording
craving       - Recording made during or about a specific craving episode
unknown       - Fallback
```

### 9g. IntensityLevel (Computed from intensity value)

```
low       - Intensity 1-3
moderate  - Intensity 4-6
high      - Intensity 7-10
unknown   - Out of range
```

### 9h. ExportFormat

```
csv   - Comma-separated values
json  - JSON with schemaVersion field
```

### 9i. Validation Constants

```
Notes max length:            500 characters
Notes counter threshold:     400 characters (counter becomes visible)
Timestamp warning threshold: 7 days (shows "are you sure?" confirmation)
Location request timeout:    10 seconds
Max recording storage:       500 MB
Toast display duration:      2 seconds
```

---

## 10. Motivational Messages (Full List)

These 11 messages are seeded into the database on first app launch. They are the complete set:

| # | Content | Category | Priority |
|---|---------|----------|----------|
| 1 | "You've resisted before. You can do it again." | urge | 1 |
| 2 | "This craving will pass. They always do." | urge | 2 |
| 3 | "Every moment of resistance is progress." | urge | 3 |
| 4 | "This feeling is temporary. Breathe through it." | anxiety | 1 |
| 5 | "Anxiety is uncomfortable, and you're safe." | anxiety | 2 |
| 6 | "Boredom isn't an emergency. Find something else to do for 10 minutes." | boredom | 1 |
| 7 | "This is just boredom, not a need. You've got this." | boredom | 2 |
| 8 | "You can have fun without using. You've done it before." | social | 1 |
| 9 | "Real friends support your choices." | social | 2 |
| 10 | "You're making progress. Every day counts." | celebration | 1 |
| 11 | "Look how far you've come. Keep going." | celebration | 2 |

**Selection algorithm:**
1. Fetch all messages where `isActive == true`.
2. Find the minimum `timesShown` value.
3. Filter to only messages with that minimum count.
4. Select index = `dayOfYear % filteredCount` (deterministic daily rotation).
5. After displaying, increment `timesShown` and set `lastShownAt`.

**Clinical rationale for each category:**
- **Urge messages** remind users that cravings are temporary and survivable. The "urge surfing" concept (riding the wave until it passes) is a core CBT/mindfulness technique.
- **Anxiety messages** normalize the discomfort without minimizing it. "You're safe" is a grounding statement used in anxiety management.
- **Boredom messages** reframe boredom as a benign state, not an emergency requiring cannabis. The "10 minutes" suggestion is a delay-and-distract technique.
- **Social messages** address peer pressure and validate the user's autonomy in social situations.
- **Celebration messages** reinforce continued effort. Positive reinforcement is more effective than shame in addiction recovery.

---

## 11. Planned but Unfinished Features

### 11a. Recordings Feature (Scaffolded, No UI)

**Status:** Data models, repository, mapper, and file storage manager all exist and work. No UI has been built.

**What exists in code:**
- `RecordingEntity` (domain model)
- `RecordingModel` (SwiftData persistence model)
- `RecordingMapper` (entity-model conversion)
- `RecordingRepositoryProtocol` + `RecordingRepository` (CRUD operations)
- `FileStorageManager` (saves recordings to `~/Documents/Recordings/`, generates video thumbnails, enforces 500MB storage limit)

**What's missing (per spec in `docs/future/RECORDINGS_SPEC.md`):**
- Use cases: SaveRecording, FetchRecordings, PlayRecording, DeleteRecording
- AVFoundation integration: AudioRecordingCoordinator, VideoRecordingCoordinator
- ViewModels: RecordingLibraryViewModel, AudioRecordingViewModel, VideoRecordingViewModel
- Views: RecordingLibraryView, AudioRecordingView, VideoRecordingView, AudioPlayerView, VideoPlayerView, SaveRecordingSheet
- Home screen integration: "Quick Play" section showing top 3 recordings

**Clinical rationale:** Video self-recording is a clinically validated technique where users record a message to their "future self" during a moment of high motivation. When a craving hits, they can play back their own voice explaining why they're quitting. Hearing your own reasons in your own voice is significantly more effective than reading generic advice. This is the app's core differentiating feature and highest priority for future development.

### 11b. Onboarding Feature (Not Started)

**Status:** No code exists. Full spec available in `docs/future/ONBOARDING_SPEC.md`.

**What's planned:**
- `WelcomeView` - First-launch screen
- `TourView` - 4-card swipeable introduction to the app's features

### 11c. Features Referenced but Not Scaffolded

The following features are mentioned in project documentation but have zero code:
- **Sponsor/friend outreach** - No code, no spec. Would involve contact integration for "call your sponsor" quick action.
- **Onboarding preferences** - Setting quit date, reasons for quitting, etc.
- **Cloud sync** - Explicitly excluded by design. The privacy-first architecture forbids it.
- **Analytics/tracking** - Explicitly excluded by design.
- **Custom motivational messages UI** - The data model supports `isCustom: true` messages, but there is no UI for users to create/manage custom messages.

---

## Appendix A: Error Messages (User-Facing)

### Craving Errors
| Error | Message |
|-------|---------|
| `invalidIntensity` | "Please choose an intensity between 1 and 10" |
| `futureTimestamp` | "The timestamp can't be in the future" |
| `notesTooLong` | "Notes are limited to 500 characters" |
| `saveFailed` | "We couldn't save your entry. Please try again." |

### Usage Errors
| Error | Message |
|-------|---------|
| `invalidMethod` | "Please select a valid method..." |
| `invalidAmount` | "Please enter an amount greater than zero" |
| `futureTimestamp` | "The timestamp can't be in the future" |
| `amountOutOfRange` | "Please choose an amount within the valid range..." |
| `notesTooLong` | "Notes are limited to 500 characters" |
| `saveFailed` | "We couldn't save your entry. Please try again." |

### System Errors
| Error | Message |
|-------|---------|
| Dashboard load failure | "Unable to load dashboard metrics" |
| Location permission denied | "Enable location access in Settings to use Current Location." |
| Old timestamp warning | "This {craving/usage} is more than 7 days old. Are you sure you want to log it?" |
| Delete confirmation | "This will permanently delete all your cravings, usage logs, recordings, and any custom motivational messages. This action cannot be undone." |
| Storage fallback | "We couldn't access your local data yet. Your entries may not be saved after you close the app." |

---

## Appendix B: Accessibility Identifiers

For automated testing and screen reader support:

| ID | Element |
|----|---------|
| `heroStreakCard` | Dashboard streak card |
| `todayStatsCard` | Dashboard today's counts |
| `motivationCard` | Dashboard motivational quote |
| `logCravingButton` | Log craving action card |
| `logUsageButton` | Log usage action card |
| `successToast` | Success toast banner |
| `historySegmentPicker` | History tab switcher |
| `cravingEntryRow` | Craving list item |
| `cravingFormCancelButton` | Craving form cancel |
| `cravingFormSaveButton` | Craving form save |
| `usageEntryRow` | Usage list item |
| `usageFormCancelButton` | Usage form cancel |
| `usageFormSaveButton` | Usage form save |
| `exportDataButton` | Settings export button |
| `deleteAllDataButton` | Settings delete all button |
| `exportFormatPicker` | Export format selector |
| `exportConfirmButton` | Export confirm button |
| `exportCancelButton` | Export cancel button |
| `toastBanner` | Generic toast message |
