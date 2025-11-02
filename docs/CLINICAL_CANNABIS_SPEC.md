# Clinical Cannabis Tracking Specification

**Author:** Ray (Psychiatrist / Addiction Medicine)
**Last Updated:** 2025-10-18
**Status:** ✅ Complete - All Clinical Validations Done
**Purpose:** Validate clinical accuracy of cannabis tracking model BEFORE implementation

---

## 🧠 Domain Expert Validation

This doc is where the domain expert (you) validates that the tracking model is clinically useful for harm reduction. Not what's technically easy to build - what actually matters for patient care.

**Key Question:** What granularity of tracking helps people reduce harm without being burdensome?

---

## 📊 Cannabis Quantity Tracking (Routes of Administration)

**✅ VALIDATED MODEL - Simple Incrementing Counts (Clinically Useful, Fast to Log)**

### 1. **SMOKE - Bowls** (Pipes / Bongs)

**Tracking Method:**
- **Incrementing by 0.5** (0.5, 1, 1.5, 2... up to 5.0)

**Examples:**
- 0.5 bowls = half bowl
- 1 bowl = full bowl
- 1.5 bowls = one and a half bowls
- 2 bowls = two full bowls

**Why This Works:**
- Matches user mental model ("I smoked half a bowl" = 0.5)
- Simple number incrementing (10 picker options: 0.5 → 5.0)
- Max 5 bowls covers heavy sessions (outliers rare)
- Actionable for harm reduction (track "3 bowls" vs "0.5 bowls")
- Quick to log (<5 sec)

---

### 2. **SMOKE - Joints**

**Tracking Method:**
- **Incrementing by 0.5** (0.5, 1, 1.5, 2... up to 5.0)

**Examples:**
- 0.5 joints = half joint
- 1 joint = full joint
- 1.5 joints = one and a half joints
- 2 joints = two full joints

**Why This Works:**
- Same pattern as bowls - simple, fast, intuitive (10 picker options)
- Half joints are common (sharing, rationing)
- Max 5 joints covers heavy sessions

---

### 3. **SMOKE - Blunts**

**Tracking Method:**
- **Incrementing by 0.5** (0.5, 1, 1.5, 2... up to 5.0)

**Examples:**
- 0.5 blunts = half blunt
- 1 blunt = full blunt
- 1.5 blunts = one and a half blunts

**Why This Works:**
- Consistent with bowls/joints pattern (10 picker options)
- Max 5 blunts covers heavy sessions
- Blunts often contain more cannabis than joints, but user knows their own context

**Clinical Note:**
- Blunts use tobacco wraps (nicotine exposure) - track this separately? Out of scope for MVP.

---

### 4. **VAPE - Pens / Cartridges**

**Tracking Method:**
- **Incrementing by 1** (1, 2, 3, 4... up to 10 pulls)

**Examples:**
- 1 pull
- 3 pulls
- 10 pulls

**Why This Works:**
- Simple whole number counting
- No short/long distinction (too pedantic, hard to track accurately)
- Max 10 pulls covers typical sessions (users lose count beyond that)
- Quick to log

**Clinical Note:**
- Vape cartridges vary wildly in THC % (300mg to 1000mg+)
- Pull count may not correlate directly with THC intake
- But useful for behavioral tracking (frequency patterns, escalation over time)
- Pull counting is inherently imprecise but captures pattern (light vs heavy use)

---

### 5. **DAB - Concentrates**

**Tracking Method:**
- **Incrementing by 1** (1, 2, 3, 4, 5 dabs)

**Examples:**
- 1 dab
- 2 dabs
- 3 dabs

**Why This Works:**
- Simple whole number counting (5 picker options)
- Max 5 dabs covers heavy sessions (dabs are potent)
- No small/large distinction (half dabs are weird, users just count dabs)
- Quick to log

**Clinical Note:**
- Dabs are high-potency (60-90% THC vs 15-25% flower)
- **Clinical concern:** Tolerance escalation with concentrate use
- Count alone is sufficient for behavioral tracking

---

### 6. **EDIBLE - Gummies / Brownies / Drinks**

**Tracking Method:**
- **Incrementing by 5mg THC** (5mg, 10mg, 15mg, 20mg... up to 100mg)

**Examples:**
- 5mg = microdose
- 10mg = one standard gummy
- 20mg = two gummies or one strong gummy
- 50mg = higher dose
- 100mg = very high dose

**Why This Works:**
- 5mg increments capture microdosing (clinically important)
- Dispensaries standardize at 5mg/10mg doses
- Users can read packaging
- 20 picker options (5mg → 100mg) = scrollable but not overwhelming
- Quick to log if they know dosage

**Clinical Note:**
- Edibles have delayed onset (1-3 hours)
- **Clinical concern:** Overdosing from impatience ("not feeling it yet, eat more")
- Tracking mg helps identify dose patterns and tolerance
- 5mg increments support harm reduction tracking for low-dose users

---

## 🤔 Open Questions (To Brainstorm)

### Routes of Administration (ROA) - Complete?
- ✅ **Smoke (Bowls)** - Incrementing by 0.5 (0.5, 1, 1.5, 2... up to 5.0)
- ✅ **Smoke (Joints)** - Incrementing by 0.5 (0.5, 1, 1.5, 2... up to 5.0)
- ✅ **Smoke (Blunts)** - Incrementing by 0.5 (0.5, 1, 1.5, 2... up to 5.0)
- ✅ **Vape** - Incrementing by 1 (1, 2, 3, 4... up to 10 pulls)
- ✅ **Dab** - Incrementing by 1 (1, 2, 3, 4, 5 dabs)
- ✅ **Edible** - Incrementing by 5mg (5mg, 10mg, 15mg, 20mg... up to 100mg)
- ❌ **Other** - Tinctures, topicals, etc. (DEFERRED to post-MVP - users can log as edible with notes workaround)

### Craving Intensity Scale
- ✅ **1-10 scale** - VALIDATED (standard medical pain scale model)
  - **Why:** Familiar, granular, fast (slider UI), clinically meaningful
  - **Clinical interpretation:**
    - 1-3: Mild (manageable, background)
    - 4-6: Moderate (uncomfortable, requires coping)
    - 7-9: Strong (urgent, high risk)
    - 10: Overwhelming (crisis)
  - **Research-backed:** Most addiction studies use 0-10 or 1-10 scales
  - **UX:** Slider with haptic feedback, <2 sec to log

### ✅ Craving & Usage Logging - INDEPENDENT FLOWS (VALIDATED)

**Critical Insight (2025-10-12):**
- **Craving logging and usage logging should be SEPARATE.**
- Not all users track both - some monitor usage only (harm reduction), some track cravings only (quit-focused)
- Forcing "craving → outcome → usage" creates unnecessary complexity

**Two Independent Flows:**

#### Flow 1: Log Craving (✅ FULLY VALIDATED 2025-10-18)

**REQUIRED FIELDS (Top of Form - <10 sec logging):**
1. **Intensity** (1-10 slider - validated pain scale model)
   - 1-3: Mild (manageable, background)
   - 4-6: Moderate (uncomfortable, requires coping)
   - 7-9: Strong (urgent, high risk)
   - 10: Overwhelming (crisis)
2. **Timestamp** (Auto "now", editable to any past date/time with warning if >7 days)

**OPTIONAL FIELDS (Below divider - "Details" section):**
3. **Trigger** (Multi-select chips - HAALT-based):
   - Primary: Hungry, Angry, Anxious, Lonely, Tired, Sad
   - Secondary: Bored, Social, Habit, Paraphernalia
4. **Location** (Single-select chips with GPS option):
   - Current Location (GPS auto-detect via CoreLocation, local storage only)
   - Home, Work, Social, Outside, Car
   - **Clinical rationale:** Environmental cues ("people, places, things") are relapse predictors. Location patterns reveal high-risk scenarios (e.g., "8/10 cravings at Car 5:30 PM" = commute trigger).
5. **Notes** (Freeform text, 500 character limit)

**UI Pattern:**
- Single scrollable form (Apple Health/Calendar style) - SAME as Usage Logging
- Core fields visible at top (no scrolling needed for quick log)
- Optional fields below divider (scroll down to add details)
- Privacy notice on first GPS use: "Location data never leaves your device"

**NO "outcome" field** - craving is logged independently, NOT linked to usage

**Optional Enhancement (Post-MVP):**
- Add "Attach Recording" button to link to motivational video/audio (helps users self-soothe during craving)

#### Flow 2: Log Usage (✅ FULLY VALIDATED 2025-10-18)

**REQUIRED FIELDS (Top of Form - <10 sec logging):**
1. **ROA** (List selection: Bowls/Joints/Blunts/Vape/Dab/Edible)
2. **Amount** (Picker wheel - context-aware per ROA):
   - Bowls/Joints/Blunts: 0.5 → 5.0 in 0.5 increments (10 options)
   - Vape: 1 → 10 pulls (10 options)
   - Dab: 1 → 5 dabs (5 options)
   - Edible: 5mg → 100mg in 5mg increments (20 options)
3. **Timestamp** (Auto "now", editable to any past date/time with warning if >7 days)

**OPTIONAL FIELDS (Below divider - "Details" section):**
4. **Trigger** (Multi-select chips - HAALT-based):
   - Primary: Hungry, Angry, Anxious, Lonely, Tired, Sad
   - Secondary: Bored, Social, Habit, Paraphernalia
5. **Location** (Single-select chips with GPS option):
   - Current Location (GPS auto-detect via CoreLocation, local storage only)
   - Home, Work, Social, Outside, Car
6. **Notes** (Freeform text, 500 character limit)

**UI Pattern:**
- Single scrollable form (Apple Health/Calendar style)
- Core fields visible at top (no scrolling needed for quick log)
- Optional fields below divider (scroll down to add details)
- Privacy notice on first GPS use: "Location data never leaves your device"

**NO forced link to cravings** - completely independent flow

**Optional Enhancement (Post-MVP):**
- Add checkbox: "Was this preceded by a craving?" (yes/no)
- If yes, could link to recent craving entry (but NOT required)

### ✅ Trigger Categories - VALIDATED (2025-10-18)

**HAALT-Based Multi-Select Chips:**

**Primary Triggers (Evidence-Based HAALT Model):**
- Hungry
- Angry
- Anxious
- Lonely
- Tired
- Sad (added for clinical completeness)

**Secondary Triggers:**
- Bored
- Social (context, not necessarily negative)
- Habit (automatic/routine use)
- Paraphernalia (cue-induced)

**Multi-select enabled** - users can select multiple simultaneous triggers (e.g., Tired + Lonely + Bored)

**Rationale:**
- HAALT is evidence-based relapse prevention framework
- Covers physiological (Hungry, Tired), emotional (Angry, Sad, Anxious, Lonely), and situational triggers
- "Sad" complements emotional spectrum (distinct from Anxious/Angry)
- Removed "Other" to eliminate decision fatigue - current triggers cover 95%+ of use cases
- Multi-select captures reality (triggers rarely singular)

### ✅ THC Potency Tracking - RESOLVED (2025-10-18)

**Decision: SKIP ENTIRELY (Post-MVP, likely never)**

**Clinical Rationale:**
- **False precision for smoked/vaped ROAs:** Combustion destroys unknown % THC, bioavailability varies wildly (10-30%), impossible to calculate actual intake from "3 pulls" or "2 bowls"
- **Edibles already captured:** We track mg THC directly (5mg, 10mg, 15mg...) - no separate potency field needed
- **Real escalation signals already tracked:**
  - ROA switching (flower → vape → dab = tolerance escalation)
  - Increasing amount over time (1 bowl/day → 4 bowls/day)
  - Frequency increase (daily → multiple times/day via timestamps)
- **Bogus data worse than no data:** Asking users to guess THC % creates garbage data that burdens users without clinical value

**Conclusion:** App already captures everything clinically meaningful. Potency tracking adds friction without insight.

---

### ✅ Medical vs. Recreational Distinction - RESOLVED (2025-10-18)

**Decision: SKIP ENTIRELY**

**Clinical Rationale:**
- **False binary:** Real-world use is nuanced (pain + boredom + habit simultaneously)
- **Stigma/shame:** Forcing "good reason vs bad reason" judgment reduces honesty
- **Already captured by triggers:** Anxious/Sad/Tired = therapeutic intent, Bored/Social = recreational context, Habit/Paraphernalia = compulsive use
- **Harm reduction doesn't care about intent:** Outcomes matter (escalation patterns, functional impairment), not labels
- **"Medical card" ≠ medical use:** Many get cards for legal dispensary access, doesn't reflect actual therapeutic use

**Conclusion:** Triggers + usage patterns tell the complete story without reductive labels. Non-judgmental approach maximizes honest data.

---

### ✅ Dashboard Metrics - FULLY VALIDATED (2025-10-18)

**What timeframes/metrics matter clinically for Progress Dashboard:**

**INCLUDE IN MVP:**
1. **Summary Card (Top)** - Weekly high-level stats (X uses, Y cravings, top trigger)
2. **Amount Trend Over Time** - Line chart showing usage increasing/decreasing week-over-week
3. **Usage Reduction/Change** - Comparison metric ("Using 30% less than last month")
4. **Trigger Breakdown** - Pie chart showing proportion of each trigger (40% Bored, 30% Anxious...)
5. **Location Patterns** - Where use/cravings occur most (Home 40%, Car 30%...)
6. **Time of Day Patterns** - Morning vs afternoon vs evening use distribution
7. **Weekly Patterns** - Bar chart showing usage by day of week (Mon: 2, Tue: 1, Wed: 3...)
8. **ROA Breakdown** - Pie chart showing method distribution (50% Bowls, 30% Vape, 20% Edibles...)
9. **Consecutive Days Tracking** - Current streak (context-aware: "7 days used" OR "5 days abstinent")
10. **Longest Abstinence Streak** - Milestone tracker ("Your best: 14 days")
11. **Average Craving Intensity Over Time** - Line chart showing if cravings getting weaker/stronger

**SKIP FOR MVP (Reduces Clutter):**
- Daily usage count (accessible via log view instead)
- Craving vs usage ratio (too granular, needs bulk data for patterns)
- Trigger combinations (trigger breakdown sufficient)

**FUTURE CONSIDERATION:**
- Heatmap visualization (time-of-day + day-of-week combined - GitHub-style contribution graph)

**Clinical Rationale:**
- Focus on **patterns over time** (trends, not single data points)
- **Environmental context** (location, time, triggers) reveals high-risk scenarios
- **Behavioral tracking** (streaks, ROA switching) shows escalation/improvement
- **Visual simplicity** (pie charts, line charts, bar charts) = quick insights without cognitive load

---

## 📝 Clinical Notes (Brainstorming Space)

*(Keep adding thoughts here as you brainstorm)*

**✅ Session Summary (2025-10-12):**

**1. ROA Tracking Model - VALIDATED**
- Simple incrementing counts match user mental models
- **Bowls/Joints/Blunts:** 0.5 increments (0.5 → 5.0)
- **Vapes/Dabs:** Whole number increments (1 → 10 for vapes, 1 → 5 for dabs)
- **Edibles:** 5mg increments (5mg, 10mg, 15mg, 20mg... up to 100mg)
- No overly pedantic distinctions (no "short/long pulls", no "small/large dabs")
- Fast to log (<5 sec target)
- Supports harm reduction insights ("using 0.5 bowls vs 3 bowls")

**2. Craving Intensity Scale - VALIDATED**
- **1-10 slider** (familiar pain scale model)
- Clinically meaningful ranges: 1-3 mild, 4-6 moderate, 7-9 strong, 10 overwhelming
- Fast to log (<2 sec with slider)

**3. CRITICAL INSIGHT - Independent Flows**
- **Craving logging ≠ Usage logging**
- Users have different goals: some monitor usage only, some track cravings only, some both
- **NO forced "outcome" field on cravings**
- **NO forced link between craving → usage**
- Keep them SEPARATE, simple, fast

**Key Principle:**
- Users in vulnerable moments need FAST, SIMPLE logging
- "Half bowl / full bowl" >> "number of puffs" (clinically useless)
- Granularity supports behavioral tracking without being burdensome
- Don't force workflows that don't match all user needs

---

## 🎯 What This Doc Will Inform

Once validated, this doc feeds into:
1. **UX_FLOW_SPEC.md** - How do users actually select these quantities?
2. **DATA_MODEL_SPEC.md** - What fields do we store in SwiftData?
3. **MVP_PRODUCT_SPEC.md** - May revise Appendix A (ROA amounts)

---

---

## 🔖 CHECKPOINT (2025-10-18)

**Status:** ✅ 100% COMPLETE - ALL CLINICAL VALIDATIONS DONE 🔥🔥🔥

**What's Validated:**

### Core Logging Flows:
1. ✅ **CRAVING LOGGING UX FLOW (Flow 1):**
   - Intensity (1-10 slider with clinical ranges)
   - Timestamp (auto "now", editable with >7 day warning)
   - Optional fields: Trigger (HAALT multi-select), Location (GPS + presets), Notes (500 char)
   - UI pattern: Single scrollable form (Apple HIG) - SAME as Usage Logging
   - Location included for cravings (environmental cue tracking = relapse prevention)

2. ✅ **USAGE LOGGING UX FLOW (Flow 2):**
   - ROA selection (List UI)
   - Amount input (Picker wheel, context-aware per ROA):
     - Bowls/Joints/Blunts: 0.5 → 5.0 (10 options)
     - Vape: 1 → 10 pulls (10 options)
     - Dab: 1 → 5 dabs (5 options)
     - Edible: 5mg → 100mg in 5mg increments (20 options)
   - Timestamp (auto "now", editable with >7 day warning)
   - Optional fields: Trigger (HAALT multi-select), Location (GPS + presets), Notes (500 char)
   - UI pattern: Single scrollable form (Apple HIG)

3. ✅ **TRIGGER CHIPS (Both Flows):** HAALT-based multi-select
   - Primary: Hungry, Angry, Anxious, Lonely, Tired, Sad
   - Secondary: Bored, Social, Habit, Paraphernalia

4. ✅ **LOCATION PRESETS (Both Flows):** Single-select with GPS
   - Current Location (GPS), Home, Work, Social, Outside, Car

5. ✅ **CRITICAL:** Independent flows (craving logging ≠ usage logging)

6. ✅ **Design Principle:** UX parity between both flows (learn once, use everywhere)

### Dashboard & Analytics:
7. ✅ **DASHBOARD METRICS VALIDATED:** 5 MVP metrics for v1.0 (summary card, 2 streaks, intensity trend, top triggers), with 6 additional metrics available as DashboardData computed properties for v1.1+

### Scope Decisions:
8. ✅ **THC Potency Tracking:** SKIP (false precision, bogus data)
9. ✅ **Medical vs Recreational:** SKIP (triggers capture "why" better, reduces stigma)
10. ✅ **Goal Tracking:** DEFER TO POST-MVP (focus on polished logging first)

**What's Next (When You Return):**
1. 🚧 **Create UX_FLOW_SPEC.md** - Map complete screen-by-screen flows (wireframes)
2. 🚧 **Create DATA_MODEL_SPEC.md** (SwiftData schemas for all models)
3. 🚧 **Create TECHNICAL_IMPLEMENTATION.md** (map features to repos/use cases/views)

**When You Resume:**
- Move to UX_FLOW_SPEC.md to document screen-by-screen flows with all validated data
- All clinical questions resolved - ready for technical specs!

**Status:** CLINICAL SPEC 100% COMPLETE - Build-ready! 🔥🔥🔥
