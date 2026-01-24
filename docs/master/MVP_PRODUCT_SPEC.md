# Cravey MVP Product Specification

**Version:** 1.4
**Last Updated:** 2025-10-25
**Status:** v1.4 - Final Product Specification (AI Chat Removed, UX Flows 100% Complete)

---

## 🔖 CHECKPOINT (2025-10-25 - ALL UX FLOWS COMPLETE)

**📋 For Full Project Status:** See `docs/CHECKPOINT_STATUS.md` (master doc tracking all planning docs)

**This Document's Status:**
- ✅ MVP_PRODUCT_SPEC.md v1.4 - **AI Chat REMOVED from MVP** (gimmicky, API cost unsustainable)
- ✅ All clinical validations complete, independent flow model finalized
- ✅ **UX_FLOW_SPEC.md 100% COMPLETE** - All 7 flows designed (19 screens total)
- ✅ **CRITICAL CHANGE:** Craving logging and usage logging are now INDEPENDENT
  - Removed "outcome" field from craving logging
  - Removed forced link between craving → usage
  - Users can track cravings only, usage only, or both
- ✅ Updated ROA amounts to match validated clinical model (CLINICAL_CANNABIS_SPEC.md):
  - Bowls/Joints/Blunts: 0.5 increments (0.5 → 5.0)
  - Vapes/Dabs: Whole number increments (1 → 10 for vapes, 1 → 5 for dabs)
  - Edibles: 5mg increments (5mg → 100mg)

**What's Next:**
- 🚀 **Move to DATA_MODEL_SPEC.md** - Define SwiftData schemas, relationships, persistence logic
- Then TECHNICAL_IMPLEMENTATION.md → Then START CODING

**v1.4 Changes (2025-10-25):**
- ❌ Removed Feature #5 (AI Chat) - Deferred indefinitely (recordings feature is better support mechanism)
- ✅ Feature #6 (Data Management) renumbered to Feature #5
- ✅ Updated success criteria (removed AI-related tests)
- ✅ Updated Phase 3 timeline (replaced "AI & Polish" with "Polish & Testing")
- ✅ All AI Chat references removed from spec

---

## Vision

**Cravey is a private, judgment-free iOS app that helps cannabis users understand their relationship with cannabis—whether they want to monitor use, reduce consumption, quit entirely, practice harm reduction, or simply track metrics for self-awareness.**

---

## Target User

**Primary Persona:**
Someone who uses cannabis and wants to:
- **Monitor their use** - Track patterns and understand habits
- **Cut down** - Reduce frequency or amount consumed
- **Stop completely** - Quit cannabis use
- **Harm reduction** - Maintain use at a specific, intentional level
- **Track metrics** - Data-driven self-awareness without judgment

**Shared Characteristics:**
- Values **privacy** - Doesn't want data shared with companies or cloud services
- Wants **self-compassion** - No shame, no streaks that "break," no punishment language
- May be in **vulnerable moments** - Needs fast, simple UI during cravings
- Wants **evidence-based support** - MI (Motivational Interviewing) principles, not lecturing
- Wants **self-directed tools** - Record motivational messages to themselves, see their own patterns

---

## Core Problems Solved

1. **Hard to track cravings AND cannabis use without judgment or data privacy concerns**
   → Most apps require cloud accounts or sell data. Users want local-only tracking. Crucially, users need to log *cravings* (whether resisted or not) to celebrate wins and understand triggers.

2. **Hard to resist cravings in the moment**
   → Users want to record motivational content when sober (video/audio messages to their future self) and replay during cravings.

3. **Hard to see patterns and progress over time**
   → Users want visual metrics (charts, trends) to understand their usage behavior and craving patterns.

4. **Hard to stay motivated without clear goals**
   → Users want to set their own goals (quit, reduce, monitor) and track progress toward them—without shame when goals shift.

---

## MVP Features (v1.0)

### 0. First Launch & Onboarding
**User Story:**
*"When I open the app for the first time, I want to understand what it does and grant only the permissions I'm comfortable with."*

**Functionality (✅ UPDATED 2025-10-18):**
- **Welcome Screen**
  - Brief intro: "Private, local-only cannabis tracking and support"
  - Privacy guarantee: "No cloud sync, no analytics, no data collection"
  - Clear value proposition: "Track patterns. Understand triggers. Make informed decisions."
- **Permission Requests**
  - Camera/Microphone (for motivational recordings)
  - Location Services (for environmental cue tracking)
  - Explained with clear "Why we need this" text
  - All permissions optional (app works without them)
  - **If denied:** Recording feature shows "Enable camera/mic in Settings to record" message. Location defaults to manual presets (Home/Work/Car/etc). User can still use all other features (logging, dashboard).
- **Quick Tour** (Optional, Skippable)
  - 3-screen walkthrough of core features
  - "Log Cravings & Usage → Record Motivational Videos → See Your Patterns"

**Deferred to Post-MVP:**
- **Goal Setting** - Removed from onboarding to reduce friction and focus on polished logging experience first. Users simply start tracking, and patterns naturally emerge. Goals can be added in v1.1 once users are already engaged with core tracking.

**Why It Matters:**
Sets user expectations, builds trust around privacy, and removes commitment pressure. Users can explore their patterns without declaring a goal upfront. **"Just track" is a valid use case** - reduces barrier to entry.

---

### 1. Craving Logging
**User Story:**
*"I want to log when I experience a craving so I can understand triggers and track patterns."*

**Functionality (✅ FULLY VALIDATED 2025-10-18):**
- **Fast input form** - Log in <10 seconds
- **UI Pattern:** Single scrollable form (Apple Health/Calendar style) - SAME as Usage Logging
  - Core fields at top (no scrolling needed for quick log)
  - Optional fields below divider ("Details" section)

**REQUIRED FIELDS:**
- **Intensity** - 1-10 slider
  - 1-3: Mild (manageable, background)
  - 4-6: Moderate (uncomfortable, requires coping)
  - 7-9: Strong (urgent, high risk)
  - 10: Overwhelming (crisis)
- **Timestamp** - Auto "now", editable to any past date/time (warning if >7 days)

**OPTIONAL FIELDS (Below divider):**
- **Trigger** - Multi-select HAALT chips (see Appendix A)
  - Primary: Hungry, Angry, Anxious, Lonely, Tired, Sad
  - Secondary: Bored, Social, Habit, Paraphernalia
- **Location** - Single-select chips (GPS + presets, see Appendix A)
  - Current Location (GPS), Home, Work, Social, Outside, Car
  - **Clinical rationale:** Environmental cues are relapse predictors. Location patterns reveal high-risk scenarios for intervention.
- **Notes** - Freeform text (500 character limit)

**NO "outcome" field** - Craving is logged independently, NOT linked to usage

**Instant Feedback** - After logging:
- "💪 Logged. Every moment of awareness counts."

**Why It Matters:**
**Logging cravings reframes urges as *data points*, not failures.** Users track patterns without judgment. Location + trigger data reveals environmental cues ("people, places, things") for targeted behavioral interventions. UX parity with Usage Logging reduces cognitive load.

---

### 2. Cannabis Usage Logging
**User Story:**
*"I want to quickly log when and how I use cannabis so I can see patterns over time."*

**Functionality (✅ FULLY VALIDATED 2025-10-18):**
- **Fast input form** - Log in <10 seconds
- **UI Pattern:** Single scrollable form (Apple Health/Calendar style)
  - Core fields at top (no scrolling needed for quick log)
  - Optional fields below divider ("Details" section)

**REQUIRED FIELDS:**
- **Date/Time** - Auto "now", editable to any past date/time (warning if >7 days)
- **Method (ROA)** - List selection
  - 💨 **Bowls** (pipes, bongs)
  - 🚬 **Joints**
  - 🌿 **Blunts**
  - 🌬️ **Vape** (pens, cartridges)
  - 💎 **Dab** (rigs, concentrates)
  - 🍫 **Edible** (gummies, brownies, drinks)
- **Amount** - Picker wheel (context-aware per ROA)
  - *Bowls/Joints/Blunts:* 0.5 → 5.0 in 0.5 increments (10 options)
  - *Vape:* 1 → 10 pulls (10 options)
  - *Dab:* 1 → 5 dabs (5 options)
  - *Edible:* 5mg → 100mg in 5mg increments (20 options)

**OPTIONAL FIELDS (Below divider):**
- **Trigger** - Multi-select HAALT chips (see Appendix A)
  - Primary: Hungry, Angry, Anxious, Lonely, Tired, Sad
  - Secondary: Bored, Social, Habit, Paraphernalia
- **Location** - Single-select chips (GPS + presets, see Appendix A)
  - Current Location (GPS), Home, Work, Social, Outside, Car
- **Notes** - Freeform text (500 character limit)

**NO forced link to cravings** - Usage is logged independently

**Why It Matters:**
Understanding *when*, *how*, and *why* they use helps users identify patterns and make informed decisions about their consumption. Picker wheels are fast, consistent, and match user mental models. HAALT-based triggers capture clinically meaningful data.

---

### 3. Pre-Recorded Motivational Content
**User Story:**
*"I want to record a video or voice message to my future self when I'm sober, so I can watch/listen during a craving."*

**Functionality:**
- **Record Video/Audio Messages** - When NOT experiencing a craving
  - Simple tap-to-record interface
  - Max 2 minutes per recording (keeps file sizes manageable)
  - Auto-compression to 720p for video (reduces storage)
  - Title the recording (e.g., "Why I'm Taking a Break," "Remember Your Goals")
  - Add category (user-assigned): Motivational, Milestone, Reflection, Other
  - Add notes/context
- **Replay During Cravings** - Easy access during vulnerable moments
  - Large, clear "Play" button on home screen
  - List view organized by category and recency
  - Play count tracking (see which recordings help most)
- **Privacy** - All recordings stored locally in app's Documents folder (never uploaded)
- **Simple Management** - Delete recordings anytime

**Why It Matters:**
Hearing your own voice/seeing your own face when you're clear-headed is more powerful than generic motivational quotes. Creates a personal accountability loop and provides immediate support during vulnerable moments.

---

### 4. Progress Metrics Dashboard
**User Story:**
*"I want to see my usage and craving trends over time so I can understand my progress."*

**Functionality (✅ FULLY VALIDATED 2025-10-18):**

**Summary Card (Top of Dashboard):**
- Weekly high-level stats at a glance
  - "This week: 12 uses, 3 cravings"
  - "Top trigger: Bored"
  - Quick reference without scrolling

**Visual Charts & Metrics (Swift Charts):**

**MVP Metrics (v1.0 - 5 cards):**

1. **Weekly Summary Card** - Top of dashboard
   - "This week: 12 uses, 3 cravings"
   - "Top trigger: Bored"
   - Quick reference without scrolling

2. **Current Clean Days Streak** - Streak card
   - Context-aware: "7 days used in a row" OR "5 days abstinent"
   - Shows current streak based on user's pattern

3. **Longest Abstinence Streak** - Milestone card
   - "Your best: 14 days"
   - Never resets, celebrates historical achievement

4. **Average Craving Intensity Over Time** - Line chart
   - Shows if cravings getting weaker/stronger week-over-week
   - Tracks improvement in craving severity over selected date range (7/30/90 days)

5. **Trigger Breakdown (Top 3)** - Pie chart
   - Shows proportion of top 3 triggers (40% Bored, 30% Anxious, 20% Habit...)
   - Applies to both usage and craving triggers combined

**Post-MVP Metrics (v1.1+ - Available as DashboardData computed properties):**

6. **Amount Trend Over Time** - Line chart
   - Shows if using more or less week-over-week
   - Reveals escalation or reduction patterns

7. **Usage Reduction/Change** - Comparison metric card
   - "Using 30% less than last month" OR "Usage increased 15%"
   - Context-aware (shows reduction or increase based on actual data)

8. **Location Patterns** - Bar chart or list
   - Where use/cravings occur most (Home 40%, Car 30%, Work 20%...)
   - Reveals high-risk environmental cues

9. **Time of Day Patterns** - Bar chart
   - Morning vs afternoon vs evening distribution
   - Identifies temporal patterns

10. **Weekly Patterns** - Bar chart
    - Usage by day of week (Mon: 2, Tue: 1, Wed: 3...)
    - Shows which days are highest risk

11. **ROA Breakdown** - Pie chart
    - Method distribution (50% Bowls, 30% Vape, 20% Edibles...)
    - Tracks ROA switching (escalation indicator)

**UI/UX Details:**
- **Empty States** - If <7 days of data: "Keep logging! You'll see patterns after 7 days."
- **Date Range Filter** - Toggle between 7 days / 30 days / 90 days / All Time
- **Scrollable Dashboard** - Metrics organized by priority (summary card first)
- **Direct Log Access** - Tap any metric to view detailed logs (no daily count clutter on dashboard)

**Future Consideration:**
- Heatmap visualization (time-of-day + day-of-week combined - GitHub-style)

**Why It Matters:**
Seeing patterns over time helps users make intentional changes. **Environmental context** (location, time, triggers) reveals high-risk scenarios for intervention. **Behavioral tracking** (streaks, ROA switching, amount trends) shows escalation or improvement. Visual simplicity (pie/line/bar charts) provides quick insights without cognitive load. Focus on **trends, not single data points**.

---

### 5. Data Management
**User Story:**
*"I want full control over my data—I should be able to export it or delete it anytime."*

**Functionality:**
- **Export All Data** (Settings → Data Management)
  - Format: CSV (for spreadsheets) or JSON (for developers/researchers)
  - Includes: All usage logs, craving logs, recordings metadata (not video/audio files)
  - Share via iOS share sheet (AirDrop, email, save to Files)
- **Delete All Data** (Settings → Data Management → Advanced)
  - Confirmation dialog: "This cannot be undone. All logs and recordings will be permanently deleted."
  - Deletes: SwiftData database + all recording files
  - App resets to first-launch state
- **Delete Individual Entries** (in-app)
  - Swipe-to-delete on usage/craving logs
  - Long-press-to-delete on recordings

**Why It Matters:**
Data transparency builds trust. Users feel in control, reducing anxiety about privacy. Export enables sharing with therapists/doctors if desired.

---

## Out of Scope for MVP

### Not Included in v1.0 (Deferred to Post-MVP):
- **Cloud sync** - 100% local-only for privacy
- **Push notifications** - No reminders, no check-ins (reduces complexity, maintains privacy)
- **AI chat support** - Removed from MVP (gimmicky, API cost unsustainable, recordings feature provides better in-app support)
- **Goal tracking** - Focus on polished logging + dashboard first; goals = v1.1 enhancement
- **Craving vs usage ratio** - Too granular, needs bulk data for meaningful patterns
- **Trigger combinations** - Trigger breakdown pie chart sufficient for MVP
- **Heatmap visualization** - GitHub-style contribution graph (time + day combined) = future enhancement
- **Social features** - No sharing, no community forums
- **Prescription tracking** - Medical cannabis features (future consideration)
- **THC potency tracking** - False precision, clinically useless (see CLINICAL_CANNABIS_SPEC.md)
- **Medical vs recreational distinction** - Triggers already capture "why" without stigma/judgment
- **macOS version** - iOS-only first (macOS planned for future)
- **Pre-populated motivational quotes** - User-generated content only (may add later)
- **Integration with other apps** - No HealthKit, no calendar sync (future consideration)
- **Accessibility audit** - Will add VoiceOver/Dynamic Type support post-MVP after user testing

---

## Success Criteria

### Technical Success (Testable)

v1.0 MVP is technically successful if:

1. **User can log craving in <5 seconds** - Timed via user testing (from home screen to "saved")
2. **User can log cannabis use in <10 seconds** - Timed via user testing
3. **User can record 60-second video without crashes** - Tested on iPhone 17 Pro (iOS 18+)
4. **User can view charts with 14+ days of data** - All charts render correctly with sample data
5. **Zero network calls** - Verified via Xcode Network Debug or proxy (100% local-only)
6. **Data persists across app restarts** - SwiftData persistence confirmed
7. **Export produces valid CSV/JSON** - Files can be opened in Numbers/Excel or parsed programmatically

### User Success (Post-Launch)

v1.0 MVP is user-successful if (measured 3 months post-launch):

1. **4.5+ star rating on App Store** - Users find it valuable
2. **"Supportive" mentioned in 50%+ of positive reviews** - MI language resonates
3. **"Privacy" mentioned in 30%+ of positive reviews** - Privacy-first approach is noticed
4. **<5% uninstall rate within first week** - Users don't immediately delete (proxy for value)
5. **Average user logs 3+ times per week** - App is actively used, not abandoned

### Ethical Success (Ongoing)

v1.0 MVP is ethically successful if:

1. **Zero data breaches or privacy incidents** - No user data ever sent to Cravey servers
2. **No reports of judgmental language** - MI principles maintained throughout
3. **No user complaints about broken streaks or punishment framing** - "Days in Progress" works as intended

---

## Privacy & Ethics Commitments

1. **No Data Collection** - App never sends any data to any server (100% local-only)
2. **No Analytics** - No Firebase, no Mixpanel, no tracking SDKs
3. **No Ads** - Never monetized via ads or data sales
4. **Local-Only Storage** - SwiftData with CloudKit disabled (`.none`)
5. **No Push Notifications** - No reminders or check-ins (privacy + simplicity)
6. **No Network Calls** - Zero API calls, zero cloud services (verified via Xcode Network Debug)
7. **Motivational Interviewing Language** - No shame, no punishment, no "failure" framing
8. **No Broken Streaks** - "Days in Progress" never resets; setbacks are normalized

---

## User Experience Principles

1. **Ultra-Low Friction** - Users may be in crisis or impaired. Craving log <5 sec, usage log <10 sec.
2. **Large Touch Targets** - Minimum 44pt tap areas (Apple HIG compliance) for easy interaction.
3. **Private by Default** - No account creation, no login, no cloud sync, no tracking.
4. **Compassionate Language** - "You're doing great" not "You failed." Every interaction is supportive.
5. **Celebrate Resistance** - Resisting a craving is explicitly framed as a WIN, not just absence of failure.
6. **Data Transparency** - Users can export/delete all data anytime. No hidden databases.
7. **Flexible Goals** - Users can change their goal (quit/reduce/monitor) without shame.
8. **No Punishment** - No broken streaks, no red warnings, no scolding. "Days in Progress" counts up forever.

---

## Technical Constraints (High-Level)

- **Platform:** iOS 18+ only (initial release)
- **Architecture:** Clean Architecture + MVVM
- **Storage:** SwiftData (local-only, CloudKit `.none`)
- **UI:** SwiftUI (iOS 18+)
- **Recording:** AVFoundation
- **Charts:** Swift Charts
- **Network:** Zero network calls (100% offline)

---

## Next Steps

### Immediate (Planning Phase)
1. ✅ **AI Agent Review** - Completed (agent provided critical feedback)
2. ✅ **Converge on Final Version** - All must-have changes incorporated
3. ✅ **Lock MVP_PRODUCT_SPEC.md (v1.4)** - This document is locked (all clinical validations complete, AI chat removed, 6 features finalized)
4. ✅ **Create CLINICAL_CANNABIS_SPEC.md** - Completed (cannabis-specific tracking requirements)
5. ✅ **Create UX_FLOW_SPEC.md (v1.2)** - Completed (all 7 flows designed, 19 screens specified)
6. **Create DATA_MODEL_SPEC.md** ← **NEXT** - Define exact SwiftData schemas for CravingModel, UsageModel, RecordingModel, MotivationalMessageModel
7. **Create TECHNICAL_IMPLEMENTATION.md** - Map features to repos/use cases/views, define implementation order

### Phase 1: Core Functionality (Weeks 1-4)
1. Implement Craving Logging (View + ViewModel + Use Cases)
2. Implement Usage Logging (View + ViewModel + Use Cases)
3. Implement Onboarding Flow (Welcome, Permissions, Tour)
4. Implement Data Management (export/delete)

### Phase 4: Recordings (Weeks 5-6)
1. Implement AVFoundation Recording (video/audio capture)
2. Implement Playback UI
3. Implement Recording Library with filters
4. Implement Quick Play section (Home tab)

### Phase 5: Dashboard (Weeks 7-8)
1. Implement Dashboard with 5 MVP metrics (Swift Charts)
2. Implement date range filtering (7/30/90 days)
3. Implement FetchDashboardDataUseCase
4. Test dashboard load time (<3 sec target)

### Phase 6: Polish, Testing & Launch (Weeks 9-16)
1. UI/UX polish (animations, empty states, error handling, haptics)
2. User testing and iteration
3. Performance optimization (SwiftData queries, chart rendering)
4. Accessibility improvements (VoiceOver, Dynamic Type)

### Phase 4: Launch Prep (Weeks 13-16)
1. TestFlight beta with target users
2. Incorporate feedback
3. App Store assets (screenshots, description, privacy policy)
4. Submit to App Store

---

## Appendix A: Data Dictionary

### ROA (Route of Administration) Amount Details

**See `docs/CLINICAL_CANNABIS_SPEC.md` for full clinical validation.**

#### 💨 Bowls (Pipes / Bongs)
- **Incrementing by 0.5** (0.5, 1, 1.5, 2... up to 5.0)
- **Picker wheel:** 10 options (0.5 → 5.0)
- Examples: 0.5 bowls (half bowl), 1 bowl (full bowl), 1.5 bowls

#### 🚬 Joints
- **Incrementing by 0.5** (0.5, 1, 1.5, 2... up to 5.0)
- **Picker wheel:** 10 options (0.5 → 5.0)
- Examples: 0.5 joints (half joint), 1 joint (full joint), 2 joints

#### 🌿 Blunts
- **Incrementing by 0.5** (0.5, 1, 1.5, 2... up to 5.0)
- **Picker wheel:** 10 options (0.5 → 5.0)
- Examples: 0.5 blunts (half blunt), 1 blunt (full blunt)

#### 🌬️ Vape (Pens / Cartridges)
- **Incrementing by 1** (1, 2, 3, 4... up to 10 pulls)
- **Picker wheel:** 10 options (1 → 10)
- Examples: 1 pull, 3 pulls, 10 pulls

#### 💎 Dab (Concentrates)
- **Incrementing by 1** (1, 2, 3, 4, 5 dabs)
- **Picker wheel:** 5 options (1 → 5)
- Examples: 1 dab, 2 dabs, 3 dabs

#### 🍫 Edible (Gummies / Brownies / Drinks)
- **Incrementing by 5mg THC** (5mg, 10mg, 15mg, 20mg... up to 100mg)
- **Picker wheel:** 20 options (5mg → 100mg)
- Examples: 5mg (microdose), 10mg (one standard gummy), 20mg, 50mg

### Trigger Categories (Craving & Usage)

**✅ VALIDATED 2025-10-18** - See `CLINICAL_CANNABIS_SPEC.md` for full rationale

**HAALT-Based Multi-Select Chips:**

**Primary Triggers (Evidence-Based HAALT Model):**
- **Hungry** - Physiological hunger
- **Angry** - Irritability, frustration, resentment
- **Anxious** - Worry, panic, unease
- **Lonely** - Isolation, disconnection
- **Tired** - Fatigue, exhaustion, low energy
- **Sad** - Depression, grief, emotional pain

**Secondary Triggers:**
- **Bored** - Understimulated, nothing to do
- **Social** - Friends using, social context (not necessarily negative)
- **Habit** - Routine, automatic behavior (e.g., "always smoke at 8pm")
- **Paraphernalia** - Visual cue (bong, lighter, dealer's contact)

**Multi-select enabled** - users can select multiple simultaneous triggers

### Location Presets (Usage Logging Only)

**✅ VALIDATED 2025-10-18**

**Single-Select Chips:**
- **Current Location** - GPS auto-detect via CoreLocation (local storage only)
- **Home**
- **Work**
- **Social** - Friend's house, party, gathering
- **Outside** - Park, street, outdoors
- **Car**

**Privacy:** First-time GPS use shows tooltip: "Location data never leaves your device"

---

## Appendix B: Data Relationships & Deletion Rules

### Craving ↔ Recording Relationship
**Structure:**
- Cravings can optionally reference recordings (many-to-one: multiple cravings can link to the same motivational video)
- Recordings exist independently of cravings (created during sober moments, not tied to specific craving events)

**Delete Behavior:**
1. **When user deletes a craving:**
   - Associated recording is NOT deleted (preserved for future use)
   - If recording was referenced by the craving, it remains accessible in Recordings library

2. **When user deletes a recording:**
   - Craving entries that referenced it remain intact
   - Craving data (intensity, timestamp, trigger, location, notes) is preserved
   - No cascading deletes

3. **When user selects "Delete All Data":**
   - All cravings, usage logs, AND recordings are permanently deleted
   - App resets to first-launch state

**Why These Rules:**
- **User Intent:** Deleting a craving log means "I want to remove this data point," not "delete my motivational content"
- **Data Integrity:** Recordings are valuable assets created intentionally, separate from spontaneous craving logs
- **Flexibility:** User can curate recordings independently without affecting historical logs

### Usage ↔ Craving Relationship (v1.3 UPDATE)
**Structure:**
- **Craving and Usage are INDEPENDENT logs** (no relationship, separate tracking)
- Users can log cravings only, usage only, or both - no forced connection
- No "outcome" field on cravings (removed to eliminate forced linkage)
- Supports all real-world patterns:
  - "I had a craving and didn't use" (log craving only)
  - "I used without a conscious craving" (log usage only)
  - "I tracked both" (log craving, then separately log usage)

**Delete Behavior:**
1. **When user deletes a usage log:**
   - Only that usage log is deleted
   - No impact on craving logs (separate data)

2. **When user deletes a craving log:**
   - Only that craving log is deleted
   - No impact on usage logs (separate data)
   - Recordings associated with that craving remain intact (see above)

**Why These Rules:**
- **Clinical Accuracy:** Many users experience cravings without using, or use without recognizing a craving
- **User Autonomy:** No forced decisions ("Did you use?" prompt creates pressure/shame)
- **Data Integrity:** Clean separation allows accurate tracking of both phenomena independently

---

**Status:** v1.3 LOCKED & READY FOR IMPLEMENTATION 🚀🔥

**Last Validated:** 2025-10-18 (All clinical models finalized, independent logging flows confirmed, dashboard metrics locked)
