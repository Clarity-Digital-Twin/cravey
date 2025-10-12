# Cravey MVP Product Specification

**Version:** 1.0
**Last Updated:** 2025-10-12
**Status:** v1.0 - Locked & Ready for Implementation

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
- May be tech-savvy enough to use their own AI API key for coaching

---

## Core Problems Solved

1. **Hard to track cravings AND cannabis use without judgment or data privacy concerns**
   → Most apps require cloud accounts or sell data. Users want local-only tracking. Crucially, users need to log *cravings* (whether resisted or not) to celebrate wins and understand triggers.

2. **Hard to resist cravings in the moment**
   → Users want to record motivational content when sober (video/audio messages to their future self) and replay during cravings.

3. **Hard to see patterns and progress over time**
   → Users want visual metrics (charts, trends) to understand their usage behavior and craving patterns.

4. **Hard to access non-judgmental support**
   → Users want an MI-trained AI coach available 24/7, but without sharing data with the app maker.

5. **Hard to stay motivated without clear goals**
   → Users want to set their own goals (quit, reduce, monitor) and track progress toward them—without shame when goals shift.

---

## MVP Features (v1.0)

### 0. First Launch & Goal Setting
**User Story:**
*"When I open the app for the first time, I want to understand what it does, set my personal goal, and grant only the permissions I'm comfortable with."*

**Functionality:**
- **Welcome Screen**
  - Brief intro: "Private, local-only cannabis tracking and support"
  - Privacy guarantee: "No cloud sync, no analytics, no data collection"
- **Goal Selection**
  - "What brings you here today?"
    - 🎯 **Quit Completely** - "I want to stop using cannabis"
    - 📉 **Cut Down** - "I want to reduce my usage"
    - 📊 **Monitor Use** - "I want to understand my patterns"
    - 🤝 **Harm Reduction** - "I want to use more intentionally"
    - 👀 **Just Exploring** - "I'm checking this out"
  - User can change goal later in Settings
- **Permission Requests**
  - Camera/Microphone (for motivational recordings)
  - Explained with clear "Why we need this" text
  - All permissions optional (app works without them)
- **Quick Tour** (Optional, Skippable)
  - 3-screen walkthrough of core features
  - "Log Cravings → Record Motivational Videos → See Your Progress"

**Why It Matters:**
Sets user expectations, builds trust around privacy, and personalizes the experience from Day 1. Users feel in control.

---

### 1. Craving Logging
**User Story:**
*"I want to log when I experience a craving—whether I resist it or give in—so I can understand triggers and celebrate moments of resistance."*

**Functionality:**
- **Ultra-Fast Input** - Log in <5 seconds (faster than usage logging)
  - Big red "Log Craving" button on home screen
  - Opens quick form with minimal fields
- **Data Captured:**
  - **Timestamp** - Auto-populated (not editable)
  - **Intensity** - 1-10 slider (required)
  - **Trigger** - Quick-select chips (optional)
    - Stress, Boredom, Social, Anxiety, Habit, Seeing Paraphernalia, Other
  - **Outcome** - Single-tap choice (required)
    - ✅ Resisted (green) - "I didn't use"
    - ⏸️ Still Deciding (yellow) - "I'm working through it"
    - 🔗 Used (blue) - "I used" (links to usage log if user taps)
  - **Duration** - Optional timer or manual input ("How long did it last?")
  - **Notes** - Optional freeform text
- **Link to Usage Log** - If outcome = "Used," prompt: "Log what you used?" (opens usage form with pre-filled timestamp)
- **Instant Feedback** - After logging:
  - If Resisted: "💪 That's strength. Every moment counts."
  - If Still Deciding: "🤝 Take your time. You've got this."
  - If Used: "📊 Thanks for logging. Patterns help."

**Why It Matters:**
**Logging cravings—especially resisted ones—is THE core feature.** It reframes urges as *data points*, not failures. A resisted craving is a WIN to celebrate. This builds self-efficacy and helps users identify triggers before they use.

---

### 2. Cannabis Usage Logging
**User Story:**
*"I want to quickly log when and how I use cannabis so I can see patterns over time."*

**Functionality:**
- **Fast input form** - Log in <10 seconds
- **Data Captured:**
  - **Date/Time** - Auto-populated, editable
  - **Method (ROA)** - Single-tap selection (simplified to 5 categories)
    - 💨 **Smoke** (joint, blunt, bowl, bong, pipe)
    - 🌬️ **Vape** (concentrate pen, cartridge)
    - 💎 **Dab** (rig, e-nail)
    - 🍫 **Edible** (gummies, brownies, drinks)
    - ➕ **Other** (custom, e.g., tincture, topical)
  - **Amount** - Context-aware based on method (see Data Dictionary in Appendix A)
    - *Smoke:* Half / Full (bowl, joint, etc.)
    - *Vape:* Short Hit / Long Hit / Multiple Hits
    - *Dab:* Small / Medium / Large
    - *Edible:* Dose in mg (e.g., 5mg, 10mg) or "Unknown"
    - *Other:* Freeform text
  - **Context/Trigger** - Optional quick-select chips
    - Stress, Social, Boredom, Anxiety, Celebration, Habit, Other
  - **Mood After** - Optional 1-10 slider ("How do you feel now?")
  - **Notes** - Optional freeform text

**Why It Matters:**
Understanding *when*, *how*, and *why* they use helps users identify patterns and make informed decisions about their consumption. Simplified ROA reduces friction while capturing meaningful data.

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

**Functionality:**
- **Visual Charts** (Swift Charts) - Minimum 7 days of data to display meaningful trends
  - **Usage Frequency** - Bar chart showing daily/weekly usage count
  - **Craving Patterns** - Line chart showing craving count and intensity over time
  - **Resistance Rate** - Percentage of cravings resisted vs. used (pie chart or percentage)
  - **Method Breakdown** - Donut chart showing ROA distribution (e.g., "60% Smoke, 30% Vape, 10% Edible")
- **Progress Stats** (at-a-glance cards)
  - **Days in Progress** - Total days using the app (never resets, always counts up)
  - **Days Since Last Use** - Factual counter (if quitting)
  - **Cravings Resisted** - Total count of ✅ Resisted outcomes
  - **Total Sessions Logged** - Combined usage + craving entries
  - **Reduction %** - Comparison of usage frequency (this week vs. first week)
- **Empty States** - If <7 days of data: "Keep logging! You'll see trends after 7 days."
- **Date Range Filter** - Toggle between 7 days / 30 days / 90 days / All Time

**Why It Matters:**
Seeing patterns helps users make intentional changes. Visual feedback motivates continued progress. **Tracking resistance rate celebrates wins and builds self-efficacy.** "Days in Progress" never resets—avoiding the psychological harm of "broken streaks."

---

### 5. Optional AI Support (Bring Your Own API Key)
**User Story:**
*"I want to chat with an MI-trained coach without sharing my data with the app developer."*

**Functionality:**
- **User Provides API Key** - OpenAI or Anthropic (user's own account)
  - Stored securely in iOS Keychain with biometric protection
  - Input validation detects key format (sk-... for OpenAI, sk-ant-... for Anthropic)
- **Fixed MI System Prompt** - Pre-configured, tested prompt (not customizable in MVP)
  - Motivational Interviewing expert for cannabis cravings
  - Non-judgmental, reflective listening, open-ended questions
  - Supports user autonomy and goal flexibility
- **Simple Chat Interface**
  - Text-only messages
  - Ephemeral sessions (no persistent conversation history for MVP)
  - Clear error messages for invalid keys, rate limits, or quota issues
- **Local Storage Only** - No chat data sent to Cravey servers (only to user's chosen AI provider)
- **Fully Optional** - Users can skip this feature entirely

**Why It Matters:**
24/7 access to evidence-based support without sacrificing privacy. Users control their own API costs and data. BYOK eliminates "free service = you're the product" problem.

---

### 6. Data Management
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

### Not Included in v1.0:
- **Cloud sync** - 100% local-only for privacy
- **Push notifications** - No reminders, no check-ins (reduces complexity, maintains privacy)
- **Location tracking** - No GPS logging (use freeform notes for context instead)
- **Time-of-day insights** - No "you use most at 7pm" analytics (defer to v2)
- **Persistent AI chat history** - Ephemeral sessions only for MVP
- **Customizable AI prompts** - Fixed, tested MI prompt only
- **Granular ROA subcategories** - 5 main categories only (no "joint vs. blunt" distinction)
- **Mood tracking before use** - Only "Mood After" (optional)
- **Social features** - No sharing, no community forums
- **Prescription tracking** - Medical cannabis features (future consideration)
- **macOS version** - iOS-only first (macOS planned for future)
- **Pre-populated motivational quotes** - User-generated content only (may add later)
- **Integration with other apps** - No HealthKit, no calendar sync (future consideration)
- **Accessibility audit** - Will add VoiceOver/Dynamic Type support in v1.1 after user testing

---

## Success Criteria

### Technical Success (Testable)

v1.0 MVP is technically successful if:

1. **User can log craving in <5 seconds** - Timed via user testing (from home screen to "saved")
2. **User can log cannabis use in <10 seconds** - Timed via user testing
3. **User can record 60-second video without crashes** - Tested on iPhone 17 Pro (iOS 18+)
4. **User can view charts with 14+ days of data** - All charts render correctly with sample data
5. **User with valid API key can send/receive AI messages** - Tested with OpenAI and Anthropic keys
6. **Zero network calls except to user's AI endpoint** - Verified via Xcode Network Debug or proxy
7. **Data persists across app restarts** - SwiftData persistence confirmed
8. **Export produces valid CSV/JSON** - Files can be opened in Numbers/Excel or parsed programmatically

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

1. **No Data Collection** - App never sends usage data to any server (except user's own AI API)
2. **No Analytics** - No Firebase, no Mixpanel, no tracking SDKs
3. **No Ads** - Never monetized via ads or data sales
4. **Local-Only Storage** - SwiftData with CloudKit disabled (`.none`)
5. **API Key Security** - User's AI keys stored in iOS Keychain with biometric protection
6. **No Push Notifications** - No reminders or check-ins (privacy + simplicity)
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
- **Storage:** SwiftData (local-only)
- **UI:** SwiftUI
- **Recording:** AVFoundation
- **Charts:** Swift Charts
- **AI:** User's own API key (OpenAI/Anthropic)

---

## Next Steps

### Immediate (Planning Phase)
1. ✅ **AI Agent Review** - Completed (agent provided critical feedback)
2. ✅ **Converge on Final Version** - Incorporated all must-have changes
3. **Lock v1.0 Spec** - This document is now locked and ready for implementation
4. **Create `DATA_MODEL_SPEC.md`** - Define exact SwiftData schemas for CravingModel, UsageModel, RecordingModel, MotivationalMessageModel
5. **Create `UX_FLOW_SPEC.md`** - Wireframe user journeys (onboarding, logging flows, dashboard navigation)
6. **Create `TECHNICAL_IMPLEMENTATION.md`** - Map features to repos/use cases/views, define implementation order

### Phase 1: Core Functionality (Weeks 1-4)
1. Implement Craving Logging (View + ViewModel + Use Cases)
2. Implement Usage Logging (View + ViewModel + Use Cases)
3. Implement Goal Setting & Onboarding Flow
4. Implement Data Management (export/delete)

### Phase 2: Recordings & Dashboard (Weeks 5-8)
1. Implement AVFoundation Recording (video/audio capture)
2. Implement Playback UI
3. Implement Progress Dashboard (Swift Charts)
4. Implement Progress Stats calculations

### Phase 3: AI & Polish (Weeks 9-12)
1. Implement BYOK AI Chat
2. Implement iOS Keychain integration
3. UI/UX polish (animations, empty states, error handling)
4. User testing and iteration

### Phase 4: Launch Prep (Weeks 13-16)
1. TestFlight beta with target users
2. Incorporate feedback
3. App Store assets (screenshots, description, privacy policy)
4. Submit to App Store

---

## Appendix A: Data Dictionary

### ROA (Route of Administration) Amount Details

#### 💨 Smoke
- **Half** - Half bowl, half joint, few puffs
- **Full** - Full bowl, full joint, full blunt

#### 🌬️ Vape
- **Short Hit** - 1-2 second inhale
- **Long Hit** - 3-5+ second inhale
- **Multiple Hits** - Several consecutive hits

#### 💎 Dab
- **Small** - Rice grain size
- **Medium** - Pea size
- **Large** - Larger than pea

#### 🍫 Edible
- **Dose (mg)** - Numeric input (e.g., 5mg, 10mg, 25mg)
- **Unknown** - User doesn't know dosage

#### ➕ Other
- **Freeform Text** - User describes (e.g., "1 dropper tincture," "topical cream")

### Craving Trigger Categories
- **Stress** - Work, family, finances, health
- **Boredom** - Nothing to do, understimulated
- **Social** - Friends using, peer pressure, FOMO
- **Anxiety** - Worry, panic, unease
- **Habit** - Routine, automatic behavior (e.g., "always smoke at 8pm")
- **Seeing Paraphernalia** - Visual cue (bong, lighter, dealer's contact)
- **Other** - Freeform text

### Usage Context/Trigger Categories
(Same as Craving Triggers, plus:)
- **Celebration** - Good news, achievement, party

---

**Status:** v1.0 LOCKED & READY FOR IMPLEMENTATION 🚀🔥
