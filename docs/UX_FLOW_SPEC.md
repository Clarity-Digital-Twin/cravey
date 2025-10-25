# Cravey UX Flow Specification

**Version:** 1.1
**Last Updated:** 2025-10-25
**Status:** 🚧 In Progress - Mapping User Journeys (5/7 flows complete)

---

## 🔖 Purpose

This document maps **screen-by-screen user flows** for all 7 MVP features. It translates clinical requirements (CLINICAL_CANNABIS_SPEC.md) and product features (MVP_PRODUCT_SPEC.md) into **tangible UI patterns** that feel natural, fast, and compassionate.

**What This Document Defines:**
- Navigation architecture (tabs, modals, sheets)
- Screen layouts (wireframe descriptions, not pixel-perfect)
- State transitions (User taps X → Screen shows Y → If Z, then...)
- Error states, empty states, loading states
- Component reuse patterns (DRY principle)

**What This Document Does NOT Define:**
- Exact pixel dimensions or colors (implementation detail)
- Animation timing/curves (implementation detail)
- Specific SF Symbol names (implementation detail)

---

## 📐 General Design Guidelines (2025 SwiftUI Best Practices)

### **1. Architecture Patterns**

**Navigation:**
- **NavigationStack** (iOS 16+) - NOT NavigationView (deprecated)
- **Tab Bar** (4 tabs) - Persistent at bottom, hides when modal is open
  - Tab 1: **Home** (Quick action hub)
  - Tab 2: **Progress** (Dashboard with charts)
  - Tab 3: **Recordings** (Video/audio library)
  - Tab 4: **Settings** (Data management, AI chat, permissions)
- **Bottom Sheets** - For contextual, dismissible actions (Log Craving/Usage forms)
- **Full-Screen Modals** - For separate modes (Recording video/audio)
- **Alerts** - For destructive actions (Delete All Data confirmation)

**State Management:**
- `@Observable` for ViewModels (Swift 6)
- `@State` for local view state (picker selection, text input)
- Unidirectional data flow: User action → ViewModel → Update state → View re-renders

---

### **2. Component Library (Reusable UI Elements)**

**Purpose:** Consistent UI, less code, easier maintenance. Build once, use everywhere.

#### **Core Components (8 Total):**

1. **`LogFormSheet`** - Bottom sheet wrapper
   - Single scrollable `Form { }` (Apple Health style)
   - Auto-dismisses on save or swipe-down
   - Used by: Craving logging, Usage logging

2. **`ChipSelector`** - Multi-select or single-select chips
   - Horizontal scrolling row of tappable pills
   - Used by: Triggers (multi-select), Location (single-select)

3. **`PickerWheelInput`** - Context-aware amount picker
   - SwiftUI `Picker` with `.wheel` style
   - Dynamic ranges based on ROA (0.5→5.0 for bowls, 5mg→100mg for edibles)
   - Used by: Usage logging (amount field)

4. **`IntensitySlider`** - 1-10 slider with visual feedback
   - Color-coded: 1-3 green (mild), 4-6 yellow (moderate), 7-9 orange (strong), 10 red (overwhelming)
   - Haptic feedback on value change
   - Used by: Craving logging (intensity field)

5. **`TimestampPicker`** - Date/time picker with "Now" default
   - Auto-populates to current time
   - Shows warning if >7 days in past (clinical memory reliability threshold)
   - Used by: Both craving and usage logging

6. **`ChartCard`** - Reusable dashboard metric container
   - Title + subtitle + Swift Charts visualization
   - Tap to expand detail view
   - Used by: All 11 dashboard metrics

7. **`EmptyStateView`** - Placeholder for no data
   - Friendly illustration + message + optional CTA
   - Used by: Dashboard (< 7 days of data), Recordings (no recordings yet)

8. **`PrimaryActionButton`** - Large, clear CTA
   - Minimum 44x44pt tap target (Apple HIG)
   - High contrast, accessible
   - Used by: "Log Craving", "Log Usage", "Record" buttons

**Note on ROA Selection:** Uses native SwiftUI `List` with radio buttons (not a custom component). Single-select vertical list pattern - all 6 options visible, large tap targets, clear "pick one" affordance.

---

### **3. Crisis-Optimized UX Principles**

**Users may be in crisis → Design for cognitive load:**

✅ **Large Tap Targets** - Minimum 44x44pt (Apple HIG standard)
✅ **Clear Primary Actions** - One obvious next step per screen
✅ **Minimal Decisions** - Default to "Now" for timestamp, pre-populate common choices
✅ **Quick Escape** - Swipe-to-dismiss sheets (don't trap users)
✅ **Progressive Disclosure** - Required fields first, optional fields below divider
✅ **Instant Feedback** - Save confirmation, haptic feedback on actions

---

### **4. Accessibility (Non-Negotiable)**

✅ **Dynamic Type** - All text scales with user settings (1x → 7x size)
✅ **SF Symbols** - Native icons that adapt to dark mode, size, weight
✅ **VoiceOver Support** - All buttons labeled, forms navigable
✅ **High Contrast** - Works in light mode, dark mode, increased contrast
✅ **Reduced Motion** - Respects accessibility settings (no essential info in animations)

---

### **5. Performance Targets**

- **Craving log**: <10 sec (required fields only)
- **Usage log**: <10 sec (required fields only)
- **Dashboard load**: <2 sec (even with 90+ days of data)
- **Recording start**: <1 sec (tap "Record" → camera active)

---

### **6. Privacy Messaging**

**Persistent reassurance across all screens:**
- Onboarding: "All data stays on your device. No cloud sync."
- Location permission request: "Location data never leaves your device."
- Settings: "Your data is private and local-only."

---

## 🧭 User Flows (7 Features)

### **Flow 1: First Launch & Onboarding**

**Goal:** Get user to first craving/usage log in <60 seconds

**Screens:**

#### Screen 1.1: Welcome
**Layout:**
- [ ] App icon + name
- [ ] Tagline: "Private cannabis tracking and support"
- [ ] Subtext: "All data stays on your device. No cloud sync."
- [ ] Primary button: "Get Started"
- [ ] Skip button: "Skip Tour" (goes straight to Home)

**Navigation:**
- Tap "Get Started" → Screen 1.2 (Optional Tour)
- Tap "Skip Tour" → Home tab (Flow 2)

---

#### Screen 1.2: Optional Tour (Swipeable Cards)
**Layout:**
- [ ] Card 1: "Track Cravings" - Illustration + "Log intensity, triggers, location in <10 seconds"
- [ ] Card 2: "Track Usage" - Illustration + "Track what you use, when, and why"
- [ ] Card 3: "Record Motivational Content" - Illustration + "Create videos/audio to watch during cravings"
- [ ] Card 4: "See Your Patterns" - Illustration + "Insights emerge after 7 days of tracking"
- [ ] Bottom: "Done" button

**Navigation:**
- Swipe through cards (optional, skippable)
- Tap "Done" → Home tab (Flow 2)

**Note:** Permissions (camera/mic/location) requested CONTEXTUALLY when first needed, NOT here

---

### **Flow 2: Home Tab (Daily Hub)**

**Goal:** Fast access to primary actions (log craving, log usage, record)

**Screen 2.1: Home (With Recordings)**
**Layout:**
```
┌─────────────────────────────────┐
│                                 │
│     [LOG CRAVING] 🧠            │  ← Full width, primary action
│                                 │
│     [LOG USAGE]   💨            │  ← Full width, primary action
│                                 │
│─────────────────────────────────│
│  Quick Play:                    │  ← Section header
│  🎥 Don't Fucking Do It         │  ← Video (user titled, tap to play)
│  🎙️ Remember Your Goals         │  ← Audio (user titled, tap to play)
│  🎥 Why I'm Taking a Break      │  ← Video (user titled, tap to play)
│                                 │
│     [+ RECORD NEW]              │  ← Tertiary action button
│                                 │
└─────────────────────────────────┘
```

**Components:**
- `PrimaryActionButton` (LOG CRAVING, LOG USAGE)
- Recording list items (tappable, show icon for video/audio)
- Secondary button (+ RECORD NEW)

**Interaction Details:**
- Quick Play section shows **Top 3 Most Played** recordings (sorted by `playCount` DESC)
- 🎥 icon = video recording, 🎙️ icon = audio recording
- Tap recording → Plays immediately (full-screen video player or audio overlay)
- Tap [+ RECORD NEW] → Navigate to Recordings tab (Flow 5)

**Navigation:**
- Tap [LOG CRAVING] → Haptic feedback + button animation (0.1s) → Bottom sheet slides up (Flow 3)
- Tap [LOG USAGE] → Haptic feedback + button animation (0.1s) → Bottom sheet slides up (Flow 4)
- Tap recording → Open native video/audio player
- Tap [+ RECORD NEW] → Switch to Recordings tab (Tab 3)

---

**Screen 2.2: Home (Empty State - No Recordings Yet)**
**Layout:**
```
┌─────────────────────────────────┐
│                                 │
│     [LOG CRAVING] 🧠            │  ← Full width
│                                 │
│     [LOG USAGE]   💨            │  ← Full width
│                                 │
│─────────────────────────────────│
│  💡 Tip: Record motivational    │  ← Helper card
│     content to play during      │
│     cravings                    │
│                                 │
│  → Go to Recordings tab         │  ← Tappable link
│                                 │
└─────────────────────────────────┘
```

**Components:**
- `PrimaryActionButton` (LOG CRAVING, LOG USAGE)
- `EmptyStateView` (contextual tip + navigation link)

**Navigation:**
- Tap "Go to Recordings tab" → Switch to Recordings tab (Tab 3)

---

### **Flow 3: Log Craving (Bottom Sheet Form)**

**Goal:** Log in <10 seconds (intensity + timestamp minimum)

**Screen 3.1: Craving Log Form**
**Layout:**
```
┌─────────────────────────────────┐
│  Log Craving                    │  ← Header
│─────────────────────────────────│
│  Intensity: [1-10 slider]  7    │  ← REQUIRED (color-coded slider)
│  Timestamp: Now ▼               │  ← REQUIRED (editable, auto "now")
│─────────────────────────────────│  ← Visual divider
│  Trigger (Optional)             │  ← OPTIONAL section header
│  [Hungry][Angry][Anxious]       │  ← Multi-select chips (HAALT)
│  [Lonely][Tired][Sad]           │
│  [Bored][Social][Habit]         │
│  [Paraphernalia]                │
│                                 │
│  Location (Optional)            │  ← OPTIONAL section header
│  [Current][Home][Work]          │  ← Single-select chips
│  [Social][Outside][Car]         │
│                                 │
│  Notes (Optional)               │  ← OPTIONAL section header
│  [Text field - 500 char limit] │  ← Freeform text
│                                 │
│─────────────────────────────────│
│        [SAVE CRAVING]           │  ← Primary CTA button
└─────────────────────────────────┘
```

**Components:**
- `LogFormSheet` (bottom sheet wrapper)
- `IntensitySlider` (1-10 slider with color coding)
  - 1-3: Green (mild)
  - 4-6: Yellow (moderate)
  - 7-9: Orange (strong)
  - 10: Red (overwhelming)
- `TimestampPicker` (auto "now", editable, shows warning if >7 days)
- `ChipSelector` (triggers: multi-select, location: single-select)
- Text field for notes
- `PrimaryActionButton` (SAVE CRAVING)

**Interaction Details:**
- Form scrolls vertically (all fields accessible)
- Required fields at top (progressive disclosure)
- Visual divider separates required from optional
- Intensity slider provides haptic feedback on value change
- Timestamp defaults to "Now", tap to edit (date/time picker)
- If timestamp >7 days: Show warning "Memory may be less reliable for events >7 days ago"
- Trigger chips: Multi-select (tap to toggle, can select multiple)
- Location chips: Single-select (tap to select, previous selection deselects)
- Notes field: 500 character limit, character counter appears at 400 chars
- Swipe down anywhere → Dismiss sheet (data not saved, no confirmation)

**Navigation:**
```
User taps [SAVE CRAVING]
  ↓
Haptic feedback (success vibration)
  ↓
Bottom sheet dismisses (slides down, 0.3s)
  ↓
Toast appears: "Craving logged ✓" (2s auto-dismiss, top of screen)
  ↓
User back on Home tab
```

**Edge Cases:**
- If intensity not set (default 5) → Save anyway (required but has default)
- If timestamp not edited → Uses "Now" (default)
- If location "Current" tapped but permission denied → Show alert "Location permission required. Enable in Settings?" (Yes/No)

---

### **Flow 4: Log Usage (Bottom Sheet Form)**

**Goal:** Log in <10 seconds (ROA + amount + timestamp minimum)

**Screen 4.1: Usage Log Form**
**Layout:**
```
┌─────────────────────────────────┐
│  Log Usage                      │  ← Header
│─────────────────────────────────│
│  ROA:                           │  ← REQUIRED (single-select list)
│  ○ Bowls / Joints / Blunts      │  ← Radio button list
│  ● Vape                         │  ← Selected (filled)
│  ○ Dab                          │
│  ○ Edible                       │
│                                 │
│  Amount: [Picker wheel] 5       │  ← REQUIRED (context-aware)
│  (pulls)                        │     Shows: 1, 2, 3... 10
│                                 │
│  Timestamp: Now ▼               │  ← REQUIRED (editable, auto "now")
│─────────────────────────────────│  ← Visual divider
│  Trigger (Optional)             │  ← OPTIONAL section header
│  [Hungry][Angry][Anxious]       │  ← Multi-select chips (HAALT)
│  [Lonely][Tired][Sad]           │
│  [Bored][Social][Habit]         │
│  [Paraphernalia]                │
│                                 │
│  Location (Optional)            │  ← OPTIONAL section header
│  [Current][Home][Work]          │  ← Single-select chips
│  [Social][Outside][Car]         │
│                                 │
│  Notes (Optional)               │  ← OPTIONAL section header
│  [Text field - 500 char limit] │  ← Freeform text
│                                 │
│─────────────────────────────────│
│        [SAVE USAGE]             │  ← Primary CTA button
└─────────────────────────────────┘
```

**Components:**
- `LogFormSheet` (bottom sheet wrapper - SAME as craving)
- Radio button list for ROA (vertical list, single-select)
- `PickerWheelInput` (context-aware amount picker)
- `TimestampPicker` (auto "now", editable - SAME as craving)
- `ChipSelector` (triggers: multi-select, location: single-select - SAME as craving)
- Text field for notes (SAME as craving)
- `PrimaryActionButton` (SAVE USAGE)

**ROA → Amount Picker Mapping:**
- **Bowls/Joints/Blunts:** 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0 (10 options)
- **Vape:** 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 pulls (10 options)
- **Dab:** 1, 2, 3, 4, 5 dabs (5 options)
- **Edible:** 5, 10, 15, 20, 25, 30... 95, 100 mg (20 options)

**Interaction Details:**
- Form scrolls vertically (all fields accessible)
- Required fields at top (progressive disclosure - UX PARITY with craving)
- Visual divider separates required from optional (UX PARITY)
- ROA radio buttons: Tap to select, auto-deselects previous
- **When ROA changes:** Amount picker fades out (0.1s) → New range fades in (0.1s)
- Amount picker shows unit label based on ROA:
  - Bowls/Joints/Blunts → "(bowls/joints)"
  - Vape → "(pulls)"
  - Dab → "(dabs)"
  - Edible → "(mg THC)"
- Timestamp defaults to "Now", tap to edit (date/time picker)
- If timestamp >7 days: Show warning "Memory may be less reliable for events >7 days ago"
- Trigger chips: Multi-select (SAME behavior as craving)
- Location chips: Single-select (SAME behavior as craving)
- Notes field: 500 character limit, character counter at 400 chars (SAME as craving)
- Swipe down anywhere → Dismiss sheet (data not saved, no confirmation)

**Navigation:**
```
User taps [SAVE USAGE]
  ↓
Haptic feedback (success vibration)
  ↓
Bottom sheet dismisses (slides down, 0.3s)
  ↓
Toast appears: "Usage logged ✓" (2s auto-dismiss, top of screen)
  ↓
User back on Home tab
```

**Edge Cases:**
- If ROA not selected → Default to first option (Bowls/Joints/Blunts)
- If amount not set → Default to first value in picker range
- If timestamp not edited → Uses "Now" (default)
- If location "Current" tapped but permission denied → Show alert "Location permission required. Enable in Settings?" (Yes/No)

**UX Parity Notes:**
- ✅ Same `LogFormSheet` component as craving
- ✅ Same divider pattern (required | optional)
- ✅ Same trigger/location chips (multi/single-select)
- ✅ Same timestamp picker behavior
- ✅ Same notes field (500 char limit)
- ✅ Same save feedback (haptic + toast)
- **Difference:** ROA + Amount fields (unique to usage logging)

---

### **Flow 5: Recordings Tab**

**Goal:** Record motivational content, play during cravings

**Screen 5.1: Recordings Library (Empty State)**
**Layout:**
```
┌─────────────────────────────────┐
│                                 │
│       🎥                        │  ← Icon
│                                 │
│  "No recordings yet"            │  ← Header
│                                 │
│  "Create motivational content   │  ← Description
│   to play during cravings"      │
│                                 │
│     [RECORD YOUR FIRST]         │  ← Primary CTA button
│                                 │
└─────────────────────────────────┘
```

**Components:**
- `EmptyStateView` (icon + message + CTA)
- `PrimaryActionButton` (RECORD YOUR FIRST)

**Navigation:**
- Tap [RECORD YOUR FIRST] → Screen 5.2 (Permission Request Flow)

---

**Screen 5.2: Permission Request Flow (Contextual)**

**First-Time Flow:**
```
User taps [RECORD YOUR FIRST]
  ↓
Check camera permission status
  ↓
IF permission NOT determined (first time):
  Show iOS system alert:
  "Cravey would like to access the camera"
  [Don't Allow] [OK]
  ↓
  IF user taps [OK]:
    Check microphone permission status
    ↓
    IF mic permission NOT determined:
      Show iOS system alert:
      "Cravey would like to access the microphone"
      [Don't Allow] [OK]
      ↓
      IF user taps [OK]:
        → Screen 5.3 (Recording Screen)
      ELSE (mic denied):
        Show alert: "Microphone required for recordings.
                     You can still record video-only in Settings."
        [Go to Settings] [Cancel]
        → Return to Screen 5.1
    ELSE (mic already granted):
      → Screen 5.3 (Recording Screen)
  ELSE (camera denied):
    Show alert: "Camera required for video recordings.
                 Enable in Settings to record video,
                 or record audio-only instead."
    [Go to Settings] [Record Audio Only] [Cancel]
    ↓
    IF [Record Audio Only]:
      Check mic permission (follow mic flow above)
    ELSE:
      → Return to Screen 5.1

ELSE (permissions already granted):
  → Screen 5.3 (Recording Screen)
```

**Permission States:**
- **Both granted:** Go straight to recording screen
- **Camera denied, mic granted:** Offer audio-only recording
- **Camera granted, mic denied:** Offer video-only recording (silent)
- **Both denied:** Show "Enable in Settings" with deep link

**Edge Cases:**
- User can record audio-only without camera permission
- User can record video-only (silent) without mic permission (edge case, probably not useful clinically)
- "Go to Settings" button deep-links to app settings page

---

**Screen 5.3: Recording Mode Choice Modal**

User has completed permission checks. Now they choose video or audio recording.

**Layout:**
```
┌─────────────────────────────────┐
│  Choose Recording Type          │  ← Header
│                                 │
│     [🎥 RECORD VIDEO]           │  ← Full width button
│                                 │
│     [🎙️ RECORD AUDIO]           │  ← Full width button
│                                 │
│     [Cancel]                    │  ← Text button (bottom)
└─────────────────────────────────┘
```

**Components:**
- Modal sheet (not full-screen)
- Two `PrimaryActionButton` instances
- Cancel text button

**Navigation:**
```
Tap [RECORD VIDEO] → Screen 5.3.1 (Video Recording Screen)
Tap [RECORD AUDIO] → Screen 5.3.2 (Audio Recording Screen)
Tap [Cancel] → Return to Screen 5.1 (Library)
```

**Design Rationale:**
- Upfront choice prevents accidental wrong-mode recording
- Clear visual distinction (video emoji vs audio emoji)
- Prevents camera preview loading for audio-only users (privacy)
- Simple, one-time decision (mode locked once chosen)

---

**Screen 5.3.1: Video Recording Screen**

User tapped [RECORD VIDEO]. Camera preview active.

**Layout (Before Recording):**
```
┌─────────────────────────────────┐
│  ✕                              │  ← Cancel (top left)
│                                 │
│  [Camera preview - full screen] │  ← Live camera feed
│                                 │
│                                 │
│                                 │
│     00:00                       │  ← Timer (center bottom)
│                                 │
│     [⏺ RECORD]                  │  ← Big red button
└─────────────────────────────────┘
```

**Layout (During Recording):**
```
┌─────────────────────────────────┐
│  ✕                              │  ← Cancel (disabled during recording)
│                                 │
│  [Camera preview - recording]   │  ← Red border or indicator
│                                 │
│                                 │
│                                 │
│     ⏺ 00:23                     │  ← Timer (incrementing)
│                                 │
│     [⏹ STOP]                    │  ← Stop button (red square)
└─────────────────────────────────┘
```

**Interaction Details:**
- Camera preview shows front-facing camera by default (user sees themselves)
- Timer shows 00:00 before recording starts
- Tap [⏺ RECORD] → Recording starts immediately, button changes to [⏹ STOP], timer increments
- Tap [⏹ STOP] → Recording stops, navigate to Screen 5.3.3 (Preview)
- Tap ✕ (before recording) → Confirm "Discard and return to library?" → Yes/No
- During recording, ✕ is disabled (must stop recording first)

**Technical Notes:**
- Uses AVCaptureSession for video recording
- Front camera default (user records message to themselves)
- Saves to .mov file in Documents/Recordings/
- No pause/resume (keeps it simple for MVP)

---

**Screen 5.3.2: Audio Recording Screen**

User tapped [RECORD AUDIO]. Audio-only mode.

**Layout (Before Recording):**
```
┌─────────────────────────────────┐
│  ✕                              │  ← Cancel (top left)
│                                 │
│     🎙️                          │  ← Microphone icon (large)
│                                 │
│  [Animated waveform - idle]     │  ← Audio visualization (flat)
│                                 │
│     00:00                       │  ← Timer (center bottom)
│                                 │
│     [⏺ RECORD]                  │  ← Big red button
└─────────────────────────────────┘
```

**Layout (During Recording):**
```
┌─────────────────────────────────┐
│  ✕                              │  ← Cancel (disabled)
│                                 │
│     🎙️                          │  ← Mic icon (pulsing red)
│                                 │
│  [Animated waveform - active]   │  ← Waveform reacts to voice
│                                 │
│     ⏺ 00:15                     │  ← Timer (incrementing)
│                                 │
│     [⏹ STOP]                    │  ← Stop button
└─────────────────────────────────┘
```

**Interaction Details:**
- Waveform shows audio levels in real-time (visual feedback that mic is working)
- Mic icon pulses red during recording
- Tap [⏺ RECORD] → Recording starts, waveform animates, timer increments
- Tap [⏹ STOP] → Recording stops, navigate to Screen 5.3.3 (Preview)
- Tap ✕ (before recording) → Confirm "Discard and return to library?" → Yes/No

**Technical Notes:**
- Uses AVAudioRecorder for audio recording
- Saves to .m4a file in Documents/Recordings/
- Waveform uses audio meter levels from AVAudioRecorder
- No pause/resume (UX parity with video)

---

**Screen 5.3.3: Post-Recording Preview & Save**

User tapped [⏹ STOP]. Recording complete. Preview before saving.

**Layout (Video Preview):**
```
┌─────────────────────────────────┐
│  ✕                     [SAVE]   │  ← Cancel / Save (top)
│                                 │
│  [Video player - paused]        │  ← First frame shown
│  [▶ Play]    2:34               │  ← Play button + duration
│                                 │
│  Title (Optional):              │  ← Text field
│  [                          ]   │     Placeholder: "Add a title..."
│  (40 char max)                  │
│                                 │
│  Notes (Optional):              │  ← Text field
│  [                          ]   │     Placeholder: "Add notes..."
│  (200 char max)                 │
│                                 │
│  Purpose (Optional):            │  ← Chip selector
│  [Motivational][Craving]        │  ← Single-select chips
│  [Reflection][Milestone]        │
└─────────────────────────────────┘
```

**Layout (Audio Preview):**
```
┌─────────────────────────────────┐
│  ✕                     [SAVE]   │
│                                 │
│     🎙️                          │  ← Audio icon
│  [Waveform visualization]       │
│  [▶ Play]    1:15               │  ← Play button + duration
│                                 │
│  Title (Optional):              │
│  [                          ]   │
│  (40 char max)                  │
│                                 │
│  Notes (Optional):              │
│  [                          ]   │
│  (200 char max)                 │
│                                 │
│  Purpose (Optional):            │
│  [Motivational][Craving]        │
│  [Reflection][Milestone]        │
└─────────────────────────────────┘
```

**Components:**
- Native video/audio player (inline preview, not full-screen)
- Text fields for title and notes
- `ChipSelector` for purpose (single-select, optional)
- Cancel button (✕)
- `PrimaryActionButton` (SAVE)

**Interaction Details:**
- Preview player loads automatically (paused state)
- Tap [▶ Play] → Plays recording in preview (user can verify it worked)
- Title field is optional, blank by default
- Notes field is optional, blank by default
- Purpose chips are optional, none selected by default
- All fields are scrollable (form scrolls vertically)

**Save Logic:**
```
Tap [SAVE]:
  IF title field has text:
    → Save with custom title
  ELSE (title blank):
    → Auto-generate title: "Recording Oct 25, 2025 3:42 PM"

  Save recording metadata to SwiftData:
    - RecordingModel.title (custom or auto-generated)
    - RecordingModel.notes (if entered)
    - RecordingModel.purpose (if selected)
    - RecordingModel.timestamp (now)
    - RecordingModel.duration (calculated from file)
    - RecordingModel.filePath (relative path to .mov or .m4a)
    - RecordingModel.type ("video" or "audio")
    - RecordingModel.playCount = 0

  File already saved during recording:
    - Documents/Recordings/video_[UUID].mov OR
    - Documents/Recordings/audio_[UUID].m4a

  → Toast: "Recording saved ✓" (2s)
  → Navigate to Screen 5.4 (Library with recordings)
```

**Cancel Flow:**
```
Tap ✕:
  → Show alert: "Discard recording? This cannot be undone."
     [Cancel] [Discard]

  IF [Discard]:
    → Delete file from Documents/Recordings/
    → Return to Screen 5.1 (Library)

  IF [Cancel]:
    → Return to preview screen (no action)
```

**Edge Cases:**
- Title max 40 characters (enforced by text field)
- Notes max 200 characters (character counter appears at 150 chars)
- If user replays recording multiple times before saving, playCount stays 0 (increments only from library)
- Purpose chips: Tap to select, tap again to deselect (optional = can save with none selected)

---

**Screen 5.4: Recordings Library (With Recordings)**

User has saved recordings. Main library view.

**Layout:**
```
┌─────────────────────────────────┐
│  Recordings            [+ NEW]  │  ← Header with new recording button
│─────────────────────────────────│
│  🎥 Don't Fucking Do It         │  ← Video, tap to play
│     Oct 25, 3:42 PM • 2:34      │     (most recent at top)
│     ▶ 12 plays                  │
│                                 │
│  🎙️ Remember Your Goals         │  ← Audio, tap to play
│     Oct 24, 8:15 PM • 1:15      │
│     ▶ 8 plays                   │
│                                 │
│  🎥 Why I'm Taking a Break      │  ← Video
│     Oct 23, 2:10 PM • 5:02      │
│     ▶ 5 plays                   │
│                                 │
│  🎙️ You Got This                │  ← Audio
│     Oct 22, 9:30 AM • 0:45      │
│     ▶ 2 plays                   │
│                                 │
│  🎥 Recording Oct 21, 1:05 PM   │  ← Auto-generated title (no custom)
│     Oct 21, 1:05 PM • 3:12      │
│     ▶ 0 plays                   │
└─────────────────────────────────┘
```

**Components:**
- Header with [+ NEW] button (tap → Screen 5.3, mode choice modal)
- List of recording rows (chronological, newest first)
- Each row shows:
  - Icon (🎥 video or 🎙️ audio)
  - Title (custom or auto-generated)
  - Timestamp + Duration
  - Play count

**Interaction Details:**
- **Tap row anywhere** → Play recording immediately (Screen 5.4.1, playback)
- **Swipe left on row** → [🗑️ Delete] button appears
- **Long-press on row** → Context menu appears:
  - "Edit Title & Notes"
  - "Delete"
  - "Cancel"
- **Tap [+ NEW]** → Navigate to Screen 5.3 (mode choice modal)

**Sorting:**
- Default: Chronological DESC (newest first)
- **MVP Note:** No sorting UI (tabs, filters). This can be added in v2 if users have 20+ recordings.
  - Potential v2: Tabs for "Most Played" / "Recent" / "All"
  - Data model already tracks playCount and timestamp, so sorting is trivial to add

---

**Screen 5.4.1: Recording Playback (Video)**

User tapped a video recording from library.

**Playback Experience:**
```
Full-screen native video player (AVPlayerViewController)
  - Standard iOS video controls (play/pause, scrub, volume, AirPlay)
  - Swipe down to dismiss
  - Tap anywhere → Show/hide controls
  - Rotate to landscape (automatic, if supported)
  - Native picture-in-picture support (iOS default)
```

**Post-Playback Actions:**
```
On dismiss (swipe down or tap Done):
  → Increment RecordingModel.playCount += 1
  → Update RecordingModel.lastPlayedAt = now
  → Save to SwiftData
  → Return to Screen 5.4 (Library)
```

**Technical Implementation:**
- Use `AVPlayerViewController` (native iOS)
- Load video from `Documents/Recordings/video_[UUID].mov`
- Zero custom UI needed (iOS handles everything)
- Playback increments play count (feeds Top 3 Most Played algorithm for home screen)

---

**Screen 5.4.2: Recording Playback (Audio)**

User tapped an audio recording from library.

**Playback Experience:**
```
Bottom sheet mini-player (overlays library screen)
┌─────────────────────────────────┐
│  🎙️ Remember Your Goals         │  ← Title (top)
│                                 │
│  [Waveform animation]           │  ← Audio visualization
│                                 │
│  ━━━━━●━━━━━━ 0:23 / 1:15      │  ← Progress bar + time
│                                 │
│  [⏮ 15s] [⏸] [⏭ 15s]           │  ← Skip back/pause/skip forward
│                                 │
│  Swipe down to close            │  ← Helper text
└─────────────────────────────────┘
```

**Interaction Details:**
- Audio plays in bottom sheet (user can navigate app while listening)
- Waveform animates based on audio amplitude
- Progress bar shows current position (draggable to scrub)
- [⏮ 15s] = Skip back 15 seconds
- [⏸] = Pause (changes to [▶] when paused)
- [⏭ 15s] = Skip forward 15 seconds
- Swipe down anywhere → Dismiss player, stop playback

**Post-Playback Actions:**
```
On dismiss (swipe down or playback complete):
  → Increment RecordingModel.playCount += 1
  → Update RecordingModel.lastPlayedAt = now
  → Save to SwiftData
  → Return to Screen 5.4 (Library)
```

**Technical Implementation:**
- Use AVPlayer with custom UI (bottom sheet)
- Load audio from `Documents/Recordings/audio_[UUID].m4a`
- Waveform visualization using audio meter levels
- Background playback NOT enabled (user must keep app open)

---

**Screen 5.4.3: Edit Recording (Title & Notes)**

User long-pressed recording row → Tapped "Edit Title & Notes" from context menu.

**Layout:**
```
┌─────────────────────────────────┐
│  Edit Recording        ✕        │  ← Header with close button
│─────────────────────────────────│
│  Title:                         │
│  [Don't Fucking Do It]          │  ← Pre-filled with existing title
│  (40 char max)                  │
│                                 │
│  Notes:                         │
│  [This was hard to record but   │  ← Pre-filled with existing notes
│   I needed to say it.]          │     (if exists, else blank)
│  (200 char max)                 │
│                                 │
│  Purpose:                       │
│  [●Motivational][○Craving]      │  ← Pre-selected if exists
│  [○Reflection][○Milestone]      │     (● = selected, ○ = unselected)
│                                 │
│─────────────────────────────────│
│     [SAVE CHANGES]              │  ← Primary CTA button
└─────────────────────────────────┘
```

**Components:**
- Bottom sheet (similar to post-recording preview)
- Text fields pre-filled with existing data
- `ChipSelector` for purpose (single-select, shows current selection)
- `PrimaryActionButton` (SAVE CHANGES)

**Interaction Details:**
- Sheet slides up from bottom
- Title field pre-filled (user can edit)
- Notes field pre-filled if exists, else blank
- Purpose chips show current selection (if exists)
- Tap [SAVE CHANGES] → Update RecordingModel → Toast "Updated ✓" → Dismiss sheet
- Tap ✕ → Dismiss sheet without saving (no confirmation needed)
- Swipe down → Dismiss sheet without saving

**Save Logic:**
```
Tap [SAVE CHANGES]:
  Update RecordingModel:
    - title (new value from text field)
    - notes (new value from text field, can be blank)
    - purpose (new selection from chips, can be none)

  Save to SwiftData
  → Toast: "Recording updated ✓" (2s)
  → Dismiss sheet
  → Return to Screen 5.4 (Library, updated row visible)
```

**Edge Cases:**
- If user clears title field (makes it blank), revert to auto-generated title on save
- Character limits enforced by text fields (40 title, 200 notes)
- Purpose can be deselected (tap selected chip to unselect)

---

**Screen 5.4.4: Delete Recording Confirmation**

User swiped left on recording row → Tapped [🗑️ Delete] OR long-pressed → Tapped "Delete".

**Layout:**
```
Alert (system iOS alert):

"Delete 'Don't Fucking Do It'?"
"This recording will be permanently deleted. This cannot be undone."

[Cancel]  [Delete]
          ↑ Red destructive button
```

**Interaction Flow:**
```
Tap [Delete]:
  → Delete RecordingModel from SwiftData
  → Delete file from Documents/Recordings/video_[UUID].mov (or .m4a)
  → Toast: "Recording deleted" (2s)
  → Row animates out of list
  → If library now empty, show Screen 5.1 (empty state)

Tap [Cancel]:
  → Dismiss alert
  → Return to Screen 5.4 (Library, no changes)
```

**Technical Notes:**
- Alert uses custom title (interpolates recording.title)
- Deletion is atomic: Both database record AND file must be deleted
- If file deletion fails, rollback database deletion (maintain consistency)
- If last recording deleted, library reverts to empty state (Screen 5.1)

---

### **Flow 6: Progress Dashboard Tab**

**Goal:** Show patterns after 7 days of data

**Screen 6.1: Dashboard (Empty State)**
**Layout:**
- [ ] TO BE DESIGNED SOCRATICALLY

**Screen 6.2: Dashboard (With Data)**
**Layout:**
- [ ] TO BE DESIGNED SOCRATICALLY

**Navigation:**
- [ ] TO BE MAPPED SOCRATICALLY

---

### **Flow 7: Settings Tab**

**Goal:** Data export, AI chat setup, permissions management

**Screen 7.1: Settings**
**Layout:**
- [ ] TO BE DESIGNED SOCRATICALLY

**Navigation:**
- [ ] TO BE MAPPED SOCRATICALLY

---

## 🚧 Status

**Completed:**
- ✅ General design guidelines (SwiftUI 2025 best practices)
- ✅ Component library defined (8 reusable components)
- ✅ Flow 1: Onboarding (Welcome + Optional Tour)
- ✅ Flow 2: Home Tab (Primary actions + Quick Play recordings)
- ✅ Flow 3: Log Craving (Bottom sheet form, full spec)
- ✅ Flow 4: Log Usage (Bottom sheet form, full spec with UX parity)
- ✅ Flow 5: Recordings Tab (Complete: Empty state, permissions, mode choice, recording screens, preview/save, library, playback, edit, delete)

**Not Started:**
- 🔴 Flow 6: Progress Dashboard Tab
- 🔴 Flow 7: Settings Tab

---

**Progress:** 5/7 flows complete (71%)

**Next Step:** Complete Flow 6 (Progress Dashboard Tab) - empty state, chart layouts, metrics visualization
